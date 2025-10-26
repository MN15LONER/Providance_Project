import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/route_constants.dart';
import '../providers/admin_provider.dart';
import '../../domain/entities/announcement.dart';
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
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildOverviewTab(statsAsync),
          _buildAnnouncementsTab(),
          _buildIdeasReviewTab(),
          _buildIssuesTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: 'Announcements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: 'Ideas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: 'Issues',
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
    final announcementsAsync = ref.watch(
      announcementsStreamProvider(const AnnouncementFilter()),
    );

    return Column(
      children: [
        // Header with create button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.campaign, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Announcements',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showCreateAnnouncementDialog(context),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('New'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ),

        // Announcements list
        Expanded(
          child: announcementsAsync.when(
            data: (announcements) {
              if (announcements.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.campaign_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No announcements yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first announcement',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  final announcement = announcements[index];
                  return _buildAnnouncementCard(announcement);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) {
              // Print full error to console/logs so the Firebase link can be copied
              print('🔴 ANNOUNCEMENTS ERROR:');
              print('Error: $error');
              print('Stack trace: $stack');
              
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Error loading announcements',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Check the console logs for the Firebase index link',
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.invalidate(announcementsStreamProvider);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementCard(Announcement announcement) {
    IconData typeIcon;
    Color typeColor;

    switch (announcement.type) {
      case 'emergency':
        typeIcon = Icons.warning;
        typeColor = Colors.red;
        break;
      case 'maintenance':
        typeIcon = Icons.build;
        typeColor = Colors.orange;
        break;
      case 'meeting':
        typeIcon = Icons.event;
        typeColor = Colors.blue;
        break;
      default:
        typeIcon = Icons.info;
        typeColor = Colors.grey;
    }

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
                  child: Icon(typeIcon, color: typeColor, size: 20),
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
                      const SizedBox(height: 4),
                      Text(
                        announcement.type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: typeColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDeleteAnnouncement(announcement.id),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              announcement.message,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy • HH:mm')
                      .format(announcement.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                if (announcement.ward != null) ...[
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Ward ${announcement.ward}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAnnouncement(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Announcement'),
        content: const Text(
          'Are you sure you want to delete this announcement? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(adminControllerProvider.notifier)
                  .deleteAnnouncement(id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Announcement deleted successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildIdeasReviewTab() {
    final ideasAsync = ref.watch(allIdeasProvider);

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ideas Review',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ),

        // Ideas list
        Expanded(
          child: ideasAsync.when(
            data: (ideas) {
              if (ideas.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lightbulb_outline,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No ideas submitted yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Sort by votes (priority)
              final sortedIdeas = List.from(ideas)
                ..sort((a, b) => b.voteCount.compareTo(a.voteCount));

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sortedIdeas.length,
                itemBuilder: (context, index) {
                  final idea = sortedIdeas[index];
                  return _buildIdeaCard(idea);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: $error'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIdeaCard(idea) {
    Color statusColor;
    String statusText;

    switch (idea.status) {
      case 'under_review':
        statusColor = Colors.orange;
        statusText = 'Under Review';
        break;
      case 'approved':
        statusColor = Colors.green;
        statusText = 'Approved';
        break;
      case 'not_feasible':
        statusColor = Colors.red;
        statusText = 'Not Feasible';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Open';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Priority badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.thumb_up, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${idea.voteCount}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    idea.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              idea.description,
              style: TextStyle(color: Colors.grey[700]),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  idea.creatorName,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(idea.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _showReviewIdeaDialog(idea),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Review'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReviewIdeaDialog(idea) {
    final responseController = TextEditingController(
      text: idea.officialResponse ?? '',
    );
    final budgetController = TextEditingController(
      text: idea.budget?.toString() ?? '',
    );
    String selectedStatus = idea.status;
    DateTime? timeline;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Review: ${idea.title}'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'open',
                        child: Text('Open'),
                      ),
                      DropdownMenuItem(
                        value: 'under_review',
                        child: Text('Under Review'),
                      ),
                      DropdownMenuItem(
                        value: 'approved',
                        child: Text('Approved'),
                      ),
                      DropdownMenuItem(
                        value: 'not_feasible',
                        child: Text('Not Feasible'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Official Response
                  TextField(
                    controller: responseController,
                    decoration: const InputDecoration(
                      labelText: 'Official Response',
                      border: OutlineInputBorder(),
                      hintText: 'Provide feedback to the community...',
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),

                  // Budget (if approved)
                  if (selectedStatus == 'approved') ...[
                    TextField(
                      controller: budgetController,
                      decoration: const InputDecoration(
                        labelText: 'Budget (R)',
                        border: OutlineInputBorder(),
                        prefixText: 'R ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Timeline
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        timeline != null
                            ? 'Timeline: ${DateFormat('MMM dd, yyyy').format(timeline!)}'
                            : 'Set implementation timeline',
                      ),
                      trailing: timeline != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  timeline = null;
                                });
                              },
                            )
                          : null,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 730)),
                        );
                        if (date != null) {
                          setState(() {
                            timeline = date;
                          });
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                final success = await ref
                    .read(adminControllerProvider.notifier)
                    .updateIdeaStatus(
                      ideaId: idea.id,
                      status: selectedStatus,
                      adminResponse: responseController.text.isNotEmpty
                          ? responseController.text
                          : null,
                      budget: budgetController.text.isNotEmpty
                          ? double.tryParse(budgetController.text)
                          : null,
                      timeline: timeline,
                    );

                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Idea status updated successfully'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssuesTab() {
    final issuesAsync = ref.watch(allIssuesProvider);

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.report_problem, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Issues Management',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),

        // Issues list
        Expanded(
          child: issuesAsync.when(
            data: (issues) {
              if (issues.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No issues reported',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Sort by date (newest first)
              final sortedIssues = List.from(issues)
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sortedIssues.length,
                itemBuilder: (context, index) {
                  final issue = sortedIssues[index];
                  return _buildIssueCard(issue);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: $error'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIssueCard(issue) {
    Color statusColor;
    Color severityColor;

    switch (issue.status) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'in_progress':
        statusColor = Colors.blue;
        break;
      case 'resolved':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    switch (issue.severity) {
      case 'low':
        severityColor = Colors.green;
        break;
      case 'medium':
        severityColor = Colors.orange;
        break;
      case 'high':
        severityColor = Colors.red;
        break;
      case 'critical':
        severityColor = Colors.purple;
        break;
      default:
        severityColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Severity badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    issue.severity.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: severityColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    issue.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    issue.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              issue.category,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              issue.description,
              style: TextStyle(color: Colors.grey[700]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    issue.locationName,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd').format(issue.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _showManageIssueDialog(issue),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Manage'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showManageIssueDialog(issue) {
    final responseController = TextEditingController(
      text: issue.officialResponse ?? '',
    );
    String selectedStatus = issue.status;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Manage: ${issue.title}'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Issue details
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category: ${issue.category}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text('Severity: ${issue.severity}'),
                        const SizedBox(height: 4),
                        Text('Location: ${issue.locationName}'),
                        const SizedBox(height: 4),
                        Text('Reporter: ${issue.reporterName}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Status
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text('Pending'),
                      ),
                      DropdownMenuItem(
                        value: 'in_progress',
                        child: Text('In Progress'),
                      ),
                      DropdownMenuItem(
                        value: 'resolved',
                        child: Text('Resolved'),
                      ),
                      DropdownMenuItem(
                        value: 'rejected',
                        child: Text('Rejected'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Official Response
                  TextField(
                    controller: responseController,
                    decoration: const InputDecoration(
                      labelText: 'Official Response',
                      border: OutlineInputBorder(),
                      hintText: 'Provide update to the reporter...',
                    ),
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                final success = await ref
                    .read(adminControllerProvider.notifier)
                    .updateIssueStatus(
                      issueId: issue.id,
                      status: selectedStatus,
                      officialResponse: responseController.text.isNotEmpty
                          ? responseController.text
                          : null,
                    );

                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Issue updated successfully'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateAnnouncementDialog(BuildContext context) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String selectedType = 'general';
    DateTime? scheduledDate;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Announcement'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Type
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Type *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'general',
                        child: Row(
                          children: [
                            Icon(Icons.info, size: 20),
                            SizedBox(width: 8),
                            Text('General'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'maintenance',
                        child: Row(
                          children: [
                            Icon(Icons.build, size: 20, color: Colors.orange),
                            SizedBox(width: 8),
                            Text('Maintenance'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'emergency',
                        child: Row(
                          children: [
                            Icon(Icons.warning, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Emergency'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'meeting',
                        child: Row(
                          children: [
                            Icon(Icons.event, size: 20, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Meeting'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Message
                  TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      labelText: 'Message *',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),

                  // Scheduled date (optional)
                  if (selectedType == 'maintenance' || selectedType == 'meeting')
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        scheduledDate != null
                            ? 'Scheduled: ${DateFormat('MMM dd, yyyy HH:mm').format(scheduledDate!)}'
                            : 'Schedule for later (optional)',
                      ),
                      trailing: scheduledDate != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  scheduledDate = null;
                                });
                              },
                            )
                          : null,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() {
                              scheduledDate = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty ||
                    messageController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all required fields'),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                try {
                  final success = await ref
                      .read(adminControllerProvider.notifier)
                      .createAnnouncement(
                        title: titleController.text,
                        message: messageController.text,
                        type: selectedType,
                        scheduledFor: scheduledDate,
                      );

                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 12),
                            Text('Announcement created successfully!'),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.error, color: Colors.white),
                            SizedBox(width: 12),
                            Text('Failed to create announcement'),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(child: Text('Error: ${e.toString()}')),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 4),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
