import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService authService;
  AuthController({AuthService? authService}) : authService = authService ?? AuthService();
  User? currentUser;
  bool isLoading = false;
  String? errorMessage;
  bool get isLoggedIn => currentUser != null;
  bool get isAdmin => currentUser?.isAdmin ?? false;

  Future<bool> login({required String email, required String password}) => _run(() async {
    currentUser = await authService.login(email: email, password: password);
  });

  Future<bool> loginWithGoogle({String? idToken, String? accessToken, required String email, String? displayName}) => _run(() async {
    currentUser = await authService.loginWithGoogle(idToken: idToken, accessToken: accessToken, email: email, displayName: displayName);
  });

  Future<bool> registerWithGoogle({String? idToken, required String email, String? displayName}) => _run(() async {
    currentUser = await authService.loginWithGoogle(idToken: idToken, email: email, displayName: displayName);
  });

  Future<bool> register({required String email, required String password, required String fullName, String? phoneNumber, required String otp}) => _run(() async {
    currentUser = await authService.register(email: email, password: password, fullName: fullName, phoneNumber: phoneNumber, otp: otp);
  });

  Future<bool> sendOtp({required String email}) => _run(() => authService.sendOtp(email: email));
  Future<bool> verifyOtp({required String email, required String otp}) => _run(() => authService.verifyOtp(email: email, otp: otp));

  Future<bool> updateProfile({required String fullName, required String email, required String phoneNumber}) => _run(() async {
    currentUser = await authService.updateProfile(fullName: fullName, email: email, phoneNumber: phoneNumber);
  });

  Future<bool> _run(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await authService.logout();
    currentUser = null;
    notifyListeners();
  }
}

