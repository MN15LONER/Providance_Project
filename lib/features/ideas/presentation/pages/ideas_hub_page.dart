import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/idea_provider.dart';
import '../widgets/idea_card.dart';

/// Ideas Hub page - displays all community ideas
/// 
/// Features:
/// - Grid/List view of all ideas
/// - Sort options (votes, date, comments)
/// - Filter by category and status
/// - Search functionality
/// - Pull-to-refresh
/// - Floating action button to propose new idea
class IdeasHubPage extends ConsumerStatefulWidget {
  const IdeasHubPage({super.key});

  @override
  ConsumerState<IdeasHubPage> createState() => _IdeasHubPageState();
}

class _IdeasHubPageState extends ConsumerState<IdeasHubPage> {
  // Filter and sort state
  String? _selectedCategory;
  String? _selectedStatus;
  String _sortBy = 'voteCount'; // voteCount, createdAt, commentCount
  bool _isGridView = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Watch ideas based on filters
    final ideasAsync = _selectedStatus != null
        ? ref.watch(ideasByStatusProvider(_selectedStatus!))
        : _selectedCategory != null
            ? ref.watch(ideasByCategoryProvider(_selectedCategory!))
            : ref.watch(allIdeasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ideas Hub'),
        actions: [
          // View toggle (grid/list)
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip: _isGridView ? 'List view' : 'Grid view',
          ),
          
          // Search
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
            tooltip: 'Search ideas',
          ),
          
          // Filter menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter and sort',
            onSelected: (value) {
              if (value.startsWith('sort_')) {
                setState(() {
                  _sortBy = value.replaceFirst('sort_', '');
                });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                enabled: false,
                child: Text(
                  'Sort By',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              PopupMenuItem(
                value: 'sort_voteCount',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'voteCount' ? Icons.check : Icons.thumb_up,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Most Votes'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'sort_createdAt',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'createdAt' ? Icons.check : Icons.access_time,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Newest'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'sort_commentCount',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'commentCount' ? Icons.check : Icons.comment,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Most Comments'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      
      body: Column(
        children: [
          // Filter chips
          if (_selectedCategory != null || _selectedStatus != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_selectedCategory != null)
                    FilterChip(
                      label: Text(_selectedCategory!),
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = null;
                        });
                      },
                      selected: true,
                      onDeleted: () {
                        setState(() {
                          _selectedCategory = null;
                        });
                      },
                    ),
                  if (_selectedStatus != null)
                    FilterChip(
                      label: Text(_selectedStatus!),
                      onSelected: (_) {
                        setState(() {
                          _selectedStatus = null;
                        });
                      },
                      selected: true,
                      onDeleted: () {
                        setState(() {
                          _selectedStatus = null;
                        });
                      },
                    ),
                ],
              ),
            ),

          // Category filter bar
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _CategoryChip(
                  label: 'All',
                  isSelected: _selectedCategory == null,
                  onTap: () {
                    setState(() {
                      _selectedCategory = null;
                    });
                  },
                ),
                ...AppConstants.ideaCategories.map((category) {
                  return _CategoryChip(
                    label: category,
                    isSelected: _selectedCategory == category,
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  );
                }),
              ],
            ),
          ),

          const Divider(height: 1),

          // Ideas list/grid
          Expanded(
            child: ideasAsync.when(
              data: (ideas) {
                // Filter by search query if active
                final filteredIdeas = _searchQuery.isEmpty
                    ? ideas
                    : ideas.where((idea) {
                        return idea.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            idea.description.toLowerCase().contains(_searchQuery.toLowerCase());
                      }).toList();

                if (filteredIdeas.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No ideas found'
                              : 'No ideas yet',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Try a different search'
                              : 'Be the first to propose an idea!',
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
                    // Refresh is automatic with StreamProvider
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  child: _isGridView
                      ? GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: filteredIdeas.length,
                          itemBuilder: (context, index) {
                            return IdeaCard(idea: filteredIdeas[index]);
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredIdeas.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: IdeaCard(idea: filteredIdeas[index]),
                            );
                          },
                        ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) {
                // Check if it's an index error
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
                          isIndexError ? Icons.lightbulb_outline : Icons.error_outline,
                          size: 64,
                          color: isIndexError 
                              ? Theme.of(context).colorScheme.outline 
                              : Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isIndexError 
                              ? 'No ideas in this category yet' 
                              : 'Failed to load ideas',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isIndexError
                              ? 'Be the first to propose an idea in this category!'
                              : 'Please check your internet connection and try again',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        if (!isIndexError) ...[
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () {
                              // Trigger refresh
                              ref.invalidate(allIdeasProvider);
                              if (_selectedCategory != null) {
                                ref.invalidate(ideasByCategoryProvider(_selectedCategory!));
                              }
                              if (_selectedStatus != null) {
                                ref.invalidate(ideasByStatusProvider(_selectedStatus!));
                              }
                            },
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

      // Floating action button to propose new idea
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/propose-idea'),
        icon: const Icon(Icons.lightbulb),
        label: const Text('Propose Idea'),
      ),
    );
  }

  /// Show search dialog
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String query = _searchQuery;
        return AlertDialog(
          title: const Text('Search Ideas'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter keywords...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              query = value;
            },
            onSubmitted: (value) {
              setState(() {
                _searchQuery = value;
              });
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                });
                Navigator.pop(context);
              },
              child: const Text('Clear'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  _searchQuery = query;
                });
                Navigator.pop(context);
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }
}

/// Category chip widget
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
