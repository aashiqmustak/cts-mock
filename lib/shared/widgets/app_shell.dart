import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/route_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../models/user_role.dart';
import '../../core/utils/platform_helper.dart';
import '../../features/settings/presentation/settings_screen.dart';
import 'command_palette.dart';

// ─── Navigation Item Definition ───────────────────────────────────────────────
class NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  final List<Permission> requiredPermissions;
  final bool requireAny;  // if true, any permission suffices; if false, all required

  const NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
    this.requiredPermissions = const [],
    this.requireAny = true,
  });
}

// ─── All Nav Items ────────────────────────────────────────────────────────────
const _navItems = <NavItem>[
  NavItem(
    label: 'Dashboard', route: RouteNames.dashboard,
    icon: PhosphorIconsRegular.squaresFour,
    activeIcon: PhosphorIconsFill.squaresFour,
    requiredPermissions: [],
  ),
  NavItem(
    label: 'Patients', route: RouteNames.patients,
    icon: PhosphorIconsRegular.users,
    activeIcon: PhosphorIconsFill.users,
    requiredPermissions: [Permission.createAuthorizationRequest, Permission.approveRequest],
    requireAny: true,
  ),
  NavItem(
    label: 'Doctors', route: RouteNames.doctors,
    icon: PhosphorIconsRegular.stethoscope,
    activeIcon: PhosphorIconsFill.stethoscope,
    requiredPermissions: [
      Permission.viewOrgWideDashboard,
      Permission.viewFacilityDashboard,
    ],
  ),
  NavItem(
    label: 'Authorizations', route: RouteNames.authorizations,
    icon: PhosphorIconsRegular.clipboardText,
    activeIcon: PhosphorIconsFill.clipboardText,
    requiredPermissions: [
      Permission.createAuthorizationRequest,
      Permission.approveRequest,
      Permission.viewOwnCases,
    ],
  ),
  NavItem(
    label: 'Insurance Review', route: RouteNames.insuranceReview,
    icon: PhosphorIconsRegular.shieldCheck,
    activeIcon: PhosphorIconsFill.shieldCheck,
    requiredPermissions: [Permission.approveRequest],
  ),
  NavItem(
    label: 'AI Decisions', route: RouteNames.aiDecisionCenter,
    icon: PhosphorIconsRegular.brain,
    activeIcon: PhosphorIconsFill.brain,
    requiredPermissions: [
      Permission.viewFullAiReasoning,
      Permission.viewAiSummaryOnly,
    ],
  ),
  NavItem(
    label: 'Appeals', route: RouteNames.appeals,
    icon: PhosphorIconsRegular.gavel,
    activeIcon: PhosphorIconsFill.gavel,
    requiredPermissions: [
      Permission.fileAppeal,
      Permission.trackAppeal,
      Permission.reviewAppeals,
    ],
  ),
  NavItem(
    label: 'Analytics', route: RouteNames.analytics,
    icon: PhosphorIconsRegular.chartLineUp,
    activeIcon: PhosphorIconsFill.chartLineUp,
    requiredPermissions: [
      Permission.viewAllAnalytics,
      Permission.viewOwnAnalytics,
      Permission.viewQueueAnalytics,
      Permission.viewFacilityAnalytics,
    ],
  ),
  NavItem(
    label: 'Medical Records', route: RouteNames.medicalRecords,
    icon: PhosphorIconsRegular.folder,
    activeIcon: PhosphorIconsFill.folder,
    requiredPermissions: [Permission.uploadDocuments, Permission.viewDocumentsOnly],
  ),
  NavItem(
    label: 'Insurance Claims', route: RouteNames.insuranceClaims,
    icon: PhosphorIconsRegular.fileText,
    activeIcon: PhosphorIconsFill.fileText,
    requiredPermissions: [Permission.viewInsuranceClaims],
  ),
  NavItem(
    label: 'Audit Logs', route: RouteNames.auditLogs,
    icon: PhosphorIconsRegular.listChecks,
    activeIcon: PhosphorIconsFill.listChecks,
    requiredPermissions: [Permission.viewAllAuditLogs, Permission.viewOwnAuditLogs],
  ),
  NavItem(
    label: 'Access Control', route: RouteNames.accessControl,
    icon: PhosphorIconsRegular.lock,
    activeIcon: PhosphorIconsFill.lock,
    requiredPermissions: [Permission.manageAccessControl],
    requireAny: false,
  ),
];

