import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'send_screen.dart';

const _bg = Color(0xFFF3EBDD);
const _dark = Color(0xFF1A0A00);
const _orange = Color(0xFFC85A1E);
const _muted = Color(0xFF9A7A5A);

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _scanned = false;
  final MobileScannerController _controller = MobileScannerController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleBarcodeScanned(BarcodeCapture capture) {
    if (_scanned) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final data = barcodes.first.rawValue;
    if (data == null) return;

    setState(() => _scanned = true);

    String? receiverId;
    String? receiverName;

    try {
      final parsed = Map<String, dynamic>.from(jsonDecode(data));
      receiverId = parsed["userId"]?.toString();
      receiverName = parsed["receiverName"]?.toString();
    } catch (_) {
      // Plain string fallback — treat as receiverId
      receiverId = data;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SendScreen(
          receiverId: receiverId,
          receiverName: receiverName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _dark,
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
                  onTap: () => Navigator.pop(context),
                  child: const SizedBox(
                    width: 40,
                    child: Text("←", style: TextStyle(color: _bg, fontSize: 24, fontWeight: FontWeight.w900)),
                  ),
                ),
                const Text(
                  "SCAN QR",
                  style: TextStyle(color: _bg, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),

          // CAMERA
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _scanned ? (_) {} : _handleBarcodeScanned,
                ),
                _buildOverlay(),
              ],
            ),
          ),

          // FOOTER
          Container(
            color: _dark,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            child: Column(
              children: [
                const Text(
                  "Point camera at the recipient's QR code",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _muted, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                ),
                if (_scanned) ...[
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(color: _orange, border: Border.all(color: const Color(0xFF111111), width: 3)),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => setState(() => _scanned = false),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 18, horizontal: 32),
                          child: Text(
                            "SCAN AGAIN",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Column(
      children: [
        Expanded(child: Container(color: Colors.black.withOpacity(0.6))),
        SizedBox(
          height: 260,
          child: Row(
            children: [
              Expanded(child: Container(color: Colors.black.withOpacity(0.6))),
              SizedBox(
                width: 260,
                height: 260,
                child: Stack(
                  children: [
                    _corner(top: 0, left: 0, borderTop: true, borderLeft: true),
                    _corner(top: 0, right: 0, borderTop: true, borderRight: true),
                    _corner(bottom: 0, left: 0, borderBottom: true, borderLeft: true),
                    _corner(bottom: 0, right: 0, borderBottom: true, borderRight: true),
                  ],
                ),
              ),
              Expanded(child: Container(color: Colors.black.withOpacity(0.6))),
            ],
          ),
        ),
        Expanded(child: Container(color: Colors.black.withOpacity(0.6))),
      ],
    );
  }

  Widget _corner({
    double? top,
    double? bottom,
    double? left,
    double? right,
    bool borderTop = false,
    bool borderBottom = false,
    bool borderLeft = false,
    bool borderRight = false,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border(
            top: borderTop ? const BorderSide(color: _orange, width: 4) : BorderSide.none,
            bottom: borderBottom ? const BorderSide(color: _orange, width: 4) : BorderSide.none,
            left: borderLeft ? const BorderSide(color: _orange, width: 4) : BorderSide.none,
            right: borderRight ? const BorderSide(color: _orange, width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}