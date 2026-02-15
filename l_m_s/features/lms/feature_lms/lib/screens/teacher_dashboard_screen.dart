import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../sanity_client_helper.dart';
import 'chapter_management_screen.dart';
import 'student_analytics_screen.dart';

class TeacherDashboardScreen extends StatefulWidget {
  final String teacherName;
  final String teacherId;

  const TeacherDashboardScreen({
    super.key,
    required this.teacherName,
    required this.teacherId,
  });

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _subjects = [];
  bool _loading = true;
  final _subjectNameController = TextEditingController();
  String? _editingSubjectId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTeacherData();
  }

  Future<void> _loadTeacherData() async {
    try {
      final client = createLmsClient();
      // Fetch subjects for this teacher
      final res = await client.fetch(r'''*[_type == "subject"]{_id, title, classLevel}''');
      setState(() {
        _subjects = res.result as List<dynamic>? ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() { _loading = false; });
    }
  }

  Future<void> _addSubject() async {
    _subjectNameController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subject'),
        content: TextField(
          controller: _subjectNameController,
          decoration: const InputDecoration(hintText: 'Subject name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_subjectNameController.text.isNotEmpty) {
                Navigator.pop(context);
                await _createSubjectInSanity(_subjectNameController.text);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _createSubjectInSanity(String title) async {
    try {
      const projectId = 'w18438cu';
      const dataset = 'production';
      final token = dotenv.env['SANITY_TOKEN'];
      
      if (token == null || token.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sanity token not configured')),
          );
        }
        return;
      }

      final url = Uri.https('$projectId.api.sanity.io', '/v2023-05-30/data/mutate/$dataset');
      
      final body = jsonEncode({
        'mutations': [
          {
            'create': {
              '_type': 'subject',
              'title': title,
            }
          }
        ]
      });

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.post(url, body: body, headers: headers);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newSubject = data['results'][0]['document'];
        if (mounted) {
          setState(() {
            _subjects.add(newSubject);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subject added successfully!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteSubjectFromSanity(String subjectId, int index) async {
    try {
      const projectId = 'w18438cu';
      const dataset = 'production';
      final token = dotenv.env['SANITY_TOKEN'];
      
      if (token == null || token.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sanity token not configured')),
          );
        }
        return;
      }

      final url = Uri.https('$projectId.api.sanity.io', '/v2023-05-30/data/mutate/$dataset');
      
      final body = jsonEncode({
        'mutations': [
          {
            'delete': {
              '_id': subjectId,
            }
          }
        ]
      });

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.post(url, body: body, headers: headers);
      
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _subjects.removeAt(index);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subject deleted successfully!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete subject: $e')),
        );
      }
    }
  }

  Future<void> _editSubject(String subjectId, String currentTitle) async {
    _subjectNameController.text = currentTitle;
    _editingSubjectId = subjectId;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Subject'),
        content: TextField(
          controller: _subjectNameController,
          decoration: const InputDecoration(hintText: 'Subject name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateSubjectInSanity();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateSubjectInSanity() async {
    if (_subjectNameController.text.isEmpty || _editingSubjectId == null) return;
    
    try {
      const projectId = 'w18438cu';
      const dataset = 'production';
      final token = dotenv.env['SANITY_TOKEN'];
      
      if (token == null || token.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sanity token not configured')),
          );
        }
        return;
      }

      final url = Uri.https('$projectId.api.sanity.io', '/v2023-05-30/data/mutate/$dataset');
      
      final body = jsonEncode({
        'mutations': [
          {
            'patch': {
              '_id': _editingSubjectId,
              'set': {
                'title': _subjectNameController.text,
              }
            }
          }
        ]
      });

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.post(url, body: body, headers: headers);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedSubject = data['results'][0]['document'];
        
        if (mounted) {
          setState(() {
            final index = _subjects.indexWhere((s) => s['_id'] == _editingSubjectId);
            if (index != -1) {
              _subjects[index] = updatedSubject;
            }
            _editingSubjectId = null;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subject updated successfully!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update subject: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subjectNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Teacher Dashboard - ${widget.teacherName}',
          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Subjects'),
            Tab(text: 'Content'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            onPressed: () => GoRouter.of(context).go('/'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: My Subjects
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Your Subjects', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        ElevatedButton.icon(
                          onPressed: _addSubject,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Subject'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_subjects.isEmpty)
                      Card(
                        elevation: 0,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              'No subjects assigned yet',
                              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                            ),
                          ),
                        ),
                      )
                    else
                      ...List.generate(_subjects.length, (index) {
                        return Card(
                          elevation: 0,
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(Icons.subject, color: theme.colorScheme.primary),
                            title: Text(_subjects[index]['title'] ?? 'Subject'),
                            subtitle: Text('Class: ${_subjects[index]['classLevel'] ?? '-'}'),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChapterManagementScreen(
                                          subjectId: _subjects[index]['_id'],
                                          subjectTitle: _subjects[index]['title'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Manage Chapters'),
                                ),
                                PopupMenuItem(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => StudentAnalyticsScreen(
                                          subjectId: _subjects[index]['_id'],
                                          subjectTitle: _subjects[index]['title'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('View Analytics'),
                                ),
                                PopupMenuItem(
                                  onTap: () {
                                    _editSubject(_subjects[index]['_id'], _subjects[index]['title']);
                                  },
                                  child: const Text('Edit'),
                                ),
                                PopupMenuItem(
                                  onTap: () {
                                    _deleteSubjectFromSanity(_subjects[index]['_id'], index);
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChapterManagementScreen(
                                    subjectId: _subjects[index]['_id'],
                                    subjectTitle: _subjects[index]['title'],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                  ],
                ),
                // Tab 2: Content Management
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('Add Content', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    // Content Type Cards
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      children: [
                        _ContentTypeCard(
                          icon: Icons.video_library,
                          title: 'Video',
                          onTap: () {
                            // TODO: Show video upload dialog
                          },
                        ),
                        _ContentTypeCard(
                          icon: Icons.description,
                          title: 'Document',
                          onTap: () {
                            // TODO: Show document upload dialog
                          },
                        ),
                        _ContentTypeCard(
                          icon: Icons.text_fields,
                          title: 'Text Content',
                          onTap: () {
                            // TODO: Show rich text editor
                          },
                        ),
                        _ContentTypeCard(
                          icon: Icons.help,
                          title: 'Question',
                          onTap: () {
                            // TODO: Show question creation dialog
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _ContentTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ContentTypeCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(title, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
