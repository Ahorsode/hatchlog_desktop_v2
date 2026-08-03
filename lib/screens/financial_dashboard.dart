import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/local_db.dart';
import '../data/sync_engine.dart';
import '../services/auth_service.dart';
import '../utils/farm_utils.dart';
import '../utils/id_utils.dart';
import '../services/finance_category_labels.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/session_mode_badge.dart';
import 'offline_terminal_login_screen.dart';

class FinancialDashboard extends StatefulWidget {
  const FinancialDashboard({super.key});

  @override
  State<FinancialDashboard> createState() => _FinancialDashboardState();
}

class _FinancialDashboardState extends State<FinancialDashboard> {
  int _selectedIndex = 0;
  bool _collapsed = false;

  static const _sections = [
    SidebarMenuSection(
      title: 'ACCOUNTING',
      items: [
        SidebarMenuItem(
          index: 0,
          icon: Icons.assessment_rounded,
          label: 'Ledger Dashboard',
        ),
      ],
    ),
  ];

  final List<Widget> _pages = const [_FinancialHome()];

  void _selectPage(int index) {
    if (index < 0 || index >= _pages.length) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final syncEngine = context.watch<SyncEngine>();

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 1000;
          final collapsed = _collapsed || narrow;
          return Row(
            children: [
              AppSidebar(
                selectedIndex: _selectedIndex,
                isCollapsed: collapsed,
                onToggleCollapse: () =>
                    setState(() => _collapsed = !_collapsed),
                onDestinationSelected: _selectPage,
                onLogout: () => _logout(context),
                sessionMode: SessionModeBadge(compact: collapsed),
                syncStatus: Tooltip(
                  message: syncEngine.isSyncing
                      ? 'Synchronizing data...'
                      : 'Click to sync now',
                  child: InkWell(
                    onTap: syncEngine.isSyncing ? null : syncEngine.syncNow,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            syncEngine.isSyncing
                                ? Icons.sync_rounded
                                : Icons.cloud_done_rounded,
                            color: const Color(0xFF22C55E),
                            size: 16,
                          ),
                          if (!collapsed) ...[
                            const SizedBox(width: 8),
                            const Flexible(
                              child: Text(
                                'CLOUD SYNC',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  color: Color(0xFF22C55E),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                sections: _sections,
              ),
              const VerticalDivider(
                thickness: 1,
                width: 1,
                color: Colors.black12,
              ),
              Expanded(child: _pages[_selectedIndex]),
            ],
          );
        },
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      debugPrint('Supabase signout warning: $e');
    }
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_role');
    await UserSession().clearSession();

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OfflineTerminalLoginScreen()),
      (route) => false,
    );
  }
}

class _FinancialHome extends StatefulWidget {
  const _FinancialHome();

  @override
  State<_FinancialHome> createState() => _FinancialHomeState();
}

class _FinancialHomeState extends State<_FinancialHome> {
  static final _currency = NumberFormat.currency(
    symbol: 'GHS ',
    decimalDigits: 2,
  );
  static const _expenseCategories = expenseEnumCategories;
  static const _revenueSources = revenueCategories;

  final _expenseAmountController = TextEditingController();
  final _expenseDescriptionController = TextEditingController();
  final _saleQuantityController = TextEditingController();
  final _saleUnitController = TextEditingController();
  final _saleMemoController = TextEditingController();

  String _expenseCategory = _expenseCategories.first;
  String _revenueSource = _revenueSources.first;
  DateTime _expenseDate = DateTime.now();
  DateTime _saleDate = DateTime.now();
  bool _savingExpense = false;
  bool _savingSale = false;

