import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../domain/entities/idea.dart';
import 'vote_button.dart';

/// Idea card widget for displaying ideas in lists
/// 
/// Shows idea information in a compact card format:
/// - Title and description preview
/// - Category badge
/// - Status indicator
/// - Creator information
/// - Vote button (compact mode)
/// - Comment count
/// - Timestamp
/// 
/// Taps navigate to idea detail page.
class IdeaCard extends StatelessWidget {
  /// The idea to display
  final Idea idea;
  
  /// Whether to show the full description or truncate it
  final bool showFullDescription;

  const IdeaCard({
    super.key,
    required this.idea,
    this.showFullDescription = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/idea/${idea.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Status badge and timestamp
              Row(
                children: [
                  _StatusBadge(status: idea.status),
                  const Spacer(),
                  Text(
                    timeago.format(idea.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                idea.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Description preview
              Text(
                idea.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: showFullDescription ? null : 3,
                overflow: showFullDescription ? null : TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Category and Budget chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text(idea.category),
                    avatar: Icon(
                      _getCategoryIcon(idea.category),
                      size: 16,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  Chip(
                    label: Text(idea.budget),
                    avatar: const Icon(
                      Icons.attach_money,
                      size: 16,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Creator info
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: idea.creatorPhoto != null
                        ? NetworkImage(idea.creatorPhoto!)
                        : null,
                    child: idea.creatorPhoto == null
                        ? Text(
                            idea.creatorName[0].toUpperCase(),
                            style: const TextStyle(fontSize: 12),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      idea.creatorName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Footer: Vote button and comment count
              Row(
                children: [
                  // Vote button (compact mode)
                  VoteButton(
                    ideaId: idea.id,
                    voteCount: idea.voteCount,
                    compact: true,
                  ),
                  const SizedBox(width: 12),

                  // Comment count
                  OutlinedButton.icon(
                    onPressed: () => context.push('/idea/${idea.id}'),
                    icon: const Icon(Icons.comment_outlined, size: 18),
                    label: Text('${idea.commentCount}'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),

                  // Official response indicator
                  if (idea.officialResponse != null) ...[
                    const SizedBox(width: 12),
                    Tooltip(
                      message: 'Official response available',
                      child: Icon(
                        Icons.verified_outlined,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],

                  // Location indicator
                  if (idea.location != null) ...[
                    const SizedBox(width: 12),
                    Tooltip(
                      message: 'Has location',
                      child: Icon(
                        Icons.location_on_outlined,
                        size: 20,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],

                  // Photos indicator
                  if (idea.photos.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Tooltip(
                      message: '${idea.photos.length} photo(s)',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.photo_outlined,
                            size: 20,
                            color: colorScheme.tertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${idea.photos.length}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get icon for category
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'infrastructure':
        return Icons.construction;
      case 'environment':
        return Icons.eco;
      case 'transportation':
        return Icons.directions_bus;
      case 'safety':
        return Icons.security;
      case 'community':
        return Icons.groups;
      case 'technology':
        return Icons.computer;
      case 'health':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      default:
        return Icons.lightbulb_outline;
    }
  }
}

/// Status badge widget
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine color and icon based on status
    Color backgroundColor;
    Color foregroundColor;
    IconData icon;
    String label;

    switch (status.toLowerCase()) {
      case 'open':
        backgroundColor = colorScheme.primaryContainer;
        foregroundColor = colorScheme.onPrimaryContainer;
        icon = Icons.lightbulb_outline;
        label = 'Open';
        break;
      case 'under_review':
        backgroundColor = colorScheme.secondaryContainer;
        foregroundColor = colorScheme.onSecondaryContainer;
        icon = Icons.rate_review_outlined;
        label = 'Under Review';
        break;
      case 'approved':
        backgroundColor = Colors.green.shade100;
        foregroundColor = Colors.green.shade900;
        icon = Icons.check_circle_outline;
        label = 'Approved';
        break;
      case 'rejected':
        backgroundColor = Colors.red.shade100;
        foregroundColor = Colors.red.shade900;
        icon = Icons.cancel_outlined;
        label = 'Rejected';
        break;
      case 'implemented':
        backgroundColor = Colors.purple.shade100;
        foregroundColor = Colors.purple.shade900;
        icon = Icons.verified;
        label = 'Implemented';
        break;
      default:
        backgroundColor = colorScheme.surfaceVariant;
        foregroundColor = colorScheme.onSurfaceVariant;
        icon = Icons.help_outline;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foregroundColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
