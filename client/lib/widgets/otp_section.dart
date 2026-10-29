import 'package:flutter/material.dart';

class OtpSection extends StatelessWidget {
  final TextEditingController controller;
  final bool otpSent;
  final bool loading;
  final VoidCallback onSendOtp;
  final VoidCallback onVerifyOtp;

  const OtpSection({
    super.key,
    required this.controller,
    required this.otpSent,
    required this.loading,
    required this.onSendOtp,
    required this.onVerifyOtp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Mã OTP',
                  prefixIcon: Icon(Icons.password_rounded),
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: loading ? null : onSendOtp,
              child: Text(
                otpSent ? 'Gửi lại' : 'Gửi OTP',
              ),
            ),
          ],
        ),

        if (otpSent)
          TextButton.icon(
            onPressed: loading ? null : onVerifyOtp,
            icon: const Icon(Icons.verified_outlined),
            label: const Text('Xác thực OTP'),
          ),
      ],
    );
  }
}