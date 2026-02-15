import 'package:flutter/material.dart';

class EnhancedDashboardLayout extends StatefulWidget {
  final String userName;
  final String userRole; // 'student', 'teacher', 'admin'
  final Widget child;

  const EnhancedDashboardLayout({
    super.key,
    required this.userName,
    required this.userRole,
    required this.child,
  });

  @override
  State<EnhancedDashboardLayout> createState() => _EnhancedDashboardLayoutState();
}

class _EnhancedDashboardLayoutState extends State<EnhancedDashboardLayout> {
  bool _sidebarExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Sidebar
          if (!isMobile)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _sidebarExpanded ? 280 : 80,
              color: Colors.white,
              child: _buildSidebar(theme),
            ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Navigation Bar
                _buildTopNavBar(theme, isMobile),
                // Main Content Area
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(ThemeData theme) {
    final menuItems = _getMenuItemsByRole(widget.userRole);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1A73E8),
                        const Color(0xFF8B5CF6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.school, color: Colors.white),
                ),
                if (_sidebarExpanded) ...[
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EduLearn',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'LMS Platform',
                        style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Divider(color: Colors.grey[200]),
          // Menu Items
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: menuItems.map((item) {
                return _buildMenuItemTile(theme, item['icon'], item['label'], item['route']);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemTile(ThemeData theme, IconData icon, String label, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1A73E8)),
        title: _sidebarExpanded ? Text(label, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w500)) : null,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Navigate to $label')),
          );
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        hoverColor: const Color(0xFF1A73E8).withOpacity(0.05),
      ),
    );
  }

  Widget _buildTopNavBar(ThemeData theme, bool isMobile) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {},
            ),
          Row(
            children: [
              Icon(Icons.search, color: Colors.grey[400], size: 20),
              const SizedBox(width: 8),
              SizedBox(
                width: 200,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search courses, tests...',
                    border: InputBorder.none,
                    hintStyle: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[400]),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: Colors.grey[600]),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.help_outline, color: Colors.grey[600]),
                onPressed: () {},
              ),
              const SizedBox(width: 16),
              // User Profile
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'),
                    ),
                    const SizedBox(width: 8),
                    if (!isMobile)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.userName,
                            style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            widget.userRole.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(width: 8),
                    Icon(Icons.expand_more, color: Colors.grey[600], size: 18),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMenuItemsByRole(String role) {
    switch (role) {
      case 'student':
        return [
          {'icon': Icons.home, 'label': 'Dashboard', 'route': '/dashboard'},
          {'icon': Icons.book, 'label': 'My Courses', 'route': '/courses'},
          {'icon': Icons.assignment, 'label': 'Assignments', 'route': '/assignments'},
          {'icon': Icons.quiz, 'label': 'Tests', 'route': '/tests'},
          {'icon': Icons.bar_chart, 'label': 'Analytics', 'route': '/analytics'},
          {'icon': Icons.question_answer, 'label': 'Q&A Forum', 'route': '/forum'},
          {'icon': Icons.settings, 'label': 'Settings', 'route': '/settings'},
        ];
      case 'teacher':
        return [
          {'icon': Icons.home, 'label': 'Dashboard', 'route': '/teacher/dashboard'},
          {'icon': Icons.book, 'label': 'My Courses', 'route': '/teacher/courses'},
          {'icon': Icons.people, 'label': 'Students', 'route': '/teacher/students'},
          {'icon': Icons.assignment, 'label': 'Assignments', 'route': '/teacher/assignments'},
          {'icon': Icons.quiz, 'label': 'Tests', 'route': '/teacher/tests'},
          {'icon': Icons.bar_chart, 'label': 'Reports', 'route': '/teacher/reports'},
          {'icon': Icons.settings, 'label': 'Settings', 'route': '/settings'},
        ];
      case 'admin':
        return [
          {'icon': Icons.home, 'label': 'Dashboard', 'route': '/admin/dashboard'},
          {'icon': Icons.people, 'label': 'Users', 'route': '/admin/users'},
          {'icon': Icons.book, 'label': 'Courses', 'route': '/admin/courses'},
          {'icon': Icons.assignment, 'label': 'Documents', 'route': '/admin/documents'},
          {'icon': Icons.calendar_today, 'label': 'Scheduling', 'route': '/admin/scheduling'},
          {'icon': Icons.bar_chart, 'label': 'Analytics', 'route': '/admin/analytics'},
          {'icon': Icons.settings, 'label': 'Settings', 'route': '/settings'},
        ];
      default:
        return [];
    }
  }
}
