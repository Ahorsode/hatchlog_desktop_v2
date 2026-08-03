import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift hide Column;
import '../utils/farm_utils.dart';
import '../data/sync_engine.dart';
import '../data/local_db.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = true;
  String? _fetchError;
  String _searchQuery = '';
  String? _selectedTableFilter;

  List<Map<String, dynamic>> _auditLogs = [];
  List<Map<String, dynamic>> _deleteLogs = [];
  List<Map<String, dynamic>> _financialLogs = [];
  List<Map<String, dynamic>> _stockLogs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          // Clear query and table filters when switching tabs for a clean experience
          _searchQuery = '';
          _searchController.clear();
          _selectedTableFilter = null;
        });
      }
    });
    _fetchLogs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchLogs() async {
    setState(() {
      _isLoading = true;
      _fetchError = null;
    });

    try {
      if (mounted) {
        await context.read<SyncEngine>().performSync();
      }

      final farmId = await FarmUtils.getBoundFarmId();
      if (farmId == null) {
        setState(() {
          _isLoading = false;
          _fetchError = "No bound farm found. Please check your settings.";
        });
        return;
      }

      // Fetch local users for offline-first mapping
      final db = context.read<AppDatabase>();
      final localUsers = await db.select(db.users).get();
      final userMap = {for (var u in localUsers) u.id: u};


      List<dynamic> auditData = [];
      try {
        // 1. Fetch Edit Logs (Safe select without users relationship join)
        auditData = await _supabase
            .from('audit_logs')
            .select('*')
            .eq('farm_id', farmId)
            .order('created_at', ascending: false)
            .limit(100);
      } catch (e) {
        debugPrint('Error fetching audit_logs: $e');
        _fetchError ??= 'Audit Logs: $e\n';
      }

      List<dynamic> deleteData = [];
      try {
        // 2. Fetch Delete Logs (Safe select without users relationship join)
        deleteData = await _supabase
            .from('delete_logs')
            .select('*')
            .eq('farm_id', farmId)
            .order('deleted_at', ascending: false)
            .limit(100);
      } catch (e) {
        debugPrint('Error fetching delete_logs: $e');
        if (_fetchError == null) {
          _fetchError = 'Delete Logs: $e\n';
        } else {
          _fetchError = '$_fetchError Delete Logs: $e\n';
        }
      }

      // Map audit logs with local user details
      final List<Map<String, dynamic>> combined = [];
      for (var row in auditData) {
        final userId = row['user_id'] as String?;
        Map<String, dynamic>? localUserData;
        if (userId != null && userMap.containsKey(userId)) {
          final u = userMap[userId]!;
          localUserData = {
            'firstname': u.firstname,
            'surname': u.surname,
            'email': u.email,
          };
        }
        combined.add({
          ...row,
          'type': 'UPDATE',
          'display_date': row['created_at'],
          'display_table': row['table_name'],
          'users': localUserData,
        });
      }

      // Map delete logs with local user details
      final List<Map<String, dynamic>> mappedDeleteData = [];
      for (var row in deleteData) {
        final userId = row['user_id'] as String?;
        Map<String, dynamic>? localUserData;
        if (userId != null && userMap.containsKey(userId)) {
          final u = userMap[userId]!;
          localUserData = {
            'firstname': u.firstname,
            'surname': u.surname,
            'email': u.email,
          };
        }
        mappedDeleteData.add({
          ...row,
          'users': localUserData,
        });
      }

      setState(() {
        _auditLogs = combined;
        _deleteLogs = mappedDeleteData;
      });

      await _fetchFinancialLogs();
      await _fetchStockLogs();
    } catch (e) {
      debugPrint('Error fetching Supabase logs: $e');
      setState(() {
        _fetchError = e.toString();
      });
      // Fallback: Still fetch local financial and stock logs even if Supabase triggers fail
      await _fetchFinancialLogs();
      await _fetchStockLogs();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchFinancialLogs() async {
    try {
      final db = context.read<AppDatabase>();
      final farmId = await FarmUtils.getBoundFarmId();
      if (farmId == null) return;

      final sales = await (db.select(db.sales)..where((t) => t.farmId.equals(farmId))).get();
      final expenses = await (db.select(db.expenses)..where((t) => t.farmId.equals(farmId))).get();
      final settlements = await (db.select(db.settlements)..where((t) => t.farmId.equals(farmId))).get();
      final customers = await (db.select(db.customers)..where((t) => t.farmId.equals(farmId))).get();

      final customerMap = {for (var c in customers) c.id: c.name};
      final List<Map<String, dynamic>> combined = [];

      for (var s in sales) {
        combined.add({
          'title': 'Sale Recorded',
          'subtitle': 'Quantity: ${s.quantity}',
          'amount': s.totalAmount,
          'date': s.saleDate,
          'icon': Icons.trending_up_rounded,
          'color': const Color(0xFF16A34A),
          'details': 'Sale ID: ${s.id} • Unit Price: GH₵ ${s.unitPrice}',
          'is_income': true,
        });
      }

      for (var e in expenses) {
        combined.add({
          'title': 'Expense: ${e.category}',
          'subtitle': e.description ?? 'No description',
          'amount': e.amount,
          'date': e.date,
          'icon': Icons.trending_down_rounded,
          'color': const Color(0xFFDC2626),
          'details': 'Expense ID: ${e.id}',
          'is_income': false,
        });
      }

      for (var st in settlements) {
        final entityName = customerMap[st.customerId] ?? 'Unknown';
        String title = 'Settlement';
        String subtitle = 'Entity: $entityName';
        IconData icon = Icons.receipt_long_rounded;
        Color color = Colors.grey;
        bool isIncome = false;

        if (st.settlementType == 'COLLECTION') {
          title = 'Balance Collection';
          subtitle = 'From: $entityName';
          icon = Icons.account_balance_wallet_rounded;
          color = Colors.orange;
          isIncome = true;
        } else if (st.settlementType == 'PAYMENT') {
          title = 'Debt Payment';
          subtitle = 'To: $entityName';
          icon = Icons.payments_rounded;
          color = Colors.purpleAccent;
          isIncome = false;
        } else if (st.settlementType == 'DEBT_INCURRED') {
          title = 'Credit Purchase';
          subtitle = 'Debt to: $entityName';
          icon = Icons.credit_score_rounded;
          color = Colors.blueGrey;
          isIncome = false;
        }

        combined.add({
          'title': title,
          'subtitle': subtitle,
          'amount': st.amount,
          'date': st.settlementDate,
          'icon': icon,
          'color': color,
          'details': 'Settlement ID: ${st.id} • Type: ${st.settlementType}',
          'is_income': isIncome,
        });
      }

      combined.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

      setState(() {
        _financialLogs = combined;
      });
    } catch (e) {
      debugPrint('Error fetching financial logs: $e');
    }
  }

  Future<void> _fetchStockLogs() async {
    try {
      final db = context.read<AppDatabase>();
      final farmId = await FarmUtils.getBoundFarmId();
      if (farmId == null) return;

      final logs = await (db.select(db.stockLogs)
            ..where((t) => t.farmId.equals(farmId))
            ..orderBy([(t) => drift.OrderingTerm(expression: t.logDate, mode: drift.OrderingMode.desc)]))
          .get();

      final inventory = await (db.select(db.inventory)..where((t) => t.farmId.equals(farmId))).get();
      final inventoryMap = {for (var i in inventory) i.id: i.itemName};

      final List<Map<String, dynamic>> mappedLogs = [];
      for (var l in logs) {
        final itemName = inventoryMap[l.itemId] ?? 'Unknown Item';

        String title = 'Inventory Update';
        IconData icon = Icons.inventory_2_rounded;
        Color color = Colors.grey;

        if (l.logType == 'PROCURED') {
          title = 'Restock: $itemName';
          icon = Icons.add_shopping_cart_rounded;
          color = const Color(0xFF16A34A);
        } else if (l.logType == 'CONSUMED') {
          title = 'Usage: $itemName';
          icon = Icons.remove_shopping_cart_rounded;
          color = const Color(0xFFF59E0B);
        } else if (l.logType == 'ADJUSTED') {
          title = 'Adjustment: $itemName';
          icon = Icons.tune_rounded;
          color = const Color(0xFF3B82F6);
        }

        mappedLogs.add({
          'title': title,
          'subtitle': '${l.logType} • Qty: ${l.quantity.abs()} ${l.note ?? ""}',
          'date': l.logDate,
          'icon': icon,
          'color': color,
          'details': 'Log ID: ${l.id}${l.note != null ? ' • Note: ${l.note}' : ''}',
        });
      }

      setState(() {
        _stockLogs = mappedLogs;
      });
    } catch (e) {
      debugPrint('Error fetching stock logs: $e');
    }
  }

  // Helper: Extract unique tables across loaded audit & delete lists for filtering chips
  Set<String> _getUniqueTables() {
    final Set<String> tables = {};
    if (_tabController.index == 0) {
      for (var row in _auditLogs) {
        if (row['display_table'] != null) {
          tables.add(row['display_table']);
        }
      }
    } else if (_tabController.index == 1) {
      for (var row in _deleteLogs) {
        if (row['table_name'] != null) {
          tables.add(row['table_name']);
        }
      }
    }
    return tables;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Premium theme-adaptive gradient background matching our global aesthetic
    final bgGradient = LinearGradient(
      colors: isDark
          ? [const Color(0xFF030712), const Color(0xFF091E0F)] // Sleek dark twilight gradient
          : [const Color(0xFFF8FAFC), const Color(0xFFE2F0D9)], // Elegant light slate/mint mint gradient
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderBar(isDark),
              _buildFilterSection(isDark),
              
              if (_fetchError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                  child: _buildWarningNotice(isDark),
                ),

              Expanded(
                child: _isLoading
                    ? _buildSkeletonTimeline()
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildAuditList(),
                          _buildDeleteList(),
                          _buildFinancialList(),
                          _buildStockList(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HEADER SECTION ---
  Widget _buildHeaderBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40, top: 40, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Audit Vault & Log Logs',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ENTERPRISE SECURITY & TRANSACTIONAL LOG TRACKER',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isDark ? const Color(0xFF34D399) : const Color(0xFF15803D),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: _fetchLogs,
            icon: Icon(
              Icons.sync_rounded,
              color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF16A34A),
            ),
            tooltip: 'Sync Audit Engine',
            style: IconButton.styleFrom(
              backgroundColor: isDark ? const Color(0x1F10B981) : const Color(0xFFDCFCE7),
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // --- FILTER & TABS CONTAINER ---
  Widget _buildFilterSection(bool isDark) {
    final uniqueTables = _getUniqueTables();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Beautiful Tab Selector
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B).withOpacity(0.5) : Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.06)),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicator: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFF16A34A),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.3),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  dividerColor: Colors.transparent,
                  tabAlignment: TabAlignment.start,
                  tabs: const [
                    Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Edits'))),
                    Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Deletions'))),
                    Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Financials'))),
                    Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Inventory'))),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Search Input Field
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B).withOpacity(0.5) : Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.06)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      hintText: 'Search logs by user, table, values, or category...',
                      hintStyle: TextStyle(
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Horizontal Filter Chips (Table Specific, shown for Updates and Deletes tabs)
          if (uniqueTables.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // 'All' chip
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: _selectedTableFilter == null,
                      label: const Text('All tables'),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _selectedTableFilter == null
                            ? Colors.white
                            : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                      ),
                      backgroundColor: isDark ? const Color(0xFF1E293B).withOpacity(0.3) : const Color(0xFFF1F5F9),
                      selectedColor: isDark ? const Color(0xFF10B981) : const Color(0xFF16A34A),
                      checkmarkColor: Colors.white,
                      side: BorderSide(
                        color: _selectedTableFilter == null
                            ? Colors.transparent
                            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onSelected: (selected) {
                        setState(() {
                          _selectedTableFilter = null;
                        });
                      },
                    ),
                  ),
                  ...uniqueTables.map((table) {
                    final isSelected = _selectedTableFilter == table;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(table.toUpperCase()),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                        ),
                        backgroundColor: isDark ? const Color(0xFF1E293B).withOpacity(0.3) : const Color(0xFFF1F5F9),
                        selectedColor: isDark ? const Color(0xFF10B981) : const Color(0xFF16A34A),
                        checkmarkColor: Colors.white,
                        side: BorderSide(
                          color: isSelected
                              ? Colors.transparent
                              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        onSelected: (selected) {
                          setState(() {
                            _selectedTableFilter = selected ? table : null;
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  // --- DIAGNOSTIC/WARNING NOTICE FOR SUPABASE SYNC ---
  Widget _buildWarningNotice(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0x17EAB308) : const Color(0xFFFEF9C3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0x3BEAB308) : const Color(0xFFFDE047)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: isDark ? Colors.amberAccent : const Color(0xFF854D0E),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Offline Sync Notice',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.amberAccent : const Color(0xFF854D0E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your local transaction tables (Financials, Inventory) are fully operational. '
                  'The remote database activity vault requires active backend cloud triggers. '
                  'Diagnostics: ${(_fetchError ?? "").replaceAll("Exception: ", "")}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: isDark ? Colors.amber.shade200 : const Color(0xFF713F12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: _fetchLogs,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              backgroundColor: isDark ? Colors.amber.withOpacity(0.1) : Colors.amber.shade200,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'RETRY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.amberAccent : const Color(0xFF854D0E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. EDITS / UPDATE LIST TIMELINE ---
  Widget _buildAuditList() {
    // Apply dynamic search and table filtering
    final filtered = _auditLogs.where((log) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final table = (log['display_table'] ?? '').toString().toLowerCase();
        final attr = (log['attribute_name'] ?? '').toString().toLowerCase();
        final oldV = (log['old_value'] ?? '').toString().toLowerCase();
        final newV = (log['new_value'] ?? '').toString().toLowerCase();
        final recordId = (log['record_id'] ?? '').toString().toLowerCase();

        String user = 'System';
        if (log['users'] != null) {
          final userData = log['users'];
          final fname = userData['firstname'] ?? '';
          final sname = userData['surname'] ?? '';
          user = '$fname $sname'.trim();
          if (user.isEmpty) user = userData['email'] ?? 'Unknown User';
        }
        final userLower = user.toLowerCase();

        final matches = table.contains(query) ||
            attr.contains(query) ||
            oldV.contains(query) ||
            newV.contains(query) ||
            recordId.contains(query) ||
            userLower.contains(query);
        if (!matches) return false;
      }

      if (_selectedTableFilter != null) {
        final table = (log['display_table'] ?? '').toString().toLowerCase();
        if (table != _selectedTableFilter!.toLowerCase()) return false;
      }

      return true;
    }).toList();

    if (filtered.isEmpty) {
      return _buildEmptyState('No updates or modifications logged in vault', Icons.history_rounded);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final log = filtered[index];
        final date = DateTime.parse(log['display_date']).toLocal();

        String user = 'System';
        if (log['users'] != null) {
          final userData = log['users'];
          final fname = userData['firstname'] ?? '';
          final sname = userData['surname'] ?? '';
          user = '$fname $sname'.trim();
          if (user.isEmpty) user = userData['email'] ?? 'Unknown User';
        }

        return _buildTimelineItem(
          index: index,
          totalCount: filtered.length,
          icon: Icons.edit_rounded,
          color: const Color(0xFFF59E0B),
          child: _AuditLogCard(
            title: 'MUTATED: ${log['display_table']?.toString().toUpperCase()}',
            subtitle: 'Action authorized by $user',
            date: DateFormat('MMM dd, yyyy • HH:mm').format(date),
            icon: Icons.edit_rounded,
            iconBgColor: const Color(0xFFF59E0B),
            detailsWidget: _buildDiffView(log),
          ),
        );
      },
    );
  }

  // --- 2. DELETIONS LIST TIMELINE ---
  Widget _buildDeleteList() {
    final filtered = _deleteLogs.where((log) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final table = (log['table_name'] ?? '').toString().toLowerCase();
        final csv = (log['deleted_data_csv'] ?? '').toString().toLowerCase();

        String user = 'System';
        if (log['users'] != null) {
          final userData = log['users'];
          final fname = userData['firstname'] ?? '';
          final sname = userData['surname'] ?? '';
          user = '$fname $sname'.trim();
          if (user.isEmpty) user = userData['email'] ?? 'Unknown User';
        }
        final userLower = user.toLowerCase();

        final matches = table.contains(query) || csv.contains(query) || userLower.contains(query);
        if (!matches) return false;
      }

      if (_selectedTableFilter != null) {
        final table = (log['table_name'] ?? '').toString().toLowerCase();
        if (table != _selectedTableFilter!.toLowerCase()) return false;
      }

      return true;
    }).toList();

    if (filtered.isEmpty) {
      return _buildEmptyState('No deletions recorded in vault', Icons.delete_outline_rounded);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final log = filtered[index];
        final date = DateTime.parse(log['deleted_at']).toLocal();

        String user = 'System';
        if (log['users'] != null) {
          final userData = log['users'];
          final fname = userData['firstname'] ?? '';
          final sname = userData['surname'] ?? '';
          user = '$fname $sname'.trim();
          if (user.isEmpty) user = userData['email'] ?? 'Unknown User';
        }

        return _buildTimelineItem(
          index: index,
          totalCount: filtered.length,
          icon: Icons.delete_forever_rounded,
          color: const Color(0xFFEF4444),
          child: _AuditLogCard(
            title: 'PURGED FROM: ${log['table_name']?.toString().toUpperCase()}',
            subtitle: 'Purged by $user',
            date: DateFormat('MMM dd, yyyy • HH:mm').format(date),
            icon: Icons.delete_forever_rounded,
            iconBgColor: const Color(0xFFEF4444),
            detailsWidget: _buildDeletionCSVDetails(log),
            trailing: FilledButton.icon(
              onPressed: () => _confirmRestore(log),
              icon: const Icon(Icons.restore_rounded, size: 14),
              label: const Text('RESTORE'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- 3. FINANCIALS TIMELINE ---
  Widget _buildFinancialList() {
    final filtered = _financialLogs.where((log) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final title = (log['title'] ?? '').toString().toLowerCase();
        final subtitle = (log['subtitle'] ?? '').toString().toLowerCase();
        final details = (log['details'] ?? '').toString().toLowerCase();
        return title.contains(query) || subtitle.contains(query) || details.contains(query);
      }
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return _buildEmptyState('No financial entries recorded in database', Icons.account_balance_rounded);
    }

    final currency = NumberFormat.currency(symbol: 'GH₵ ', decimalDigits: 2);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final log = filtered[index];
        final date = log['date'] as DateTime;
        final isIncome = log['is_income'] as bool;
        final Color themeColor = log['color'] as Color;

        return _buildTimelineItem(
          index: index,
          totalCount: filtered.length,
          icon: log['icon'] as IconData,
          color: themeColor,
          child: _AuditLogCard(
            title: log['title'],
            subtitle: log['subtitle'],
            date: DateFormat('MMM dd, yyyy • HH:mm').format(date),
            icon: log['icon'] as IconData,
            iconBgColor: themeColor,
            detailsWidget: Text(
              log['details'] ?? '',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isIncome ? const Color(0x1F10B981) : const Color(0x1FEF4444),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isIncome ? const Color(0x3B10B981) : const Color(0x3BEF4444),
                ),
              ),
              child: Text(
                '${isIncome ? "+" : "-"}${currency.format(log['amount'])}',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- 4. INVENTORY TIMELINE ---
  Widget _buildStockList() {
    final filtered = _stockLogs.where((log) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final title = (log['title'] ?? '').toString().toLowerCase();
        final subtitle = (log['subtitle'] ?? '').toString().toLowerCase();
        final details = (log['details'] ?? '').toString().toLowerCase();
        return title.contains(query) || subtitle.contains(query) || details.contains(query);
      }
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return _buildEmptyState('No inventory movements logged in cache', Icons.inventory_2_outlined);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final log = filtered[index];
        final date = log['date'] as DateTime;
        final Color themeColor = log['color'] as Color;

        return _buildTimelineItem(
          index: index,
          totalCount: filtered.length,
          icon: log['icon'] as IconData,
          color: themeColor,
          child: _AuditLogCard(
            title: log['title'],
            subtitle: log['subtitle'],
            date: DateFormat('MMM dd, yyyy • HH:mm').format(date),
            icon: log['icon'] as IconData,
            iconBgColor: themeColor,
            detailsWidget: Text(
              log['details'] ?? '',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  // --- TIMELINE CONNECTING LAYOUT WRAPPER ---
  Widget _buildTimelineItem({
    required int index,
    required int totalCount,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Stack(
      children: [
        // Seamless vertical timeline connector line
        if (index != totalCount - 1)
          Positioned(
            left: 24,
            top: 24,
            bottom: -24,
            child: Container(
              width: 2.5,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.15),
            ),
          ),
        
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline circular node
            Container(
              margin: const EdgeInsets.only(top: 18, left: 10, right: 24),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.12),
                border: Border.all(color: color.withOpacity(0.35), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.05),
                    blurRadius: 6,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Icon(icon, color: color, size: 13),
            ),
            
            // Redesigned responsive card
            Expanded(child: child),
          ],
        ),
      ],
    );
  }

  // --- DIFFERENCES VISUALIZER (EDITS VIEW) ---
  Widget _buildDiffView(Map<String, dynamic> log) {
    final recordId = log['record_id']?.toString() ?? 'N/A';
    final field = log['attribute_name']?.toString() ?? 'FIELD';
    final oldVal = log['old_value']?.toString() ?? 'NULL';
    final newVal = log['new_value']?.toString() ?? 'NULL';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
              ),
              child: Text(
                'Record ID: $recordId',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.25)),
              ),
              child: Text(
                field.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.blue,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Old value red pill representation
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x1AFF4D4D) : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? const Color(0x3BFF4D4D) : const Color(0xFFFCA5A5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BEFORE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.redAccent : const Color(0xFFDC2626),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      oldVal,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.lineThrough,
                        color: isDark ? Colors.redAccent.withOpacity(0.8) : const Color(0xFFB91C1C),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                size: 20,
              ),
            ),
            // New value green pill representation
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x1A10B981) : const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? const Color(0x3B10B981) : const Color(0xFF6EE7B7)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AFTER',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      newVal,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- POSTGRES CSV DELETED RECORD DATA PARSER ---
  Widget _buildDeletionCSVDetails(Map<String, dynamic> log) {
    final csv = log['deleted_data_csv'] as String? ?? '';
    final lines = csv.split('\n');
    if (lines.length < 2) {
      return const SizedBox.shrink();
    }
    
    final keys = lines[0].split('|');
    final values = lines[1].split('|');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<MapEntry<String, String>> properties = [];
    for (int i = 0; i < keys.length; i++) {
      if (i < values.length) {
        final k = keys[i].trim();
        final v = values[i].trim();
        if (k.isNotEmpty && k != 'synced' && k != 'farm_id' && k != 'farmId' && k != 'user_id' && k != 'userId' && v != 'NULL' && v.isNotEmpty) {
          properties.add(MapEntry(k, v));
        }
      }
    }

    if (properties.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          'PURGED DATA DICTIONARY',
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w900,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: properties.map((p) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B).withOpacity(0.4) : const Color(0xFFF1F5F9).withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.04)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${p.key.replaceAll("_", " ")}: ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                    ),
                  ),
                  Text(
                    p.value,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- EMPTY STATE CARD ILLUSTRATION ---
  Widget _buildEmptyState(String message, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        margin: const EdgeInsets.all(40),
        padding: const EdgeInsets.all(40),
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B).withOpacity(0.3) : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              ),
              child: Icon(
                icon,
                size: 48,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search criteria or triggering database transactions locally.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HIGH-QUALITY SKELETON TIMELINE LOADING STATE ---
  Widget _buildSkeletonTimeline() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Stack(
          children: [
            if (index != 3)
              Positioned(
                left: 24,
                top: 24,
                bottom: -24,
                child: Container(
                  width: 2.5,
                  color: (isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0)).withOpacity(0.5),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 18, left: 10, right: 24),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)).withOpacity(0.6),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B).withOpacity(0.3) : Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.04)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 140,
                              height: 16,
                              decoration: BoxDecoration(
                                color: (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)).withOpacity(0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Container(
                              width: 80,
                              height: 12,
                              decoration: BoxDecoration(
                                color: (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)).withOpacity(0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: 220,
                          height: 14,
                          decoration: BoxDecoration(
                                color: (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)).withOpacity(0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                                color: (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // --- RESTORATION VAULT DIALOGS ---
  Future<void> _confirmRestore(Map<String, dynamic> log) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.restore_rounded, color: Color(0xFF10B981)),
            SizedBox(width: 12),
            Text('Restore Deleted Record?'),
          ],
        ),
        content: Text(
          'This operation will inject the purged record back into the ${log['table_name']} '
          'database table with its exact original values.',
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            child: const Text('CONFIRM RESTORE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _performRestore(log);
    }
  }

  Future<void> _performRestore(Map<String, dynamic> log) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _supabase.rpc('restore_deleted_record', params: {
        'p_delete_log_id': log['id'],
      });

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Record restored successfully to system table'),
          backgroundColor: Color(0xFF10B981),
        ));
        _fetchLogs();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Restoration failed: $e'),
          backgroundColor: Colors.redAccent,
        ));
      }
    }
  }
}

