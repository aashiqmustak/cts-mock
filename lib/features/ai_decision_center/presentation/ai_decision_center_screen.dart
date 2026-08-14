import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';
import '../../../repositories/data_repository.dart';
import '../../../core/utils/platform_helper.dart';
import '../../../core/providers/authorizations_provider.dart';
import '../../../core/providers/auth_provider.dart';

class AiDecisionCenterScreen extends ConsumerStatefulWidget {
  const AiDecisionCenterScreen({super.key});

  @override
  ConsumerState<AiDecisionCenterScreen> createState() => _AiDecisionCenterScreenState();
}

class _AiDecisionCenterScreenState extends ConsumerState<AiDecisionCenterScreen> {
  int _selectedIndex = 0;
  bool _showDetailOnMobile = false;

  @override
  Widget build(BuildContext context) {
    final authsList = ref.watch(authorizationsProvider);
    final authIds = authsList.map((a) => a.id).toSet();
    final decisions = MockDataRepository.instance.aiDecisions
        .where((d) => authIds.contains(d.authorizationId))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(gradient: AppColors.aiGradient, borderRadius: BorderRadius.circular(12)),
                child: const Icon(PhosphorIconsRegular.brain, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('AI Decision Center',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                Text('Explainable AI reasoning for all \nauthorization decisions',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
              ]),
            ],
          ).animate().fadeIn(),

          const SizedBox(height: 20),

          // Stats strip
          LayoutBuilder(builder: (ctx, constraints) {
            final isMobile = constraints.maxWidth < 600;
            if (isMobile) {
              return GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _AiStatChip('96.2%', 'Overall Accuracy', AppColors.success, PhosphorIconsRegular.target, isMobile: true),
                  _AiStatChip('3.24s', 'Avg Decision Time', AppColors.primary, PhosphorIconsRegular.lightning, isMobile: true),
                  _AiStatChip('91.4%', 'Instant Decisions', AppColors.accent, PhosphorIconsRegular.robot, isMobile: true),
                  _AiStatChip('2', 'Auto-Escalated', AppColors.warning, PhosphorIconsRegular.warningOctagon, isMobile: true),
                ],
              );
            }
            return Row(
              children: [
                _AiStatChip('96.2%', 'Overall Accuracy', AppColors.success, PhosphorIconsRegular.target),
                const SizedBox(width: 12),
                _AiStatChip('3.24s', 'Avg Decision Time', AppColors.primary, PhosphorIconsRegular.lightning),
                const SizedBox(width: 12),
                _AiStatChip('91.4%', 'Instant Decisions', AppColors.accent, PhosphorIconsRegular.robot),
                const SizedBox(width: 12),
                _AiStatChip('2', 'Auto-Escalated', AppColors.warning, PhosphorIconsRegular.warningOctagon),
              ],
            );
          }).animate(delay: 100.ms).fadeIn(),

          const SizedBox(height: 20),

          // Content
          Expanded(
            child: LayoutBuilder(builder: (ctx, constraints) {
              if (decisions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIconsRegular.brain, size: 48, color: AppColors.neutral300),
                      const SizedBox(height: 12),
                      Text('No AI decisions found',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              )),
                      const SizedBox(height: 4),
                      Text('Prior authorizations will show AI insights once processed.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textTertiary,
                              )),
                    ],
                  ),
                );
              }

              final isMobile = isMobileLayout(ctx);
              if (!isMobile) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 320, child: _DecisionList(
                      decisions: decisions,
                      selectedIndex: _selectedIndex,
                      onSelect: (i) => setState(() {
                        _selectedIndex = i;
                      }),
                    )),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _DecisionDetail(
                        decision: decisions[_selectedIndex],
                      ),
                    ),
                  ],
                );
              }

              // Mobile Layout
              if (_showDetailOnMobile) {
                return _DecisionDetail(
                  decision: decisions[_selectedIndex],
                  onBack: () => setState(() => _showDetailOnMobile = false),
                );
              }

              return _DecisionList(
                decisions: decisions,
                selectedIndex: _selectedIndex,
                onSelect: (i) => setState(() {
                  _selectedIndex = i;
                  _showDetailOnMobile = true;
                }),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _AiStatChip extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;
  final bool isMobile;
  const _AiStatChip(this.value, this.label, this.color, this.icon, {this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8.0 : 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: isMobile ? 14 : 18, color: color),
          SizedBox(width: isMobile ? 6 : 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: (isMobile
                      ? Theme.of(context).textTheme.labelMedium
                      : Theme.of(context).textTheme.titleSmall)
                      ?.copyWith(fontWeight: FontWeight.w800, color: color),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: isMobile ? 9 : 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isMobile) {
      return content;
    }
    return Expanded(child: content);
  }
}

