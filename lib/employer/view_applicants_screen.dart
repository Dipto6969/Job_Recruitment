import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/application.dart';
import '../models/job.dart';
import '../services/application_service.dart'; // ✅ ADD THIS

class ViewApplicantsScreen extends StatefulWidget {
  final Job job;

  const ViewApplicantsScreen({Key? key, required this.job}) : super(key: key);

  @override
  State<ViewApplicantsScreen> createState() => _ViewApplicantsScreenState();
}

class _ViewApplicantsScreenState extends State<ViewApplicantsScreen> {
  final ApplicationService _applicationService = ApplicationService(); // ✅ CHANGED

  List<Application> _applications = [];
  bool _isLoading = true;
  String? _downloadingId;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() => _isLoading = true);
    try {
      print('Loading applications for job: ${widget.job.id}');  // ✅ DEBUG
      
      final response = await _applicationService.getJobApplications(widget.job.id);
      
      print('Applications loaded: ${response.length}');  // ✅ DEBUG
      
      if (!mounted) return;
      setState(() => _applications = response);
    } catch (e) {
      print('Error loading applicants: $e');  // ✅ DEBUG
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading applicants: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String applicationId, String status) async {
    try {
      await _applicationService.updateApplicationStatus(
        applicationId: applicationId,
        status: status,
      );
      await _loadApplications();
      if (!mounted) return;

      final isAccepted = status == 'accepted';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAccepted
              ? 'Application accepted!'
              : status == 'rejected'
                  ? 'Application rejected!'
                  : 'Status updated!'),
          backgroundColor: isAccepted ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }

  Future<void> _downloadResume({
    required String resumeUrl,
    required String applicantName,
  }) async {
    try {
      setState(() => _downloadingId = applicantName);

      final response = await http.get(Uri.parse(resumeUrl)).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw 'Download timeout',
      );

      if (response.statusCode != 200) {
        throw 'Server error: ${response.statusCode}';
      }

      final appDocDir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${appDocDir.path}/Downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final safeName = applicantName.trim().isEmpty ? 'applicant' : applicantName;
      final fileName = '${safeName.replaceAll(RegExp(r'\s+'), '_')}_resume.pdf';
      final filePath = '${downloadsDir.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      if (!mounted) return;
      setState(() => _downloadingId = null);
      _showDownloadInfo(applicantName: applicantName, filePath: filePath);
    } catch (e) {
      if (!mounted) return;
      setState(() => _downloadingId = null);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading resume: $e'),
          action: SnackBarAction(
            label: 'Copy URL',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: resumeUrl));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('URL copied')),
              );
            },
          ),
        ),
      );
    }
  }

  void _showDownloadInfo({
    required String applicantName,
    required String filePath,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 26),
            const SizedBox(width: 12),
            Text(
              'Download complete',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resume for $applicantName saved.',
              style: GoogleFonts.inter(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: SelectableText(
                filePath,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF111827),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: filePath));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Path copied')),
              );
            },
            child: const Text('Copy path'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return const Color(0xFF10B981);
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = GoogleFonts.interTextTheme(Theme.of(context).textTheme);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Applicants',
          style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _applications.isEmpty
              ? _EmptyState(
                  title: 'No applications yet',
                  subtitle: 'Applications will appear here.',
                )
              : RefreshIndicator(
                  onRefresh: _loadApplications,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: _applications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final app = _applications[index];
                      final applicantName = app.applicantName ?? 'Unknown';
                      final status = app.status;
                      final statusColor = _statusColor(status);
                      final isDownloading = _downloadingId == applicantName;

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.10),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      Icons.person_outline,
                                      color: statusColor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          applicantName,
                                          style: text.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF111827),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Applied ${app.appliedAt.toString().split(' ').first}', // ✅ FIXED
                                          style: text.bodySmall?.copyWith(
                                            color: const Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      status.toUpperCase(),
                                      style: text.labelSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: statusColor,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              if (app.applicantEmail != null) ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.email_outlined,  // ✅ CHANGED from email_outline
                                      size: 16,
                                      color: Color(0xFF6B7280),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      app.applicantEmail!,
                                      style: text.bodySmall?.copyWith(
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              // ✅ REMOVED app.applicant references since we don't have that data
                              
                              if (app.coverLetter != null && app.coverLetter!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Cover Letter:',
                                        style: text.labelSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        app.coverLetter!,
                                        style: text.bodySmall?.copyWith(
                                          color: const Color(0xFF374151),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 16),
                              const Divider(height: 1, color: Color(0xFFE5E7EB)),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  if (app.status == 'pending') ...[
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _updateStatus(app.id, 'rejected'),
                                        icon: const Icon(Icons.close, size: 18),
                                        label: const Text('Reject'),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          foregroundColor: const Color(0xFFEF4444),
                                          side: const BorderSide(color: Color(0xFFEF4444)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: () => _updateStatus(app.id, 'accepted'),
                                        icon: const Icon(Icons.check, size: 18),
                                        label: const Text('Accept'),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: const Color(0xFF10B981),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final text = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.inbox_outlined,
                  color: Color(0xFF9CA3AF),
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(color: const Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}