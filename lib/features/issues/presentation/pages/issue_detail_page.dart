import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IssueDetailPage extends ConsumerWidget {
  final String issueId;
  
  const IssueDetailPage({super.key, required this.issueId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Details'),
      ),
      body: Center(
        child: Text('Issue Detail Page - ID: $issueId'),
      ),
    );
  }
}
