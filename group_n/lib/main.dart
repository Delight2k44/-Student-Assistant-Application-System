/*
 * Student Numbers: (all your group member numbers here)
 * Student Names: (all your group member names here)
 * Question: Main Entry Point
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/application_viewmodel.dart';
import 'routes/route_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jqovxwkxuahggrzvvhz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impxb3Z4d3hrdXhhaGdncnp2dmh6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc2NzQ1OTAsImV4cCI6MjA5MzI1MDU5MH0.VxNCDwx-BQL5rZO5VGuPzsiNHPQ6ycNLVOJ-rKe9OH0',
  );

  final prefs = await SharedPreferences.getInstance();
  final bool onboardingComplete =
      prefs.getBool('onboarding_complete') ?? false;

  runApp(MyApp(
    startRoute: onboardingComplete
        ? RouteManager.login
        : RouteManager.onboarding,
  ));
}

class MyApp extends StatelessWidget {
  final String startRoute;
  const MyApp({super.key, required this.startRoute});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ApplicationViewModel()),
      ],
      child: MaterialApp(
        title: 'Student Assistant Application System',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        initialRoute: startRoute,
        onGenerateRoute: RouteManager.generateRoute,
      ),
    );
  }
}