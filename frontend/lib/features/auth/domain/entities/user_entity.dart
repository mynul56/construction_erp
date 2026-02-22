enum UserRole { worker, siteManager, admin }

class UserEntity {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.projectIds = const [],
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? avatarUrl;
  final List<String> projectIds;

  String get roleLabel {
    switch (role) {
      case UserRole.worker:
        return 'Worker';
      case UserRole.siteManager:
        return 'Site Manager';
      case UserRole.admin:
        return 'Admin';
    }
  }
}
