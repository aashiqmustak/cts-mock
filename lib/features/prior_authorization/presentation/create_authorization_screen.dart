import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class CreateAuthorizationScreen extends ConsumerStatefulWidget {
  const CreateAuthorizationScreen({super.key});

  @override
  ConsumerState<CreateAuthorizationScreen> createState() => _CreateAuthorizationScreenState();
}

class _CreateAuthorizationScreenState extends ConsumerState<CreateAuthorizationScreen> {
  int _step = 0;
  final _steps = ['Patient', 'Diagnosis', 'Procedure', 'Insurance', 'Review'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New Prior Authorization Request',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700))
              .animate().fadeIn(),

          const SizedBox(height: 8),
          Text('Complete all steps to submit your prior authorization request.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary))
              .animate(delay: 100.ms).fadeIn(),

          const SizedBox(height: 28),

          // Step indicator
          _StepIndicator(currentStep: _step, steps: _steps)
              .animate(delay: 150.ms).fadeIn().slideY(begin: -0.1),

          const SizedBox(height: 24),

          // Step content
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppColors.border),
              boxShadow: AppTheme.shadowSm,
            ),
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_steps[_step],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('Step ${_step + 1} of ${_steps.length}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                _buildStepContent(_step),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_step > 0)
                      OutlinedButton.icon(
                        onPressed: () => setState(() => _step--),
                        icon: const Icon(PhosphorIconsRegular.arrowLeft, size: 16),
                        label: const Text('Back'),
                      )
                    else
                      const SizedBox.shrink(),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_step < _steps.length - 1) {
                          setState(() => _step++);
                        } else {
                          _submitRequest();
                        }
                      },
                      icon: Icon(
                        _step == _steps.length - 1
                            ? PhosphorIconsRegular.paperPlaneRight
                            : PhosphorIconsRegular.arrowRight,
                        size: 16,
                      ),
                      label: Text(_step == _steps.length - 1 ? 'Submit Request' : 'Continue'),
                    ),
                  ],
                ),
              ],
            ),
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.05),
        ],
      ),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0: return _PatientStep();
      case 1: return _DiagnosisStep();
      case 2: return _ProcedureStep();
      case 3: return _InsuranceStep();
      case 4: return _ReviewStep();
      default: return const SizedBox.shrink();
    }
  }

  void _submitRequest() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Authorization Submitted'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(color: AppColors.successLight, shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, color: AppColors.success, size: 32),
        ),
        const SizedBox(height: 16),
        const Text('Your prior authorization request has been submitted successfully.'),
        const SizedBox(height: 8),
        Text('Auth #: PA-2024-08855', style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
          fontFamily: 'monospace', color: AppColors.primary, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('AI is processing your request...', style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary)),
      ]),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Done'),
        ),
      ],
    ));
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> steps;
  const _StepIndicator({required this.currentStep, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: steps.asMap().entries.map((e) {
        final i = e.key;
        final label = e.value;
        final isDone = i < currentStep;
        final isCurrent = i == currentStep;
        final color = isDone || isCurrent ? AppColors.primary : AppColors.neutral300;
        return Expanded(
          child: Row(
            children: [
              Column(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: isDone ? AppColors.primary : (isCurrent ? AppColors.primarySurface : AppColors.neutral100),
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                        : Text('${i + 1}',
                            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isCurrent ? AppColors.primary : AppColors.textTertiary,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                    fontSize: MediaQuery.of(context).size.width < 600 ? 9 : 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ]),
              if (i < steps.length - 1)
                Expanded(child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    height: 2,
                    color: i < currentStep ? AppColors.primary : AppColors.neutral200,
                  ),
                )),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PatientStep extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) => Column(children: [
    _Field('Patient Name', 'Full legal name'),
    _Field('Date of Birth', 'MM/DD/YYYY'),
    _Field('Member ID', 'Insurance member ID'),
    _Field('MRN', 'Medical Record Number (optional)'),
  ]);
}

class _DiagnosisStep extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) => Column(children: [
    _Field('ICD-10 Code', 'e.g. I25.10', hint: 'Primary diagnosis code'),
    _Field('Diagnosis Description', 'Atherosclerotic Heart Disease of Native Coronary Artery'),
    _Field('Clinical Notes', 'Additional clinical information', maxLines: 3),
  ]);
}

class _ProcedureStep extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) => Column(children: [
    _Field('CPT Code', 'e.g. 93015', hint: 'Procedure code'),
    _Field('Procedure Description', 'Cardiovascular Stress Test'),
    _Field('Scheduled Date', 'MM/DD/YYYY'),
    _Field('Facility NPI', 'NPI number of facility'),
  ]);
}

class _InsuranceStep extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) => Column(children: [
    _Field('Insurance Plan', 'BlueCross PPO Premium'),
    _Field('Group Number', 'Insurance group number'),
    _Field('Requesting Physician NPI', '10-digit NPI number'),
    _Field('Priority', '', isDropdown: true, items: ['Routine', 'Urgent', 'Emergent', 'STAT']),
  ]);
}

class _ReviewStep extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Review Summary', style: Theme.of(ctx).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _ReviewRow('Patient', 'John Smith (DOB: 01/15/1970)'),
          _ReviewRow('Diagnosis', 'I25.10 — Coronary Artery Disease'),
          _ReviewRow('Procedure', 'CPT 93015 — Cardiac Stress Test'),
          _ReviewRow('Insurance', 'BlueCross PPO Premium'),
          _ReviewRow('Priority', 'Routine'),
        ]),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.warningLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Row(children: [
          const Icon(Icons.info_rounded, color: AppColors.warning, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(
            'AI will process this request immediately upon submission and aims to provide a decision within 5 seconds.',
            style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: AppColors.warningDark),
          )),
        ]),
      ),
    ],
  );
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReviewRow(this.label, this.value);
  @override
  Widget build(BuildContext ctx) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      SizedBox(width: 100, child: Text(label, style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary))),
      Expanded(child: Text(value, style: Theme.of(ctx).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
    ]),
  );
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  final String? hint;
  final int maxLines;
  final bool isDropdown;
  final List<String> items;
  const _Field(this.label, this.value, {this.hint, this.maxLines = 1, this.isDropdown = false, this.items = const []});

  @override
  Widget build(BuildContext ctx) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: isDropdown
        ? DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: label),
            items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
            onChanged: (_) {},
          )
        : TextFormField(
            initialValue: value.isEmpty ? null : value,
            maxLines: maxLines,
            decoration: InputDecoration(labelText: label, hintText: hint),
          ),
  );
}
