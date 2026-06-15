class Wallet {
  final num balance;
  final num lockedBalance;
  final Map<String, dynamic> extra;

  Wallet({
    required this.balance,
    this.lockedBalance = 0,
    this.extra = const {},
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    final copy = Map<String, dynamic>.from(json);
    final balance = copy.remove('balance') ?? 0;
    final locked = copy.remove('locked_balance') ?? 0;
    return Wallet(
      balance: balance as num,
      lockedBalance: locked as num,
      extra: copy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...extra,
      'balance': balance,
      'locked_balance': lockedBalance,
    };
  }

  Wallet copyWith({num? balance, num? lockedBalance}) {
    return Wallet(
      balance: balance ?? this.balance,
      lockedBalance: lockedBalance ?? this.lockedBalance,
      extra: extra,
    );
  }
}