import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/local_db.dart';
import '../data/sync_engine.dart';
import '../widgets/finance_ledger_hub_panel.dart';
import '../widgets/financial_init_wizard.dart';
import '../utils/farm_utils.dart';
import '../utils/id_utils.dart';
import 'package:drift/drift.dart' hide Batch, Column;

class FinancialControlScreen extends StatefulWidget {
  const FinancialControlScreen({super.key});

  @override
  State<FinancialControlScreen> createState() => _FinancialControlScreenState();
}

class _FinancialControlScreenState extends State<FinancialControlScreen> {
  late AppDatabase db;
  bool _hasCheckedInit = false;

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _checkUninitializedBatches(),
    );
  }

  Future<void> _checkUninitializedBatches() async {
    if (_hasCheckedInit) return;
    _hasCheckedInit = true;
    if (!mounted) return;
    await FinancialInitWizard.promptIfNeeded(context);
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'GH₵ ', decimalDigits: 2);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 850;
        return StreamBuilder<List<EggProduction>>(
          stream: db.select(db.eggProductions).watch(),
          builder: (context, eggSnap) {
            return StreamBuilder<List<InventoryItem>>(
              stream: db.select(db.inventory).watch(),
              builder: (context, invSnap) {
                return StreamBuilder<List<Customer>>(
                  stream: db.select(db.customers).watch(),
                  builder: (context, custSnap) {
                    return StreamBuilder<List<Expense>>(
                      stream: db.select(db.expenses).watch(),
                      builder: (context, expSnap) {
                        return StreamBuilder<List<Settlement>>(
                          stream: db.select(db.settlements).watch(),
                          builder: (context, setSnap) {
                            final eggs = eggSnap.data ?? [];
                            final inventory = invSnap.data ?? [];
                            final customers = custSnap.data ?? [];
                            final expenses = expSnap.data ?? [];
                            final settlements = setSnap.data ?? [];

                            const pricePerEgg = 0.40;
                            final totalEggs = eggs.fold(
                              0,
                              (s, e) => s + e.eggsCollected,
                            );
                            final totalRevenue = totalEggs * pricePerEgg;
                            final totalExpenses = expenses.fold(
                              0.0,
                              (s, e) => s + e.amount,
                            );
                            final totalCollections = settlements
                                .where((s) => s.settlementType == 'COLLECTION')
                                .fold(0.0, (s, st) => s + st.amount);
                            final totalPayments = settlements
                                .where((s) => s.settlementType == 'PAYMENT')
                                .fold(0.0, (s, st) => s + st.amount);
                            final netCashflow =
                                totalRevenue +
                                totalCollections -
                                totalExpenses -
                                totalPayments;
                            final stockValue = inventory.fold(
                              0.0,
                              (s, i) =>
                                  s + (i.stockLevel * (i.costPerUnit ?? 0.0)),
                            );
                            final totalReceivables = customers
                                .where((c) => c.customerType == 'CUSTOMER')
                                .fold(0.0, (s, c) => s + c.balanceOwed);
                            final totalPayables = customers
                                .where((c) => c.customerType == 'SUPPLIER')
                                .fold(0.0, (s, c) => s + c.balanceOwed);

                            final now = DateTime.now();
                            final monthlyData = List.generate(6, (i) {
                              final month = DateTime(
                                now.year,
                                now.month - (5 - i),
                                1,
                              );
                              final monthEggs = eggs
                                  .where(
                                    (e) =>
                                        e.logDate.year == month.year &&
                                        e.logDate.month == month.month,
                                  )
                                  .fold(0, (s, e) => s + e.eggsCollected);
                              return FlSpot(
                                i.toDouble(),
                                (monthEggs * pricePerEgg),
                              );
                            });

                            final monthLabels = List.generate(6, (i) {
                              final month = DateTime(
                                now.year,
                                now.month - (5 - i),
                                1,
                              );
                              return DateFormat('MMM').format(month);
                            });

                            return Scaffold(
                              backgroundColor: Theme.of(
                                context,
                              ).scaffoldBackgroundColor,
                              body: SingleChildScrollView(
                                padding: EdgeInsets.all(isNarrow ? 16 : 32),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Financial Control',
                                      style: TextStyle(
                                        fontSize: isNarrow ? 24 : 28,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      'Operational insight & performance metrics',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 32),

                                    Wrap(
                                      spacing: 16,
                                      runSpacing: 16,
                                      children: [
                                        SizedBox(
                                          width: isNarrow
                                              ? (constraints.maxWidth - 32)
                                              : (constraints.maxWidth -
                                                        64 -
                                                        32) /
                                                    3,
                                          child: _kpiCard(
                                            'Net Cashflow',
                                            currency.format(netCashflow),
                                            Icons.account_balance_rounded,
                                            netCashflow >= 0
                                                ? const Color(0xFF16A34A)
                                                : const Color(0xFFDC2626),
                                            'Actual liquid cash position',
                                          ),
                                        ),
                                        SizedBox(
                                          width: isNarrow
                                              ? (constraints.maxWidth - 32)
                                              : (constraints.maxWidth -
                                                        64 -
                                                        32) /
                                                    3,
                                          child: _kpiCard(
                                            'Total Outflow',
                                            currency.format(
                                              totalExpenses + totalPayments,
                                            ),
                                            Icons.trending_down_rounded,
                                            const Color(0xFFDC2626),
                                            'Expenses + Supplier payments',
                                          ),
                                        ),
                                        SizedBox(
                                          width: isNarrow
                                              ? (constraints.maxWidth - 32)
                                              : (constraints.maxWidth -
                                                        64 -
                                                        32) /
                                                    3,
                                          child: _kpiCard(
                                            'Estimated Revenue',
                                            currency.format(totalRevenue),
                                            Icons.analytics_rounded,
                                            const Color(0xFF2563EB),
                                            'Based on egg production value',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 32),

                                    Wrap(
                                      spacing: 16,
                                      runSpacing: 16,
                                      children: [
                                        SizedBox(
                                          width: isNarrow
                                              ? (constraints.maxWidth - 32)
                                              : (constraints.maxWidth -
                                                        64 -
                                                        16) /
                                                    3,
                                          child: _kpiCard(
                                            'Total Receivables',
                                            currency.format(totalReceivables),
                                            Icons.call_received_rounded,
                                            Colors.orange,
                                            'Owed by customers',
                                          ),
                                        ),
                                        SizedBox(
                                          width: isNarrow
                                              ? (constraints.maxWidth - 32)
                                              : (constraints.maxWidth -
                                                        64 -
                                                        16) /
                                                    3,
                                          child: _kpiCard(
                                            'Total Payables',
                                            currency.format(totalPayables),
                                            Icons.call_made_rounded,
                                            Colors.purpleAccent,
                                            'Owed to suppliers',
                                          ),
                                        ),
                                        SizedBox(
                                          width: isNarrow
                                              ? (constraints.maxWidth - 32)
                                              : (constraints.maxWidth -
                                                        64 -
                                                        16) /
                                                    3,
                                          child: _kpiCard(
                                            'Inventory Value',
                                            currency.format(stockValue),
                                            Icons.inventory_2_rounded,
                                            const Color(0xFF3B82F6),
                                            'Value of current stock',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 32),
                                    const FinanceLedgerHubPanel(),
                                    const SizedBox(height: 32),

                                    if (!isNarrow)
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: _buildProductionChart(
                                              monthlyData,
                                              monthLabels,
                                            ),
                                          ),
                                          const SizedBox(width: 24),
                                          Expanded(
                                            flex: 1,
                                            child: _buildStockSummary(
                                              inventory,
                                            ),
                                          ),
                                        ],
                                      )
                                    else ...[
                                      _buildProductionChart(
                                        monthlyData,
                                        monthLabels,
                                      ),
                                      const SizedBox(height: 24),
                                      _buildStockSummary(inventory),
                                    ],
                                    const SizedBox(height: 100),
                                  ],
                                ),
                              ),
                              floatingActionButton:
                                  FloatingActionButton.extended(
                                    onPressed: () =>
                                        _showExpenseDialog(customers),
                                    backgroundColor: const Color(0xFF16A34A),
                                    icon: const Icon(
                                      Icons.add_rounded,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'Add Expense',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _kpiCard(
    String label,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Builder(
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 15,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductionChart(List<FlSpot> data, List<String> labels) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenue Trend (Last 6 Months)',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        if (v.toInt() < 0 || v.toInt() >= labels.length) {
                          return const SizedBox();
                        }
                        return Text(
                          labels[v.toInt()],
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data,
                    isCurved: true,
                    color: const Color(0xFF16A34A),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockSummary(List<InventoryItem> items) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stock Summary',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No inventory records found',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...items
                .take(5)
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.itemName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${item.stockLevel} ${item.unit}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  void _showExpenseDialog(List<Customer> allContacts) {
    showDialog(
      context: context,
      builder: (context) =>
          _DesktopExpenseDialog(db: db, allContacts: allContacts),
    );
  }
}

class _DesktopExpenseDialog extends StatefulWidget {
  final AppDatabase db;
  final List<Customer> allContacts;

  const _DesktopExpenseDialog({required this.db, required this.allContacts});

  @override
  State<_DesktopExpenseDialog> createState() => _DesktopExpenseDialogState();
}

class _DesktopExpenseDialogState extends State<_DesktopExpenseDialog> {
  static const _categories = [
    'Feed',
    'Medication',
    'Labor',
    'Fuel',
    'Utility',
    'Maintenance',
    'Transport',
    'Other',
  ];

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountFocus = FocusNode();
  final _categoryFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _supplierFocus = FocusNode();
  final _batchFocus = FocusNode();
  final Map<String, _AllocationRowState> _allocationRows = {};

  String _selectedCategory = _categories.first;
  Customer? _selectedSupplier;
  Batch? _selectedDirectBatch;
  bool _isCredit = false;
  bool _splitExpense = false;
  bool _pendingEvenSeed = false;
  bool _isSaving = false;
  String? _warning;
  DateTime _transactionDate = DateTime.now();

  List<Customer> get _suppliers {
    return widget.allContacts
        .where((contact) => contact.customerType == 'SUPPLIER')
        .toList();
  }

  double get _baseAmount => double.tryParse(_amountController.text) ?? 0.0;

  double get _totalAllocatedAmount {
    return _allocationRows.values.fold<double>(
      0.0,
      (sum, row) => sum + row.amount,
    );
  }

  double get _totalAllocatedPercent {
    return _allocationRows.values.fold<double>(
      0.0,
      (sum, row) => sum + row.percent,
    );
  }

  bool get _allocationPercentValid {
    return (_totalAllocatedPercent - 100.0).abs() <= 0.01;
  }

  bool get _allocationAmountValid {
    return _cents(_totalAllocatedAmount) == _cents(_baseAmount);
  }

  bool get _canSubmit {
    if (_isSaving || _baseAmount <= 0) return false;
    if (!_splitExpense) return true;
    return _allocationRows.isNotEmpty &&
        _allocationPercentValid &&
        _allocationAmountValid;
  }

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onBaseAmountChanged);
  }

  @override
  void dispose() {
    _amountController
      ..removeListener(_onBaseAmountChanged)
      ..dispose();
    _descriptionController.dispose();
    _amountFocus.dispose();
    _categoryFocus.dispose();
    _descriptionFocus.dispose();
    _supplierFocus.dispose();
    _batchFocus.dispose();
    for (final row in _allocationRows.values) {
      row.dispose();
    }
    super.dispose();
  }

  void _onBaseAmountChanged() {
    if (!_splitExpense) return;
    for (final row in _allocationRows.values) {
      if (row.percentController.text.trim().isEmpty) continue;
      _setRowAmountFromPercent(row);
    }
    setState(() {});
  }

  void _ensureAllocationRows(List<Batch> batches) {
    final activeIds = batches.map((batch) => batch.id).toSet();
    final removedIds = _allocationRows.keys
        .where((id) => !activeIds.contains(id))
        .toList();
    for (final id in removedIds) {
      _allocationRows.remove(id)?.dispose();
    }

    for (final batch in batches) {
      _allocationRows.putIfAbsent(
        batch.id,
        () => _AllocationRowState(batch: batch),
      );
    }

    if (_pendingEvenSeed && _allocationRows.isNotEmpty) {
      _pendingEvenSeed = false;
      _seedEvenAllocation();
    }
  }

  void _seedEvenAllocation() {
    final rows = _allocationRows.values.toList();
    if (rows.isEmpty || _baseAmount <= 0) {
      _pendingEvenSeed = rows.isEmpty;
      return;
    }

    final share = 100.0 / rows.length;
    var assignedAmountCents = 0;
    var assignedPercent = 0.0;

    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final isLast = i == rows.length - 1;
      final percent = isLast ? 100.0 - assignedPercent : share;
      final amountCents = isLast
          ? _cents(_baseAmount) - assignedAmountCents
          : _cents(_baseAmount * percent / 100.0);

      row.setPercent(_formatPercent(percent));
      row.setAmount(_formatControllerAmount(amountCents / 100.0));
      assignedPercent += percent;
      assignedAmountCents += amountCents;
    }
  }

  void _onPercentChanged(_AllocationRowState row, String value) {
    if (row.isUpdating) return;
    row.isUpdating = true;
    _setRowAmountFromPercent(row);
    row.isUpdating = false;
    setState(() {});
  }

  void _onAmountChanged(_AllocationRowState row, String value) {
    if (row.isUpdating) return;
    row.isUpdating = true;
    final percent = _baseAmount > 0 ? (row.amount / _baseAmount) * 100.0 : 0.0;
    row.setPercent(_formatPercent(percent));
    row.isUpdating = false;
    setState(() {});
  }

  void _setRowAmountFromPercent(_AllocationRowState row) {
    final amount = _baseAmount * row.percent / 100.0;
    row.setAmount(_formatControllerAmount(amount));
  }

  int _cents(double value) => (value * 100).round();

  String _formatControllerAmount(double value) => value.toStringAsFixed(2);

  String _formatPercent(double value) {
    final fixed = value.toStringAsFixed(4);
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  String? _validateAmount(String? value) {
    final amount = double.tryParse(value ?? '') ?? 0.0;
    return amount <= 0 ? 'Enter a valid amount' : null;
  }

  Future<void> _pickTransactionDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _transactionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_transactionDate),
    );
    if (time == null || !mounted) return;

    setState(() {
      _transactionDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submit() async {
    setState(() => _warning = null);
    if (!_formKey.currentState!.validate()) return;

    if (_splitExpense &&
        (!_allocationPercentValid || !_allocationAmountValid)) {
      setState(() {
        _warning =
            'Allocation total must equal exactly 100% and match the base expense amount.';
      });
      return;
    }

    final context = this.context;
    final farmId = await FarmUtils.getBoundFarmId();
    final workerId = await FarmUtils.getRequiredUserId();
    if (farmId == null) return;

    setState(() => _isSaving = true);
    final now = DateTime.now();
    final transactionDate = _transactionDate;
    final amount = _baseAmount;
    final baseDescription = _descriptionController.text.trim();
    final supplierName = _selectedSupplier?.name;

    try {
      await widget.db.transaction(() async {
        if (_splitExpense) {
          final allocationGroupId = newLocalId();
          for (final row in _allocationRows.values) {
            if (row.amount <= 0 || row.percent <= 0) continue;
            final description = [
              '[SHARED ALLOCATION: group=$allocationGroupId; percent=${_formatPercent(row.percent)}%; base=${amount.toStringAsFixed(2)}]',
              if (baseDescription.isNotEmpty) baseDescription,
              if (_isCredit && supplierName != null)
                '[CREDIT PURCHASE] $supplierName',
            ].join(' ');

            await widget.db
                .into(widget.db.expenses)
                .insert(
                  ExpensesCompanion.insert(
                    id: newLocalId(),
                    farmId: farmId,
                    batchId: Value(row.batch.id),
                    supplierId: Value(_selectedSupplier?.id),
                    category: _selectedCategory,
                    amount: row.amount,
                    date: Value(transactionDate),
                    description: Value(description),
                    allocationGroupId: Value(allocationGroupId),
                    allocationPercent: Value(row.percent),
                    isSharedAllocation: const Value(true),
                    userId: Value(workerId),
                    synced: const Value(false),
                  ),
                );
          }
        } else {
          final description = [
            if (_isCredit && supplierName != null)
              '[CREDIT PURCHASE] $supplierName',
            if (baseDescription.isNotEmpty) baseDescription,
          ].join(' ');

          await widget.db
              .into(widget.db.expenses)
              .insert(
                ExpensesCompanion.insert(
                  id: newLocalId(),
                  farmId: farmId,
                  batchId: Value(_selectedDirectBatch?.id),
                  supplierId: Value(_selectedSupplier?.id),
                  category: _selectedCategory,
                  amount: amount,
                  date: Value(transactionDate),
                  description: Value(description.isEmpty ? null : description),
                  userId: Value(workerId),
                  synced: const Value(false),
                ),
              );
        }

        if (_isCredit && _selectedSupplier != null) {
          final supplier = _selectedSupplier!;
          await widget.db
              .update(widget.db.customers)
              .replace(
                supplier.copyWith(
                  balanceOwed: supplier.balanceOwed + amount,
                  updatedAt: now,
                  synced: false,
                ),
              );

          await widget.db
              .into(widget.db.settlements)
              .insert(
                SettlementsCompanion.insert(
                  id: newLocalId(),
                  farmId: farmId,
                  customerId: supplier.id,
                  amount: amount,
                  settlementDate: Value(transactionDate),
                  settlementType: 'DEBT_INCURRED',
                  userId: Value(workerId),
                  synced: const Value(false),
                ),
              );
        }
      });

      if (!context.mounted) return;
      unawaited(context.read<SyncEngine>().syncNow());
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _splitExpense
                ? 'Shared expense allocated and queued for sync'
                : 'Expense recorded and queued for sync',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      setState(() {
        _isSaving = false;
        _warning = 'Unable to save expense: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shellColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final subtleBg = isDark ? const Color(0xFF172033) : const Color(0xFFF8FAFC);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180, maxHeight: 760),
        child: Container(
          decoration: BoxDecoration(
            color: shellColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              _buildHeader(context, borderColor),
              Expanded(
                child: StreamBuilder<List<Batch>>(
                  stream:
                      (widget.db.select(widget.db.batches)
                            ..where((t) => t.status.equals('active'))
                            ..orderBy([(t) => OrderingTerm.asc(t.batchName)]))
                          .watch(),
                  builder: (context, snapshot) {
                    final batches = snapshot.data ?? const <Batch>[];
                    _ensureAllocationRows(batches);
                    if (_selectedDirectBatch != null) {
                      final directBatchId = _selectedDirectBatch!.id;
                      final matches = batches
                          .where((b) => b.id == directBatchId)
                          .toList();
                      _selectedDirectBatch = matches.isEmpty
                          ? null
                          : matches.first;
                    }

                    return FocusTraversalGroup(
                      child: Form(
                        key: _formKey,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 392,
                              child: _buildFormPanel(
                                batches: batches,
                                subtleBg: subtleBg,
                                borderColor: borderColor,
                              ),
                            ),
                            VerticalDivider(width: 1, color: borderColor),
                            Expanded(
                              child: _buildAllocationPanel(
                                batches: batches,
                                subtleBg: subtleBg,
                                borderColor: borderColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildFooter(context, borderColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color borderColor) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Color(0xFF16A34A),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expense Workstation',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Local-first entry with batch allocation controls',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildFormPanel({
    required List<Batch> batches,
    required Color subtleBg,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: subtleBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Transaction'),
          const SizedBox(height: 12),
          FocusTraversalOrder(
            order: const NumericFocusOrder(1),
            child: DropdownButtonFormField<String>(
              focusNode: _categoryFocus,
              initialValue: _selectedCategory,
              items: _categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedCategory = value);
              },
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
            ),
          ),
          const SizedBox(height: 14),
          FocusTraversalOrder(
            order: const NumericFocusOrder(2),
            child: TextFormField(
              controller: _amountController,
              focusNode: _amountFocus,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _descriptionFocus.requestFocus(),
              validator: _validateAmount,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: 'GH₵ ',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: _pickTransactionDate,
            borderRadius: BorderRadius.circular(8),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Transaction date',
                prefixIcon: Icon(Icons.event_rounded),
              ),
              child: Text(
                DateFormat('dd MMM yyyy, HH:mm').format(_transactionDate),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 14),
          FocusTraversalOrder(
            order: const NumericFocusOrder(3),
            child: TextFormField(
              controller: _descriptionController,
              focusNode: _descriptionFocus,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.edit_note_rounded),
              ),
            ),
          ),
          const SizedBox(height: 22),
          _sectionLabel('Supplier'),
          const SizedBox(height: 12),
          FocusTraversalOrder(
            order: const NumericFocusOrder(4),
            child: DropdownButtonFormField<Customer?>(
              focusNode: _supplierFocus,
              initialValue: _selectedSupplier,
              items: [
                const DropdownMenuItem(value: null, child: Text('No supplier')),
                ..._suppliers.map(
                  (supplier) => DropdownMenuItem(
                    value: supplier,
                    child: Text(supplier.name),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedSupplier = value;
                  if (value == null) _isCredit = false;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Supplier',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
          ),
          if (_selectedSupplier != null) ...[
            const SizedBox(height: 10),
            SwitchListTile(
              value: _isCredit,
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Buy on credit',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              ),
              subtitle: const Text(
                'Adds this amount to supplier balance',
                style: TextStyle(fontSize: 11),
              ),
              onChanged: (value) => setState(() => _isCredit = value),
            ),
          ],
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(
                  _splitExpense ? Icons.call_split_rounded : Icons.link_rounded,
                  color: const Color(0xFF16A34A),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _splitExpense
                        ? 'Split mode saves allocated rows per batch.'
                        : 'Direct mode can link this expense to one batch.',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationPanel({
    required List<Batch> batches,
    required Color subtleBg,
    required Color borderColor,
  }) {
    final currency = NumberFormat.currency(symbol: 'GH₵ ', decimalDigits: 2);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _sectionLabel('Batch Allocation')),
              SizedBox(
                width: 310,
                child: CheckboxListTile(
                  value: _splitExpense,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text(
                    'Split expense across multiple batches',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _splitExpense = value ?? false;
                      _warning = null;
                      if (_splitExpense) _seedEvenAllocation();
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _splitExpense
                  ? _buildSplitGrid(
                      batches: batches,
                      currency: currency,
                      subtleBg: subtleBg,
                      borderColor: borderColor,
                    )
                  : _buildDirectBatchPanel(
                      batches: batches,
                      subtleBg: subtleBg,
                      borderColor: borderColor,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectBatchPanel({
    required List<Batch> batches,
    required Color subtleBg,
    required Color borderColor,
  }) {
    return Container(
      key: const ValueKey('direct-panel'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: subtleBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FocusTraversalOrder(
            order: const NumericFocusOrder(5),
            child: DropdownButtonFormField<Batch?>(
              focusNode: _batchFocus,
              initialValue: _selectedDirectBatch,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('General expense, no batch link'),
                ),
                ...batches.map(
                  (batch) => DropdownMenuItem(
                    value: batch,
                    child: Text('${batch.batchName} (${batch.id})'),
                  ),
                ),
              ],
              onChanged: (value) =>
                  setState(() => _selectedDirectBatch = value),
              decoration: const InputDecoration(
                labelText: 'Direct batch link',
                prefixIcon: Icon(Icons.layers_outlined),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: batches.isEmpty
                ? _emptyGridState('No active batches available')
                : ListView.separated(
                    itemCount: batches.length,
                    separatorBuilder: (_, index) =>
                        Divider(color: borderColor, height: 1),
                    itemBuilder: (context, index) {
                      final batch = batches[index];
                      final selected = _selectedDirectBatch?.id == batch.id;
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          selected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          size: 18,
                          color: selected
                              ? const Color(0xFF16A34A)
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        title: Text(
                          batch.batchName,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                          '${batch.type.replaceAll('POULTRY_', '')} • ${batch.currentCount} birds',
                        ),
                        onTap: () =>
                            setState(() => _selectedDirectBatch = batch),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitGrid({
    required List<Batch> batches,
    required NumberFormat currency,
    required Color subtleBg,
    required Color borderColor,
  }) {
    final amountDelta = _baseAmount - _totalAllocatedAmount;
    final percentDelta = 100.0 - _totalAllocatedPercent;
    final isValid = _allocationPercentValid && _allocationAmountValid;

    return Column(
      key: const ValueKey('split-panel'),
      children: [
        _allocationStatusBanner(
          isValid: isValid,
          amountDelta: amountDelta,
          percentDelta: percentDelta,
          currency: currency,
        ),
        if (_warning != null) ...[
          const SizedBox(height: 8),
          _warningBanner(_warning!),
        ],
        const SizedBox(height: 10),
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A5F),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: borderColor),
          ),
          child: const Row(
            children: [
              Expanded(flex: 4, child: _GridHeader('Batch Name / ID')),
              Expanded(flex: 2, child: _GridHeader('Allocation %')),
              Expanded(flex: 2, child: _GridHeader('Calculated Amount')),
            ],
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: subtleBg,
              border: Border(
                left: BorderSide(color: borderColor),
                right: BorderSide(color: borderColor),
              ),
            ),
            child: batches.isEmpty
                ? _emptyGridState('No active livestock batches to allocate')
                : ListView.builder(
                    itemCount: batches.length,
                    itemBuilder: (context, index) {
                      final batch = batches[index];
                      final row = _allocationRows[batch.id]!;
                      return _buildAllocationRow(row, index, borderColor);
                    },
                  ),
          ),
        ),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(8),
            ),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              const Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Totals',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${_totalAllocatedPercent.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: _allocationPercentValid
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFDC2626),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  currency.format(_totalAllocatedAmount),
                  style: TextStyle(
                    color: _allocationAmountValid
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFDC2626),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAllocationRow(
    _AllocationRowState row,
    int index,
    Color borderColor,
  ) {
    final bg = index.isEven
        ? Theme.of(context).cardColor
        : Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35);
    return Container(
      height: 54,
      color: bg,
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.batch.batchName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    row.batch.id,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextFormField(
                controller: row.percentController,
                focusNode: row.percentFocus,
                textAlign: TextAlign.right,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,4}')),
                ],
                decoration: const InputDecoration(
                  isDense: true,
                  suffixText: '%',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                ),
                onChanged: (value) => _onPercentChanged(row, value),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextFormField(
                controller: row.amountController,
                focusNode: row.amountFocus,
                textAlign: TextAlign.right,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  isDense: true,
                  prefixText: 'GH₵ ',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                ),
                onChanged: (value) => _onAmountChanged(row, value),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _allocationStatusBanner({
    required bool isValid,
    required double amountDelta,
    required double percentDelta,
    required NumberFormat currency,
  }) {
    final color = isValid ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final message = isValid
        ? 'Allocation balanced at 100% and ${currency.format(_baseAmount)}.'
        : 'Unbalanced: ${percentDelta.toStringAsFixed(2)}% and ${currency.format(amountDelta)} remaining.';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.verified_rounded : Icons.warning_amber_rounded,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          TextButton(
            onPressed: _seedEvenAllocation,
            child: const Text('AUTO BALANCE'),
          ),
        ],
      ),
    );
  }

  Widget _warningBanner(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFDC2626).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFDC2626),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFDC2626),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyGridState(String text) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, Color borderColor) {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          if (_warning != null && !_splitExpense)
            Expanded(child: _warningBanner(_warning!))
          else
            const Spacer(),
          const SizedBox(width: 16),
          TextButton(
            onPressed: _isSaving ? null : () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          const SizedBox(width: 10),
          FilledButton.icon(
            onPressed: _canSubmit ? _submit : null,
            style: FilledButton.styleFrom(
              backgroundColor: _isCredit
                  ? const Color(0xFFE8833A)
                  : const Color(0xFF16A34A),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            ),
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_rounded, size: 18),
            label: Text(
              _isCredit ? 'RECORD CREDIT' : 'SAVE EXPENSE',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF1E3A5F),
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _AllocationRowState {
  final Batch batch;
  final TextEditingController percentController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final FocusNode percentFocus = FocusNode();
  final FocusNode amountFocus = FocusNode();
  bool isUpdating = false;

  _AllocationRowState({required this.batch});

  double get percent => double.tryParse(percentController.text) ?? 0.0;
  double get amount => double.tryParse(amountController.text) ?? 0.0;

  void setPercent(String value) => _setControllerText(percentController, value);

  void setAmount(String value) => _setControllerText(amountController, value);

  void _setControllerText(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  void dispose() {
    percentController.dispose();
    amountController.dispose();
    percentFocus.dispose();
    amountFocus.dispose();
  }
}

class _GridHeader extends StatelessWidget {
  final String label;

  const _GridHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
