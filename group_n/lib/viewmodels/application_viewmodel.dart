/*
 * Student Numbers: (all your group member numbers here)
 * Student Names: (all your group member names here)
 * Question: Application ViewModel
 */

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import '../models/application_model.dart';

class ApplicationViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<ApplicationModel> _applications = [];
  ApplicationModel? _selectedApplication;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  List<ApplicationModel> get applications => _applications;
  ApplicationModel? get selectedApplication => _selectedApplication;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void selectApplication(ApplicationModel app) {
    _selectedApplication = app;
    notifyListeners();
  }

  Future<void> fetchMyApplications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser!.id;
      final data = await _supabase
          .from('applications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _applications = (data as List)
          .map((item) => ApplicationModel.fromMap(item))
          .toList();
    } catch (e) {
      _errorMessage = 'Failed to load applications.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllApplications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _supabase
          .from('applications')
          .select()
          .order('created_at', ascending: false);

      _applications = (data as List)
          .map((item) => ApplicationModel.fromMap(item))
          .toList();
    } catch (e) {
      _errorMessage = 'Failed to load applications.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> submitApplication({
    required String yearOfStudy,
    required String academicLevel1,
    required String module1,
    String? academicLevel2,
    String? module2,
    required bool eligibilityConfirmed,
    PlatformFile? document,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser!.id;

      final existing = await _supabase
          .from('applications')
          .select()
          .eq('user_id', userId);

      if ((existing as List).isNotEmpty) {
        _errorMessage = 'You already have a submitted application.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      String? documentUrl;

      if (document != null && document.bytes != null) {
        final filePath = '$userId/${document.name}';
        await _supabase.storage
            .from('application_documents')
            .uploadBinary(filePath, document.bytes!);

        documentUrl = _supabase.storage
            .from('application_documents')
            .getPublicUrl(filePath);
      }

      await _supabase.from('applications').insert({
        'user_id': userId,
        'year_of_study': yearOfStudy,
        'academic_level_1': academicLevel1,
        'module_1': module1,
        'academic_level_2': academicLevel2,
        'module_2': module2,
        'eligibility_confirmed': eligibilityConfirmed,
        'document_url': documentUrl,
        'status': 'pending',
      });

      _successMessage = 'Application submitted successfully.';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to submit application. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateApplication({
    required String applicationId,
    required String yearOfStudy,
    required String academicLevel1,
    required String module1,
    String? academicLevel2,
    String? module2,
    required bool eligibilityConfirmed,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabase.from('applications').update({
        'year_of_study': yearOfStudy,
        'academic_level_1': academicLevel1,
        'module_1': module1,
        'academic_level_2': academicLevel2,
        'module_2': module2,
        'eligibility_confirmed': eligibilityConfirmed,
      }).eq('id', applicationId);

      _successMessage = 'Application updated successfully.';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update application.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteApplication(String applicationId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabase
          .from('applications')
          .delete()
          .eq('id', applicationId);

      _applications.removeWhere((app) => app.id == applicationId);
      _successMessage = 'Application deleted successfully.';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete application.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateApplicationStatus(String applicationId, String status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabase
          .from('applications')
          .update({'status': status})
          .eq('id', applicationId);

      await fetchAllApplications();

      _successMessage = 'Application $status successfully.';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update status.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}

