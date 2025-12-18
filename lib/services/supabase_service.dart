import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://bwfbhcvqwunyxlucfasz.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ3ZmJoY3Zxd3VueXhsdWNmYXN6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU3NzY3NDYsImV4cCI6MjA4MTM1Mjc0Nn0.uJpqSSj1cSXLjZcy7P0HAxlu7kcnsmPUw3Y2ib2QLvw';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}