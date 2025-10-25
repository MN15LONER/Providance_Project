/// Leaderboard entry entity
class LeaderboardEntry {
  final int rank;
  final String userId;
  final String name;
  final String? photoURL;
  final int points;
  final String? ward;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.name,
    this.photoURL,
    required this.points,
    this.ward,
  });

  LeaderboardEntry copyWith({
    int? rank,
    String? userId,
    String? name,
    String? photoURL,
    int? points,
    String? ward,
  }) {
    return LeaderboardEntry(
      rank: rank ?? this.rank,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      photoURL: photoURL ?? this.photoURL,
      points: points ?? this.points,
      ward: ward ?? this.ward,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LeaderboardEntry && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() {
    return 'LeaderboardEntry(rank: $rank, name: $name, points: $points)';
  }
}
