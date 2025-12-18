class UserProfile {
  // ✅ BASIC INFO (collected during signup)
  final String id;
  final String email;
  final String fullName;
  final String role; // 'job_seeker' or 'employer'
  final DateTime createdAt;

  // ✅ ADDITIONAL INFO (filled later in Edit Profile screen)
  final String? phoneNumber;
  final String? bio;
  final List<String>? skills;
  final int? experienceYears;
  final String? currentPosition;
  final String? location;
  final String? portfolioUrl;
  final String? githubUrl;
  final String? linkedinUrl;
  final String? availability;
  final String? profileImageUrl;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.createdAt,
    this.phoneNumber,
    this.bio,
    this.skills,
    this.experienceYears,
    this.currentPosition,
    this.location,
    this.portfolioUrl,
    this.githubUrl,
    this.linkedinUrl,
    this.availability,
    this.profileImageUrl,
    this.updatedAt,
  });

  // Check if profile is complete (has additional info)
  bool get isProfileComplete {
    if (role == 'job_seeker') {
      return skills != null && 
             skills!.isNotEmpty && 
             experienceYears != null &&
             bio != null &&
             bio!.isNotEmpty;
    } else {
      // Employer profile completion check
      return bio != null && bio!.isNotEmpty;
    }
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      phoneNumber: json['phone_number'] as String?,
      bio: json['bio'] as String?,
      skills: json['skills'] != null 
          ? List<String>.from(json['skills'] as List)
          : null,
      experienceYears: json['experience_years'] as int?,
      currentPosition: json['current_position'] as String?,
      location: json['location'] as String?,
      portfolioUrl: json['portfolio_url'] as String?,
      githubUrl: json['github_url'] as String?,
      linkedinUrl: json['linkedin_url'] as String?,
      availability: json['availability'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'phone_number': phoneNumber,
      'bio': bio,
      'skills': skills,
      'experience_years': experienceYears,
      'current_position': currentPosition,
      'location': location,
      'portfolio_url': portfolioUrl,
      'github_url': githubUrl,
      'linkedin_url': linkedinUrl,
      'availability': availability,
      'profile_image_url': profileImageUrl,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    DateTime? createdAt,
    String? phoneNumber,
    String? bio,
    List<String>? skills,
    int? experienceYears,
    String? currentPosition,
    String? location,
    String? portfolioUrl,
    String? githubUrl,
    String? linkedinUrl,
    String? availability,
    String? profileImageUrl,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      experienceYears: experienceYears ?? this.experienceYears,
      currentPosition: currentPosition ?? this.currentPosition,
      location: location ?? this.location,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      availability: availability ?? this.availability,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}