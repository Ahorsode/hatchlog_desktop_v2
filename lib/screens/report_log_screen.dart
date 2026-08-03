import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:drift/drift.dart' hide Column, Batch;
import '../data/local_db.dart';
import '../utils/inventory_constants.dart';
import '../utils/livestock_breed_options.dart';
import '../widgets/worker_stamp.dart';

/// Represents a single unified log entry from any category with detailed auditing data.
class _LogEntry {
  final String title;
  final String subtitle;
  final DateTime date;
  final IconData icon;
  final Color color;
  final String category;

  /// Formatted key-value pairs for deep verification and audit viewing.
  final Map<String, String> auditDetails;

  /// Raw payload map to support rich, category-specific formatting and layouts.
  final Map<String, dynamic> rawData;
  final String workerName;
  final String workerPosition;

  const _LogEntry({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    required this.color,
    required this.category,
    required this.auditDetails,
    required this.rawData,
    required this.workerName,
    required this.workerPosition,
  });
}

class _WorkerIdentity {
  final String name;
  final String position;

  const _WorkerIdentity({required this.name, required this.position});
}

class ReportLogScreen extends StatefulWidget {
  const ReportLogScreen({super.key});

  @override
  State<ReportLogScreen> createState() => _ReportLogScreenState();
}

class _ReportLogScreenState extends State<ReportLogScreen> {
  late AppDatabase db;
  bool _isGenerating = false;
  String _selectedCategory = 'Egg Production';

