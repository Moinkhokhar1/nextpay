import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';

// Theme colors matching the RN styles
const _bg = Color(0xFFF3EBDD);
const _card = Color(0xFFEFE4D1);
const _border = Color(0xFF111111);
const _orange = Color(0xFFC85A1E);
const _muted = Color(0xFF9A7A5A);
const _dark = Color(0xFF1A0A00);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showAlert("Error", "All fields required");
      return;
    }

    final auth = context.read<AuthProvider>();
    final result = await auth.register(name, email, password);

    if (!mounted) return;

    if (result["success"] == true) {
      await _showAlert("Success", "Account created!");
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      _showAlert("Error", result["message"] ?? "Registration failed");
    }
  }

  Future<void> _showAlert(String title, String message) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // Reusable hard-shadow decoration matching shadowOffset: {6,6} etc.
  BoxDecoration _hardShadowBox({Color color = _card, double offset = 5}) {
    return BoxDecoration(
      color: color,
      border: Border.all(color: _border, width: 3),
      boxShadow: [
        BoxShadow(
          color: Colors.black,
          offset: Offset(offset, offset),
          blurRadius: 0,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BACK BUTTON
              Container(
                width: 44,
                height: 44,
                decoration: _hardShadowBox(color: const Color(0xFFEFE4D1), offset: 4),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Center(
                      child: Text(
                        "←",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: _border,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // BRAND
              const Text(
                "OFFLINEPAY",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: _orange,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "CREATE YOUR ACCOUNT",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: _muted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 28),

              // FORM CARD
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _hardShadowBox(offset: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Join OfflinePay",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: _border,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "Set up your wallet in seconds",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7A6A5A),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // NAME
                    _fieldLabel("FULL NAME"),
                    _inputField(
                      icon: "✦",
                      controller: _nameController,
                      hint: "Your name",
                    ),
                    const SizedBox(height: 16),

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
                      hint: "Min. 8 characters",
                      obscure: !_showPassword,
                      trailing: GestureDetector(
                        onTap: () => setState(() => _showPassword = !_showPassword),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            _showPassword ? "🙈" : "👁",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // REGISTER BUTTON
              Container(
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
                    onTap: _handleRegister,
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "CREATE ACCOUNT",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            "→",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
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
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: _muted,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(child: Divider(color: Color(0xFFC8B89A), thickness: 2)),
                ],
              ),
              const SizedBox(height: 16),

              // LOGIN LINK
              Container(
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
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: const Center(
                      child: Text(
                        "ALREADY HAVE AN ACCOUNT",
                        style: TextStyle(
                          color: _bg,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: _muted,
          letterSpacing: 2,
        ),
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
            child: Text(
              icon,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboardType,
              autocorrect: false,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _border,
              ),
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