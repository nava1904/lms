import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../core/current_admin_holder.dart';
import '../models/test_attempt.dart';
import '../services/lms_sanity_service.dart';
import '../services/sanity_service.dart';
import '../stores/admin_dashboard_store.dart';
import '../stores/analytics_store.dart';
import '../theme/lms_theme.dart';
import '../sanity_client_helper.dart';
import '../utils/sanity_image_uploader.dart';

/// Zimyo-style admin dashboard: enrollments, teachers, fees snapshot;
/// teacher management, student onboarding, banner management, document management, export report.
class AdminDashboardScreen extends StatefulWidget {
  final String adminId;
  final String adminName;
  final String adminEmail;
  final String adminRole;
  final int? initialTabIndex;

  const AdminDashboardScreen({
    super.key,
    required this.adminId,
    required this.adminName,
    required this.adminEmail,
    required this.adminRole,
    this.initialTabIndex,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  final AdminDashboardStore _store = AdminDashboardStore();
  final AnalyticsStore _analyticsStore = AnalyticsStore();
  late TabController _tabController;

  final SanityService _sanityService = SanityService();
  final LmsSanityService _lmsService = LmsSanityService();

  @override
  void initState() {
    super.initState();
    final initial = widget.initialTabIndex != null && widget.initialTabIndex! >= 0 && widget.initialTabIndex! < 5
        ? widget.initialTabIndex!
        : 0;
    _tabController = TabController(length: 5, vsync: this, initialIndex: initial);
    _tabController.addListener(_onTabChanged);
    _store.loadDashboardStats();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging && mounted) {
      final id = CurrentAdminHolder.adminId ?? '';
      if (id.isNotEmpty) {
        context.go('/admin-dashboard?tab=${_tabController.index}', extra: {
          'adminId': id,
          'adminName': CurrentAdminHolder.adminName ?? 'Admin',
          'adminEmail': CurrentAdminHolder.adminEmail ?? '',
          'adminRole': CurrentAdminHolder.adminRole ?? 'admin',
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LMSTheme.surfaceColor,
      appBar: AppBar(
        title: Text('Admin Dashboard', style: TextStyle(color: LMSTheme.onSurfaceColor, fontWeight: FontWeight.w600)),
        backgroundColor: LMSTheme.surfaceColor,
        foregroundColor: LMSTheme.onSurfaceColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: LMSTheme.primaryColor,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Teachers'),
            Tab(text: 'Students'),
            Tab(text: 'Banners'),
            Tab(text: 'Documents'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildTeachersTab(),
          _buildStudentsTab(),
          _buildBannersTab(),
          _buildDocumentsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Observer(
      builder: (_) {
        if (_store.loading && _store.totalStudents == 0 && _store.totalTeachers == 0) {
          return const Center(child: CircularProgressIndicator(color: LMSTheme.primaryColor));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_store.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(_store.error!, style: TextStyle(color: LMSTheme.errorColor)),
                ),
              Text('Institute snapshot', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _MetricCard(title: 'Total students', value: '${_store.totalStudents}', icon: Icons.school, color: LMSTheme.primaryColor)),
                  const SizedBox(width: 16),
                  Expanded(child: _MetricCard(title: 'Active teachers', value: '${_store.totalTeachers}', icon: Icons.person, color: LMSTheme.successColor)),
                  const SizedBox(width: 16),
                  Expanded(child: _MetricCard(title: 'Active enrollments', value: '${_store.activeEnrollments}', icon: Icons.how_to_reg, color: LMSTheme.warningColor)),
                ],
              ),
              const SizedBox(height: 32),
              Text('Monthly performance report', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _exportReport,
                icon: const Icon(Icons.download),
                label: const Text('Export report (test attempts aggregate)'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTeachersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Teacher management', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              FilledButton.icon(
                onPressed: _showAddTeacherDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add teacher'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Create teacher profiles, assign specialization (e.g. Physics), link to batches.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  void _showAddTeacherDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final specializationController = TextEditingController();
    final qualificationController = TextEditingController();
    final bioController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Teacher'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name *'), textCapitalization: TextCapitalization.words),
                const SizedBox(height: 12),
                TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email *'), keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                TextField(controller: specializationController, decoration: const InputDecoration(labelText: 'Specialization (e.g. Physics)')),
                const SizedBox(height: 12),
                TextField(controller: qualificationController, decoration: const InputDecoration(labelText: 'Qualification')),
                const SizedBox(height: 12),
                TextField(controller: bioController, decoration: const InputDecoration(labelText: 'Bio'), maxLines: 3),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final email = emailController.text.trim();
              if (name.isEmpty || email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name and email are required')));
                return;
              }
              Navigator.pop(ctx);
              final result = await _sanityService.createTeacher(
                name: name,
                email: email,
                phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                specialization: specializationController.text.trim().isEmpty ? null : specializationController.text.trim(),
                qualification: qualificationController.text.trim().isEmpty ? null : qualificationController.text.trim(),
                bio: bioController.text.trim().isEmpty ? null : bioController.text.trim(),
              );
              if (mounted) {
                if (result != null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Teacher created successfully')));
                  _store.loadDashboardStats();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create teacher. ${lastMutationError ?? "Check Sanity token."}')));
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Student onboarding', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              FilledButton.icon(
                onPressed: _showBulkAddStudentsDialog,
                icon: const Icon(Icons.add),
                label: const Text('Bulk add students'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Bulk create students with unique roll numbers (e.g. ROLL001, ROLL002).', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  void _showBulkAddStudentsDialog() {
    final rows = <_StudentRowData>[
      _StudentRowData(TextEditingController(), TextEditingController(), TextEditingController()),
      _StudentRowData(TextEditingController(), TextEditingController(), TextEditingController()),
      _StudentRowData(TextEditingController(), TextEditingController(), TextEditingController()),
    ];
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Bulk Add Students'),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...rows.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(child: TextField(controller: e.value.nameController, decoration: const InputDecoration(labelText: 'Name', hintText: 'Student name'))),
                          const SizedBox(width: 8),
                          Expanded(child: TextField(controller: e.value.emailController, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress)),
                          const SizedBox(width: 8),
                          SizedBox(width: 100, child: TextField(controller: e.value.rollController, decoration: const InputDecoration(labelText: 'Roll'))),
                          if (rows.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                rows.remove(e.value);
                                setDialogState(() {});
                              },
                            ),
                        ],
                      ),
                    )),
                    TextButton.icon(
                      onPressed: () {
                        rows.add(_StudentRowData(TextEditingController(), TextEditingController(), TextEditingController()));
                        setDialogState(() {});
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add row'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              FilledButton(
                onPressed: () async {
                  final toCreate = <Map<String, String>>[];
                  for (final r in rows) {
                    final name = r.nameController.text.trim();
                    final email = r.emailController.text.trim();
                    var roll = r.rollController.text.trim();
                    if (name.isEmpty && email.isEmpty && roll.isEmpty) continue;
                    if (name.isEmpty || email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name and email are required for each student')));
                      return;
                    }
                    if (roll.isEmpty) roll = 'STU${DateTime.now().millisecondsSinceEpoch + toCreate.length}';
                    toCreate.add({'name': name, 'email': email, 'roll': roll});
                  }
                  if (toCreate.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least one student')));
                    return;
                  }
                  Navigator.pop(ctx);
                  var created = 0;
                  for (final s in toCreate) {
                    final result = await _sanityService.createStudent(
                      name: s['name']!,
                      email: s['email']!,
                      rollNumber: s['roll']!,
                    );
                    if (result != null) created++;
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Created $created of ${toCreate.length} students')));
                    _store.loadDashboardStats();
                  }
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBannersTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _lmsService.getAllAdBanners(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: LMSTheme.primaryColor));
        }
        final banners = snapshot.data ?? [];
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Marketing banners', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                  FilledButton.icon(
                    onPressed: () => _showAddBannerDialog(onCreated: () => setState(() {})),
                    icon: const Icon(Icons.add),
                    label: const Text('Add banner'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Create text and image banners for the login screen (e.g. New Scholarship Batch).', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 24),
              if (banners.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.campaign_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text('No banners yet', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text('Add a banner to show on the login screen', style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...banners.map((b) => _BannerCard(
                  banner: b,
                  onEdit: () => _showEditBannerDialog(b, onUpdated: () => setState(() {})),
                  onToggleActive: () async {
                    final id = b['_id'] as String?;
                    if (id == null) return;
                    final currentlyActive = b['active'] as bool? ?? true;
                    final res = await _lmsService.updateAdBanner(id, active: !currentlyActive);
                    if (mounted && res != null) setState(() {});
                  },
                  onDelete: () async {
                    final ok = await _lmsService.deleteAdBanner(b['_id'] as String);
                    if (mounted && ok) setState(() {});
                  },
                )),
            ],
          ),
        );
      },
    );
  }

  void _showAddBannerDialog({VoidCallback? onCreated}) {
    _showBannerFormDialog(onSaved: onCreated);
  }

  void _showEditBannerDialog(Map<String, dynamic> banner, {VoidCallback? onUpdated}) {
    _showBannerFormDialog(banner: banner, onSaved: onUpdated);
  }

  void _showBannerFormDialog({Map<String, dynamic>? banner, VoidCallback? onSaved}) {
    final headlineController = TextEditingController(text: banner?['headline'] as String? ?? '');
    final descriptionController = TextEditingController(text: banner?['description'] as String? ?? '');
    final ctaController = TextEditingController(text: banner?['callToAction'] as String? ?? '');
    var imageAssetId = banner != null ? _getImageAssetId(banner['image']) : null;
    var imageBytes = <int>[];
    var imageFilename = '';
    var active = banner?['active'] as bool? ?? true;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(banner != null ? 'Edit Banner' : 'Add Banner'),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(controller: headlineController, decoration: const InputDecoration(labelText: 'Headline *', hintText: 'e.g. New Scholarship Batch')),
                    const SizedBox(height: 12),
                    TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
                    const SizedBox(height: 12),
                    TextField(controller: ctaController, decoration: const InputDecoration(labelText: 'Call to action', hintText: 'e.g. Join Now')),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(type: FileType.image);
                            if (result != null && result.files.single.bytes != null) {
                              imageBytes = result.files.single.bytes!;
                              imageFilename = result.files.single.name;
                              imageAssetId = null;
                              setDialogState(() {});
                            }
                          },
                          icon: const Icon(Icons.image),
                          label: Text(imageBytes.isNotEmpty ? 'Change image' : 'Pick image'),
                        ),
                        if (imageBytes.isNotEmpty || imageAssetId != null) ...[
                          const SizedBox(width: 8),
                          Text('Image selected', style: TextStyle(color: LMSTheme.successColor, fontSize: 12)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(value: active, onChanged: (v) { active = v ?? true; setDialogState(() {}); }),
                        const Text('Active (show on login)'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              FilledButton(
                onPressed: () async {
                  final headline = headlineController.text.trim();
                  if (headline.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Headline is required')));
                    return;
                  }
                  Navigator.pop(ctx);
                  String? assetId = imageAssetId;
                  if (imageBytes.isNotEmpty) {
                    assetId = await SanityImageUploader.uploadImage(imageBytes, imageFilename.isNotEmpty ? imageFilename : 'banner.png');
                  }
                  String? result;
                  if (banner != null) {
                    result = await _lmsService.updateAdBanner(banner['_id'] as String,
                      headline: headline,
                      description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                      callToAction: ctaController.text.trim().isEmpty ? null : ctaController.text.trim(),
                      imageAssetId: assetId,
                      active: active,
                    );
                  } else {
                    result = await _lmsService.createAdBanner(
                      headline: headline,
                      description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                      callToAction: ctaController.text.trim().isEmpty ? null : ctaController.text.trim(),
                      imageAssetId: assetId,
                      active: active,
                    );
                  }
                  if (mounted) {
                    if (result != null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(banner != null ? 'Banner updated' : 'Banner created')));
                      onSaved?.call();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed. ${lastMutationError ?? "Check token."}')));
                    }
                  }
                },
                child: Text(banner != null ? 'Update' : 'Create'),
              ),
            ],
          );
        },
      ),
    );
  }

  String? _getImageAssetId(dynamic image) {
    if (image is Map && image['asset'] != null) {
      final asset = image['asset'];
      if (asset is Map) return asset['_ref'] as String? ?? asset['_id'] as String?;
    }
    return null;
  }

  Widget _buildDocumentsTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('Document management', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('OCR/Cengage content – categorize and assign to subjects. Edit in Sanity Studio.', style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Future<void> _exportReport() async {
    await _analyticsStore.loadTestAttemptsForAnalytics();
    if (!mounted) return;
    final allAttempts = _analyticsStore.testAttempts;
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final attempts = allAttempts.where((a) {
      final d = a.submittedAt ?? a.startedAt;
      return d != null && !d.isBefore(monthStart) && !d.isAfter(monthEnd);
    }).toList();
    final buffer = StringBuffer();
    buffer.writeln('Test,Student,Score,Percentage,Passed,SubmittedAt');
    for (final a in attempts) {
      buffer.writeln('${a.testTitle ?? a.testId},${a.studentId},${a.score ?? ""},${a.percentage ?? ""},${a.passed ?? false},${a.submittedAt ?? ""}');
    }
    final csv = buffer.toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${attempts.length} attempts this month. Copy or export PDF.'),
        action: SnackBarAction(
          label: 'Copy',
          onPressed: () => _copyToClipboard(csv),
        ),
      ),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Monthly performance (${now.month}/${now.year})'),
        content: SingleChildScrollView(
          child: SelectableText(csv.isEmpty ? 'No data for this month' : csv),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          TextButton(onPressed: () { _copyToClipboard(csv); Navigator.pop(ctx); }, child: const Text('Copy')),
          FilledButton.icon(
            onPressed: csv.isEmpty ? null : () async { Navigator.pop(ctx); await _exportPdf(attempts, now); },
            icon: const Icon(Icons.picture_as_pdf, size: 18),
            label: const Text('Export PDF'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPdf(List<TestAttempt> attempts, DateTime month) async {
    final baseFont = await PdfGoogleFonts.openSansRegular();
    final boldFont = await PdfGoogleFonts.openSansBold();
    final theme = pw.ThemeData.withFont(base: baseFont, bold: boldFont);
    final pdf = pw.Document(theme: theme);
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (ctx) => pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text('Monthly Performance Report - ${month.month}/${month.year}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        ),
        build: (ctx) => [
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: ['Test', 'Student', 'Score', '%', 'Passed', 'Date'].map((h) => pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(h, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))).toList(),
              ),
              ...attempts.map((a) => pw.TableRow(
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(a.testTitle ?? a.testId, style: const pw.TextStyle(fontSize: 10))),
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(a.studentId, style: const pw.TextStyle(fontSize: 10))),
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${a.score ?? 0}', style: const pw.TextStyle(fontSize: 10))),
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${a.percentage?.toStringAsFixed(1) ?? 0}%', style: const pw.TextStyle(fontSize: 10))),
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(a.passed == true ? 'Yes' : 'No', style: const pw.TextStyle(fontSize: 10))),
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(a.submittedAt?.toIso8601String().split('T').first ?? '-', style: const pw.TextStyle(fontSize: 10))),
                ],
              )),
            ],
          ),
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }
}

