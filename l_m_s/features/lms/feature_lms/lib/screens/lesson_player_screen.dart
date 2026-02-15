import 'package:flutter/material.dart';

class LessonPlayerScreen extends StatefulWidget {
  final String lessonId;
  final String lessonTitle;
  final String chapterTitle;

  const LessonPlayerScreen({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
    required this.chapterTitle,
  });

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  bool _showPlaylist = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 1200;

    return Scaffold(
      backgroundColor: Colors.black,
      body: isDesktop ? _buildDesktopLayout(theme) : _buildMobileLayout(theme),
    );
  }

  Widget _buildDesktopLayout(ThemeData theme) {
    return Row(
      children: [
        // Video Player
        Expanded(
          flex: 3,
          child: _buildVideoPlayer(theme),
        ),
        // Playlist Sidebar
        if (_showPlaylist)
          Expanded(
            flex: 1,
            child: _buildPlaylistSidebar(theme),
          ),
      ],
    );
  }

  Widget _buildMobileLayout(ThemeData theme) {
    return _showPlaylist ? _buildPlaylistSidebar(theme) : _buildVideoPlayer(theme);
  }

  Widget _buildVideoPlayer(ThemeData theme) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // Video Player Area
          Container(
            color: Colors.black,
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1633356122544-f134324ef6db?w=1200&h=600&fit=crop',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
                const Icon(Icons.play_circle_fill, size: 80, color: Colors.white),
              ],
            ),
          ),
          // Lesson Info
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.chapterTitle, style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600])),
                            const SizedBox(height: 4),
                            Text(widget.lessonTitle, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(_showPlaylist ? Icons.playlist_add_check : Icons.playlist_add),
                        onPressed: () => setState(() => _showPlaylist = !_showPlaylist),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Lesson Content', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Text(
                    'In this lesson, we will explore the fundamental concepts of physics and how they apply to real-world scenarios. We will cover Newton\'s laws, motion, and energy conservation.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 20),
                  Text('Key Topics:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ..._buildKeyTopics(theme),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Mark as Complete'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.note_add),
                        label: const Text('Notes'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildKeyTopics(ThemeData theme) {
    final topics = ['Newton\'s First Law', 'Momentum and Impulse', 'Work and Energy', 'Power and Efficiency'];
    return topics
        .map((topic) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check, size: 18, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(topic, style: theme.textTheme.bodySmall),
                ],
              ),
            ))
        .toList();
  }

  Widget _buildPlaylistSidebar(ThemeData theme) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Playlist', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _showPlaylist = false)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 8,
              itemBuilder: (context, index) {
                return ListTile(
                  selected: index == 0,
                  leading: index == 0 ? const Icon(Icons.play_circle, color: Color(0xFF1A73E8)) : const Icon(Icons.videocam),
                  title: Text(
                    'Lesson ${index + 1}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: index == 0 ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text('15 min', style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600])),
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
