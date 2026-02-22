import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    super.avatarUrl,
    super.projectIds,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: _parseRole(json['role'] as String),
      avatarUrl: json['avatar_url'] as String?,
      projectIds: (json['project_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
        'avatar_url': avatarUrl,
        'project_ids': projectIds,
      };

  static UserRole _parseRole(String value) {
    switch (value) {
      case 'site_manager':
        return UserRole.siteManager;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.worker;
    }
  }

  /// Mock data for development — mimics Django REST response
  static UserModel mock(UserRole role) {
    return UserModel(
      id: 'usr_${role.name}_001',
      name: role == UserRole.admin
          ? 'Arjun Mehta'
          : role == UserRole.siteManager
              ? 'Rashid Khan'
              : 'Md. Hasan',
      email: '${role.name}@constructio.app',
      role: role,
      projectIds: ['proj_001', 'proj_002'],
    );
  }
}
