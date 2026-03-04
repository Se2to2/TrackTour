import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  String _selectedRole = 'user';
  bool _isLoading = false;

  // colors as login
  static const Color bgColor = Color(0xFF0A0A0A);
  static const Color accentColor = Color(0xFF7B6EF6);
  static const Color fieldColor = Color(0xFF1E1E1E);
  static const Color textColor = Colors.white;
  static const Color subTextColor = Color(0xFF888888);
  static const Color labelColor = Color(0xFF9B9B9B);

  void _register() async {
    // Check passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Passwords do not match'),
          backgroundColor: Colors.red.shade800,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    String result = await _authService.register(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
      _selectedRole,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result == 'success') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(role: _selectedRole),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: labelColor,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      style: TextStyle(
        color: textColor,
        fontSize: obscure ? 18 : 14,
        letterSpacing: obscure ? 4.0 : 1.0,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: const Color(0xFF555555),
          fontSize: obscure ? 18 : 14,
          letterSpacing: obscure ? 4.0 : 1.0,
        ),
        filled: true,
        fillColor: fieldColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
    );
  }

  Widget _buildRoleChip(String value, String label) {
    final bool selected = _selectedRole == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? accentColor : fieldColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : subTextColor,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable form content
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                children: [
                  // Top Logo Section
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/Loge.png',
                          width: 90,
                          height: 90,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'TRACKTOUR',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage your Favorite Gaming Tournaments',
                          style: TextStyle(
                            color: subTextColor,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Form Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Center(
                          child: Text(
                            'Create new\nAccount',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Already registered link
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            ),
                            child: RichText(
                              text: TextSpan(
                                text: 'Already Registered? ',
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 13,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Log in here.',
                                    style: TextStyle(
                                      color: accentColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Name
                        _buildLabel('NAME'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _nameController,
                          hint: '',
                        ),
                        const SizedBox(height: 18),

                        // Email
                        _buildLabel('EMAIL'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _emailController,
                          hint: '',
                          keyboard: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 18),

                        // Password
                        _buildLabel('PASSWORD'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _passwordController,
                          hint: '',
                          obscure: true,
                        ),
                        const SizedBox(height: 18),

                        // Confirm Password
                        _buildLabel('CONFIRM PASSWORD'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _confirmPasswordController,
                          hint: '',
                          obscure: true,
                        ),
                        const SizedBox(height: 18),

                        // TODO: TEMPORARY - Remove role selection before release!
                        // Replace with proper role assignment (e.g. invite codes or
                        // admin-only creation panel). Do NOT ship this to production.
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.5),
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.orange.withOpacity(0.05),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.orange,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'TEMPORARY — REMOVE BEFORE RELEASE',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              _buildLabel('ACCOUNT TYPE'),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildRoleChip('user', 'User'),
                                  const SizedBox(width: 12),
                                  _buildRoleChip('admin', 'Admin'),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Sign Up Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: textColor,
                              disabledBackgroundColor:
                                  accentColor.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Sign up',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Wave pinned to bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipPath(
                clipper: _BottomWaveClipper(),
                child: Container(
                  height: 80,
                  width: double.infinity,
                  color: accentColor.withOpacity(0.85),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.25, 0,
      size.width * 0.5, size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.6,
      size.width, size.height * 0.2,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}