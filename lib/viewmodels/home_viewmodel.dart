import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/application_model.dart';

class HomeViewModel extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<StudentApplication> _applications = [];
  bool _isLoading = false;

  // FIX 4: Real-time subscription so the student's status badge updates
  //        automatically when the admin approves or rejects — no manual
  //        refresh needed.
  StreamSubscription<List<Map<String, dynamic>>>? _realtimeSubscription;

  List<StudentApplication> get applications => _applications;
  bool get isLoading => _isLoading;

  // Call this once after the widget mounts
  void startListening() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Subscribe to changes on this user's own rows
    _realtimeSubscription = _supabase
        .from('applications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .listen(
          (data) {
            _applications = data
                .map((item) =>
                    StudentApplication.fromMap(item as Map<String, dynamic>))
                .toList();
            notifyListeners();
          },
          onError: (e) => debugPrint('Real-time error: $e'),
        );
  }

  // One-shot fetch (for pull-to-refresh)
  Future<void> fetchApplications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser!.id;
      final response = await _supabase
          .from('applications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _applications = (response as List)
          .map((item) =>
              StudentApplication.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching applications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }
}
