import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';

const _bg = Color(0xFFF3EBDD);
const _dark = Color(0xFF1A0A00);
const _border = Color(0xFF111111);
const _orange = Color(0xFFC85A1E);
const _muted = Color(0xFF9A7A5A);

class PendingScreen extends StatefulWidget {
  const PendingScreen({super.key});

  @override
  State<PendingScreen> createState() => _PendingScreenState();
}

class _PendingScreenState extends State<PendingScreen> {
  List<OfflineTransaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTransactions());
  }

  Future<void> _loadTransactions() async {
    try {
      final auth = context.read<AuthProvider>();
      final user = auth.user;
      if (user == null) return;

      // Use same ID resolution as TransactionEngine and SyncEngine
      final senderId = user.wallet?.extra['user_id']?.toString() ?? user.id;
      final storageKey = "pending_transactions_$senderId";
      debugPrint("PENDING STORAGE KEY: $storageKey");

      final data = await StorageService.getItem(storageKey);
      final List<dynamic> raw = data != null ? jsonDecode(data) : [];

      setState(() {
        _transactions = raw
            .map((e) => OfflineTransaction.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      });
    } catch (error) {
      debugPrint("LOAD TX ERROR: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalLocked = _transactions.fold<num>(0, (s, tx) => s + tx.amount);

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
                      border: Border.all(color: Colors.white.withOpacity(0.15), width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "←",
                      style: TextStyle(color: _bg, fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "OFFLINE QUEUE",
                      style: TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2),
                    ),
                    Text(
                      "Pending",
                      style: TextStyle(color: _bg, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // SUMMARY STRIP — FIX: color moved inside BoxDecoration
          if (_transactions.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              decoration: const BoxDecoration(
                color: _dark, // ← moved here from color: property
                border: Border(bottom: BorderSide(color: _orange, width: 3)),
              ),
              child: Row(
                children: [
                  _summaryItem("QUEUED", "${_transactions.length}", _bg),
                  _summaryDivider(),
                  _summaryItem("TOTAL LOCKED", "₹${totalLocked.toStringAsFixed(2)}", const Color(0xFFFFB347)),
                  _summaryDivider(),
                  _summaryItem("STATUS", "OFFLINE", const Color(0xFFFF8A8A)),
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
                return _PendingCard(item: _transactions[index]);
              },
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
            style: const TextStyle(color: _muted, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: valueColor, fontSize: 15, fontWeight: FontWeight.w900),
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

class _PendingCard extends StatelessWidget {
  final OfflineTransaction item;

  const _PendingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFE4D1),
        border: Border.all(color: _border, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(5, 5), blurRadius: 0),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5, color: _orange),
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
                              "₹${item.amount.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: _orange,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              "↑ SENT",
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: _orange, letterSpacing: 1),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _orange,
                            border: Border.all(color: _border, width: 2),
                          ),
                          child: const Text(
                            "PENDING",
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 2,
                      color: _border,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    _metaRow("STATUS: ", item.status.toUpperCase(), bold: true),
                    const SizedBox(height: 4),
                    _metaRow("TX ID: ", item.txId),
                    const SizedBox(height: 4),
                    _metaRow("TO: ", item.receiver),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaRow(String label, String value, {bool bold = false}) {
    return RichText(
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
          TextSpan(text: label),
          TextSpan(
            text: value,
            style: TextStyle(
              color: _border,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w800,
            ),
          ),
        ],
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
          Text("✅", style: TextStyle(fontSize: 48)),
          SizedBox(height: 16),
          Text(
            "ALL CLEAR",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _border, letterSpacing: 2),
          ),
          SizedBox(height: 6),
          Text(
            "No pending transactions",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _muted),
          ),
        ],
      ),
    );
  }
}