import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/otp_section.dart';
import 'realtime_translation_page.dart';
import 'device_management_page.dart';
import 'video_home_page.dart';
import '../services/device_api.dart';

enum AuthMode {
  login,
  register,
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final AuthService authService = AuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  AuthMode mode = AuthMode.login;
  bool otpSent = false;
  bool loading = false;
  bool obscurePassword = true;

  bool get isRegister => mode == AuthMode.register;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
  }

  void showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red.shade700 : const Color(0xFF0B6E69),
      ),
    );
  }

  Future<void> executeRequest(Future<void> Function() request) async {
    if (loading) return;
    setState(() => loading = true);
    try {
      await request();
    } catch (error) {
      if (mounted) {
        showMessage(
          error.toString().replaceFirst('Exception: ', ''),
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> sendOtp() async {
    final email = emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      showMessage('Vui lòng nhập email hợp lệ', error: true);
      return;
    }

    if (!isRegister && passwordController.text.isEmpty) {
      showMessage('Vui lòng nhập mật khẩu trước khi gửi OTP', error: true);
      return;
    }

    await executeRequest(() async {
      if (isRegister) {
        await authService.sendRegisterOtp(email: email);
      } else {
        await authService.sendLoginOtp(
          email: email,
          password: passwordController.text,
        );
      }

      setState(() => otpSent = true);
      showMessage(
        isRegister
            ? 'OTP đăng ký đã được gửi đến email'
            : 'OTP đăng nhập đã được gửi đến email',
      );
    });
  }

  Future<void> verifyOtp() async {
    final email = emailController.text.trim();
    final otp = otpController.text.trim();

    if (email.isEmpty || otp.isEmpty) {
      showMessage('Vui lòng nhập email và mã OTP', error: true);
      return;
    }

    await executeRequest(() async {
      await authService.verifyOtp(email: email, otp: otp);
      showMessage('Mã OTP hợp lệ');
    });
  }

  Future<void> submit() async {
    if (isRegister) {
      await register();
    } else {
      await login();
    }
  }

  Future<void> register() async {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final phone = phoneController.text.trim();
    final otp = otpController.text.trim();

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      showMessage('Vui lòng nhập đầy đủ thông tin đăng ký', error: true);
      return;
    }

    await executeRequest(() async {
      await authService.register(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phone.isEmpty ? null : phone,
        otp: otp.isEmpty ? null : otp,
      );

      if (!mounted) return;

      showMessage('Đăng ký thành công. Vui lòng đăng nhập.');
      setState(() {
        mode = AuthMode.login;
        otpSent = false;
        otpController.clear();
        passwordController.clear();
      });
    });
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final otp = otpController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMessage('Vui lòng nhập email và mật khẩu', error: true);
      return;
    }

    await executeRequest(() async {
      final response = await authService.login(
        email: email,
        password: password,
        otp: otp.isEmpty ? null : otp,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UserHomePage(
            token: response.token,
            userId: response.userId,
            userRole: response.role ?? 'User',
            userName: response.fullName.isEmpty ? email : response.fullName,
          ),
        ),
      );
    });
  }

  void changeMode(AuthMode newMode) {
    setState(() {
      mode = newMode;
      otpSent = false;
      otpController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE9F6F1), Color(0xFFF9F4E8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 470),
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.shield_rounded,
                          size: 44,
                          color: Color(0xFF0B6E69),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          isRegister ? 'Tạo tài khoản' : 'Chào mừng trở lại',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF16312F),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isRegister
                              ? 'Đăng ký để quản lý thiết bị an toàn hơn.'
                              : 'Đăng nhập để tiếp tục.',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        SegmentedButton<AuthMode>(
                          segments: const [
                            ButtonSegment(
                              value: AuthMode.login,
                              label: Text('Đăng nhập'),
                              icon: Icon(Icons.login_rounded),
                            ),
                            ButtonSegment(
                              value: AuthMode.register,
                              label: Text('Đăng ký'),
                              icon: Icon(Icons.person_add_alt_1_rounded),
                            ),
                          ],
                          selected: {mode},
                          onSelectionChanged: (selection) {
                            changeMode(selection.first);
                          },
                        ),
                        const SizedBox(height: 22),
                        if (isRegister) ...[
                          AuthTextField(
                            controller: fullNameController,
                            label: 'Họ và tên',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 12),
                        ],
                        AuthTextField(
                          controller: emailController,
                          label: 'Email',
                          icon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        AuthTextField(
                          controller: passwordController,
                          label: 'Mật khẩu',
                          icon: Icons.lock_outline,
                          obscureText: obscurePassword,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() => obscurePassword = !obscurePassword);
                            },
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        if (isRegister) ...[
                          const SizedBox(height: 12),
                          AuthTextField(
                            controller: phoneController,
                            label: 'Số điện thoại không bắt buộc',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                        const SizedBox(height: 18),
                        OtpSection(
                          controller: otpController,
                          otpSent: otpSent,
                          loading: loading,
                          onSendOtp: sendOtp,
                          onVerifyOtp: verifyOtp,
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton.icon(
                            onPressed: loading ? null : submit,
                            icon: loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    isRegister
                                        ? Icons.rocket_launch_rounded
                                        : Icons.arrow_forward_rounded,
                                  ),
                            label: Text(
                              isRegister ? 'Đăng ký tài khoản' : 'Đăng nhập',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UserHomePage extends StatelessWidget {
  final String token;
  final int? userId;
  final String userRole;
  final String userName;

  const UserHomePage({
    super.key,
    required this.token,
    required this.userId,
    required this.userRole,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Devices'),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthPage()),
                (_) => false,
              );
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Xin chào, $userName',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text('Vai trò: $userRole'),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VideoHomePage(
                      token: token,
                      userId: userId?.toString(),
                      userRole: userRole,
                      userName: userName,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.video_call_rounded),
              label: const Text('Gọi video'),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RealtimeTranslationPage(),
                  ),
                );
              },
              icon: const Icon(Icons.translate_rounded),
              label: const Text('Dịch realtime'),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DeviceManagementPage(
                      api: DeviceApi(
                        token: token,
                        userId: userId?.toString(),
                        userRole: userRole,
                        userName: userName,
                      ),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.devices_other_rounded),
              label: const Text('Quản lý thiết bị'),
            ),
          ],
        ),
      ),
    );
  }
}





