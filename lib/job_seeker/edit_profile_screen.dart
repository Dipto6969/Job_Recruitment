import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../models/profile.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _currentPositionController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _githubController = TextEditingController();
  final _linkedinController = TextEditingController();

  List<String> _skills = [];
  final _skillController = TextEditingController();
  int? _experienceYears;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _authService.getCurrentProfile();
      if (profile != null && mounted) {
        setState(() {
          _nameController.text = profile.fullName;
          _bioController.text = profile.bio ?? '';
          _phoneController.text = profile.phoneNumber ?? '';
          _locationController.text = profile.location ?? '';
          _currentPositionController.text = profile.currentPosition ?? '';
          _portfolioController.text = profile.portfolioUrl ?? '';
          _githubController.text = profile.githubUrl ?? '';
          _linkedinController.text = profile.linkedinUrl ?? '';
          _skills = List.from(profile.skills ?? []);
          _experienceYears = profile.experienceYears;
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      await _authService.updateProfile(
        userId: userId,
        data: {
          'full_name': _nameController.text.trim(),
          'bio': _bioController.text.trim(),
          'phone_number': _phoneController.text.trim(),
          'location': _locationController.text.trim(),
          'current_position': _currentPositionController.text.trim(),
          'portfolio_url': _portfolioController.text.trim(),
          'github_url': _githubController.text.trim(),
          'linkedin_url': _linkedinController.text.trim(),
          'skills': _skills,
          'experience_years': _experienceYears,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      print('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _addSkill() {
    if (_skillController.text.trim().isNotEmpty) {
      setState(() {
        _skills.add(_skillController.text.trim());
        _skillController.clear();
      });
    }
  }

  void _removeSkill(int index) {
    setState(() {
      _skills.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF2563EB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Info Card
              _buildCard(
                title: 'Basic Information',
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                    validator: (v) => v?.isEmpty ?? true ? 'Name required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _bioController,
                    label: 'Bio',
                    icon: Icons.info_outline,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _locationController,
                    label: 'Location',
                    icon: Icons.location_on_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Professional Info Card
              _buildCard(
                title: 'Professional Information',
                children: [
                  _buildTextField(
                    controller: _currentPositionController,
                    label: 'Current Position',
                    icon: Icons.work_outline,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _experienceYears,
                    decoration: InputDecoration(
                      labelText: 'Years of Experience',
                      prefixIcon: const Icon(Icons.timeline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: List.generate(31, (i) => i).map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text('$year ${year == 1 ? 'year' : 'years'}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _experienceYears = value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Skills Card
              _buildCard(
                title: 'Skills',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _skillController,
                          decoration: InputDecoration(
                            hintText: 'Add a skill',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onSubmitted: (_) => _addSkill(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _addSkill,
                        icon: const Icon(Icons.add_circle),
                        color: const Color(0xFF2563EB),
                        iconSize: 32,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _skills.asMap().entries.map((entry) {
                      return Chip(
                        label: Text(entry.value),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _removeSkill(entry.key),
                        backgroundColor: const Color(0xFFEFF6FF),
                        labelStyle: GoogleFonts.inter(
                          color: const Color(0xFF2563EB),
                          fontSize: 13,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Links Card
              _buildCard(
                title: 'Links',
                children: [
                  _buildTextField(
                    controller: _portfolioController,
                    label: 'Portfolio URL',
                    icon: Icons.link,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _githubController,
                    label: 'GitHub URL',
                    icon: Icons.code,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _linkedinController,
                    label: 'LinkedIn URL',
                    icon: Icons.business,
                    keyboardType: TextInputType.url,
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
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
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
      ),
      validator: validator,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _currentPositionController.dispose();
    _portfolioController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    _skillController.dispose();
    super.dispose();
  }
}