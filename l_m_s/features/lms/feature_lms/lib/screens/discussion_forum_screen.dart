import 'package:flutter/material.dart';

class DiscussionForumScreen extends StatefulWidget {
  final String courseId;

  const DiscussionForumScreen({
    super.key,
    required this.courseId,
  });

  @override
  State<DiscussionForumScreen> createState() => _DiscussionForumScreenState();
}

class _DiscussionForumScreenState extends State<DiscussionForumScreen> {
  final _searchController = TextEditingController();
  String _sortBy = 'Latest';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('Discussions', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search discussions...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Wrap(
                      spacing: 8,
                      children: ['Doubt', 'Resource', 'Discussion'].map((tag) {
                        return Chip(label: Text(tag));
                      }).toList(),
                    ),
                    DropdownButton<String>(
                      value: _sortBy,
                      items: ['Latest', 'Popular', 'Unanswered'].map((String value) {
                        return DropdownMenuItem(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (value) => setState(() => _sortBy = value!),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Discussions List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildDiscussionThread(
                  theme,
                  'How to solve this differential equation?',
                  'Rahul Singh',
                  '2 hours ago',
                  'This is a challenging problem from the assignment...',
                  5,
                  isPinned: true,
                ),
                _buildDiscussionThread(
                  theme,
                  'Anyone have the lecture notes from Chapter 5?',
                  'Priya Kumar',
                  '5 hours ago',
                  'I missed the class, can someone share the notes?',
                  12,
                  hasAnswer: true,
                ),
                _buildDiscussionThread(
                  theme,
                  'Practice problems solutions',
                  'Prof. Amit Kumar',
                  '1 day ago',
                  'Here are the complete solutions for practice set 3...',
                  24,
                  isTeacher: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscussionThread(
    ThemeData theme,
    String title,
    String author,
    String time,
    String content,
    int replies, {
    bool isPinned = false,
    bool hasAnswer = false,
    bool isTeacher = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=${title.hashCode % 50}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              author,
                              style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (isTeacher)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Teacher',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(time, style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600])),
                    ],
                  ),
                ),
                if (isPinned) const Icon(Icons.push_pin, size: 16, color: Colors.orange),
              ],
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            // Content Preview
            Text(
              content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (hasAnswer)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, size: 12, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              'Answered',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (!hasAnswer)
                      Icon(Icons.comment_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '$replies replies',
                        style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
                      ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.thumb_up_outlined, size: 18),
                      onPressed: () {},
                      splashRadius: 20,
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined, size: 18),
                      onPressed: () {},
                      splashRadius: 20,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
