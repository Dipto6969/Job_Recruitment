import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../auth/role_selection_screen.dart';
import '../job_seeker/job_seeker_home.dart';
import '../job_seeker/my_applications_screen.dart';
import '../employer/employer_dashboard.dart';
import '../employer/post_job_screen.dart';
import '../employer/view_applicants_screen.dart';
import 'auth_service.dart';
import '../job_seeker/edit_profile_screen.dart';
import '../employer/edit_employer_profile_screen.dart';
import '../employer/employer_home.dart'; // Add import at top

class RouterService {
  final AuthService _authService;

  RouterService(this._authService);

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: _handleRedirect,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? 'job_seeker';
          return RegisterScreen(role: role);
        },
      ),
      GoRoute(
        path: '/jobs',
        builder: (context, state) => const JobSeekerHome(),
      ),
      GoRoute(
        path: '/my-applications',
        builder: (context, state) => const MyApplicationsScreen(),
      ),
      GoRoute(
        path: '/employer',
        builder: (context, state) => const EmployerHome(), // Changed from EmployerDashboard
      ),
      GoRoute(
        path: '/post-job',
        builder: (context, state) => PostJobScreen(
          company: state.extra as dynamic,
        ),
      ),
      GoRoute(
        path: '/view-applicants',
        builder: (context, state) => ViewApplicantsScreen(
          job: state.extra as dynamic,
        ),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/edit-employer-profile',
        builder: (context, state) => const EditEmployerProfileScreen(),
      ),
    ],
  );

  Future<String?> _handleRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final user = _authService.currentUser;
    final currentPath = state.matchedLocation;

    // Public routes (no auth needed)
    final publicRoutes = ['/login', '/role-selection', '/register'];
    final isPublicRoute = publicRoutes.contains(currentPath);

    // User not logged in
    if (user == null) {
      if (isPublicRoute) {
        return null; // Stay on current public route
      }
      return '/login'; // Redirect to login
    }

    // User IS logged in
    final profile = await _authService.getCurrentProfile();

    // If on public route and logged in, redirect to dashboard
    if (isPublicRoute) {
      if (profile == null) {
        await _authService.signOut();
        return '/login';
      }
      return profile.role == 'job_seeker' ? '/jobs' : '/employer';
    }

    // All other routes - stay where you are
    return null;
  }
}