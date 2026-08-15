import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../core/constants/route_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../models/user_role.dart';

// ─── Search History State ────────────────────────────────────────────────────
final searchHistoryProvider = StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
  return SearchHistoryNotifier();
});

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  SearchHistoryNotifier() : super(['Cardiology', 'PA-2024-001', 'MRI Appeal', 'Dr. Fox']);

  void addQuery(String query) {
    if (query.trim().isEmpty) return;
    final clean = query.trim();
    state = [clean, ...state.where((q) => q != clean)].take(5).toList();
  }

  void removeQuery(String query) {
    state = state.where((q) => q != query).toList();
  }

  void clear() {
    state = [];
  }
}

// ─── Command Item ─────────────────────────────────────────────────────────────
class CommandItem {
  final String id;
  final String title;
  final String? subtitle;
  final IconData icon;
  final String route;
  final List<Permission> requiredPermissions;
  final List<String> keywords;

  const CommandItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.route,
    this.requiredPermissions = const [],
    this.keywords = const [],
  });
}

final _allCommands = <CommandItem>[
  CommandItem(id: 'c-dashboard', title: 'Dashboard', subtitle: 'View org-wide dashboard',
    icon: PhosphorIconsRegular.squaresFour, route: RouteNames.dashboard,
    keywords: ['home', 'stats', 'overview']),
  CommandItem(id: 'c-new-auth', title: 'New Authorization', subtitle: 'Submit prior auth request',
    icon: PhosphorIconsRegular.plusCircle, route: RouteNames.createAuthorization,
    requiredPermissions: [Permission.createAuthorizationRequest],
    keywords: ['create', 'submit', 'new request', 'prior auth']),
  CommandItem(id: 'c-authorizations', title: 'Authorizations', subtitle: 'View all authorization requests',
    icon: PhosphorIconsRegular.clipboardText, route: RouteNames.authorizations,
    keywords: ['requests', 'auth list', 'pending', 'approved']),
  CommandItem(id: 'c-patients', title: 'Patients', subtitle: 'Patient management',
    icon: PhosphorIconsRegular.users, route: RouteNames.patients,
    keywords: ['patient list', 'members']),
  CommandItem(id: 'c-doctors', title: 'Physicians', subtitle: 'Doctor profiles and performance',
    icon: PhosphorIconsRegular.stethoscope, route: RouteNames.doctors,
    keywords: ['doctors', 'physicians', 'providers']),
  CommandItem(id: 'c-review', title: 'Insurance Review', subtitle: 'Review queue',
    icon: PhosphorIconsRegular.shieldCheck, route: RouteNames.insuranceReview,
    requiredPermissions: [Permission.approveRequest],
    keywords: ['approve', 'reject', 'review queue']),
  CommandItem(id: 'c-ai', title: 'AI Decision Center', subtitle: 'Explainable AI reasoning',
    icon: PhosphorIconsRegular.brain, route: RouteNames.aiDecisionCenter,
    keywords: ['ai', 'machine learning', 'decisions', 'confidence', 'reasoning']),
  CommandItem(id: 'c-appeals', title: 'Appeals', subtitle: 'Manage and file appeals',
    icon: PhosphorIconsRegular.gavel, route: RouteNames.appeals,
    keywords: ['appeal', 'dispute', 'overturn']),
  CommandItem(id: 'c-analytics', title: 'Analytics', subtitle: 'Reports and dashboards',
    icon: PhosphorIconsRegular.chartLineUp, route: RouteNames.analytics,
    keywords: ['reports', 'charts', 'trends', 'performance']),
  CommandItem(id: 'c-claims', title: 'Insurance Claims', subtitle: 'Verify insurance and track claims',
    icon: PhosphorIconsRegular.fileText, route: RouteNames.insuranceClaims,
    requiredPermissions: [Permission.viewInsuranceClaims],
    keywords: ['insurance', 'claims', 'verification', 'member id', 'policy']),
  CommandItem(id: 'c-audit', title: 'Audit Logs', subtitle: 'Tamper-evident activity log',
    icon: PhosphorIconsRegular.listChecks, route: RouteNames.auditLogs,
    requiredPermissions: [Permission.viewAllAuditLogs, Permission.viewOwnAuditLogs],
    keywords: ['audit', 'history', 'activity', 'logs']),
  CommandItem(id: 'c-access', title: 'Access Control', subtitle: 'Role and permission management',
    icon: PhosphorIconsRegular.lock, route: RouteNames.accessControl,
    requiredPermissions: [Permission.manageAccessControl],
    keywords: ['rbac', 'roles', 'permissions', 'admin']),
  CommandItem(id: 'c-fhir', title: 'FHIR Integrations', subtitle: 'EMR connectivity status',
    icon: PhosphorIconsRegular.plugsConnected, route: RouteNames.integrations,
    requiredPermissions: [Permission.manageFhirIntegrations],
    keywords: ['fhir', 'emr', 'hl7', 'integration', 'sync']),
  CommandItem(id: 'c-settings', title: 'Settings', subtitle: 'Application preferences',
    icon: PhosphorIconsRegular.gear, route: RouteNames.settings,
    keywords: ['preferences', 'config']),
  CommandItem(id: 'c-profile', title: 'My Profile', subtitle: 'Account and user settings',
    icon: PhosphorIconsRegular.userCircle, route: RouteNames.profile,
    keywords: ['account', 'profile', 'user']),
];