// --- PRIVATELY SCORED GLASSMORPHIC CARD W/ DYNAMIC HOVER SHADOWS ---
class _AuditLogCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String date;
  final IconData icon;
  final Color iconBgColor;
  final Widget detailsWidget;
  final Widget? trailing;

  const _AuditLogCard({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    required this.iconBgColor,
    required this.detailsWidget,
    this.trailing,
  });

  @override
  State<_AuditLogCard> createState() => _AuditLogCardState();
}

class _AuditLogCardState extends State<_AuditLogCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.015 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E293B).withOpacity(_isHovered ? 0.65 : 0.45)
                : Colors.white.withOpacity(_isHovered ? 0.95 : 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered
                  ? widget.iconBgColor.withOpacity(0.35)
                  : (isDark ? Colors.white : Colors.black).withOpacity(0.06),
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? widget.iconBgColor.withOpacity(0.08)
                    : Colors.black.withOpacity(0.02),
                blurRadius: _isHovered ? 24 : 12,
                spreadRadius: _isHovered ? 4 : 0,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Header Node
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.iconBgColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: widget.iconBgColor.withOpacity(0.2)),
                  ),
                  child: Icon(widget.icon, color: widget.iconBgColor, size: 22),
                ),
                const SizedBox(width: 20),
                
                // Card contents
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                letterSpacing: 0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.date,
                            style: TextStyle(
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Details Block
                      widget.detailsWidget,
                    ],
                  ),
                ),
                
                if (widget.trailing != null) ...[
                  const SizedBox(width: 16),
                  widget.trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
