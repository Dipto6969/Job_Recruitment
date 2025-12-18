import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/company.dart';

class CompanyService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Company?> getCompanyByEmployer(String employerId) async {
    try {
      print('Fetching company for employerId: $employerId');
      
      final response = await _supabase
          .from('companies')
          .select()
          .eq('employer_id', employerId)
          .maybeSingle(); // Use maybeSingle() instead of single()
      
      if (response != null) {
        print('Company found: ${response['name']}');
        return Company.fromJson(response);
      } else {
        print('No company found for this employer');
        return null;
      }
    } catch (e) {
      print('Error fetching company: $e');
      return null;
    }
  }

  Future<String> createCompany({
    required String employerId,
    required String name,
    String? description,
  }) async {
    final response = await _supabase
        .from('companies')
        .insert({
          'employer_id': employerId,
          'name': name,
          'description': description,
        })
        .select()
        .single();
    
    return response['id'];
  }

  Future<void> updateCompany({
    required String companyId,
    required String name,
    String? description,
  }) async {
    await _supabase
        .from('companies')
        .update({
          'name': name,
          'description': description,
        })
        .eq('id', companyId);
  }
}