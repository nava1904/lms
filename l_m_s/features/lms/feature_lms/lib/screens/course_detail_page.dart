import 'package:flutter/material.dart';

class CourseDetailPage extends StatefulWidget {
  final String courseId;
  final String courseName;

  const CourseDetailPage({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FA),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1633356122544-f134324ef6db?w=1200&h=400&fit=crop',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            // Course Info
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.courseName,
                              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 16, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text('4.8 (125 reviews)', style: theme.textTheme.labelSmall),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.bookmark),
                        label: const Text('Save'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatChip(theme, '12', 'Chapters'),
                      _buildStatChip(theme, '48', 'Lessons'),
                      _buildStatChip(theme, '2.5K', 'Students'),
                      _buildStatChip(theme, '120h', 'Duration'),
                    ],
                  ),
                ],
              ),
            ),
            // Tabs
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Curriculum'),
                Tab(text: 'Instructor'),
                Tab(text: 'Reviews'),
                Tab(text: 'FAQs'),
              ],
            ),
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCurriculumTab(theme),
                  _buildInstructorTab(theme),
                  _buildReviewsTab(theme),
                  _buildFAQsTab(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(ThemeData theme, String value, String label) {
    return Column(
      children: [
        Text(value, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF1A73E8))),
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildCurriculumTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildChapterCard(theme, 'Chapter 1: Basics', '12 lessons', 0.8),
        _buildChapterCard(theme, 'Chapter 2: Advanced', '14 lessons', 0.5),
        _buildChapterCard(theme, 'Chapter 3: Expert Level', '16 lessons', 0.2),
      ],
    );
  }

  Widget _buildChapterCard(ThemeData theme, String title, String lessons, double progress) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      child: ExpansionTile(
        title: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(lessons, style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600])),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLessonItem(theme, 'Lesson 1: Introduction', '15 min', true),
                _buildLessonItem(theme, 'Lesson 2: Concepts', '25 min', true),
                _buildLessonItem(theme, 'Lesson 3: Examples', '20 min', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonItem(ThemeData theme, String title, String duration, bool completed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.play_circle_outline,
            size: 20,
            color: completed ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
                Text(duration, style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600])),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildInstructorTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Prof. Amit Kumar', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                          Text('Physics Expert', style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600])),
                          Text('15+ years experience', style: theme.textTheme.labelSmall?.copyWith(color: const Color(0xFF1A73E8))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'About',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Prof. Amit Kumar is a renowned Physics educator with 15+ years of experience teaching JEE and NEET aspirants. He has trained over 10,000 students who have successfully cleared competitive exams.',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=2'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Rahul Singh', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
                          Row(
                            children: List.generate(5, (i) => const Icon(Icons.star, size: 14, color: Colors.amber)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Excellent course! Prof. Amit explains concepts very clearly. The examples and practice problems are very helpful.',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFAQsTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          color: Colors.white,
          child: ExpansionTile(
            title: Text('Do I need prior physics knowledge?', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No, this course is designed for beginners. We start from the basics and gradually move to advanced topics.',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: Colors.white,
          child: ExpansionTile(
            title: Text('Is there a certificate upon completion?', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Yes, you will receive a certificate of completion after finishing all chapters and passing the final test.',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