// ─── Command Palette Widget ───────────────────────────────────────────────────
class CommandPalette extends ConsumerStatefulWidget {
  const CommandPalette({super.key});

  @override
  ConsumerState<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends ConsumerState<CommandPalette>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  String _query = '';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            _close();
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            final filtered = _filteredCommands;
            setState(() => _selectedIndex = (_selectedIndex + 1).clamp(0, filtered.length - 1));
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            final filtered = _filteredCommands;
            setState(() => _selectedIndex = (_selectedIndex - 1).clamp(0, filtered.length - 1));
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.enter) {
            final filtered = _filteredCommands;
            if (filtered.isNotEmpty) {
              _navigate(filtered[_selectedIndex]);
              return KeyEventResult.handled;
            }
          }
        }
        return KeyEventResult.ignored;
      },
    );
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _close() {
    ref.read(commandPaletteOpenProvider.notifier).state = false;
    FocusManager.instance.primaryFocus?.unfocus();
  }

  List<CommandItem> get _filteredCommands {
    final role = ref.read(currentRoleProvider);
    final allVisible = _allCommands.where((cmd) {
      if (cmd.requiredPermissions.isEmpty) return true;
      if (role == null) return false;
      return role.hasAnyPermission(cmd.requiredPermissions);
    }).toList();

    if (_query.isEmpty) return allVisible;

    final lower = _query.toLowerCase();
    return allVisible.where((cmd) {
      return cmd.title.toLowerCase().contains(lower) ||
          (cmd.subtitle?.toLowerCase().contains(lower) ?? false) ||
          cmd.keywords.any((k) => k.contains(lower));
    }).toList();
  }

  void _navigate(CommandItem item) {
    if (_query.trim().isNotEmpty) {
      ref.read(searchHistoryProvider.notifier).addQuery(_query);
    } else {
      ref.read(searchHistoryProvider.notifier).addQuery(item.title);
    }
    _close();
    context.go(item.route);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredCommands;

    return FadeTransition(
      opacity: _fadeAnim,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _close,
        child: Container(
          color: Colors.black54,
          child: Center(
            child: GestureDetector(
              onTap: () {}, // prevent close on palette tap
              child: Container(
                width: 580,
                constraints: const BoxConstraints(maxHeight: 480),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  boxShadow: AppTheme.shadowLg,
                  border: Border.all(color: AppColors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Search input
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            hintText: 'Search actions, pages, patients...',
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(PhosphorIconsRegular.magnifyingGlass,
                                  color: AppColors.textTertiary, size: 20),
                            ),
                             suffixIcon: Padding(
                               padding: const EdgeInsets.only(right: 12),
                               child: InkWell(
                                 onTap: _close,
                                 child: MediaQuery.of(context).size.width < 600
                                     ? const Icon(Icons.close_rounded, color: AppColors.textSecondary)
                                     : Container(
                                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                         decoration: BoxDecoration(
                                           color: AppColors.neutral100,
                                           borderRadius: BorderRadius.circular(6),
                                           border: Border.all(color: AppColors.border),
                                         ),
                                         child: Text('ESC',
                                             style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                               color: AppColors.textSecondary,
                                             )),
                                       ),
                               ),
                             ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppColors.neutral50,
                          ),
                          onChanged: (v) => setState(() {
                            _query = v;
                            _selectedIndex = 0;
                          }),
                        ),
                      ),

                      const Divider(height: 1),

                      if (_query.isEmpty) ...[
                        Consumer(
                          builder: (context, ref, child) {
                            final history = ref.watch(searchHistoryProvider);
                            if (history.isEmpty) return const SizedBox.shrink();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'RECENT SEARCHES',
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: AppColors.textTertiary,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => ref.read(searchHistoryProvider.notifier).clear(),
                                        child: Text(
                                          'Clear All',
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 38,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: history.map((q) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ActionChip(
                                        label: Text(q, style: const TextStyle(fontSize: 11)),
                                        padding: EdgeInsets.zero,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        backgroundColor: AppColors.neutral50,
                                        onPressed: () {
                                          _controller.text = q;
                                          _controller.selection = TextSelection.fromPosition(TextPosition(offset: q.length));
                                          setState(() {
                                            _query = q;
                                          });
                                        },
                                      ),
                                    )).toList(),
                                  ),
                                ),
                                const Divider(height: 16),
                              ],
                            );
                          },
                        ),
                      ],

                      // Results
                      if (filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(PhosphorIconsRegular.magnifyingGlass,
                                  size: 40, color: AppColors.neutral300),
                              const SizedBox(height: 12),
                              Text('No results for "$_query"',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  )),
                            ],
                          ),
                        )
                      else
                        Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: filtered.length,
                            itemBuilder: (ctx, i) {
                              final item = filtered[i];
                              final isSelected = i == _selectedIndex;
                              return InkWell(
                                onTap: () => _navigate(item),
                                onHover: (v) {
                                  if (v) setState(() => _selectedIndex = i);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 100),
                                  color: isSelected ? AppColors.primarySurface : Colors.transparent,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.neutral100,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(item.icon,
                                            size: 18,
                                            color: isSelected ? AppColors.primary : AppColors.neutral500),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(item.title,
                                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                                )),
                                            if (item.subtitle != null)
                                              Text(item.subtitle!,
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: AppColors.textTertiary,
                                                  )),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text('↵',
                                              style: TextStyle(color: Colors.white, fontSize: 12)),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      // Footer hint
                      Container(
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: AppColors.border)),
                          color: AppColors.neutral50,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            _HintKey('↑↓'), const SizedBox(width: 4),
                            Text('navigate', style: _hintStyle(context)),
                            const SizedBox(width: 12),
                            _HintKey('↵'), const SizedBox(width: 4),
                            Text('open', style: _hintStyle(context)),
                            const SizedBox(width: 12),
                            _HintKey('ESC'), const SizedBox(width: 4),
                            Text('close', style: _hintStyle(context)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextStyle? _hintStyle(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary);
}

class _HintKey extends StatelessWidget {
  final String label;
  const _HintKey(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.neutral200,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontFamily: 'monospace',
            color: AppColors.textSecondary,
          )),
    );
  }
}

// re-export so app_shell.dart can reference it
final commandPaletteOpenProvider = StateProvider<bool>((ref) => false);
