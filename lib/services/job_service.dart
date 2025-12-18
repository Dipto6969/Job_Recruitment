import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../models/job.dart';
import '../models/application.dart';

class JobService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Job>> getJobs({
    String? skill,
    int? experienceRequired,
    String? location,
  }) async {
    var query = _supabase
        .from('jobs')
        .select('*, companies(*)');

    if (skill != null && skill.isNotEmpty) {
      query = query.contains('skills_required', [skill]);
    }

    if (experienceRequired != null) {
      query = query.lte('experience_required', experienceRequired);
    }

    if (location != null && location.isNotEmpty) {
      query = query.ilike('location', '%$location%');
    }

    final response = await query.order('created_at', ascending: false);
    return (response as List).map((json) => Job.fromJson(json)).toList();
  }

  Future<Job> getJobById(String jobId) async {
    final response = await _supabase
        .from('jobs')
        .select('*, companies(*)')
        .eq('id', jobId)
        .single();

    return Job.fromJson(response);
  }

  Future<List<Job>> getJobsByCompany(String companyId) async {
    try {
      final response = await _supabase
          .from('jobs')
          .select('''
            *,
            companies!inner(name)
          ''')
          .eq('company_id', companyId)
          .order('created_at', ascending: false);  // ✅ Order by created_at instead

      return (response as List).map((json) {
        return Job.fromJson({
          ...json,
          'company_name': json['companies']['name'],
        });
      }).toList();
    } catch (e) {
      print('Error fetching company jobs: $e');
      return [];
    }
  }

  Future<String> createJob({
    required String companyId,
    required String title,
    required String description,
    List<String>? skillsRequired,
    int? experienceRequired,
    String? location,
  }) async {
    final response = await _supabase
        .from('jobs')
        .insert({
          'company_id': companyId,
          'title': title,
          'description': description,
          'skills_required': skillsRequired,
          'experience_required': experienceRequired,
          'location': location,
        })
        .select()
        .single();

    return response['id'];
  }

  Future<void> updateJob({
    required String jobId,
    required String title,
    required String description,
    List<String>? skillsRequired,
    int? experienceRequired,
    String? location,
  }) async {
    await _supabase
        .from('jobs')
        .update({
          'title': title,
          'description': description,
          'skills_required': skillsRequired,
          'experience_required': experienceRequired,
          'location': location,
        })
        .eq('id', jobId);
  }

  Future<void> deleteJob(String jobId) async {
    await _supabase
        .from('jobs')
        .delete()
        .eq('id', jobId);
  }

  Future<void> applyToJob({
    required String jobId,
    required String applicantId,
    String? resumeUrl,
  }) async {
    await _supabase.from('applications').insert({
      'job_id': jobId,
      'applicant_id': applicantId,
      'resume_url': resumeUrl,
      'status': 'pending',
    });
  }

  Future<List<Application>> getMyApplications(String applicantId) async {
    final response = await _supabase
        .from('applications')
        .select('*, jobs(*, companies(*)), profiles(*)')
        .eq('applicant_id', applicantId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Application.fromJson(json)).toList();
  }

  Future<List<Application>> getApplicationsByJob(String jobId) async {
    final response = await _supabase
        .from('applications')
        .select('*, profiles(*), jobs(*)')
        .eq('job_id', jobId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Application.fromJson(json)).toList();
  }

  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
  }) async {
    await _supabase
        .from('applications')
        .update({'status': status})
        .eq('id', applicationId);
  }

  Future<String> uploadResume(String filePath, String fileName) async {
    try {
      print('Starting resume upload...');
      print('File path: $filePath');
      print('File name: $fileName');
      
      final file = File(filePath);
      
      // Check if file exists
      if (!await file.exists()) {
        throw Exception('File does not exist at: $filePath');
      }
      
      print('File exists, reading bytes...');
      final bytes = await file.readAsBytes();
      print('Bytes read: ${bytes.length}');
      
      // Upload to Supabase Storage
      print('Uploading to Supabase...');
      await _supabase.storage
          .from('resumes')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );
      
      print('Upload successful, generating public URL...');
      
      // Get public URL - IMPORTANT: Use getPublicUrl() correctly
      final String publicUrl = _supabase.storage
          .from('resumes')
          .getPublicUrl(fileName);
      
      print('Public URL generated: $publicUrl');
      
      // Verify URL is valid
      if (!publicUrl.contains('http')) {
        throw Exception('Invalid public URL generated: $publicUrl');
      }
      
      return publicUrl;
    } catch (e) {
      print('Error uploading resume: $e');
      throw Exception('Failed to upload resume: $e');
    }
  }

  Future<void> postJob({
    required String companyId,
    required String title,
    required String description,
    required List<String> skillsRequired,
    int? experienceRequired,
    String? location,
  }) async {
    try {
      await _supabase.from('jobs').insert({
        'company_id': companyId,
        'title': title,
        'description': description,
        'skills_required': skillsRequired,
        'experience_required': experienceRequired,
        'location': location,
      });
    } catch (e) {
      print('Error posting job: $e');
      throw Exception('Failed to post job: $e');
    }
  }

  Future<List<Job>> getAllJobs() async {
    try {
      final response = await _supabase
          .from('jobs')
          .select('''
            *,
            companies!inner(name)
          ''')
          .eq('is_active', true)
          .order('created_at', ascending: false);  // ✅ Order by created_at instead

      return (response as List).map((json) {
        return Job.fromJson({
          ...json,
          'company_name': json['companies']['name'],
        });
      }).toList();
    } catch (e) {
      print('Error fetching jobs: $e');
      return [];
    }
  }
}