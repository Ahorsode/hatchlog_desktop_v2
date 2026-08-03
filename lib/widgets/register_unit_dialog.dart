import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' hide Column, Batch;
import '../data/local_db.dart';
import '../data/sync_engine.dart';
import '../utils/farm_utils.dart';
import '../utils/id_utils.dart';
import '../utils/livestock_breed_options.dart';
import 'financial_init_dialog.dart';

const _addHouseSentinel = '__add_new_house__';

class RegisterUnitDialog extends StatefulWidget {
  const RegisterUnitDialog({super.key});

  @override
  State<RegisterUnitDialog> createState() => _RegisterUnitDialogState();
}

class _RegisterUnitDialogState extends State<RegisterUnitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _vaccineNameController = TextEditingController();

  String? _selectedCategory = LivestockBreedCatalog.poultryMeat;
  String? _selectedBreed;
  String? _selectedHouseId;
  DateTime _arrivalDate = DateTime.now();
  DateTime? _vaccinationDate;

  final List<String> _categories = LivestockBreedCatalog.categories;

  @override
  void initState() {
    super.initState();
    _selectedBreed = LivestockBreedCatalog.optionsForCategory(
      _selectedCategory,
    ).first.key;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _vaccineNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 650,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              _buildHeader(context),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildInputField(
                                label: 'UNIT NAME / IDENTITY',
                                hint: 'e.g., Q1-Broiler-Alpha',
                                controller: _nameController,
                                icon: Icons.badge_outlined,
                                validator: (v) =>
                                    v?.isEmpty ?? true ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildDropdownField<String>(
                                label: 'LIVESTOCK CATEGORY',
                                value: _selectedCategory,
                                items: _categories,
                                icon: Icons.category_outlined,
                                onChanged: (v) {
                                  setState(() {
                                    _selectedCategory = v;
                                    _selectedBreed =
                                        LivestockBreedCatalog.optionsForCategory(
                                          v,
                                        ).first.key;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildBreedDropdown()),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildInputField(
                                label: 'ARRIVAL QUANTITY',
                                hint: '1000',
                                controller: _quantityController,
                                icon: Icons.numbers_rounded,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Required';
                                  if (int.tryParse(v) == null) return 'Invalid';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildHouseDropdown(db)),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildDateField(
                                label: 'ARRIVAL / HATCH DATE',
                                value: _arrivalDate,
                                icon: Icons.calendar_today_rounded,
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _arrivalDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2100),
                                    builder: (context, child) =>
                                        _darkDatePickerTheme(context, child!),
                                  );
                                  if (picked != null) {
                                    setState(() => _arrivalDate = picked);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _buildSectionHeader(
                          'INITIAL HEALTH RECORD',
                          Icons.health_and_safety_outlined,
                          Colors.amber,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildDateField(
                                label: '1ST VACCINATION DATE',
                                value: _vaccinationDate,
                                icon: Icons.event_note_rounded,
                                isOptional: true,
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2100),
                                    builder: (context, child) =>
                                        _darkDatePickerTheme(context, child!),
                                  );
                                  if (picked != null) {
                                    setState(() => _vaccinationDate = picked);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildInputField(
                                label: 'VACCINE NAME',
                                hint: 'e.g., Gumboro',
                                controller: _vaccineNameController,
                                icon: Icons.medication_outlined,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),
                        _buildFooterActions(db),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.add_business_rounded,
              color: Color(0xFF10B981),
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'REGISTER NEW LIVESTOCK UNIT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'START TRACKING PERFORMANCE & GROWTH',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: Divider(color: color.withValues(alpha: 0.2))),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle()),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: _inputTextStyle(),
          decoration: _inputDecoration(hint, icon),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
    required IconData icon,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle()),
        const SizedBox(height: 10),
        DropdownButtonFormField<T>(
          key: ValueKey('$label-${value ?? 'none'}-${items.join('|')}'),
          initialValue: value,
          isExpanded: true,
          onChanged: onChanged,
          dropdownColor: const Color(0xFF1E293B),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF94A3B8),
          ),
          style: _inputTextStyle(),
          decoration: _inputDecoration(hint ?? '', icon),
          selectedItemBuilder: (context) => items
              .map(
                (e) => Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    e.toString(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: _inputTextStyle(),
                  ),
                ),
              )
              .toList(),
          items: items
              .map(
                (e) => DropdownMenuItem<T>(value: e, child: Text(e.toString())),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildBreedDropdown() {
    final options = LivestockBreedCatalog.optionsForCategory(_selectedCategory);
    final selectedValue = options.any((option) => option.key == _selectedBreed)
        ? _selectedBreed
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PRIMARY BREED / SPECIE', style: _labelStyle()),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          key: ValueKey(
            'breed-${_selectedCategory ?? 'none'}-${selectedValue ?? 'none'}',
          ),
          initialValue: selectedValue,
          isExpanded: true,
          onChanged: (v) => setState(() => _selectedBreed = v),
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          dropdownColor: const Color(0xFF1E293B),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF94A3B8),
          ),
          style: _inputTextStyle(),
          decoration: _inputDecoration('Select Breed', Icons.pets_outlined),
          selectedItemBuilder: (context) => options
              .map(
                (option) => Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    option.label,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: _inputTextStyle(),
                  ),
                ),
              )
              .toList(),
          items: options
              .map(
                (option) => DropdownMenuItem<String>(
                  value: option.key,
                  child: LivestockBreedOptionRow(option: option),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildHouseDropdown(AppDatabase db) {
    return FutureBuilder<String?>(
      future: FarmUtils.getBoundFarmId(),
      builder: (context, farmSnapshot) {
        final farmId = farmSnapshot.data;
        if (farmId == null || farmId.isEmpty) return const SizedBox();

        return StreamBuilder<List<House>>(
          stream: (db.select(
            db.houses,
          )..where((t) => t.farmId.equals(farmId))).watch(),
          builder: (context, snapshot) {
            final houses = snapshot.data ?? [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ALLOCATE FARM HOUSE', style: _labelStyle()),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: houses.any((h) => h.id == _selectedHouseId)
                      ? _selectedHouseId
                      : null,
                  isExpanded: true,
                  onChanged: (v) {
                    if (v == _addHouseSentinel) {
                      _showQuickAddHouseDialog(context, db, farmId);
                    } else {
                      setState(() => _selectedHouseId = v);
                    }
                  },
                  dropdownColor: const Color(0xFF1E293B),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF94A3B8),
                  ),
                  style: _inputTextStyle(),
                  decoration: _inputDecoration(
                    'Select Location',
                    Icons.home_work_outlined,
                  ),
                  selectedItemBuilder: (context) => [
                    ...houses.map(
                      (h) => Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          h.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: _inputTextStyle(),
                        ),
                      ),
                    ),
                    const Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        'Add New House',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                  items: [
                    ...houses.map(
                      (h) => DropdownMenuItem<String>(
                        value: h.id,
                        child: Text(h.name),
                      ),
                    ),
                    const DropdownMenuItem<String>(
                      value: _addHouseSentinel,
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_circle_outline_rounded,
                            size: 18,
                            color: Color(0xFF10B981),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Add New House',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required IconData icon,
    required VoidCallback onTap,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle()),
        const SizedBox(height: 10),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
                const SizedBox(width: 14),
                Text(
                  value != null
                      ? DateFormat('dd MMM yyyy').format(value)
                      : 'Select Date',
                  style: TextStyle(
                    color: value != null
                        ? Colors.white
                        : const Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterActions(AppDatabase db) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'DISCARD',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w800,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: () => _handleSubmit(db),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'SAVE UNIT & CONTINUE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  TextStyle _labelStyle() => const TextStyle(
    color: Color(0xFF10B981),
    fontSize: 12,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.2,
  );

  TextStyle _inputTextStyle() => const TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

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
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Text(
          'Add House',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('HOUSE NAME', style: _labelStyle()),
              const SizedBox(height: 12),
              TextField(
                controller: houseNameCtrl,
                style: _inputTextStyle(),
                decoration: _inputDecoration(
                  'Enter house name',
                  Icons.home_work_outlined,
                ),
              ),
              const SizedBox(height: 24),
              Text('CAPACITY (OPTIONAL)', style: _labelStyle()),
              const SizedBox(height: 12),
              TextField(
                controller: capacityCtrl,
                style: _inputTextStyle(),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _inputDecoration(
                  'Enter capacity',
                  Icons.people_outline,
                ),
              ),
            ],
          ),
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
              backgroundColor: const Color(0xFF10B981),
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

  InputDecoration _inputDecoration(String hint, IconData icon) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      );

  Widget _darkDatePickerTheme(BuildContext context, Widget child) {
    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF10B981),
          onPrimary: Colors.white,
          surface: Color(0xFF0F172A),
          onSurface: Colors.white,
        ),
      ),
      child: child,
    );
  }

  Future<void> _handleSubmit(AppDatabase db) async {
    if (!_formKey.currentState!.validate()) return;

    final farmId = await FarmUtils.getBoundFarmId();
    if (!mounted) return;
    if (farmId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No farm bound to this device.')),
      );
      return;
    }

    final quantity = int.parse(_quantityController.text);
    final workerId = await FarmUtils.getRequiredUserId();

    try {
      await db.transaction(() async {
        final batchId = newLocalId();
        await db
            .into(db.batches)
            .insert(
              BatchesCompanion.insert(
                id: batchId,
                farmId: farmId,
                batchName: Value(_nameController.text),
                type: Value(_mapCategoryToType(_selectedCategory!)),
                breedType: Value(_selectedBreed),
                houseId: Value(_selectedHouseId),
                arrivalDate: _arrivalDate,
                currentCount: quantity,
                initialCount: quantity,
                userId: Value(workerId),
                synced: const Value(false),
              ),
            );

        if (_vaccinationDate != null &&
            _vaccineNameController.text.isNotEmpty) {
          await db
              .into(db.vaccinationSchedules)
              .insert(
                VaccinationSchedulesCompanion.insert(
                  id: newLocalId(),
                  batchId: batchId,
                  vaccineName: _vaccineNameController.text,
                  scheduledDate: _vaccinationDate!,
                  farmId: farmId,
                  synced: const Value(false),
                ),
              );
        }
      });

      // Trigger sync
      if (mounted) {
        context.read<SyncEngine>().performSync();
      }

      if (mounted) {
        Navigator.pop(context);
        final newBatch =
            await (db.select(db.batches)
                  ..orderBy([(t) => OrderingTerm.desc(t.id)])
                  ..limit(1))
                .getSingleOrNull();
        if (newBatch != null && mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => FinancialInitDialog(batch: newBatch),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  String _mapCategoryToType(String category) {
    return LivestockBreedCatalog.categoryToType(category);
  }
}
