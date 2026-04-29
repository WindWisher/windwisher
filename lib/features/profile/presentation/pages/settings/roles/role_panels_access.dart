class RolePanelsAccess {
  const RolePanelsAccess({
    required this.roles,
    required this.hasModeratorPanel,
    required this.hasManagerPanel,
    required this.hasAdminPanel,
    required this.hasSuperAdminPanel,
    required this.hasVipPanel,
  });

  final Set<String> roles;
  final bool hasModeratorPanel;
  final bool hasManagerPanel;
  final bool hasAdminPanel;
  final bool hasSuperAdminPanel;
  final bool hasVipPanel;

  bool get hasAnyPanel =>
      hasModeratorPanel ||
      hasManagerPanel ||
      hasAdminPanel ||
      hasSuperAdminPanel;

  static RolePanelsAccess fromRoles(Set<String> roles) {
    final hasSuperAdminPanel = roles.contains('super_admin');
    final hasAdminPanel = roles.contains('admin') || hasSuperAdminPanel;
    return RolePanelsAccess(
      roles: roles,
      hasModeratorPanel:
          roles.contains('moderator') || hasAdminPanel || hasSuperAdminPanel,
      hasManagerPanel: roles.contains('manager') || hasSuperAdminPanel,
      hasAdminPanel: hasAdminPanel,
      hasSuperAdminPanel: roles.contains('super_admin'),
      hasVipPanel: false,
    );
  }
}
