import 'package:supabase_flutter/supabase_flutter.dart';

/// Central place to access Supabase from the app.
///
/// This app is currently used in widget tests, where Supabase is not
/// initialized. Use [tryGetSupabaseClient] to avoid crashes.
class SupabaseService {
  SupabaseService._internal();

  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() => _instance;

  SupabaseClient? tryGetSupabaseClient() {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  bool get isInitialized {
    try {
      // If this throws, Supabase isn't initialized.
      // ignore: unnecessary_statements
      Supabase.instance;
      return true;
    } catch (_) {
      return false;
    }
  }
}

