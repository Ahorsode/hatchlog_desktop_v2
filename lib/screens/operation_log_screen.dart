import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' hide Column, Batch;
import 'package:flutter/services.dart';
import '../data/local_db.dart';
import '../utils/farm_utils.dart';
import '../utils/id_utils.dart';
import '../utils/inventory_constants.dart';

enum OperationType { feeding, mortality, eggs }

class OperationLogScreen extends StatefulWidget {
  final OperationType type;
  const OperationLogScreen({super.key, required this.type});

  @override
  State<OperationLogScreen> createState() => _OperationLogScreenState();
}

class _OperationLogScreenState extends State<OperationLogScreen> {
  final _valueController = TextEditingController();
  String? _selectedBatchId;
  String? _selectedFeedTypeId;
  String? _selectedFormulationId;

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final cs = Theme.of(context).colorScheme;
    final theme = _getTheme();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(theme.title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: cs.onSurface)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Info
                Text(theme.subtitle, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16)),
                const SizedBox(height: 32),

                // Form Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10))
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: Batch Selection
                        _buildLabel('Select Target Batch'),
                        const SizedBox(height: 12),
                        StreamBuilder<List<Batch>>(
                          stream: (db.select(db.batches)..where((t) => t.status.equals('active'))).watch(),
                          builder: (context, snapshot) {
                            final batches = snapshot.data ?? [];
                            final validBatch = batches.any((b) => b.id == _selectedBatchId);
                            return DropdownButtonFormField<String>(
                              initialValue: validBatch ? _selectedBatchId : null,
                              hint: Text('Choose an active batch', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
                              dropdownColor: Colors.white,
                              alignment: AlignmentDirectional.bottomStart,
                              menuMaxHeight: 300,
                              items: batches.map((b) => DropdownMenuItem<String>(
                                value: b.id, 
                                child: Text(b.batchName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))
                              )).toList(),
                              onChanged: (v) => setState(() => _selectedBatchId = v),
                              decoration: _inputDecoration(Icons.layers_rounded, context),
                            );
                          },
                        ),
                        const SizedBox(height: 32),

                        // Conditional Feeding Fields
                        if (widget.type == OperationType.feeding) ...[
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Feed Type'),
                                    const SizedBox(height: 12),
                                    StreamBuilder<List<InventoryItem>>(
                                      stream: (db.select(db.inventory)..where((t) => t.category.equals(kFeedInventoryCategory))).watch(),
                                      builder: (context, snapshot) {
                                        final types = snapshot.data ?? [];
                                        final validType = types.any((t) => t.id == _selectedFeedTypeId);
                                        return DropdownButtonFormField<String>(
                                          initialValue: validType ? _selectedFeedTypeId : null,
                                          hint: const Text('Select Feed', style: TextStyle(fontSize: 14)),
                                          dropdownColor: Colors.white,
                                          alignment: AlignmentDirectional.bottomStart,
                                          menuMaxHeight: 300,
                                          items: types.map((t) => DropdownMenuItem<String>(
                                            value: t.id, 
                                            child: Text(t.itemName, style: const TextStyle(fontSize: 14))
                                          )).toList(),
                                          onChanged: (v) => setState(() => _selectedFeedTypeId = v),
                                          decoration: _inputDecoration(Icons.restaurant_menu_rounded, context),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Feed Formulation'),
                                    const SizedBox(height: 12),
                                    StreamBuilder<List<FeedFormulation>>(
                                      stream: db.select(db.feedFormulations).watch(),
                                      builder: (context, snapshot) {
                                        final forms = snapshot.data ?? [];
                                        final validForm = forms.any((f) => f.id == _selectedFormulationId);
                                        return DropdownButtonFormField<String>(
                                          initialValue: validForm ? _selectedFormulationId : null,
                                          hint: const Text('Select Formula', style: TextStyle(fontSize: 14)),
                                          dropdownColor: Colors.white,
                                          alignment: AlignmentDirectional.bottomStart,
                                          menuMaxHeight: 300,
                                          items: forms.map((f) => DropdownMenuItem<String>(
                                            value: f.id, 
                                            child: Text(f.name, style: const TextStyle(fontSize: 14))
                                          )).toList(),
                                          onChanged: (v) => setState(() => _selectedFormulationId = v),
                                          decoration: _inputDecoration(Icons.science_rounded, context),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                        ],

                        // Row 2: Value Input
                        _buildLabel(theme.valueLabel),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _valueController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                          decoration: _inputDecoration(theme.icon, context, suffix: widget.type == OperationType.feeding ? 'KG' : null),
                        ),
                        
                        const SizedBox(height: 48),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 64,
                          child: FilledButton(
                            onPressed: () => _submitLog(db),
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.color,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                              shadowColor: theme.color.withValues(alpha: 0.4),
                            ),
                            child: Text('LOG ${theme.title.toUpperCase()}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Helper Card
                if (widget.type == OperationType.feeding)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb_outline_rounded, color: Colors.blue.shade700),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Logging feed correctly helps track cost-per-bird and growth efficiency accurately.',
                            style: TextStyle(color: Color(0xFF1E40AF), fontWeight: FontWeight.w600, fontSize: 13),
                          ),
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

  Widget _buildLabel(String text) {
    return Text(text, 
      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF64748B), letterSpacing: 0.5));
  }

  InputDecoration _inputDecoration(IconData icon, BuildContext context, {String? suffix}) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      prefixIcon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Icon(icon, color: const Color(0xFF64748B), size: 20),
      ),
      suffixText: suffix,
      suffixStyle: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: cs.primary, width: 2)),
      contentPadding: const EdgeInsets.all(20),
    );
  }

  _OperationTheme _getTheme() {
    switch (widget.type) {
      case OperationType.feeding:
        return _OperationTheme(title: 'Feeding Log', subtitle: 'Record daily feed consumption and formulation details.',
            valueLabel: 'AMOUNT CONSUMED', icon: Icons.scale_rounded, color: const Color(0xFF2563EB));
      case OperationType.mortality:
        return _OperationTheme(title: 'Mortality Record', subtitle: 'Track bird losses to monitor flock health.',
            valueLabel: 'NUMBER OF BIRDS LOST', icon: Icons.remove_circle_outline_rounded, color: const Color(0xFFDC2626));
      case OperationType.eggs:
        return _OperationTheme(title: 'Egg Production', subtitle: 'Log daily egg collection and quality grades.',
            valueLabel: 'TOTAL EGGS COLLECTED', icon: Icons.egg_outlined, color: const Color(0xFFD97706));
    }
  }

  Future<void> _submitLog(AppDatabase db) async {
    if (_selectedBatchId == null) {
      _showError('Please select a batch');
      return;
    }
    
    final valueStr = _valueController.text;
    if (valueStr.isEmpty) {
      _showError('Please enter a value');
      return;
    }

    final farmId = await FarmUtils.getBoundFarmId();
    final workerId = await FarmUtils.getRequiredUserId();
    if (farmId == null) {
      _showError('Farm ID not found');
      return;
    }

    final value = double.tryParse(valueStr) ?? 0;
    if (value <= 0) {
      _showError('Value must be greater than zero');
      return;
    }

    try {
      switch (widget.type) {
        case OperationType.feeding:
          await db.into(db.feedingLogs).insert(FeedingLogsCompanion.insert(
              id: newLocalId(),
              farmId: farmId,
              batchId: Value(_selectedBatchId),
              feedTypeId: Value(_selectedFeedTypeId),
              formulationId: Value(_selectedFormulationId),
              amountConsumed: value,
              logDate: DateTime.now(),
              userId: Value(workerId),
              synced: const Value(false)));
          break;
        case OperationType.mortality:
          await db.into(db.mortalities).insert(MortalitiesCompanion.insert(
              id: newLocalId(),
              farmId: farmId,
              batchId: _selectedBatchId!,
              count: value.toInt(),
              logDate: DateTime.now(),
              userId: Value(workerId),
              synced: const Value(false)));
          break;
        case OperationType.eggs:
          await db.into(db.eggProductions).insert(EggProductionsCompanion.insert(
              id: newLocalId(),
              farmId: farmId,
              batchId: _selectedBatchId!,
              eggsCollected: value.toInt(),
              logDate: DateTime.now(),
              userId: Value(workerId),
              synced: const Value(false)));
          break;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text('${_getTheme().title} saved successfully', style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(20),
        ));
        _valueController.clear();
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(20),
    ));
  }
}

class _OperationTheme {
  final String title, subtitle, valueLabel;
  final IconData icon;
  final Color color;
  _OperationTheme({required this.title, required this.subtitle, required this.valueLabel, required this.icon, required this.color});
}
