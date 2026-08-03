import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' hide Column, Batch;
import 'package:intl/intl.dart';
import '../data/local_db.dart';
import '../data/sync_engine.dart';
import '../services/inventory_repository.dart';
import '../utils/farm_utils.dart';
import '../utils/health_constants.dart';
import '../utils/id_utils.dart';
import '../utils/inventory_constants.dart';

class InventoryManager extends StatefulWidget {
  const InventoryManager({super.key});

  @override
  State<InventoryManager> createState() => _InventoryManagerState();
}

class _InventoryManagerState extends State<InventoryManager> {
  bool _showUsedUp = false;
  String? _categoryFilter = kInventoryCategoryFilterAll;

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final repo = InventoryRepository(db);
    final currency = NumberFormat.currency(symbol: 'GH₵ ', decimalDigits: 2);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Inventory & Stock',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: ElevatedButton.icon(
              onPressed: () => _showItemDialog(context, db),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
              label: const Text('New Item', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 850;
          return StreamBuilder<List<InventoryItem>>(
            stream: db.select(db.inventory).watch(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              return FutureBuilder<(String, List<InventoryItem>, int, ActiveBatchEggStock)?>(
                future: _loadInventoryView(repo),
                builder: (context, dataSnapshot) {
                  if (dataSnapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final payload = dataSnapshot.data;
                  if (payload == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final farmId = payload.$1;
                  final allFiltered = payload.$2;
                  final usedUpCount = payload.$3;
                  final eggStock = payload.$4;
                  final items = allFiltered
                      .where(
                        (item) => matchesInventoryCategoryFilter(
                          item.category,
                          _categoryFilter,
                        ),
                      )
                      .toList();

                          if (items.isEmpty && eggStock.totalEggs == 0 && !_showUsedUp && _categoryFilter == null) {
                            return _buildEmptyState(context, db);
                          }

                          final totalValue = items.fold(
                            0.0,
                            (sum, item) => sum + (item.stockLevel * (item.costPerUnit ?? 0)),
                          );
                          final lowStockItems = items
                              .where((item) => item.stockLevel < (item.reorderLevel ?? 10))
                              .length;

                          return CustomScrollView(
                            slivers: [
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  isNarrow ? 16 : 32,
                                  isNarrow ? 16 : 24,
                                  isNarrow ? 16 : 32,
                                  0,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildStockTabs(usedUpCount),
                                      const SizedBox(height: 12),
                                      _buildCategoryFilters(),
                                      if (_showUsedUp)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8, bottom: 4),
                                          child: Text(
                                            'Fully depleted items — open a row to see usage history.',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              if (!_showUsedUp && eggStock.totalEggs > 0)
                                SliverPadding(
                                  padding: EdgeInsets.fromLTRB(
                                    isNarrow ? 16 : 32,
                                    0,
                                    isNarrow ? 16 : 32,
                                    0,
                                  ),
                                  sliver: SliverToBoxAdapter(
                                    child: _buildEggStockCard(context, eggStock),
                                  ),
                                ),
                              SliverPadding(
                                padding: EdgeInsets.all(isNarrow ? 16 : 32),
                                sliver: SliverToBoxAdapter(
                                  child: Wrap(
                                    spacing: 16,
                                    runSpacing: 16,
                                    children: [
                                      _kpiCard(
                                        context,
                                        'Inventory Value',
                                        currency.format(totalValue),
                                        Icons.account_balance_wallet_rounded,
                                        Colors.teal,
                                        isNarrow,
                                      ),
                                      _kpiCard(
                                        context,
                                        _showUsedUp ? 'Used-up Items' : 'In-stock Items',
                                        '${items.length}',
                                        Icons.inventory_2_rounded,
                                        Colors.blue,
                                        isNarrow,
                                      ),
                                      if (!_showUsedUp)
                                        _kpiCard(
                                          context,
                                          'Low Stock Alerts',
                                          '$lowStockItems',
                                          Icons.warning_amber_rounded,
                                          Colors.orange,
                                          isNarrow,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              if (items.isEmpty && (_showUsedUp || eggStock.totalEggs == 0))
                                SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: Center(
                                    child: Text(
                                      _showUsedUp
                                          ? 'No used-up items yet.'
                                          : 'No in-stock items match this filter.',
                                    ),
                                  ),
                                )
                              else
                                SliverPadding(
                                  padding: EdgeInsets.symmetric(horizontal: isNarrow ? 16 : 32),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final item = items[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 16),
                                          child: _InventoryItemTile(
                                            item: item,
                                            isNarrow: isNarrow,
                                            showUsedUp: _showUsedUp,
                                            repo: repo,
                                            farmId: farmId,
                                          ),
                                        );
                                      },
                                      childCount: items.length,
                                    ),
                                  ),
                                ),
                              const SliverToBoxAdapter(child: SizedBox(height: 100)),
                            ],
                          );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<(String, List<InventoryItem>, int, ActiveBatchEggStock)?> _loadInventoryView(
    InventoryRepository repo,
  ) async {
    final farmId = await FarmUtils.getBoundFarmId();
    if (farmId == null) {
      return null;
    }
    final results = await Future.wait([
      repo.getAllInventory(
        farmId: farmId,
        filter: _showUsedUp ? InventoryListFilter.usedUp : InventoryListFilter.active,
      ),
      repo.getUsedUpInventoryCount(farmId),
      _showUsedUp
          ? Future.value(const ActiveBatchEggStock(totalEggs: 0, batches: []))
          : repo.getActiveBatchEggStock(farmId),
    ]);
    final items = (results[0] as List<InventoryItem>)
        .where((item) => (item.category ?? '').toUpperCase() != 'EGGS')
        .toList();
    return (
      farmId,
      items,
      results[1] as int,
      results[2] as ActiveBatchEggStock,
    );
  }

  Widget _buildEggStockCard(BuildContext context, ActiveBatchEggStock eggStock) {
    final crates = eggStock.totalEggs ~/ 30;
    final remainder = eggStock.totalEggs % 30;
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Egg Inventory (Active Batches)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$crates crates${remainder > 0 ? ' + $remainder remainder' : ''}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            Text('${eggStock.totalEggs} eggs from active layer batches'),
            const SizedBox(height: 12),
            for (final batch in eggStock.batches)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        batch.batchName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text('${batch.eggsRemaining} eggs'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockTabs(int usedUpCount) {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: const Text('In stock'),
          selected: !_showUsedUp,
          onSelected: (_) => setState(() => _showUsedUp = false),
        ),
        ChoiceChip(
          label: Text(usedUpCount > 0 ? 'Used up ($usedUpCount)' : 'Used up'),
          selected: _showUsedUp,
          onSelected: (_) => setState(() => _showUsedUp = true),
        ),
      ],
    );
  }

  Widget _buildCategoryFilters() {
    const filters = [
      (null, 'All'),
      (kFeedInventoryCategory, 'Feed'),
      (kMedicineInventoryCategory, 'Medicine'),
      (kVaccineInventoryCategory, 'Vaccine'),
      (kOtherInventoryCategory, 'Other'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: filters.map((entry) {
        final selected = _categoryFilter == entry.$1;
        return FilterChip(
          label: Text(entry.$2),
          selected: selected,
          onSelected: (_) => setState(() => _categoryFilter = entry.$1),
        );
      }).toList(),
    );
  }

  Widget _kpiCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    bool isNarrow,
  ) {
    return Container(
      width: isNarrow ? (MediaQuery.of(context).size.width - 48) : 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppDatabase db) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warehouse_outlined, size: 100, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 24),
          const Text('Inventory is Empty', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            'Add feed, medicine, or supplies to track your stock.',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => _showItemDialog(context, db),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20)),
            child: const Text('Add Your First Item'),
          ),
        ],
      ),
    );
  }

