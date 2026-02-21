import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../stores/dashboard_store.dart';
import '../theme/lms_theme.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/professional_course_card.dart';

/// My Courses: courses-focused view with grid of enrolled courses.
class StudentCoursesScreen extends StatefulWidget {
  final String studentId;

  const StudentCoursesScreen({super.key, required this.studentId});

  @override
  State<StudentCoursesScreen> createState() => _StudentCoursesScreenState();
}

class _StudentCoursesScreenState extends State<StudentCoursesScreen> {
  final DashboardStore _store = DashboardStore();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _store.loadDashboard(widget.studentId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Course> get _filteredCourses {
    final courses = _store.enrolledCourses;
    if (_searchQuery.isEmpty) return courses;
    final q = _searchQuery.toLowerCase();
    return courses.where((c) {
      final title = (c.title).toLowerCase();
      final level = (c.level ?? '').toLowerCase();
      return title.contains(q) || level.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Observer(
      builder: (_) {
        if (_store.loading) {
          return const Center(child: CircularProgressIndicator(color: LMSTheme.primaryColor));
        }
        if (_store.error != null) {
          return EmptyStateWidget(
            icon: Icons.error_outline,
            title: _store.error!,
            subtitle: 'Pull down or tap Retry to try again.',
            ctaLabel: 'Retry',
            onCtaPressed: () => _store.loadDashboard(widget.studentId),
          );
        }
        return RefreshIndicator(
          onRefresh: () => _store.loadDashboard(widget.studentId),
          color: LMSTheme.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Courses',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                    color: LMSTheme.onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your enrolled courses and progress',
                  style: theme.textTheme.bodyLarge?.copyWith(color: LMSTheme.mutedForeground),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (_) => setState(() => _searchQuery = _searchController.text.trim()),
                        decoration: InputDecoration(
                          hintText: 'Search courses...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: LMSTheme.borderColor),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => setState(() => _searchQuery = _searchController.text.trim()),
                      child: const Text('Search'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildCoursesGrid(theme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCoursesGrid(ThemeData theme) {
    final courses = _filteredCourses;
    if (courses.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: EmptyStateWidget(
            icon: Icons.menu_book_outlined,
            title: _searchQuery.isEmpty ? 'No courses yet' : 'No matching courses',
            subtitle: _searchQuery.isEmpty
                ? 'You have not enrolled in any courses.'
                : 'Try a different search term.',
            ctaLabel: _searchQuery.isEmpty ? 'Refresh' : 'Clear search',
            onCtaPressed: () {
              if (_searchQuery.isNotEmpty) {
                _searchController.clear();
                setState(() => _searchQuery = '');
              } else {
                _store.loadDashboard(widget.studentId);
              }
            },
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
}
