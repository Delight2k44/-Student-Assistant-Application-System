/*
TPG316C Group Assignment - GROUP_A
Student Assistant Application System
Contributor: YOUR_NAME (YOUR_STUDENT_NUMBER) - Authentication Screen (1.1)
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade400, Colors.blue.shade800],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.school,
                        size: 80,
                        color: Colors.blue.shade600,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Student Assistant',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      Text(
                        'Application System',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 32),
                      
                      // FORM
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Consumer<AuthViewModel>(
                              builder: (context, authVM, child) {
                                return TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    errorText: authVM.error != null && 
                                      authVM.email.isEmpty ? authVM.error : null,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (value) {
                                    authVM.email = value;
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Enter your email';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Enter valid email';
                                    }
                                    return null;
                                  },
                                );
                              },
                            ),
                            SizedBox(height: 16),
                            
                            Consumer<AuthViewModel>(
                              builder: (context, authVM, child) {
                                return TextFormField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: Icon(Icons.lock),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    errorText: authVM.error != null && 
                                      authVM.password.isEmpty ? authVM.error : null,
                                  ),
                                  obscureText: true,
                                  onChanged: (value) {
                                    authVM.password = value;
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Enter your password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be 6+ characters';
                                    }
                                    return null;
                                  },
                                );
                              },
                            ),
                            SizedBox(height: 24),
                            
                            Consumer<AuthViewModel>(
                              builder: (context, authVM, child) {
                                return SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: authVM.isLoading 
                                      ? null 
                                      : () async {
                                          if (_formKey.currentState!.validate()) {
                                            await authVM.login(context);
                                          }
                                        },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade600,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: authVM.isLoading
                                        ? CircularProgressIndicator(color: Colors.white)
                                        : Text(
                                            'LOGIN',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Admin/Student Login',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}