import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muni_report_pro/features/auth/presentation/providers/auth_provider.dart';
import 'package:muni_report_pro/features/auth/presentation/providers/auth_controller.dart';
import 'package:muni_report_pro/core/constants/route_constants.dart';
import 'package:muni_report_pro/core/theme/app_colors.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userModelAsync = ref.watch(currentUserModelProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go(Routes.editProfile),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'logout':
                  _handleLogout(context, ref);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: userModelAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('No user data found'),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                Card(
                  color: AppColors.primary.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: user.photoURL != null
                              ? NetworkImage(user.photoURL!)
                              : null,
                          child: user.photoURL == null
                              ? Text(
                                  user.displayName?.isNotEmpty == true
                                      ? user.displayName![0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(fontSize: 32),
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        
                        Text(
                          user.displayName ?? 'No name',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email ?? 'No email',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            user.role?.toUpperCase() ?? 'CITIZEN',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(context, 'Points', '${user.points}'),
                    _buildStatColumn(context, 'Reports', '0'),
                    _buildStatColumn(context, 'Ideas', '0'),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Profile Information
                Text(
                  'Profile Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person, color: AppColors.primary),
                        title: const Text('Full Name'),
                        subtitle: Text(user.displayName ?? 'Not provided'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => context.go(Routes.editProfile),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.email, color: AppColors.primary),
                        title: const Text('Email'),
                        subtitle: Text(user.email ?? 'Not provided'),
                      ),
                      if (user.phoneNumber != null) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.phone, color: AppColors.primary),
                          title: const Text('Phone'),
                          subtitle: Text(user.phoneNumber!),
                        ),
                      ],
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.badge, color: AppColors.primary),
                        title: const Text('Role'),
                        subtitle: Text(user.role?.toUpperCase() ?? 'CITIZEN'),
                      ),
                      if (user.municipality != null) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.location_city, color: AppColors.primary),
                          title: const Text('Municipality'),
                          subtitle: Text(user.municipality!),
                        ),
                      ],
                      if (user.ward != null) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.map, color: AppColors.primary),
                          title: const Text('Ward'),
                          subtitle: Text(user.ward!),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit, color: AppColors.primary),
                        title: const Text('Edit Profile'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => context.go(Routes.editProfile),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.history, color: AppColors.primary),
                        title: const Text('My Contributions'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => context.go(Routes.myContributions),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.settings, color: AppColors.primary),
                        title: const Text('Settings'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => context.go(Routes.settings),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleLogout(context, ref),
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
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
                onPressed: () => ref.invalidate(currentUserModelProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authControllerProvider.notifier).signOut();
      if (context.mounted) {
        context.go(Routes.login);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildStatColumn(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

}
