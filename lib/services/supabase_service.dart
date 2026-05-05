// ignore_for_file: avoid_print

/*
TPG316C Group Assignment - GROUP_A
Contributor: YOUR_NAME (YOUR_STUDENT_NUMBER) - Authentication Screen
*/

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<UserModel?> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        return UserModel.fromJson(response.user!.toJson());
      }
      return null;
    } catch (e) {
      print('Auth error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;
}