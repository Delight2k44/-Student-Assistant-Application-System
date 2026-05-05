/*
 * Student Numbers: (all your group member numbers here)
 * Student Names: (all your group member names here)
 * Question: Route Manager
 */

import 'package:flutter/material.dart';
import '../views/auth/login_view.dart';
import '../views/student/home_view.dart';
import '../views/student/application_form_view.dart';
import '../views/student/application_detail_view.dart';
import '../views/admin/admin_dashboard_view.dart';
import '../views/auth/onboarding_view.dart';
import '../views/auth/register_view.dart';

class RouteManager {
  // Route names
  static const String login = '/';
  static const String studentHome = '/student-home';
  static const String applicationForm = '/application-form';
  static const String applicationDetail = '/application-detail';
  static const String adminDashboard = '/admin-dashboard';
  static const String onboarding = '/onboarding';
  static const String register = '/register';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginView(),
        );

      case studentHome:
        return MaterialPageRoute(
          builder: (_) => const HomeView(),
        );

      case applicationForm:
        return MaterialPageRoute(
          builder: (_) => const ApplicationFormView(),
        );

      case applicationDetail:
        return MaterialPageRoute(
          builder: (_) => const ApplicationDetailView(),
        );

      case adminDashboard:
        return MaterialPageRoute(
          builder: (_) => const AdminDashboardView(),
        );

      case onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingView(),
        );
      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterView(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
