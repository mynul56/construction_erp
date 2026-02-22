import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_entity.dart';

/// Animated segmented role selector with sliding indicator.
class RoleSelector extends StatefulWidget {
  const RoleSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final UserRole selected;
  final ValueChanged<UserRole> onChanged;

  @override
  State<RoleSelector> createState() => _RoleSelectorState();
}

class _RoleSelectorState extends State<RoleSelector> {
  static const _roles = [
    (UserRole.worker, Icons.engineering_rounded, 'Worker'),
    (UserRole.siteManager, Icons.supervisor_account_rounded, 'Manager'),
    (UserRole.admin, Icons.admin_panel_settings_rounded, 'Admin'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Role',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white.withAlpha(153),
                letterSpacing: 1,
              ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(13),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withAlpha(25)),
          ),
          child: Row(
            children: _roles.map((entry) {
              final (role, icon, label) = entry;
              final isSelected = widget.selected == role;
              return Expanded(
                child: GestureDetector(
                  onTap: () => widget.onChanged(role),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.cyan.withAlpha(230)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.cyan.withAlpha(77),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 16,
                          color: isSelected
                              ? AppColors.navyDeep
                              : Colors.white.withAlpha(128),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w400,
                            color: isSelected
                                ? AppColors.navyDeep
                                : Colors.white.withAlpha(128),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