const _bottomNavItems = <NavItem>[
  NavItem(
    label: 'Settings', route: RouteNames.settings,
    icon: PhosphorIconsRegular.gear,
    activeIcon: PhosphorIconsFill.gear,
    requiredPermissions: [Permission.viewSettings],
  ),
  NavItem(
    label: 'Profile', route: RouteNames.profile,
    icon: PhosphorIconsRegular.userCircle,
    activeIcon: PhosphorIconsFill.userCircle,
    requiredPermissions: [Permission.viewProfile],
  ),
];

// ─── Sidebar State ────────────────────────────────────────────────────────────
final sidebarExpandedProvider = StateProvider<bool>((ref) => true);


// ─── App Shell Widget ─────────────────────────────────────────────────────────
class AppShell extends ConsumerStatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  @override
  void initState() {
    super.initState();
    // Register keyboard shortcut for command palette
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  @override
  Widget build(BuildContext context) {
    final isExpanded = ref.watch(sidebarExpandedProvider);
    final isCommandOpen = ref.watch(commandPaletteOpenProvider);
    final isMobile = isMobileLayout(context);
    final isTablet = MediaQuery.of(context).size.width < AppConstants.sidebarBreakpoint;
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final notifications = ref.watch(unreadNotificationCountProvider);

    final isTopLevel = currentRoute == RouteNames.dashboard ||
                       currentRoute == RouteNames.authorizations ||
                       currentRoute == RouteNames.aiDecisionCenter ||
                       currentRoute == RouteNames.profile;

    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: (event) {
        // Cmd/Ctrl+K → open command palette
        if (event is KeyDownEvent &&
            (HardwareKeyboard.instance.isMetaPressed ||
             HardwareKeyboard.instance.isControlPressed) &&
            event.logicalKey == LogicalKeyboardKey.keyK) {
          ref.read(commandPaletteOpenProvider.notifier).state = true;
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: isMobile ? AppBar(
          title: Text(
            _getTitleForRoute(currentRoute),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
          ),
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: !isTopLevel
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      if (currentRoute.startsWith('/authorizations')) {
                        context.go(RouteNames.authorizations);
                      } else if (currentRoute.startsWith('/settings')) {
                        context.go(RouteNames.profile);
                      } else {
                        context.go(RouteNames.dashboard);
                      }
                    }
                  },
                )
              : null,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: AppColors.border, height: 1),
          ),
          actions: [
            IconButton(
              icon: const Icon(PhosphorIconsRegular.magnifyingGlass),
              onPressed: () => ref.read(commandPaletteOpenProvider.notifier).state = true,
            ),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(PhosphorIconsRegular.bell),
                  onPressed: () => context.go(RouteNames.notifications),
                ),
                if (notifications > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          notifications > 9 ? '9+' : '$notifications',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
          ],
        ) : null,
        drawer: (isMobile && isTopLevel) ? _buildDrawer(context, isExpanded) : null,
        bottomNavigationBar: isMobile ? _buildBottomNavBar(context) : null,
        body: Stack(
          children: [
            Row(
              children: [
                if (!isMobile) _SidebarNav(
                  isExpanded: isTablet ? false : isExpanded,
                ),
                Expanded(
                  child: Column(
                    children: [
                      if (!isMobile) _TopBar(isMobile: isMobile),
                      Expanded(child: widget.child),
                    ],
                  ),
                ),
              ],
            ),
            // Command Palette overlay
            if (isCommandOpen)
              const CommandPalette(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, bool isExpanded) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: _SidebarNav(isExpanded: true),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    int currentIndex = 0;
    if (currentRoute.startsWith(RouteNames.authorizations) || currentRoute.startsWith(RouteNames.createAuthorization)) {
      currentIndex = 1;
    } else if (currentRoute.startsWith(RouteNames.aiDecisionCenter)) {
      currentIndex = 2;
    } else if (currentRoute.startsWith(RouteNames.profile) || currentRoute.startsWith(RouteNames.settings)) {
      currentIndex = 3;
    }

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (idx) {
        switch (idx) {
          case 0: context.go(RouteNames.dashboard); break;
          case 1: context.go(RouteNames.authorizations); break;
          case 2: context.go(RouteNames.aiDecisionCenter); break;
          case 3: context.go(RouteNames.profile); break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(PhosphorIconsRegular.squaresFour),
          selectedIcon: Icon(PhosphorIconsFill.squaresFour),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(PhosphorIconsRegular.clipboardText),
          selectedIcon: Icon(PhosphorIconsFill.clipboardText),
          label: 'Authorizations',
        ),
        NavigationDestination(
          icon: Icon(PhosphorIconsRegular.brain),
          selectedIcon: Icon(PhosphorIconsFill.brain),
          label: 'AI Decisions',
        ),
        NavigationDestination(
          icon: Icon(PhosphorIconsRegular.userCircle),
          selectedIcon: Icon(PhosphorIconsFill.userCircle),
          label: 'Profile',
        ),
      ],
    );
  }
}

