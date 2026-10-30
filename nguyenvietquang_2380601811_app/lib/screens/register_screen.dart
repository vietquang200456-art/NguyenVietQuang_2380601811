import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../controllers/auth_controller.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  final AuthController authController;
  const RegisterScreen({super.key, required this.authController});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _otpVerified = false;
  bool _otpLoading = false;
  bool _googleLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_emailController.text.trim().isEmpty) { _showMessage('Vui lòng nhập email.'); return; }
    setState(() => _otpLoading = true);
    final success = await widget.authController.sendOtp(email: _emailController.text.trim());
    if (!mounted) return;
    setState(() { _otpLoading = false; if (success) { _otpSent = true; _otpVerified = false; _otpController.clear(); } });
    _showMessage(success ? 'Mã OTP đã được gửi.' : widget.authController.errorMessage ?? 'Không thể gửi OTP.');
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) { _showMessage('Mã OTP phải gồm 6 chữ số.'); return; }
    setState(() => _otpLoading = true);
    final success = await widget.authController.verifyOtp(email: _emailController.text.trim(), otp: otp);
    if (!mounted) return;
    setState(() { _otpLoading = false; _otpVerified = success; });
    _showMessage(success ? 'Xác thực OTP thành công.' : widget.authController.errorMessage ?? 'Mã OTP không đúng.');
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false) || !_otpVerified) { _showMessage('Vui lòng xác thực OTP.'); return; }
    final success = await widget.authController.register(email: _emailController.text.trim(), password: _passwordController.text, fullName: _fullNameController.text.trim(), phoneNumber: _phoneController.text.trim(), otp: _otpController.text.trim());
    if (!mounted) return;
    if (success) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomeScreen(authController: widget.authController)), (_) => false); else _showMessage(widget.authController.errorMessage ?? 'Đăng ký thất bại.');
  }

  Future<void> _registerWithGoogle() async {
    setState(() => _googleLoading = true);
    try {
      final account = await GoogleSignIn(scopes: const ['email', 'profile']).signIn();
      if (account == null) return;
      final auth = await account.authentication;
      final success = await widget.authController.registerWithGoogle(idToken: auth.idToken, email: account.email, displayName: account.displayName);
      if (!mounted) return;
      if (success) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomeScreen(authController: widget.authController)), (_) => false); else _showMessage(widget.authController.errorMessage ?? 'Đăng ký Google thất bại.');
    } catch (error) {
      if (mounted) _showMessage('Không thể đăng ký Google: $error');
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  void _showMessage(String message) { ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(message))); }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.authController.isLoading || _otpLoading || _googleLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo tài khoản')),
      body: Form(key: _formKey, child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(children: [
        Text('Đăng ký bằng email hoặc Google', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        OutlinedButton.icon(onPressed: disabled ? null : _registerWithGoogle, icon: _googleLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('G', style: TextStyle(color: Color(0xFF4285F4), fontSize: 22, fontWeight: FontWeight.w800)), label: const Text('Đăng ký bằng Google'), style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(54))),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 20),
        AppTextField(controller: _fullNameController, label: 'Họ và tên', icon: Icons.person),
        const SizedBox(height: 14),
        AppTextField(controller: _emailController, label: 'Email', icon: Icons.email, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 14),
        Row(children: [Expanded(child: AppTextField(controller: _otpController, label: 'Mã OTP', icon: Icons.verified_user, enabled: _otpSent && !_otpVerified, maxLength: 6)), const SizedBox(width: 10), SizedBox(height: 56, child: OutlinedButton(onPressed: disabled ? null : (_otpSent ? _verifyOtp : _sendOtp), child: Text(_otpSent ? 'Xác thực' : 'Gửi OTP')))]),
        if (_otpVerified) const Text('✓ OTP đã xác thực', style: TextStyle(color: Colors.green)),
        const SizedBox(height: 14),
        AppTextField(controller: _phoneController, label: 'Số điện thoại (tùy chọn)', icon: Icons.phone, keyboardType: TextInputType.phone),
        const SizedBox(height: 14),
        AppTextField(controller: _passwordController, label: 'Mật khẩu', icon: Icons.lock, obscureText: _obscurePassword, validator: (v) => v!.length < 6 ? 'Mật khẩu tối thiểu 6 ký tự' : null),
        const SizedBox(height: 24),
        AppButton(text: 'Đăng ký', onPressed: _register, loading: widget.authController.isLoading)
      ])))
    );
  }
}