  static const _categories = [
    {'label': 'Egg Production', 'icon': Icons.egg_rounded},
    {'label': 'Financials', 'icon': Icons.account_balance_wallet_rounded},
    {'label': 'Livestock', 'icon': Icons.pets_rounded},
    {'label': 'Inventory', 'icon': Icons.inventory_2_rounded},
    {'label': 'Mortality', 'icon': Icons.warning_amber_rounded},
    {'label': 'Feeding', 'icon': Icons.restaurant_rounded},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    db = Provider.of<AppDatabase>(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F1113)
          : const Color(0xFFF8FAFC),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDark),
            const SizedBox(height: 24),
            _buildCategoryTabs(isDark),
            const SizedBox(height: 20),
            Expanded(child: _buildLogList(isDark)),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────
  Widget _buildHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reports & Logs',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Browse all record logs by category. Expand to view detailed audit trails and sync signatures.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _isGenerating ? null : _showExportDialog,
          icon: _isGenerating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.picture_as_pdf_rounded, size: 16),
          label: Text(
            _isGenerating ? 'GENERATING...' : 'EXPORT PDF',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D9488),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  // ── Horizontal Category Tabs ────────────────────────────────────────────
  Widget _buildCategoryTabs(bool isDark) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, i) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final label = cat['label'] as String;
          final icon = cat['icon'] as IconData;
          final isSelected = _selectedCategory == label;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _selectedCategory = label),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0D9488)
                        : isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0D9488)
                          : isDark
                          ? Colors.white12
                          : Colors.grey.shade200,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFF0D9488,
                              ).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : isDark
                            ? Colors.white54
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : isDark
                              ? Colors.white70
                              : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Main Log List ───────────────────────────────────────────────────────
  Widget _buildLogList(bool isDark) {
    return FutureBuilder<List<_LogEntry>>(
      future: _fetchLogs([_selectedCategory]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF0D9488)),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(isDark);
        }

        final logs = snapshot.data!;
        return ListView.builder(
          itemCount: logs.length,
          itemBuilder: (context, index) =>
              _LogCard(entry: logs[index], isDark: isDark),
        );
      },
    );
  }

  Future<List<_LogEntry>> _fetchLogs(List<String> categories) async {
    final List<_LogEntry> entries = [];

    // Pre-load all lookups in parallel
    final batchesList = await db.select(db.batches).get();
    final batchMap = {for (var b in batchesList) b.id: b.batchName};

    final housesList = await db.select(db.houses).get();
    final houseMap = {for (var h in housesList) h.id: h.name};

    final customersList = await db.select(db.customers).get();
    final customerMap = {for (var c in customersList) c.id: c.name};

    final feedTypesList = await (db.select(
      db.inventory,
    )..where((t) => t.category.equals(kFeedInventoryCategory))).get();
    final feedTypeMap = {for (var f in feedTypesList) f.id: f.itemName};

    final formulationsList = await db.select(db.feedFormulations).get();
    final formulationMap = {for (var f in formulationsList) f.id: f.name};

    String formatUserDisplayName(User u) {
      final displayName = u.name?.trim().isNotEmpty == true
          ? u.name!.trim()
          : [
              if (u.firstname?.trim().isNotEmpty == true) u.firstname!.trim(),
              if (u.middleName?.trim().isNotEmpty == true) u.middleName!.trim(),
              if (u.surname?.trim().isNotEmpty == true) u.surname!.trim(),
            ].join(' ').trim();

      if (displayName.isNotEmpty) {
        final email = u.email?.trim();
        return email != null && email.isNotEmpty
            ? '$displayName ($email)'
            : displayName;
      }

      return u.email?.trim().isNotEmpty == true
          ? u.email!.trim()
          : 'Unknown User';
    }

    final usersList = await db.select(db.users).get();
    final userMap = {for (var u in usersList) u.id: u};

    _WorkerIdentity getWorkerIdentity(String? userId) {
      if (userId == null || userId.isEmpty) {
        return const _WorkerIdentity(
          name: 'System / Unknown',
          position: 'System',
        );
      }
      final user = userMap[userId];
      if (user == null) {
        return _WorkerIdentity(
          name: 'ID: ${userId.length > 8 ? userId.substring(0, 8) : userId}',
          position: 'Unknown Position',
        );
      }
      final name = formatUserDisplayName(user);
      final role = user.role.trim().isEmpty ? 'Unknown Position' : user.role;
      return _WorkerIdentity(name: name, position: role);
    }

    String getLoggedUser(_WorkerIdentity worker) {
      return '${worker.name} (${worker.position})';
    }

    // Egg Production
    if (categories.contains('Egg Production')) {
      final eggLogs =
          await (db.select(db.eggProductions)
                ..orderBy([(t) => OrderingTerm.desc(t.logDate)])
                ..limit(100))
              .get();
      for (final log in eggLogs) {
        final worker = getWorkerIdentity(log.userId);
        final loggedUser = getLoggedUser(worker);
        entries.add(
          _LogEntry(
            title: '${log.eggsCollected} Eggs Collected',
            subtitle:
                'Unusable: ${log.unusableCount} | Grade: ${log.qualityGrade ?? 'N/A'}',
            date: log.logDate,
            icon: Icons.egg_alt_rounded,
            color: const Color(0xFFF59E0B),
            category: 'Egg Production',
            auditDetails: {
              'Date': DateFormat('dd MMM yyyy, HH:mm').format(log.logDate),
              'Batch': batchMap[log.batchId] ?? 'ID: ${log.batchId}',
              'Eggs Collected': '${log.eggsCollected}',
              'Unusable Count': '${log.unusableCount}',
              'Eggs Remaining': '${log.eggsRemaining}',
              'Crates Collected': log.cratesCollected != null
                  ? '${log.cratesCollected!.toStringAsFixed(1)} Crates'
                  : 'N/A',
              'Quality Grade': log.qualityGrade ?? 'N/A',
              'Logged By': loggedUser,
              'Sync Status': log.synced ? 'Synced' : 'Local Only',
            },
            rawData: {
              'logDate': log.logDate,
              'batchName': batchMap[log.batchId] ?? 'ID: ${log.batchId}',
              'eggsCollected': log.eggsCollected,
              'unusableCount': log.unusableCount,
              'eggsRemaining': log.eggsRemaining,
              'cratesCollected': log.cratesCollected,
              'qualityGrade': log.qualityGrade,
              'userId': loggedUser,
              'synced': log.synced,
            },
            workerName: worker.name,
            workerPosition: worker.position,
          ),
        );
      }
    }

    // Financials (Sales & Expenses)
    if (categories.contains('Financials')) {
      final salesLogs =
          await (db.select(db.sales)
                ..orderBy([(t) => OrderingTerm.desc(t.saleDate)])
                ..limit(100))
              .get();
      for (final log in salesLogs) {
        final worker = getWorkerIdentity(log.userId);
        final loggedUser = getLoggedUser(worker);
        entries.add(
          _LogEntry(
            title: 'Sale: GHS ${log.totalAmount.toStringAsFixed(2)}',
            subtitle:
                'Qty: ${log.quantity} | Cust: ${customerMap[log.customerId] ?? 'N/A'}',
            date: log.saleDate,
            icon: Icons.attach_money_rounded,
            color: const Color(0xFF10B981),
            category: 'Financials',
            auditDetails: {
              'Transaction Type': 'Sale / Income',
              'Date': DateFormat('dd MMM yyyy, HH:mm').format(log.saleDate),
              'Batch': log.batchId != null
                  ? (batchMap[log.batchId] ?? 'ID: ${log.batchId}')
                  : 'N/A',
              'Customer': log.customerId != null
                  ? (customerMap[log.customerId] ?? 'ID: ${log.customerId}')
                  : 'N/A',
              'Quantity': '${log.quantity}',
              'Unit Price': 'GHS ${log.unitPrice.toStringAsFixed(2)}',
              'Total Amount': 'GHS ${log.totalAmount.toStringAsFixed(2)}',
              'Logged By': loggedUser,
              'Sync Status': log.synced ? 'Synced' : 'Local Only',
            },
            rawData: {
              'type': 'Sale',
              'saleDate': log.saleDate,
              'batchName': log.batchId != null
                  ? (batchMap[log.batchId] ?? 'ID: ${log.batchId}')
                  : 'N/A',
              'customerName': log.customerId != null
                  ? (customerMap[log.customerId] ?? 'ID: ${log.customerId}')
                  : 'N/A',
              'quantity': log.quantity,
              'unitPrice': log.unitPrice,
              'totalAmount': log.totalAmount,
              'userId': loggedUser,
              'synced': log.synced,
            },
            workerName: worker.name,
            workerPosition: worker.position,
          ),
        );
      }

      final expenseLogs =
          await (db.select(db.expenses)
                ..orderBy([(t) => OrderingTerm.desc(t.date)])
                ..limit(100))
              .get();
      for (final log in expenseLogs) {
        final worker = getWorkerIdentity(log.userId);
        final loggedUser = getLoggedUser(worker);
        entries.add(
          _LogEntry(
            title: 'Expense: GHS ${log.amount.toStringAsFixed(2)}',
            subtitle: 'Cat: ${log.category} | ${log.description ?? 'No desc'}',
            date: log.date,
            icon: Icons.money_off_rounded,
            color: const Color(0xFFEF4444),
            category: 'Financials',
            auditDetails: {
              'Transaction Type': 'Expense / Outflow',
              'Date': DateFormat('dd MMM yyyy, HH:mm').format(log.date),
              'Category': log.category,
              'Amount': 'GHS ${log.amount.toStringAsFixed(2)}',
              'Description': log.description ?? 'N/A',
              'Logged By': loggedUser,
              'Sync Status': log.synced ? 'Synced' : 'Local Only',
            },
            rawData: {
              'type': 'Expense',
              'date': log.date,
              'category': log.category,
              'amount': log.amount,
              'description': log.description,
              'userId': loggedUser,
              'synced': log.synced,
            },
            workerName: worker.name,
            workerPosition: worker.position,
          ),
        );
      }
    }

    // Livestock
    if (categories.contains('Livestock')) {
      final batches =
          await (db.select(db.batches)
                ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
                ..limit(100))
              .get();
      for (final log in batches) {
        final worker = getWorkerIdentity(log.userId);
        final loggedUser = getLoggedUser(worker);
        entries.add(
          _LogEntry(
            title: log.batchName,
            subtitle:
                '${log.currentCount} Birds | Breed: ${LivestockBreedCatalog.labelForKey(log.breedType)}',
            date: log.createdAt,
            icon: Icons.pets_rounded,
            color: const Color(0xFF3B82F6),
            category: 'Livestock',
            auditDetails: {
              'Batch Name': log.batchName,
              'Type': log.type.replaceAll('POULTRY_', ''),
              'Breed': LivestockBreedCatalog.labelForKey(log.breedType),
              'Arrival Date': DateFormat('dd MMM yyyy').format(log.arrivalDate),
              'Current Count': '${log.currentCount}',
              'Initial Count': '${log.initialCount}',
              'Isolation Count': '${log.isolationCount}',
              'Initial Cost': log.initialActualCost != null
                  ? 'GHS ${log.initialActualCost!.toStringAsFixed(2)}'
                  : 'N/A',
              'Growth Target': log.growthTarget ?? 'N/A',
              'House': log.houseId != null
                  ? (houseMap[log.houseId] ?? 'ID: ${log.houseId}')
                  : 'N/A',
              'Status': log.status,
              'Created At': DateFormat(
                'dd MMM yyyy, HH:mm',
              ).format(log.createdAt),
              'Updated At': DateFormat(
                'dd MMM yyyy, HH:mm',
              ).format(log.updatedAt),
              'Logged By': loggedUser,
              'Sync Status': log.synced ? 'Synced' : 'Local Only',
            },
            rawData: {
              'batchName': log.batchName,
              'type': log.type.replaceAll('POULTRY_', ''),
              'breedType': log.breedType,
              'arrivalDate': log.arrivalDate,
              'currentCount': log.currentCount,
              'initialCount': log.initialCount,
              'isolationCount': log.isolationCount,
              'initialActualCost': log.initialActualCost,
              'growthTarget': log.growthTarget,
              'houseName': log.houseId != null
                  ? (houseMap[log.houseId] ?? 'ID: ${log.houseId}')
                  : 'N/A',
              'status': log.status,
              'createdAt': log.createdAt,
              'updatedAt': log.updatedAt,
              'userId': loggedUser,
              'synced': log.synced,
            },
            workerName: worker.name,
            workerPosition: worker.position,
          ),
        );
      }
    }

    // Inventory
    if (categories.contains('Inventory')) {
      final items =
          await (db.select(db.inventory)
                ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
                ..limit(100))
              .get();
      for (final log in items) {
        final worker = getWorkerIdentity(log.userId);
        final loggedUser = getLoggedUser(worker);
        entries.add(
          _LogEntry(
            title: log.itemName,
            subtitle:
                'Stock: ${log.stockLevel} ${log.unit} | Cat: ${log.category ?? 'N/A'}',
            date: log.updatedAt,
            icon: Icons.inventory_2_rounded,
            color: const Color(0xFF8B5CF6),
            category: 'Inventory',
            auditDetails: {
              'Item Name': log.itemName,
              'Category': log.category ?? 'N/A',
              'Stock Level': '${log.stockLevel} ${log.unit}',
              'Reorder Level': log.reorderLevel != null
                  ? '${log.reorderLevel} ${log.unit}'
                  : 'N/A',
              'Cost Per Unit': log.costPerUnit != null
                  ? 'GHS ${log.costPerUnit!.toStringAsFixed(2)}'
                  : 'N/A',
              'Supplier': log.supplierId != null
                  ? (customerMap[log.supplierId] ?? 'ID: ${log.supplierId}')
                  : 'N/A',
              'Last Updated': DateFormat(
                'dd MMM yyyy, HH:mm',
              ).format(log.updatedAt),
              'Logged By': loggedUser,
              'Sync Status': log.synced ? 'Synced' : 'Local Only',
            },
            rawData: {
              'itemName': log.itemName,
              'category': log.category,
              'stockLevel': log.stockLevel,
              'unit': log.unit,
              'reorderLevel': log.reorderLevel,
              'costPerUnit': log.costPerUnit,
              'supplierName': log.supplierId != null
                  ? (customerMap[log.supplierId] ?? 'ID: ${log.supplierId}')
                  : 'N/A',
              'updatedAt': log.updatedAt,
              'userId': loggedUser,
              'synced': log.synced,
            },
            workerName: worker.name,
            workerPosition: worker.position,
          ),
        );
      }
    }

    // Mortality
    if (categories.contains('Mortality')) {
      final morts =
          await (db.select(db.mortalities)
                ..orderBy([(t) => OrderingTerm.desc(t.logDate)])
                ..limit(100))
              .get();
      for (final log in morts) {
        final worker = getWorkerIdentity(log.userId);
        final loggedUser = getLoggedUser(worker);
        entries.add(
          _LogEntry(
            title: '${log.count} Mortality',
            subtitle:
                'Batch: ${batchMap[log.batchId] ?? 'N/A'} | Reason: ${log.reason ?? 'N/A'}',
            date: log.logDate,
            icon: Icons.warning_amber_rounded,
            color: const Color(0xFFEF4444),
            category: 'Mortality',
            auditDetails: {
              'Date': DateFormat('dd MMM yyyy, HH:mm').format(log.logDate),
              'Batch': batchMap[log.batchId] ?? 'ID: ${log.batchId}',
              'Count': '${log.count}',
              'Reason': log.reason ?? 'No reason specified',
              'Category': log.category ?? 'N/A',
              'Sub-Category': log.subCategory ?? 'N/A',
              'Logged By': loggedUser,
              'Sync Status': log.synced ? 'Synced' : 'Local Only',
            },
            rawData: {
              'logDate': log.logDate,
              'batchName': batchMap[log.batchId] ?? 'ID: ${log.batchId}',
              'count': log.count,
              'reason': log.reason,
              'category': log.category,
              'subCategory': log.subCategory,
              'userId': loggedUser,
              'synced': log.synced,
            },
            workerName: worker.name,
            workerPosition: worker.position,
          ),
        );
      }
    }

    // Feeding
    if (categories.contains('Feeding')) {
      final feeds =
          await (db.select(db.feedingLogs)
                ..orderBy([(t) => OrderingTerm.desc(t.logDate)])
                ..limit(100))
              .get();
      for (final log in feeds) {
        final worker = getWorkerIdentity(log.userId);
        final loggedUser = getLoggedUser(worker);
        entries.add(
          _LogEntry(
            title: '${log.amountConsumed.toStringAsFixed(1)} kg Feed Consumed',
            subtitle:
                'Batch: ${batchMap[log.batchId] ?? 'N/A'} | Feed: ${feedTypeMap[log.feedTypeId] ?? 'N/A'}',
            date: log.logDate,
            icon: Icons.restaurant_rounded,
            color: const Color(0xFFEC4899),
            category: 'Feeding',
            auditDetails: {
              'Date': DateFormat('dd MMM yyyy, HH:mm').format(log.logDate),
              'Batch': log.batchId != null
                  ? (batchMap[log.batchId] ?? 'ID: ${log.batchId}')
                  : 'N/A',
              'Feed Type': log.feedTypeId != null
                  ? (feedTypeMap[log.feedTypeId] ?? 'ID: ${log.feedTypeId}')
                  : 'N/A',
              'Formulation': log.formulationId != null
                  ? (formulationMap[log.formulationId] ??
                        'ID: ${log.formulationId}')
                  : 'N/A',
              'Amount Consumed': '${log.amountConsumed.toStringAsFixed(2)} kg',
              'Logged By': loggedUser,
              'Sync Status': log.synced ? 'Synced' : 'Local Only',
            },
            rawData: {
              'logDate': log.logDate,
              'batchName': log.batchId != null
                  ? (batchMap[log.batchId] ?? 'ID: ${log.batchId}')
                  : 'N/A',
              'feedTypeName': log.feedTypeId != null
                  ? (feedTypeMap[log.feedTypeId] ?? 'ID: ${log.feedTypeId}')
                  : 'N/A',
              'formulationName': log.formulationId != null
                  ? (formulationMap[log.formulationId] ??
                        'ID: ${log.formulationId}')
                  : 'N/A',
              'amountConsumed': log.amountConsumed,
              'userId': loggedUser,
              'synced': log.synced,
            },
            workerName: worker.name,
            workerPosition: worker.position,
          ),
        );
      }
    }

    // Sort all entries by date descending
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  // ── Empty State ─────────────────────────────────────────────────────────
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 60,
            color: isDark ? Colors.white12 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No logs found for "$_selectedCategory"',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white38 : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Records will appear here once data is logged.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white24 : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  // ── PDF Export Dialog ────────────────────────────────────────────────────
  void _showExportDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Set<String> selectedForExport = {
      ..._categories.map((c) => c['label'] as String),
    };
    bool selectAll = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF161A1D) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export Reports to PDF',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select which categories to include in the audit report.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Select All
                    CheckboxListTile(
                      title: const Text(
                        'Select All',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      value: selectAll,
                      activeColor: const Color(0xFF0D9488),
                      onChanged: (val) {
                        setDialogState(() {
                          selectAll = val ?? false;
                          if (selectAll) {
                            selectedForExport.addAll(
                              _categories.map((c) => c['label'] as String),
                            );
                          } else {
                            selectedForExport.clear();
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(),
                    // Individual Categories
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: _categories.map((cat) {
                          final label = cat['label'] as String;
                          return CheckboxListTile(
                            title: Text(label),
                            value: selectedForExport.contains(label),
                            activeColor: const Color(0xFF0D9488),
                            onChanged: (val) {
                              setDialogState(() {
                                if (val == true) {
                                  selectedForExport.add(label);
                                } else {
                                  selectedForExport.remove(label);
                                  selectAll = false;
                                }
                                if (selectedForExport.length ==
                                    _categories.length) {
                                  selectAll = true;
                                }
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : const Color(0xFF64748B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: selectedForExport.isEmpty
                      ? null
                      : () {
                          Navigator.pop(context);
                          _generatePdfReport(selectedForExport.toList());
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Export PDF',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _generatePdfReport(List<String> categoriesToExport) async {
    setState(() => _isGenerating = true);

    try {
      final exportLogs = await _fetchLogs(categoriesToExport);
      final doc = pw.Document();

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context ctx) {
            final List<pw.Widget> pageContent = [];

            // Header
            pageContent.add(
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'FARM MANAGEMENT SYSTEM',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.teal700,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'AUDITING & VERIFICATION REPORT',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.teal900,
                            ),
                          ),
                        ],
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.teal50,
                          borderRadius: pw.BorderRadius.all(
                            pw.Radius.circular(6),
                          ),
                        ),
                        child: pw.Text(
                          'AUDITED & VERIFIED',
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.teal700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'Generated on: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Divider(color: PdfColors.teal, thickness: 1.5),
                  pw.SizedBox(height: 12),
                ],
              ),
            );

            if (exportLogs.isEmpty) {
              pageContent.add(
                pw.Text(
                  'No records found for selected categories.',
                  style: pw.TextStyle(color: PdfColors.grey),
                ),
              );
            } else {
              // Print separate custom table for each category
              for (final category in categoriesToExport) {
                final catLogs = exportLogs
                    .where((e) => e.category == category)
                    .toList();
                if (catLogs.isEmpty) continue;

                pageContent.add(
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
                    child: pw.Row(
                      children: [
                        pw.Container(
                          width: 4,
                          height: 12,
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.teal,
                            borderRadius: pw.BorderRadius.all(
                              pw.Radius.circular(2),
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 6),
                        pw.Text(
                          category.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.teal800,
                          ),
                        ),
                      ],
                    ),
                  ),
                );

                List<String> headers = [];
                List<List<dynamic>> data = [];

                switch (category) {
                  case 'Egg Production':
                    headers = [
                      'Date',
                      'Batch',
                      'Eggs Coll.',
                      'Unusable',
                      'Remaining',
                      'Crates',
                      'Grade',
                      'Synced',
                      'User',
                    ];
                    data = catLogs
                        .map(
                          (e) => [
                            DateFormat('dd/MM/yy HH:mm').format(e.date),
                            e.auditDetails['Batch'] ?? '',
                            e.auditDetails['Eggs Collected'] ?? '',
                            e.auditDetails['Unusable Count'] ?? '',
                            e.auditDetails['Eggs Remaining'] ?? '',
                            e.auditDetails['Crates Collected'] ?? '',
                            e.auditDetails['Quality Grade'] ?? '',
                            e.auditDetails['Sync Status'] ?? '',
                            e.auditDetails['Logged By'] ?? '',
                          ],
                        )
                        .toList();
                    break;

                  case 'Financials':
                    headers = [
                      'Date',
                      'Type',
                      'Item/Batch',
                      'Customer/Cat',
                      'Qty/Desc',
                      'Unit Price',
                      'Total',
                      'User',
                    ];
                    data = catLogs.map((e) {
                      final isSale = e.rawData['type'] == 'Sale';
                      return [
                        DateFormat('dd/MM/yy HH:mm').format(e.date),
                        isSale ? 'SALE' : 'EXPENSE',
                        isSale
                            ? (e.rawData['batchName'] ?? '')
                            : (e.rawData['category'] ?? ''),
                        isSale ? (e.rawData['customerName'] ?? '') : '',
                        isSale
                            ? '${e.rawData['quantity']}'
                            : (e.rawData['description'] ?? ''),
                        isSale
                            ? 'GHS ${e.rawData['unitPrice'].toStringAsFixed(2)}'
                            : '',
                        'GHS ${isSale ? e.rawData['totalAmount'].toStringAsFixed(2) : e.rawData['amount'].toStringAsFixed(2)}',
                        e.auditDetails['Logged By'] ?? '',
                      ];
                    }).toList();
                    break;

                  case 'Livestock':
                    headers = [
                      'Batch Name',
                      'Type',
                      'Breed',
                      'Arrival Date',
                      'Count',
                      'Initial',
                      'House',
                      'Status',
                      'Synced',
                    ];
                    data = catLogs
                        .map(
                          (e) => [
                            e.auditDetails['Batch Name'] ?? '',
                            e.auditDetails['Type'] ?? '',
                            e.auditDetails['Breed'] ?? '',
                            e.auditDetails['Arrival Date'] ?? '',
                            e.auditDetails['Current Count'] ?? '',
                            e.auditDetails['Initial Count'] ?? '',
                            e.auditDetails['House'] ?? '',
                            e.auditDetails['Status'] ?? '',
                            e.auditDetails['Sync Status'] ?? '',
                          ],
                        )
                        .toList();
                    break;

                  case 'Inventory':
                    headers = [
                      'Item Name',
                      'Category',
                      'Stock Level',
                      'Reorder Lvl',
                      'Cost/Unit',
                      'Supplier',
                      'Updated',
                      'Synced',
                    ];
                    data = catLogs
                        .map(
                          (e) => [
                            e.auditDetails['Item Name'] ?? '',
                            e.auditDetails['Category'] ?? '',
                            e.auditDetails['Stock Level'] ?? '',
                            e.auditDetails['Reorder Level'] ?? '',
                            e.auditDetails['Cost Per Unit'] ?? '',
                            e.auditDetails['Supplier'] ?? '',
                            e.auditDetails['Last Updated'] ?? '',
                            e.auditDetails['Sync Status'] ?? '',
                          ],
                        )
                        .toList();
                    break;

                  case 'Mortality':
                    headers = [
                      'Date',
                      'Batch',
                      'Count',
                      'Reason',
                      'Category',
                      'Sub-Category',
                      'Synced',
                      'User',
                    ];
                    data = catLogs
                        .map(
                          (e) => [
                            DateFormat('dd/MM/yy HH:mm').format(e.date),
                            e.auditDetails['Batch'] ?? '',
                            e.auditDetails['Count'] ?? '',
                            e.auditDetails['Reason'] ?? '',
                            e.auditDetails['Category'] ?? '',
                            e.auditDetails['Sub-Category'] ?? '',
                            e.auditDetails['Sync Status'] ?? '',
                            e.auditDetails['Logged By'] ?? '',
                          ],
                        )
                        .toList();
                    break;

                  case 'Feeding':
                    headers = [
                      'Date',
                      'Batch',
                      'Feed Type',
                      'Formulation',
                      'Amount',
                      'Synced',
                      'User',
                    ];
                    data = catLogs
                        .map(
                          (e) => [
                            DateFormat('dd/MM/yy HH:mm').format(e.date),
                            e.auditDetails['Batch'] ?? '',
                            e.auditDetails['Feed Type'] ?? '',
                            e.auditDetails['Formulation'] ?? '',
                            e.auditDetails['Amount Consumed'] ?? '',
                            e.auditDetails['Sync Status'] ?? '',
                            e.auditDetails['Logged By'] ?? '',
                          ],
                        )
                        .toList();
                    break;

                  default:
                    headers = ['Date', 'Title', 'Subtitle'];
                    data = catLogs
                        .map(
                          (e) => [
                            DateFormat('dd/MM/yy HH:mm').format(e.date),
                            e.title,
                            e.subtitle,
                          ],
                        )
                        .toList();
                }

                pageContent.add(
                  pw.TableHelper.fromTextArray(
                    headers: headers,
                    data: data,
                    headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                      fontSize: 8,
                    ),
                    headerDecoration: const pw.BoxDecoration(
                      color: PdfColors.teal,
                    ),
                    cellPadding: const pw.EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 3,
                    ),
                    cellStyle: const pw.TextStyle(fontSize: 7),
                    oddRowDecoration: const pw.BoxDecoration(
                      color: PdfColors.grey50,
                    ),
                  ),
                );
                pageContent.add(pw.SizedBox(height: 12));
              }
            }

            return pageContent;
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name:
            'Audit_Report_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate report: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }
}

class _LogCard extends StatefulWidget {
  final _LogEntry entry;
  final bool isDark;

  const _LogCard({required this.entry, required this.isDark});

  @override
  State<_LogCard> createState() => _LogCardState();
}

class _LogCardState extends State<_LogCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final isDark = widget.isDark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161A1D) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isExpanded
                ? entry.color.withValues(alpha: 0.5)
                : isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.grey.shade200,
            width: _isExpanded ? 1.5 : 1.0,
          ),
          boxShadow: [
            if (_isExpanded)
              BoxShadow(
                color: entry.color.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
            else if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: entry.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(entry.icon, color: entry.color, size: 18),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              entry.subtitle,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white54
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: entry.color.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  entry.category,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: entry.color,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _isExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: isDark
                                    ? Colors.white30
                                    : Colors.grey.shade400,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            DateFormat('dd MMM yyyy, HH:mm').format(entry.date),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white38
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: _isExpanded
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              Divider(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.grey.shade200,
                                height: 1,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(
                                    Icons.verified_user_rounded,
                                    color: entry.color,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'AUDITING & VERIFICATION RECORDS',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                      color: entry.color,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildAuditGrid(entry.auditDetails, isDark),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      WorkerStamp(
                                        fullName: entry.workerName,
                                        position: entry.workerPosition,
                                        color: entry.color,
                                        fontSize: 8.5,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 2,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Operator: ${entry.workerName} (${entry.workerPosition})',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? Colors.white38
                                              : Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF0D9488,
                                      ).withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF0D9488,
                                        ).withValues(alpha: 0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.check_circle_outline_rounded,
                                          color: Color(0xFF0D9488),
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'AUDITED',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            color: const Color(0xFF0D9488),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuditGrid(Map<String, String> details, bool isDark) {
    final gridItems = details.entries
        .where((e) => e.key != 'Logged By' && e.key != 'Date')
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int crossAxisCount = width > 450 ? 2 : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: gridItems.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: 52,
            crossAxisSpacing: 10,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final item = gridItems[index];
            final key = item.key;
            final val = item.value;

            Color valColor = isDark
                ? const Color(0xDDFFFFFF)
                : const Color(0xFF1E293B);
            FontWeight valWeight = FontWeight.w700;
            Widget? customWidget;

            if (key == 'Sync Status') {
              final isSynced = val == 'Synced';
              customWidget = Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isSynced
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              (isSynced
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFF59E0B))
                                  .withValues(alpha: 0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    val,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isSynced
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              );
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.02)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.grey.shade100,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    key.toUpperCase(),
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white30 : Colors.grey.shade400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  customWidget ??
                      Text(
                        val,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: valWeight,
                          color: valColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
