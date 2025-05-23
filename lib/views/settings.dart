import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../theme/app_colors.dart';
import '../viewmodels/offline_mode_viewmodel.dart'; // Keep for offline mode functionality

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showNotifications = true;
  bool _enableOfflineMode = false;
  AuthViewModel? _authViewModel;

  @override
  void initState() {
    super.initState();
    _authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    _authViewModel?.fetchUserProfile();
    _authViewModel?.addListener(_updateUserFields);
    _updateUserFields(); // Initial population
  }

  void _updateUserFields() {
    if (mounted && _authViewModel != null) {
      _displayNameController.text = _authViewModel!.displayName ?? '';
      _emailController.text = _authViewModel!.displayEmail ?? '';
    }
  }

  @override
  void dispose() {
    _authViewModel?.removeListener(_updateUserFields);
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveAll() async {
    final name = _displayNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    bool changesMade = false;
    bool overallSuccess = true;
    String successMessage = "User info updated successfully";
    String errorMessage = "";

    if (name.isEmpty && email.isEmpty && password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Nothing to update"),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
      return;
    }

    if (_authViewModel == null) return;

    if (name.isNotEmpty && name != _authViewModel!.displayName) {
      changesMade = true;
      bool success = await _authViewModel!.updateDisplayName(name);
      if (!success) {
        overallSuccess = false;
        errorMessage += "Failed to update display name. ";
      }
    }

    if (email.isNotEmpty && email != _authViewModel!.displayEmail) {
      changesMade = true;
      bool success = await _authViewModel!.updateEmail(email);
      if (!success) {
        overallSuccess = false;
        errorMessage += "Failed to update email. ";
      }
    }

    if (password.isNotEmpty) {
      changesMade = true;
      bool success = await _authViewModel!.updatePassword(password);
      if (!success) {
        overallSuccess = false;
        errorMessage += "Failed to update password. ";
      } else {
         _passwordController.clear(); // Clear password field on successful update
      }
    }
    
    if (!changesMade){
        successMessage = "Nothing to update";
    }

    if (mounted) {
      if (overallSuccess && changesMade) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        _authViewModel?.fetchUserProfile(); // Re-fetch to ensure UI consistency
      } else if (!overallSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage.isNotEmpty ? errorMessage : _authViewModel!.errorMessage ?? "An error occurred during update"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } else { // No changes made but save was clicked
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Theme.of(context).colorScheme.secondary, // Use secondary for no-op
          ),
        );
      }
    }
  }

  // Add _signOut method here if it's not already present or needs modification for dialog
  void _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Confirm Sign Out', style: TextStyle(color: AppColors.textPrimary)),
          content: Text('Are you sure you want to sign out?', style: TextStyle(color: AppColors.textSecondary)),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
              onPressed: () {
                Navigator.of(context).pop(false); // Return false when cancelled
              },
            ),
            TextButton(
              child: Text('Sign Out', style: TextStyle(color: AppColors.primary)),
              onPressed: () {
                Navigator.of(context).pop(true); // Return true when confirmed
              },
            ),
          ],
        );
      },
    );

    // If the user confirmed, then proceed with sign out
    if (confirmed == true) {
      await _authViewModel?.signOut();
      if (mounted) {
        // Navigate to login screen and remove all previous routes
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // final offlineViewModel = Provider.of<OfflineModeViewModel>(context);
    // We'll track dark mode state locally now
    bool isDarkMode = true; // Always true since we only want dark mode

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        automaticallyImplyLeading: false, // Remove back button
        elevation: 0,
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('User Profile'),
                _buildProfileCard(authViewModel),
                const SizedBox(height: 24),
                _buildSectionHeader('Account Settings'),
                _buildSettingsForm(authViewModel),
                const SizedBox(height: 24),
                _buildSectionHeader('App Settings'),
                _buildAppSettings(isDarkMode/*, offlineViewModel*/),
                const SizedBox(height: 24),
                _buildSectionHeader('About'),
                _buildAboutSection(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    onPressed: _signOut,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonDanger,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary.withOpacity(0.8),
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
  Widget _buildProfileCard(AuthViewModel viewModel) {
    return Card(
      color: AppColors.cardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primary,
              child: const Icon(
                Icons.person,
                size: 30,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    viewModel.displayName ?? 'N/A',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                  ),
                  Text(
                    viewModel.displayEmail ?? 'N/A',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSettingsForm(AuthViewModel viewModel) {
    return Card(
      color: AppColors.cardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(
              controller: _displayNameController,
              label: 'Display Name',
              icon: Icons.person,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _passwordController,
              label: 'New Password (optional)',
              icon: Icons.lock,
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surfaceLight.withOpacity(0.3),
      ),
    );
  }
  Widget _buildAppSettings(bool isDarkMode/*, OfflineModeViewModel offlineViewModel*/) {
    return Card(
      color: AppColors.cardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: Text('Dark Mode', style: TextStyle(color: AppColors.textPrimary)),
            subtitle: Text('Toggle dark/light theme', style: TextStyle(color: AppColors.textSecondary)),
            value: isDarkMode,
            activeColor: AppColors.primary,
            onChanged: (value) {
              // Theme toggle is non-functional but kept in UI
              // No action needed as we're maintaining dark mode only
            },
            secondary: Icon(Icons.dark_mode, color: AppColors.primary),
          ),
          Divider(color: AppColors.divider, height: 1),
          SwitchListTile(
            title: Text('Notifications', style: TextStyle(color: AppColors.textPrimary)),
            subtitle: Text('Enable push notifications', style: TextStyle(color: AppColors.textSecondary)),
            value: _showNotifications,
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() {
                _showNotifications = value;
              });
            },
            secondary: Icon(Icons.notifications, color: AppColors.primary),
          ),
          Divider(color: AppColors.divider, height: 1),
          SwitchListTile(
            title: Text('Offline Mode', style: TextStyle(color: AppColors.textPrimary)),
            subtitle: Text('Download music for offline use', style: TextStyle(color: AppColors.textSecondary)),
            value: _enableOfflineMode,
            // value: offlineViewModel.isOfflineModeEnabled,
            activeColor: AppColors.primary,
            onChanged: (value) async {
              setState(() {
                _enableOfflineMode = value;
              });

              // if (value) {
              //   bool? confirmed = await showDialog<bool>(
              //     context: context,
              //     builder: (BuildContext dialogContext) {
              //       return AlertDialog(
              //         backgroundColor: AppColors.surface,
              //         title: const Text('Enable Offline Mode?', style: TextStyle(color: AppColors.textPrimary)),
              //         content: const Text('This will download your favorite songs and playlists. This may take some time and consume data and storage.',
              //           style: TextStyle(color: AppColors.textSecondary)),
              //         actions: <Widget>[
              //           TextButton(
              //             child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
              //             onPressed: () {
              //               Navigator.of(dialogContext).pop(false);
              //             },
              //           ),
              //           TextButton(
              //             child: const Text('Enable', style: TextStyle(color: AppColors.primary)),
              //             onPressed: () {
              //               Navigator.of(dialogContext).pop(true);
              //             },
              //           ),
              //         ],
              //       );
              //     },
              //   );
              //   if (confirmed == true) {
              //     offlineViewModel.setOfflineMode(true);
              //   }
              // } else {
              //   offlineViewModel.setOfflineMode(false);
              // }
            },
            secondary: Icon(Icons.offline_bolt, color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }
  Widget _buildAboutSection() {
    return Card(
      color: AppColors.cardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.primary),
            title: const Text('App Version', style: TextStyle(color: AppColors.textPrimary)),
            subtitle: const Text('1.0.0', style: TextStyle(color: AppColors.textSecondary)),
          ),
          Divider(color: AppColors.divider, height: 1),
          ListTile(
            leading: const Icon(Icons.policy, color: AppColors.primary),
            title: const Text('Privacy Policy', style: TextStyle(color: AppColors.textPrimary)),
            onTap: () {
              // TODO: Implement navigation or show Privacy Policy
            },
          ),
          Divider(color: AppColors.divider, height: 1),
          ListTile(
            leading: const Icon(Icons.description, color: AppColors.primary),
            title: const Text('Terms of Service', style: TextStyle(color: AppColors.textPrimary)),
            onTap: () {
              // TODO: Implement navigation or show Terms of Service
            },
          ),
        ],
      ),
    );
  }
}
