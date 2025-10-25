import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muni_report_pro/features/auth/presentation/providers/auth_provider.dart';
import 'package:muni_report_pro/features/auth/presentation/providers/auth_controller.dart';
import 'package:muni_report_pro/core/constants/route_constants.dart';
import 'package:muni_report_pro/core/theme/app_colors.dart';
import 'package:muni_report_pro/core/utils/validators.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String? _selectedRole;
  String? _selectedWard;
  String? _selectedMunicipality;
  
  final List<String> _municipalities = [
    'City of Johannesburg',
    'City of Tshwane',
    'City of Ekurhuleni',
    'City of Cape Town',
  ];
  
  final List<String> _wards = [
    'Ward 1',
    'Ward 2',
    'Ward 3',
    'Ward 4',
    'Ward 5',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final userModelAsync = ref.read(currentUserModelProvider);
    userModelAsync.whenData((user) {
      if (user != null) {
        _nameController.text = user.displayName ?? '';
        _phoneController.text = user.phoneNumber ?? '';
        _selectedRole = user.role;
        _selectedWard = user.ward;
        _selectedMunicipality = user.municipality;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final currentFirebaseUser = ref.read(authControllerProvider).valueOrNull;
      
      if (currentFirebaseUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No user logged in')),
          );
        }
        return;
      }

      await ref.read(authControllerProvider.notifier).completeProfileSetup(
        currentFirebaseUser.uid,
        _nameController.text.trim(),
        _phoneController.text.trim(),
        _selectedRole ?? 'citizen',
        _selectedWard,
        _selectedMunicipality,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        context.go(Routes.profile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userModelAsync = ref.watch(currentUserModelProvider);
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: authState.isLoading ? null : _handleSave,
            child: authState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Picture Section
                  Center(
                    child: Stack(
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
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, color: Colors.white),
                              onPressed: () {
                                // TODO: Implement photo upload
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Photo upload coming soon')),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: Validators.name,
                  ),
                  const SizedBox(height: 16),

                  // Phone field
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: Validators.phoneNumber,
                  ),
                  const SizedBox(height: 16),

                  // Role field
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'citizen', child: Text('Citizen')),
                      DropdownMenuItem(value: 'official', child: Text('Government Official')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedRole = value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Municipality field
                  DropdownButtonFormField<String>(
                    value: _selectedMunicipality,
                    decoration: const InputDecoration(
                      labelText: 'Municipality',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    items: _municipalities.map((municipality) {
                      return DropdownMenuItem(
                        value: municipality,
                        child: Text(municipality),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedMunicipality = value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Ward field
                  DropdownButtonFormField<String>(
                    value: _selectedWard,
                    decoration: const InputDecoration(
                      labelText: 'Ward',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.map),
                    ),
                    items: _wards.map((ward) {
                      return DropdownMenuItem(
                        value: ward,
                        child: Text(ward),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedWard = value);
                    },
                  ),
                  const SizedBox(height: 32),

                  // Save button
                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Changes'),
                  ),
                ],
              ),
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
}
