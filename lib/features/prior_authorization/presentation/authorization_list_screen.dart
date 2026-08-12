import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';
import '../../../core/providers/authorizations_provider.dart';

final authFilterProvider = StateProvider<String>((ref) => 'all');
final authSearchProvider = StateProvider<String>((ref) => '');

class AuthorizationListScreen extends ConsumerWidget {
  const AuthorizationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all    = ref.watch(authorizationsProvider);
    final filter = ref.watch(authFilterProvider);
    final search = ref.watch(authSearchProvider).toLowerCase();

    final filtered = all.where((a) {
      final matchesFilter = filter == 'all' || a.status.name == filter;
      final matchesSearch = search.isEmpty ||
          a.patientName.toLowerCase().contains(search) ||
          a.authNumber.toLowerCase().contains(search) ||
          a.diagnosisDescription.toLowerCase().contains(search);
      return matchesFilter && matchesSearch;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          LayoutBuilder(builder: (ctx, constraints) {
            final isMobile = constraints.maxWidth < 600;
            if (isMobile) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Prior Authorizations',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('${all.length} total requests across all facilities',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go(RouteNames.createAuthorization),
                      icon: const Icon(PhosphorIconsRegular.plusCircle, size: 18),
                      label: const Text('New Request'),
                    ),
                  ),
                ],
              );
            }
            return Row(
              children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Prior Authorizations',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                    Text('${all.length} total requests across all facilities',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                  ]),
                ),
                ElevatedButton.icon(
                  onPressed: () => context.go(RouteNames.createAuthorization),
                  icon: const Icon(PhosphorIconsRegular.plusCircle, size: 18),
                  label: const Text('New Request'),
                ),
              ],
            );
          }).animate().fadeIn().slideY(begin: -0.1),

          const SizedBox(height: 20),

          // Filters + Search
          LayoutBuilder(builder: (ctx, constraints) {
            final isMobile = constraints.maxWidth < 600;
            if (isMobile) {
              return Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by patient, auth #, diagnosis...',
                      prefixIcon: Icon(PhosphorIconsRegular.magnifyingGlass, size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (v) => ref.read(authSearchProvider.notifier).state = v,
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        'all', 'pending', 'underReview', 'approved', 'rejected', 'escalated',
                      ].map((f) {
                        final isSelected = filter == f;
                        final label = f == 'all' ? 'All' :
                            f == 'underReview' ? 'Under Review' :
                            f[0].toUpperCase() + f.substring(1);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(label),
                            selected: isSelected,
                            onSelected: (_) => ref.read(authFilterProvider.notifier).state = f,
                            backgroundColor: AppColors.neutral100,
                            selectedColor: AppColors.primarySurface,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              fontSize: 13,
                            ),
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.border,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            }
            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by patient, auth #, diagnosis...',
                      prefixIcon: Icon(PhosphorIconsRegular.magnifyingGlass, size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (v) => ref.read(authSearchProvider.notifier).state = v,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        'all', 'pending', 'underReview', 'approved', 'rejected', 'escalated',
                      ].map((f) {
                        final isSelected = filter == f;
                        final label = f == 'all' ? 'All' :
                            f == 'underReview' ? 'Under Review' :
                            f[0].toUpperCase() + f.substring(1);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(label),
                            selected: isSelected,
                            onSelected: (_) => ref.read(authFilterProvider.notifier).state = f,
                            backgroundColor: AppColors.neutral100,
                            selectedColor: AppColors.primarySurface,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              fontSize: 13,
                            ),
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.border,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            );
          }).animate(delay: 100.ms).fadeIn(),

          const SizedBox(height: 16),

          // Table / Cards
          Expanded(
            child: LayoutBuilder(builder: (ctx, tblConstraints) {
              final isMobile = tblConstraints.maxWidth < 600;
              if (isMobile) {
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(PhosphorIconsRegular.clipboardText, size: 48, color: AppColors.neutral300),
                        const SizedBox(height: 12),
                        Text('No authorizations found',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 12),
                  itemBuilder: (c, i) {
                    final auth = filtered[i];
                    return Card(
                      color: AppColors.surface,
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: InkWell(
                        onTap: () => context.go('/authorizations/${auth.id}'),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      auth.patientName,
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                    ),
                                  ),
                                  _StatusBadge(status: auth.status),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Diagnosis: ${auth.diagnosisDescription}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Procedure: ${auth.procedureDescription}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    auth.authNumber,
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textTertiary,
                                        ),
                                  ),
                                  _SlaIndicator(auth: auth),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppTheme.shadowSm,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  child: DataTable2(
                    columnSpacing: 16,
                    horizontalMargin: 20,
                    headingRowHeight: 48,
                    dataRowHeight: 72,
                    headingRowColor: WidgetStateProperty.all(AppColors.neutral50),
                    headingTextStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    columns: const [
                      DataColumn2(label: Text('Patient'), size: ColumnSize.L),
                      DataColumn2(label: Text('Auth #'), size: ColumnSize.M),
                      DataColumn2(label: Text('Diagnosis'), size: ColumnSize.L),
                      DataColumn2(label: Text('Procedure'), size: ColumnSize.L),
                      DataColumn2(label: Text('Status'), size: ColumnSize.S, fixedWidth: 130),
                      DataColumn2(label: Text('SLA'), size: ColumnSize.S, fixedWidth: 80),
                      DataColumn2(label: Text(''), size: ColumnSize.S, fixedWidth: 60),
                    ],
                    rows: filtered.map((auth) {
                      return DataRow2(
                        onTap: () => context.go('/authorizations/${auth.id}'),
                        cells: [
                          DataCell(Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(auth.patientName,
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600)),
                              Text(auth.requestingDoctorName,
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.textTertiary)),
                            ],
                          )),
                          DataCell(Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(auth.authNumber,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontFamily: 'monospace', fontWeight: FontWeight.w600)),
                              if (auth.isUrgent)
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.errorLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('URGENT',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: AppColors.error,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      )),
                                ),
                            ],
                          )),
                          DataCell(Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(auth.diagnosisCode,
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'monospace',
                                  )),
                              Text(auth.diagnosisDescription,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          )),
                          DataCell(Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(auth.procedureCode,
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'monospace',
                                  )),
                              Text(auth.procedureDescription,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          )),
                          DataCell(_StatusBadge(status: auth.status)),
                          DataCell(_SlaIndicator(auth: auth)),
                          DataCell(IconButton(
                            icon: Icon(PhosphorIconsRegular.arrowRight,
                                size: 16, color: AppColors.textTertiary),
                            onPressed: () => context.go('/authorizations/${auth.id}'),
                          )),
                        ],
                      );
                    }).toList(),
                    empty: Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(PhosphorIconsRegular.clipboardText,
                            size: 48, color: AppColors.neutral300),
                        const SizedBox(height: 12),
                        Text('No authorizations found',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.textSecondary)),
                      ]),
                    ),
                  ),
                ),
              );
            }),
          ).animate(delay: 200.ms).fadeIn(),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AuthorizationStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 12, color: status.color),
          const SizedBox(width: 4),
          Text(status.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: status.color,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}

class _SlaIndicator extends StatelessWidget {
  final AuthorizationRequest auth;
  const _SlaIndicator({required this.auth});

  @override
  Widget build(BuildContext context) {
    if (auth.processingTimeMs == null) {
      return Text('—', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary));
    }
    final secs = (auth.processingTimeMs! / 1000).toStringAsFixed(1);
    final color = auth.isWithinSla ? AppColors.success : AppColors.error;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('${secs}s',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color, fontWeight: FontWeight.w700)),
        Icon(auth.isWithinSla ? Icons.check_circle_rounded : Icons.warning_rounded,
            size: 12, color: color),
      ],
    );
  }
}
