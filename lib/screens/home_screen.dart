import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../providers/auth_provider.dart';
import '../offline/wallet_engine.dart';
import '../offline/sync_engine.dart';
import '../services/storage_service.dart';
import 'profile_screen.dart';
import 'send_screen.dart';
import 'scanner_screen.dart';
import 'pending_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';

const _bg = Color(0xFFF3EBDD);
const _dark = Color(0xFF1A0A00);
const _orange = Color(0xFFC85A1E);
const _muted = Color(0xFF9A7A5A);
const _cream = Color(0xFFEFE4D1);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isOnline = true;
  bool _balanceVisible = false;
  File? _profileImage;                          // ✅ NEW
  static const _prefKey = 'profile_image_path'; // ✅ NEW
  StreamSubscription<List<ConnectivityResult>>? _connSub;

  @override
  void initState() {
    super.initState();

    _loadProfileImage(); // ✅ NEW

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchWallet();
    });

    _connSub = Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (mounted) setState(() => _isOnline = online);
    });

    Connectivity().checkConnectivity().then((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (mounted) setState(() => _isOnline = online);
    });
  }

  // ✅ NEW — reads same key ProfileScreen saves to
  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_prefKey);
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        if (mounted) setState(() => _profileImage = file);
      } else {
        await prefs.remove(_prefKey);
      }
    }
  }

  @override
  void dispose() {
    _connSub?.cancel();
    super.dispose();
  }

  Future<void> _handleSync() async {
    final auth = context.read<AuthProvider>();
    final walletEngine = WalletEngine(auth);
    final syncEngine = SyncEngine(auth, walletEngine);

    try {
      final result = await syncEngine.syncPendingTransactions();
      debugPrint("SYNC RESULT: $result");
      if (result["success"] == true) {
        await StorageService.removeItem("local_wallet");
        await Future.delayed(const Duration(milliseconds: 500));
        await auth.fetchWallet();
        if (mounted) _showAlert("Synced", "All transactions completed.");
      } else {
        if (mounted) {
          _showAlert("Nothing to sync", result["message"] ?? "No pending transactions.");
        }
      }
    } catch (error) {
      if (mounted) _showAlert("Error", "Sync failed");
    }
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

  // ✅ CHANGED — async so we reload photo on return
  Future<void> _navigate(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    _loadProfileImage(); // refresh photo whenever returning from any screen
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    final balance = (user?.wallet?.balance ?? 0).toDouble();
    final lockedBalance = (user?.wallet?.lockedBalance ?? 0).toDouble();
    final availableBalance = (balance - lockedBalance).toStringAsFixed(2);
    final lockedBalanceDisplay = lockedBalance.toStringAsFixed(2);
    final totalBalance = balance.toStringAsFixed(2);
    final userName = user?.name.isNotEmpty == true ? user!.name : "User";

    final initials = userName
        .split(" ")
        .where((n) => n.isNotEmpty)
        .map((n) => n[0])
        .join("")
        .toUpperCase();
    final initialsShort = initials.length > 2 ? initials.substring(0, 2) : initials;

    const mask = "*****";

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // HEADER
          Container(
            color: _dark,
            padding: EdgeInsets.fromLTRB(
              20,
              Theme.of(context).platform == TargetPlatform.iOS ? 54 : 40,
              20,
              20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // ✅ CHANGED — shows photo if available, else initials
                    GestureDetector(
                      onTap: () => _navigate(const ProfileScreen()),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _orange,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE8845A), width: 2),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _profileImage != null
                            ? Image.file(
                          _profileImage!,
                          fit: BoxFit.cover,
                          width: 44,
                          height: 44,
                        )
                            : Center(
                          child: Text(
                            initialsShort,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "GOOD DAY,",
                          style: TextStyle(
                              color: Color(0xFF7A5A3A), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1),
                        ),
                        Text(
                          userName,
                          style: const TextStyle(color: _bg, fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isOnline ? const Color(0xFF1E6B37) : const Color(0xFF8B1A1A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: _isOnline ? const Color(0xFFA8F0C6) : const Color(0xFFFFAAAA),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isOnline ? "ONLINE" : "OFFLINE",
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  // BALANCE CARD
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    padding: const EdgeInsets.all(28),
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: _dark,
                      border: Border.all(color: _orange, width: 3),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          offset: const Offset(0, 6),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -70,
                          right: -50,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: _orange.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -30,
                          left: 10,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: _orange.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "AVAILABLE BALANCE",
                                  style: TextStyle(color: Color(0xFF7A5A3A), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() => _balanceVisible = !_balanceVisible),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Text(_balanceVisible ? "👁" : "🙈", style: const TextStyle(fontSize: 18)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _balanceVisible ? "₹$availableBalance" : "₹$mask",
                              style: const TextStyle(color: _bg, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -1),
                            ),
                            Container(
                              height: 1,
                              margin: const EdgeInsets.symmetric(vertical: 16),
                              color: _orange.withOpacity(0.3),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("TOTAL", style: TextStyle(color: Color(0xFF7A5A3A), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                                    const SizedBox(height: 2),
                                    Text(
                                      _balanceVisible ? "₹$totalBalance" : "₹$mask",
                                      style: const TextStyle(color: _orange, fontSize: 18, fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                                if (lockedBalance > 0)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text("LOCKED", style: TextStyle(color: Color(0xFFFFD580), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                                      const SizedBox(height: 2),
                                      Text(
                                        _balanceVisible ? "₹$lockedBalanceDisplay" : "₹$mask",
                                        style: const TextStyle(color: Color(0xFFFFD580), fontSize: 18, fontWeight: FontWeight.w800),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // QUICK ACTIONS
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "QUICK ACTIONS",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: _muted, letterSpacing: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(child: _quickAction("SEND", "↑", _orange, () => _navigate(const SendScreen()))),
                        const SizedBox(width: 8),
                        Expanded(child: _quickAction("SCAN", "⊡", const Color(0xFF1E6B37), () => _navigate(const ScannerScreen()))),
                        const SizedBox(width: 8),
                        Expanded(child: _quickAction("PENDING", "⏳", const Color(0xFF2A1A0E), () => _navigate(const PendingScreen()))),
                        const SizedBox(width: 8),
                        Expanded(child: _quickAction("HISTORY", "≡", const Color(0xFF2A1A0E), () => _navigate(const HistoryScreen()))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // MENU LIST
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "MORE",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: _muted, letterSpacing: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: _cream,
                      border: Border.all(color: _dark, width: 2),
                      boxShadow: const [
                        BoxShadow(color: _dark, offset: Offset(4, 4), blurRadius: 0),
                      ],
                    ),
                    child: Column(
                      children: [
                        _menuItem("₹", _orange, "Send Money", "Transfer to any wallet", () => _navigate(const SendScreen())),
                        _menuDivider(),
                        _menuItem("⏳", const Color(0xFF1E6B37), "Pending Transactions", "Offline queue waiting to sync", () => _navigate(const PendingScreen())),
                        _menuDivider(),
                        _menuItem("📋", const Color(0xFF2A1A0E), "Transaction History", "All completed payments", () => _navigate(const HistoryScreen())),
                        _menuDivider(),
                        _menuItem("🔁", const Color(0xFF2A1A0E), "Sync Transactions", "Push offline payments online", _handleSync),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // LOGOUT
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: _dark,
                      border: Border.all(color: _dark, width: 2),
                      boxShadow: const [
                        BoxShadow(color: _dark, offset: Offset(4, 4), blurRadius: 0),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _handleLogout,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 18),
                          child: Center(
                            child: Text(
                              "LOG OUT",
                              style: TextStyle(color: _bg, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    "© 2025 Built by moinworksonlocalhost",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _muted, letterSpacing: 1),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(String label, String icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _dark, width: 2),
              boxShadow: const [
                BoxShadow(color: _dark, offset: Offset(3, 3), blurRadius: 0),
              ],
            ),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF2A1A0E), letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _menuItem(String icon, Color bg, String title, String sub, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: _dark, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(icon, style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _dark)),
                    const SizedBox(height: 2),
                    Text(sub, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _muted, letterSpacing: 0.3)),
                  ],
                ),
              ),
              const Text("›", style: TextStyle(fontSize: 24, color: _orange, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: _dark.withOpacity(0.15),
    );
  }
}