import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/local_db.dart';
import '../data/sync_engine.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/license_service.dart';
import 'lockout_screen.dart';
import 'offline_terminal_login_screen.dart';
import 'overview.dart';
import 'livestock_manager.dart';
import 'comparative_analytics_screen.dart';
import 'egg_production_screen.dart';
import 'inventory_manager.dart';
import 'houses_screen.dart';
import 'sales_screen.dart';
import 'customer_directory_screen.dart';
import 'supplier_directory_screen.dart';
import 'financial_control_screen.dart';
import 'team_management_screen.dart';
import 'settings_screen.dart';
import 'report_log_screen.dart';
import 'climate_screen.dart';
import 'comprehensive_report_screen.dart';
import 'egg_analytics_screen.dart';
import 'feed_analytics_screen.dart';
import 'sales_analytics_screen.dart';
import 'user_profile_screen.dart';
import 'trash_screen.dart';

import 'mortality_screen.dart';
import 'health_screen.dart';
import 'quarantine_screen.dart';
import 'feed_management_screen.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/session_mode_badge.dart';
import '../services/auth_service.dart';
import '../utils/user_role.dart';
import '../utils/worker_permissions_loader.dart';
import '../utils/navigation_permissions.dart';
import '../utils/staff_permission_defaults.dart';

class MainScaffold extends StatefulWidget {
  final String role;

  const MainScaffold({super.key, required this.role});

  @override
  State<MainScaffold> createState() => MainScaffoldState();

  static MainScaffoldState? of(BuildContext context) {
    return context.findAncestorStateOfType<MainScaffoldState>();
  }
}

class MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  bool _isCollapsed = false;
  Timer? _subscriptionCheckTimer;
  late final String _normalizedRole;
  late final List<Widget> _pages;
  List<SidebarMenuSection> _sections = const [];

  @override
  void initState() {
    super.initState();
    _normalizedRole = UserRoleUtils.normalize(widget.role);
    final config = _buildRoleConfig(_normalizedRole);
    _pages = config.pages;
    _sections = config.sections;
    _loadPermissionsAndFilterSections(config.sections);
    _subscriptionCheckTimer = Timer.periodic(
      const Duration(hours: 6),
      (_) => _checkSubscriptionInBackground(),
    );
  }

  Future<void> _checkSubscriptionInBackground() async {
    try {
      final db = context.read<AppDatabase>();
      final svc = LicenseService(db);
      final config = await svc.getConfig();
      if (config?.hardwareId == null) return;

      await svc.renewFromCloud(config!.hardwareId!);
      final status = await svc.checkLicense();

      if (!mounted) return;

      if (status == LicenseStatus.hardLocked) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) =>
                const LockoutScreen(reason: LockoutReason.trialExpired),
          ),
          (_) => false,
        );
      } else if (status == LicenseStatus.softLocked) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Subscription expiring soon. Upgrade to keep access.',
            ),
            backgroundColor: const Color(0xFFEF4444),
            action: SnackBarAction(
              label: 'Upgrade',
              textColor: Colors.white,
              onPressed: () async {
                final url = dotenv.env['WEB_APP_URL'] ?? '';
                if (url.isNotEmpty) {
                  await launchUrl(Uri.parse('$url/dashboard/license-upgrade'));
                }
              },
            ),
            duration: const Duration(seconds: 10),
          ),
        );
      }
    } catch (e) {
      debugPrint('[Background] Subscription check failed: $e');
    }
  }

  Future<void> _loadPermissionsAndFilterSections(
    List<SidebarMenuSection> baseSections,
  ) async {
    try {
      final db = context.read<AppDatabase>();
      final permissions = await loadWorkerPermissions(db);
      if (!mounted) return;
      setState(() {
        _sections = _filterSections(baseSections, permissions);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sections = baseSections;
      });
    }
  }

  List<SidebarMenuSection> _filterSections(
    List<SidebarMenuSection> sections,
    Set<String> permissions,
  ) {
    return sections
        .map((section) {
          final items = section.items.where((item) {
            if (item.label == 'Data Recovery') {
              return _normalizedRole == UserRoleUtils.owner ||
                  _normalizedRole == UserRoleUtils.manager;
            }
            if (item.label != 'Reports & Logs') {
              return true;
            }
            return canShowNavigationItem(
              name: 'Reports & Logs',
              role: _normalizedRole == UserRoleUtils.owner
                  ? 'OWNER'
                  : widget.role,
              roles: assignableStaffRoles,
              permissions: permissions,
            );
          }).toList();
          if (items.isEmpty) return null;
          return SidebarMenuSection(title: section.title, items: items);
        })
        .whereType<SidebarMenuSection>()
        .toList();
  }

  @override
  void dispose() {
    _subscriptionCheckTimer?.cancel();
    super.dispose();
  }

  void setSelectedIndex(int index) {
    if (index < 0 || index >= _pages.length) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Sign out of Supabase (Online)
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      debugPrint("Supabase signout warning: $e");
    }

    // 2. Clear user session (Local) — keep device binding (is_bound, bound_farm_id)
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_role');
    await UserSession().clearSession();

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OfflineTerminalLoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final syncEngine = Provider.of<SyncEngine>(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Breakpoints for Desktop Responsiveness
          final bool isNarrow = constraints.maxWidth < 1000;

          // Auto-collapse sidebar on narrow screens
          final bool effectiveCollapsed = _isCollapsed || isNarrow;

          return Row(
            children: [
              // Navigation Sidebar
              AppSidebar(
                selectedIndex: _selectedIndex,
                isCollapsed: effectiveCollapsed,
                onToggleCollapse: () =>
                    setState(() => _isCollapsed = !_isCollapsed),
                onDestinationSelected: setSelectedIndex,
                onLogout: () => _logout(context),
                sections: _sections,
                sessionMode: SessionModeBadge(compact: effectiveCollapsed),
                syncStatus: StreamBuilder<bool>(
                  stream: syncEngine.syncStatus,
                  initialData: syncEngine.isSyncing,
                  builder: (context, snapshot) {
                    final isSyncing = snapshot.data ?? false;
                    return Tooltip(
                      message: isSyncing
                          ? 'Synchronizing data...'
                          : 'Click to sync now',
                      child: InkWell(
                        onTap: isSyncing ? null : () => syncEngine.syncNow(),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSyncing)
                                const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white70,
                                    ),
                                  ),
                                )
                              else
                                const Icon(
                                  Icons.cloud_done_rounded,
                                  color: Color(0xFF22C55E),
                                  size: 16,
                                ),
                              if (!effectiveCollapsed) ...[
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    isSyncing ? 'SYNCING...' : 'CLOUD SYNCED',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                      color: isSyncing
                                          ? Colors.white70
                                          : const Color(0xFF22C55E),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const VerticalDivider(
                thickness: 1,
                width: 1,
                color: Colors.black12,
              ),
              // Main Content
              Expanded(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: _selectedIndex < _pages.length
                      ? _pages[_selectedIndex]
                      : _pages.first,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RoleDashboardConfig {
  final List<Widget> pages;
  final List<SidebarMenuSection> sections;

  const _RoleDashboardConfig({required this.pages, required this.sections});
}

_RoleDashboardConfig _buildRoleConfig(String role) {
  if (role == UserRoleUtils.operational) {
    return _RoleDashboardConfig(
      pages: const [
        OverviewPage(),
        EggProductionScreen(),
        FeedManagementScreen(),
        MortalityScreen(),
        ReportLogScreen(),
        UserProfileScreen(),
      ],
      sections: const [
        SidebarMenuSection(
          title: 'OPERATIONS',
          items: [
            SidebarMenuItem(
              index: 0,
              icon: Icons.grid_view_rounded,
              label: 'Dashboard',
            ),
            SidebarMenuItem(
              index: 1,
              icon: Icons.egg_rounded,
              label: 'Egg Collection',
            ),
            SidebarMenuItem(
              index: 2,
              icon: Icons.restaurant_rounded,
              label: 'Feed Consumption',
            ),
            SidebarMenuItem(
              index: 3,
              icon: Icons.dangerous_outlined,
              label: 'Mortality',
            ),
          ],
        ),
        SidebarMenuSection(
          title: 'SUPPORT',
          items: [
            SidebarMenuItem(
              index: 4,
              icon: Icons.library_books_rounded,
              label: 'Operation Logs',
            ),
            SidebarMenuItem(
              index: 5,
              icon: Icons.account_circle_rounded,
              label: 'Profile',
            ),
          ],
        ),
      ],
    );
  }

  return _RoleDashboardConfig(
    pages: const [
      OverviewPage(),
      LivestockManager(),
      ComparativeAnalyticsScreen(),
      HousesScreen(),
      EggProductionScreen(),
      FeedManagementScreen(),
      MortalityScreen(),
      HealthScreen(),
      ClimateScreen(),
      QuarantineScreen(),
      SalesScreen(),
      CustomerDirectoryScreen(),
      SupplierDirectoryScreen(),
      FinancialControlScreen(),
      InventoryManager(),
      TeamManagementScreen(),
      SettingsScreen(),
      ComprehensiveReportScreen(),
      EggAnalyticsScreen(),
      FeedAnalyticsScreen(),
      SalesAnalyticsScreen(),
      UserProfileScreen(),
      TrashScreen(),
    ],
    sections: const [
      SidebarMenuSection(
        title: 'OPERATIONS',
        items: [
          SidebarMenuItem(
            index: 0,
            icon: Icons.grid_view_rounded,
            label: 'Dashboard',
          ),
          SidebarMenuItem(
            index: 1,
            icon: Icons.pets_rounded,
            label: 'Livestock',
          ),
          SidebarMenuItem(
            index: 2,
            icon: Icons.analytics_rounded,
            label: 'Comparative Analytics',
          ),
          SidebarMenuItem(
            index: 3,
            icon: Icons.home_work_rounded,
            label: 'Houses',
          ),
          SidebarMenuItem(index: 4, icon: Icons.egg_rounded, label: 'Eggs'),
          SidebarMenuItem(
            index: 5,
            icon: Icons.restaurant_rounded,
            label: 'Feeding',
          ),
          SidebarMenuItem(
            index: 6,
            icon: Icons.dangerous_outlined,
            label: 'Mortality',
          ),
          SidebarMenuItem(
            index: 7,
            icon: Icons.health_and_safety_rounded,
            label: 'Health',
          ),
          SidebarMenuItem(
            index: 8,
            icon: Icons.thermostat_rounded,
            label: 'Climate',
          ),
          SidebarMenuItem(
            index: 9,
            icon: Icons.health_and_safety_outlined,
            label: 'Quarantine',
          ),
        ],
      ),
      SidebarMenuSection(
        title: 'COMMERCIAL HUB',
        items: [
          SidebarMenuItem(
            index: 10,
            icon: Icons.receipt_long_rounded,
            label: 'Sales',
          ),
          SidebarMenuItem(
            index: 11,
            icon: Icons.people_alt_rounded,
            label: 'Customers',
          ),
          SidebarMenuItem(
            index: 12,
            icon: Icons.local_shipping_rounded,
            label: 'Suppliers',
          ),
          SidebarMenuItem(
            index: 13,
            icon: Icons.account_balance_wallet_rounded,
            label: 'Finance',
          ),
          SidebarMenuItem(
            index: 14,
            icon: Icons.inventory_2_rounded,
            label: 'Inventory',
          ),
        ],
      ),
      SidebarMenuSection(
        title: 'GOVERNANCE',
        items: [
          SidebarMenuItem(index: 15, icon: Icons.group_rounded, label: 'Team'),
          SidebarMenuItem(
            index: 16,
            icon: Icons.settings_rounded,
            label: 'Settings',
          ),
          SidebarMenuItem(
            index: 17,
            icon: Icons.library_books_rounded,
            label: 'Reports & Logs',
          ),
          SidebarMenuItem(
            index: 21,
            icon: Icons.account_circle_rounded,
            label: 'Profile',
          ),
          SidebarMenuItem(
            index: 22,
            icon: Icons.restore_from_trash_rounded,
            label: 'Data Recovery',
          ),
        ],
      ),
    ],
  );
}
