# Phase 4 & 5 UI Implementation Plan

## ✅ COMPLETED: Riverpod Providers

### Phase 4: Ideas Providers ✅
**File**: `lib/features/ideas/presentation/providers/idea_provider.dart`

**Providers Created**:
- ✅ `ideaRepositoryProvider` - Repository instance
- ✅ `commentRepositoryProvider` - Comment repository
- ✅ `allIdeasProvider` - All ideas stream (sorted by votes)
- ✅ `myIdeasProvider` - Current user's ideas
- ✅ `ideasByStatusProvider` - Filter by status
- ✅ `ideasByCategoryProvider` - Filter by category
- ✅ `ideaStreamProvider` - Single idea real-time
- ✅ `ideaDetailProvider` - Single idea fetch
- ✅ `hasVotedProvider` - Check if user voted
- ✅ `commentsProvider` - Comments stream
- ✅ `hasLikedCommentProvider` - Check if user liked comment
- ✅ `ideasCountProvider` - Ideas count by status
- ✅ `ideaControllerProvider` - State management with actions

**Controller Methods**:
- `createIdea()` - Create new idea
- `voteOnIdea()` - Vote on idea
- `removeVote()` - Remove vote
- `addComment()` - Add comment
- `likeComment()` - Like comment
- `unlikeComment()` - Unlike comment
- `deleteComment()` - Delete comment
- `updateStatus()` - Update idea status (officials)
- `addResponse()` - Add official response
- `deleteIdea()` - Delete idea

### Phase 5: Gamification Providers ✅
**File**: `lib/features/gamification/presentation/providers/gamification_provider.dart`

**Providers Created**:
- ✅ `verificationRepositoryProvider` - Verification repository
- ✅ `pointsRepositoryProvider` - Points repository
- ✅ `currentUserPointsProvider` - Current user points stream
- ✅ `userPointsProvider` - User points by ID
- ✅ `pointsHistoryProvider` - Points history stream
- ✅ `currentUserPointsHistoryProvider` - Current user history
- ✅ `leaderboardProvider` - Leaderboard (with ward filter)
- ✅ `globalLeaderboardProvider` - Global leaderboard
- ✅ `userRankProvider` - User rank
- ✅ `currentUserRankProvider` - Current user rank
- ✅ `hasVerifiedProvider` - Check if user verified
- ✅ `pointsStatisticsProvider` - User statistics
- ✅ `currentUserStatisticsProvider` - Current user stats
- ✅ `pointsBreakdownProvider` - Points breakdown
- ✅ `gamificationControllerProvider` - State management

**Controller Methods**:
- `verifyIssue()` - Verify an issue
- `removeVerification()` - Remove verification
- `awardPoints()` - Award points (admin)

---

## 🚧 PENDING: UI Pages & Widgets

### Priority 1: Ideas Hub Page
**File**: `lib/features/ideas/presentation/pages/ideas_hub_page.dart`

**Features Needed**:
```dart
- Grid/List view of ideas
- Sort options (votes, date, comments)
- Filter by category and status
- Search functionality
- Pull-to-refresh
- Floating action button to propose idea
- Idea cards with:
  - Title, description preview
  - Vote count
  - Comment count
  - Category badge
  - Status indicator
  - Creator info
```

**Implementation**:
```dart
class IdeasHubPage extends ConsumerStatefulWidget {
  // Use allIdeasProvider
  // Display in GridView or ListView
  // Add filters and sort options
  // Navigate to idea detail on tap
}
```

---

### Priority 2: Propose Idea Page
**File**: `lib/features/ideas/presentation/pages/propose_idea_page.dart`

**Features Needed**:
```dart
- Title input field
- Description textarea
- Category dropdown
- Budget input
- Optional photo picker
- Optional location picker
- Submit button
- Form validation
- Loading states
```

**Implementation**:
```dart
class ProposeIdeaPage extends ConsumerStatefulWidget {
  // Similar to ReportIssuePage
  // Use ideaControllerProvider.createIdea()
  // Optional photos and location
  // Navigate to idea detail after submission
}
```

---

### Priority 3: Idea Detail Page
**File**: `lib/features/ideas/presentation/pages/idea_detail_page.dart`

**Features Needed**:
```dart
- Idea title and description
- Creator info
- Vote button widget
- Vote count display
- Category and budget
- Status badge
- Photos gallery (if any)
- Location map (if any)
- Comments section:
  - Comment list
  - Add comment field
  - Like button on comments
- Official response (if any)
```