// ─── Sidebar Navigation ───────────────────────────────────────────────────────
class _SidebarNav extends ConsumerWidget {
  final bool isExpanded;
  const _SidebarNav({required this.isExpanded});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final role = user?.role;
    final currentRoute = GoRouterState.of(context).matchedLocation;

    // Filter nav items by current user's permissions
    final visibleItems = _navItems.where((item) {
      if (item.requiredPermissions.isEmpty) return true;
      if (role == null) return false;
      return item.requireAny
          ? role.hasAnyPermission(item.requiredPermissions)
          : role.hasAllPermissions(item.requiredPermissions);
    }).toList();

    final isMobile = isMobileLayout(context);

    final content = Column(
      children: [
        // Logo area
        _SidebarLogo(isExpanded: isExpanded),
        const SizedBox(height: 8),

        // Search / Command bar
        if (isExpanded) _CommandBarButton(),
        if (!isExpanded) const SizedBox(height: 8),

        const Divider(height: 1),
        const SizedBox(height: 8),

        // Main nav items
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            itemCount: visibleItems.length,
            itemBuilder: (ctx, i) {
              final item = visibleItems[i];
              final isActive = currentRoute.startsWith(item.route);
              return _NavItemTile(
                item: item,
                isActive: isActive,
                isExpanded: isExpanded,
                onTap: () {
                  if (isMobile) Navigator.pop(context); // Close drawer
                  context.go(item.route);
                },
              );
            },
          ),
        ),

        // Bottom nav items (Settings, Profile)
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            children: _bottomNavItems.map((item) {
              final isActive = currentRoute.startsWith(item.route);
              return _NavItemTile(
                item: item,
                isActive: isActive,
                isExpanded: isExpanded,
                onTap: () {
                  if (isMobile) Navigator.pop(context); // Close drawer
                  context.go(item.route);
                },
              );
            }).toList(),
          ),
        ),

        // User info / Sign out
        if (isExpanded && user != null) _UserFooter(user: user),
        if (!isExpanded) _CollapsedUserFooter(),
      ],
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: AppConstants.animMedium),
      width: isExpanded
          ? AppConstants.sidebarExpandedWidth
          : AppConstants.sidebarCollapsedWidth,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        top: isMobile,
        bottom: false,
        child: content,
      ),
    );
  }
}

