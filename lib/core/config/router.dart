import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/role_selection_page.dart';
import '../../features/auth/presentation/pages/profile_setup_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
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
import '../../features/discussions/presentation/pages/discussions_page.dart';
import '../../features/discussions/presentation/pages/discussion_detail_page.dart';
import '../../features/discussions/presentation/pages/new_discussion_page.dart';
import '../constants/route_constants.dart';
import '../widgets/main_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Create a notifier that triggers when auth state changes
  final notifier = ValueNotifier<int>(0);
  
  // Listen to auth state changes and trigger router refresh
  ref.listen(currentUserModelProvider, (previous, next) {
    print('🔔 Auth state changed! Previous user: ${previous?.valueOrNull?.email}, New user: ${next.valueOrNull?.email}');
    notifier.value++;
  });
  
  return GoRouter(
    initialLocation: Routes.login,
    debugLogDiagnostics: true,
    refreshListenable: notifier,
    redirect: (context, state) {
      // Get fresh auth state on every redirect check
      final authState = ref.read(currentUserModelProvider);
      
      // Handle loading state
      if (authState.isLoading) {
        print('🔄 Router: Auth state is loading...');
        return null;
      }

      // Get the current user from auth state (now using UserModel with role field)
      final user = authState.valueOrNull;
      final isLoggedIn = user != null;
      final isAuthRoute = state.matchedLocation == Routes.login ||
          state.matchedLocation == Routes.signup;
      final isAdminRoute = state.matchedLocation == Routes.adminDashboard;

      print('🔍 Router redirect check:');
      print('   - Current location: ${state.matchedLocation}');
      print('   - User logged in: $isLoggedIn');
      print('   - User role: ${user?.role ?? "none"}');
      print('   - Is auth route: $isAuthRoute');
      print('   - Is admin route: $isAdminRoute');

      // If user is not logged in and not on an auth route, redirect to login
      if (!isLoggedIn && !isAuthRoute) {
        print('   ➡️ Redirecting to login (not logged in)');
        return Routes.login;
      }

      // If user is logged in and on an auth route, redirect based on role
      if (isLoggedIn && isAuthRoute) {
        // Check if user is admin
        if (user.role == 'admin') {
          print('   ➡️ Redirecting to admin dashboard (admin user on auth route)');
          return Routes.adminDashboard;
        }
        print('   ➡️ Redirecting to home (regular user on auth route)');
        return Routes.home;
      }

      // If user is admin and trying to access regular home, redirect to admin dashboard
      if (isLoggedIn && user.role == 'admin' && state.matchedLocation == Routes.home) {
        print('   ➡️ Redirecting admin from home to admin dashboard');
        return Routes.adminDashboard;
      }

      // If user is not admin and trying to access admin dashboard, redirect to home
      if (isLoggedIn && user.role != 'admin' && isAdminRoute) {
        print('   ➡️ Redirecting non-admin from admin dashboard to home');
        return Routes.home;
      }

      // No redirect needed
      print('   ✅ No redirect needed');
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
      
      // Discussion Routes
      GoRoute(
        path: Routes.discussions,
        name: RouteNames.discussions,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const DiscussionsPage(),
        ),
      ),
      GoRoute(
        path: Routes.newDiscussion,
        name: RouteNames.newDiscussion,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const NewDiscussionPage(),
        ),
      ),
      GoRoute(
        path: '${Routes.discussions}/:id',
        name: RouteNames.discussionDetail,
        pageBuilder: (context, state) {
          final discussionId = state.pathParameters['id']!;
          return MaterialPage(
            key: state.pageKey,
            child: DiscussionDetailPage(discussionId: discussionId),
          );
        },
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
