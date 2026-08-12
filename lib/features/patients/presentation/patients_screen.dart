import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../repositories/mock/mock_data_repository.dart';

class PatientsScreen extends StatelessWidget {
  const PatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patients = MockDataRepository.instance.patients;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patients',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ).animate().fadeIn(),
          const SizedBox(height: 4),
          Text(
            'Manage patient records and authorization history',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search patients...',
              prefixIcon: Icon(PhosphorIconsRegular.magnifyingGlass, size: 18),
            ),
          ).animate(delay: 150.ms).fadeIn(),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: patients.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final p = patients[i];
                return InkWell(
                  onTap: () => context.go('/patients/${p.id}'),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppTheme.shadowSm,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primarySurface,
                        child: Text(
                          p.name.split(' ').map((w) => w[0]).take(2).join(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: Theme.of(ctx).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'MRN: ${p.mrn ?? "—"} · DOB: ${p.dateOfBirth} · ${p.gender}',
                              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                            ),
                            Text(
                              p.insurancePlan,
                              style: Theme.of(ctx).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${p.totalAuthorizations} auths',
                            style: Theme.of(ctx).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.successLight,
                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                            ),
                            child: Text(
                              '${p.approvedAuthorizations} approved',
                              style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      ],
                    ),
                  ),
                ).animate(delay: Duration(milliseconds: 50 + i * 40)).fadeIn().slideY(begin: 0.05);
              },
            ),
          ),
        ],
      ),
    );
  }
}