class _DecisionList extends ConsumerWidget {
  final List<AiDecision> decisions;
  final int selectedIndex;
  final Function(int) onSelect;
  const _DecisionList({required this.decisions, required this.selectedIndex, required this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auths = ref.watch(authorizationsProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Decisions (${decisions.length})',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: decisions.length,
              itemBuilder: (ctx, i) {
                final d = decisions[i];
                final auth = auths.firstWhere(
                    (a) => a.id == d.authorizationId, orElse: () => auths.first);
                final isSelected = i == selectedIndex;
                return InkWell(
                  onTap: () => onSelect(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    color: isSelected ? AppColors.primarySurface : Colors.transparent,
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        _RecommBadge(d.recommendation),
                        const Spacer(),
                        if (d.autoEscalated)
                          const Icon(PhosphorIconsRegular.warningOctagon,
                              size: 14, color: AppColors.escalated),
                        Text('${(d.confidenceScore * 100).toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      ]),
                      const SizedBox(height: 6),
                      Text(auth.patientName,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary)),
                      Text('${auth.authNumber} · ${auth.procedureCode}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textTertiary)),
                      const SizedBox(height: 6),
                      _ConfidenceBar(value: d.confidenceScore),
                    ]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommBadge extends StatelessWidget {
  final String recommendation;
  const _RecommBadge(this.recommendation);

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (recommendation) {
      case 'approve':  color = AppColors.success; break;
      case 'reject':   color = AppColors.error; break;
      default:         color = AppColors.escalated;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(recommendation.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color, fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 0.5)),
    );
  }
}

class _ConfidenceBar extends StatelessWidget {
  final double value;
  const _ConfidenceBar({required this.value});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (value >= 0.85) color = AppColors.success;
    else if (value >= 0.75) color = AppColors.warning;
    else color = AppColors.error;
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: value,
        backgroundColor: color.withOpacity(0.1),
        valueColor: AlwaysStoppedAnimation<Color>(color),
        minHeight: 4,
      ),
    );
  }
}

class _DecisionDetail extends StatefulWidget {
  final AiDecision decision;
  final VoidCallback? onBack;
  const _DecisionDetail({required this.decision, this.onBack});

  @override
  State<_DecisionDetail> createState() => _DecisionDetailState();
}

class _DecisionDetailState extends State<_DecisionDetail> {
  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final d = widget.decision;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Confidence meter card
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.aiGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                if (widget.onBack != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: widget.onBack,
                    ),
                  ),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('AI Confidence Score',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white.withOpacity(0.8))),
                    Text('${(d.confidenceScore * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w900)),
                  ]),
                ),
                Column(children: [
                  Text(d.recommendation.toUpperCase(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1)),
                  Text('Recommendation',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white.withOpacity(0.7))),
                  const SizedBox(height: 8),
                  if (d.autoEscalated)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        border: Border.all(color: AppColors.warning.withOpacity(0.5)),
                      ),
                      child: Row(children: [
                        const Icon(PhosphorIconsRegular.warningOctagon, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text('AUTO-ESCALATED',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 10)),
                      ]),
                    ),
                ]),
              ]),

              const SizedBox(height: 20),

              // Score bars
              LayoutBuilder(builder: (ctx, scoreConstraints) {
                final isMobileLayout = scoreConstraints.maxWidth < 500;
                if (isMobileLayout) {
                  return Column(
                    children: [
                      _ScoreBar('Medical Necessity', d.medicalNecessityScore, Colors.white),
                      const SizedBox(height: 12),
                      _ScoreBar('Risk Score', d.riskScore, Colors.white),
                      const SizedBox(height: 12),
                      _ScoreBar('Appeal Likelihood', d.appealLikelihood, Colors.white),
                    ],
                  );
                }
                return Row(children: [
                  Expanded(child: _ScoreBar('Medical Necessity', d.medicalNecessityScore, Colors.white)),
                  const SizedBox(width: 16),
                  Expanded(child: _ScoreBar('Risk Score', d.riskScore, Colors.white)),
                  const SizedBox(width: 16),
                  Expanded(child: _ScoreBar('Appeal Likelihood', d.appealLikelihood, Colors.white)),
                ]);
              }),
            ]),
          ).animate().fadeIn(),

          const SizedBox(height: 16),

          // Fraud signals
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(PhosphorIconsRegular.shield, size: 18, color: AppColors.error),
                  const SizedBox(width: 8),
                  Text('Fraud & Anomaly Signals',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 16),
                ...d.fraudSignals.entries.map((e) {
                  Color c = e.value >= 0.4 ? AppColors.error : (e.value >= 0.2 ? AppColors.warning : AppColors.success);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(children: [
                      Expanded(child: Text(e.key,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary))),
                      Text('${(e.value * 100).toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: c, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 12),
                      SizedBox(width: 100, child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: e.value,
                          backgroundColor: c.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(c),
                          minHeight: 5,
                        ),
                      )),
                    ]),
                  );
                }).toList(),
              ],
            ),
          ).animate(delay: 100.ms).fadeIn(),

          const SizedBox(height: 16),

          // Reasoning chain
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(PhosphorIconsRegular.listMagnifyingGlass, size: 18, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Text('Step-by-Step Reasoning',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() {
                      if (_expanded.length == d.reasoningChain.length) {
                        _expanded.clear();
                      } else {
                        _expanded.addAll(d.reasoningChain.map((s) => s.stepNumber));
                      }
                    }),
                    child: Text(_expanded.length == d.reasoningChain.length ? 'Collapse all' : 'Expand all'),
                  ),
                ]),
                const SizedBox(height: 12),
                ...d.reasoningChain.map((step) {
                  final isExpanded = _expanded.contains(step.stepNumber);
                  return _AIReasoningStep(
                    step: step,
                    isExpanded: isExpanded,
                    onToggle: () => setState(() {
                      isExpanded ? _expanded.remove(step.stepNumber) : _expanded.add(step.stepNumber);
                    }),
                  );
                }).toList(),
              ],
            ),
          ).animate(delay: 150.ms).fadeIn(),
        ],
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final double value;
  final Color textColor;
  const _ScoreBar(this.label, this.value, this.textColor);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: textColor.withOpacity(0.7))),
      const SizedBox(height: 6),
      Text('${(value * 100).toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: textColor, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.white.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
          minHeight: 5,
        ),
      ),
    ]);
  }
}

