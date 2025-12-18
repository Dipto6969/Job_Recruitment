import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/job_service.dart';
import '../services/auth_service.dart';
import '../services/application_service.dart';  // ✅ ADD THIS
import '../models/job.dart';
import '../models/application.dart';
import '../widgets/app_widgets.dart';
import 'job_detail_screen.dart';
import 'my_applications_screen.dart';

class JobListingScreen extends StatefulWidget {
  const JobListingScreen({super.key});

  @override
  State<JobListingScreen> createState() => _JobListingScreenState();
}

class _JobListingScreenState extends State<JobListingScreen> {
  final _jobService = JobService();
  final _authService = AuthService();
  final _applicationService = ApplicationService();  // ✅ ADD THIS
  
  List<Job> _jobs = [];
  List<Application> _myApplications = [];
  bool _isLoading = true;
  
  final _skillController = TextEditingController();
  final _locationController = TextEditingController();
  int? _selectedExperience;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = _authService.currentUser;
      
      final jobs = await _jobService.getAllJobs();  // ✅ CHANGED - Use getAllJobs instead
      
      List<Application> myApps = [];
      if (user != null) {
        myApps = await _applicationService.getMyApplications(user.id);  // ✅ CHANGED - Use ApplicationService
      }
      
      setState(() {
        _jobs = jobs;
        _myApplications = myApps;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading jobs: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _hasApplied(String jobId) {
    return _myApplications.any((app) => app.jobId == jobId);
  }

  String? _getApplicationStatus(String jobId) {
    try {
      final app = _myApplications.firstWhere((app) => app.jobId == jobId);
      return app.status;
    } catch (e) {
      return null;
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Filter Jobs',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            AppTextField(
              controller: _skillController,
              label: 'Skill',
              hint: 'e.g., Flutter, React',
              prefixIcon: Icons.psychology_outlined,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _locationController,
              label: 'Location',
              hint: 'e.g., Dhaka, Remote',
              prefixIcon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),
            Text(
              'Max Experience Required',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonFormField<int>(
                value: _selectedExperience,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  prefixIcon: Icon(Icons.work_outline, size: 20),
                ),
                hint: const Text('Select experience'),
                items: List.generate(21, (index) => index)
                    .map((year) => DropdownMenuItem(
                          value: year,
                          child: Text('$year years'),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedExperience = value),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Clear',
                    isOutlined: true,
                    onPressed: () {
                      _skillController.clear();
                      _locationController.clear();
                      setState(() => _selectedExperience = null);
                      Navigator.pop(context);
                      _loadData();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: 'Apply Filters',
                    onPressed: () {
                      Navigator.pop(context);
                      _loadData();
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Logout?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.pop(context);
                context.go('/login');
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),  // ✅ ADD background color
      appBar: AppBar(
        title: Text(
          'Find Jobs',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,  // ✅ ADD this to remove back button
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.article_outlined, size: 20, color: AppColors.primary),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyApplicationsScreen()),
              ).then((_) => _loadData());
            },
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.filter_list, size: 20, color: AppColors.textSecondary),
            ),
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout, size: 20, color: AppColors.error),
            ),
            onPressed: _showLogoutDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _jobs.isEmpty
              ? EmptyState(
                  icon: Icons.work_off_outlined,
                  title: 'No jobs found',
                  subtitle: 'Try adjusting your filters or check back later',
                  action: AppButton(
                    text: 'Clear Filters',
                    onPressed: () {
                      _skillController.clear();
                      _locationController.clear();
                      setState(() => _selectedExperience = null);
                      _loadData();
                    },
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: _jobs.length,
                    itemBuilder: (context, index) {
                      final job = _jobs[index];
                      final hasApplied = _hasApplied(job.id);
                      final status = _getApplicationStatus(job.id);
                      
                      return _JobCard(
                        job: job,
                        hasApplied: hasApplied,
                        status: status,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JobDetailScreen(job: job),
                            ),
                          ).then((_) => _loadData());
                        },
                      );
                    },
                  ),
                ),
    );
  }

  @override
  void dispose() {
    _skillController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}

class _JobCard extends StatelessWidget {
  final Job job;
  final bool hasApplied;
  final String? status;
  final VoidCallback onTap;

  const _JobCard({
    required this.job,
    required this.hasApplied,
    this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.companyName ?? 'Unknown Company',  // ✅ CHANGED from job.company?.name
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasApplied) StatusChip(status: status ?? 'pending'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _InfoChip(icon: Icons.location_on_outlined, label: job.location),  // ✅ REMOVED if check
              const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.work_outline,
                label: job.jobType,  // ✅ CHANGED to show job type instead
              ),
            ],
          ),
          // ✅ REMOVED skillsRequired section since Job model doesn't have it
          // If you want skills, add them to Job model later
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}