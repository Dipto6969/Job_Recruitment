import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/job.dart';
import '../services/application_service.dart';
import '../services/auth_service.dart';

class JobDetailScreen extends StatefulWidget {
  final Job job;

  const JobDetailScreen({Key? key, required this.job}) : super(key: key);

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  final _applicationService = ApplicationService();
  final _authService = AuthService();
  final _coverLetterController = TextEditingController();

  bool _isApplying = false;
  bool _hasApplied = false;
  bool _isCheckingStatus = true;

  @override
  void initState() {
    super.initState();
    _checkApplicationStatus();
  }

  Future<void> _checkApplicationStatus() async {
    final userId = _authService.currentUser?.id;
    if (userId == null) return;

    final hasApplied = await _applicationService.hasApplied(
      jobId: widget.job.id,
      applicantId: userId, // ✅ CHANGED from jobSeekerId
    );

    if (mounted) {
      setState(() {
        _hasApplied = hasApplied;
        _isCheckingStatus = false;
      });
    }
  }

  Future<void> _showApplyDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Apply to ${widget.job.title}',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cover Letter (Optional)',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _coverLetterController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Tell the employer why you\'re a great fit...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: _applyToJob,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Submit Application',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _applyToJob() async {
    final userId = _authService.currentUser?.id;
    if (userId == null) return;

    setState(() => _isApplying = true);

    try {
      await _applicationService.applyToJob(
        jobId: widget.job.id,
        applicantId: userId, // ✅ CHANGED from jobSeekerId
        resumeUrl: null, // ✅ CHANGED from coverLetter - we'll add resume upload later
      );

      if (mounted) {
        Navigator.pop(context); // Close dialog
        setState(() {
          _hasApplied = true;
          _isApplying = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isApplying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Job Details',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.work,
                          color: Color(0xFF2563EB),
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.job.title,
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.job.companyName ?? 'Company',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(Icons.location_on_outlined, widget.job.location),
                      _buildChip(Icons.work_outline, widget.job.jobType),
                      if (widget.job.salary != null)
                        _buildChip(Icons.attach_money, widget.job.salary!),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Job Description
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Job Description',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.job.description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF374151),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Requirements
            if (widget.job.requirements != null && widget.job.requirements!.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Requirements',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...widget.job.requirements!.map((req) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 20,
                                color: Color(0xFF10B981),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  req,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF374151),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),

            const SizedBox(height: 100), // Space for button
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: _isCheckingStatus
              ? const Center(child: CircularProgressIndicator())
              : _hasApplied
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF10B981)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, color: Color(0xFF10B981)),
                          const SizedBox(width: 8),
                          Text(
                            'Already Applied',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _isApplying ? null : _showApplyDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isApplying)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          else
                            const Icon(Icons.send, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            _isApplying ? 'Applying...' : 'Apply Now',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF6B7280)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }
}