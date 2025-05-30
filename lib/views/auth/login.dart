import 'package:emotion_music_player/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/snackbar.dart';
import '../../widgets/text_field.dart';
import '../../widgets/button.dart';
import '../../theme/app_colors.dart';
import '../../views/main_navigator.dart';
import 'signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    if (!_validateInputs()) return;

    final viewmodel = Provider.of<AuthViewModel>(context, listen: false);

    try {
      final success = await viewmodel.login(
        emailController.text.trim(),
        passwordController.text.trim(),
        _rememberMe,
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigator()),
        );
      } else if (!success && mounted) {
        showSnackBar(context, viewmodel.errorMessage ?? 'Login failed. Please check your credentials.');
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, viewmodel.errorMessage ?? 'An error occurred during login.');
      }
    }
  }

  bool _validateInputs() {
    if (emailController.text.trim().isEmpty) {
      showSnackBar(context, 'Please enter your email');
      return false;
    }
    if (passwordController.text.trim().isEmpty) {
      showSnackBar(context, 'Please enter your password');
      return false;
    }
    if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(emailController.text.trim())) {
      showSnackBar(context, 'Please enter a valid email');
      return false;
    }
    return true;
  }
  Future<void> loginWithGoogle() async {
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App logo/branding
                Padding(
                  padding: const EdgeInsets.only(top: 30, bottom: 30),
                  child: Column(
                    children: [
                      Icon(
                        Icons.music_note_rounded,
                        size: 60,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Emotion Music Player",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Sign in to your account",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Login form
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
                      
                      // Remember me checkbox
                      Theme(
                        data: Theme.of(context).copyWith(
                          checkboxTheme: CheckboxThemeData(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            fillColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.selected)) {
                                  return AppColors.primary;
                                }
                                return AppColors.surfaceLight;
                              },
                            ),
                          ),
                        ),
                        child: CheckboxListTile(
                          title: Text(
                            'Remember me',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          value: _rememberMe,
                          onChanged: (bool? value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: const EdgeInsets.only(left: 8),
                          dense: true,
                          activeColor: AppColors.primary,
                          checkColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Login button
                if (viewmodel.isLoading)
                  const CircularProgressIndicator(
                    color: AppColors.primary,
                  )
                else
                  MyButtons(onTap: loginUser, text: "SIGN IN"),
                
                // Google sign-in button
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: loginWithGoogle,
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
                            "Sign in with Google",
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
                
                // Forgot password
                TextButton(
                  onPressed: () {
                    // Add forgot password functionality
                    showSnackBar(context, 'Password reset coming soon!');
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Sign up redirect
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Sign Up",
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