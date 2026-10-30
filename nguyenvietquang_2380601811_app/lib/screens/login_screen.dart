import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../controllers/auth_controller.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final AuthController authController;
  const LoginScreen({super.key, required this.authController});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final success = await widget.authController.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (success) {
      _openHome();
    } else {
      _showMessage(widget.authController.errorMessage ?? 'Đăng nhập thất bại.');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isGoogleLoading || widget.authController.isLoading) return;
    setState(() => _isGoogleLoading = true);

    try {
      final account = await GoogleSignIn(scopes: const ['email', 'profile']).signIn();
      if (account == null) return;

      final authentication = await account.authentication;
      final success = await widget.authController.loginWithGoogle(
        idToken: authentication.idToken,
        accessToken: authentication.accessToken,
        email: account.email,
        displayName: account.displayName,
      );

      if (!mounted) return;
      if (success) {
        _openHome();
      } else {
        _showMessage(widget.authController.errorMessage ?? 'Đăng nhập Google thất bại.');
      }
    } catch (error) {
      if (mounted) _showMessage('Không thể đăng nhập Google: $error');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  void _openHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(authController: widget.authController)),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Vui lòng nhập email.';
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
        ? null
        : 'Email không đúng định dạng.';
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu.';
    if (value.length < 6) return 'Mật khẩu cần ít nhất 6 ký tự.';
    return null;
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF7F8FC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final loading = widget.authController.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(Icons.shield_rounded, color: Colors.white, size: 38),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Chào mừng trở lại',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    const Text('Đăng nhập để quản lý thiết bị an toàn cho gia đình.'),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _validateEmail,
                      decoration: _fieldDecoration(label: 'Email', icon: Icons.email_outlined),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleLogin(),
                      validator: _validatePassword,
                      decoration: _fieldDecoration(
                        label: 'Mật khẩu',
                        icon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _showMessage('Tính năng khôi phục mật khẩu sẽ được bổ sung sau.'),
                        child: const Text('Quên mật khẩu?'),
                      ),
                    ),
                    FilledButton(
                      onPressed: loading ? null : _handleLogin,
                      child: loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white)) : const Text('Đăng nhập'),
                    ),
                    const SizedBox(height: 24),
                    const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Hoặc tiếp tục với')), Expanded(child: Divider())]),
                    const SizedBox(height: 18),
                    OutlinedButton.icon(
                      onPressed: (_isGoogleLoading || loading) ? null : _handleGoogleSignIn,
                      icon: _isGoogleLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const _GoogleMark(),
                      label: const Text('Đăng nhập bằng Google / Gmail'),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Chưa có tài khoản?'),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen(authController: widget.authController))),
                          child: const Text('Đăng ký ngay'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();
  @override
  Widget build(BuildContext context) => const Text('G', style: TextStyle(color: Color(0xFF4285F4), fontSize: 22, fontWeight: FontWeight.w800));
}