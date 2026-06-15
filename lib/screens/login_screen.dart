import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'register_screen.dart';

const _bg = Color(0xFFF3EBDD);
const _card = Color(0xFFEFE4D1);
const _border = Color(0xFF111111);
const _orange = Color(0xFFC85A1E);
const _muted = Color(0xFF9A7A5A);
const _dark = Color(0xFF1A0A00);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showAlert("Error", "All fields required");
      return;
    }

    final auth = context.read<AuthProvider>();
    final result = await auth.login(email, password);

    if (!mounted) return;

    if (result["success"] == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
      );
    } else {
      _showAlert("Error", result["message"] ?? "Login failed");
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // BRAND
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: _orange,
                        border: Border.all(color: _border, width: 3),
                        boxShadow: const [
                          BoxShadow(color: Colors.black, offset: Offset(5, 5), blurRadius: 0),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "OP",
                        style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 2),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "OFFLINEPAY",
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: _orange, letterSpacing: 3),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "SECURE OFFLINE PAYMENTS",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: _muted, letterSpacing: 2),
                    ),
                    const SizedBox(height: 36),

                    // FORM CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _card,
                        border: Border.all(color: _border, width: 3),
                        boxShadow: const [
                          BoxShadow(color: Colors.black, offset: Offset(5, 5), blurRadius: 0),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome back",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _border),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "Sign in to your account",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF7A6A5A)),
                          ),
                          const SizedBox(height: 20),

                          // EMAIL
                          _fieldLabel("EMAIL"),
                          _inputField(
                            icon: "@",
                            controller: _emailController,
                            hint: "you@email.com",
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),

                          // PASSWORD
                          _fieldLabel("PASSWORD"),
                          _inputField(
                            icon: "🔒",
                            controller: _passwordController,
                            hint: "••••••••",
                            obscure: !_showPassword,
                            trailing: GestureDetector(
                              onTap: () => setState(() => _showPassword = !_showPassword),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Text(_showPassword ? "🙈" : "👁", style: const TextStyle(fontSize: 16)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // LOGIN BUTTON
                    Container(
                      width: double.infinity,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _orange,
                        border: Border.all(color: _border, width: 3),
                        boxShadow: const [
                          BoxShadow(color: Colors.black, offset: Offset(6, 6), blurRadius: 0),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _handleLogin,
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "SIGN IN",
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "→",
                                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // DIVIDER
                    Row(
                      children: const [
                        Expanded(child: Divider(color: Color(0xFFC8B89A), thickness: 2)),
                        SizedBox(width: 12),
                        Text(
                          "OR",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: _muted, letterSpacing: 2),
                        ),
                        SizedBox(width: 12),
                        Expanded(child: Divider(color: Color(0xFFC8B89A), thickness: 2)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // REGISTER LINK
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _dark,
                        border: Border.all(color: _border, width: 3),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          ),
                          child: const Center(
                            child: Text(
                              "CREATE ACCOUNT",
                              style: TextStyle(color: _bg, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                "© 2025 Built by moinworksonlocalhost",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _muted, letterSpacing: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _muted, letterSpacing: 2),
      ),
    );
  }

  Widget _inputField({
    required String icon,
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _bg,
        border: Border.all(color: _border, width: 3),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 52,
            decoration: const BoxDecoration(
              color: _orange,
              border: Border(right: BorderSide(color: _border, width: 3)),
            ),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboardType,
              autocorrect: false,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _border),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: _muted),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}