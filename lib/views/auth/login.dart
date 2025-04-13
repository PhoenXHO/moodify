import 'package:emotion_music_player/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/snackbar.dart';
import '../../widgets/text_field.dart';
import '../../widgets/button.dart';
import 'signup.dart';
import '../../widgets/bottomnav.dart';

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
    // Load remembered credentials if any
    _loadRememberedCredentials();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadRememberedCredentials() async {
    final viewmodel = Provider.of<AuthViewModel>(context, listen: false);
    final remembered = await viewmodel.getRememberedCredentials();
    if (remembered != null) {
      setState(() {
        emailController.text = remembered.email;
        passwordController.text = remembered.password;
        _rememberMe = true;
      });
    }
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
        if (_rememberMe) {
          await viewmodel.saveCredentials(
            emailController.text.trim(),
            passwordController.text.trim(),
          );
        } else {
          await viewmodel.clearCredentials();
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const BottomNav()),
        );
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, viewmodel.errorMessage ?? 'An error occurred');
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
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(emailController.text.trim())) {
      showSnackBar(context, 'Please enter a valid email');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    final viewmodel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: height / 3,
                  child: Image.asset('images/login.jpg'),
                ),
                const SizedBox(height: 20),
                TextFieldInput(
                  icon: Icons.person,
                  textEditingController: emailController,
                  hintText: 'Enter your email',
                  textInputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),
                TextFieldInput(
                  icon: Icons.lock,
                  textEditingController: passwordController,
                  hintText: 'Enter your password',
                  textInputType: TextInputType.text,
                  isPass: true,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: CheckboxListTile(
                    title: const Text('Remember me'),
                    value: _rememberMe,
                    onChanged: (bool? value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.only(left: 20.0),
                    visualDensity: const VisualDensity(horizontal: -4),
                  ),
                ),
                const SizedBox(height: 20),
                if (viewmodel.isLoading)
                  const CircularProgressIndicator()
                else
                  MyButtons(onTap: loginUser, text: "Log In"),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}