import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/wallet.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? user;
  String? token;
  Wallet? localWallet;
  bool loading = false;
  bool hydrated = false;

  Future<Map<String, dynamic>> register(
      String name,
      String email,
      String password,
      String phone,
      ) async {
    try {
      loading = true;
      notifyListeners();

      final response = await ApiService.instance.post(
        "/auth/register",
        data: {"name": name, "email": email, "password": password, "phone": phone},
      );

      final data = response.data;
      final newToken = data["token"] as String;
      final newUser = AppUser.fromJson(Map<String, dynamic>.from(data["user"]));

      await StorageService.setItem("token", newToken);

      token = newToken;
      user = newUser;
      loading = false;
      notifyListeners();

      return {"success": true};
    } catch (error) {
      loading = false;
      notifyListeners();

      String message = "Registration failed";
      if (error is DioException) {
        message = error.response?.data?["message"] ?? message;
      }
      return {"success": false, "message": message};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await ApiService.instance.post(
        "/auth/login",
        data: {"email": email, "password": password},
      );

      final data = response.data;
      final newToken = data["token"] as String;
      final baseUser = AppUser.fromJson(Map<String, dynamic>.from(data["user"]));

      final walletJson = data["wallet"];
      final mergedUser = baseUser.copyWith(
        wallet: walletJson != null
            ? Wallet.fromJson(Map<String, dynamic>.from(walletJson))
            : baseUser.wallet,
      );

      await StorageService.setItem("token", newToken);
      await StorageService.setItem("user", jsonEncode(mergedUser.toJson()));

      token = newToken;
      user = mergedUser;
      notifyListeners();

      return {"success": true};
    } catch (error) {
      debugPrint("LOGIN ERROR: $error");
      return {"success": false};
    }
  }

  Future<void> restoreSession() async {
    try {
      final storedToken = await StorageService.getItem("token");
      final userData = await StorageService.getItem("user");

      if (storedToken != null && userData != null) {
        final parsedUser = AppUser.fromJson(
          Map<String, dynamic>.from(jsonDecode(userData)),
        );

        Wallet? mergedWallet = parsedUser.wallet;

        final localWalletRaw = await StorageService.getItem("local_wallet");
        if (localWalletRaw != null && parsedUser.wallet != null) {
          final localWalletJson = Map<String, dynamic>.from(jsonDecode(localWalletRaw));
          final local = Wallet.fromJson(localWalletJson);
          mergedWallet = parsedUser.wallet!.copyWith(
            lockedBalance: local.lockedBalance,
          );
        }

        token = storedToken;
        user = parsedUser.copyWith(wallet: mergedWallet);
      }
    } catch (error) {
      debugPrint("RESTORE SESSION ERROR: $error");
    } finally {
      hydrated = true;
      notifyListeners();
    }
  }

  Future<void> fetchWallet() async {
    try {
      final response = await ApiService.instance.get("/wallet/");
      final walletFromServer = Wallet.fromJson(
        Map<String, dynamic>.from(response.data),
      );

      // ✅ After sync, local_wallet is removed so lockedBalance = 0
      // Only use local locked balance if local_wallet exists
      final localWalletRaw = await StorageService.getItem("local_wallet");
      num localLockedBalance = walletFromServer.lockedBalance; // default to server value

      if (localWalletRaw != null) {
        final local = Wallet.fromJson(
          Map<String, dynamic>.from(jsonDecode(localWalletRaw)),
        );
        // Only override if local locked is higher (offline txs pending)
        if (local.lockedBalance > walletFromServer.lockedBalance) {
          localLockedBalance = local.lockedBalance;
        }
      }

      final mergedWallet = walletFromServer.copyWith(
        lockedBalance: localLockedBalance,
      );

      if (user != null) {
        user = user!.copyWith(wallet: mergedWallet);
        await StorageService.setItem("user", jsonEncode(user!.toJson()));
        notifyListeners();
      }
    } catch (error) {
      debugPrint("FETCH WALLET ERROR: $error");
    }
  }

  Future<void> refreshLocalWallet() async {
    try {
      final localWalletRaw = await StorageService.getItem("local_wallet");
      if (localWalletRaw != null) {
        localWallet = Wallet.fromJson(
          Map<String, dynamic>.from(jsonDecode(localWalletRaw)),
        );
        notifyListeners();
      }
    } catch (error) {
      debugPrint("REFRESH LOCAL WALLET ERROR: $error");
    }
  }

  void setUserWallet(Wallet updatedWallet) {
    if (user == null) return;
    user = user!.copyWith(wallet: updatedWallet);
    notifyListeners();
  }

  Future<void> logout() async {
    await StorageService.removeItem("token");
    await StorageService.removeItem("user");
    await StorageService.removeItem("local_wallet");

    user = null;
    token = null;
    hydrated = false;
    notifyListeners();
  }
}