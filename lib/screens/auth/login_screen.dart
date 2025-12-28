import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/security_colors.dart';
import '../../navigation/app_shell.dart';

/// YouTube-inspired Sign In screen
/// Clean, modern, familiar, and highly usable
/// Bright and professional aesthetic
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // Mock login - just navigate to app shell
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AppShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SecurityColors.primaryBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),

                // App logo/name - centered, simple
                Text(
                  'ORIN',
                  style: GoogleFonts.orbitron(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 6,
                    color: SecurityColors.primaryText,
                  ),
                ),

                const SizedBox(height: 48),

                // Title and subtitle
                Column(
                  children: [
                    const Text(
                      'Sign in',
                      style: TextStyle(
                        color: SecurityColors.primaryText,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Continue to your CCTV dashboard',
                      style: TextStyle(
                        color: SecurityColors.secondaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Email field
                _buildInputField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  label: 'Email',
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  },
                ),

                const SizedBox(height: 16),

                // Password field
                _buildInputField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  label: 'Password',
                  hintText: 'Enter your password',
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleLogin(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: SecurityColors.secondaryText,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Sign in button
                SizedBox(
                  width: double.infinity,
                  child: _buildPrimaryButton(
                    text: 'Sign in',
                    onPressed: _handleLogin,
                  ),
                ),

                const SizedBox(height: 16),

                // Forgot password link
                GestureDetector(
                  onTap: () {
                    // Mock action
                  },
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: SecurityColors.secondaryAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hintText,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: SecurityColors.primaryText,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // Input field
        ListenableBuilder(
          listenable: focusNode,
          builder: (context, child) {
            final isFocused = focusNode.hasFocus;
            return Container(
              decoration: BoxDecoration(
                color: SecurityColors.secondarySurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isFocused
                      ? SecurityColors.accent
                      : SecurityColors.divider,
                  width: isFocused ? 2 : 1,
                ),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                obscureText: obscureText,
                keyboardType: keyboardType,
                textInputAction: textInputAction,
                onSubmitted: onSubmitted,
                style: const TextStyle(
                  color: SecurityColors.primaryText,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    color: SecurityColors.secondaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  suffixIcon: suffixIcon,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: SecurityColors.accent.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: SecurityColors.accent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
