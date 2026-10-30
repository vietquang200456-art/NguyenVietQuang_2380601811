import 'package:flutter/material.dart';
import 'controllers/auth_controller.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ChildDevicesApp());
}

class ChildDevicesApp extends StatefulWidget {
  const ChildDevicesApp({super.key});

  @override
  State<ChildDevicesApp> createState() => _ChildDevicesAppState();
}

class _ChildDevicesAppState extends State<ChildDevicesApp> {
  late final AuthController _authController;
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    _authController = AuthController();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final storage = StorageService();

    try {
      if (await storage.isLoggedIn()) {
        _authController.currentUser = await _authController.authService.getCurrentUser();
      }
    } catch (_) {
      await _authController.logout();
    } finally {
      if (mounted) {
        setState(() => _checkingSession = false);
      }
    }
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Child Devices',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1769FF)),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF5F7FA),
        ),
      ),
      home: _checkingSession
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _authController.isLoggedIn
              ? HomeScreen(authController: _authController)
              : LoginScreen(authController: _authController),
    );
  }
}
