import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/user_role.dart';

class AccessControlScreen extends StatelessWidget {
  const AccessControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final roles = UserRole.values;
    final perms = Permission.values.take(10).toList();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Access Control',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ).animate().fadeIn(),
          const SizedBox(height: 4),
          Text(
            'Role-based permission matrix management (Administrator only)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppTheme.shadowSm,
                  ),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(AppColors.neutral50),
                    columns: [
                      const DataColumn(label: Text('Permission', style: TextStyle(fontWeight: FontWeight.w700))),
                      ...roles.map((r) => DataColumn(
                        label: Column(
                          children: [
                            Icon(r.icon, size: 16, color: r.color),
                            const SizedBox(height: 2),
                            Text(
                              r.displayName.split(' ').first,
                              style: TextStyle(color: r.color, fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                          ],
                        ),
                      )),
                    ],
                    rows: perms.map((perm) {
                      final readableName = perm.name
                          .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[0]}')
                          .trim();
                      return DataRow(
                        cells: [
                          DataCell(Text(
                            readableName[0].toUpperCase() + readableName.substring(1),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                          )),
                          ...roles.map((r) => DataCell(
                            rolePermissions[r]!.contains(perm)
                                ? const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18)
                                : const Icon(Icons.cancel_rounded, color: AppColors.neutral300, size: 18),
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ).animate(delay: 200.ms).fadeIn(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
