import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'services/api_service.dart';
import 'offline/wallet_engine.dart';
import 'offline/sync_engine.dart';
import 'offline/network_monitor.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  ApiService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..restoreSession(),
      child: MaterialApp(
        title: 'Offline Payment',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          useMaterial3: true,
        ),
        home: const AppRoot(),
      ),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  NetworkMonitor? _networkMonitor;
  bool _monitorStarted = false;

  @override
  void dispose() {
    _networkMonitor?.stop();
    super.dispose();
  }

  void _startMonitorIfNeeded() {
    if (_monitorStarted) return;
    final auth = context.read<AuthProvider>();
    if (!auth.hydrated || auth.user == null) return;

    _monitorStarted = true;
    final walletEngine = WalletEngine(auth);
    final syncEngine = SyncEngine(auth, walletEngine);
    _networkMonitor = NetworkMonitor(syncEngine);
    _networkMonitor!.start(auth.fetchWallet);
    debugPrint("NETWORK MONITOR INITIALIZED");
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.hydrated) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // // Start network monitoring once, after hydration
    // if (!_monitorStarted) {
    //   _monitorStarted = true;
    //   final walletEngine = WalletEngine(auth);
    //   final syncEngine = SyncEngine(auth, walletEngine);
    //   _networkMonitor = NetworkMonitor(syncEngine);
    //   _networkMonitor!.start(auth.fetchWallet);
    // }

    if (auth.user != null && auth.token != null) {
      _startMonitorIfNeeded();
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}