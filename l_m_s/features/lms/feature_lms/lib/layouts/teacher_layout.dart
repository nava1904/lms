import 'package:flutter/material.dart';

class TeacherLayout extends StatefulWidget {
  final String teacherName;
  final Widget child;

  const TeacherLayout({
    super.key,
    required this.teacherName,
    required this.child,
  });

  @override
  State<TeacherLayout> createState() => _TeacherLayoutState();
}

class _TeacherLayoutState extends State<TeacherLayout> {
  int _selectedMenuIndex = 0;
  final menuItems = [
    {'icon': Icons.home, 'label': 'Dashboard'},
    {'icon': Icons.book, 'label': 'My Courses'},
    {'icon': Icons.people, 'label': 'Students'},
    {'icon': Icons.assignment, 'label': 'Assignments'},
    {'icon': Icons.quiz, 'label': 'Tests'},
    {'icon': Icons.bar_chart, 'label': 'Reports'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Teacher Sidebar
          if (!isMobile)
            Container(
              width: 280,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Teacher Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.orange, Colors.red],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.person_outline, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Teacher',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Portal',
                              style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Colors.grey[200]),
                  // Menu Items
                  Expanded(
                    child: ListView.builder(
                      itemCount: menuItems.length,
                      itemBuilder: (context, index) {
                        final item = menuItems[index];
                        final isSelected = _selectedMenuIndex == index;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: Icon(
                              item['icon'] as IconData,
                              color: isSelected ? Colors.orange : Colors.grey[400],
                            ),
                            title: Text(
                              item['label'] as String,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                            selected: isSelected,
                            onTap: () {
                              setState(() => _selectedMenuIndex = index);
                            },
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            selectedTileColor: Colors.orange.withOpacity(0.05),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Navigation
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 32,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search courses, students...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=2'),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.teacherName,
                                  style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Teacher',
                                  style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600], fontSize: 9),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
