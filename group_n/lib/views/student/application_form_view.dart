/*
 * Student Numbers: (all your group member numbers here)
 * Student Names: (all your group member names here)
 * Question: Application Form Screen
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../routes/route_manager.dart';

class ApplicationFormView extends StatefulWidget {
  const ApplicationFormView({super.key});

  @override
  State<ApplicationFormView> createState() => _ApplicationFormViewState();
}

class _ApplicationFormViewState extends State<ApplicationFormView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // ─── State ─────────────────────────────────────────────────────────────────
  String? _selectedYearOfStudy;
  String? _selectedAcademicLevel1;
  String? _selectedModule1;
  String? _selectedAcademicLevel2;
  String? _selectedModule2;
  bool _eligibilityConfirmed = false;
  bool _addSecondModule = false;
  PlatformFile? _selectedDocument;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  // ─── Constants ─────────────────────────────────────────────────────────────
  static const _primaryColor = Color(0xFF1565C0);
  static const _successColor = Color(0xFF2E7D32);
  static const _borderRadius = 16.0;

  // ─── Data ──────────────────────────────────────────────────────────────────
  final List<String> _yearsOfStudy = const ['1', '2', '3'];
  final List<String> _academicLevels = const [
    'First Year',
    'Second Year',
    'Third Year',
  ];

  final Map<String, List<String>> _modulesByLevel = const {
    'First Year': [
      'TPG116C', 'TPG126C', 'CMN116C', 'CMN126C', 'SOE116C', 'SOE126C',
    ],
    'Second Year': [
      'TPG216C', 'TPG226C', 'CMN216C', 'CMN226C', 'SOE216C', 'SOE226C',
    ],
    'Third Year': [
      'TPG316C', 'TPG326C', 'CMN316C', 'CMN326C', 'SOE316C', 'SOE326C',
    ],
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ─── Actions ───────────────────────────────────────────────────────────────

  Future<void> _pickDocument() async {
    HapticFeedback.selectionClick();
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedDocument = result.files.first);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      _showErrorSnackBar('Please fill in all required fields correctly.');
      return;
    }

    if (!_eligibilityConfirmed) {
      _showErrorSnackBar(
        'Please confirm that you meet the eligibility requirements.',
      );
      return;
    }

    if (_selectedDocument == null) {
      _showErrorSnackBar('Please upload your supporting document.');
      return;
    }

    final success = await context.read<ApplicationViewModel>().submitApplication(
          yearOfStudy: _selectedYearOfStudy!,
          academicLevel1: _selectedAcademicLevel1!,
          module1: _selectedModule1!,
          academicLevel2: _addSecondModule ? _selectedAcademicLevel2 : null,
          module2: _addSecondModule ? _selectedModule2 : null,
          eligibilityConfirmed: _eligibilityConfirmed,
          document: _selectedDocument,
        );

    if (!mounted) return;

    if (success) {
      _showSuccessDialog();
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Application Submitted',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: animation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.shade400,
                                  Colors.green.shade600,
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Application Submitted!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your Student Assistant application has been submitted successfully. You will be notified once it has been reviewed.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            RouteManager.studentHome,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Back to Home',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _removeDocument() {
    setState(() => _selectedDocument = null);
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final appVm = context.watch<ApplicationViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'SA Application Form',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Banner
                  _buildInfoBanner(),

                  const SizedBox(height: 28),

                  // Year of Study
                  _buildDropdownSection(
                    title: 'Year of Study',
                    hint: 'Select your current year',
                    value: _selectedYearOfStudy,
                    items: _yearsOfStudy
                        .map((y) => DropdownMenuItem(value: y, child: Text('Year $y')))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedYearOfStudy = v),
                    validator: (v) => v == null ? 'Please select your year of study' : null,
                    icon: Icons.school_outlined,
                  ),

                  const SizedBox(height: 28),

                  // Module 1 Section
                  _buildModuleSectionHeader('Module 1', required: true),
                  const SizedBox(height: 16),

                  _buildDropdownSection(
                    title: 'Academic Level',
                    hint: 'Select academic level',
                    value: _selectedAcademicLevel1,
                    items: _academicLevels
                        .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                        .toList(),
                    onChanged: (v) => setState(() {
                      _selectedAcademicLevel1 = v;
                      _selectedModule1 = null;
                    }),
                    validator: (v) => v == null ? 'Please select an academic level' : null,
                    icon: Icons.layers_outlined,
                  ),

                  const SizedBox(height: 16),

                  _buildDropdownSection(
                    title: 'Module',
                    hint: 'Select module',
                    value: _selectedModule1,
                    items: _selectedAcademicLevel1 != null
                        ? _modulesByLevel[_selectedAcademicLevel1]!
                            .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                            .toList()
                        : [],
                    onChanged: _selectedAcademicLevel1 != null
                        ? (v) => setState(() => _selectedModule1 = v)
                        : null,
                    validator: (v) => v == null ? 'Please select a module' : null,
                    icon: Icons.menu_book_outlined,
                  ),

                  const SizedBox(height: 28),

                  // Add Second Module Toggle
                  _buildSecondModuleToggle(),

                  // Module 2 Section
                  if (_addSecondModule) ...[
                    const SizedBox(height: 28),
                    _buildModuleSectionHeader('Module 2', required: false),
                    const SizedBox(height: 16),

                    _buildDropdownSection(
                      title: 'Academic Level',
                      hint: 'Select academic level',
                      value: _selectedAcademicLevel2,
                      items: _academicLevels
                          .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                          .toList(),
                      onChanged: (v) => setState(() {
                        _selectedAcademicLevel2 = v;
                        _selectedModule2 = null;
                      }),
                      validator: (v) => _addSecondModule && v == null
                          ? 'Please select an academic level'
                          : null,
                      icon: Icons.layers_outlined,
                    ),

                    const SizedBox(height: 16),

                    _buildDropdownSection(
                      title: 'Module',
                      hint: 'Select module',
                      value: _selectedModule2,
                      items: _selectedAcademicLevel2 != null
                          ? _modulesByLevel[_selectedAcademicLevel2]!
                              .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                              .toList()
                          : [],
                      onChanged: _selectedAcademicLevel2 != null
                          ? (v) => setState(() => _selectedModule2 = v)
                          : null,
                      validator: (v) => _addSecondModule && v == null
                          ? 'Please select a module'
                          : null,
                      icon: Icons.menu_book_outlined,
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Document Upload
                  _buildDocumentUploadSection(),

                  const SizedBox(height: 28),

                  // Eligibility Confirmation
                  _buildEligibilitySection(),

                  const SizedBox(height: 32),

                  // Error Message
                  _buildErrorMessage(appVm),

                  // Submit Button
                  _buildSubmitButton(appVm),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Sub-Builders ──────────────────────────────────────────────────────────

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1565C0).withOpacity(0.08),
            const Color(0xFF42A5F5).withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1565C0).withOpacity(0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF1565C0),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'You may apply for a maximum of two modules. The second module is optional.',
              style: TextStyle(
                color: const Color(0xFF1565C0).withOpacity(0.9),
                fontSize: 13.5,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSection({
    required String title,
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?)? onChanged,
    required String? Function(String?)? validator,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade500),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: _inputDecoration(hint),
          items: items,
          onChanged: onChanged,
          validator: validator,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade900,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ],
    );
  }

  Widget _buildModuleSectionHeader(String title, {required bool required}) {
    return Row(
      children: [
        Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.book_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: required
                ? const Color(0xFF1565C0).withOpacity(0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            required ? 'Required' : 'Optional',
            style: TextStyle(
              fontSize: 11,
              color: required ? const Color(0xFF1565C0) : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondModuleToggle() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _addSecondModule
            ? const Color(0xFF1565C0).withOpacity(0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(
          color: _addSecondModule
              ? const Color(0xFF1565C0).withOpacity(0.2)
              : Colors.grey.shade200,
          width: _addSecondModule ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _addSecondModule
                      ? const Color(0xFF1565C0).withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.add_circle_outline_rounded,
                  size: 20,
                  color: _addSecondModule
                      ? const Color(0xFF1565C0)
                      : Colors.grey.shade500,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Second Module',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Apply for an additional module',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch.adaptive(
            value: _addSecondModule,
            activeColor: const Color(0xFF1565C0),
            activeTrackColor: const Color(0xFF1565C0).withOpacity(0.3),
            onChanged: (value) {
              setState(() {
                _addSecondModule = value;
                if (!value) {
                  _selectedAcademicLevel2 = null;
                  _selectedModule2 = null;
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadSection() {
    final isUploaded = _selectedDocument != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.upload_file_outlined, size: 16, color: Colors.grey.shade500),
            const SizedBox(width: 8),
            Text(
              'Supporting Document',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDocument,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isUploaded ? const Color(0xFFE8F5E9) : Colors.white,
              borderRadius: BorderRadius.circular(_borderRadius),
              border: Border.all(
                color: isUploaded
                    ? const Color(0xFF2E7D32).withOpacity(0.3)
                    : Colors.grey.shade200,
                width: isUploaded ? 1.5 : 1,
              ),
              boxShadow: isUploaded
                  ? [
                      BoxShadow(
                        color: const Color(0xFF2E7D32).withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    gradient: isUploaded
                        ? LinearGradient(
                            colors: [
                              Colors.green.shade400,
                              Colors.green.shade600,
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              Colors.grey.shade100,
                              Colors.grey.shade200,
                            ],
                          ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isUploaded ? Icons.check_rounded : Icons.upload_file_outlined,
                    color: isUploaded ? Colors.white : Colors.grey.shade500,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isUploaded ? _selectedDocument!.name : 'Upload Document',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: isUploaded
                              ? const Color(0xFF2E7D32)
                              : Colors.grey.shade800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isUploaded
                            ? '${(_selectedDocument!.size / 1024).toStringAsFixed(1)} KB • Tap to change'
                            : 'PDF, DOC or DOCX accepted',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isUploaded)
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    onPressed: _removeDocument,
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEligibilitySection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _eligibilityConfirmed
            ? const Color(0xFFE8F5E9)
            : Colors.white,
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(
          color: _eligibilityConfirmed
              ? const Color(0xFF2E7D32).withOpacity(0.3)
              : Colors.grey.shade200,
          width: _eligibilityConfirmed ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.scale(
            scale: 1.1,
            child: Checkbox(
              value: _eligibilityConfirmed,
              activeColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              side: BorderSide(
                color: Colors.grey.shade400,
                width: 1.5,
              ),
              onChanged: (value) {
                setState(() => _eligibilityConfirmed = value ?? false);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'I confirm that I meet the minimum eligibility requirements for the Student Assistant position and that all information provided is accurate.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: _eligibilityConfirmed
                      ? const Color(0xFF2E7D32)
                      : Colors.grey.shade700,
                  height: 1.6,
                  fontWeight: _eligibilityConfirmed
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(ApplicationViewModel appVm) {
    if (appVm.errorMessage == null) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              color: Colors.red.shade700,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              appVm.errorMessage!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(ApplicationViewModel appVm) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: appVm.isLoading
              ? null
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                ),
          color: appVm.isLoading ? Colors.grey.shade300 : null,
          borderRadius: BorderRadius.circular(_borderRadius),
          boxShadow: appVm.isLoading
              ? []
              : [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: appVm.isLoading ? null : _handleSubmit,
            borderRadius: BorderRadius.circular(_borderRadius),
            splashColor: Colors.white.withOpacity(0.2),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: appVm.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Submit Application',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 14,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: const BorderSide(
          color: _primaryColor,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: BorderSide(
          color: Colors.red.shade300,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: const BorderSide(
          color: Color(0xFFD32F2F),
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }
}

