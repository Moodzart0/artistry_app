import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/auth_state.dart';
import '../providers/auth_provider.dart';

/// Profile setup screen shown after first sign-up.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authProvider);
    if (authState is! AuthNeedsProfileSetup) return;

    // Check username availability
    final isAvailable = await ref
        .read(authRepositoryProvider)
        .isUsernameAvailable(_usernameController.text.trim().toLowerCase());

    if (!isAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username is already taken'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    await ref.read(authProvider.notifier).completeProfileSetup(
          userId: authState.userId,
          username: _usernameController.text.trim().toLowerCase(),
          displayName: _displayNameController.text.trim(),
          bio: _bioController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),

                // Avatar placeholder
                Center(
                  child: Stack(
                    children: [
                      const CircleAvatar(
                        radius: 56,
                        backgroundColor: AppColors.surfaceVariant,
                        child: Icon(
                          Icons.person_outline,
                          size: 56,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  'Complete Your Profile',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tell the community about yourself',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 32),

                // Display name
                AppTextField(
                  controller: _displayNameController,
                  label: 'Display Name',
                  hint: 'Your artist name',
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: Validators.displayName,
                  textInputAction: TextInputAction.next,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),

                // Username
                AppTextField(
                  controller: _usernameController,
                  label: 'Username',
                  hint: 'Choose a unique username',
                  prefixIcon: const Icon(Icons.alternate_email),
                  validator: Validators.username,
                  textInputAction: TextInputAction.next,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),

                // Bio
                AppTextField(
                  controller: _bioController,
                  label: 'Bio (optional)',
                  hint: 'Tell us about your art style...',
                  maxLines: 3,
                  maxLength: 300,
                  textInputAction: TextInputAction.done,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 32),

                // Submit button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleSubmit,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("Let's Go!"),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
