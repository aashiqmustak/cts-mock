import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';

// ─── Models ──────────────────────────────────────────────────────────────────
class TaskFlowProject {
  final String name;
  final double completion; // 0.0 to 1.0
  final int daysLeft;
  final Color color;
  final bool isActive;
  final bool isAtRisk;

  const TaskFlowProject({
    required this.name,
    required this.completion,
    required this.daysLeft,
    required this.color,
    this.isActive = true,
    this.isAtRisk = false,
  });
}

class ChatMessage {
  final String text;
  final bool isAi;
  final DateTime time;
  final Widget? customWidget;

  ChatMessage({
    required this.text,
    required this.isAi,
    required this.time,
    this.customWidget,
  });
}

// ─── Providers ───────────────────────────────────────────────────────────────
final taskFlowProjectsProvider = StateProvider<List<TaskFlowProject>>((ref) {
  return [
    const TaskFlowProject(
      name: 'Website Redesign',
      completion: 0.78,
      daysLeft: 70,
      color: Colors.black,
      isActive: true,
      isAtRisk: false,
    ),
    const TaskFlowProject(
      name: 'CRM Migration',
      completion: 0.45,
      daysLeft: 18,
      color: Color(0xFFF35F20), // Orange
      isActive: true,
      isAtRisk: true,
    ),
    const TaskFlowProject(
      name: 'Mobile App Launch',
      completion: 0.62,
      daysLeft: 45,
      color: Color(0xFFF35F20), // Orange
      isActive: true,
      isAtRisk: true,
    ),
    const TaskFlowProject(
      name: 'Marketing Campaign',
      completion: 0.96,
      daysLeft: 80,
      color: Color(0xFF555555), // Dark gray
      isActive: true,
      isAtRisk: false,
    ),
  ];
});

final activeFilterProvider = StateProvider<String>((ref) => 'All');

// ─── Main Screen Widget ────────────────────────────────────────────────────────
class TaskFlowScreen extends ConsumerStatefulWidget {
  const TaskFlowScreen({super.key});

  @override
  ConsumerState<TaskFlowScreen> createState() => _TaskFlowScreenState();
}

