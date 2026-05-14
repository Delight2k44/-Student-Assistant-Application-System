import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/application_model.dart';

enum ApplicationFilter { all, pending, approved, rejected }

class AdminViewModel extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  // ─── State ───
  List<StudentApplication> _allApplications = [];
  List<StudentApplication> _filteredApplications = [];
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _errorMessage;
  String? _successMessage;
  ApplicationFilter _currentFilter = ApplicationFilter.all;
  String _searchQuery = '';

  // ─── Getters ───
  List<StudentApplication> get allApplications => _allApplications;
  List<StudentApplication> get filteredApplications => _filteredApplications;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get hasError => _errorMessage != null;
  ApplicationFilter get currentFilter => _currentFilter;
  String get searchQuery => _searchQuery;

  // ─── Computed Stats (always derived from _allApplications) ───
  int get totalCount => _allApplications.length;
  int get pendingCount => _allApplications.where((a) => a.isPending).length;
  int get approvedCount => _allApplications.where((a) => a.isApproved).length;
  int get rejectedCount => _allApplications.where((a) => a.isRejected).length;

  // ─── State Helpers ───
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setUpdating(bool value) {
    _isUpdating = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccess(String message) {
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  // ─── Filtering ───
  void setFilter(ApplicationFilter filter) {
    _currentFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase().trim();
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    var result = List<StudentApplication>.from(_allApplications);

    switch (_currentFilter) {
      case ApplicationFilter.pending:
        result = result.where((a) => a.isPending).toList();
        break;
      case ApplicationFilter.approved:
        result = result.where((a) => a.isApproved).toList();
        break;
      case ApplicationFilter.rejected:
        result = result.where((a) => a.isRejected).toList();
        break;
      case ApplicationFilter.all:
        break;
    }

    if (_searchQuery.isNotEmpty) {
      result = result.where((a) {
        final matchYear = a.yearOfStudy.toLowerCase().contains(_searchQuery);
        final matchModule = a.modules.any((m) => m.toLowerCase().contains(_searchQuery));
        final matchStatus = a.status.toLowerCase().contains(_searchQuery);
        return matchYear || matchModule || matchStatus;
      }).toList();
    }

    _filteredApplications = result;
  }

  void clearFilters() {
    _currentFilter = ApplicationFilter.all;
    _searchQuery = '';
    _filteredApplications = List.from(_allApplications);
    notifyListeners();
  }

  // ─── Read: fetch all applications ───
  Future<void> fetchAllApplications() async {
    clearMessages();
    _setLoading(true);

    try {
      final response = await _supabase
          .from('applications')
          .select('*, profiles:user_id (full_name)')
          .order('created_at', ascending: false);

      _allApplications = (response as List)
          .map((item) => StudentApplication.fromMap(item))
          .toList();

      _applyFilters();
      // Don't set success here — avoid hiding errors from the snackbar
    } on PostgrestException catch (e) {
      debugPrint('Admin fetch error: ${e.message}');
      _setError('Failed to load applications: ${e.message}');
    } catch (e, stackTrace) {
      debugPrint('Admin fetch error: $e\n$stackTrace');
      _setError('An unexpected error occurred while loading applications');
    } finally {
      _setLoading(false);
    }
  }

  // ─── Update: approve or reject (single source of truth) ───
  //
  // FIX 1: Removed the duplicate `approveApplication` method that was
  //         calling .update() but never checking the returned data,
  //         causing silent failures.
  //
  // FIX 2: Added `.select()` after `.update()` so Supabase returns the
  //         updated row. If the row comes back empty it means RLS blocked
  //         the write — we catch that and roll back the optimistic update.
  //
  // FIX 3: `_applyFilters()` + `notifyListeners()` are called after BOTH
  //         the optimistic update AND the rollback, so the stat counters
  //         always reflect the true in-memory state.
  Future<bool> updateApplicationStatus(String appId, String newStatus) async {
    clearMessages();

    final validStatuses = ['pending', 'approved', 'rejected'];
    if (!validStatuses.contains(newStatus)) {
      _setError('Invalid status: $newStatus');
      return false;
    }
    if (appId.isEmpty) {
      _setError('Invalid application ID');
      return false;
    }

    _setUpdating(true);

    // Optimistic update — immediately reflect the change in the UI
    final index = _allApplications.indexWhere((app) => app.id == appId);
    StudentApplication? originalApp;
    if (index != -1) {
      originalApp = _allApplications[index];
      _allApplications[index] = originalApp.copyWith(status: newStatus);
      _applyFilters();
      notifyListeners();
    }

    try {
      // .select() makes Supabase return the updated rows.
      // An empty list means RLS prevented the update.
      final updated = await _supabase
          .from('applications')
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
            'reviewed_by': _supabase.auth.currentUser?.id,
          })
          .eq('id', appId)
          .select();

      if (updated == null || (updated as List).isEmpty) {
        // RLS or policy blocked the write — roll back
        if (index != -1 && originalApp != null) {
          _allApplications[index] = originalApp;
          _applyFilters();
        }
        _setError(
          'Update was blocked. Check that your admin account has the correct '
          'role in the profiles table and that Supabase RLS allows admin writes.',
        );
        _setUpdating(false);
        return false;
      }

      // Success — the optimistic update was correct, keep it
      _setSuccess('Application ${newStatus.toLowerCase()} successfully');
      _setUpdating(false);
      return true;

    } on PostgrestException catch (e) {
      debugPrint('Status update error: ${e.message}');
      if (index != -1 && originalApp != null) {
        _allApplications[index] = originalApp;
        _applyFilters();
      }
      _setError('Failed to update status: ${e.message}');
      _setUpdating(false);
      return false;

    } catch (e, stackTrace) {
      debugPrint('Status update error: $e\n$stackTrace');
      if (index != -1 && originalApp != null) {
        _allApplications[index] = originalApp;
        _applyFilters();
      }
      _setError('An unexpected error occurred');
      _setUpdating(false);
      return false;
    }
  }

  // Convenience wrappers
  Future<bool> approveApplication(String appId) =>
      updateApplicationStatus(appId, 'approved');

  Future<bool> rejectApplication(String appId) =>
      updateApplicationStatus(appId, 'rejected');

  // ─── Bulk Operations ───
  Future<bool> bulkUpdateStatus(List<String> appIds, String newStatus) async {
    clearMessages();
    if (appIds.isEmpty) {
      _setError('No applications selected');
      return false;
    }
    _setUpdating(true);
    try {
      await _supabase
          .from('applications')
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
            'reviewed_by': _supabase.auth.currentUser?.id,
          })
          .inFilter('id', appIds);

      await fetchAllApplications();
      _setSuccess('${appIds.length} applications ${newStatus.toLowerCase()}');
      _setUpdating(false);
      return true;
    } catch (e) {
      debugPrint('Bulk update error: $e');
      _setError('Failed to update applications');
      _setUpdating(false);
      return false;
    }
  }

  @override
  void dispose() {
    clearMessages();
    super.dispose();
  }
}
