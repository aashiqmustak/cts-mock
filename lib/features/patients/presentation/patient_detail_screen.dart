import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';
import '../../../models/user_role.dart';
import '../../../repositories/mock/mock_data_repository.dart';
import '../../../core/utils/patient_portal_helper.dart';
import '../../../core/providers/auth_provider.dart';

class PatientDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const PatientDetailScreen({super.key, required this.id});

  @override
  ConsumerState<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends ConsumerState<PatientDetailScreen> {
  bool _isVerifying = false;
  bool _coverageVerified = false;
  String? _verificationTime;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final patients = MockDataRepository.instance.patients;
    
    // Find the patient by ID, if not found fallback to first or create a dummy
    final patient = patients.firstWhere(
      (p) => p.id == widget.id, 
      orElse: () => patients.first,
    );
    
    final allAuths = MockDataRepository.instance.authorizations;
    final patientAuths = allAuths.where((a) => a.patientId == patient.id).toList();

    // Get appointments and surgeries for this patient
    final patientAppointments = MockDataRepository.instance.appointments
        .where((a) => a.patientId == patient.id)
        .toList();
    final patientSurgeries = MockDataRepository.instance.surgeries
        .where((s) => s.patientId == patient.id)
        .toList();

    final canManage = user?.role == UserRole.adminHospital || 
        user?.role == UserRole.administrator || 
        user?.role == UserRole.hospitalStaff;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs
            Row(
              children: [
                TextButton(
                  onPressed: () => context.go(RouteNames.patients),
                  child: const Text('Patients'),
                ),
                const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textTertiary),
                Text(
                  patient.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ).animate().fadeIn(),

            const SizedBox(height: 16),

            // Patient Header Card
            _PatientHeader(patient: patient).animate(delay: 50.ms).fadeIn().slideY(begin: -0.05),

            const SizedBox(height: 20),

            // Responsive Layout
            LayoutBuilder(builder: (ctx, constraints) {
              final isWide = constraints.maxWidth > 900;
              
              final leftColumn = Column(
                children: [
                  _ClinicalSummaryCard(patient: patient),
                  const SizedBox(height: 16),
                  _buildSchedulingCard(patient, patientAppointments, patientSurgeries, canManage),
                  const SizedBox(height: 16),
                  _AuthorizationHistoryCard(auths: patientAuths),
                ],
              );

              final rightColumn = Column(
                children: [
                  _buildInsuranceCard(patient),
                  const SizedBox(height: 16),
                  _buildGuardianCard(patient, canManage),
                  const SizedBox(height: 16),
                  _QuickActionsCard(patient: patient),
                ],
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: leftColumn),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: rightColumn),
                  ],
                );
              }
              return Column(
                children: [
                  leftColumn,
                  const SizedBox(height: 16),
                  rightColumn,
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // ─── Insurance Verification Widget ──────────────────────────────────────────
  Widget _buildInsuranceCard(Patient patient) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsRegular.shieldCheck, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Insurance & Demographics',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const Divider(height: 24),
          _DetailField(label: 'Payer', value: patient.payer),
          _DetailField(label: 'Plan Name', value: patient.insurancePlan),
          _DetailField(label: 'Member/Insurance ID', value: patient.insuranceId, isCode: true),
          _DetailField(label: 'Phone Number', value: patient.contactPhone),
          _DetailField(label: 'Email Address', value: patient.contactEmail ?? '—'),
          _DetailField(label: 'Primary Care Physician', value: patient.primaryPhysicianName ?? '—'),
          
          const Divider(height: 20),
          
          // Eligibility Verification Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Eligibility Status',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  if (_isVerifying)
                    Row(
                      children: [
                        const SizedBox(
                          width: 12, height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Verifying...',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    )
                  else if (_coverageVerified)
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Active · Verified',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.successDark, fontWeight: FontWeight.w700),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Icon(PhosphorIconsRegular.warning, color: AppColors.warning, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Unverified',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.warningDark, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _isVerifying ? null : () => _verifyInsurance(patient),
                icon: const Icon(Icons.sync_rounded, size: 14),
                label: const Text('Verify Coverage', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  backgroundColor: _coverageVerified ? AppColors.success : AppColors.primary,
                ),
              ),
            ],
          ),
          if (_coverageVerified && _verificationTime != null) ...[
            const SizedBox(height: 8),
            Text(
              'Last verified: $_verificationTime via HL7 FHIR Gateway',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  void _verifyInsurance(Patient patient) {
    setState(() {
      _isVerifying = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      final user = ref.read(currentUserProvider);
      final randomId = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
      final prevHash = MockDataRepository.instance.auditLogs.isNotEmpty 
          ? MockDataRepository.instance.auditLogs.last.entryHash 
          : 'f9e2d1c6b3a8';

      // Log verification audit trail
      MockDataRepository.instance.auditLogs.add(
        AuditLogEntry(
          id: 'log-$randomId',
          action: 'insurance.verified',
          actorId: user?.id ?? 'usr-006',
          actorName: user?.name ?? 'Sarah Jenkins',
          actorRole: user?.role.displayName ?? 'Hospital Admin',
          resourceId: patient.id,
          resourceType: 'Patient',
          description: 'Insurance verified for patient ${patient.name} (${patient.payer} - Active)',
          timestamp: DateTime.now(),
          entryHash: 'e${randomId}h',
          previousHash: prevHash,
          ipAddress: '192.168.1.100',
          metadata: {'patient_id': patient.id, 'status': 'Active', 'plan': patient.insurancePlan},
        ),
      );

      setState(() {
        _isVerifying = false;
        _coverageVerified = true;
        _verificationTime = DateFormat('hh:mm a').format(DateTime.now());
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insurance status verified successfully with ${patient.payer}.'),
          backgroundColor: AppColors.success,
        ),
      );
    });
  }

  // ─── Guardian Card Widget ───────────────────────────────────────────────────
  Widget _buildGuardianCard(Patient patient, bool canEdit) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(PhosphorIconsRegular.usersThree, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Guardian / Next of Kin',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              if (canEdit)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                  onPressed: () => _showEditGuardianDialog(patient),
                  tooltip: 'Edit Guardian Details',
                ),
            ],
          ),
          const Divider(height: 20),
          _DetailField(label: 'Name', value: patient.guardianName ?? '—'),
          _DetailField(label: 'Relationship', value: patient.guardianRelationship ?? '—'),
          _DetailField(label: 'Contact Phone', value: patient.guardianPhone ?? '—'),
        ],
      ),
    );
  }

  void _showEditGuardianDialog(Patient patient) {
    final nameCtrl = TextEditingController(text: patient.guardianName);
    final relationCtrl = TextEditingController(text: patient.guardianRelationship);
    final phoneCtrl = TextEditingController(text: patient.guardianPhone);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(PhosphorIconsRegular.userCircle, color: AppColors.primary, size: 24),
            const SizedBox(width: 10),
            const Text('Edit Next of Kin', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Guardian Name'),
                  validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: relationCtrl,
                  decoration: const InputDecoration(labelText: 'Relationship (e.g. Spouse, Parent)'),
                  validator: (v) => v == null || v.isEmpty ? 'Relationship is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Contact Phone Number'),
                  validator: (v) => v == null || v.isEmpty ? 'Phone is required' : null,
                ),
              ],
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
                
                // Find patient in list and overwrite next-of-kin details
                final idx = MockDataRepository.instance.patients.indexWhere((p) => p.id == patient.id);
                if (idx != -1) {
                  final p = MockDataRepository.instance.patients[idx];
                  MockDataRepository.instance.patients[idx] = Patient(
                    id: p.id,
                    name: p.name,
                    dateOfBirth: p.dateOfBirth,
                    gender: p.gender,
                    insuranceId: p.insuranceId,
                    insurancePlan: p.insurancePlan,
                    payer: p.payer,
                    primaryDiagnosis: p.primaryDiagnosis,
                    chronicConditions: p.chronicConditions,
                    primaryPhysicianId: p.primaryPhysicianId,
                    primaryPhysicianName: p.primaryPhysicianName,
                    contactPhone: p.contactPhone,
                    contactEmail: p.contactEmail,
                    facilityId: p.facilityId,
                    totalAuthorizations: p.totalAuthorizations,
                    approvedAuthorizations: p.approvedAuthorizations,
                    pendingAuthorizations: p.pendingAuthorizations,
                    mrn: p.mrn,
                    guardianName: nameCtrl.text.trim(),
                    guardianPhone: phoneCtrl.text.trim(),
                    guardianRelationship: relationCtrl.text.trim(),
                  );
                }

                // Log audit trail
                final prevHash = MockDataRepository.instance.auditLogs.isNotEmpty 
                    ? MockDataRepository.instance.auditLogs.last.entryHash 
                    : 'f9e2d1c6b3a8';
                MockDataRepository.instance.auditLogs.add(
                  AuditLogEntry(
                    id: 'log-$randomId',
                    action: 'guardian.updated',
                    actorId: user?.id ?? 'usr-006',
                    actorName: user?.name ?? 'Sarah Jenkins',
                    actorRole: user?.role.displayName ?? 'Hospital Admin',
                    resourceId: patient.id,
                    resourceType: 'Patient',
                    description: 'Guardian details updated for ${patient.name} (Relative: ${nameCtrl.text.trim()})',
                    timestamp: DateTime.now(),
                    entryHash: 'e${randomId}h',
                    previousHash: prevHash,
                    ipAddress: '192.168.1.100',
                    metadata: {'patient_id': patient.id, 'guardian_name': nameCtrl.text.trim(), 'relation': relationCtrl.text.trim()},
                  ),
                );

                Navigator.pop(ctx);
                setState(() {});
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Guardian contact details updated.'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ─── Scheduling Center Widget ───────────────────────────────────────────────
  Widget _buildSchedulingCard(
      Patient patient, 
      List<PatientAppointment> appts, 
      List<PatientSurgery> surgs, 
      bool canSchedule) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(PhosphorIconsRegular.calendar, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Facility Scheduling Center',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              if (canSchedule)
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _showScheduleAppointmentDialog(patient),
                      icon: const Icon(Icons.add_rounded, size: 14),
                      label: const Text('Appointment', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 4),
                    TextButton.icon(
                      onPressed: () => _showScheduleSurgeryDialog(patient),
                      icon: const Icon(Icons.medical_services_rounded, size: 14),
                      label: const Text('Surgery', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(foregroundColor: AppColors.escalated),
                    ),
                  ],
                ),
            ],
          ),
          const Divider(height: 20),
          
          if (appts.isEmpty && surgs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No upcoming appointments or surgeries scheduled.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
                ),
              ),
            )
          else ...[
            if (appts.isNotEmpty) ...[
              Text(
                'Upcoming Clinic Appointments',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...appts.map((apt) => Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    color: AppColors.primarySurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: Icon(PhosphorIconsRegular.calendar, color: AppColors.primary),
                      title: Text(apt.reason, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('Physician: ${apt.doctorName}'),
                      trailing: Text(
                        DateFormat('MMM d, h:mm a').format(apt.dateTime),
                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                    ),
                  )),
              const SizedBox(height: 12),
            ],
            if (surgs.isNotEmpty) ...[
              Text(
                'Scheduled Surgeries',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.escalated, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...surgs.map((surg) => Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    color: AppColors.escalatedLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      side: BorderSide(color: AppColors.escalated.withOpacity(0.2)),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: Icon(PhosphorIconsRegular.scissors, color: AppColors.escalated),
                      title: Text(surg.procedure, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('Surgeon: ${surg.surgeonName} · ${surg.operationTheatre}'),
                      trailing: Text(
                        DateFormat('MMM d, h:mm a').format(surg.dateTime),
                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                    ),
                  )),
            ],
          ],
        ],
      ),
    );
  }

  void _showScheduleAppointmentDialog(Patient patient) {
    final doctors = MockDataRepository.instance.doctors;
    String selectedDoc = doctors.first.name;
    final reasonCtrl = TextEditingController();
    
    DateTime selectedDate = DateTime.now().add(const Duration(days: 3));
    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(PhosphorIconsRegular.calendarPlus, color: AppColors.primary, size: 24),
            const SizedBox(width: 10),
            const Text('Schedule Appointment', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedDoc,
                  decoration: const InputDecoration(labelText: 'Select Physician'),
                  items: doctors.map((d) => DropdownMenuItem(value: d.name, child: Text(d.name))).toList(),
                  onChanged: (val) {
                    if (val != null) selectedDoc = val;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: reasonCtrl,
                  decoration: const InputDecoration(labelText: 'Reason for Visit', hintText: 'e.g. Chronic Pain Checkup'),
                  validator: (v) => v == null || v.isEmpty ? 'Reason is required' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.date_range_rounded),
                        label: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (d != null) {
                            setState(() { selectedDate = d; });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.access_time_rounded),
                        label: Text(selectedTime.format(context)),
                        onPressed: () async {
                          final t = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (t != null) {
                            setState(() { selectedTime = t; });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
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
                
                final finalDateTime = DateTime(
                  selectedDate.year, selectedDate.month, selectedDate.day,
                  selectedTime.hour, selectedTime.minute,
                );

                // Add to appointments
                MockDataRepository.instance.appointments.add(
                  PatientAppointment(
                    id: 'apt-$randomId',
                    patientId: patient.id,
                    doctorName: selectedDoc,
                    dateTime: finalDateTime,
                    reason: reasonCtrl.text.trim(),
                  ),
                );

                // Log audit trail
                final prevHash = MockDataRepository.instance.auditLogs.isNotEmpty 
                    ? MockDataRepository.instance.auditLogs.last.entryHash 
                    : 'f9e2d1c6b3a8';
                MockDataRepository.instance.auditLogs.add(
                  AuditLogEntry(
                    id: 'log-$randomId',
                    action: 'appointment.scheduled',
                    actorId: user?.id ?? 'usr-006',
                    actorName: user?.name ?? 'Sarah Jenkins',
                    actorRole: user?.role.displayName ?? 'Hospital Admin',
                    resourceId: patient.id,
                    resourceType: 'Patient',
                    description: 'Appointment scheduled for ${patient.name} with $selectedDoc on ${DateFormat('yyyy-MM-dd').format(finalDateTime)}',
                    timestamp: DateTime.now(),
                    entryHash: 'e${randomId}h',
                    previousHash: prevHash,
                    ipAddress: '192.168.1.100',
                    metadata: {'patient_id': patient.id, 'doctor': selectedDoc, 'date': finalDateTime.toIso8601String()},
                  ),
                );

                Navigator.pop(ctx);
                setState(() {});

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Appointment scheduled successfully.'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  void _showScheduleSurgeryDialog(Patient patient) {
    final doctors = MockDataRepository.instance.doctors;
    String selectedSurgeon = doctors.first.name;
    final procedureCtrl = TextEditingController();
    
    String selectedOR = 'OR-1';
    
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
    TimeOfDay selectedTime = const TimeOfDay(hour: 7, minute: 30);

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(PhosphorIconsRegular.scissors, color: AppColors.escalated, size: 24),
            const SizedBox(width: 10),
            const Text('Schedule Surgery', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedSurgeon,
                  decoration: const InputDecoration(labelText: 'Surgeon'),
                  items: doctors.map((d) => DropdownMenuItem(value: d.name, child: Text(d.name))).toList(),
                  onChanged: (val) {
                    if (val != null) selectedSurgeon = val;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: procedureCtrl,
                  decoration: const InputDecoration(labelText: 'Procedure Name', hintText: 'e.g. Lumbar Spine Fusion'),
                  validator: (v) => v == null || v.isEmpty ? 'Procedure is required' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedOR,
                        decoration: const InputDecoration(labelText: 'Operating Room'),
                        items: const [
                          DropdownMenuItem(value: 'OR-1', child: Text('OR-1 (Cardiovascular)')),
                          DropdownMenuItem(value: 'OR-2', child: Text('OR-2 (Orthopedic)')),
                          DropdownMenuItem(value: 'OR-3', child: Text('OR-3 (General)')),
                          DropdownMenuItem(value: 'OR-4', child: Text('OR-4 (Emergency)')),
                        ],
                        onChanged: (val) {
                          if (val != null) selectedOR = val;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.date_range_rounded),
                        label: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (d != null) {
                            setState(() { selectedDate = d; });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.access_time_rounded),
                        label: Text(selectedTime.format(context)),
                        onPressed: () async {
                          final t = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (t != null) {
                            setState(() { selectedTime = t; });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
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
                
                final finalDateTime = DateTime(
                  selectedDate.year, selectedDate.month, selectedDate.day,
                  selectedTime.hour, selectedTime.minute,
                );

                // Add to surgeries
                MockDataRepository.instance.surgeries.add(
                  PatientSurgery(
                    id: 'srg-$randomId',
                    patientId: patient.id,
                    surgeonName: selectedSurgeon,
                    operationTheatre: selectedOR,
                    dateTime: finalDateTime,
                    procedure: procedureCtrl.text.trim(),
                  ),
                );

                // Log audit trail
                final prevHash = MockDataRepository.instance.auditLogs.isNotEmpty 
                    ? MockDataRepository.instance.auditLogs.last.entryHash 
                    : 'f9e2d1c6b3a8';
                MockDataRepository.instance.auditLogs.add(
                  AuditLogEntry(
                    id: 'log-$randomId',
                    action: 'surgery.scheduled',
                    actorId: user?.id ?? 'usr-006',
                    actorName: user?.name ?? 'Sarah Jenkins',
                    actorRole: user?.role.displayName ?? 'Hospital Admin',
                    resourceId: patient.id,
                    resourceType: 'Patient',
                    description: 'Surgery scheduled: ${procedureCtrl.text.trim()} for ${patient.name} in $selectedOR on ${DateFormat('yyyy-MM-dd').format(finalDateTime)}',
                    timestamp: DateTime.now(),
                    entryHash: 'e${randomId}h',
                    previousHash: prevHash,
                    ipAddress: '192.168.1.100',
                    metadata: {'patient_id': patient.id, 'surgeon': selectedSurgeon, 'or': selectedOR, 'procedure': procedureCtrl.text.trim()},
                  ),
                );

                Navigator.pop(ctx);
                setState(() {});

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Surgery scheduled successfully in $selectedOR.'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Schedule Surgery'),
          ),
        ],
      ),
    );
  }
}

// ─── Header Card Widget ───────────────────────────────────────────────────────
class _PatientHeader extends StatelessWidget {
  final Patient patient;
  const _PatientHeader({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primarySurface,
            child: Text(
              patient.name.split(' ').map((w) => w[0]).take(2).join(),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        patient.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: patient.gender == 'Male' ? Colors.blue.withOpacity(0.08) : Colors.pink.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        border: Border.all(
                          color: patient.gender == 'Male' ? Colors.blue.withOpacity(0.3) : Colors.pink.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        patient.gender,
                        style: TextStyle(
                          color: patient.gender == 'Male' ? Colors.blue[700] : Colors.pink[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'MRN: ${patient.mrn ?? "—"} · DOB: ${patient.dateOfBirth}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Clinical Summary Widget ──────────────────────────────────────────────────
class _ClinicalSummaryCard extends StatelessWidget {
  final Patient patient;
  const _ClinicalSummaryCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsRegular.firstAid, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Clinical Summary',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const Divider(height: 24),
          Text(
            'Primary Diagnosis',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: 4),
          Text(
            patient.primaryDiagnosis ?? 'No primary diagnosis recorded',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Text(
            'Chronic Conditions',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: 8),
          if (patient.chronicConditions.isEmpty)
            Text('No chronic conditions recorded', style: Theme.of(context).textTheme.bodyMedium)
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: patient.chronicConditions.map((cond) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    cond,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

// ─── Detail Field Util ────────────────────────────────────────────────────────
class _DetailField extends StatelessWidget {
  final String label;
  final String value;
  final bool isCode;
  const _DetailField({required this.label, required this.value, this.isCode = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFamily: isCode ? 'monospace' : null,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Prior Authorization History Widget ────────────────────────────────────────
class _AuthorizationHistoryCard extends StatelessWidget {
  final List<AuthorizationRequest> auths;
  const _AuthorizationHistoryCard({required this.auths});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(PhosphorIconsRegular.clipboardText, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Prior Authorizations (${auths.length})',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          if (auths.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No authorization history found for this patient.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: auths.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (ctx, i) {
                final auth = auths[i];
                return InkWell(
                  onTap: () => context.go('${RouteNames.authorizations}/${auth.id}'),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 36,
                          decoration: BoxDecoration(
                            color: auth.status.color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    auth.authNumber,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'monospace',
                                        ),
                                  ),
                                  const SizedBox(width: 8),
                                  _StatusChip(status: auth.status),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${auth.procedureCode} · ${auth.procedureDescription}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: 'Preview Patient Portal Explanation',
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _showPatientExplanation(ctx, auth),
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(PhosphorIconsRegular.user, color: auth.status.color, size: 20),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _showPatientExplanation(BuildContext context, AuthorizationRequest auth) {
    final decisions = MockDataRepository.instance.aiDecisions;
    final decision = auth.aiDecisionId != null
        ? decisions.firstWhere((d) => d.id == auth.aiDecisionId, orElse: () => decisions.first)
        : null;
    final explanation = PatientPortalExplanation.generate(auth, decision);

    Color statusColor;
    IconData statusIcon;
    switch (auth.status) {
      case AuthorizationStatus.approved:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle_rounded;
        break;
      case AuthorizationStatus.rejected:
        statusColor = AppColors.error;
        statusIcon = Icons.cancel_rounded;
        break;
      case AuthorizationStatus.pending:
      case AuthorizationStatus.underReview:
        statusColor = AppColors.warning;
        statusIcon = Icons.schedule_rounded;
        break;
      case AuthorizationStatus.escalated:
        statusColor = AppColors.escalated;
        statusIcon = Icons.priority_high_rounded;
        break;
      default:
        statusColor = AppColors.neutral500;
        statusIcon = Icons.info_rounded;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Pull handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Icon(PhosphorIconsRegular.user, color: statusColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Patient Portal Preview',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Status row
                    Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 26),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            explanation.title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      explanation.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Text(
                      'What you should do next:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...explanation.nextSteps.map((step) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.arrow_forward_rounded, size: 14, color: statusColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              step,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                    
                    const Divider(height: 32),

                    Row(
                      children: [
                        Icon(PhosphorIconsRegular.bookOpen, color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Understand Your Treatment & Codes',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Healthcare terms can be confusing. Here is what they mean in plain language:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    ...explanation.glossary.map((entry) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 0,
                      color: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        side: BorderSide(color: AppColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              entry.value,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Status Chip Widget ───────────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final AuthorizationStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: status.color,
              fontWeight: FontWeight.w600,
              fontSize: 9,
            ),
      ),
    );
  }
}

// ─── Quick Actions Widget ─────────────────────────────────────────────────────
class _QuickActionsCard extends StatelessWidget {
  final Patient patient;
  const _QuickActionsCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsRegular.lightning, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Actions',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const Divider(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.go(RouteNames.createAuthorization),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('New Authorization'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('FHIR XML Summary generated for ${patient.name}'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              icon: Icon(PhosphorIconsRegular.downloadSimple, size: 18),
              label: const Text('Export Health Record (CCD)'),
            ),
          ),
        ],
      ),
    );
  }
}
