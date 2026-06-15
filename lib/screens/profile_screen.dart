import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nextpay/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

const _bg = Color(0xFFF3EBDD);
const _dark = Color(0xFF1A0A00);
const _border = Color(0xFF111111);
const _orange = Color(0xFFC85A1E);
const _muted = Color(0xFF9A7A5A);
const _cream = Color(0xFFEFE4D1);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final ImagePicker _imagePicker = ImagePicker();
  File? _profileImage;

  static const _prefKey = 'profile_image_path';

  @override
  void initState() {
    super.initState();
    _loadSavedImage();
  }

  Future<void> _loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_prefKey);
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        setState(() => _profileImage = file);
      } else {
        await prefs.remove(_prefKey);
      }
    }
  }

  Future<void> _saveImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, path);
  }

  Future<void> _clearImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  Future<File> _persistImage(File tempFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final permanent = File('${appDir.path}/profile_photo.jpg');
    return tempFile.copy(permanent.path);
  }

  Future<void> _handleShare() async {
    try {
      final imageBytes = await _screenshotController.capture();
      if (imageBytes == null) return;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/offlinepay_qr.png');
      await file.writeAsBytes(imageBytes);
      await Share.shareXFiles([XFile(file.path)], text: 'Scan to pay me');
    } catch (e) {
      debugPrint("Share error: $e");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (picked == null) return;
      final permanent = await _persistImage(File(picked.path));
      await _saveImagePath(permanent.path);
      setState(() => _profileImage = permanent);
    } catch (e) {
      debugPrint("Image pick error: $e");
    }
  }

  Future<void> _removeImage() async {
    if (_profileImage != null) {
      try {
        if (await _profileImage!.exists()) await _profileImage!.delete();
      } catch (_) {}
    }
    await _clearImagePath();
    setState(() => _profileImage = null);
  }

  Future<void> _handleLogout() async {
    final auth = context.read<AuthProvider>();
    await auth.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  // Opens full-screen zoomable photo viewer
  void _openPhotoViewer() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => _PhotoViewerScreen(image: _profileImage!),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.zero),
        side: BorderSide(color: _border, width: 3),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: _border, width: 2)),
              ),
              child: const Text(
                "CHANGE PHOTO",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: _muted, letterSpacing: 2),
              ),
            ),
            _sheetOption(
              icon: Icons.photo_library_outlined,
              label: "Choose from Gallery",
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            Container(height: 2, color: _border, margin: const EdgeInsets.symmetric(horizontal: 16)),
            _sheetOption(
              icon: Icons.camera_alt_outlined,
              label: "Take a Photo",
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            if (_profileImage != null) ...[
              Container(height: 2, color: _border, margin: const EdgeInsets.symmetric(horizontal: 16)),
              _sheetOption(
                icon: Icons.delete_outline,
                label: "Remove Photo",
                color: _orange,
                onTap: () {
                  Navigator.pop(context);
                  _removeImage();
                },
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _sheetOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = _dark,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    final userId = user?.id ?? "";
    final userName = user?.name.isNotEmpty == true ? user!.name : "User";
    final userEmail = user?.email ?? "";

    final initials = userName
        .split(" ")
        .where((n) => n.isNotEmpty)
        .map((n) => n[0])
        .join("")
        .toUpperCase();
    final initialsShort = initials.length > 2 ? initials.substring(0, 2) : initials;

    final qrValue = jsonEncode({"userId": userId, "receiverName": userName});

    String memberSince = "—";
    final createdAt = user?.extra['created_at'];
    if (createdAt != null) {
      try {
        final date = DateTime.parse(createdAt.toString());
        const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
        memberSince = "${months[date.month - 1]} ${date.year}";
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // HEADER
          Container(
            color: _dark,
            padding: EdgeInsets.fromLTRB(
              16,
              Theme.of(context).platform == TargetPlatform.iOS ? 54 : 40,
              16,
              16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  ),
                  child: const SizedBox(
                    width: 40,
                    child: Text("←", style: TextStyle(color: _bg, fontSize: 24, fontWeight: FontWeight.w900)),
                  ),
                ),
                const Text(
                  "MY PROFILE",
                  style: TextStyle(color: _bg, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 2),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // AVATAR SECTION
                  Container(
                    color: _dark,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            // Avatar — tap to VIEW photo
                            GestureDetector(
                              onTap: _profileImage != null ? _openPhotoViewer : _showImageSourceSheet,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: _orange,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFFF8C42), width: 3),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: _profileImage != null
                                    ? Image.file(_profileImage!, fit: BoxFit.cover, width: 80, height: 80)
                                    : Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    initialsShort,
                                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ),
                            ),
                            // Camera badge — tap to CHANGE photo
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _showImageSourceSheet,
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: _orange,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: _border, width: 2),
                                  ),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 13),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          userName,
                          style: const TextStyle(color: _bg, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        ),
                        // Hint text when photo exists
                        if (_profileImage != null) ...[
                          const SizedBox(height: 4),
                          const Text(
                            "tap photo to view",
                            style: TextStyle(color: _muted, fontSize: 11, letterSpacing: 1),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // QR CARD
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _cream,
                      border: Border.all(color: _border, width: 3),
                      boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(5, 5), blurRadius: 0)],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "SCAN TO PAY ME",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: _muted, letterSpacing: 2),
                        ),
                        const SizedBox(height: 16),
                        Screenshot(
                          controller: _screenshotController,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: _border, width: 3)),
                            child: QrImageView(
                              data: qrValue.isNotEmpty ? qrValue : "empty",
                              size: 200,
                              backgroundColor: Colors.white,
                              eyeStyle: const QrEyeStyle(color: _border),
                              dataModuleStyle: const QrDataModuleStyle(color: _border),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(color: _bg, border: Border.all(color: _border, width: 2)),
                          alignment: Alignment.center,
                          child: Text(
                            userName,
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.w800, color: _border, letterSpacing: 1),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: _orange,
                            border: Border.all(color: _border, width: 3),
                            boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _handleShare,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: Text(
                                    "SHARE QR CODE",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // INFO CARD
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: _cream,
                      border: Border.all(color: _border, width: 3),
                      boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(5, 5), blurRadius: 0)],
                    ),
                    child: Column(
                      children: [
                        _infoRow("USER NAME", userId.isNotEmpty ? userName : "—"),
                        _infoDivider(),
                        _infoRow("EMAIL", userEmail.isNotEmpty ? userEmail : "—"),
                        _infoDivider(),
                        _infoRow("USER ID", userId.isNotEmpty ? userId : "—"),
                        _infoDivider(),
                        _infoRow("MEMBER SINCE", memberSince),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                ],
              ),

            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: _muted, letterSpacing: 1.5)),
          Flexible(
            child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _border)),
          ),
        ],
      ),
    );
  }

  Widget _infoDivider() {
    return Container(height: 2, color: _border, margin: const EdgeInsets.symmetric(horizontal: 16));
  }
}

// ─── Full-screen photo viewer ───────────────────────────────────────────────

class _PhotoViewerScreen extends StatelessWidget {
  final File image;
  const _PhotoViewerScreen({required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Zoomable image
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.file(image, fit: BoxFit.contain),
            ),
          ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _dark.withOpacity(0.7),
                  shape: BoxShape.circle,
                  border: Border.all(color: _border, width: 2),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),

          // "YOUR PHOTO" label at bottom
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            left: 0,
            right: 0,
            child: const Text(
              "YOUR PHOTO",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}