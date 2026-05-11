/*
 * Student Numbers: (all your group member numbers here)
 * Student Names: (all your group member names here)
 * Question: Register Screen (Optimized)
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../routes/route_manager.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView>
    with SingleTickerProviderStateMixin {
  // ─── Form & Controllers ────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{
    'fullName': TextEditingController(),
    'studentNumber': TextEditingController(),
    'email': TextEditingController(),
    'password': TextEditingController(),
    'confirmPassword': TextEditingController(),
  };

  // ─── Focus Nodes ───────────────────────────────────────────────────────────
  final _focusNodes = <String, FocusNode>{
    'fullName': FocusNode(),
    'studentNumber': FocusNode(),
    'email': FocusNode(),
    'password': FocusNode(),
    'confirmPassword': FocusNode(),
  };

  // ─── State ─────────────────────────────────────────────────────────────────
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  double _passwordStrength = 0.0;

  // ─── Animation ─────────────────────────────────────────────────────────────
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  // ─── Constants ─────────────────────────────────────────────────────────────
  static const _primaryColor = Color(0xFF1565C0);
  static const _animationDuration = Duration(milliseconds: 800);
  static const _inputSpacing = 20.0;
  static const _cardPadding = 28.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    // Listen to password changes for strength meter
    _controllers['password']!.addListener(_calculatePasswordStrength);

    _animController.forward();
  }

  @override
  void dispose() {
    // Dispose all controllers and focus nodes efficiently
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    _animController.dispose();
    super.dispose();
  }

  // ─── Password Strength Logic ───────────────────────────────────────────────
  void _calculatePasswordStrength() {
    final password = _controllers['password']!.text;
    if (password.isEmpty) {
      if (_passwordStrength != 0.0) {
        setState(() => _passwordStrength = 0.0);
      }
      return;
    }

    double strength = 0.0;
    if (password.length >= 6) strength += 0.2;
    if (password.length >= 10) strength += 0.2;
    if (password.length >= 12) strength += 0.1;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.1;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.1;

    strength = strength.clamp(0.0, 1.0);
    if (strength != _passwordStrength) {
      setState(() => _passwordStrength = strength);
    }
  }

  Color _getPasswordStrengthColor() {
    if (_passwordStrength <= 0.3) return Colors.red.shade400;
    if (_passwordStrength <= 0.5) return Colors.orange.shade400;
    if (_passwordStrength <= 0.7) return Colors.yellow.shade700;
    return Colors.green.shade500;
  }

  String _getPasswordStrengthText() {
    if (_passwordStrength <= 0.3) return 'Weak';
    if (_passwordStrength <= 0.5) return 'Fair';
    if (_passwordStrength <= 0.7) return 'Good';
    return 'Strong';
  }

  // ─── Actions ───────────────────────────────────────────────────────────────
  void _unfocusAll() {
    FocusScope.of(context).unfocus();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }

    _unfocusAll();
    setState(() => _isLoading = true);

    try {
      final result = await context.read<AuthViewModel>().register(
        email: _controllers['email']!.text.trim(),
        password: _controllers['password']!.text.trim(),
        fullName: _controllers['fullName']!.text.trim(),
        studentNumber: _controllers['studentNumber']!.text.trim(),
      );

      if (!mounted) return;

      if (result == 'success') {
        _showSuccessDialog();
      } else {
        _showErrorSnackBar(result ?? 'Registration failed. Please try again.');
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar('An error occurred: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Registration Successful'),
        content: const Text(
          'Your account has been created. Please sign in to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, RouteManager.login);
            },
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _navigateToLogin() => Navigator.pop(context);

  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 36),
                  _buildFormCard(),
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
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: Colors.grey.shade700,
          onPressed: _navigateToLogin,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
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
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryColor.withAlpha(77),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_add_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Create Account',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fill in your details to get started',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(_cardPadding),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              key: 'fullName',
              label: 'Full Name',
              hint: 'John Doe',
              prefixIcon: Icons.person_outlined,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              nextFocus: 'studentNumber',
              validator: _validateFullName,
            ),
            const SizedBox(height: _inputSpacing),
            _buildTextField(
              key: 'studentNumber',
              label: 'Student Number',
              hint: 'e.g. 12345678',
              prefixIcon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              nextFocus: 'email',
              validator: _validateStudentNumber,
            ),
            const SizedBox(height: _inputSpacing),
            _buildTextField(
              key: 'email',
              label: 'Email Address',
              hint: 'name@student.cut.ac.za',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              nextFocus: 'password',
              validator: _validateEmail,
            ),
            const SizedBox(height: _inputSpacing),
            _buildTextField(
              key: 'password',
              label: 'Password',
              hint: 'Create a strong password',
              prefixIcon: Icons.lock_outlined,
              obscureText: _obscurePassword,
              suffixIcon: _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
              textInputAction: TextInputAction.next,
              nextFocus: 'confirmPassword',
              validator: _validatePassword,
            ),
            if (_passwordStrength > 0) ...[
              const SizedBox(height: 10),
              _buildPasswordStrengthIndicator(),
            ],
            const SizedBox(height: _inputSpacing),
            _buildTextField(
              key: 'confirmPassword',
              label: 'Confirm Password',
              hint: 'Re-enter your password',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscureConfirmPassword,
              suffixIcon: _obscureConfirmPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              onSuffixTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleRegister(),
              validator: _validateConfirmPassword,
            ),
            const SizedBox(height: 28),
            _buildRegisterButton(),
            const SizedBox(height: 24),
            _buildLoginLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String key,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.done,
    bool obscureText = false,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    String? nextFocus,
    Function(String)? onFieldSubmitted,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: _controllers[key],
      focusNode: _focusNodes[key],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(prefixIcon, color: _primaryColor),
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon, color: Colors.grey.shade600),
                tooltip: obscureText ? 'Show password' : 'Hide password',
                onPressed: onSuffixTap,
              )
            : null,
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
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade600, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      autocorrect: false,
      enableSuggestions: key != 'password' && key != 'confirmPassword',
      validator: validator,
      onFieldSubmitted: onFieldSubmitted ?? (_) {
        if (nextFocus != null && _focusNodes.containsKey(nextFocus)) {
          _focusNodes[nextFocus]!.requestFocus();
        } else if (textInputAction == TextInputAction.done) {
          _handleRegister();
        }
      },
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _passwordStrength,
              minHeight: 4,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getPasswordStrengthColor(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          _getPasswordStrengthText(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: _getPasswordStrengthColor(),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade400,
          disabledForegroundColor: Colors.white70,
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
                'Create Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          text: 'Already have an account? ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          children: [
            TextSpan(
              text: 'Login',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = _navigateToLogin,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Validators ────────────────────────────────────────────────────────────
  String? _validateFullName(String? value) {
    if (value?.trim().isEmpty ?? true) return 'Full name is required';
    if (value!.trim().length < 2) return 'Must be at least 2 characters';
    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(value.trim())) {
      return 'Only letters, spaces, hyphens and apostrophes allowed';
    }
    return null;
  }

  String? _validateStudentNumber(String? value) {
    if (value?.trim().isEmpty ?? true) return 'Student number is required';
    final trimmed = value!.trim();
    if (trimmed.length < 8) return 'Must be at least 8 characters';
    if (!RegExp(r'^\d+$').hasMatch(trimmed)) return 'Only digits allowed';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value?.trim().isEmpty ?? true) return 'Email is required';
    final trimmed = value!.trim();
    // RFC 5322 simplified
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
    );
    if (!emailRegex.hasMatch(trimmed)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value?.isEmpty ?? true) return 'Password is required';
    if (value!.length < 6) return 'Must be at least 6 characters';
    if (value.length > 128) return 'Max 128 characters allowed';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value?.isEmpty ?? true) return 'Please confirm your password';
    if (value != _controllers['password']!.text) return 'Passwords do not match';
    return null;
  }
}