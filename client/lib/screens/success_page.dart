import 'package:flutter/material.dart';

import 'auth_page.dart';

class SuccessPage extends StatelessWidget {
  final String email;
  final String token;

  const SuccessPage({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF0B6E69),
                size: 88,
              ),

              const SizedBox(height: 20),

              const Text(
                'Xác thực thành công',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Tài khoản $email đã đăng nhập thành công.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              FilledButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AuthPage(),
                    ),
                  );
                },
                child: const Text('Quay lại trang đăng nhập'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}