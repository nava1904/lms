import 'package:flutter/material.dart';

class AdminLayout extends StatefulWidget {
  final String adminName;
  final Widget child;

  const AdminLayout({
    super.key,
    required this.adminName,
    required this.child,
  });

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int _selectedMenuIndex = 0;
  final menuItems = [
    {'icon': Icons.home, 'label': 'Dashboard', 'color': Colors.blue},
    {'icon': Icons.people, 'label': 'Users', 'color': Colors.green},
    {'icon': Icons.book, 'label': 'Courses', 'color': Colors.orange},
    {'icon': Icons.file_copy, 'label': 'Documents', 'color': Colors.purple},
    {'icon': Icons.calendar_today, 'label': 'Scheduling', 'color': Colors.red},
    {'icon': Icons.bar_chart, 'label': 'Analytics', 'color': Colors.indigo},
    {'icon': Icons.settings, 'label': 'Settings', 'color': Colors.grey},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Admin Sidebar
          if (!isMobile)
            Container(
              width: 280,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Admin Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A73E8).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.admin_panel_settings, color: Color(0xFF1A73E8)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Admin Panel',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
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
                              color: isSelected ? item['color'] as Color : Colors.grey[400],
                            ),
                            title: Text(
                              item['label'] as String,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected ? Colors.black87 : Colors.grey[600],
                              ),
                            ),
                            selected: isSelected,
                            onTap: () {
                              setState(() => _selectedMenuIndex = index);
                            },
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            selectedTileColor: const Color(0xFF1A73E8).withOpacity(0.05),
                          ),
                        );
                      },
                    ),
                  ),
                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                        backgroundColor: Colors.red.withOpacity(0.1),
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
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
                        )
                      else
                        const SizedBox(),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search anything...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Row(
                        children: [
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
                                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.adminName,
                                      style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      'Admin',
                                      style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600], fontSize: 9),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Content Area
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
