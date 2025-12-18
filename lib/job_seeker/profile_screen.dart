import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../models/profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
      final profile = await _authService.getCurrentProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Profile not found', style: GoogleFonts.inter(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('My Profile', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await context.push('/edit-profile');
              _loadProfile(); // Reload after edit
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Header Card
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildInfoChip(
                          icon: Icons.email_outlined,
                          label: _profile!.email,
                        ),
                        if (_profile!.location != null) ...[
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            icon: Icons.location_on_outlined,
                            label: _profile!.location!,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Bio Card
              if (_profile!.bio != null && _profile!.bio!.isNotEmpty)
                _buildCard(
                  title: 'About Me',
                  child: Text(
                    _profile!.bio!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF374151),
                      height: 1.5,
                    ),
                  ),
                ),

              // Experience Card
              if (_profile!.experienceYears != null)
                _buildCard(
                  title: 'Experience',
                  child: Row(
                    children: [
                      const Icon(Icons.work_outline, color: Color(0xFF2563EB)),
                      const SizedBox(width: 12),
                      Text(
                        '${_profile!.experienceYears} ${_profile!.experienceYears == 1 ? 'year' : 'years'} of experience',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),

              // Skills Card
              if (_profile!.skills != null && _profile!.skills!.isNotEmpty)
                _buildCard(
                  title: 'Skills',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _profile!.skills!.map((skill) {
                      return Chip(
                        label: Text(skill),
                        backgroundColor: const Color(0xFFEFF6FF),
                        labelStyle: GoogleFonts.inter(
                          color: const Color(0xFF2563EB),
                          fontSize: 13,
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // Links Card
              if (_hasLinks())
                _buildCard(
                  title: 'Links',
                  child: Column(
                    children: [
                      if (_profile!.portfolioUrl != null && _profile!.portfolioUrl!.isNotEmpty)
                        _buildLinkItem(
                          icon: Icons.link,
                          label: 'Portfolio',
                          url: _profile!.portfolioUrl!,
                        ),
                      if (_profile!.githubUrl != null && _profile!.githubUrl!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildLinkItem(
                          icon: Icons.code,
                          label: 'GitHub',
                          url: _profile!.githubUrl!,
                        ),
                      ],
                      if (_profile!.linkedinUrl != null && _profile!.linkedinUrl!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildLinkItem(
                          icon: Icons.business,
                          label: 'LinkedIn',
                          url: _profile!.linkedinUrl!,
                        ),
                      ],
                    ],
                  ),
                ),

              // Contact Card
              if (_profile!.phoneNumber != null && _profile!.phoneNumber!.isNotEmpty)
                _buildCard(
                  title: 'Contact',
                  child: Row(
                    children: [
                      const Icon(Icons.phone_outlined, color: Color(0xFF2563EB)),
                      const SizedBox(width: 12),
                      Text(
                        _profile!.phoneNumber!,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
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
        // TODO: Open URL in browser
        print('Opening: $url');
      },
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2563EB)),
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
          const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }
}