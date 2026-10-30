import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final String initialName;
  const SettingsPage({super.key, required this.initialName});
  @override State<SettingsPage> createState() => _SettingsPageState();
}
class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController nameController;
  double textScale = 1.0;
  Color background = const Color(0xFFF7FAF9);
  @override void initState() { super.initState(); nameController = TextEditingController(text: widget.initialName); }
  @override void dispose() { nameController.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: background,
    appBar: AppBar(title: const Text('Cài đặt')),
    body: MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)), child: ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Hiển thị', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Cỡ chữ: ${textScale.toStringAsFixed(1)}x'), Slider(value: textScale, min: .85, max: 1.35, divisions: 10, onChanged: (v) => setState(() => textScale = v)),
        const Text('Màu nền'), const SizedBox(height: 10), Wrap(spacing: 12, children: [for (final color in [const Color(0xFFF7FAF9), const Color(0xFFFFF8E7), const Color(0xFFEAF3FF), const Color(0xFFF7ECF7), const Color(0xFF202A34)]) GestureDetector(onTap: () => setState(() => background = color), child: CircleAvatar(backgroundColor: color, child: background == color ? const Icon(Icons.check) : null))]),
      ]))),
      const SizedBox(height: 20), const Text('Hồ sơ cá nhân', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Họ và tên', prefixIcon: Icon(Icons.person_outline))), const SizedBox(height: 16), SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () { if (nameController.text.trim().isNotEmpty) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu thay đổi trong phiên hiện tại'))); }, icon: const Icon(Icons.save_outlined), label: const Text('Lưu thay đổi')))]))),
    ])),
  );
}