  Future<void> _showItemDialog(
    BuildContext context,
    AppDatabase db, {
    InventoryItem? editing,
  }) async {
    final nameController = TextEditingController(text: editing?.itemName ?? '');
    final levelController = TextEditingController(
      text: editing != null ? editing.stockLevel.toString() : '',
    );
    final unitController = TextEditingController(
      text: editing?.unit ?? kDefaultFeedUnit,
    );
    final costController = TextEditingController(
      text: editing?.costPerUnit?.toString() ?? '',
    );
    final reorderController = TextEditingController(
      text: (editing?.reorderLevel ?? 10).toString(),
    );
    var selectedCategory = editing?.category?.toUpperCase() ?? kFeedInventoryCategory;
    var selectedUsageType = normalizeHealthUsageType(editing?.usageType);

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDlgState) {
          final isHealthCategory = kHealthInventoryFormCategories.contains(selectedCategory);

          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(
              editing == null ? 'Add New Stock Item' : 'Edit Stock Item',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            content: SizedBox(
              width: 450,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: kInventoryFormCategories.contains(selectedCategory)
                          ? selectedCategory
                          : kOtherInventoryCategory,
                      items: kInventoryFormCategories
                          .map(
                            (cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat[0] + cat.substring(1).toLowerCase()),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDlgState(() {
                          selectedCategory = value;
                          unitController.text = defaultUnitForInventoryCategory(value);
                          if (!kHealthInventoryFormCategories.contains(value)) {
                            selectedUsageType = HealthUsageType.quantity;
                          }
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Category',
                        prefixIcon: const Icon(Icons.category_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    if (isHealthCategory) ...[
                      const SizedBox(height: 16),
                      InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Usage',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Text('One-time'),
                                selected: selectedUsageType == HealthUsageType.oneTime,
                                onSelected: (_) => setDlgState(() {
                                  selectedUsageType = HealthUsageType.oneTime;
                                  levelController.text = '1';
                                }),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ChoiceChip(
                                label: const Text('Quantity'),
                                selected: selectedUsageType == HealthUsageType.quantity,
                                onSelected: (_) => setDlgState(() {
                                  selectedUsageType = HealthUsageType.quantity;
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedUsageType == HealthUsageType.oneTime
                            ? 'Single application — stock capped at 1 and depletes when completed on a batch.'
                            : 'Tracked by stock quantity and unit.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Item Name',
                        hintText: 'e.g. Broiler Starter Mash',
                        prefixIcon: const Icon(Icons.inventory_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: levelController,
                            enabled: !(isHealthCategory &&
                                selectedUsageType == HealthUsageType.oneTime),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                            ],
                            decoration: InputDecoration(
                              labelText: 'Stock Level',
                              prefixIcon: const Icon(Icons.numbers_rounded),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: unitController,
                            decoration: InputDecoration(
                              labelText: 'Unit',
                              hintText: 'bags, doses…',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: costController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                            ],
                            decoration: InputDecoration(
                              labelText: 'Cost Per Unit (GH₵)',
                              prefixIcon: const Icon(Icons.attach_money_rounded),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: reorderController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                            ],
                            decoration: InputDecoration(
                              labelText: 'Reorder Level',
                              prefixIcon: const Icon(Icons.notification_important_rounded),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              FilledButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) return;

                  var stock = double.tryParse(levelController.text) ?? 0;
                  final cost = double.tryParse(costController.text) ?? 0;
                  final reorder = double.tryParse(reorderController.text) ?? 10;
                  final usageTypeDb = isHealthCategory
                      ? healthUsageTypeDbValue(selectedUsageType)
                      : null;
                  stock = normalizeHealthInventoryStock(
                    category: selectedCategory,
                    usageType: usageTypeDb,
                    stockLevel: stock,
                  );

                  final farmId = await FarmUtils.getBoundFarmId();
                  final workerId = await FarmUtils.getRequiredUserId();
                  if (farmId == null) return;

                  if (editing == null) {
                    await db.into(db.inventory).insert(
                          InventoryCompanion.insert(
                            id: newLocalId(),
                            farmId: farmId,
                            itemName: nameController.text.trim(),
                            category: Value(selectedCategory),
                            stockLevel: stock,
                            unit: unitController.text.trim().isEmpty
                                ? defaultUnitForInventoryCategory(selectedCategory)
                                : unitController.text.trim(),
                            costPerUnit: Value(cost),
                            reorderLevel: Value(reorder),
                            usageType: Value(usageTypeDb),
                            userId: Value(workerId),
                            synced: const Value(false),
                          ),
                        );
                  } else {
                    await (db.update(db.inventory)..where((t) => t.id.equals(editing.id))).write(
                      InventoryCompanion(
                        itemName: Value(nameController.text.trim()),
                        category: Value(selectedCategory),
                        stockLevel: Value(stock),
                        unit: Value(
                          unitController.text.trim().isEmpty
                              ? defaultUnitForInventoryCategory(selectedCategory)
                              : unitController.text.trim(),
                        ),
                        costPerUnit: Value(cost),
                        reorderLevel: Value(reorder),
                        usageType: Value(usageTypeDb),
                        synced: const Value(false),
                        updatedAt: Value(DateTime.now()),
                      ),
                    );
                  }

                  if (context.mounted) {
                    context.read<SyncEngine>().syncNow();
                    Navigator.pop(context);
                  }
                },
                style: FilledButton.styleFrom(backgroundColor: Colors.teal[600]),
                child: Text(editing == null ? 'Create Item' : 'Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InventoryItemTile extends StatelessWidget {
  const _InventoryItemTile({
    required this.item,
    required this.isNarrow,
    required this.showUsedUp,
    required this.repo,
    required this.farmId,
  });

  final InventoryItem item;
  final bool isNarrow;
  final bool showUsedUp;
  final InventoryRepository repo;
  final String farmId;

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final isLow = !showUsedUp && item.stockLevel <= (item.reorderLevel ?? 10);
    final currency = NumberFormat.currency(symbol: 'GH₵ ', decimalDigits: 2);

    return InkWell(
      onTap: () => _showUsageDetail(context, db),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.all(isNarrow ? 16 : 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isLow ? Colors.red.withValues(alpha: 0.3) : Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(item.category ?? kOtherInventoryCategory)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(item.category ?? kOtherInventoryCategory),
                    color: _getCategoryColor(item.category ?? kOtherInventoryCategory),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemName,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item.category ?? 'Uncategorized',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isHealthInventoryCategory(item.category) && item.usageType != null)
                        Text(
                          'Usage: ${item.usageType}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      showUsedUp
                          ? 'Used up'
                          : '${item.stockLevel} ${item.unit}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: showUsedUp ? 14 : 20,
                        color: showUsedUp || isLow
                            ? Colors.red[700]
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (isLow && !showUsedUp)
                      Text(
                        'LOW STOCK',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _infoChip(
                        context,
                        'Cost/Unit: ${currency.format(item.costPerUnit ?? 0)}',
                        Icons.sell_rounded,
                        Colors.grey,
                      ),
                      _infoChip(
                        context,
                        'Value: ${currency.format(item.stockLevel * (item.costPerUnit ?? 0))}',
                        Icons.payments_rounded,
                        Colors.green,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (!showUsedUp) ...[
                      IconButton.filledTonal(
                        onPressed: () => _showRestockDialog(context, db, item),
                        icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                        tooltip: 'Restock Item',
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: () => _showEditDialog(context, db, item),
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        tooltip: 'Edit Item',
                      ),
                      const SizedBox(width: 8),
                    ],
                    IconButton.filledTonal(
                      onPressed: () => _showUsageDetail(context, db),
                      icon: const Icon(Icons.history_rounded, size: 18),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue.withValues(alpha: 0.1),
                        foregroundColor: Colors.blue,
                      ),
                      tooltip: 'Usage History',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    AppDatabase db,
    InventoryItem item,
  ) async {
    final state = context.findAncestorStateOfType<_InventoryManagerState>();
    if (state != null) {
      await state._showItemDialog(context, db, editing: item);
    }
  }

  Future<void> _showUsageDetail(BuildContext context, AppDatabase db) async {
    final detail = await repo.getInventoryItemWithUsage(farmId, item.id);
    if (!context.mounted || detail == null) return;

    final dateFormat = DateFormat('MMM d, yyyy • HH:mm');
    final totalUsed = detail.usageEvents.fold<double>(
      0,
      (sum, event) => sum + event.quantity,
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Usage: ${detail.item.itemName}', style: const TextStyle(fontWeight: FontWeight.w900)),
        content: SizedBox(
          width: 560,
          height: 480,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _detailChip(
                    'Stock left',
                    detail.isUsedUp
                        ? 'Used up'
                        : '${detail.item.stockLevel} ${detail.item.unit}',
                    detail.isUsedUp ? Colors.red : Colors.teal,
                  ),
                  _detailChip(
                    'Recorded usage',
                    '${totalUsed.toStringAsFixed(1)} ${detail.item.unit}',
                    Colors.blue,
                  ),
                  if (detail.item.costPerUnit != null)
                    _detailChip(
                      'Cost/unit',
                      NumberFormat.currency(symbol: 'GH₵ ', decimalDigits: 2)
                          .format(detail.item.costPerUnit),
                      Colors.amber,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Who used it & when',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: detail.usageEvents.isEmpty
                    ? Center(
                        child: Text(
                          'No usage recorded yet.\nFeed usage comes from feeding logs.\nMedicine and vaccine usage comes from health schedules.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      )
                    : ListView.separated(
                        itemCount: detail.usageEvents.length,
                        separatorBuilder: (_, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final event = detail.usageEvents[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              _usageKindIcon(event.kind),
                              color: _usageKindColor(event.kind),
                            ),
                            title: Text(
                              '${_usageKindLabel(event.kind)} • ${event.quantity} ${event.unit}',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(
                              [
                                if (event.batchName != '-') 'Batch: ${event.batchName}',
                                if (event.status != null) 'Status: ${event.status}',
                              ].join(' • '),
                            ),
                            trailing: Text(
                              dateFormat.format(event.date.toLocal()),
                              style: const TextStyle(fontSize: 11),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _detailChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _infoChip(BuildContext context, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _showRestockDialog(
    BuildContext context,
    AppDatabase db,
    InventoryItem item,
  ) async {
    final qtyController = TextEditingController();
    final costController = TextEditingController(text: item.costPerUnit?.toString() ?? '');
    Customer? selectedSupplier;
    var isCredit = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: Text('Restock: ${item.itemName}', style: const TextStyle(fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StreamBuilder<List<Customer>>(
                stream: (db.select(db.customers)..where((t) => t.customerType.equals('SUPPLIER'))).watch(),
                builder: (context, snapshot) {
                  final suppliers = snapshot.data ?? [];
                  return DropdownButtonFormField<Customer>(
                    initialValue: selectedSupplier,
                    items: suppliers
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                        .toList(),
                    onChanged: (v) => setDlgState(() => selectedSupplier = v),
                    decoration: InputDecoration(
                      labelText: 'Supplier',
                      prefixIcon: const Icon(Icons.business_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Added Quantity',
                        suffixText: item.unit,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: costController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'New Cost/Unit',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Buy on Credit', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                value: isCredit,
                onChanged: (v) => setDlgState(() => isCredit = v),
                secondary: const Icon(Icons.credit_card_rounded),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final qty = double.tryParse(qtyController.text) ?? 0;
                final cost = double.tryParse(costController.text) ?? item.costPerUnit ?? 0;
                if (qty <= 0) return;

                final farmId = await FarmUtils.getBoundFarmId();
                final workerId = await FarmUtils.getRequiredUserId();
                if (farmId == null) return;

                await (db.update(db.inventory)..where((t) => t.id.equals(item.id))).write(
                  InventoryCompanion(
                    stockLevel: Value(item.stockLevel + qty),
                    costPerUnit: Value(cost),
                    synced: const Value(false),
                    updatedAt: Value(DateTime.now()),
                  ),
                );

                await db.into(db.stockLogs).insert(
                      StockLogsCompanion.insert(
                        id: newLocalId(),
                        farmId: farmId,
                        itemId: item.id,
                        quantity: qty,
                        logType: 'PROCURED',
                        supplierId: Value(selectedSupplier?.id),
                        logDate: Value(DateTime.now()),
                        synced: const Value(false),
                      ),
                    );

                final total = qty * cost;
                final descSuffix =
                    selectedSupplier != null ? ' (Supplier: ${selectedSupplier!.name})' : '';
                await db.into(db.expenses).insert(
                      ExpensesCompanion.insert(
                        id: newLocalId(),
                        farmId: farmId,
                        amount: total,
                        category: item.category ?? 'INVENTORY',
                        description: Value(
                          'Restocked ${item.itemName} x $qty ${item.unit}$descSuffix${isCredit ? ' [CREDIT]' : ''}',
                        ),
                        date: Value(DateTime.now()),
                        userId: Value(workerId),
                        supplierId: Value(selectedSupplier?.id),
                        synced: const Value(false),
                      ),
                    );

                if (isCredit && selectedSupplier != null) {
                  await (db.update(db.customers)..where((t) => t.id.equals(selectedSupplier!.id))).write(
                    CustomersCompanion(
                      balanceOwed: Value(selectedSupplier!.balanceOwed + total),
                      synced: const Value(false),
                    ),
                  );
                }

                if (context.mounted) {
                  context.read<SyncEngine>().syncNow();
                  Navigator.pop(context);
                }
              },
              child: const Text('Confirm Restock'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat.toUpperCase()) {
      case kFeedInventoryCategory:
        return Icons.grass_rounded;
      case kMedicineInventoryCategory:
        return Icons.medication_liquid_rounded;
      case kVaccineInventoryCategory:
        return Icons.vaccines_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _getCategoryColor(String cat) {
    switch (cat.toUpperCase()) {
      case kFeedInventoryCategory:
        return Colors.teal;
      case kMedicineInventoryCategory:
        return Colors.blue;
      case kVaccineInventoryCategory:
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _usageKindIcon(InventoryUsageKind kind) {
    switch (kind) {
      case InventoryUsageKind.feed:
        return Icons.grass_rounded;
      case InventoryUsageKind.vaccination:
        return Icons.vaccines_rounded;
      case InventoryUsageKind.medication:
        return Icons.medication_liquid_rounded;
    }
  }

  Color _usageKindColor(InventoryUsageKind kind) {
    switch (kind) {
      case InventoryUsageKind.feed:
        return Colors.teal;
      case InventoryUsageKind.vaccination:
        return Colors.orange;
      case InventoryUsageKind.medication:
        return Colors.blue;
    }
  }

  String _usageKindLabel(InventoryUsageKind kind) {
    switch (kind) {
      case InventoryUsageKind.feed:
        return 'Feed log';
      case InventoryUsageKind.vaccination:
        return 'Vaccination';
      case InventoryUsageKind.medication:
        return 'Medication';
    }
  }
}