class _AIReasoningStep extends StatelessWidget {
  final AiReasoningStep step;
  final bool isExpanded;
  final VoidCallback onToggle;
  const _AIReasoningStep({required this.step, required this.isExpanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: step.passed ? AppColors.successLight.withOpacity(0.4) : AppColors.errorLight.withOpacity(0.4),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
              color: step.passed ? AppColors.success.withOpacity(0.25) : AppColors.error.withOpacity(0.25)),
        ),
        child: Column(children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Container(
                  width: 26, height: 26,
                  decoration: BoxDecoration(
                    color: step.passed ? AppColors.success : AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(step.passed ? Icons.check_rounded : Icons.close_rounded,
                      size: 14, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Step ${step.stepNumber}: ${step.title}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                  if (step.citedValue != null)
                    Text(step.citedValue!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary, fontFamily: 'monospace')),
                ])),
                // Source badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.accent.withOpacity(0.2)),
                  ),
                  child: Text(step.dataSource.split(' ').first,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                Icon(isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: AppColors.textTertiary, size: 20),
              ]),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Divider(height: 12),
                Text(step.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary, height: 1.6)),
                const SizedBox(height: 8),
                ...step.details.map((det) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Icon(Icons.circle, size: 5, color: AppColors.textTertiary),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(det,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary))),
                  ]),
                )).toList(),
                if (step.policyRef != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(children: [
                      Icon(PhosphorIconsRegular.book, size: 12, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(step.policyRef!,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ],
              ]),
            ),
        ]),
      ),
    );
  }
}

