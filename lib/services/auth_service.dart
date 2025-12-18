import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;
  
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    List<String>? skills,
    int? experienceYears,
  }) async {
    try {
      print('=== SIGNUP STARTED ===');
      print('Email: $email, Role: $role');
      
      // Sign up the user
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Signup failed: User is null');
      }

      final userId = response.user!.id;
      print('User created with ID: $userId');
      
      // Create profile immediately
      await _supabase.from('profiles').insert({
        'id': userId,
        'role': role,
        'full_name': fullName,
        'email': email,
        'skills': skills,
        'experience_years': experienceYears,
        'availability': 'available',
        'created_at': DateTime.now().toIso8601String(),
      });
      
      print('Profile created successfully');
      
      return response;
    } catch (e) {
      print('Signup error: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('=== SIGNIN STARTED ===');
      print('Email: $email');
      
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('Sign in successful: ${response.user?.id}');

      // Check if profile exists
      if (response.user != null) {
        try {
          final existing = await _supabase
              .from('profiles')
              .select()
              .eq('id', response.user!.id)
              .maybeSingle();

          if (existing == null) {
            print('Profile not found, creating default profile...');
            
            await _supabase.from('profiles').insert({
              'id': response.user!.id,
              'email': email,
              'full_name': email.split('@')[0],
              'role': 'job_seeker',
              'availability': 'available',
              'created_at': DateTime.now().toIso8601String(),
            });
            
            print('Default profile created');
          } else {
            print('Profile found with role: ${existing['role']}');
          }
        } catch (e) {
          print('Error with profile: $e');
        }
      }

      return response;
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<UserProfile?> getCurrentProfile() async {
    final user = currentUser;
    if (user == null) {
      print('No current user logged in');
      return null;
    }

    try {
      print('Fetching profile for: ${user.id}');
      
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        print('No profile found');
        return null;
      }

      print('Profile retrieved: ${response['role']}');
      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<void> updateProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();
      await _supabase
          .from('profiles')
          .update(data)
          .eq('id', userId);
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }
}