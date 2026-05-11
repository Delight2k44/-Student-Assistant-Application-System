/*
 * Student Numbers: 223022577, 224132354, 222070281, 223043998, 221026798
 * Student Names: TD Tshitangano, L Koloi, MA Mohapi, IR Salam, GA Leeuw
 * Question: Student Application Form View
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../routes/route_manager.dart';

class ApplicationFormView extends StatefulWidget {
  const ApplicationFormView({super.key});

  @override
  State<ApplicationFormView> createState() => _ApplicationFormViewState();
}

class _ApplicationFormViewState extends State<ApplicationFormView> {
  final _formKey = GlobalKey<FormState>();

  // Year of study
  String? _selectedYear;

  // Module 1
  String? _selectedLevel1;
  String? _selectedModule1;

  // Module 2 (optional)
  bool _addSecondModule = false;
  String? _selectedLevel2;
  String? _selectedModule2;

  // Eligibility
  bool _eligibilityConfirmed = false;

  // Document
  File? _selectedDocument;
  String? _documentName;

  bool _isLoading = false;

  // ── Data ──────────────────────────────────────────────────────────────────
  final List<String> _years = ['1', '2', '3'];

  final Map<String, List<String>> _modulesByLevel = {
    '1st Year': [
      'Introduction to Programming',
      'Computer Fundamentals',
      'Mathematics for IT',
      'Communication Skills',
    ],
    '2nd Year': [
      'Data Structures',
      'Object-Oriented Programming',
      'Database Management',
      'Web Development',
    ],
    '3rd Year': [
      'Software Engineering',
      'Mobile Development',
      'Network Administration',
      'Systems Analysis',
    ],
  };

  List<String> get _levels => _modulesByLevel.keys.toList();

  // ── File picker ───────────────────────────────────────────────────────────
  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedDocument = File(result.files.single.path!);
        _documentName = result.files.single.name;
      });
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_eligibilityConfirmed) {
      _showSnack('Please confirm your eligibility before submitting.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final appVM = context.read<ApplicationViewModel>();

      await appVM.submitApplication(
        yearOfStudy: _selectedYear!,
        academicLevel1: _selectedLevel1!,
        module1: _selectedModule1!,
        academicLevel2: _addSecondModule ? _selectedLevel2 : null,
        module2: _addSecondModule ? _selectedModule2 : null,
        eligibilityConfirmed: _eligibilityConfirmed,
        document: _selectedDocument,
      );

      if (!mounted) return;

      _showSnack('Application submitted successfully!');
      Navigator.pushReplacementNamed(context, RouteManager.studentHome);
    } catch (e) {
      if (mounted) _showSnack('Error: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Text(
          'New Application',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionCard(
                title: 'Personal Information',
                icon: Icons.person_outline_rounded,
                children: [
                  _buildDropdown(
                    label: 'Current Year of Study',
                    value: _selectedYear,
                    items: _years.map((y) => 'Year $y').toList(),
                    rawValues: _years,
                    onChanged: (val) => setState(() => _selectedYear = val),
                    validator: (val) =>
                        val == null ? 'Please select your year of study' : null,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _sectionCard(
                title: 'Module 1 (Required)',
                icon: Icons.book_outlined,
                children: [
                  _buildDropdown(
                    label: 'Academic Level',
                    value: _selectedLevel1,
                    items: _levels,
                    onChanged: (val) => setState(() {
                      _selectedLevel1 = val;
                      _selectedModule1 = null;
                    }),
                    validator: (val) =>
                        val == null ? 'Please select an academic level' : null,
                  ),
                  const SizedBox(height: 14),
                  _buildDropdown(
                    label: 'Module',
                    value: _selectedModule1,
                    items: _selectedLevel1 != null
                        ? _modulesByLevel[_selectedLevel1!]!
                        : [],
                    onChanged: (val) => setState(() => _selectedModule1 = val),
                    validator: (val) =>
                        val == null ? 'Please select a module' : null,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Second module toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Apply for a second module',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Optional — maximum of 2 modules per application',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  value: _addSecondModule,
                  activeColor: const Color(0xFF1565C0),
                  onChanged: (val) => setState(() {
                    _addSecondModule = val;
                    if (!val) {
                      _selectedLevel2 = null;
                      _selectedModule2 = null;
                    }
                  }),
                ),
              ),

              if (_addSecondModule) ...[
                const SizedBox(height: 16),
                _sectionCard(
                  title: 'Module 2 (Optional)',
                  icon: Icons.book_outlined,
                  children: [
                    _buildDropdown(
                      label: 'Academic Level',
                      value: _selectedLevel2,
                      items: _levels,
                      onChanged: (val) => setState(() {
                        _selectedLevel2 = val;
                        _selectedModule2 = null;
                      }),
                      validator: (val) => _addSecondModule && val == null
                          ? 'Please select an academic level'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    _buildDropdown(
                      label: 'Module',
                      value: _selectedModule2,
                      items: _selectedLevel2 != null
                          ? _modulesByLevel[_selectedLevel2!]!
                          : [],
                      onChanged: (val) =>
                          setState(() => _selectedModule2 = val),
                      validator: (val) => _addSecondModule && val == null
                          ? 'Please select a module'
                          : null,
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              _sectionCard(
                title: 'Supporting Documentation',
                icon: Icons.attach_file_rounded,
                children: [
                  Text(
                    'Upload your academic transcript or proof of eligibility (PDF, DOC, DOCX).',
                    style:
                        TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickDocument,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedDocument != null
                              ? Colors.green
                              : const Color(0xFF1565C0),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: _selectedDocument != null
                            ? Colors.green.withAlpha(13)
                            : const Color(0xFF1565C0).withAlpha(13),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _selectedDocument != null
                                ? Icons.check_circle_outline
                                : Icons.upload_file_rounded,
                            color: _selectedDocument != null
                                ? Colors.green
                                : const Color(0xFF1565C0),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _documentName ?? 'Tap to upload document',
                              style: TextStyle(
                                color: _selectedDocument != null
                                    ? Colors.green.shade700
                                    : const Color(0xFF1565C0),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _sectionCard(
                title: 'Eligibility Confirmation',
                icon: Icons.verified_outlined,
                children: [
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _eligibilityConfirmed,
                    activeColor: const Color(0xFF1565C0),
                    onChanged: (val) =>
                        setState(() => _eligibilityConfirmed = val ?? false),
                    title: const Text(
                      'I confirm that I meet the minimum requirements for the Student Assistant position and that the information provided is accurate.',
                      style: TextStyle(fontSize: 13),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Submit Application',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1565C0), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    List<String>? rawValues,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    final effectiveItems = rawValues ?? items;

    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF1565C0), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: List.generate(items.length, (i) {
        return DropdownMenuItem(
          value: effectiveItems[i],
          child: Text(items[i]),
        );
      }),
      onChanged: items.isEmpty ? null : onChanged,
      validator: validator,
      hint: Text(
        items.isEmpty ? 'Select level first' : 'Select $label',
        style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      ),
    );
  }
}