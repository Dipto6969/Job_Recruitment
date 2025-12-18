import 'profile.dart';
import 'job.dart';

class Application {
  final String id;
  final String jobId;
  final String applicantId;  // ✅ CHANGED from jobSeekerId
  final String status;
  final String? resumeUrl;  // ✅ CHANGED from coverLetter
  final DateTime createdAt;  // ✅ CHANGED from appliedAt
  final DateTime? updatedAt;

  // For displaying with job/user info
  final String? jobTitle;
  final String? companyName;
  final String? applicantName;
  final String? applicantEmail;

  Application({
    required this.id,
    required this.jobId,
    required this.applicantId,  // ✅ CHANGED
    required this.status,
    this.resumeUrl,  // ✅ CHANGED
    required this.createdAt,  // ✅ CHANGED
    this.updatedAt,
    this.jobTitle,
    this.companyName,
    this.applicantName,
    this.applicantEmail,
  });

  // Getter for backward compatibility
  String get jobSeekerId => applicantId;
  DateTime get appliedAt => createdAt;
  String? get coverLetter => resumeUrl;

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'] as String,
      jobId: json['job_id'] as String,
      applicantId: json['applicant_id'] as String,  // ✅ CHANGED
      status: json['status'] as String? ?? 'pending',
      resumeUrl: json['resume_url'] as String?,  // ✅ CHANGED
      createdAt: DateTime.parse(json['created_at'] as String),  // ✅ CHANGED
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      jobTitle: json['job_title'] as String?,
      companyName: json['company_name'] as String?,
      applicantName: json['applicant_name'] as String?,
      applicantEmail: json['applicant_email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_id': jobId,
      'applicant_id': applicantId,  // ✅ CHANGED
      'status': status,
      'resume_url': resumeUrl,  // ✅ CHANGED
      'created_at': createdAt.toIso8601String(),  // ✅ CHANGED
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}