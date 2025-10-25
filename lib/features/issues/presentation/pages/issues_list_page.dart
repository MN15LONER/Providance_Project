import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/issue_provider.dart';

class IssuesListPage extends ConsumerStatefulWidget {
  const IssuesListPage({super.key});

  @override
  ConsumerState<IssuesListPage> createState() => _IssuesListPageState();
}

class _IssuesListPageState extends ConsumerState<IssuesListPage> {
  String? _selectedCategory;
  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    // Watch issues based on filters
    final issuesAsync = _selectedStatus != null
        ? ref.watch(issuesByStatusProvider(_selectedStatus!))
        : _selectedCategory != null
            ? ref.watch(issuesByCategoryProvider(_selectedCategory!))
            : ref.watch(allIssuesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Issues'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onSelected: (value) {
              setState(() {
                if (value == 'all') {
                  _selectedCategory = null;
                  _selectedStatus = null;
                } else if (AppConstants.issueCategories.contains(value)) {
                  _selectedCategory = value;
                  _selectedStatus = null;
                } else {
                  _selectedStatus = value;
                  _selectedCategory = null;
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Issues'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                enabled: false,
                child: Text(
                  'By Category',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ...AppConstants.issueCategories.map(
                (category) => PopupMenuItem(
                  value: category,
                  child: Text(_formatCategory(category)),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                enabled: false,
                child: Text(
                  'By Status',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ...IssueStatus.all.map(
                (status) => PopupMenuItem(
                  value: status,
                  child: Text(_formatStatus(status)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Active filters
          if (_selectedCategory != null || _selectedStatus != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedCategory != null
                          ? 'Category: ${_formatCategory(_selectedCategory!)}'
                          : 'Status: ${_formatStatus(_selectedStatus!)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      setState(() {
                        _selectedCategory = null;
                        _selectedStatus = null;
                      });
                    },
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
                        Icon(
                          Icons.report_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No issues found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedCategory != null || _selectedStatus != null
                              ? 'Try a different filter'
                              : 'No issues have been reported yet',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(allIssuesProvider);
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: issues.length,
                    itemBuilder: (context, index) {
                      final issue = issues[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => context.push('/issue/${issue.id}'),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _StatusBadge(status: issue.status),
                                    const Spacer(),
                                    Text(
                                      _formatCategory(issue.category),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  issue.title,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  issue.description,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Theme.of(context).colorScheme.outline,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        issue.locationName,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).colorScheme.outline,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) {
                final errorStr = error.toString();
                final isIndexError = errorStr.contains('requires an index') || 
                                    errorStr.contains('FAILED_PRECONDITION');
                
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isIndexError ? Icons.report_outlined : Icons.error_outline,
                          size: 64,
                          color: isIndexError 
                              ? Theme.of(context).colorScheme.outline 
                              : Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isIndexError 
                              ? 'No issues in this category yet' 
                              : 'Failed to load issues',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isIndexError
                              ? 'Be the first to report an issue!'
                              : 'Please check your internet connection',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        if (!isIndexError) ...[
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () => ref.invalidate(allIssuesProvider),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/report-issue'),
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Report Issue'),
      ),
    );
  }

  String _formatCategory(String category) {
    return category.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  String _formatStatus(String status) {
    return status.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case 'in_progress':
        color = Colors.blue;
        icon = Icons.engineering;
        break;
      case 'resolved':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.split('_').map((word) {
              return word[0].toUpperCase() + word.substring(1);
            }).join(' '),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
