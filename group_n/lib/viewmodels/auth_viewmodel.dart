/*
 * Student Numbers: (all your group member numbers here)
 * Student Names: (all your group member names here)
 * Question: Auth ViewModel
 */

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

class AuthViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  ProfileModel? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAdmin => _profile?.role == 'admin';
  bool get isLoggedIn => _supabase.auth.currentUser != null;

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _fetchProfile(response.user!.id);
        _isLoading = false;
        notifyListeners();
        return _profile?.role;
      }
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Login failed. Please check your credentials.';
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<String?> register({
    required String email,
    required String password,
    required String fullName,
    required String studentNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'student_number': studentNumber,
        },
      );

      if (response.user != null) {
        await _supabase.from('profiles').upsert({
          'id': response.user!.id,
          'full_name': fullName,
          'student_number': studentNumber,
          'role': 'student',
        });

        _isLoading = false;
        notifyListeners();
        return 'success';
      } else {
        _errorMessage = 'Registration failed. Please try again.';
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = 'Something went wrong: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> _fetchProfile(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      _profile = ProfileModel.fromMap(data);
    } catch (e) {
      _errorMessage = 'Failed to load profile.';
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    _profile = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

