import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../models/profile.dart';

class ApplicantProfileScreen extends StatefulWidget {
  final String applicantId;

  const ApplicantProfileScreen({
    Key? key,
    required this.applicantId,
  }) : super(key: key);

  @override
  State<ApplicantProfileScreen> createState() => _ApplicantProfileScreenState();
}

class _ApplicantProfileScreenState extends State<ApplicantProfileScreen> {
  final _authService = AuthService();
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _authService.getUserProfile(widget.applicantId);
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading applicant profile: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Applicant Profile')),
        body: const Center(child: Text('Profile not found')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('Applicant Profile', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
                    child: Text(
                      _profile!.fullName[0].toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _profile!.fullName,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  if (_profile!.currentPosition != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _profile!.currentPosition!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildInfoChip(
                        icon: Icons.email_outlined,
                        label: _profile!.email,
                      ),
                      if (_profile!.location != null)
                        _buildInfoChip(
                          icon: Icons.location_on_outlined,
                          label: _profile!.location!,
                        ),
                      if (_profile!.phoneNumber != null)
                        _buildInfoChip(
                          icon: Icons.phone_outlined,
                          label: _profile!.phoneNumber!,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Bio
            if (_profile!.bio != null && _profile!.bio!.isNotEmpty)
              _buildCard(
                title: 'About',
                child: Text(
                  _profile!.bio!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF374151),
                    height: 1.5,
                  ),
                ),
              ),

            // Experience
            if (_profile!.experienceYears != null)
              _buildCard(
                title: 'Experience',
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.work_outline, color: Color(0xFF2563EB)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_profile!.experienceYears} ${_profile!.experienceYears == 1 ? 'year' : 'years'} of experience',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),

            // Skills
            if (_profile!.skills != null && _profile!.skills!.isNotEmpty)
              _buildCard(
                title: 'Skills',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _profile!.skills!.map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.2)),
                      ),
                      child: Text(
                        skill,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF2563EB),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            // Links
            if (_hasLinks())
              _buildCard(
                title: 'Links & Portfolio',
                child: Column(
                  children: [
                    if (_profile!.portfolioUrl != null && _profile!.portfolioUrl!.isNotEmpty)
                      _buildLinkItem(
                        icon: Icons.link,
                        label: 'Portfolio',
                        url: _profile!.portfolioUrl!,
                      ),
                    if (_profile!.githubUrl != null && _profile!.githubUrl!.isNotEmpty) ...[
                      const Divider(height: 24),
                      _buildLinkItem(
                        icon: Icons.code,
                        label: 'GitHub',
                        url: _profile!.githubUrl!,
                      ),
                    ],
                    if (_profile!.linkedinUrl != null && _profile!.linkedinUrl!.isNotEmpty) ...[
                      const Divider(height: 24),
                      _buildLinkItem(
                        icon: Icons.business,
                        label: 'LinkedIn',
                        url: _profile!.linkedinUrl!,
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _hasLinks() {
    return (_profile!.portfolioUrl != null && _profile!.portfolioUrl!.isNotEmpty) ||
        (_profile!.githubUrl != null && _profile!.githubUrl!.isNotEmpty) ||
        (_profile!.linkedinUrl != null && _profile!.linkedinUrl!.isNotEmpty);
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
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

  Widget _buildLinkItem({
    required IconData icon,
    required String label,
    required String url,
  }) {
    return InkWell(
      onTap: () {
        // TODO: Open URL
        print('Opening: $url');
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF2563EB)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF111827),
                  ),
                ),
                Text(
                  url,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF2563EB),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.open_in_new, size: 18, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }
}