  @override
  void dispose() {
    _expenseAmountController.dispose();
    _expenseDescriptionController.dispose();
    _saleQuantityController.dispose();
    _saleUnitController.dispose();
    _saleMemoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();

    return Scaffold(
      body: StreamBuilder<List<Sale>>(
        stream: db.select(db.sales).watch(),
        builder: (context, salesSnap) {
          return StreamBuilder<List<Expense>>(
            stream: db.select(db.expenses).watch(),
            builder: (context, expensesSnap) {
              final sales = salesSnap.data ?? const <Sale>[];
              final expenses = expensesSnap.data ?? const <Expense>[];
              final totalRevenue = sales.fold<double>(
                0,
                (sum, sale) => sum + sale.totalAmount,
              );
              final runningExpenses = expenses.fold<double>(
                0,
                (sum, expense) => sum + expense.amount,
              );
              final netMargin = totalRevenue - runningExpenses;
              final entries = _buildLedgerEntries(sales, expenses);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Financial Accountant Ledger',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bookkeeping workspace for cashflow, expenses, sales, and invoices.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _CashflowBalanceCard(
                      totalRevenue: totalRevenue,
                      runningExpenses: runningExpenses,
                      netMargin: netMargin,
                      currency: _currency,
                    ),
                    const SizedBox(height: 18),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final narrow = constraints.maxWidth < 980;
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width: narrow
                                  ? constraints.maxWidth
                                  : (constraints.maxWidth - 16) / 2,
                              child: _LedgerCard(
                                icon: Icons.payments_rounded,
                                title: 'Expense Ingestion Form',
                                accent: const Color(0xFFDC2626),
                                children: [
                                  DropdownButtonFormField<String>(
                                    key: ValueKey(_expenseCategory),
                                    initialValue: _expenseCategory,
                                    isExpanded: true,
                                    decoration: _inputDecoration(
                                      'Expense category',
                                      Icons.category_rounded,
                                    ),
                                    items: _expenseCategories
                                        .map(
                                          (category) => DropdownMenuItem(
                                            value: category,
                                            child: Text(
                                              expenseCategoryLabel(category),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) => setState(
                                      () => _expenseCategory =
                                          value ?? _expenseCategory,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _MoneyField(
                                    controller: _expenseAmountController,
                                    label: 'Amount',
                                  ),
                                  const SizedBox(height: 12),
                                  _DateTimeField(
                                    label: 'Expense date',
                                    value: _expenseDate,
                                    onChanged: (value) =>
                                        setState(() => _expenseDate = value),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _expenseDescriptionController,
                                    decoration: _inputDecoration(
                                      'Description / supplier note',
                                      Icons.notes_rounded,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _SubmitButton(
                                    label: 'Save expense',
                                    saving: _savingExpense,
                                    onPressed: () => _submitExpense(db),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: narrow
                                  ? constraints.maxWidth
                                  : (constraints.maxWidth - 16) / 2,
                              child: _LedgerCard(
                                icon: Icons.receipt_long_rounded,
                                title: 'Sales & Invoice Logger',
                                accent: const Color(0xFF2563EB),
                                children: [
                                  DropdownButtonFormField<String>(
                                    key: ValueKey(_revenueSource),
                                    initialValue: _revenueSource,
                                    isExpanded: true,
                                    decoration: _inputDecoration(
                                      'Revenue source',
                                      Icons.sell_rounded,
                                    ),
                                    items: _revenueSources
                                        .map(
                                          (source) => DropdownMenuItem(
                                            value: source,
                                            child: Text(source),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) => setState(
                                      () => _revenueSource =
                                          value ?? _revenueSource,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _NumberField(
                                          controller: _saleQuantityController,
                                          label: 'Quantity',
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _MoneyField(
                                          controller: _saleUnitController,
                                          label: 'Unit value',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _DateTimeField(
                                    label: 'Revenue date',
                                    value: _saleDate,
                                    onChanged: (value) =>
                                        setState(() => _saleDate = value),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _saleMemoController,
                                    decoration: _inputDecoration(
                                      'Invoice note',
                                      Icons.description_rounded,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _SubmitButton(
                                    label: 'Save invoice entry',
                                    saving: _savingSale,
                                    onPressed: () => _submitSale(db),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    _LedgerTable(entries: entries, currency: _currency),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _submitExpense(AppDatabase db) async {
    final amount = double.tryParse(_expenseAmountController.text.trim()) ?? 0;
    if (amount <= 0) {
      _showMessage('Enter a valid expense amount.', isError: true);
      return;
    }

    setState(() => _savingExpense = true);
    try {
      final farmId = await FarmUtils.getBoundFarmId();
      final workerId = await FarmUtils.getRequiredUserId();
      if (farmId == null) throw Exception('Farm ID not found');

      await db
          .into(db.expenses)
          .insert(
            ExpensesCompanion.insert(
              id: newLocalId(),
              farmId: farmId,
              category: _expenseCategory,
              amount: amount,
              date: Value(_expenseDate),
              description: Value(
                _expenseDescriptionController.text.trim().isEmpty
                    ? null
                    : _expenseDescriptionController.text.trim(),
              ),
              userId: Value(workerId),
              synced: const Value(false),
            ),
          );
      _expenseAmountController.clear();
      _expenseDescriptionController.clear();
      setState(() => _expenseDate = DateTime.now());
      _showMessage('Expense saved.');
    } catch (e) {
      _showMessage('Unable to save expense: $e', isError: true);
    } finally {
      if (mounted) setState(() => _savingExpense = false);
    }
  }

  Future<void> _submitSale(AppDatabase db) async {
    final quantity = int.tryParse(_saleQuantityController.text.trim()) ?? 0;
    final unitValue = double.tryParse(_saleUnitController.text.trim()) ?? 0;
    if (quantity <= 0 || unitValue <= 0) {
      _showMessage('Enter a valid quantity and unit value.', isError: true);
      return;
    }

    setState(() => _savingSale = true);
    try {
      final farmId = await FarmUtils.getBoundFarmId();
      final workerId = await FarmUtils.getRequiredUserId();
      if (farmId == null) throw Exception('Farm ID not found');

      await db
          .into(db.sales)
          .insert(
            SalesCompanion.insert(
              id: newLocalId(),
              farmId: farmId,
              batchId: const Value(null),
              customerId: const Value(null),
              quantity: quantity,
              unitPrice: unitValue,
              totalAmount: quantity * unitValue,
              saleDate: Value(_saleDate),
              userId: Value(workerId),
              synced: const Value(false),
            ),
          );
      _saleQuantityController.clear();
      _saleUnitController.clear();
      _saleMemoController.clear();
      setState(() => _saleDate = DateTime.now());
      _showMessage('Invoice entry saved for $_revenueSource.');
    } catch (e) {
      _showMessage('Unable to save invoice entry: $e', isError: true);
    } finally {
      if (mounted) setState(() => _savingSale = false);
    }
  }

  List<_LedgerEntry> _buildLedgerEntries(
    List<Sale> sales,
    List<Expense> expenses,
  ) {
    final entries = [
      ...sales.map(
        (sale) => _LedgerEntry(
          date: sale.saleDate,
          type: 'Revenue',
          description:
              'Invoice #${sale.id.substring(0, sale.id.length.clamp(0, 8))}',
          amount: sale.totalAmount,
          isRevenue: true,
        ),
      ),
      ...expenses.map(
        (expense) => _LedgerEntry(
          date: expense.date,
          type: 'Expense',
          description: expense.description?.trim().isNotEmpty == true
              ? expense.description!.trim()
              : expenseCategoryLabel(expense.category),
          amount: expense.amount,
          isRevenue: false,
        ),
      ),
    ];
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF16A34A),
      ),
    );
  }
}

class _CashflowBalanceCard extends StatelessWidget {
  final double totalRevenue;
  final double runningExpenses;
  final double netMargin;
  final NumberFormat currency;

  const _CashflowBalanceCard({
    required this.totalRevenue,
    required this.runningExpenses,
    required this.netMargin,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF22C55E).withValues(alpha: 0.35),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth < 860
              ? constraints.maxWidth
              : (constraints.maxWidth - 24) / 3;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _CashflowMetric(
                label: 'Total Revenue',
                value: currency.format(totalRevenue),
                color: const Color(0xFF86EFAC),
                width: width,
              ),
              _CashflowMetric(
                label: 'Running Expenses',
                value: currency.format(runningExpenses),
                color: const Color(0xFFFCA5A5),
                width: width,
              ),
              _CashflowMetric(
                label: 'Current Net Margins',
                value: currency.format(netMargin),
                color: netMargin >= 0
                    ? const Color(0xFF93C5FD)
                    : const Color(0xFFFBBF24),
                width: width,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CashflowMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final double width;

  const _CashflowMetric({
    required this.label,
    required this.value,
    required this.color,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color.withValues(alpha: 0.78),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color accent;
  final List<Widget> children;

  const _LedgerCard({
    required this.icon,
    required this.title,
    required this.accent,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _LedgerTable extends StatelessWidget {
  final List<_LedgerEntry> entries;
  final NumberFormat currency;

  const _LedgerTable({required this.entries, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bookkeeping Ledger Table',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 360,
            child: entries.isEmpty
                ? Center(
                    child: Text(
                      'No ledger entries yet.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : Scrollbar(
                    child: SingleChildScrollView(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.5),
                          ),
                          columns: const [
                            DataColumn(label: Text('DATE')),
                            DataColumn(label: Text('TYPE')),
                            DataColumn(label: Text('DESCRIPTION')),
                            DataColumn(label: Text('AMOUNT')),
                          ],
                          rows: entries.take(80).map((entry) {
                            final amountColor = entry.isRevenue
                                ? const Color(0xFF15803D)
                                : const Color(0xFFDC2626);
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    DateFormat(
                                      'dd MMM yyyy',
                                    ).format(entry.date),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    entry.type,
                                    style: TextStyle(
                                      color: amountColor,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 260,
                                    child: Text(
                                      entry.description,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    currency.format(entry.amount),
                                    style: TextStyle(
                                      color: amountColor,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _LedgerEntry {
  final DateTime date;
  final String type;
  final String description;
  final double amount;
  final bool isRevenue;

  const _LedgerEntry({
    required this.date,
    required this.type,
    required this.description,
    required this.amount,
    required this.isRevenue,
  });
}

class _MoneyField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _MoneyField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: _inputDecoration(label, Icons.account_balance_wallet_rounded),
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _NumberField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: _inputDecoration(label, Icons.pin_rounded),
    );
  }
}

class _DateTimeField extends StatelessWidget {
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  const _DateTimeField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  Future<void> _pick(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(value),
    );
    if (time == null) return;

    onChanged(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: _inputDecoration(label, Icons.event_rounded),
        child: Text(
          DateFormat('dd MMM yyyy, HH:mm').format(value),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final String label;
  final bool saving;
  final VoidCallback onPressed;

  const _SubmitButton({
    required this.label,
    required this.saving,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: FilledButton.icon(
        onPressed: saving ? null : onPressed,
        icon: saving
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save_rounded, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

InputDecoration _inputDecoration(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 18),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
  );
}

BoxDecoration _panelDecoration(BuildContext context) {
  return BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 14,
        offset: const Offset(0, 6),
      ),
    ],
  );
}
