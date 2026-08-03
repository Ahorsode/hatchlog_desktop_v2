import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' hide Column, Batch;
import 'package:provider/provider.dart';
import '../data/local_db.dart';
import '../utils/farm_utils.dart';
import '../utils/id_utils.dart';
import '../utils/livestock_breed_options.dart';
import '../utils/mortality_log_utils.dart';
import '../data/sync_engine.dart';
import '../features/sales/sale_line_draft.dart';
import '../services/local_sales_service.dart';
import '../utils/user_role.dart';

const _addHouseSentinel = '__add_new_house__';

class MortalityDialog extends StatefulWidget {
  final Batch batch;
  const MortalityDialog({super.key, required this.batch});

  @override
  State<MortalityDialog> createState() => _MortalityDialogState();
}

class _MortalityDialogState extends State<MortalityDialog> {
  final _countController = TextEditingController();
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedTab = 'mortality'; // 'mortality' or 'isolation'
  House? _selectedHouse;
  String _category = mortalityReasons.keys.first;
  String _subCategory = mortalityReasons.values.first.first;

  @override
  void dispose() {
    _countController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final db = context.watch<AppDatabase>();
    final isIsolation = _selectedTab == 'isolation';
    final activeColor = isIsolation
        ? const Color(0xFFF59E0B)
        : const Color(0xFFEF4444);

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF121417) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      title: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: activeColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIsolation
                  ? Icons.health_and_safety_outlined
                  : Icons.coronavirus_outlined,
              color: activeColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            isIsolation ? 'Isolate & Quarantine' : 'Record Mortality',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontWeight: FontWeight.w900,
              fontSize: 20,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Sliding Segmented Control / Tab Selector
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF23262B)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (_selectedTab != 'mortality') {
                            setState(() {
                              _selectedTab = 'mortality';
                              _countController.clear();
                              _reasonController.clear();
                            });
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 'mortality'
                                ? (isDark
                                      ? const Color(
                                          0xFFEF4444,
                                        ).withValues(alpha: 0.15)
                                      : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _selectedTab == 'mortality'
                                  ? const Color(
                                      0xFFEF4444,
                                    ).withValues(alpha: 0.3)
                                  : Colors.transparent,
                            ),
                            boxShadow: _selectedTab == 'mortality' && !isDark
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.coronavirus_outlined,
                                size: 16,
                                color: _selectedTab == 'mortality'
                                    ? const Color(0xFFEF4444)
                                    : (isDark
                                          ? Colors.white38
                                          : Colors.black38),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'MORTALITY',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  color: _selectedTab == 'mortality'
                                      ? const Color(0xFFEF4444)
                                      : (isDark
                                            ? Colors.white60
                                            : Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (_selectedTab != 'isolation') {
                            setState(() {
                              _selectedTab = 'isolation';
                              _countController.clear();
                              _reasonController.clear();
                              _selectedHouse = null;
                            });
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 'isolation'
                                ? (isDark
                                      ? const Color(
                                          0xFFF59E0B,
                                        ).withValues(alpha: 0.15)
                                      : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _selectedTab == 'isolation'
                                  ? const Color(
                                      0xFFF59E0B,
                                    ).withValues(alpha: 0.3)
                                  : Colors.transparent,
                            ),
                            boxShadow: _selectedTab == 'isolation' && !isDark
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.health_and_safety_outlined,
                                size: 16,
                                color: _selectedTab == 'isolation'
                                    ? const Color(0xFFF59E0B)
                                    : (isDark
                                          ? Colors.white38
                                          : Colors.black38),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ISOLATE BIRDS',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  color: _selectedTab == 'isolation'
                                      ? const Color(0xFFF59E0B)
                                      : (isDark
                                            ? Colors.white60
                                            : Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Information Pill
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: activeColor.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    Icon(
                      isIsolation
                          ? Icons.health_and_safety_outlined
                          : Icons.info_outline_rounded,
                      size: 16,
                      color: activeColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isIsolation
                            ? 'Isolating birds from ${widget.batch.batchName}. ${widget.batch.currentCount} active birds remaining.'
                            : 'Recording mortality for ${widget.batch.batchName}. ${widget.batch.currentCount} active birds remaining.',
                        style: TextStyle(
                          color: activeColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Number input field
              TextFormField(
                controller: _countController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                ),
                decoration: _inputDecoration(
                  context,
                  isIsolation
                      ? 'Number of Birds to Isolate'
                      : 'Number of Birds Lost',
                  isIsolation
                      ? Icons.health_and_safety_outlined
                      : Icons.remove_circle_outline,
                  isIsolation: isIsolation,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final count = int.tryParse(v) ?? 0;
                  if (count <= 0) return 'Must be > 0';
                  if (count > widget.batch.currentCount) {
                    return 'Cannot exceed current count';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 4. Dynamic Isolation House Selector (Only for Isolation mode)
              if (isIsolation) ...[
                StreamBuilder<List<House>>(
                  stream:
                      (db.select(db.houses)..where(
                            (t) =>
                                t.isIsolation.equals(true) &
                                t.farmId.equals(widget.batch.farmId),
                          ))
                          .watch(),
                  builder: (context, snapshot) {
                    final houses = snapshot.data ?? [];
                    return DropdownButtonFormField<House?>(
                      // ignore: deprecated_member_use
                      value: _selectedHouse,
                      dropdownColor: isDark
                          ? const Color(0xFF1E293B)
                          : Colors.white,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        fontSize: 14,
                      ),
                      decoration: _inputDecoration(
                        context,
                        'Select Quarantine Bay / Room',
                        Icons.home_work_outlined,
                        isIsolation: true,
                      ),
                      items: [
                        const DropdownMenuItem<House?>(
                          value: null,
                          child: Row(
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                size: 16,
                                color: Colors.amber,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'General Quarantine Zone',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        ...houses.map(
                          (h) => DropdownMenuItem<House?>(
                            value: h,
                            child: Text(
                              '${h.name} (Capacity: ${h.capacity} birds)',
                            ),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedHouse = val;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],

              if (!isIsolation) ...[
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  dropdownColor: isDark
                      ? const Color(0xFF1E293B)
                      : Colors.white,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 14,
                  ),
                  decoration: _inputDecoration(
                    context,
                    'Condition / Reason Category',
                    Icons.medical_information_outlined,
                  ),
                  items: mortalityReasons.keys
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _category = value;
                      _subCategory = mortalityReasons[value]!.first;
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (_category != 'Unknown')
                  DropdownButtonFormField<String>(
                    initialValue: _subCategory,
                    dropdownColor: isDark
                        ? const Color(0xFF1E293B)
                        : Colors.white,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      fontSize: 14,
                    ),
                    decoration: _inputDecoration(
                      context,
                      'Specific Symptom / Cause',
                      Icons.search,
                    ),
                    items: mortalityReasons[_category]!
                        .map(
                          (sub) => DropdownMenuItem(
                            value: sub,
                            child: Text(sub),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _subCategory = value);
                      }
                    },
                  ),
                if (_category != 'Unknown') const SizedBox(height: 16),
              ],

              // 5. Notes / Reason field
              TextFormField(
                controller: _reasonController,
                maxLines: 2,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
                decoration: _inputDecoration(
                  context,
                  isIsolation
                      ? 'Symptoms / Illness Notes'
                      : 'Reason (Optional)',
                  Icons.notes,
                  isIsolation: isIsolation,
                ),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text(
            'CANCEL',
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black45,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: activeColor,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            isIsolation ? 'ISOLATE BIRDS' : 'RECORD LOSS',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context,
    String label,
    IconData icon, {
    bool isIsolation = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isIsolation
        ? const Color(0xFFF59E0B)
        : const Color(0xFFEF4444);

    return InputDecoration(
      labelText: label.toUpperCase(),
      labelStyle: TextStyle(
        color: primaryColor,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
      ),
      prefixIcon: Icon(
        icon,
        color: isDark ? Colors.white24 : Colors.black26,
        size: 20,
      ),
      fillColor: isDark ? const Color(0xFF23262B) : const Color(0xFFF8FAFC),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final count = int.parse(_countController.text);
    final db = context.read<AppDatabase>();
    final farmId = widget.batch.farmId;
    final workerId = await FarmUtils.getRequiredUserId();
    final isIsolation = _selectedTab == 'isolation';

    if (isIsolation && _selectedHouse != null) {
      final targetRoomName = _selectedHouse!.name;
      final targetCapacity = _selectedHouse!.capacity;

      // Fetch active isolated batches and their isolation logs to calculate current occupancy
      final activeBatches =
          await (db.select(db.batches)..where(
                (t) =>
                    t.status.equals('active') &
                    t.isolationCount.isBiggerThanValue(0),
              ))
              .get();

      int currentOccupancy = 0;
      for (final b in activeBatches) {
        final logs =
            await (db.select(db.mortalities)
                  ..where(
                    (t) =>
                        t.batchId.equals(b.id) & t.healthType.equals('SICK'),
                  )
                  ..orderBy([
                    (t) => OrderingTerm(
                      expression: t.logDate,
                      mode: OrderingMode.desc,
                    ),
                  ])
                  ..limit(1))
                .get();

        final room = logs.isNotEmpty
            ? (logs.first.subCategory ?? 'General Quarantine Zone')
            : 'General Quarantine Zone';

        if (room == targetRoomName) {
          currentOccupancy += b.isolationCount;
        }
      }

      if (currentOccupancy + count > targetCapacity) {
        if (mounted) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Capacity Exceeded',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Text(
                'Cannot isolate birds in $targetRoomName.\n\n'
                'Current Occupancy: $currentOccupancy / $targetCapacity birds.\n'
                'Requested Isolation: $count birds.\n\n'
                'This would exceed the maximum room capacity by ${(currentOccupancy + count) - targetCapacity} birds. Please select another bay or reduce the count.',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        }
        return;
      }
    }

    try {
      await db.transaction(() async {
        if (isIsolation) {
          await db
              .into(db.mortalities)
              .insert(
                MortalitiesCompanion.insert(
                  id: newLocalId(),
                  farmId: farmId,
                  batchId: widget.batch.id,
                  count: count,
                  logDate: DateTime.now(),
                  healthType: const Value('SICK'),
                  reason: Value(
                    _reasonController.text.trim().isEmpty
                        ? 'Quarantined for health monitoring'
                        : _reasonController.text.trim(),
                  ),
                  category: const Value('Disease'),
                  subCategory: Value(
                    _reasonController.text.trim().isEmpty
                        ? 'Unknown cause yet'
                        : _reasonController.text.trim(),
                  ),
                  isolationRoomId: Value(_selectedHouse?.id),
                  userId: Value(workerId),
                  synced: const Value(false),
                ),
              );

          await (db.update(
            db.batches,
          )..where((t) => t.id.equals(widget.batch.id))).write(
            BatchesCompanion(
              currentCount: Value(widget.batch.currentCount - count),
              isolationCount: Value(widget.batch.isolationCount + count),
              synced: const Value(false),
            ),
          );
        } else {
          await db
              .into(db.mortalities)
              .insert(
                MortalitiesCompanion.insert(
                  id: newLocalId(),
                  farmId: farmId,
                  batchId: widget.batch.id,
                  count: count,
                  logDate: DateTime.now(),
                  healthType: const Value('DEAD'),
                  reason: Value(
                    _reasonController.text.trim().isEmpty
                        ? null
                        : _reasonController.text.trim(),
                  ),
                  category: Value(_category),
                  subCategory: Value(
                    resolveSubCategory(
                      category: _category,
                      subCategory: _subCategory,
                    ),
                  ),
                  userId: Value(workerId),
                  synced: const Value(false),
                ),
              );

          await (db.update(
            db.batches,
          )..where((t) => t.id.equals(widget.batch.id))).write(
            BatchesCompanion(
              currentCount: Value(widget.batch.currentCount - count),
              synced: const Value(false),
            ),
          );
        }
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: isIsolation
                ? const Color(0xFFF59E0B)
                : const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: Text(
              isIsolation
                  ? 'Successfully quarantined $count birds to ${_selectedHouse?.name ?? "General Quarantine Zone"}'
                  : 'Successfully recorded mortality log of $count birds.',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}

class QuickSaleDialog extends StatefulWidget {
  final Batch batch;
  const QuickSaleDialog({super.key, required this.batch});

  @override
  State<QuickSaleDialog> createState() => _QuickSaleDialogState();
}

class _QuickSaleDialogState extends State<QuickSaleDialog> {
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Customer? _selectedCustomer;
  bool _isWalkIn = true;
  DateTime _saleDate = DateTime.now();
  bool _canOverridePrice = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _setDefaultPrice();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await FarmUtils.getUserRole();
    final normalized = UserRoleUtils.normalize(role);
    if (!mounted) return;
    setState(() {
      _canOverridePrice =
          normalized == UserRoleUtils.owner ||
          normalized == UserRoleUtils.manager;
    });
  }

  void _setDefaultPrice() {
    final initial = widget.batch.initialActualCost ?? 0;
    final count = widget.batch.initialCount;
    if (initial > 0 && count > 0) {
      _priceController.text = (initial / count).toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();

    return AlertDialog(
      backgroundColor: const Color(0xFF121417),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            color: Color(0xFF10B981),
            size: 24,
          ),
          SizedBox(width: 12),
          Text(
            'Walk-in Sale',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Selling from ${widget.batch.batchName}',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              _buildTypeToggle(),
              const SizedBox(height: 20),
              if (!_isWalkIn) ...[
                _buildCustomerDropdown(db),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _qtyController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Quantity', Icons.numbers),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final q = int.tryParse(v) ?? 0;
                        if (q <= 0) return 'Must be > 0';
                        if (q > widget.batch.currentCount) {
                          return 'Exceeds stock';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      readOnly: !_canOverridePrice,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(
                        'Price (GH₵)',
                        Icons.payments,
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickSaleDate,
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: _inputDecoration('Sale date', Icons.event),
                  child: Text(
                    DateFormat('dd MMM yyyy, HH:mm').format(_saleDate),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildTotalDisplay(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
          ),
          child: Text(_isSaving ? 'SAVING...' : 'COMPLETE SALE'),
        ),
      ],
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF23262B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _toggleBtn(
              'Walk-In',
              _isWalkIn,
              () => setState(() => _isWalkIn = true),
            ),
          ),
          Expanded(
            child: _toggleBtn(
              'Existing Customer',
              !_isWalkIn,
              () => setState(() => _isWalkIn = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF10B981) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerDropdown(AppDatabase db) {
    return StreamBuilder<List<Customer>>(
      stream: db.select(db.customers).watch(),
      builder: (context, snapshot) {
        final customers = snapshot.data ?? [];
        return DropdownButtonFormField<Customer>(
          dropdownColor: const Color(0xFF23262B),
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('Select Customer', Icons.person),
          items: customers
              .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
              .toList(),
          onChanged: (v) => setState(() => _selectedCustomer = v),
          validator: (v) => (!_isWalkIn && v == null) ? 'Required' : null,
        );
      },
    );
  }

  Widget _buildTotalDisplay() {
    return ValueListenableBuilder(
      valueListenable: _qtyController,
      builder: (context, _, _) {
        return ValueListenableBuilder(
          valueListenable: _priceController,
          builder: (context, _, _) {
            final qty = double.tryParse(_qtyController.text) ?? 0;
            final price = double.tryParse(_priceController.text) ?? 0;
            final total = qty * price;
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL REVENUE',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    'GH₵ ${NumberFormat('#,###.00').format(total)}',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF10B981), fontSize: 12),
      prefixIcon: Icon(icon, color: Colors.grey, size: 20),
      fillColor: const Color(0xFF23262B),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _pickSaleDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _saleDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_saleDate),
    );
    if (time == null || !mounted) return;

    setState(() {
      _saleDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    final qty = int.parse(_qtyController.text);
    final price = double.parse(_priceController.text);
    final total = qty * price;

    final db = context.read<AppDatabase>();
    final farmId = await FarmUtils.getBoundFarmId();
    final workerId = await FarmUtils.getRequiredUserId();
    if (farmId == null) return;

    setState(() => _isSaving = true);
    try {
      final salesService = LocalSalesService(db);
      final isCredit = !_isWalkIn && _selectedCustomer != null;
      await salesService.recordMultiLineSale(
        farmId: farmId,
        userId: workerId,
        items: [
          SaleLineDraft(
            productType: SaleProductType.livestock,
            description: widget.batch.batchName,
            quantity: qty,
            unitPrice: price,
            livestockId: widget.batch.id,
          ),
        ],
        orderDate: _saleDate,
        totalCashReceived: isCredit ? 0 : total,
        customerId: isCredit ? _selectedCustomer!.id : null,
        customerName: isCredit ? _selectedCustomer!.name : 'Walk-in Customer',
        paymentMethod: isCredit ? 'CREDIT' : 'CASH',
        requireExactCashTotal: !isCredit,
        completeNow: true,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sale recorded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class EditBatchDialog extends StatefulWidget {
  final Batch batch;
  const EditBatchDialog({super.key, required this.batch});

  @override
  State<EditBatchDialog> createState() => _EditBatchDialogState();
}

class _EditBatchDialogState extends State<EditBatchDialog> {
  late TextEditingController _nameController;
  late TextEditingController _initialCountController;
  late TextEditingController _currentCountController;
  late String _status;
  late String _type;
  late String _selectedBreedKey;
  late String _selectedBenchmark;
  late DateTime _arrivalDate;
  String? _selectedHouseId;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.batch.batchName);
    _initialCountController = TextEditingController(
      text: widget.batch.initialCount.toString(),
    );
    _currentCountController = TextEditingController(
      text: widget.batch.currentCount.toString(),
    );
    _selectedBreedKey = LivestockBreedCatalog.normalizeBreedKey(
      widget.batch.breedType,
    );
    _status = widget.batch.status;
    _type = LivestockBreedCatalog.categoryToType(
      LivestockBreedCatalog.typeToCategory(widget.batch.type),
    );
    final typeOptions = LivestockBreedCatalog.optionsForCategory(
      LivestockBreedCatalog.typeToCategory(_type),
    );
    if (!typeOptions.any((option) => option.key == _selectedBreedKey)) {
      _selectedBreedKey = typeOptions.first.key;
    }
    _selectedBenchmark = widget.batch.growthTarget ?? 'Default (From Breed)';
    _arrivalDate = widget.batch.arrivalDate;
    _selectedHouseId = widget.batch.houseId;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF121417),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Edit Unit Details',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(
                    'Unit Name / Identity',
                    Icons.edit,
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _initialCountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          'Arrival Quantity',
                          Icons.add_circle_outline,
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                        onChanged: (v) {
                          // Automatically update current count based on the difference
                          final newInitial = int.tryParse(v) ?? 0;
                          final diff = newInitial - widget.batch.initialCount;
                          _currentCountController.text =
                              (widget.batch.currentCount + diff).toString();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _currentCountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          'Current Stock',
                          Icons.inventory_2_outlined,
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDatePicker(context),
                const SizedBox(height: 16),
                _buildHouseDropdown(context),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  dropdownColor: const Color(0xFF23262B),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(
                    'Batch Type',
                    Icons.category_outlined,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'POULTRY_BROILER',
                      child: Text('BROILER'),
                    ),
                    DropdownMenuItem(
                      value: 'POULTRY_LAYER',
                      child: Text('LAYER'),
                    ),
                    DropdownMenuItem(
                      value: 'CATTLE',
                      child: Text('CATTLE / LIVESTOCK'),
                    ),
                    DropdownMenuItem(
                      value: 'SHEEP_GOAT',
                      child: Text('SHEEP / GOAT'),
                    ),
                    DropdownMenuItem(value: 'PIG', child: Text('PIG / SWINE')),
                    DropdownMenuItem(value: 'OTHER', child: Text('OTHER')),
                  ],
                  onChanged: (v) => setState(() {
                    _type = v!;
                    _selectedBreedKey =
                        LivestockBreedCatalog.optionsForCategory(
                          LivestockBreedCatalog.typeToCategory(_type),
                        ).first.key;
                  }),
                ),
                const SizedBox(height: 16),
                _buildBreedDropdown(),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedBenchmark,
                  dropdownColor: const Color(0xFF23262B),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(
                    'Benchmark Override',
                    Icons.speed,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Default (From Breed)',
                      child: Text('Default (From Breed)'),
                    ),
                    DropdownMenuItem(
                      value: 'Ross 308 (Meat)',
                      child: Text('Ross 308 (Meat)'),
                    ),
                    DropdownMenuItem(
                      value: 'Cobb 500 (Meat)',
                      child: Text('Cobb 500 (Meat)'),
                    ),
                    DropdownMenuItem(
                      value: 'ISA Brown (Eggs)',
                      child: Text('ISA Brown (Eggs)'),
                    ),
                    DropdownMenuItem(
                      value: 'Lohmann (Eggs)',
                      child: Text('Lohmann (Eggs)'),
                    ),
                    DropdownMenuItem(
                      value: 'Ankole (Cattle)',
                      child: Text('Ankole (Cattle)'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _selectedBenchmark = v!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  dropdownColor: const Color(0xFF23262B),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Status', Icons.info_outline),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('ACTIVE')),
                    DropdownMenuItem(
                      value: 'completed',
                      child: Text('COMPLETED'),
                    ),
                    DropdownMenuItem(
                      value: 'archived',
                      child: Text('ARCHIVED'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _status = v!),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
          ),
          child: const Text('UPDATE UNIT'),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF3B82F6), fontSize: 12),
      prefixIcon: Icon(icon, color: Colors.grey, size: 20),
      fillColor: const Color(0xFF23262B),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildBreedDropdown() {
    final options = LivestockBreedCatalog.optionsForCategory(
      LivestockBreedCatalog.typeToCategory(_type),
    );
    final selectedValue =
        options.any((option) => option.key == _selectedBreedKey)
        ? _selectedBreedKey
        : null;

    return DropdownButtonFormField<String>(
      key: ValueKey('edit-breed-$_type-${selectedValue ?? 'none'}'),
      initialValue: selectedValue,
      dropdownColor: const Color(0xFF23262B),
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration('Primary Breed / Specie', Icons.pets),
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      items: options
          .map(
            (option) => DropdownMenuItem<String>(
              value: option.key,
              child: LivestockBreedOptionRow(option: option),
            ),
          )
          .toList(),
      onChanged: (v) => setState(() => _selectedBreedKey = v!),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: _arrivalDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (d != null) setState(() => _arrivalDate = d);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF23262B),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
            const SizedBox(width: 12),
            Text(
              DateFormat('MMM dd, yyyy').format(_arrivalDate),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHouseDropdown(BuildContext context) {
    final db = context.watch<AppDatabase>();
    return FutureBuilder<String?>(
      future: FarmUtils.getBoundFarmId(),
      builder: (context, farm) {
        final farmId = farm.data;
        if (farmId == null || farmId.isEmpty) return const SizedBox.shrink();
        return StreamBuilder<List<House>>(
          stream: (db.select(
            db.houses,
          )..where((t) => t.farmId.equals(farmId))).watch(),
          builder: (context, snapshot) {
            final houses = snapshot.data ?? [];
            return DropdownButtonFormField<String?>(
              initialValue: _selectedHouseId,
              dropdownColor: const Color(0xFF23262B),
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                'Assign House',
                Icons.house_outlined,
              ),
              onChanged: (v) {
                if (v == _addHouseSentinel) {
                  _showQuickAddHouseDialog(context, db, farmId);
                } else {
                  setState(() => _selectedHouseId = v);
                }
              },
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('No House Assigned'),
                ),
                ...houses.map(
                  (h) => DropdownMenuItem(value: h.id, child: Text(h.name)),
                ),
                const DropdownMenuItem<String>(
                  value: _addHouseSentinel,
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        size: 18,
                        color: Color(0xFF3B82F6),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Add New House',
                        style: TextStyle(
                          color: Color(0xFF3B82F6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final db = context.read<AppDatabase>();
    try {
      await (db.update(
        db.batches,
      )..where((t) => t.id.equals(widget.batch.id))).write(
        BatchesCompanion(
          batchName: Value(_nameController.text),
          initialCount: Value(int.parse(_initialCountController.text)),
          currentCount: Value(int.parse(_currentCountController.text)),
          status: Value(_status),
          type: Value(_type),
          arrivalDate: Value(_arrivalDate),
          houseId: Value(_selectedHouseId),
          breedType: Value(_selectedBreedKey),
          growthTarget: Value(_selectedBenchmark),
          synced: const Value(false),
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showQuickAddHouseDialog(
    BuildContext context,
    AppDatabase db,
    String farmId,
  ) {
    final houseNameCtrl = TextEditingController();
    final capacityCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF121417),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Text(
          'Add House',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'HOUSE NAME',
              style: TextStyle(
                color: Color(0xFF3B82F6),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: houseNameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                'Enter house name',
                Icons.home_work_outlined,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'CAPACITY (OPTIONAL)',
              style: TextStyle(
                color: Color(0xFF3B82F6),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: capacityCtrl,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _inputDecoration(
                'Enter capacity',
                Icons.people_outline,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
          ),
          FilledButton(
            onPressed: () async {
              if (houseNameCtrl.text.trim().isEmpty) return;
              final cap = int.tryParse(capacityCtrl.text) ?? 1000;
              final userId = await FarmUtils.getRequiredUserId();

              final houseId = newLocalId();
              await db
                  .into(db.houses)
                  .insert(
                    HousesCompanion.insert(
                      id: houseId,
                      farmId: farmId,
                      name: houseNameCtrl.text.trim(),
                      capacity: cap,
                      userId: Value(userId),
                      isIsolation: const Value(false),
                      synced: const Value(false),
                    ),
                  );

              if (ctx.mounted) {
                ctx.read<SyncEngine>().performSync();
                Navigator.pop(ctx);
                setState(() => _selectedHouseId = houseId);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
            ),
            child: const Text(
              'Add',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
