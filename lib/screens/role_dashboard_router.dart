import 'package:flutter/material.dart';

import '../utils/user_role.dart';
import '../widgets/offline_security_setup_gate.dart';
import 'financial_dashboard.dart';
import 'main_scaffold.dart';
import 'operational_dashboard.dart';

class RoleDashboardRouter extends StatelessWidget {
  final String? role;

  const RoleDashboardRouter({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return OfflineSecuritySetupGate(child: getTargetDashboard(role));
  }
}

Widget getTargetDashboard(String? role) {
  switch (UserRoleUtils.normalizeOrNull(role)) {
    case UserRoleUtils.owner:
    case UserRoleUtils.manager:
      return const MainScaffold(role: UserRoleUtils.owner);
    case UserRoleUtils.operational:
      return const OperationalDashboard();
    case UserRoleUtils.financial:
      return const FinancialDashboard();
    default:
      return const Scaffold(
        body: Center(child: Text('Unauthorized Role Configuration')),
      );
  }
}
