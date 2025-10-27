import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:muni_report_pro/features/auth/presentation/providers/auth_provider.dart';
import 'package:muni_report_pro/features/auth/presentation/providers/auth_controller.dart';
import 'package:muni_report_pro/core/constants/route_constants.dart';
import 'package:muni_report_pro/core/theme/app_colors.dart';
import 'package:muni_report_pro/features/announcements/presentation/providers/announcements_provider.dart';
import 'package:muni_report_pro/features/issues/presentation/providers/issue_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userModelAsync = ref.watch(currentUserModelProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muni-Report Pro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(currentUserModelProvider),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  context.go(Routes.profile);
                  break;
                case 'logout':
                  _handleLogout(context, ref);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: userModelAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('No user data found'),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome section
                Card(
                  color: AppColors.primary.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: user.photoURL != null
                              ? NetworkImage(user.photoURL!)
                              : null,
                          child: user.photoURL == null
                              ? Text(
                                  user.displayName?.isNotEmpty == true
                                      ? user.displayName![0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(fontSize: 24),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back, ${user.displayName ?? 'User'}!',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${user.role?.toUpperCase() ?? 'CITIZEN'} • ${user.municipality ?? 'No municipality'}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: CustomPaint(
                            painter: _StarPainter(color: AppColors.primary),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '${user.points}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Announcements Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Announcements',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go(Routes.announcements),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _AnnouncementsSection(),
                const SizedBox(height: 24),
                
                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _QuickActionCard(
                      title: 'Report Issue',
                      icon: Icons.report_problem,
                      color: Colors.red,
                      onTap: () => context.go(Routes.reportIssue),
                    ),
                    _QuickActionCard(
                      title: 'View Issues',
                      icon: Icons.list_alt,
                      color: Colors.orange,
                      onTap: () => context.go(Routes.issuesList),
                    ),
                    _QuickActionCard(
                      title: 'Community',
                      icon: Icons.forum,
                      color: Colors.purple,
                      onTap: () => context.go(Routes.discussions),
                    ),
                    _QuickActionCard(
                      title: 'Ideas Hub',
                      icon: Icons.lightbulb,
                      color: Colors.blue,
                      onTap: () => context.go(Routes.ideasHub),
                    ),
                    _QuickActionCard(
                      title: 'Map View',
                      icon: Icons.map,
                      color: Colors.green,
                      onTap: () => context.go(Routes.mapView),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Recent Activity
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildRecentActivity(context, ref),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(currentUserModelProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authControllerProvider.notifier).signOut();
      if (context.mounted) {
        context.go(Routes.login);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildRecentActivity(BuildContext context, WidgetRef ref) {
    final issuesAsync = ref.watch(recentIssuesProvider);

    return issuesAsync.when(
      data: (issues) {
        if (issues.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No recent activity',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (int i = 0; i < min(issues.length, 5); i++) ...[
                  if (i > 0) const Divider(),
                  ListTile(
                    leading: Icon(
                      _getStatusIcon(issues[i].status),
                      color: _getStatusColor(issues[i].status),
                    ),
                    title: Text(
                      '${_getStatusLabel(issues[i].status)}: ${issues[i].title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      issues[i].description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      timeago.format(issues[i].updatedAt),
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () => context.push('${Routes.issueDetail}/${issues[i].id}'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) {
        // Print error to console for debugging
        print('🔴 Recent Activity Error: $error');
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.orange, size: 32),
                const SizedBox(height: 8),
                Text(
                  'Error loading activity',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Check console for Firebase index link',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => ref.invalidate(recentIssuesProvider),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'resolved':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.pending;
      case 'pending':
        return Icons.hourglass_empty;
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'resolved':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'resolved':
        return 'Resolved';
      case 'in_progress':
        return 'In Progress';
      case 'pending':
        return 'Pending';
      default:
        return 'Issue';
    }
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter to draw a star shape
class _StarPainter extends CustomPainter {
  final Color color;

  _StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.4;

    // Draw a 5-pointed star
    for (int i = 0; i < 5; i++) {
      final outerAngle = (i * 72 - 90) * 3.14159 / 180;
      final innerAngle = ((i * 72) + 36 - 90) * 3.14159 / 180;

      final outerX = centerX + outerRadius * cos(outerAngle);
      final outerY = centerY + outerRadius * sin(outerAngle);

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }

      final innerX = centerX + innerRadius * cos(innerAngle);
      final innerY = centerY + innerRadius * sin(innerAngle);
      path.lineTo(innerX, innerY);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Announcements section widget
class _AnnouncementsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(announcementsProvider);

    return announcementsAsync.when(
      data: (announcements) {
        if (announcements.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.campaign_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No announcements yet',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Show only the first 3 announcements
        final recentAnnouncements = announcements.take(3).toList();

        return Column(
          children: recentAnnouncements.map((announcement) {
            return _AnnouncementCard(announcement: announcement);
          }).toList(),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Error loading announcements',
            style: TextStyle(color: Colors.red[700]),
          ),
        ),
      ),
    );
  }
}

/// Individual announcement card widget
class _AnnouncementCard extends StatelessWidget {
  final dynamic announcement;

  const _AnnouncementCard({required this.announcement});

  Color _getTypeColor(String type) {
    switch (type) {
      case 'emergency':
        return Colors.red;
      case 'maintenance':
        return Colors.orange;
      case 'meeting':
        return Colors.blue;
      default:
        return AppColors.primary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'emergency':
        return Icons.warning;
      case 'maintenance':
        return Icons.build;
      case 'meeting':
        return Icons.event;
      default:
        return Icons.campaign;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(announcement.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTypeIcon(announcement.type),
                    color: typeColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcement.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        timeago.format(announcement.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    announcement.type.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: typeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              announcement.message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
