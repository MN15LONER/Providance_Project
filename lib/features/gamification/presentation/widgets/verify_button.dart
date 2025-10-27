import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/gamification_provider.dart';

/// Verify button widget for issues
/// 
/// Allows users to verify that an issue exists and is legitimate.
/// Shows different states:
/// - Not verified: Primary button with "Verify" text
/// - Already verified: Green button with "Verified" text (disabled)
/// - Loading: Shows progress indicator
/// 
/// Awards +2 points when user verifies successfully.
/// Awards +5 bonus points to reporter when issue reaches 3 verifications.
class VerifyButton extends ConsumerWidget {
  /// The ID of the issue to verify
  final String issueId;
  
  /// Current verification count for the issue
  final int verificationCount;
  
  /// ID of the user who reported the issue (to prevent self-verification)
  final String reportedBy;
  
  /// Whether to show as a compact button
  final bool compact;

  const VerifyButton({
    super.key,
    required this.issueId,
    required this.verificationCount,
    required this.reportedBy,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch if user has verified this issue
    final hasVerifiedAsync = ref.watch(hasVerifiedProvider(issueId));
    
    // Watch controller state for loading/error states
    final controllerState = ref.watch(gamificationControllerProvider);
    
    // Get current user ID to check if they're the reporter
    final currentUserId = ref.watch(currentUserIdProvider);

    return hasVerifiedAsync.when(
      // Data loaded successfully
      data: (hasVerified) {
        // Check if user is the reporter (cannot verify own report)
        final isOwnReport = currentUserId == reportedBy;
        
        // Determine button style based on verification status
        final buttonColor = hasVerified 
            ? Colors.green
            : Theme.of(context).colorScheme.primary;
        
        final icon = hasVerified 
            ? Icons.verified
            : Icons.check_circle_outline;

        // Show disabled state if own report
        if (isOwnReport) {
          return compact
              ? Tooltip(
                  message: 'Cannot verify your own report',
                  child: FilledButton.tonalIcon(
                    onPressed: null,
                    icon: const Icon(Icons.block, size: 18),
                    label: Text('$verificationCount'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                )
              : FilledButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.block),
                  label: Text('Cannot Verify ($verificationCount)'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                );
        }

        if (compact) {
          // Compact version for list items
          return FilledButton.tonalIcon(
            onPressed: hasVerified || controllerState.isLoading 
                ? null 
                : () => _handleVerify(context, ref),
            icon: Icon(icon, size: 18),
            label: Text('$verificationCount'),
            style: FilledButton.styleFrom(
              backgroundColor: hasVerified ? buttonColor.withOpacity(0.2) : null,
              foregroundColor: hasVerified ? buttonColor : null,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        }

        // Full version for detail pages
        return FilledButton.icon(
          onPressed: hasVerified || controllerState.isLoading 
              ? null 
              : () => _handleVerify(context, ref),
          icon: controllerState.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(icon),
          label: Text(
            hasVerified 
                ? 'Verified ($verificationCount)' 
                : 'Verify ($verificationCount)',
          ),
          style: FilledButton.styleFrom(
            backgroundColor: hasVerified ? buttonColor : null,
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
              width: 140,
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
              tooltip: 'Error loading verification status',
            )
          : OutlinedButton.icon(
              onPressed: () => _showError(context, error.toString()),
              icon: const Icon(Icons.error_outline),
              label: const Text('Error'),
            ),
    );
  }

  /// Handle verify action
  Future<void> _handleVerify(BuildContext context, WidgetRef ref) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify Issue'),
        content: const Text(
          'By verifying this issue, you confirm that:\n\n'
          '• You have personally observed this issue\n'
          '• The information provided is accurate\n'
          '• This is not a duplicate report\n\n'
          'You will earn +2 points for verifying.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Verify'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Call controller to verify
    final success = await ref
        .read(gamificationControllerProvider.notifier)
        .verifyIssue(issueId);

    if (success && context.mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.verified, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Issue verified! +2 points',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (verificationCount + 1 == 3)
                      const Text(
                        'Reporter earned +5 bonus points!',
                        style: TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    } else if (!success && context.mounted) {
      // Get error message from controller
      final error = ref.read(gamificationControllerProvider).error;
      if (error != null) {
        _showError(context, error);
      }
    }
  }

  /// Show error message
  void _showError(BuildContext context, String error) {
    if (!context.mounted) return;
    
    String message = 'Failed to verify. Please try again.';
    
    if (error.contains('already verified')) {
      message = 'You have already verified this issue';
    } else if (error.contains('own report')) {
      message = 'You cannot verify your own report';
    } else if (error.contains('not found')) {
      message = 'Issue not found';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// Provider for current user ID
final currentUserIdProvider = Provider<String?>((ref) {
  // Import at top: import 'package:firebase_auth/firebase_auth.dart';
  return FirebaseAuth.instance.currentUser?.uid;
});