**Implementation**:
```dart
class IdeaDetailPage extends ConsumerWidget {
  final String ideaId;
  
  // Use ideaStreamProvider(ideaId)
  // Use commentsProvider(ideaId)
  // Display VoteButton widget
  // Show comments with like buttons
  // Add comment input at bottom
}
```

---

### Priority 4: Vote Button Widget
**File**: `lib/features/ideas/presentation/widgets/vote_button.dart`

**Features Needed**:
```dart
- Show vote count
- Check if user voted (hasVotedProvider)
- Disable if already voted
- Show loading state
- Success feedback
- Points notification
```

**Implementation**:
```dart
class VoteButton extends ConsumerWidget {
  final String ideaId;
  final int voteCount;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasVotedAsync = ref.watch(hasVotedProvider(ideaId));
    
    return hasVotedAsync.when(
      data: (hasVoted) => ElevatedButton.icon(
        onPressed: hasVoted ? null : () async {
          final success = await ref
              .read(ideaControllerProvider.notifier)
              .voteOnIdea(ideaId);
          
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Vote recorded! +1 point')),
            );
          }
        },
        icon: Icon(hasVoted ? Icons.check : Icons.thumb_up),
        label: Text('$voteCount ${hasVoted ? "Voted" : "Vote"}'),
      ),
      loading: () => CircularProgressIndicator(),
      error: (e, _) => Text('Error'),
    );
  }
}
```

---

### Priority 5: Leaderboard Page
**File**: `lib/features/gamification/presentation/pages/leaderboard_page.dart`

**Features Needed**:
```dart
- List of top users
- Rank, name, photo, points
- Current user highlight
- Ward filter toggle
- Pull-to-refresh
- Podium for top 3
- User cards with:
  - Rank badge
  - Profile photo
  - Name
  - Points
  - Ward (optional)
```

**Implementation**:
```dart
class LeaderboardPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(globalLeaderboardProvider);
    final currentUserRankAsync = ref.watch(currentUserRankProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
        actions: [
          // Ward filter toggle
        ],
      ),
      body: leaderboardAsync.when(
        data: (entries) => ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return LeaderboardCard(entry: entry);
          },
        ),
        loading: () => LoadingIndicator(),
        error: (e, _) => ErrorWidget(error: e.toString()),
      ),
    );
  }
}
```

---

### Priority 6: Points History Page
**File**: `lib/features/gamification/presentation/pages/points_history_page.dart`

**Features Needed**:
```dart
- Timeline of points earned
- Action description
- Points (+/-)
- Timestamp
- Reference link (to issue/idea)
- Total points at top
- Filter by action type
```

**Implementation**:
```dart
class PointsHistoryPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(currentUserPointsHistoryProvider);
    final pointsAsync = ref.watch(currentUserPointsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Points History'),
      ),
      body: Column(
        children: [
          // Total points card
          pointsAsync.when(
            data: (points) => Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Total Points', style: Theme.of(context).textTheme.titleMedium),
                    Text('$points', style: Theme.of(context).textTheme.displayMedium),
                  ],
                ),
              ),
            ),
            loading: () => CircularProgressIndicator(),
            error: (e, _) => Text('Error'),
          ),
          
          // History list
          Expanded(
            child: historyAsync.when(
              data: (history) => ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  return PointHistoryTile(item: item);
                },
              ),
              loading: () => LoadingIndicator(),
              error: (e, _) => ErrorWidget(error: e.toString()),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### Priority 7: Verify Button Widget
**File**: `lib/features/gamification/presentation/widgets/verify_button.dart`

**Features Needed**:
```dart
- Show verification count
- Check if user verified (hasVerifiedProvider)
- Disable if already verified
- Disable if own report
- Show loading state
- Success feedback
- Points notification
```

**Implementation**:
```dart
class VerifyButton extends ConsumerWidget {
  final String issueId;
  final int verificationCount;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasVerifiedAsync = ref.watch(hasVerifiedProvider(issueId));
    
    return hasVerifiedAsync.when(
      data: (hasVerified) => ElevatedButton.icon(
        onPressed: hasVerified ? null : () async {
          final success = await ref
              .read(gamificationControllerProvider.notifier)
              .verifyIssue(issueId);
          
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Issue verified! +2 points')),
            );
          }
        },
        icon: Icon(hasVerified ? Icons.verified : Icons.check_circle_outline),
        label: Text('$verificationCount ${hasVerified ? "Verified" : "Verify"}'),
        style: ElevatedButton.styleFrom(
          backgroundColor: hasVerified ? Colors.green : null,
        ),
      ),
      loading: () => CircularProgressIndicator(),
      error: (e, _) => Text('Error'),
    );
  }
}
```

---

### Priority 8: Supporting Widgets

#### Idea Card Widget
**File**: `lib/features/ideas/presentation/widgets/idea_card.dart`

```dart
class IdeaCard extends StatelessWidget {
  final Idea idea;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/ideas/${idea.id}'),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(idea.title, style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 8),
              
