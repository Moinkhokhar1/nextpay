import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/wallet.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../services/storage_service.dart';

/// Mirrors offline/walletEngine.js
class WalletEngine {
  final AuthProvider authProvider;

  WalletEngine(this.authProvider);

  Future<Map<String, dynamic>> lockBalance(num amount) async {
    try {
      final user = authProvider.user;

      if (user?.wallet == null) {
        return {"success": false, "message": "Wallet not found"};
      }

      final wallet = user!.wallet!;
      final currentBalance = wallet.balance;
      final currentLocked = wallet.lockedBalance;

      if (amount > currentBalance - currentLocked) {
        return {"success": false, "message": "Insufficient balance"};
      }

      final updatedWallet = wallet.copyWith(
        lockedBalance: currentLocked + amount,
      );

      debugPrint("LOCKING AMOUNT: $amount");
      debugPrint("BEFORE LOCK - balance: $currentBalance, locked: $currentLocked");
      debugPrint("AFTER LOCK  - locked: ${updatedWallet.lockedBalance}");

      // Update provider immediately so UI reflects it
      authProvider.setUserWallet(updatedWallet);

      // Persist locally — source of truth for locked_balance
      await StorageService.setItem("local_wallet", jsonEncode(updatedWallet.toJson()));

      // Also update the "user" key so restoreSession picks it up on reload
      final userData = await StorageService.getItem("user");
      if (userData != null) {
        final parsedUser = AppUser.fromJson(Map<String, dynamic>.from(jsonDecode(userData)));
        final updatedUser = parsedUser.copyWith(wallet: updatedWallet);
        await StorageService.setItem("user", jsonEncode(updatedUser.toJson()));
      }

      return {"success": true};
    } catch (error) {
      debugPrint("LOCK BALANCE ERROR: $error");
      return {"success": false};
    }
  }

  Future<Map<String, dynamic>> unlockBalance(num amount) async {
    try {
      final user = authProvider.user;
      if (user?.wallet == null) {
        return {"success": false};
      }

      final wallet = user!.wallet!;
      final updatedLocked = (wallet.lockedBalance - amount) < 0
          ? 0
          : wallet.lockedBalance - amount;

      final updatedWallet = wallet.copyWith(lockedBalance: updatedLocked);

      debugPrint("UNLOCKING AMOUNT: $amount");
      debugPrint("AFTER UNLOCK - locked: $updatedLocked");

      authProvider.setUserWallet(updatedWallet);

      if (updatedLocked == 0) {
        await StorageService.removeItem("local_wallet");
      } else {
        await StorageService.setItem("local_wallet", jsonEncode(updatedWallet.toJson()));
      }

      final userData = await StorageService.getItem("user");
      if (userData != null) {
        final parsedUser = AppUser.fromJson(Map<String, dynamic>.from(jsonDecode(userData)));
        final updatedUser = parsedUser.copyWith(wallet: updatedWallet);
        await StorageService.setItem("user", jsonEncode(updatedUser.toJson()));
      }

      return {"success": true};
    } catch (error) {
      debugPrint("UNLOCK BALANCE ERROR: $error");
      return {"success": false};
    }
  }
}