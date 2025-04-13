import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<AuthViewModel>(context, listen: false);

    // Appel à fetchUserProfile pour charger les données utilisateur
    viewModel.fetchUserProfile();

    // Ajouter un listener pour écouter les changements de données dans le ViewModel
    viewModel.addListener(() {
      if (viewModel.displayName != null && viewModel.displayEmail != null) {
        _displayNameController.text = viewModel.displayName ?? '';
        _emailController.text = viewModel.displayEmail ?? '';
      }
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveAll() async {
    final viewModel = Provider.of<AuthViewModel>(context, listen: false);

    final name = _displayNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty && email.isEmpty && password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nothing to update")),
      );
      return;
    }

    bool success = true;

    if (name.isNotEmpty && name != viewModel.displayName) {
      success &= await viewModel.updateDisplayName(name);
    }

    if (email.isNotEmpty && email != viewModel.displayEmail) {
      success &= await viewModel.updateEmail(email);
    }

    if (password.isNotEmpty) {
      success &= await viewModel.updatePassword(password);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User info updated successfully')),
        );
        _passwordController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.errorMessage ?? "An error occurred")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'New Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
            const SizedBox(height: 24),
            viewModel.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _saveAll,
                    child: const Text("Save Changes"),
                  ),
          ],
        ),
      ),
    );
  }
}
