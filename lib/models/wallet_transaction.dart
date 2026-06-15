/// Represents a server-side wallet transaction record
/// returned by GET /wallet/transactions
class WalletTransaction {
  final String id;
  final String senderId;
  final String receiverId;
  final num amount;
  final bool isOffline;
  final String status;
  final Map<String, dynamic> extra;

  WalletTransaction({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.amount,
    required this.isOffline,
    required this.status,
    this.extra = const {},
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    final copy = Map<String, dynamic>.from(json);
    final id = copy.remove('id');
    final senderId = copy.remove('sender_id');
    final receiverId = copy.remove('receiver_id');
    final amount = copy.remove('amount');
    final isOffline = copy.remove('is_offline');
    final status = copy.remove('status');

    return WalletTransaction(
      id: id.toString(),
      senderId: senderId.toString(),
      receiverId: receiverId.toString(),
      amount: amount is num ? amount : num.parse(amount.toString()),
      isOffline: isOffline == true || isOffline == 1,
      status: (status ?? '').toString(),
      extra: copy,
    );
  }
}