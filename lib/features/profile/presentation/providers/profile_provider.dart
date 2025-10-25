import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/profile_service.dart';

/// Profile service provider
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

/// User statistics provider
final userStatisticsProvider = FutureProvider.family<UserStatistics, String>((ref, userId) async {
  final profileService = ref.watch(profileServiceProvider);
  return await profileService.getUserStatistics(userId);
});
