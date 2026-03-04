import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  // Theme colors
  static const Color bgColor = Color(0xFF0A0A0A);
  static const Color accentColor = Color(0xFF7B6EF6); // purple
  static const Color fieldColor = Color(0xFF1E1E1E);
  static const Color textColor = Colors.white;
  static const Color subTextColor = Color(0xFF888888);
  static const Color labelColor = Color(0xFF9B9B9B);

  void _login() async {
    setState(() => _isLoading = true);

    String result = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result == 'success') {
      String role = await _authService.getUserRole();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(role: role)),
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // Top Logo Section
                  Padding(
                    padding: const EdgeInsets.only(top: 60.0),
                    child: Column(
                      children: [
                        // Logo Image
                        Image.asset(
                          'assets/Loge.png',
                          width: 110,
                          height: 110,
                        ),
                        const SizedBox(height: 12),
                        // App Name
                        Text(
                          'TRACKTOUR',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 22,
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

                  const SizedBox(height: 60),
                  Divider(
                  color: const Color(0xFF2A2A2A),
                  thickness: 1,
                  indent: 170,    
                  endIndent: 170, 
                  ),
                  const SizedBox(height: 50),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Login Title
                        Center(
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: Text(
                            'Sign in to continue.',
                            style: TextStyle(
                              color: subTextColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Email Label
                        Text(
                          'Email',
                          style: TextStyle(
                            color: labelColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Email Field
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            letterSpacing: 1.0,
                          ),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                              color: Color(0xFF555555),
                              letterSpacing: 1.0,
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
                        ),
                        const SizedBox(height: 20),

                        // Password Label
                        Text(
                          'Password',
                          style: TextStyle(
                            color: labelColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Password Field
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            letterSpacing: 4.0,
                          ),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                              color: Color(0xFF555555),
                              letterSpacing: 4.0,
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
                        ),
                        const SizedBox(height: 28),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: textColor,
                              disabledBackgroundColor: accentColor.withOpacity(0.5),
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
                                    'Log in',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Register Link
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                text: "Don't have an account? ",
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 13,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Register',
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
                      ],
                    ),
                  ),

                  const Spacer(),

                  ClipPath(
                    clipper: _BottomWaveClipper(),
                    child: Container(
                      height: 80,
                      width: double.infinity,
                      color: accentColor.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Poorple weyv
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