              // Description preview
              Text(
                idea.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              
              // Category badge
              Chip(label: Text(idea.category)),
              SizedBox(height: 8),
              
              // Stats row
              Row(
                children: [
                  Icon(Icons.thumb_up, size: 16),
                  SizedBox(width: 4),
                  Text('${idea.voteCount}'),
                  SizedBox(width: 16),
                  Icon(Icons.comment, size: 16),
                  SizedBox(width: 4),
                  Text('${idea.commentCount}'),
                  Spacer(),
                  // Status badge
                  StatusBadge(status: idea.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### Leaderboard Card Widget
**File**: `lib/features/gamification/presentation/widgets/leaderboard_card.dart`

```dart
class LeaderboardCard extends StatelessWidget {
  final LeaderboardEntry entry;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text('#${entry.rank}'),
          backgroundColor: _getRankColor(entry.rank),
        ),
        title: Text(entry.name),
        subtitle: entry.ward != null ? Text(entry.ward!) : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.stars, color: Colors.amber),
            Text('${entry.points}'),
          ],
        ),
      ),
    );
  }
  
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1: return Colors.amber;
      case 2: return Colors.grey[400]!;
      case 3: return Colors.brown[300]!;
      default: return Colors.blue;
    }
  }
}
```

#### Point History Tile Widget
**File**: `lib/features/gamification/presentation/widgets/point_history_tile.dart`

```dart
class PointHistoryTile extends StatelessWidget {
  final PointHistory item;
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: item.points > 0 ? Colors.green : Colors.red,
        child: Text(
          '${item.points > 0 ? "+" : ""}${item.points}',
          style: TextStyle(color: Colors.white),
        ),
      ),
      title: Text(item.action),
      subtitle: Text(timeago.format(item.timestamp)),
      trailing: item.referenceId != null
          ? IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () {
                // Navigate to reference
                if (item.referenceType == 'issue') {
                  context.push('/issues/${item.referenceId}');
                } else if (item.referenceType == 'idea') {
                  context.push('/ideas/${item.referenceId}');
                }
              },
            )
          : null,
    );
  }
}
```

---

## 🧪 Testing Workflows

### Workflow 1: Propose and Vote on Idea
1. User logs in
2. Navigate to Ideas Hub
3. Tap FAB to propose idea
4. Fill form (title, description, category, budget)
5. Submit → +3 points
6. Navigate to idea detail
7. Another user votes → +1 point to voter
8. Vote count increases
9. Check leaderboard → points reflected

### Workflow 2: Verify Issue
1. User reports an issue
2. Another user views issue detail
3. Tap "Verify" button
4. Verification count increases → +2 points
5. When 3 verifications reached → +5 bonus to reporter
6. Check points history → verification recorded

### Workflow 3: Comment and Like
1. User views idea detail
2. Add comment → +1 point
3. Another user likes comment
4. Like count increases
5. Check points history → comment points recorded

### Workflow 4: Leaderboard
1. Navigate to leaderboard
2. See top users ranked by points
3. Toggle ward filter
4. See current user's rank
5. Tap user to view profile (future)

---

## 📝 Implementation Order

1. ✅ **Providers** (DONE)
2. **Vote Button Widget** (simple, reusable)
3. **Verify Button Widget** (simple, reusable)
4. **Idea Card Widget** (for list display)
5. **Ideas Hub Page** (list of ideas)
6. **Propose Idea Page** (form)
7. **Idea Detail Page** (with comments)
8. **Leaderboard Card Widget**
9. **Leaderboard Page**
10. **Point History Tile Widget**
11. **Points History Page**
12. **Integration Testing**

---

## 🎯 Success Criteria

- ✅ Users can propose ideas
- ✅ Users can vote on ideas
- ✅ Users can comment on ideas
- ✅ Users can verify issues
- ✅ Points are awarded automatically
- ✅ Leaderboard shows rankings
- ✅ Points history shows all transactions
- ✅ Real-time updates work
- ✅ UI is responsive and beautiful

---

**Status**: Providers Complete ✅ | UI Pages Pending 🚧

**Next**: Implement UI pages and widgets following this plan.
