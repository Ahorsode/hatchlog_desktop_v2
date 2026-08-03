enum UserRole { owner, manager, operational, financial }

class UserRoleUtils {
  static const owner = 'OWNER';
  static const manager = 'MANAGER';
  static const operational = 'OPERATIONAL';
  static const financial = 'FINANCIAL';

  static const supportedRoles = <String>{
    owner,
    manager,
    operational,
    financial,
  };

  static String normalize(String? role) {
    final cleaned = (role ?? '').trim().toUpperCase();
    if (cleaned == 'ACCOUNTANT' || cleaned == 'ACCOUNTEN') return financial;
    if (cleaned == 'WORKER' || cleaned == 'VETERINARIAN') return operational;
    if (supportedRoles.contains(cleaned)) return cleaned;
    return operational;
  }

  static String? normalizeOrNull(String? role) {
    final cleaned = (role ?? '').trim().toUpperCase();
    if (cleaned == 'ACCOUNTANT' || cleaned == 'ACCOUNTEN') return financial;
    if (cleaned == 'WORKER' || cleaned == 'VETERINARIAN') return operational;
    if (supportedRoles.contains(cleaned)) return cleaned;
    return null;
  }

  static UserRole parse(String? role) {
    switch (normalize(role)) {
      case owner:
        return UserRole.owner;
      case manager:
        return UserRole.manager;
      case financial:
        return UserRole.financial;
      case operational:
      default:
        return UserRole.operational;
    }
  }

  static bool canViewFinancials(String? role) {
    final normalized = normalize(role);
    return normalized == owner ||
        normalized == manager ||
        normalized == financial;
  }
}
