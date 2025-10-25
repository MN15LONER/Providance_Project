import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/route_constants.dart';
import '../providers/admin_provider.dart';
import '../../../ideas/presentation/providers/idea_provider.dart';
import '../../../issues/presentation/providers/issue_provider.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(adminStatisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => context.push(Routes.notifications),
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar navigation
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.grey[100],
            selectedIconTheme: const IconThemeData(color: AppColors.primary),
            selectedLabelTextStyle: const TextStyle(color: AppColors.primary),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Overview'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.campaign),
                label: Text('Announcements'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.lightbulb),
                label: Text('Ideas Review'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.report_problem),
                label: Text('Issues'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          
          // Main content
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildOverviewTab(statsAsync),
                _buildAnnouncementsTab(),
                _buildIdeasReviewTab(),
                _buildIssuesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(AsyncValue<Map<String, dynamic>> statsAsync) {
    return statsAsync.when(
      data: (stats) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard Overview',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            
            // Statistics cards
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  'Total Issues',
                  '${stats['totalIssues']}',
                  Icons.report_problem,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Pending Issues',
                  '${stats['pendingIssues']}',
                  Icons.pending,
                  Colors.red,
                ),
                _buildStatCard(
                  'Resolved Issues',
                  '${stats['resolvedIssues']}',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatCard(
                  'Total Users',
                  '${stats['totalUsers']}',
                  Icons.people,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Total Ideas',
                  '${stats['totalIdeas']}',
                  Icons.lightbulb,
                  Colors.purple,
                ),
                _buildStatCard(
                  'Under Review',
                  '${stats['underReviewIdeas']}',
                  Icons.rate_review,
                  Colors.amber,
                ),
                _buildStatCard(
                  'Approved Ideas',
                  '${stats['approvedIdeas']}',
                  Icons.thumb_up,
                  Colors.teal,
                ),
                _buildStatCard(
                  'Resolution Rate',
                  '${((stats['resolvedIssues'] / (stats['totalIssues'] > 0 ? stats['totalIssues'] : 1)) * 100).toStringAsFixed(0)}%',
                  Icons.trending_up,
                  Colors.indigo,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Quick actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildQuickActionButton(
                  'Post Announcement',
                  Icons.campaign,
                  () => _showCreateAnnouncementDialog(context),
                ),
                _buildQuickActionButton(
                  'View All Issues',
                  Icons.list,
                  () => context.push(Routes.issuesList),
                ),
                _buildQuickActionButton(
                  'View All Ideas',
                  Icons.lightbulb_outline,
                  () => context.push(Routes.ideasHub),
                ),
                _buildQuickActionButton(
                  'View Map',
                  Icons.map,
                  () => context.push(Routes.mapView),
                ),
              ],
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading statistics: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(adminStatisticsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    );
  }

  Widget _buildAnnouncementsTab() {
    return const Center(child: Text('Announcements Tab - Coming next'));
  }

  Widget _buildIdeasReviewTab() {
    return const Center(child: Text('Ideas Review Tab - Coming next'));
  }

  Widget _buildIssuesTab() {
    return const Center(child: Text('Issues Tab - Coming next'));
  }

  void _showCreateAnnouncementDialog(BuildContext context) {
    // Will implement this next
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create announcement dialog - Coming next')),
    );
  }
}
