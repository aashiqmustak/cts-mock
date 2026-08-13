import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../repositories/data_repository.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../models/user_role.dart';
import '../../../models/models.dart';

class PatientsScreen extends ConsumerStatefulWidget {
  const PatientsScreen({super.key});

  @override
  ConsumerState<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends ConsumerState<PatientsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showRegisterPatientDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final dobCtrl = TextEditingController();
    final insuranceIdCtrl = TextEditingController();
    final insurancePlanCtrl = TextEditingController();
    
    String gender = 'Female';
    String payer = 'BlueCross BlueShield';
    
    final doctors = MockDataRepository.instance.doctors;
    String primaryPhysician = doctors.first.name;

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(PhosphorIconsRegular.userPlus, color: AppColors.primary, size: 24),
            const SizedBox(width: 10),
            const Text('Register New Patient', style: TextStyle(fontWeight: FontWeight.w700)),
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
                    decoration: const InputDecoration(labelText: 'Full Name', hintText: 'e.g. John Doe'),
                    validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: dobCtrl,
                          decoration: const InputDecoration(labelText: 'Date of Birth', hintText: 'YYYY-MM-DD'),
                          validator: (v) => v == null || v.isEmpty ? 'DOB is required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: gender,
                          decoration: const InputDecoration(labelText: 'Gender'),
                          items: const [
                            DropdownMenuItem(value: 'Male', child: Text('Male')),
                            DropdownMenuItem(value: 'Female', child: Text('Female')),
                            DropdownMenuItem(value: 'Other', child: Text('Other')),
                          ],
                          onChanged: (val) {
                            if (val != null) gender = val;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: payer,
                          decoration: const InputDecoration(labelText: 'Payer'),
                          items: const [
                            DropdownMenuItem(value: 'BlueCross BlueShield', child: Text('BlueCross BlueShield')),
                            DropdownMenuItem(value: 'Aetna', child: Text('Aetna')),
                            DropdownMenuItem(value: 'UnitedHealthcare', child: Text('UnitedHealthcare')),
                            DropdownMenuItem(value: 'Cigna', child: Text('Cigna')),
                            DropdownMenuItem(value: 'Humana', child: Text('Humana')),
                          ],
                          onChanged: (val) {
                            if (val != null) payer = val;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: insuranceIdCtrl,
                          decoration: const InputDecoration(labelText: 'Insurance ID'),
                          validator: (v) => v == null || v.isEmpty ? 'Insurance ID is required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: insurancePlanCtrl,
                    decoration: const InputDecoration(labelText: 'Insurance Plan Name', hintText: 'e.g. Choice PPO Premium'),
                    validator: (v) => v == null || v.isEmpty ? 'Plan Name is required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: primaryPhysician,
                    decoration: const InputDecoration(labelText: 'Primary Care Physician'),
                    items: doctors.map((d) => DropdownMenuItem(value: d.name, child: Text(d.name))).toList(),
                    onChanged: (val) {
                      if (val != null) primaryPhysician = val;
                    },
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
                final newPatient = Patient(
                  id: 'pat-$randomId',
                  name: nameCtrl.text.trim(),
                  dateOfBirth: dobCtrl.text.trim(),
                  gender: gender,
                  insuranceId: insuranceIdCtrl.text.trim(),
                  insurancePlan: insurancePlanCtrl.text.trim(),
                  payer: payer,
                  primaryDiagnosis: 'Pending Clinical Evaluation',
                  primaryPhysicianName: primaryPhysician,
                  contactPhone: '(555) 019-9283',
                  facilityId: 'fac-001',
                  mrn: 'MRN-00$randomId',
                  totalAuthorizations: 0,
                  approvedAuthorizations: 0,
                  pendingAuthorizations: 0,
                );

                // Add to mock data
                MockDataRepository.instance.patients.add(newPatient);

                // Create audit entry
                final prevHash = MockDataRepository.instance.auditLogs.isNotEmpty 
                    ? MockDataRepository.instance.auditLogs.last.entryHash 
                    : 'f9e2d1c6b3a8';
                MockDataRepository.instance.auditLogs.add(
                  AuditLogEntry(
                    id: 'log-$randomId',
                    action: 'patient.registered',
                    actorId: user?.id ?? 'usr-006',
                    actorName: user?.name ?? 'Sarah Jenkins',
                    actorRole: user?.role.displayName ?? 'Hospital Admin',
                    resourceId: newPatient.id,
                    resourceType: 'Patient',
                    description: 'Registered patient ${newPatient.name} with ${newPatient.mrn}',
                    timestamp: DateTime.now(),
                    entryHash: 'e${randomId}h',
                    previousHash: prevHash,
                    ipAddress: '192.168.1.100',
                    metadata: {'mrn': newPatient.mrn, 'patient_id': newPatient.id},
                  ),
                );

                Navigator.pop(ctx);
                setState(() {});
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Registered patient ${newPatient.name} successfully.'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final allPatients = MockDataRepository.instance.patients;

    final patients = allPatients.where((p) {
      if (_searchQuery.isEmpty) return true;
      return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.insurancePlan.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p.mrn != null && p.mrn!.toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();

    final canRegister = user?.role == UserRole.adminHospital || 
        user?.role == UserRole.administrator || 
        user?.role == UserRole.hospitalStaff;

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
                      'Patients',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                    ).animate().fadeIn(),
                    const SizedBox(height: 4),
                    Text(
                      'Manage patient records and authorization history',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                    ).animate(delay: 100.ms).fadeIn(),
                  ],
                ),
              ),
              if (canRegister)
                ElevatedButton.icon(
                  onPressed: () => _showRegisterPatientDialog(context),
                  icon: const Icon(Icons.person_add_rounded, size: 18),
                  label: const Text('Register Patient'),
                ).animate().fadeIn(),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchCtrl,
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search patients by name or MRN...',
              prefixIcon: Icon(PhosphorIconsRegular.magnifyingGlass, size: 18),
            ),
          ).animate(delay: 150.ms).fadeIn(),
          const SizedBox(height: 16),
          Expanded(
            child: patients.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(PhosphorIconsRegular.users, size: 48, color: AppColors.textTertiary),
                        const SizedBox(height: 12),
                        Text('No patients found',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : ListView.separated(
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