class _BannerCard extends StatelessWidget {
  final Map<String, dynamic> banner;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const _BannerCard({required this.banner, required this.onEdit, required this.onToggleActive, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final headline = banner['headline'] as String? ?? 'Untitled';
    final active = banner['active'] as bool? ?? true;
    final imageUrl = banner['imageUrl'] as String?;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(imageUrl, width: 80, height: 60, fit: BoxFit.cover),
              )
            else
              Container(width: 80, height: 60, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.image_not_supported)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(headline, style: Theme.of(context).textTheme.titleMedium),
                  if ((banner['callToAction'] as String?)?.isNotEmpty == true)
                    Text(banner['callToAction'] as String, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Switch(
                        value: active,
                        onChanged: (_) => onToggleActive(),
                      ),
                      Text(active ? 'Active' : 'Inactive', style: TextStyle(fontSize: 12, color: active ? LMSTheme.successColor : Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            IconButton(icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error), onPressed: () async {
              final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
                title: const Text('Delete banner?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                  FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete'), style: FilledButton.styleFrom(backgroundColor: Theme.of(c).colorScheme.error)),
                ],
              ));
              if (ok == true) onDelete();
            }),
          ],
        ),
      ),
    );
  }
}

class _StudentRowData {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController rollController;
  _StudentRowData(this.nameController, this.emailController, this.rollController);
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
