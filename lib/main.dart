/*
TPG316C Group Assignment - GROUP_A
Student Assistant Application System
All Group Members - Initial Setup
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ⚠️ REPLACE WITH YOUR SUPABASE URL & ANON KEY
  await Supabase.initialize(
    url: 'https://pxspyrznakjkaprpderm.supabase.co',
    anonKey: 'sb_publishable_0oM9YIyTT1jHX7BU1GUSLQ_n2AHJMlR',
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: MaterialApp(
        title: 'Student Assistant System',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: LoginScreen(),
        // Add these routes later
        routes: {
          '/student/home': (context) => Scaffold(body: Center(child: Text('Student Home'))),
          '/admin/dashboard': (context) => Scaffold(body: Center(child: Text('Admin Dashboard'))),
        },
      ),
    );
  }
}