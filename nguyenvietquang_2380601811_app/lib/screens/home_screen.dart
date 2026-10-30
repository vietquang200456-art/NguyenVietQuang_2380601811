import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'devices_screen.dart';
import 'login_screen.dart';
import 'video_call_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  final AuthController authController;

  const HomeScreen({super.key, required this.authController});

  @override
  Widget build(BuildContext context) {
    final user = authController.currentUser;
    if (user == null) return _LoginFallback(authController: authController);

    final name = user.fullName.trim().isEmpty ? user.email : user.fullName.trim();
    final initial = name.isEmpty ? 'U' : name.substring(0, 1).toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Devices'),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      initial,
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(user.email, style: TextStyle(color: Colors.grey.shade600)),
                        const SizedBox(height: 8),
                        Chip(label: Text(user.role)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Chức năng', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _FeatureTile(
            icon: Icons.devices,
            title: 'Quản lý thiết bị',
            subtitle: 'Xem và quản lý thiết bị trẻ em',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DevicesScreen(authController: authController))),
          ),
          _FeatureTile(
            icon: Icons.video_call,
            title: 'Video Call',
            subtitle: 'Phòng cuộc gọi video trực tuyến',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VideoCallScreen(authController: authController))),
          ),
          _FeatureTile(
            icon: Icons.settings,
            title: 'Cài đặt',
            subtitle: 'Xem và chỉnh sửa toàn bộ hồ sơ cá nhân',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(authController: authController))),
          ),
          _FeatureTile(
            icon: Icons.shopping_cart,
            title: 'Đơn hàng',
            subtitle: 'Tính năng đang được phát triển',
            onTap: () => _showMessage(context),
          ),
          _FeatureTile(
            icon: Icons.star,
            title: 'Đánh giá',
            subtitle: 'Tính năng đang được phát triển',
            onTap: () => _showMessage(context),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await authController.logout();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen(authController: authController)),
      (_) => false,
    );
  }

  void _showMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng đang được phát triển')));
  }
}

class _LoginFallback extends StatelessWidget {
  final AuthController authController;
  const _LoginFallback({required this.authController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Child Devices')),
      body: Center(
        child: FilledButton(
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen(authController: authController))),
          child: const Text('Đăng nhập'),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
