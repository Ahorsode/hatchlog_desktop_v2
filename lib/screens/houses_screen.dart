import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' hide Column, Batch;
import '../data/local_db.dart';
import '../data/sync_engine.dart';
import '../utils/farm_utils.dart';
import '../utils/id_utils.dart';

class HousesScreen extends StatelessWidget {
  const HousesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Farm Houses', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: cs.onSurface)),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: cs.outline),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 850;
          return FutureBuilder<String?>(
            future: FarmUtils.getBoundFarmId(),
            builder: (context, farmSnapshot) {
              final farmId = farmSnapshot.data;
              if (farmId == null || farmId.isEmpty) {
                return const Center(child: Text('No farm bound. Complete device setup first.'));
              }
              final housesStream = (db.select(db.houses)..where((t) => t.farmId.equals(farmId))).watch();
              final activeBatchesStream = (db.select(db.batches)..where((t) => t.farmId.equals(farmId) & t.status.equals('active'))).watch();
    
              return StreamBuilder<List<House>>(
                stream: housesStream,
                builder: (context, housesSnapshot) {
                  final houses = housesSnapshot.data ?? [];
                  if (houses.isEmpty) return _buildEmptyState(context);
    
                  return StreamBuilder<List<Batch>>(
                    stream: activeBatchesStream,
                    builder: (context, batchesSnapshot) {
                      final activeBatches = batchesSnapshot.data ?? [];
                      
                      return GridView.builder(
                        padding: EdgeInsets.all(isNarrow ? 16 : 24),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 450,
                          crossAxisSpacing: isNarrow ? 16 : 24,
                          mainAxisSpacing: isNarrow ? 16 : 24,
                          childAspectRatio: isNarrow ? 1.4 : 1.6,
                        ),
                        itemCount: houses.length,
                        itemBuilder: (context, index) {
                          final house = houses[index];
                          final houseBatches = activeBatches.where((b) => b.houseId == house.id).toList();
                          final currentBirds = houseBatches.fold<int>(0, (sum, b) => sum + b.currentCount);
                          final occupancyPercent = house.capacity > 0 ? (currentBirds / house.capacity) : 0.0;
                          
                          return _buildHouseCard(context, house, occupancyPercent, currentBirds, isNarrow);
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHouseDialog(context, db),
        backgroundColor: const Color(0xFF16A34A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add New House', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.home_work_outlined, size: 80, color: cs.outline),
      const SizedBox(height: 16),
      Text('No houses registered yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)),
      const SizedBox(height: 8),
      Text('Register your farm houses to start tracking batches.', style: TextStyle(color: cs.onSurfaceVariant)),
    ]));
  }

  Widget _buildHouseCard(BuildContext context, House house, double occupancy, int currentBirds, bool isNarrow) {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(isNarrow ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        house.name,
                        style: TextStyle(
                          fontSize: isNarrow ? 16 : 18,
                          fontWeight: FontWeight.w900,
                          color: cs.onSurface,
                          letterSpacing: -0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildHouseActions(context, house, db),
                  ],
                ),
                SizedBox(height: isNarrow ? 12 : 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildStatBadge(
                      Icons.groups_rounded,
                      'Birds',
                      '$currentBirds/${house.capacity}',
                      const Color(0xFF3B82F6),
                      isNarrow,
                    ),
                    if (house.isIsolation)
                      _buildStatBadge(
                        Icons.health_and_safety_rounded,
                        'Type',
                        'Isolation',
                        const Color(0xFFF59E0B),
                        isNarrow,
                      )
                    else
                      _buildStatBadge(
                        Icons.home_work_rounded,
                        'Type',
                        'Standard',
                        const Color(0xFF10B981),
                        isNarrow,
                      ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Occupancy',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${(occupancy * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: occupancy.clamp(0.0, 1.0),
                        backgroundColor: cs.outlineVariant.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          occupancy > 1.0 ? Colors.redAccent : cs.primary,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildStatBadge(IconData icon, String label, String value, Color color, bool isNarrow) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isNarrow ? 8 : 12, vertical: isNarrow ? 6 : 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isNarrow ? 14 : 16, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isNarrow ? 8 : 9,
                  fontWeight: FontWeight.w700,
                  color: color.withValues(alpha: 0.7),
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: isNarrow ? 11 : 12,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildHouseActions(BuildContext context, House house, AppDatabase db) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'edit') {
          _showEditHouseDialog(context, db, house);
        } else if (value == 'delete') {
          _confirmDeleteHouse(context, db, house);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_rounded, size: 18),
              SizedBox(width: 12),
              Text('Edit Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
              SizedBox(width: 12),
              Text('Remove House', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }



  Future<void> _showAddHouseDialog(BuildContext context, AppDatabase db) async {
    final nameController = TextEditingController();
    final capacityController = TextEditingController();
    bool isIsolation = false;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 40, offset: const Offset(0, 20)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDialogHeader(
                        icon: Icons.add_home_work_rounded,
                        title: 'ADD NEW HOUSE',
                        subtitle: 'REGISTER NEW LOCATION',
                        color: Colors.blue,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDialogInputField('House Name', 'e.g. Broiler House A', nameController, Icons.badge_outlined),
                            const SizedBox(height: 24),
                            _buildDialogInputField('Total Bird Capacity', 'e.g. 1000', capacityController, Icons.groups_outlined, isNumber: true),
                            const SizedBox(height: 32),
                            const Text('HOUSE CATEGORY', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                              ),
                              child: SwitchListTile(
                                title: const Text('Isolation House', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                                subtitle: const Text('Mark if this house is for sick birds', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                                value: isIsolation,
                                onChanged: (v) => setState(() => isIsolation = v),
                                activeTrackColor: const Color(0xFFF59E0B),
                              ),
                            ),
                            const SizedBox(height: 40),
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('CANCEL', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w800, letterSpacing: 1)),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  flex: 2,
                                  child: FilledButton(
                                    onPressed: () async {
                                      final farmId = await FarmUtils.getBoundFarmId();
                                      final workerId = await FarmUtils.getRequiredUserId();
                                      if (farmId == null) return;
                                      await db.into(db.houses).insert(HousesCompanion.insert(
                                        id: newLocalId(),
                                        farmId: farmId,
                                        name: nameController.text,
                                        capacity: int.tryParse(capacityController.text) ?? 0,
                                        userId: Value(workerId),
                                        isIsolation: Value(isIsolation),
                                        synced: const Value(false),
                                      ));
                                      if (context.mounted) Navigator.pop(context);
                                    },
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFF10B981),
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text('SAVE HOUSE LOCATION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
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
          ),
        ),
      ),
    );
  }

  Future<void> _showEditHouseDialog(BuildContext context, AppDatabase db, House house) async {
    final nameController = TextEditingController(text: house.name);
    final capacityController = TextEditingController(text: house.capacity.toString());
    bool isIsolation = house.isIsolation;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 40, offset: const Offset(0, 20)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDialogHeader(
                        icon: Icons.home_work_rounded,
                        title: 'EDIT HOUSE DETAILS',
                        subtitle: 'UPDATE LOCATION INFO',
                        color: Colors.blue,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDialogInputField('House Name', 'e.g. Broiler House A', nameController, Icons.badge_outlined),
                            const SizedBox(height: 24),
                            _buildDialogInputField('Total Bird Capacity', 'e.g. 1000', capacityController, Icons.groups_outlined, isNumber: true),
                            const SizedBox(height: 32),
                            const Text('HOUSE CATEGORY', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                              ),
                              child: SwitchListTile(
                                title: const Text('Isolation House', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                                subtitle: const Text('Mark if this house is for sick birds', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                                value: isIsolation,
                                onChanged: (v) => setState(() => isIsolation = v),
                                activeTrackColor: const Color(0xFFF59E0B),
                              ),
                            ),
                            const SizedBox(height: 40),
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('CANCEL', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w800, letterSpacing: 1)),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  flex: 2,
                                  child: FilledButton(
                                    onPressed: () async {
                                      await (db.update(db.houses)..where((t) => t.id.equals(house.id)))
                                        .write(HousesCompanion(
                                          name: Value(nameController.text),
                                          capacity: Value(int.tryParse(capacityController.text) ?? house.capacity),
                                          isIsolation: Value(isIsolation),
                                          synced: const Value(false),
                                          updatedAt: Value(DateTime.now()),
                                        ));
                                      if (context.mounted) Navigator.pop(context);
                                    },
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFF10B981),
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text('UPDATE LOCATION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
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
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteHouse(BuildContext context, AppDatabase db, House house) async {
    final cs = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete House?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('Are you sure you want to remove ${house.name}? This action cannot be undone if there are active batches associated with it.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: TextStyle(color: cs.onSurfaceVariant))),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (house.synced) {
        await db.into(db.pendingDeletions).insert(
              PendingDeletionsCompanion.insert(
                id: newLocalId(),
                targetTableName: 'houses',
                recordId: house.id,
                farmId: house.farmId,
              ),
            );
      }
      await (db.delete(db.houses)..where((t) => t.id.equals(house.id))).go();
      if (context.mounted) {
        context.read<SyncEngine>().performSync();
      }
    }
  }

  Widget _buildDialogHeader({required IconData icon, required String title, required String subtitle, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.5),
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDialogInputField(String label, String hint, TextEditingController controller, IconData icon, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFF1E293B),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5)),
            contentPadding: const EdgeInsets.all(18),
          ),
        ),
      ],
    );
  }
}
