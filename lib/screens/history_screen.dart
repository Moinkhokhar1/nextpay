import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/wallet_transaction.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'dart:convert';
import '../services/storage_service.dart';


const _bg = Color(0xFFF3EBDD);
const _dark = Color(0xFF1A0A00);
const _border = Color(0xFF111111);
const _orange = Color(0xFFC85A1E);
const _muted = Color(0xFF9A7A5A);

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<WalletTransaction> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoad());
  }

  Future<void> _maybeLoad() async {
    final auth = context.read<AuthProvider>();
    final currentUserId = _resolveUserId(auth);

    if (auth.hydrated && currentUserId != null) {
      await _loadTransactions();
    } else if (auth.hydrated) {
      setState(() => _loading = false);
    }
  }

  String? _resolveUserId(AuthProvider auth) {
    final user = auth.user;
    if (user == null) return null;
    final walletUserId = user.wallet?.extra['user_id'];
    if (walletUserId != null) return walletUserId.toString();
    final userIdExtra = user.extra['user_id'];
    if (userIdExtra != null) return userIdExtra.toString();
    return user.id;
  }

  // In history_screen.dart — replace _loadTransactions() with this:

  Future<void> _loadTransactions() async {
    try {
      final response = await ApiService.instance.get("/wallet/transactions");
      final List<dynamic> data = response.data;
      final txs = data
          .map((e) => WalletTransaction.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      // Cache to local storage for offline use
      await StorageService.setItem("cached_transactions", jsonEncode(data));

      setState(() => _transactions = txs);
    } catch (error) {
      debugPrint("HISTORY ERROR (trying cache): $error");

      // Offline fallback — load from cache
      try {
        final cached = await StorageService.getItem("cached_transactions");
        if (cached != null) {
          final List<dynamic> data = jsonDecode(cached);
          final txs = data
              .map((e) => WalletTransaction.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          setState(() => _transactions = txs);
        }
      } catch (e) {
        debugPrint("CACHE LOAD ERROR: $e");
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.hydrated || _loading) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator(color: _orange)),
      );
    }

    final currentUserId = _resolveUserId(auth);

    final received = _transactions
        .where((tx) => tx.receiverId == currentUserId)
        .toList();
    final sent = _transactions
        .where((tx) => tx.receiverId != currentUserId)
        .toList();

    final totalReceived = received.fold<num>(0, (s, tx) => s + tx.amount);
    final totalSent = sent.fold<num>(0, (s, tx) => s + tx.amount);

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
              children: [
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  ),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.15), width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "←",
                      style: TextStyle(
                          color: _bg,
                          fontSize: 20,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "WALLET",
                      style: TextStyle(
                          color: _muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2),
                    ),
                    Text(
                      "History",
                      style: TextStyle(
                          color: _bg,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // SUMMARY STRIP
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: _dark,
              border:
              Border(bottom: BorderSide(color: _orange, width: 3)),
            ),
            child: Row(
              children: [
                _summaryItem("RECEIVED",
                    "+ ₹${totalReceived.toStringAsFixed(2)}",
                    const Color(0xFF5DFF9A)),
                _summaryDivider(),
                _summaryItem(
                    "SENT",
                    "- ₹${totalSent.toStringAsFixed(2)}",
                    const Color(0xFFFF8A8A)),
                _summaryDivider(),
                _summaryItem(
                    "TOTAL TXS", "${_transactions.length}", _bg),
              ],
            ),
          ),

          // LIST
          Expanded(
            child: _transactions.isEmpty
                ? const _EmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final item = _transactions[index];
                return _TransactionCard(
                  item: item,
                  isReceived: item.receiverId == currentUserId,
                );
              },
            ),
          ),

          const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text(
              "© 2025 Built by moinworksonlocalhost",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _muted,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
                color: _muted,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
                color: valueColor,
                fontSize: 15,
                fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _summaryDivider() {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.white.withOpacity(0.1),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final WalletTransaction item;
  final bool isReceived;

  const _TransactionCard({required this.item, required this.isReceived});

  @override
  Widget build(BuildContext context) {
    final amountColor =
    isReceived ? const Color(0xFF1E6B37) : const Color(0xFFC62828);
    final amountFormatted = item.amount.toStringAsFixed(2);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFE4D1),
        border: Border.all(color: _border, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(5, 5), blurRadius: 0),
        ],
      ),
      // ✅ FIX: IntrinsicHeight allows crossAxisAlignment.stretch in ListView
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5, color: amountColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${isReceived ? '+' : '-'}₹$amountFormatted",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: amountColor,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              isReceived ? "↓ RECEIVED" : "↑ SENT",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: amountColor,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: item.isOffline
                                    ? const Color(0xFF8E8E8E)
                                    : const Color(0xFF2E9E50),
                                border: Border.all(color: _border, width: 2),
                              ),
                              child: Text(
                                item.isOffline ? "OFFLINE" : "ONLINE",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _bg,
                                border: Border.all(color: _border, width: 2),
                              ),
                              child: Text(
                                item.status.toUpperCase(),
                                style: const TextStyle(
                                  color: _border,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      height: 2,
                      color: _border,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    RichText(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7A6A5A),
                          letterSpacing: 0.5,
                        ),
                        children: [
                          TextSpan(
                              text: isReceived ? "FROM: " : "TO: "),
                          TextSpan(
                            text: isReceived
                                ? item.senderId
                                : item.receiverId,
                            style: const TextStyle(
                                color: _border,
                                fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Text("📭", style: TextStyle(fontSize: 48)),
          SizedBox(height: 16),
          Text(
            "NO TRANSACTIONS",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: _border,
                letterSpacing: 2),
          ),
          SizedBox(height: 6),
          Text(
            "Your history will appear here",
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _muted),
          ),
        ],
      ),
    );
  }
}