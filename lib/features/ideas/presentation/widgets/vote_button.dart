import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/idea_provider.dart';

/// Vote button widget for ideas
/// 
/// Displays vote count and allows users to vote on ideas.
/// Shows different states:
/// - Not voted: Blue button with "Vote" text
/// - Already voted: Green button with "Voted" text (disabled)
/// - Loading: Shows progress indicator
/// 
/// Awards +1 point when user votes successfully.
class VoteButton extends ConsumerWidget {
  /// The ID of the idea to vote on
  final String ideaId;
  
  /// Current vote count for the idea
  final int voteCount;
  
  /// Whether to show as a compact button
  final bool compact;

  const VoteButton({
    super.key,
    required this.ideaId,
    required this.voteCount,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch if user has voted on this idea
    final hasVotedAsync = ref.watch(hasVotedProvider(ideaId));
    
    // Watch controller state for loading/error states
    final controllerState = ref.watch(ideaControllerProvider);

    return hasVotedAsync.when(
      // Data loaded successfully
      data: (hasVoted) {
        // Determine button style based on vote status
        final buttonColor = hasVoted 
            ? Theme.of(context).colorScheme.tertiary
            : Theme.of(context).colorScheme.primary;
        
        final icon = hasVoted 
            ? Icons.check_circle
            : Icons.thumb_up_outlined;

        if (compact) {
          // Compact version for list items
          return FilledButton.tonalIcon(
            onPressed: hasVoted || controllerState.isLoading 
                ? null 
                : () => _handleVote(context, ref),
            icon: Icon(icon, size: 18),
            label: Text('$voteCount'),
            style: FilledButton.styleFrom(
              backgroundColor: hasVoted ? buttonColor.withOpacity(0.2) : null,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        }

        // Full version for detail pages
        return FilledButton.icon(
          onPressed: hasVoted || controllerState.isLoading 
              ? null 
              : () => _handleVote(context, ref),
          icon: controllerState.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon),
          label: Text(
            hasVoted 
                ? 'Voted ($voteCount)' 
                : 'Vote ($voteCount)',
          ),
          style: FilledButton.styleFrom(
            backgroundColor: hasVoted ? buttonColor : null,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        );
      },
      
      // Loading state
      loading: () => compact
          ? const SizedBox(
              width: 80,
              height: 36,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          : const SizedBox(
              width: 120,
              height: 48,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
      
      // Error state
      error: (error, stackTrace) => compact
          ? IconButton(
              icon: const Icon(Icons.error_outline),
              onPressed: () => _showError(context, error.toString()),
              tooltip: 'Error loading vote status',
            )
          : OutlinedButton.icon(
              onPressed: () => _showError(context, error.toString()),
              icon: const Icon(Icons.error_outline),
              label: const Text('Error'),
            ),
    );
  }

  /// Handle vote action
  Future<void> _handleVote(BuildContext context, WidgetRef ref) async {
    // Call controller to vote
    final success = await ref
        .read(ideaControllerProvider.notifier)
        .voteOnIdea(ideaId);

    if (success && context.mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Vote recorded! +1 point'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (!success && context.mounted) {
      // Get error message from controller
      final error = ref.read(ideaControllerProvider).error;
      if (error != null) {
        _showError(context, error);
      }
    }
  }

  /// Show error message
  void _showError(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error.contains('already voted')
                    ? 'You have already voted on this idea'
                    : 'Failed to vote. Please try again.',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
