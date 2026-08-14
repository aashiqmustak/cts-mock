import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../repositories/data_repository.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../models/user_role.dart';
import '../../../models/models.dart';

class DoctorsScreen extends ConsumerStatefulWidget {
  const DoctorsScreen({super.key});

  @override
  ConsumerState<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends ConsumerState<DoctorsScreen> {
  void _showAddDoctorDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final npiCtrl = TextEditingController();
    final specCtrl = TextEditingController();
    final facilityCtrl = TextEditingController(text: 'Metropolitan General Hospital');
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final availCtrl = TextEditingController(text: 'Mon-Fri 09:00 - 17:00');

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(PhosphorIconsRegular.stethoscope, color: AppColors.primary, size: 24),
            const SizedBox(width: 10),
            const Text('Add New Physician', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Full Name', hintText: 'e.g. Dr. John Doe'),
                    validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: npiCtrl,
                    decoration: const InputDecoration(labelText: 'National Provider Identifier (NPI)', hintText: '10-digit NPI'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'NPI is required';
                      if (v.length != 10) return 'NPI must be exactly 10 digits';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: specCtrl,
                    decoration: const InputDecoration(labelText: 'Specialization', hintText: 'e.g. Cardiology'),
                    validator: (v) => v == null || v.isEmpty ? 'Specialization is required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: facilityCtrl,
                    decoration: const InputDecoration(labelText: 'Hospital Facility'),
                    validator: (v) => v == null || v.isEmpty ? 'Facility is required' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: emailCtrl,
                          decoration: const InputDecoration(labelText: 'Email Address'),
                          validator: (v) => v == null || v.isEmpty ? 'Email is required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: phoneCtrl,
                          decoration: const InputDecoration(labelText: 'Phone Number'),
                          validator: (v) => v == null || v.isEmpty ? 'Phone is required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: availCtrl,
                    decoration: const InputDecoration(labelText: 'Weekly Availability Schedule', hintText: 'e.g. Mon, Wed, Fri 09:00 - 17:00'),
                    validator: (v) => v == null || v.isEmpty ? 'Availability is required' : null,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final user = ref.read(currentUserProvider);
                final randomId = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
                
                final newDoc = Doctor(
                  id: 'doc-$randomId',
                  name: nameCtrl.text.trim(),
                  npi: npiCtrl.text.trim(),
                  specialization: specCtrl.text.trim(),
                  facility: facilityCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  totalRequests: 0,
                  approvedRequests: 0,
                  rejectedRequests: 0,
                  approvalRate: 0.0,
                  avgProcessingTimeMs: 0,
                  isActive: true,
                  availability: availCtrl.text.trim(),
                );

                // Add to mock data list
                MockDataRepository.instance.doctors.add(newDoc);

                // Create audit entry
                final prevHash = MockDataRepository.instance.auditLogs.isNotEmpty 
                    ? MockDataRepository.instance.auditLogs.last.entryHash 
                    : 'f9e2d1c6b3a8';
                MockDataRepository.instance.auditLogs.add(
                  AuditLogEntry(
                    id: 'log-$randomId',
                    action: 'doctor.added',
                    actorId: user?.id ?? 'usr-006',
                    actorName: user?.name ?? 'Sarah Jenkins',
                    actorRole: user?.role.displayName ?? 'Hospital Admin',
                    resourceId: newDoc.id,
                    resourceType: 'Doctor',
                    description: 'Added Dr. ${newDoc.name} to hospital roster NPI: ${newDoc.npi}',
                    timestamp: DateTime.now(),
                    entryHash: 'e${randomId}h',
                    previousHash: prevHash,
                    ipAddress: '192.168.1.100',
                    metadata: {'npi': newDoc.npi, 'doctor_id': newDoc.id},
                  ),
                );

                Navigator.pop(ctx);
                setState(() {});
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Physician ${newDoc.name} registered successfully.'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Add Roster'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final doctors = MockDataRepository.instance.doctors;
    
    final canAddDoctor = user?.role == UserRole.adminHospital || 
        user?.role == UserRole.administrator;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Physicians',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                    ).animate().fadeIn(),
                    const SizedBox(height: 4),
                    Text(
                      'Physician profiles and authorization performance metrics',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                    ).animate(delay: 100.ms).fadeIn(),
                  ],
                ),
              ),
              if (canAddDoctor)
                ElevatedButton.icon(
                  onPressed: () => _showAddDoctorDialog(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Physician'),
                ).animate().fadeIn(),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 380,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.25,
              ),
              itemCount: doctors.length,
              itemBuilder: (ctx, i) {
                final d = doctors[i];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppTheme.shadowSm,
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.primarySurface,
                            child: const Text('Dr', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d.name,
                                  style: Theme.of(ctx).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  d.specialization,
                                  style: Theme.of(ctx).textTheme.labelSmall?.copyWith(color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'NPI: ${d.npi}',
                        style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
                          color: AppColors.textTertiary,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        d.facility,
                        style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Availability Tag
                      Row(
                        children: [
                          Icon(PhosphorIconsRegular.clock, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              d.availability ?? 'On Call / Schedule Pending',
                              style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
                                color: d.availability != null ? AppColors.textSecondary : AppColors.textTertiary,
                                fontStyle: d.availability == null ? FontStyle.italic : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${(d.approvalRate * 100).toStringAsFixed(1)}%',
                                style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.success,
                                ),
                              ),
                              Text(
                                'Approval Rate',
                                style: Theme.of(ctx).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${d.totalRequests}',
                                style: Theme.of(ctx).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              Text(
                                'Total Requests',
                                style: Theme.of(ctx).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate(delay: Duration(milliseconds: 50 + i * 40)).fadeIn().scale(begin: const Offset(0.95, 0.95));
              },
            ),
          ),
        ],
      ),
    );
  }
}