class _SidebarLogo extends StatelessWidget {
  final bool isExpanded;
  const _SidebarLogo({required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/priorx_logo.png',
            width: 36,
            height: 36,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.mockupTealLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_rounded, color: AppColors.mockupTeal, size: 22),
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'PriorX',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.mockupDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Prior Auth Platform',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CommandBarButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () => ref.read(commandPaletteOpenProvider.notifier).state = true,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(PhosphorIconsRegular.magnifyingGlass,
                  size: 16, color: AppColors.textTertiary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Search...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              if (!isMobileLayout(context))
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.neutral200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '⌘K',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItemTile extends StatelessWidget {
  final NavItem item;
  final bool isActive;
  final bool isExpanded;
  final VoidCallback onTap;

  const _NavItemTile({
    required this.item,
    required this.isActive,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Tooltip(
        message: isExpanded ? '' : item.label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? 12 : 0,
              vertical: isExpanded ? 10 : 0,
            ),
            width: isExpanded ? double.infinity : 40,
            height: isExpanded ? null : 40,
            decoration: BoxDecoration(
              color: isActive
                  ? (isExpanded ? AppColors.mockupTealLight : AppColors.mockupTeal)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: isExpanded
                ? Row(
                    children: [
                      Icon(
                        isActive ? item.activeIcon : item.icon,
                        size: 20,
                        color: isActive ? AppColors.mockupTeal : AppColors.neutral500,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.label,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isActive ? AppColors.mockupDark : AppColors.textSecondary,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Icon(
                      isActive ? item.activeIcon : item.icon,
                      size: 20,
                      color: isActive ? Colors.white : AppColors.neutral400,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _UserFooter extends ConsumerWidget {
  final dynamic user;
  const _UserFooter({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primarySurface,
            child: Text(
              user.initials,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user.role.displayName,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(PhosphorIconsRegular.signOut,
                size: 18, color: AppColors.neutral500),
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) context.go(RouteNames.login);
            },
            tooltip: 'Sign out',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

class _CollapsedUserFooter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.primarySurface,
        child: Text(
          user?.initials ?? '?',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ─── Top App Bar ──────────────────────────────────────────────────────────────
class _TopBar extends ConsumerWidget {
  final bool isMobile;
  const _TopBar({required this.isMobile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final notifications = ref.watch(unreadNotificationCountProvider);
    final routeState = GoRouterState.of(context);
    final pageTitle = _getTitleForRoute(routeState.matchedLocation);

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          if (!isMobile) ...[
            // Sidebar toggle
            Consumer(builder: (ctx, ref2, _) {
              final isExpanded = ref2.watch(sidebarExpandedProvider);
              return IconButton(
                icon: Icon(
                  isExpanded
                      ? PhosphorIconsRegular.sidebarSimple
                      : PhosphorIconsRegular.sidebarSimple,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => ref2
                    .read(sidebarExpandedProvider.notifier)
                    .state = !isExpanded,
                tooltip: isExpanded ? 'Collapse sidebar' : 'Expand sidebar',
              );
            }),
          ],
          const SizedBox(width: 8),
          Text(
            pageTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),

          // Role badge
          if (user != null) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: user.role.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Text(
                user.role.displayName,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: user.role.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],

          const Spacer(),

          // Command palette trigger
          TextButton.icon(
            onPressed: () =>
                ref.read(commandPaletteOpenProvider.notifier).state = true,
            icon: Icon(PhosphorIconsRegular.magnifyingGlass,
                size: 16, color: AppColors.textSecondary),
            label: Row(children: [
              Text('Search', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text('⌘K',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    )),
              ),
            ]),
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
          ),

          const SizedBox(width: 8),

          // Notifications bell
          Stack(
            children: [
              IconButton(
                icon: Icon(PhosphorIconsRegular.bell,
                    size: 22, color: AppColors.textSecondary),
                onPressed: () => context.go(RouteNames.notifications),
                tooltip: 'Notifications',
              ),
              if (notifications > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        notifications > 9 ? '9+' : '$notifications',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Admin Purge Supabase Data Button (Administrator only)
          if (user?.role == UserRole.administrator) ...[
            Tooltip(
              message: 'Purge All Supabase Data',
              child: IconButton(
                icon: const Icon(PhosphorIconsRegular.trash, size: 20, color: AppColors.error),
                onPressed: () => showAdminPurgeDialog(context),
              ),
            ),
            const SizedBox(width: 4),
          ],

          const SizedBox(width: 4),

          // Avatar
          if (user != null)
            GestureDetector(
              onTap: () => context.go(RouteNames.profile),
              child: CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.primarySurface,
                child: Text(
                  user.initials,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _getTitleForRoute(String route) {
  if (route.startsWith(RouteNames.dashboard))     return 'Dashboard';
  if (route.startsWith(RouteNames.patients))      return 'Patients';
  if (route.startsWith(RouteNames.doctors))       return 'Physicians';
  if (route.startsWith(RouteNames.createAuthorization)) return 'New Authorization';
  if (route.startsWith(RouteNames.authorizations)) return 'Prior Authorizations';
  if (route.startsWith(RouteNames.insuranceReview)) return 'Insurance Review';
  if (route.startsWith(RouteNames.aiDecisionCenter)) return 'AI Decision Center';
  if (route.startsWith(RouteNames.appeals))       return 'Appeals';
  if (route.startsWith(RouteNames.analytics))     return 'Analytics';
  if (route.startsWith(RouteNames.medicalRecords)) return 'Medical Records';
  if (route.startsWith(RouteNames.insuranceClaims)) return 'Insurance Claims';
  if (route.startsWith(RouteNames.auditLogs))     return 'Audit Logs';
  if (route.startsWith(RouteNames.accessControl)) return 'Access Control';
  if (route.startsWith(RouteNames.integrations))  return 'FHIR Integrations';
  if (route.startsWith(RouteNames.settings))      return 'Settings';
  if (route.startsWith(RouteNames.profile))       return 'Profile';
  if (route.startsWith(RouteNames.notifications)) return 'Notifications';
  return 'PriorX';
}

// ─── Unread notification count provider ──────────────────────────────────────
final unreadNotificationCountProvider = Provider<int>((ref) => 4);
