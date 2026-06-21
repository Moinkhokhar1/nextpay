// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:math';
// import 'package:provider/provider.dart';
// import '../providers/auth_provider.dart';
// import '../services/api_service.dart';
// import 'scanner_screen.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:dio/dio.dart';
// import '../offline/transaction_engine.dart';
// import '../offline/wallet_engine.dart';
// import '../sms_payment/sms_payment_service.dart';
// import 'package:audioplayers/audioplayers.dart';
//
//
// // ─── Success Modal ────────────────────────────────────────────────────────────
// class SuccessModal extends StatefulWidget {
//   final bool visible;
//   final String amount;
//   final String successReceiver;
//   final String transactionId; // 👈 added
//   final String mode;          // 👈 added
//   final String timestamp;
//   final VoidCallback onDone;
//
//   const SuccessModal({
//     Key? key,
//     required this.visible,
//     required this.amount,
//     required this.successReceiver,
//     required this.transactionId, // 👈
//     required this.mode,          // 👈
//     required this.timestamp,
//     required this.onDone,
//   }) : super(key: key);
//
//   @override
//   State<SuccessModal> createState() => _SuccessModalState();
// }
//
// class _SuccessModalState extends State<SuccessModal>
//     with TickerProviderStateMixin {
//   late AnimationController _scaleController;
//   late AnimationController _checkController;
//   late AnimationController _amountController;
//   late AnimationController _subtitleController;
//   late AnimationController _rippleController;
//   late AnimationController _particleController;
//
//   late Animation<double> _checkAnim;
//   late Animation<double> _amountAnim;
//   late Animation<double> _subtitleAnim;
//   late Animation<double> _particleAnim;
//
//   final AudioPlayer _player = AudioPlayer();
//
//   final List<Color> particleColors = const [
//     Color(0xFF1E6B37),
//     Color(0xFFC85A1E),
//     Color(0xFFF3EBDD),
//     Color(0xFF1A0A00),
//     Color(0xFF9A7A5A),
//     Color(0xFF1E6B37),
//     Color(0xFFC85A1E),
//     Colors.white,
//   ];
//
//   final List<double> particleAngles = [0, 45, 90, 135, 180, 225, 270, 315];
//
//   @override
//   void initState() {
//     super.initState();
//
//     _scaleController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );
//     _checkController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _amountController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );
//     _subtitleController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );
//     _rippleController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     )..repeat();
//     _particleController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );
//
//     _checkAnim = CurvedAnimation(
//       parent: _checkController,
//       curve: Curves.easeOut,
//     );
//     _amountAnim = CurvedAnimation(
//       parent: _amountController,
//       curve: Curves.elasticOut,
//     );
//     _subtitleAnim = CurvedAnimation(
//       parent: _subtitleController,
//       curve: Curves.easeIn,
//     );
//     _particleAnim = CurvedAnimation(
//       parent: _particleController,
//       curve: Curves.easeOut,
//     );
//
//     if (widget.visible) _startAnimations();
//   }
//
//   void _startAnimations() {
//     HapticFeedback.heavyImpact();
//     _player.play(AssetSource('sounds/success.mp3'));
//     Future.delayed(const Duration(milliseconds: 300), () {
//       if (mounted) HapticFeedback.mediumImpact();
//     });
//     _scaleController.forward();
//     Future.delayed(const Duration(milliseconds: 200), () {
//       if (mounted) _checkController.forward();
//     });
//     Future.delayed(const Duration(milliseconds: 300), () {
//       if (mounted) _particleController.forward();
//     });
//     Future.delayed(const Duration(milliseconds: 500), () {
//       if (mounted) _amountController.forward();
//     });
//     Future.delayed(const Duration(milliseconds: 700), () {
//       if (mounted) _subtitleController.forward();
//     });
//   }
//
//   void _resetAnimations() {
//     _scaleController.reset();
//     _checkController.reset();
//     _amountController.reset();
//     _subtitleController.reset();
//     _particleController.reset();
//   }
//
//   @override
//   void didUpdateWidget(SuccessModal oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.visible && !oldWidget.visible) {
//       _resetAnimations();
//       _startAnimations();
//     } else if (!widget.visible && oldWidget.visible) {
//       _resetAnimations();
//     }
//   }
//
//   @override
//   void dispose() {
//     _player.dispose();
//     _scaleController.dispose();
//     _checkController.dispose();
//     _amountController.dispose();
//     _subtitleController.dispose();
//     _rippleController.dispose();
//     _particleController.dispose();
//     super.dispose();
//   }
//
//   Widget _detailRow(String label, String value) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 10,
//             fontWeight: FontWeight.w800,
//             color: Color(0xFF9A7A5A),
//             letterSpacing: 1.5,
//           ),
//         ),
//         Flexible(
//           child: Text(
//             value,
//             textAlign: TextAlign.right,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w700,
//               color: Color(0xFF1A0A00),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (!widget.visible) return const SizedBox.shrink();
//
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       child: ScaleTransition(
//         scale: _scaleController,
//         child: Container(
//           padding: const EdgeInsets.all(32),
//           decoration: BoxDecoration(
//             color: const Color(0xFFF3EBDD),
//             border: Border.all(color: const Color(0xFF111111), width: 3),
//             boxShadow: const [
//               BoxShadow(
//                   color: Colors.black, offset: Offset(8, 8), blurRadius: 0),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               SizedBox(
//                 width: 120,
//                 height: 120,
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     ...List.generate(3, (i) {
//                       return AnimatedBuilder(
//                         animation: _rippleController,
//                         builder: (_, __) {
//                           final offset = i * 0.33;
//                           final value =
//                               (_rippleController.value + offset) % 1.0;
//                           final opacity = value < 0.3
//                               ? value / 0.3 * 0.4
//                               : (1 - value) / 0.7 * 0.4;
//                           return Transform.scale(
//                             scale: 0.6 + value * 1.6,
//                             child: Opacity(
//                               opacity: opacity.clamp(0.0, 1.0),
//                               child: Container(
//                                 width: 100,
//                                 height: 100,
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   border: Border.all(
//                                     color: const Color(0xFF1E6B37),
//                                     width: 3,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     }),
//                     ...List.generate(8, (i) {
//                       final angle = particleAngles[i] * pi / 180;
//                       const distance = 65.0;
//                       return AnimatedBuilder(
//                         animation: _particleAnim,
//                         builder: (_, __) {
//                           final v = _particleAnim.value;
//                           return Transform.translate(
//                             offset: Offset(
//                               cos(angle) * distance * v,
//                               sin(angle) * distance * v,
//                             ),
//                             child: Opacity(
//                               opacity: v < 0.5 ? v * 2 : (1 - v) * 2,
//                               child: Container(
//                                 width: 10,
//                                 height: 10,
//                                 decoration: BoxDecoration(
//                                   color: particleColors[i],
//                                   borderRadius: BorderRadius.circular(2),
//                                   border: Border.all(
//                                     color: const Color(0xFF111111),
//                                     width: 1.5,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     }),
//                     ScaleTransition(
//                       scale: _checkAnim,
//                       child: Container(
//                         width: 90,
//                         height: 90,
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF1E6B37),
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             color: const Color(0xFF111111),
//                             width: 3,
//                           ),
//                           boxShadow: const [
//                             BoxShadow(
//                               color: Colors.black,
//                               offset: Offset(4, 4),
//                               blurRadius: 0,
//                             ),
//                           ],
//                         ),
//                         child: const Center(
//                           child: Text(
//                             '✓',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 44,
//                               fontWeight: FontWeight.w900,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 8),
//               SlideTransition(
//                 position: Tween<Offset>(
//                   begin: const Offset(0, 0.5),
//                   end: Offset.zero,
//                 ).animate(_amountController),
//                 child: FadeTransition(
//                   opacity: _amountController,
//                   child: Text(
//                     '₹${widget.amount}',
//                     style: const TextStyle(
//                       fontSize: 38,
//                       fontWeight: FontWeight.w900,
//                       color: Color(0xFF1A0A00),
//                       letterSpacing: 1,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 6),
//               FadeTransition(
//                 opacity: _subtitleAnim,
//                 child: Column(
//                   children: [
//                     const Text(
//                       'PAYMENT SUCCESSFUL',
//                       style: TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w900,
//                         color: Color(0xFF1E6B37),
//                         letterSpacing: 2.5,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       'To: ${widget.successReceiver}',
//                       style: const TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF9A7A5A),
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                     const SizedBox(height: 14), // 👈 new block starts here
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFF3EBDD),
//                         border: Border.all(color: const Color(0xFF111111), width: 2),
//                       ),
//                       child: Column(
//                         children: [
//                           _detailRow('TIME', widget.timestamp),
//                           const SizedBox(height: 8),
//                           _detailRow('TXN ID', widget.transactionId),
//                           const SizedBox(height: 8),
//                           _detailRow('MODE', widget.mode.toUpperCase()),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 28),
//               FadeTransition(
//                 opacity: _subtitleAnim,
//                 child: GestureDetector(
//                   onTap: widget.onDone,
//                   child: Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFC85A1E),
//                       border:
//                       Border.all(color: const Color(0xFF111111), width: 3),
//                       boxShadow: const [
//                         BoxShadow(
//                             color: Colors.black,
//                             offset: Offset(4, 4),
//                             blurRadius: 0),
//                       ],
//                     ),
//                     child: const Center(
//                       child: Text(
//                         'DONE',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w900,
//                           letterSpacing: 3,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Send Screen ──────────────────────────────────────────────────────────────
// class SendScreen extends StatefulWidget {
//   final String? receiverId;
//   final String? receiverName;
//   final String? scannedReceiverId;
//   final String? scannedAmount;
//
//   const SendScreen({
//     super.key,
//     this.receiverId,
//     this.receiverName,
//     this.scannedReceiverId,
//     this.scannedAmount,
//   });
//
//   @override
//   State<SendScreen> createState() => _SendScreenState();
// }
//
// class _SendScreenState extends State<SendScreen> {
//   final TextEditingController _receiverController = TextEditingController();
//   final TextEditingController _amountController = TextEditingController();
//
//   String _formatTime(DateTime dt) {
//     final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
//     final minute = dt.minute.toString().padLeft(2, '0');
//     final period = dt.hour >= 12 ? 'PM' : 'AM';
//     return '$hour:$minute $period';
//   }
//
//   bool _showSuccess = false;
//   String _successAmount = '';
//   String _successReceiver = '';
//   String? _confirmationQR;
//   String _successTxnId = '';
//   String _successMode = '';
//   DateTime? _successTimestamp;
//
//   double _balance = 0.0;
//   double _lockedBalance = 0.0;
//   bool _balanceLoading = true;
//
//   double get availableBalance => _balance - _lockedBalance;
//
//   // ── Helper: safe setState (guards against unmounted calls) ──────
//   void _safeSetState(VoidCallback fn) {
//     if (mounted) setState(fn);
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _loadWallet();
//
//     if (widget.receiverId != null) {
//       _receiverController.text = widget.receiverId!;
//     } else if (widget.scannedReceiverId != null) {
//       _receiverController.text = widget.scannedReceiverId!;
//     }
//     if (widget.scannedAmount != null) {
//       _amountController.text = widget.scannedAmount!;
//     }
//   }
//
//   @override
//   void dispose() {
//     _receiverController.dispose();
//     _amountController.dispose();
//     super.dispose();
//   }
//
//   // ── Fetch wallet — handles disconnect gracefully ────────────────
//   Future<void> _loadWallet() async {
//     // Read auth BEFORE the async gap
//     final auth = context.read<AuthProvider>();
//
//     try {
//       final response = await ApiService.instance.get("/wallet/");
//       _safeSetState(() {
//         _balance =
//             double.tryParse(response.data['balance']?.toString() ?? '0') ??
//                 0.0;
//         _lockedBalance = double.tryParse(
//             response.data['locked_balance']?.toString() ?? '0') ??
//             0.0;
//         _balanceLoading = false;
//       });
//     } on DioException catch (e) {
//       // Covers: connectionError, connectionTimeout, receiveTimeout, cancel
//       debugPrint("WALLET LOAD OFFLINE (DioException: ${e.type}): $e");
//       final wallet = auth.user?.wallet;
//       _safeSetState(() {
//         _balance = (wallet?.balance ?? 0).toDouble();
//         _lockedBalance = (wallet?.lockedBalance ?? 0).toDouble();
//         _balanceLoading = false;
//       });
//     } catch (e) {
//       // Any other unexpected error — still don't crash
//       debugPrint("WALLET LOAD ERROR (unexpected): $e");
//       final wallet = auth.user?.wallet;
//       _safeSetState(() {
//         _balance = (wallet?.balance ?? 0).toDouble();
//         _lockedBalance = (wallet?.lockedBalance ?? 0).toDouble();
//         _balanceLoading = false;
//       });
//     }
//   }
//
//   // ── Send handler ────────────────────────────────────────────────
//   Future<void> _handleSend() async {
//     final receiverId = _receiverController.text.trim();
//     final amountText = _amountController.text.trim();
//
//     if (receiverId.isEmpty || amountText.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('All fields required')),
//       );
//       return;
//     }
//
//     final numericAmount = double.tryParse(amountText);
//     if (numericAmount == null || numericAmount <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Invalid amount')),
//       );
//       return;
//     }
//
//     if (numericAmount > availableBalance) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Insufficient balance')),
//       );
//       return;
//     }
//
//     // Read auth BEFORE async gap
//     final auth = context.read<AuthProvider>();
//
//     // Check connectivity
//     final connectivity = await Connectivity().checkConnectivity();
//     final isOnline = connectivity.any((r) => r != ConnectivityResult.none);
//
//     if (isOnline) {
//       // ── ONLINE ──────────────────────────────────────────────────
//       try {
//         final response =
//         await ApiService.instance.post("/wallet/transfer", data: {
//           "receiverId": receiverId,
//           "amount": numericAmount,
//         });
//
//         if (response.data['success'] == true) {
//           // ── NEW: Send confirmation SMS ─────────────────────────────
//           final smsResult = await SmsPaymentService.instance.sendPayment(
//             senderId: auth.user?.wallet?.extra['user_id']?.toString() ??
//                 auth.user?.id ??
//                 '',
//             receiverId: receiverId,
//             amount: numericAmount,
//           );
//           if (!smsResult.success) {
//             debugPrint('SMS SEND FAILED (online): ${smsResult.message}');
//           } else {
//             debugPrint('SMS SENT (online): ${smsResult.payload}');
//           }
//           // ──────────────────────────────────────────────────────────
//
//           _safeSetState(() {
//             _successAmount = numericAmount.toStringAsFixed(2);
//             _successReceiver = response.data['receiverName'] ?? receiverId;
//             _successTxnId = response.data['transactionId']?.toString() ?? '-'; // 👈 confirmed correct now
//             _successMode = 'Online';
//             _successTimestamp = response.data['createdAt'] != null
//                 ? DateTime.parse(response.data['createdAt']).toLocal() // 👈 use server timestamp, not local clock
//                 : DateTime.now();
//             _showSuccess = true;
//           });
//           await auth.fetchWallet();
//           await _loadWallet();
//         }else {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                   content: Text(
//                       response.data['message'] ?? 'Transfer failed')),
//             );
//           }
//         }
//       } on DioException catch (e) {
//         debugPrint("ONLINE SEND DioException (${e.type}): $e");
//         // Internet dropped mid-request — fall through to offline path
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text(
//                   'Connection lost. Saving as offline transaction...'),
//             ),
//           );
//         }
//         await _doOfflineSend(auth, receiverId, numericAmount);
//       } catch (e) {
//         debugPrint("ONLINE SEND ERROR (unexpected): $e");
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Transfer failed. Try again.')),
//           );
//         }
//       }
//     } else {
//       // ── OFFLINE ─────────────────────────────────────────────────
//       await _doOfflineSend(auth, receiverId, numericAmount);
//     }
//   }
//
//   // ── Extracted offline logic (reused by both paths) ─────────────
//   Future<void> _doOfflineSend(
//       AuthProvider auth,
//       String receiverId,
//       double numericAmount,
//       ) async {
//     try {
//       final walletEngine = WalletEngine(auth);
//       final txEngine = TransactionEngine(auth, walletEngine);
//
//       final senderId = auth.user?.wallet?.extra['user_id']?.toString() ??
//           auth.user?.id ??
//           '';
//
//       if (senderId.isEmpty) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//                 content: Text('User not found. Please login again.')),
//           );
//         }
//         return;
//       }
//
//       final result = await txEngine.createOfflineTransaction(
//         senderId: senderId,
//         receiverId: receiverId,
//         amount: numericAmount,
//         senderName: auth.user?.name,
//       );
//
//       if (result['success'] == true) {
//         await _loadWallet();
//         _safeSetState(() {
//           _successAmount = numericAmount.toStringAsFixed(2);
//           _successReceiver = receiverId;
//           _successTxnId = result['transactionId']?.toString() ??
//               result['id']?.toString() ?? '-'; // 👈 adjust key name to match your txEngine result
//           _successMode = 'Offline';
//           _successTimestamp = DateTime.now();
//           _showSuccess = true;
//         });
//       } else {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text(
//                     result['message'] ?? 'Offline transaction failed')),
//           );
//         }
//       }
//     } catch (e) {
//       debugPrint("OFFLINE SEND ERROR: $e");
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Something went wrong')),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF3EBDD),
//       resizeToAvoidBottomInset: true,
//         body: GestureDetector(
//           behavior: HitTestBehavior.opaque,
//           onTap: () => FocusScope.of(context).unfocus(),
//       child: Stack(
//         children: [
//           Column(
//             children: [
//               // ── Header ────────────────────────────────────────────
//               Container(
//                 color: const Color(0xFF1A0A00),
//                 padding: EdgeInsets.only(
//                   top: MediaQuery.of(context).padding.top + 16,
//                   bottom: 20,
//                   left: 20,
//                   right: 20,
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     GestureDetector(
//                       onTap: () => Navigator.pop(context),
//                       child: Container(
//                         width: 42,
//                         height: 42,
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.08),
//                           borderRadius: BorderRadius.circular(4),
//                           border: Border.all(
//                             color: Colors.white.withOpacity(0.15),
//                             width: 2,
//                           ),
//                         ),
//                         child: const Center(
//                           child: Text(
//                             '←',
//                             style: TextStyle(
//                               color: Color(0xFFF3EBDD),
//                               fontSize: 20,
//                               fontWeight: FontWeight.w900,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Text(
//                           'TRANSFER',
//                           style: TextStyle(
//                             color: Color(0xFF9A7A5A),
//                             fontSize: 10,
//                             fontWeight: FontWeight.w800,
//                             letterSpacing: 2,
//                           ),
//                         ),
//                         Text(
//                           'Send Money',
//                           style: TextStyle(
//                             color: Color(0xFFF3EBDD),
//                             fontSize: 22,
//                             fontWeight: FontWeight.w900,
//                             letterSpacing: 0.5,
//                           ),
//                         ),
//                       ],
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => const ScannerScreen(),
//                           ),
//                         );
//                       },
//                       child: Container(
//                         width: 42,
//                         height: 42,
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.08),
//                           borderRadius: BorderRadius.circular(4),
//                           border: Border.all(
//                             color: Colors.white.withOpacity(0.15),
//                             width: 2,
//                           ),
//                         ),
//                         child: const Center(
//                           child: Icon(
//                             Icons.qr_code_scanner,
//                             color: Colors.white,
//                             size: 20,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // ── Scrollable Content ─────────────────────────────────
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       // Balance pill
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 14,
//                           horizontal: 20,
//                         ),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF1E6B37),
//                           border: Border.all(
//                             color: const Color(0xFF111111),
//                             width: 3,
//                           ),
//                           boxShadow: const [
//                             BoxShadow(
//                               color: Colors.black,
//                               offset: Offset(4, 4),
//                               blurRadius: 0,
//                             ),
//                           ],
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text(
//                               'AVAILABLE',
//                               style: TextStyle(
//                                 color: Colors.white70,
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w800,
//                                 letterSpacing: 2,
//                               ),
//                             ),
//                             _balanceLoading
//                                 ? const SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                                 strokeWidth: 2,
//                               ),
//                             )
//                                 : Text(
//                               '₹${availableBalance.toStringAsFixed(2)}',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.w900,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       const SizedBox(height: 20),
//
//                       // Form card
//                       Container(
//                         padding: const EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFEFE4D1),
//                           border: Border.all(
//                             color: const Color(0xFF111111),
//                             width: 3,
//                           ),
//                           boxShadow: const [
//                             BoxShadow(
//                               color: Colors.black,
//                               offset: Offset(5, 5),
//                               blurRadius: 0,
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'RECEIVER ID',
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w900,
//                                 color: Color(0xFF9A7A5A),
//                                 letterSpacing: 2,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Container(
//                               decoration: BoxDecoration(
//                                 border: Border.all(
//                                   color: const Color(0xFF111111),
//                                   width: 3,
//                                 ),
//                                 color: const Color(0xFFF3EBDD),
//                               ),
//                               child: Row(
//                                 children: [
//                                   Container(
//                                     width: 48,
//                                     height: 52,
//                                     color: const Color(0xFFC85A1E),
//                                     child: const Center(
//                                       child: Text(
//                                         '@',
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.w900,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Expanded(
//                                     child: TextField(
//                                       controller: _receiverController,
//                                       autocorrect: false,
//                                       style: const TextStyle(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.w700,
//                                         color: Color(0xFF111111),
//                                       ),
//                                       decoration: const InputDecoration(
//                                         hintText: 'Paste wallet user ID',
//                                         hintStyle: TextStyle(
//                                           color: Color(0xFF9A7A5A),
//                                         ),
//                                         border: InputBorder.none,
//                                         contentPadding: EdgeInsets.symmetric(
//                                           horizontal: 14,
//                                           vertical: 14,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//
//                             const SizedBox(height: 20),
//
//                             const Text(
//                               'AMOUNT',
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w900,
//                                 color: Color(0xFF9A7A5A),
//                                 letterSpacing: 2,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Container(
//                               decoration: BoxDecoration(
//                                 border: Border.all(
//                                   color: const Color(0xFF111111),
//                                   width: 3,
//                                 ),
//                                 color: const Color(0xFFF3EBDD),
//                               ),
//                               child: Row(
//                                 children: [
//                                   Container(
//                                     width: 48,
//                                     height: 52,
//                                     color: const Color(0xFFC85A1E),
//                                     child: const Center(
//                                       child: Text(
//                                         '₹',
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.w900,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Expanded(
//                                     child: TextField(
//                                       controller: _amountController,
//                                       keyboardType: TextInputType.phone,
//                                       style: const TextStyle(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.w700,
//                                         color: Color(0xFF111111),
//                                       ),
//                                       decoration: const InputDecoration(
//                                         hintText: '0.00',
//                                         hintStyle: TextStyle(
//                                           color: Color(0xFF9A7A5A),
//                                         ),
//                                         border: InputBorder.none,
//                                         contentPadding: EdgeInsets.symmetric(
//                                           horizontal: 14,
//                                           vertical: 14,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//
//                             const SizedBox(height: 16),
//
//                             Row(
//                               children: [50, 100, 200, 500].map((val) {
//                                 return Expanded(
//                                   child: Padding(
//                                     padding: const EdgeInsets.only(right: 8),
//                                     child: GestureDetector(
//                                       onTap: () {
//                                         _amountController.text =
//                                             val.toString();
//                                       },
//                                       child: Container(
//                                         padding: const EdgeInsets.symmetric(
//                                           vertical: 10,
//                                         ),
//                                         decoration: BoxDecoration(
//                                           color: const Color(0xFFF3EBDD),
//                                           border: Border.all(
//                                             color: const Color(0xFF111111),
//                                             width: 2,
//                                           ),
//                                         ),
//                                         child: Center(
//                                           child: Text(
//                                             '+₹$val',
//                                             style: const TextStyle(
//                                               fontSize: 12,
//                                               fontWeight: FontWeight.w800,
//                                               color: Color(0xFFC85A1E),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       const SizedBox(height: 16),
//
//                       Container(
//                         padding: const EdgeInsets.all(14),
//                         decoration: const BoxDecoration(
//                           color: Color(0xFFEFE4D1),
//                           border: Border(
//                             top: BorderSide(
//                                 color: Color(0xFFC85A1E), width: 2),
//                             right: BorderSide(
//                                 color: Color(0xFFC85A1E), width: 2),
//                             bottom: BorderSide(
//                                 color: Color(0xFFC85A1E), width: 2),
//                             left: BorderSide(
//                                 color: Color(0xFFC85A1E), width: 5),
//                           ),
//                         ),
//                         child: const Text(
//                           '💡 If you\'re offline, the transaction will be saved locally and synced when internet is restored.',
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFF5A3A00),
//                             height: 1.5,
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(height: 20),
//
//                       GestureDetector(
//                         onTap: _handleSend,
//                         child: Container(
//                           height: 64,
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFC85A1E),
//                             border: Border.all(
//                               color: const Color(0xFF111111),
//                               width: 3,
//                             ),
//                             boxShadow: const [
//                               BoxShadow(
//                                 color: Colors.black,
//                                 offset: Offset(6, 6),
//                                 blurRadius: 0,
//                               ),
//                             ],
//                           ),
//                           child: const Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 'SEND MONEY',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w900,
//                                   letterSpacing: 2,
//                                 ),
//                               ),
//                               SizedBox(width: 12),
//                               Text(
//                                 '→',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.w900,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(height: 40),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//
//           // ── Success Modal ────────────────────────────────────────
//           if (_showSuccess)
//             Container(
//               color: Colors.black.withOpacity(0.8),
//               child: Center(
//                 child: SuccessModal(
//                   visible: _showSuccess,
//                   amount: _successAmount,
//                   successReceiver: _successReceiver,
//                   transactionId: _successTxnId, // 👈
//                   mode: _successMode,           // 👈
//                   timestamp: _successTimestamp != null
//                       ? _formatTime(_successTimestamp!)
//                       : '-', // 👈
//                   onDone: () {
//                     setState(() => _showSuccess = false);
//                     Navigator.pop(context);
//                   },
//                 ),
//               ),
//             ),
//
//           // ── Offline QR Modal ─────────────────────────────────────
//           if (_confirmationQR != null)
//             Container(
//               color: Colors.black.withOpacity(0.75),
//               child: Center(
//                 child: Container(
//                   width: MediaQuery.of(context).size.width * 0.85,
//                   padding: const EdgeInsets.all(28),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF3EBDD),
//                     border: Border.all(
//                       color: const Color(0xFF111111),
//                       width: 3,
//                     ),
//                     boxShadow: const [
//                       BoxShadow(
//                         color: Colors.black,
//                         offset: Offset(6, 6),
//                         blurRadius: 0,
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Text(
//                         'PAYMENT SENT',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.w900,
//                           color: Color(0xFF1A0A00),
//                           letterSpacing: 2,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       const Text(
//                         'Ask vendor to scan this QR',
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF9A7A5A),
//                           letterSpacing: 1,
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       const SizedBox(height: 16),
//                       Text(
//                         '₹${_amountController.text}',
//                         style: const TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.w900,
//                           color: Color(0xFF1E6B37),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       GestureDetector(
//                         onTap: () {
//                           setState(() => _confirmationQR = null);
//                           Navigator.pop(context);
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             vertical: 14,
//                             horizontal: 40,
//                           ),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFC85A1E),
//                             border: Border.all(
//                               color: const Color(0xFF111111),
//                               width: 3,
//                             ),
//                             boxShadow: const [
//                               BoxShadow(
//                                 color: Colors.black,
//                                 offset: Offset(4, 4),
//                                 blurRadius: 0,
//                               ),
//                             ],
//                           ),
//                           child: const Text(
//                             'DONE',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w900,
//                               letterSpacing: 2,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'scanner_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import '../offline/transaction_engine.dart';
import '../offline/wallet_engine.dart';
import '../sms_payment/sms_payment_service.dart';
import 'package:audioplayers/audioplayers.dart';


// ─── Success Modal ────────────────────────────────────────────────────────────
class SuccessModal extends StatefulWidget {
  final bool visible;
  final String amount;
  final String successReceiver;
  final String transactionId;
  final String mode;
  final String timestamp;
  final VoidCallback onDone;

  const SuccessModal({
    Key? key,
    required this.visible,
    required this.amount,
    required this.successReceiver,
    required this.transactionId,
    required this.mode,
    required this.timestamp,
    required this.onDone,
  }) : super(key: key);

  @override
  State<SuccessModal> createState() => _SuccessModalState();
}

class _SuccessModalState extends State<SuccessModal>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late AnimationController _amountController;
  late AnimationController _subtitleController;
  late AnimationController _rippleController;
  late AnimationController _particleController;

  late Animation<double> _checkAnim;
  late Animation<double> _amountAnim;
  late Animation<double> _subtitleAnim;
  late Animation<double> _particleAnim;

  final AudioPlayer _player = AudioPlayer();

  final List<Color> particleColors = const [
    Color(0xFF1E6B37),
    Color(0xFFC85A1E),
    Color(0xFFF3EBDD),
    Color(0xFF1A0A00),
    Color(0xFF9A7A5A),
    Color(0xFF1E6B37),
    Color(0xFFC85A1E),
    Colors.white,
  ];

  final List<double> particleAngles = [0, 45, 90, 135, 180, 225, 270, 315];

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _amountController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _subtitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _checkAnim = CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeOut,
    );
    _amountAnim = CurvedAnimation(
      parent: _amountController,
      curve: Curves.elasticOut,
    );
    _subtitleAnim = CurvedAnimation(
      parent: _subtitleController,
      curve: Curves.easeIn,
    );
    _particleAnim = CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOut,
    );

    if (widget.visible) _startAnimations();
  }

  void _startAnimations() {
    HapticFeedback.heavyImpact();
    _player.play(AssetSource('sounds/success.mp3'));
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) HapticFeedback.mediumImpact();
    });
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _checkController.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _particleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _amountController.forward();
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _subtitleController.forward();
    });
  }

  void _resetAnimations() {
    _scaleController.reset();
    _checkController.reset();
    _amountController.reset();
    _subtitleController.reset();
    _particleController.reset();
  }

  @override
  void didUpdateWidget(SuccessModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) {
      _resetAnimations();
      _startAnimations();
    } else if (!widget.visible && oldWidget.visible) {
      _resetAnimations();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _scaleController.dispose();
    _checkController.dispose();
    _amountController.dispose();
    _subtitleController.dispose();
    _rippleController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  Widget _detailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Color(0xFF9A7A5A),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A0A00),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleController,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFFF3EBDD),
            border: Border.all(color: const Color(0xFF111111), width: 3),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black, offset: Offset(8, 8), blurRadius: 0),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ...List.generate(3, (i) {
                      return AnimatedBuilder(
                        animation: _rippleController,
                        builder: (_, __) {
                          final offset = i * 0.33;
                          final value =
                              (_rippleController.value + offset) % 1.0;
                          final opacity = value < 0.3
                              ? value / 0.3 * 0.4
                              : (1 - value) / 0.7 * 0.4;
                          return Transform.scale(
                            scale: 0.6 + value * 1.6,
                            child: Opacity(
                              opacity: opacity.clamp(0.0, 1.0),
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF1E6B37),
                                    width: 3,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                    ...List.generate(8, (i) {
                      final angle = particleAngles[i] * pi / 180;
                      const distance = 65.0;
                      return AnimatedBuilder(
                        animation: _particleAnim,
                        builder: (_, __) {
                          final v = _particleAnim.value;
                          return Transform.translate(
                            offset: Offset(
                              cos(angle) * distance * v,
                              sin(angle) * distance * v,
                            ),
                            child: Opacity(
                              opacity: v < 0.5 ? v * 2 : (1 - v) * 2,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: particleColors[i],
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: const Color(0xFF111111),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                    ScaleTransition(
                      scale: _checkAnim,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E6B37),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF111111),
                            width: 3,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '✓',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(_amountController),
                child: FadeTransition(
                  opacity: _amountController,
                  child: Text(
                    '₹${widget.amount}',
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A0A00),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              FadeTransition(
                opacity: _subtitleAnim,
                child: Column(
                  children: [
                    const Text(
                      'PAYMENT SUCCESSFUL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E6B37),
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'To: ${widget.successReceiver}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9A7A5A),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3EBDD),
                        border: Border.all(color: const Color(0xFF111111), width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _detailRow('TIME', widget.timestamp),
                          const SizedBox(height: 8),
                          _detailRow('TXN ID', widget.transactionId),
                          const SizedBox(height: 8),
                          _detailRow('MODE', widget.mode.toUpperCase()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _subtitleAnim,
                child: GestureDetector(
                  onTap: widget.onDone,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC85A1E),
                      border:
                      Border.all(color: const Color(0xFF111111), width: 3),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black,
                            offset: Offset(4, 4),
                            blurRadius: 0),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'DONE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
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
}

// ─── Send Screen ──────────────────────────────────────────────────────────────
class SendScreen extends StatefulWidget {
  final String? receiverId;
  final String? receiverName;
  final String? scannedReceiverId;
  final String? scannedAmount;

  const SendScreen({
    super.key,
    this.receiverId,
    this.receiverName,
    this.scannedReceiverId,
    this.scannedAmount,
  });

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  bool _showSuccess = false;
  String _successAmount = '';
  String _successReceiver = '';
  String? _confirmationQR;
  String _successTxnId = '';
  String _successMode = '';
  DateTime? _successTimestamp;

  double _balance = 0.0;
  double _lockedBalance = 0.0;
  bool _balanceLoading = true;

  double get availableBalance => _balance - _lockedBalance;

  // ── Helper: safe setState (guards against unmounted calls) ──────
  void _safeSetState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _loadWallet();

    if (widget.receiverId != null) {
      _receiverController.text = widget.receiverId!;
    } else if (widget.scannedReceiverId != null) {
      _receiverController.text = widget.scannedReceiverId!;
    }
    if (widget.scannedAmount != null) {
      _amountController.text = widget.scannedAmount!;
    }
  }

  @override
  void dispose() {
    _receiverController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // ── Fetch wallet — handles disconnect gracefully ────────────────
  Future<void> _loadWallet() async {
    // Read auth BEFORE the async gap
    final auth = context.read<AuthProvider>();

    try {
      final response = await ApiService.instance.get("/wallet/");
      _safeSetState(() {
        _balance =
            double.tryParse(response.data['balance']?.toString() ?? '0') ??
                0.0;
        _lockedBalance = double.tryParse(
            response.data['locked_balance']?.toString() ?? '0') ??
            0.0;
        _balanceLoading = false;
      });
    } on DioException catch (e) {
      // Covers: connectionError, connectionTimeout, receiveTimeout, cancel
      debugPrint("WALLET LOAD OFFLINE (DioException: ${e.type}): $e");
      final wallet = auth.user?.wallet;
      _safeSetState(() {
        _balance = (wallet?.balance ?? 0).toDouble();
        _lockedBalance = (wallet?.lockedBalance ?? 0).toDouble();
        _balanceLoading = false;
      });
    } catch (e) {
      // Any other unexpected error — still don't crash
      debugPrint("WALLET LOAD ERROR (unexpected): $e");
      final wallet = auth.user?.wallet;
      _safeSetState(() {
        _balance = (wallet?.balance ?? 0).toDouble();
        _lockedBalance = (wallet?.lockedBalance ?? 0).toDouble();
        _balanceLoading = false;
      });
    }
  }

  // ── Send handler ────────────────────────────────────────────────
  Future<void> _handleSend() async {
    final receiverId = _receiverController.text.trim();
    final amountText = _amountController.text.trim();

    if (receiverId.isEmpty || amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields required')),
      );
      return;
    }

    final numericAmount = double.tryParse(amountText);
    if (numericAmount == null || numericAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid amount')),
      );
      return;
    }

    if (numericAmount > availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient balance')),
      );
      return;
    }

    // Read auth BEFORE async gap
    final auth = context.read<AuthProvider>();

    // Check connectivity
    final connectivity = await Connectivity().checkConnectivity();
    final isOnline = connectivity.any((r) => r != ConnectivityResult.none);

    if (isOnline) {
      // ── ONLINE ──────────────────────────────────────────────────
      try {
        final response =
        await ApiService.instance.post("/wallet/transfer", data: {
          "receiverId": receiverId,
          "amount": numericAmount,
        });

        if (response.data['success'] == true) {
          if (mounted) FocusScope.of(context).unfocus();
          // ── Send confirmation SMS ─────────────────────────────
          final smsResult = await SmsPaymentService.instance.sendPayment(
            senderId: auth.user?.wallet?.extra['user_id']?.toString() ??
                auth.user?.id ??
                '',
            receiverId: receiverId,
            amount: numericAmount,
          );
          if (!smsResult.success) {
            debugPrint('SMS SEND FAILED (online): ${smsResult.message}');
          } else {
            debugPrint('SMS SENT (online): ${smsResult.payload}');
          }
          // ──────────────────────────────────────────────────────────

          _safeSetState(() {
            _successAmount = numericAmount.toStringAsFixed(2);
            _successReceiver = response.data['receiverName'] ?? receiverId;
            _successTxnId = response.data['transactionId']?.toString() ?? '-';
            _successMode = 'Online';
            _successTimestamp = response.data['createdAt'] != null
                ? DateTime.parse(response.data['createdAt']).toLocal()
                : DateTime.now();
            _showSuccess = true;
          });
          await auth.fetchWallet();
          await _loadWallet();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      response.data['message'] ?? 'Transfer failed')),
            );
          }
        }
      } on DioException catch (e) {
        debugPrint("ONLINE SEND DioException (${e.type}): $e");
        // Internet dropped mid-request — fall through to offline path
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Connection lost. Saving as offline transaction...'),
            ),
          );
        }
        await _doOfflineSend(auth, receiverId, numericAmount);
      } catch (e) {
        debugPrint("ONLINE SEND ERROR (unexpected): $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transfer failed. Try again.')),
          );
        }
      }
    } else {
      // ── OFFLINE ─────────────────────────────────────────────────
      await _doOfflineSend(auth, receiverId, numericAmount);
    }
  }

  // ── Extracted offline logic (reused by both paths) ─────────────
  Future<void> _doOfflineSend(
      AuthProvider auth,
      String receiverId,
      double numericAmount,
      ) async {
    try {
      final walletEngine = WalletEngine(auth);
      final txEngine = TransactionEngine(auth, walletEngine);

      final senderId = auth.user?.wallet?.extra['user_id']?.toString() ??
          auth.user?.id ??
          '';

      if (senderId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('User not found. Please login again.')),
          );
        }
        return;
      }

      final result = await txEngine.createOfflineTransaction(
        senderId: senderId,
        receiverId: receiverId,
        amount: numericAmount,
        senderName: auth.user?.name,
      );

      if (result['success'] == true) {
        if (mounted) FocusScope.of(context).unfocus();
        await _loadWallet();
        _safeSetState(() {
          _successAmount = numericAmount.toStringAsFixed(2);
          _successReceiver = receiverId;
          _successTxnId = result['transactionId']?.toString() ??
              result['id']?.toString() ?? '-';
          _successMode = 'Offline';
          _successTimestamp = DateTime.now();
          _showSuccess = true;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    result['message'] ?? 'Offline transaction failed')),
          );
        }
      }
    } catch (e) {
      debugPrint("OFFLINE SEND ERROR: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF3EBDD),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Column(
              children: [
                // ── Header ────────────────────────────────────────────
                Container(
                  color: const Color(0xFF1A0A00),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16,
                    bottom: 20,
                    left: 20,
                    right: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              '←',
                              style: TextStyle(
                                color: Color(0xFFF3EBDD),
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'TRANSFER',
                            style: TextStyle(
                              color: Color(0xFF9A7A5A),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            'Send Money',
                            style: TextStyle(
                              color: Color(0xFFF3EBDD),
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ScannerScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.qr_code_scanner,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Scrollable Content (button is NOT in here anymore) ──
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      children: [
                        // Balance pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E6B37),
                            border: Border.all(
                              color: const Color(0xFF111111),
                              width: 3,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(4, 4),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'AVAILABLE',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                ),
                              ),
                              _balanceLoading
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : Text(
                                '₹${availableBalance.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Form card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFE4D1),
                            border: Border.all(
                              color: const Color(0xFF111111),
                              width: 3,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(5, 5),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'RECEIVER ID',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF9A7A5A),
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF111111),
                                    width: 3,
                                  ),
                                  color: const Color(0xFFF3EBDD),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 52,
                                      color: const Color(0xFFC85A1E),
                                      child: const Center(
                                        child: Text(
                                          '@',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: _receiverController,
                                        autocorrect: false,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF111111),
                                        ),
                                        decoration: const InputDecoration(
                                          hintText: 'Paste wallet user ID',
                                          hintStyle: TextStyle(
                                            color: Color(0xFF9A7A5A),
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              const Text(
                                'AMOUNT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF9A7A5A),
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF111111),
                                    width: 3,
                                  ),
                                  color: const Color(0xFFF3EBDD),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 52,
                                      color: const Color(0xFFC85A1E),
                                      child: const Center(
                                        child: Text(
                                          '₹',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: _amountController,
                                        keyboardType: TextInputType.phone,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF111111),
                                        ),
                                        decoration: const InputDecoration(
                                          hintText: '0.00',
                                          hintStyle: TextStyle(
                                            color: Color(0xFF9A7A5A),
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              Row(
                                children: [50, 100, 200, 500].map((val) {
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: GestureDetector(
                                        onTap: () {
                                          _amountController.text =
                                              val.toString();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF3EBDD),
                                            border: Border.all(
                                              color: const Color(0xFF111111),
                                              width: 2,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '+₹$val',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFFC85A1E),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEFE4D1),
                            border: Border(
                              top: BorderSide(
                                  color: Color(0xFFC85A1E), width: 2),
                              right: BorderSide(
                                  color: Color(0xFFC85A1E), width: 2),
                              bottom: BorderSide(
                                  color: Color(0xFFC85A1E), width: 2),
                              left: BorderSide(
                                  color: Color(0xFFC85A1E), width: 5),
                            ),
                          ),
                          child: const Text(
                            '💡 If you\'re offline, the transaction will be saved locally and synced when internet is restored.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5A3A00),
                              height: 1.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),
                        // NOTE: SEND MONEY button intentionally moved out of
                        // this scroll view — see pinned footer below.
                      ],
                    ),
                  ),
                ),

                // ── Pinned footer: SEND MONEY button (always above keyboard) ──
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    keyboardOpen ? 12 : 24,
                  ),
                  child: GestureDetector(
                    onTap: _handleSend,
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC85A1E),
                        border: Border.all(
                          color: const Color(0xFF111111),
                          width: 3,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(6, 6),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'SEND MONEY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            '→',
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
              ],
            ),
            // ── Success Modal ────────────────────────────────────────
            if (_showSuccess)
              MediaQuery(
                data: MediaQuery.of(context).copyWith(viewInsets: EdgeInsets.zero), // 👈 wrap
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  child: Center(
                    child: SuccessModal(
                      visible: _showSuccess,
                      amount: _successAmount,
                      successReceiver: _successReceiver,
                      transactionId: _successTxnId,
                      mode: _successMode,
                      timestamp: _successTimestamp != null
                          ? _formatTime(_successTimestamp!)
                          : '-',
                      onDone: () {
                        setState(() => _showSuccess = false);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ),

            // ── Offline QR Modal ─────────────────────────────────────
            if (_confirmationQR != null)
              Container(
                color: Colors.black.withOpacity(0.75),
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EBDD),
                      border: Border.all(
                        color: const Color(0xFF111111),
                        width: 3,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(6, 6),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'PAYMENT SENT',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1A0A00),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Ask vendor to scan this QR',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9A7A5A),
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const SizedBox(height: 16),
                        Text(
                          '₹${_amountController.text}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E6B37),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            setState(() => _confirmationQR = null);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 40,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC85A1E),
                              border: Border.all(
                                color: const Color(0xFF111111),
                                width: 3,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(4, 4),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: const Text(
                              'DONE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
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
    );
  }
}