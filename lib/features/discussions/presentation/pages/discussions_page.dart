import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/route_constants.dart';
import '../providers/discussions_provider.dart';
import '../../domain/entities/discussion.dart';

class DiscussionsPage extends ConsumerWidget {
  const DiscussionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discussionsAsync = ref.watch(discussionsProvider);

    return WillPopScope(
      onWillPop: () async {
        context.go(Routes.home);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Community Discussions'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.invalidate(discussionsProvider),
            ),
          ],
        ),
      body: discussionsAsync.when(
        data: (discussions) {
          if (discussions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.forum_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No discussions yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a conversation with your community',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(discussionsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: discussions.length,
              itemBuilder: (context, index) {
                final discussion = discussions[index];
                return _DiscussionCard(
                  discussion: discussion,
                  onTap: () => context.push(
                    '${Routes.discussions}/${discussion.id}',
                  ),
                );
              },
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
                onPressed: () => ref.invalidate(discussionsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.newDiscussion),
        icon: const Icon(Icons.add),
        label: const Text('New Discussion'),
      ),
      ),
    );
  }
}

class _DiscussionCard extends ConsumerWidget {
  final Discussion discussion;
  final VoidCallback onTap;

  const _DiscussionCard({
    required this.discussion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author info
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: discussion.authorPhotoURL != null
                        ? NetworkImage(discussion.authorPhotoURL!)
                        : null,
                    child: discussion.authorPhotoURL == null
                        ? Text(
                            discussion.authorName.isNotEmpty
                                ? discussion.authorName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(fontSize: 14),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          discussion.authorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          timeago.format(discussion.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (discussion.ward != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        discussion.ward!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Title
              Text(
                discussion.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Content preview
              Text(
                discussion.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              
              // Tags
              if (discussion.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: discussion.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Stats
              Row(
                children: [
                  Icon(
                    Icons.favorite,
                    size: 16,
                    color: discussion.likesCount > 0
                        ? Colors.red
                        : Colors.grey[400],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${discussion.likesCount}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.comment,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${discussion.commentsCount}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
