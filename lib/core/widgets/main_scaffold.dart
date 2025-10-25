import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../constants/route_constants.dart';
import '../theme/app_colors.dart';

/// Main scaffold with bottom navigation bar
class MainScaffold extends StatefulWidget {
  final Widget child;
  final String currentPath;

  const MainScaffold({
    super.key,
    required this.child,
    required this.currentPath,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  DateTime? _lastBackPress;

  int _calculateSelectedIndex(String path) {
    if (path.startsWith(Routes.home)) return 0;
    if (path.startsWith(Routes.issuesList) || path.startsWith(Routes.reportIssue)) return 1;
    if (path.startsWith(Routes.ideasHub) || path.startsWith(Routes.proposeIdea)) return 2;
    if (path.startsWith(Routes.mapView)) return 3;
    if (path.startsWith(Routes.profile)) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(Routes.home);
        break;
      case 1:
        context.go(Routes.issuesList);
        break;
      case 2:
        context.go(Routes.ideasHub);
        break;
      case 3:
        context.go(Routes.mapView);
        break;
      case 4:
        context.go(Routes.profile);
        break;
    }
  }

  Future<bool> _onWillPop() async {
    final currentIndex = _calculateSelectedIndex(widget.currentPath);
    
    // If not on home page, navigate to home
    if (currentIndex != 0) {
      context.go(Routes.home);
      return false;
    }
    
    // If on home page, show exit confirmation with double-tap
    final now = DateTime.now();
    if (_lastBackPress == null || now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    
    // Exit the app
    SystemNavigator.pop();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await _onWillPop();
        }
      },
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _calculateSelectedIndex(widget.currentPath),
          onTap: (index) => _onItemTapped(context, index),
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.report_problem),
              label: 'Issues',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb),
              label: 'Ideas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
