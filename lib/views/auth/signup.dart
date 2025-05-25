import 'package:emotion_music_player/widgets/button.dart';
import 'package:emotion_music_player/views/main_navigator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/snackbar.dart';
import '../../widgets/text_field.dart';
import '../../theme/app_colors.dart';

import 'login.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
  }

  void signupUser() async {
    final viewmodel = Provider.of<AuthViewModel>(context, listen: false);

    // Input validation
    if (usernameController.text.trim().isEmpty) {
      showSnackBar(context, 'Please enter a username');
      return;
    }
    if (emailController.text.trim().isEmpty) {
      showSnackBar(context, 'Please enter an email');
      return;
    }
    if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(emailController.text.trim())) {
      showSnackBar(context, 'Please enter a valid email');
      return;
    }
    if (passwordController.text.trim().isEmpty) {
      showSnackBar(context, 'Please enter a password');
      return;
    }
    if (passwordController.text.trim().length < 6) {
      showSnackBar(context, 'Password must be at least 6 characters');
      return;
    }

    final success = await viewmodel.signUp(
      usernameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
    );
    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigator()),
      );
    } else if (mounted && viewmodel.errorMessage != null) {
      showSnackBar(context, viewmodel.errorMessage!);
    } else if (mounted) {
      // Generic error if no specific message from viewmodel      showSnackBar(context, 'Sign up failed. Please try again.');
    }
  }

  Future<void> signUpWithGoogle() async {
    final viewmodel = Provider.of<AuthViewModel>(context, listen: false);

    try {
      final success = await viewmodel.signInWithGoogle();

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigator()),
        );
      } else if (!success && mounted) {
        showSnackBar(context, viewmodel.errorMessage ?? 'Google Sign-In failed. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'An error occurred during Google Sign-In.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewmodel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App logo/branding
                Padding(
                  padding: const EdgeInsets.only(top: 40, bottom: 20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.music_note_rounded,
                        size: 60,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Sign up to start your music journey",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Signup form
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12, bottom: 8),
                        child: Text(
                          "Username",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      TextFieldInput(
                        icon: Icons.person_outline_rounded,
                        textEditingController: usernameController,
                        hintText: 'Enter your username',
                        textInputType: TextInputType.text,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Padding(
                        padding: const EdgeInsets.only(left: 12, bottom: 8),
                        child: Text(
                          "Email",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      TextFieldInput(
                        icon: Icons.email_outlined,
                        textEditingController: emailController,
                        hintText: 'Enter your email',
                        textInputType: TextInputType.emailAddress,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Padding(
                        padding: const EdgeInsets.only(left: 12, bottom: 8),
                        child: Text(
                          "Password",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      TextFieldInput(
                        icon: Icons.lock_outline_rounded,
                        textEditingController: passwordController,
                        hintText: 'Enter your password',
                        textInputType: TextInputType.text,
                        isPass: true,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Sign up button
                viewmodel.isLoading
                    ? const CircularProgressIndicator(
                        color: AppColors.primary,
                      )
                    : MyButtons(onTap: signupUser, text: "CREATE ACCOUNT"),
                
                const SizedBox(height: 8),
                
                // Custom Google sign-up button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,                    child: ElevatedButton(
                      onPressed: signUpWithGoogle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.textPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.g_mobiledata, color: AppColors.primary, size: 32),
                          const SizedBox(width: 8),
                          Text(
                            "Sign up with Google",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                
                // Terms & conditions note
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "By signing up, you agree to our Terms of Service and Privacy Policy",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Login redirect
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
