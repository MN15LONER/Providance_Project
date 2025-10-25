import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/role_selection_page.dart';
import '../../features/auth/presentation/pages/profile_setup_page.dart';
import '../../features/auth/presentation/providers/auth_controller.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/issues/presentation/pages/report_issue_page.dart';
import '../../features/issues/presentation/pages/issue_detail_page.dart';
import '../../features/issues/presentation/pages/issues_list_page.dart';
import '../../features/ideas/presentation/pages/ideas_hub_page.dart';
import '../../features/ideas/presentation/pages/propose_idea_page.dart';
import '../../features/ideas/presentation/pages/idea_detail_page.dart';
import '../../features/map/presentation/pages/map_view_page.dart';
import '../../features/announcements/presentation/pages/announcements_page.dart';
import '../../features/announcements/presentation/pages/notification_center_page.dart';
import '../../features/gamification/presentation/pages/leaderboard_page.dart';
import '../../features/gamification/presentation/pages/points_history_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/my_contributions_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../constants/route_constants.dart';
import '../widgets/main_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);
  
  return GoRouter(
    initialLocation: Routes.login,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Handle loading state
      if (authState.isLoading) return null;

      // Get the current user from auth state
      final user = authState.valueOrNull;
      final isLoggedIn = user != null;
      final isAuthRoute = state.matchedLocation == Routes.login ||
          state.matchedLocation == Routes.signup;

      // If user is not logged in and not on an auth route, redirect to login
      if (!isLoggedIn && !isAuthRoute) {
        return Routes.login;
      }

      // If user is logged in and on an auth route, redirect to home
      if (isLoggedIn && isAuthRoute) {
        return Routes.home;
      }

      // No redirect needed
      return null;
    },
    routes: [
      // Auth Routes (without bottom nav)
      GoRoute(
        path: Routes.login,
        name: RouteNames.login,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: Routes.signup,
        name: RouteNames.signup,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SignupPage(),
        ),
      ),
      GoRoute(
        path: Routes.roleSelection,
        name: RouteNames.roleSelection,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const RoleSelectionPage(),
        ),
      ),
      GoRoute(
        path: Routes.profileSetup,
        name: RouteNames.profileSetup,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ProfileSetupPage(),
        ),
      ),
      
      // Main App Routes with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(
            currentPath: state.matchedLocation,
            child: child,
          );
        },
        routes: [
          // Home
          GoRoute(
            path: Routes.home,
            name: RouteNames.home,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const HomePage(),
            ),
          ),
          
          // Issues List
          GoRoute(
            path: Routes.issuesList,
            name: RouteNames.issuesList,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const IssuesListPage(),
            ),
          ),
          
          // Ideas Hub
          GoRoute(
            path: Routes.ideasHub,
            name: RouteNames.ideasHub,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const IdeasHubPage(),
            ),
          ),
          
          // Map View
          GoRoute(
            path: Routes.mapView,
            name: RouteNames.mapView,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const MapViewPage(),
            ),
          ),
          
          // Profile
          GoRoute(
            path: Routes.profile,
            name: RouteNames.profile,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ProfilePage(),
            ),
          ),
        ],
      ),
      
      // Secondary Routes (without bottom nav)
      GoRoute(
        path: Routes.editProfile,
        name: RouteNames.editProfile,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const EditProfilePage(),
        ),
      ),
      GoRoute(
        path: Routes.myContributions,
        name: RouteNames.myContributions,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const MyContributionsPage(),
        ),
      ),
      
      // Issue Routes (without bottom nav)
      GoRoute(
        path: Routes.reportIssue,
        name: RouteNames.reportIssue,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ReportIssuePage(),
        ),
      ),
      GoRoute(
        path: '${Routes.issueDetail}/:id',
        name: RouteNames.issueDetail,
        pageBuilder: (context, state) {
          final issueId = state.pathParameters['id']!;
          return MaterialPage(
            key: state.pageKey,
            child: IssueDetailPage(issueId: issueId),
          );
        },
      ),
      
      // Ideas Routes (without bottom nav)
      GoRoute(
        path: Routes.proposeIdea,
        name: RouteNames.proposeIdea,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ProposeIdeaPage(),
        ),
      ),
      GoRoute(
        path: '${Routes.ideaDetail}/:id',
        name: RouteNames.ideaDetail,
        pageBuilder: (context, state) {
          final ideaId = state.pathParameters['id']!;
          return MaterialPage(
            key: state.pageKey,
            child: IdeaDetailPage(ideaId: ideaId),
          );
        },
      ),
      
      // Settings Route (without bottom nav)
      GoRoute(
        path: Routes.settings,
        name: RouteNames.settings,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SettingsPage(),
        ),
      ),
      
      // Announcements Routes
      GoRoute(
        path: Routes.announcements,
        name: RouteNames.announcements,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const AnnouncementsPage(),
        ),
      ),
      GoRoute(
        path: Routes.notifications,
        name: RouteNames.notifications,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const NotificationCenterPage(),
        ),
      ),
      
      // Gamification Routes
      GoRoute(
        path: Routes.leaderboard,
        name: RouteNames.leaderboard,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const LeaderboardPage(),
        ),
      ),
      GoRoute(
        path: Routes.pointsHistory,
        name: RouteNames.pointsHistory,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const PointsHistoryPage(),
        ),
      ),
      
      // Admin Routes
      GoRoute(
        path: Routes.adminDashboard,
        name: RouteNames.adminDashboard,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const AdminDashboardPage(),
        ),
      ),
    ],
    errorPageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: Scaffold(
        body: Center(
          child: Text('Error: ${state.error}'),
        ),
      ),
    ),
  );
});
