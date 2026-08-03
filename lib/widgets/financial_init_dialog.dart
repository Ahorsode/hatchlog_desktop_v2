import 'package:drift/drift.dart' hide Column, Batch;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../data/local_db.dart';
import '../data/sync_engine.dart';
import '../utils/farm_utils.dart';
import '../utils/id_utils.dart';

class _OtherExpenseRow {
  _OtherExpenseRow({String label = '', String amount = ''})
      : labelController = TextEditingController(text: label),
        amountController = TextEditingController(text: amount);

  final TextEditingController labelController;
  final TextEditingController amountController;

  void dispose() {
    labelController.dispose();
    amountController.dispose();
  }
}

class FinancialInitDialog extends StatefulWidget {
  final Batch batch;
  const FinancialInitDialog({super.key, required this.batch});

  @override
  State<FinancialInitDialog> createState() => _FinancialInitDialogState();
}

class _FinancialInitDialogState extends State<FinancialInitDialog> {
  final _costPerUnitController = TextEditingController();
  final _carriageController = TextEditingController();
  final _otherExpenses = <_OtherExpenseRow>[];

  double _totalCost = 0.0;

  @override
  void initState() {
    super.initState();
    _costPerUnitController.addListener(_calculateTotal);
    _carriageController.addListener(_calculateTotal);
  }

  @override
  void dispose() {
    _costPerUnitController.dispose();
    _carriageController.dispose();
    for (final row in _otherExpenses) {
      row.dispose();
    }
    super.dispose();
  }

  void _calculateTotal() {
    final qty = widget.batch.initialCount;
    final cpu = double.tryParse(_costPerUnitController.text) ?? 0.0;
    final carriage = double.tryParse(_carriageController.text) ?? 0.0;
    final other = _otherExpenses.fold<double>(
      0,
      (sum, row) => sum + (double.tryParse(row.amountController.text) ?? 0),
    );

    setState(() {
      _totalCost = (qty * cpu) + carriage + other;
    });
  }

  bool get _canSave {
    final cpu = double.tryParse(_costPerUnitController.text) ?? 0.0;
    return cpu > 0;
  }

  Future<bool> _saveCosts(BuildContext context) async {
    if (!_canSave) return false;
    final db = Provider.of<AppDatabase>(context, listen: false);

    try {
      final farmId = await FarmUtils.getBoundFarmId();
      final workerId = await FarmUtils.getRequiredUserId();
      if (farmId == null) return false;

      await (db.update(db.batches)..where((t) => t.id.equals(widget.batch.id)))
          .write(
        BatchesCompanion(
          initialActualCost: Value(_totalCost),
          updatedAt: Value(DateTime.now()),
          synced: const Value(false),
        ),
      );

      await db.into(db.expenses).insert(
        ExpensesCompanion.insert(
          id: newLocalId(),
          farmId: farmId,
          batchId: Value(widget.batch.id),
          category: 'LIVESTOCK_PURCHASE',
          amount: _totalCost,
          date: Value(DateTime.now()),
          description: Value(
            'Initial batch cost — ${widget.batch.batchName}',
          ),
          userId: Value(workerId),
          synced: const Value(false),
        ),
      );

      if (!context.mounted) return true;
      context.read<SyncEngine>().syncNow();
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Financial data initialized successfully'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return true;
    } catch (e) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 550,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBatchSummary(),
                      const SizedBox(height: 32),
                      _buildInputField(
                        'Cost Per Unit (Bird)',
                        _costPerUnitController,
                        Icons.payments_outlined,
                      ),
                      const SizedBox(height: 24),
                      _buildInputField(
                        'Carriage / Transport',
                        _carriageController,
                        Icons.local_shipping_outlined,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'OTHER EXPENSES',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              color: Color(0xFF10B981),
                              letterSpacing: 1,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                final row = _OtherExpenseRow();
                                row.amountController.addListener(_calculateTotal);
                                _otherExpenses.add(row);
                              });
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add row'),
                          ),
                        ],
                      ),
                      ..._otherExpenses.map(
                        (row) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: row.labelController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    hintText: 'Label',
                                    filled: true,
                                    fillColor: Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: row.amountController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d*'),
                                    ),
                                  ],
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    prefixText: 'GH₵ ',
                                    filled: true,
                                    fillColor: Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    row.dispose();
                                    _otherExpenses.remove(row);
                                    _calculateTotal();
                                  });
                                },
                                icon: const Icon(Icons.close, color: Colors.white54),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Divider(color: Colors.white.withValues(alpha: 0.1)),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL ACTUAL COST',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  color: Color(0xFF94A3B8),
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            NumberFormat.currency(symbol: 'GH₵ ').format(_totalCost),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 32,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('SKIP FOR NOW'),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 2,
                            child: FilledButton(
                              onPressed: _canSave ? () => _saveCosts(context) : null,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                              ),
                              child: const Text('SAVE INITIAL COSTS'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.account_balance_wallet_rounded, color: Colors.amber, size: 28),
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FINANCIAL INITIALIZATION',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'SET UP INITIAL BATCH COSTS',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBatchSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('BATCH NAME', style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
              Text(
                widget.batch.batchName,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('INITIAL QUANTITY', style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
              Text(
                '${widget.batch.initialCount} birds',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 10,
            color: Color(0xFF10B981),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
            prefixText: 'GH₵ ',
            filled: true,
            fillColor: const Color(0xFF1E293B),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
