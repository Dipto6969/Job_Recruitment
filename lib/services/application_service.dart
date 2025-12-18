import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application.dart';

class ApplicationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Apply to a job
  Future<void> applyToJob({
    required String jobId,
    required String applicantId,
    String? resumeUrl,
  }) async {
    try {
      // Check if already applied
      final existing = await _supabase
          .from('applications')
          .select()
          .eq('job_id', jobId)
          .eq('applicant_id', applicantId)
          .maybeSingle();

      if (existing != null) {
        throw Exception('You have already applied to this job');
      }

      // Create application
      await _supabase.from('applications').insert({
        'job_id': jobId,
        'applicant_id': applicantId,
        'status': 'pending',
        'resume_url': resumeUrl,
        'created_at': DateTime.now().toIso8601String(),
      });

      print('Application submitted successfully');
    } catch (e) {
      print('Error applying to job: $e');
      rethrow;
    }
  }

  // Get job seeker's applications
  Future<List<Application>> getMyApplications(String applicantId) async {
    try {
      final response = await _supabase
          .from('applications')
          .select('''
            *,
            jobs!applications_job_id_fkey(
              id,
              title,
              companies!inner(name)
            )
          ''')
          .eq('applicant_id', applicantId)
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        return Application.fromJson({
          ...json,
          'job_title': json['jobs']?['title'],
          'company_name': json['jobs']?['companies']?['name'],
        });
      }).toList();
    } catch (e) {
      print('Error fetching applications: $e');
      return [];
    }
  }

  // Get applications for a specific job (for employers) ✅ FIXED
  Future<List<Application>> getJobApplications(String jobId) async {
    try {
      print('Fetching applications for job: $jobId');
      
      final response = await _supabase
          .from('applications')
          .select('''
            *,
            profiles!applications_applicant_id_fkey(
              id,
              full_name,
              email
            )
          ''')
          .eq('job_id', jobId)
          .order('created_at', ascending: false);

      print('Raw response: $response');
      print('Applications count: ${(response as List).length}');

      if (response.isEmpty) {
        print('No applications found for this job');
        return [];
      }

      return (response as List).map((json) {
        print('Processing application: ${json['id']}');
        
        return Application.fromJson({
          'id': json['id'],
          'job_id': json['job_id'],
          'applicant_id': json['applicant_id'],
          'status': json['status'],
          'resume_url': json['resume_url'],
          'created_at': json['created_at'],
          'updated_at': json['updated_at'],
          'applicant_name': json['profiles']?['full_name'] ?? 'Unknown Applicant',
          'applicant_email': json['profiles']?['email'] ?? 'No email',
        });
      }).toList();
    } catch (e) {
      print('Error fetching job applications: $e');
      print('Error type: ${e.runtimeType}');
      return [];
    }
  }

  // Update application status (for employers)
  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
  }) async {
    try {
      await _supabase.from('applications').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', applicationId);

      print('Application status updated to: $status');
    } catch (e) {
      print('Error updating application status: $e');
      rethrow;
    }
  }

  // Check if user already applied to a job
  Future<bool> hasApplied({
    required String jobId,
    required String applicantId,
  }) async {
    try {
      final response = await _supabase
          .from('applications')
          .select('id')
          .eq('job_id', jobId)
          .eq('applicant_id', applicantId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking application: $e');
      return false;
    }
  }
}