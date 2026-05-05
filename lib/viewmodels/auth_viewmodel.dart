/*
TPG316C Group Assignment - GROUP_A
Contributor: MATHABO 222070281 - Authentication Screen
*/

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';

class AuthViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String? _error;
  UserModel? _user;

  String get email => _email;
  String get password => _password;
  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get user => _user;

  set email(String value) {
    _email = value;
    notifyListeners();
  }

  set password(String value) {
    _password = value;
    notifyListeners();
  }

  Future<bool> login(BuildContext context) async {
  if (_email.isEmpty || _password.isEmpty) {
    _error = 'Please fill all fields';
    notifyListeners();
    return false;
  }

  _isLoading = true;
  _error = null;
  notifyListeners();

  final user = await _supabaseService.signIn(_email, _password);

  _isLoading = false;
  if (user != null) {
    _user = user;

    // ✅ Check if context is still valid before navigation
    if (!context.mounted) return false;

    // Navigate based on role
    if (user.role == 'admin') {
      Navigator.pushReplacementNamed(context, '/admin/dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/student/home');
    }
    return true;
  } else {
    _error = 'Invalid credentials';
  }

  notifyListeners();
  return false;
  }
}