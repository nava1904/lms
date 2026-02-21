import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../stores/dashboard_store.dart';
import '../theme/lms_theme.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/professional_course_card.dart';

class DashboardScreen extends StatefulWidget {
  final String studentName;
  final String rollNumber;
  final String studentId;

  const DashboardScreen({
    super.key,
    required this.studentName,
    required this.rollNumber,
    required this.studentId,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardStore _store = DashboardStore();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _store.loadDashboard(widget.studentId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Observer(
      builder: (_) {
        if (_store.loading) return const Center(child: CircularProgressIndicator());
        if (_store.error != null) {
          return EmptyStateWidget(
            icon: Icons.error_outline,
            title: _store.error!,
            subtitle: 'Pull down or tap Retry to try again.',
            ctaLabel: 'Retry',
            onCtaPressed: () => _store.loadDashboard(widget.studentId),
          );
        }
        return _buildBody(theme);
      },
    );
  }

  Future<void> _loadData() async {
    await _store.loadDashboard(widget.studentId);
  }

  Widget _buildBody(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(theme),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickStats(theme),
                  const SizedBox(height: 24),
                  Text(
                    'Explore Courses',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildCoursesGrid(theme),
                  const SizedBox(height: 24),
                  Text(
                    'Your Subjects',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  _buildSubjectsGrid(theme),
                  const SizedBox(height: 24),
                  Text(
                    'Upcoming Tests',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  _buildUpcomingTests(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Professional EdTech v2 hero: gradient EFF6FF → white, "Unlock Your Potential", search bar.
  Widget _buildHero(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [LMSTheme.gradientStart, Colors.white],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unlock Your Potential',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
              color: LMSTheme.onSurfaceColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Explore thousands of courses and master new skills with expert instructors',
            style: theme.textTheme.bodyLarge?.copyWith(color: LMSTheme.mutedForeground),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for courses, skills, or topics...',
                    hintStyle: TextStyle(color: LMSTheme.mutedForeground, fontSize: 16),
                    prefixIcon: Icon(Icons.search, color: LMSTheme.mutedForeground, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: const BorderSide(color: LMSTheme.borderColor, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: LMSTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                  ),
                  child: const Text('Go'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesGrid(ThemeData theme) {
    final courses = _store.enrolledCourses;
    if (courses.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: EmptyStateWidget(
            icon: Icons.menu_book_outlined,
            title: 'No courses yet',
            subtitle: 'You have not enrolled in any courses.',
            ctaLabel: 'Refresh',
            onCtaPressed: () => _store.loadDashboard(widget.studentId),
          ),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return ProfessionalCourseCard(
          title: course.title,
          category: course.level ?? 'Course',
          thumbnailUrl: course.thumbnailUrl,
          rating: 0,
          tags: [],
          features: [],
          progress: _store.currentCourseProgress,
          onTap: () => context.go('/content', extra: {'courseId': course.id}),
        );
      },
    );
  }

  /// Professional EdTech v2 stats row: white cards, icon in colored circle, value + label.
  Widget _buildQuickStats(ThemeData theme) {
    final count = _store.enrolledCount;
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 600 ? 3 : 1;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossCount,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          childAspectRatio: 2.2,
          children: [
            _buildStatCard(theme, 'Hours Spent', '${count * 12}h', Icons.schedule, const Color(0xFFEFF6FF)),
            _buildStatCard(theme, 'Test Score', '${(_store.currentCourseProgress * 100).toInt()}%', Icons.track_changes, const Color(0xFFECFDF5)),
            _buildStatCard(theme, 'Active Courses', '$count', Icons.menu_book, const Color(0xFFF5F3FF)),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color iconBgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(LMSTheme.radiusMd),
        border: Border.all(color: LMSTheme.borderColor),
        boxShadow: LMSTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: LMSTheme.primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Outfit',
                  color: LMSTheme.onSurfaceColor,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(color: LMSTheme.mutedForeground),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsGrid(ThemeData theme) {
    final courses = _store.enrolledCourses;
    if (courses.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No subjects available',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return _buildSubjectCard(theme, course);
      },
    );
  }

  Widget _buildSubjectCard(ThemeData theme, Course course) {
    const color = LMSTheme.primaryColor;
    final subjectLabel = course.subjectIds != null && course.subjectIds!.isNotEmpty
        ? '${course.subjectIds!.length} subjects'
        : 'Course';

    return Card(
      child: InkWell(
        onTap: () => context.go('/content', extra: {'courseId': course.id}),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.book, color: color),
              ),
              const Spacer(),
              Text(
                course.title,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subjectLabel,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoursesSection(ThemeData theme) {
    if (_store.enrolledCourses.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No courses available',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    final courses = _store.enrolledCourses;
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return _buildCourseCard(theme, course.title, course.id, course.thumbnailUrl);
        },
      ),
    );
  }

  Widget _buildCourseCard(ThemeData theme, String title, String id, String? thumbnailUrl) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        child: InkWell(
          onTap: () => context.go('/content', extra: {'courseId': id}),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: LMSTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.play_circle, color: LMSTheme.primaryColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Tap to open',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                LinearProgressIndicator(
                  value: _store.currentCourseProgress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(LMSTheme.primaryColor),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(_store.currentCourseProgress * 100).toInt()}% Complete',
                  style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingTests(ThemeData theme) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: LMSTheme.warningColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.assignment, color: Colors.orange),
        ),
        title: const Text('Physics Unit Test'),
        subtitle: const Text('Tomorrow at 10:00 AM'),
        trailing: ElevatedButton(
          onPressed: () => context.go('/tests'),
          child: const Text('View'),
        ),
      ),
    );
  }

}