class _TaskFlowScreenState extends ConsumerState<TaskFlowScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  
  final List<ChatMessage> _chatMessages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    _chatMessages.add(
      ChatMessage(
        text: 'Hello Shafi! 👋\nI can help you monitor project progress, identify blockers, generate sprint summaries, and keep your team aligned across all active projects.',
        isAi: true,
        time: DateTime.now(),
      ),
    );
  }

  void _scrollChatToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    _chatController.clear();
    
    setState(() {
      _chatMessages.add(ChatMessage(
        text: text,
        isAi: false,
        time: DateTime.now(),
      ));
      _isTyping = true;
    });
    _scrollChatToBottom();

    // Simulated response delay
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      
      String aiResponse = '';
      final lowerText = text.toLowerCase();
      
      if (lowerText.contains('website') || lowerText.contains('redesign')) {
        aiResponse = 'The **Website Redesign** project is currently at **78% completion** and is on track. UI integration has finished, and we are starting client reviews next Monday.';
      } else if (lowerText.contains('crm') || lowerText.contains('migration')) {
        aiResponse = 'The **CRM Migration** is at **45% completion**. There is a minor blocker regarding legacy data encoding, which is why it is currently flagged as At Risk.';
      } else if (lowerText.contains('mobile') || lowerText.contains('launch') || lowerText.contains('app')) {
        aiResponse = 'The **Mobile App Launch** is at **62%**. We have 3 overdue tasks in sprint planning related to App Store guidelines. Review meeting is scheduled for today.';
      } else if (lowerText.contains('marketing') || lowerText.contains('campaign')) {
        aiResponse = 'The **Marketing Campaign** is nearly complete at **96%**. Landing pages and email flows are ready; we are just waiting for final compliance approval.';
      } else if (lowerText.contains('status') || lowerText.contains('health') || lowerText.contains('summary')) {
        aiResponse = 'Here is the summary:\n- Website Redesign: 78% (On Track)\n- CRM Migration: 45% (At Risk)\n- Mobile App Launch: 62% (At Risk)\n- Marketing Campaign: 96% (Completed soon)';
      } else {
        aiResponse = 'I\'ve checked our current workspaces. Let me know if you would like me to generate a progress summary, list overdue tasks, or contact team members.';
      }

      setState(() {
        _isTyping = false;
        _chatMessages.add(ChatMessage(
          text: aiResponse,
          isAi: true,
          time: DateTime.now(),
        ));
      });
      _scrollChatToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 1100;
    final isTablet = width > 768 && width <= 1100;
    
    return Scaffold(
      backgroundColor: const Color(0xFFE5EBF0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Stacked Background Cards Effect ──
              Positioned(
                top: -8,
                left: 12,
                right: 12,
                bottom: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              Positioned(
                top: -4,
                left: 6,
                right: 6,
                bottom: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              
              // ── Main UI Window Container ──
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Row(
                    children: [
                      // Sidebar Navigation (shown only on Desktop/Tablet)
                      if (!isTablet && isDesktop) 
                        _buildSidebar(context, isExpanded: true)
                      else if (isTablet)
                        _buildSidebar(context, isExpanded: false),
                      
                      // Dashboard Content Area
                      Expanded(
                        child: Container(
                          color: const Color(0xFFF3F6F9),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top header row
                              _buildHeader(context),
                              
                              // Main content scroll area
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // 4 Stat Cards Grid
                                      _buildStatsGrid(context),
                                      const SizedBox(height: 20),
                                      
                                      // Two Columns: AI Assistant & Project Overview
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          if (constraints.maxWidth > 900) {
                                            return Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(flex: 9, child: _buildAiAssistantCard(context)),
                                                const SizedBox(width: 20),
                                                Expanded(flex: 11, child: _buildProjectOverviewCard(context)),
                                              ],
                                            );
                                          } else {
                                            return Column(
                                              children: [
                                                _buildAiAssistantCard(context),
                                                const SizedBox(height: 20),
                                                _buildProjectOverviewCard(context),
                                              ],
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Sidebar Navigation Widget ──────────────────────────────────────────────
  Widget _buildSidebar(BuildContext context, {required bool isExpanded}) {
    return Container(
      width: isExpanded ? 240 : 72,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          // Logo Area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black12, width: 1),
                  ),
                  child: const Center(
                    child: Icon(
                      PhosphorIconsRegular.target,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 10),
                  const Text(
                    'TASK FLOW',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Navigation Menu Sections
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                if (isExpanded)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      'OVERVIEW',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.black38,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                
                // Dashboard (Selected)
                _buildSidebarTile(
                  icon: PhosphorIconsRegular.squaresFour,
                  label: 'Dashboard',
                  isSelected: true,
                  isExpanded: isExpanded,
                ),
                _buildSidebarTile(
                  icon: PhosphorIconsRegular.bell,
                  label: 'Notifications',
                  isExpanded: isExpanded,
                  badgeCount: 3,
                ),
                _buildSidebarTile(
                  icon: PhosphorIconsRegular.chartLineUp,
                  label: 'Insights',
                  isExpanded: isExpanded,
                ),
                
                const SizedBox(height: 16),
                if (isExpanded)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      'WORKSPACES',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.black38,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                
                // Projects group
                _buildSidebarTile(
                  icon: PhosphorIconsRegular.folder,
                  label: 'Projects',
                  isExpanded: isExpanded,
                  hasSubmenu: true,
                ),
                if (isExpanded) ...[
                  _buildSubmenuTile(label: 'Active Projects', dotColor: const Color(0xFF10B981)),
                  _buildSubmenuTile(label: 'Projects Done', dotColor: const Color(0xFF2563EB)),
                  _buildSubmenuTile(label: 'Projects On Hold', dotColor: const Color(0xFFF59E0B)),
                ],
                
                _buildSidebarTile(
                  icon: PhosphorIconsRegular.checkSquare,
                  label: 'Tasks',
                  isExpanded: isExpanded,
                ),
                _buildSidebarTile(
                  icon: PhosphorIconsRegular.calendar,
                  label: 'Timeline',
                  isExpanded: isExpanded,
                ),
                _buildSidebarTile(
                  icon: PhosphorIconsRegular.chartBar,
                  label: 'Analytics',
                  isExpanded: isExpanded,
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          
          // Return to MediAuth AI Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Tooltip(
              message: 'Return to healthcare dashboard',
              child: InkWell(
                onTap: () => context.go(RouteNames.dashboard),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
                    children: [
                      const Icon(PhosphorIconsRegular.arrowLeft, color: AppColors.primary, size: 16),
                      if (isExpanded) ...[
                        const SizedBox(width: 8),
                        const Text(
                          'Exit Preview',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // User profile footer
          _buildUserProfileFooter(isExpanded),
        ],
      ),
    );
  }

  Widget _buildSidebarTile({
    required IconData icon,
    required String label,
    bool isSelected = false,
    required bool isExpanded,
    int? badgeCount,
    bool hasSubmenu = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.black87,
                size: 20,
              ),
              if (isExpanded) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                if (badgeCount != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                if (hasSubmenu)
                  const Icon(
                    PhosphorIconsRegular.caretDown,
                    size: 12,
                    color: Colors.black45,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmenuTile({required String label, required Color dotColor}) {
    return Padding(
      padding: const EdgeInsets.only(left: 36, top: 4, bottom: 4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileFooter(bool isExpanded) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.amber,
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=80&auto=format&fit=crop&q=80'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(width: 8),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shafi Islam',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Project Lead',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black38,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(PhosphorIconsRegular.caretUpDown, size: 12, color: Colors.black38),
          ],
        ],
      ),
    );
  }

  // ─── Header Widget ──────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          
          final welcomeSection = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'GOOD MORNING, SHAFI!',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Organize work, monitor project health, and deliver milestones faster with a unified project workspace.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black38,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
          
          final actionsSection = Row(
            children: [
              // Search input
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for anything...',
                      hintStyle: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 13),
                      prefixIcon: Icon(PhosphorIconsRegular.magnifyingGlass, color: Colors.black.withOpacity(0.4), size: 18),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Create Task Button
              OutlinedButton(
                onPressed: () => _showCreateTaskDialog(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(0, 38),
                ),
                child: const Text('Create Task', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 10),
              
              // New Project Button
              ElevatedButton.icon(
                onPressed: () => _showCreateProjectDialog(context),
                icon: const Icon(PhosphorIconsRegular.plus, size: 14),
                label: const Text('New Project'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(0, 38),
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          );

          if (isWide) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(flex: 3, child: welcomeSection),
                const SizedBox(width: 24),
                Expanded(flex: 4, child: actionsSection),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                welcomeSection,
                const SizedBox(height: 16),
                actionsSection,
              ],
            );
          }
        },
      ),
    );
  }

  // ─── Stats Cards Grid ───────────────────────────────────────────────────────
  Widget _buildStatsGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 4;
        if (constraints.maxWidth < 600) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 1000) {
          crossAxisCount = 2;
        }
        
        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.6,
          children: [
            _buildStatCard(
              title: 'ACTIVE PROJECTS',
              value: '24',
              subtitle: '+12% vs last month',
              trend: '9.1%',
              isPositive: true,
              icon: PhosphorIconsRegular.folderSimple,
            ),
            _buildStatCard(
              title: 'OPEN TASKS',
              value: '186',
              subtitle: '-8% vs last week',
              trend: '-4.3%',
              isPositive: true,
              icon: PhosphorIconsRegular.checkSquare,
            ),
            _buildStatCard(
              title: 'TEAM MEMBERS',
              value: '32',
              subtitle: '+5 added recently',
              trend: '-4.3%',
              isPositive: true,
              icon: PhosphorIconsRegular.users,
            ),
            _buildStatCard(
              title: 'COMPLETION RATE',
              value: '94%',
              subtitle: '+4% improvement',
              trend: '-4.3%',
              isPositive: true,
              icon: PhosphorIconsRegular.chartLineUp,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required String trend,
    required bool isPositive,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(icon, size: 14, color: Colors.black45),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.black38,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const Icon(PhosphorIconsRegular.dotsThree, size: 18, color: Colors.black38),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              letterSpacing: -1.0,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black.withOpacity(0.4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F7ED),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? PhosphorIconsRegular.arrowUpRight : PhosphorIconsRegular.arrowDownRight,
                      size: 10,
                      color: const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trend.replaceAll('-', ''),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── AI Project Assistant Widget ───────────────────────────────────────────
  Widget _buildAiAssistantCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'AI PROJECT ASSISTANT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                'Online',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black.withOpacity(0.3),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: ListView.builder(
              controller: _chatScrollController,
              itemCount: _chatMessages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _chatMessages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                
                final msg = _chatMessages[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildChatBubble(msg),
                    if (index == 0) ...[
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            _sendMessage('Generate Weekly Report');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            minimumSize: const Size(0, 30),
                          ),
                          child: const Text('Generate Weekly Report', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildProjectInsightsList(),
                    ],
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  onSubmitted: _sendMessage,
                  decoration: InputDecoration(
                    hintText: 'Write a message...',
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.black54),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _sendMessage(_chatController.text),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      PhosphorIconsRegular.paperPlaneRight,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Container(
      margin: EdgeInsets.only(
        left: message.isAi ? 0 : 40,
        right: message.isAi ? 40 : 0,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: message.isAi ? const Color(0xFFF1F5F9) : Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: Radius.circular(message.isAi ? 0 : 12),
          bottomRight: Radius.circular(message.isAi ? 12 : 0),
        ),
      ),
      child: Text(
        message.text,
        style: TextStyle(
          fontSize: 12.5,
          color: message.isAi ? Colors.black87 : Colors.white,
          height: 1.4,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(right: 180, bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle)).animate(onPlay: (c) => c.repeat(reverse: true)).slideY(begin: 0, end: -0.5, duration: 300.ms),
          const SizedBox(width: 4),
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle)).animate(onPlay: (c) => c.repeat(reverse: true)).slideY(begin: 0, end: -0.5, delay: 100.ms, duration: 300.ms),
          const SizedBox(width: 4),
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle)).animate(onPlay: (c) => c.repeat(reverse: true)).slideY(begin: 0, end: -0.5, delay: 200.ms, duration: 300.ms),
        ],
      ),
    );
  }

  Widget _buildProjectInsightsList() {
    final insights = [
      ('Website Redesign is 78% complete and on track.', const Color(0xFF10B981)),
      ('Mobile App Launch has 3 overdue tasks requiring attention.', const Color(0xFFF59E0B)),
      ('Marketing Campaign reached 100% completion.', const Color(0xFFF35F20)),
      ('Team productivity increased by 9.1% compared to last week.', const Color(0xFF64748B)),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Project Insights',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          ...insights.map((insight) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: insight.$2,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    insight.$1,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ─── Project Overview Widget ───────────────────────────────────────────────
  Widget _buildProjectOverviewCard(BuildContext context) {
    final projects = ref.watch(taskFlowProjectsProvider);
    final selectedFilter = ref.watch(activeFilterProvider);
    
    final filteredProjects = projects.where((p) {
      if (selectedFilter == 'All') return true;
      if (selectedFilter == 'Active') return p.isActive && !p.isAtRisk;
      if (selectedFilter == 'At Risk') return p.isAtRisk;
      return true;
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PROJECT OVERVIEW',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Health status across all active initiatives',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black38,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              _buildFilterTabs(context),
            ],
          ),
          const SizedBox(height: 16),
          _buildPriorityBar(),
          const SizedBox(height: 16),
          Column(
            children: filteredProjects.map((project) => _buildProjectRow(project)).toList(),
          ),
          const SizedBox(height: 16),
          _buildStatusOverviewFooter(),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context) {
    final activeFilter = ref.watch(activeFilterProvider);
    final filters = ['All', 'Active', 'At Risk'];
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        children: filters.map((filter) {
          final isSelected = activeFilter == filter;
          return GestureDetector(
            onTap: () {
              ref.read(activeFilterProvider.notifier).state = filter;
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.black : Colors.black45,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriorityBar() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            height: 28,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(6),
                bottomLeft: Radius.circular(6),
              ),
            ),
            child: const Center(
              child: Text(
                '3 Critical',
                style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
        const SizedBox(width: 2),
        Expanded(
          flex: 11,
          child: Container(
            height: 28,
            color: const Color(0xFFF35F20),
            child: const Center(
              child: Text(
                '11 High Priority',
                style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
        const SizedBox(width: 2),
        Expanded(
          flex: 10,
          child: Container(
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFFE2E8F0),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(6),
                bottomRight: Radius.circular(6),
              ),
            ),
            child: const Center(
              child: Text(
                '10 Normal',
                style: TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectRow(TaskFlowProject project) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  project.name,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${(project.completion * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 7,
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 12,
                        color: const Color(0xFFE2E8F0),
                      ),
                    ),
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: project.completion,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 12,
                          color: project.color,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      child: Text(
                        '${project.daysLeft}d',
                        style: TextStyle(
                          fontSize: 8.5,
                          color: project.completion > 0.85 ? Colors.white : Colors.black45,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusOverviewFooter() {
    final statuses = [
      ('9 On Track', const Color(0xFFE2E8F0)),
      ('6 In Review', const Color(0xFFE2E8F0)),
      ('5 At Risk', const Color(0xFFFEE2E2)),
      ('4 Completed', const Color(0xFFE2E8F0)),
    ];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: statuses.map((status) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: status.$2,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status.$1,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Interaction Dialogs ───────────────────────────────────────────────────
  void _showCreateTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'e.g. Integrate Auth Service API',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = titleController.text.trim();
                if (text.isNotEmpty) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Task "$text" created successfully!'),
                      backgroundColor: Colors.black,
                    ),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateProjectDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Project'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Project Name',
                  hintText: 'e.g. Cloud Migration Phase 2',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = nameController.text.trim();
                if (text.isNotEmpty) {
                  ref.read(taskFlowProjectsProvider.notifier).update((state) => [
                    ...state,
                    TaskFlowProject(
                      name: text,
                      completion: 0.1,
                      daysLeft: 90,
                      color: const Color(0xFF2563EB),
                      isActive: true,
                    )
                  ]);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Project "$text" added to workspace!'),
                      backgroundColor: Colors.black,
                    ),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
