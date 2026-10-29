import 'package:flutter/material.dart';

import '../models/device.dart';
import '../services/device_api.dart';

class DeviceManagementPage extends StatefulWidget {
  final DeviceApi api;
  const DeviceManagementPage({super.key, required this.api});

  @override
  State<DeviceManagementPage> createState() => _DeviceManagementPageState();
}

class _DeviceManagementPageState extends State<DeviceManagementPage> {
  final searchController = TextEditingController();
  List<Device> devices = [];
  bool loading = true;

  @override
  void initState() { super.initState(); loadDevices(); }
  @override
  void dispose() { searchController.dispose(); super.dispose(); }

  void message(String text, {bool error = false}) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: error ? Colors.red : const Color(0xFF0B6E69)));

  Future<void> loadDevices() async {
    setState(() => loading = true);
    try {
      final result = await widget.api.getDevices(search: searchController.text);
      if (mounted) setState(() => devices = result);
    } catch (e) { if (mounted) message(e.toString().replaceFirst('Exception: ', ''), error: true); }
    finally { if (mounted) setState(() => loading = false); }
  }

  Future<void> openEditor({Device? device}) async {
    final name = TextEditingController(text: device?.name ?? '');
    final category = TextEditingController(text: device?.category ?? '');
    final price = TextEditingController(text: device == null ? '' : device.price.toString());
    final stock = TextEditingController(text: device == null ? '' : device.stockQuantity.toString());
    final minAge = TextEditingController(text: device == null ? '0' : device.minAge.toString());
    final maxAge = TextEditingController(text: device == null ? '18' : device.maxAge.toString());
    final description = TextEditingController(text: device?.description ?? '');
    final brand = TextEditingController(text: device?.brand ?? '');
    final model = TextEditingController(text: device?.modelNumber ?? '');
    final image = TextEditingController(text: device?.imageUrl ?? '');

    final saved = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: Text(device == null ? 'Thêm thiết bị' : 'Sửa thiết bị'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Tên thiết bị')),
        TextField(controller: category, decoration: const InputDecoration(labelText: 'Danh mục')),
        TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Giá')),
        TextField(controller: stock, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Số lượng')),
        TextField(controller: minAge, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tuổi nhỏ nhất')),
        TextField(controller: maxAge, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tuổi lớn nhất')),
        TextField(controller: brand, decoration: const InputDecoration(labelText: 'Thương hiệu')),
        TextField(controller: model, decoration: const InputDecoration(labelText: 'Mã model')),
        TextField(controller: image, decoration: const InputDecoration(labelText: 'URL hình ảnh')),
        TextField(controller: description, decoration: const InputDecoration(labelText: 'Mô tả')),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
        FilledButton(onPressed: () async {
          final body = {'name': name.text.trim(), 'category': category.text.trim(), 'price': double.tryParse(price.text) ?? 0, 'stockQuantity': int.tryParse(stock.text) ?? 0, 'minAge': int.tryParse(minAge.text) ?? 0, 'maxAge': int.tryParse(maxAge.text) ?? 18, 'brand': brand.text.trim(), 'modelNumber': model.text.trim(), 'imageUrl': image.text.trim(), 'description': description.text.trim()};
          try { if (device == null) { await widget.api.createDevice(body); } else { await widget.api.updateDevice(device.id, body); } if (context.mounted) Navigator.pop(context, true); } catch (e) { if (context.mounted) message(e.toString().replaceFirst('Exception: ', ''), error: true); }
        }, child: const Text('Lưu')),
      ],
    ));

    for (final controller in [name, category, price, stock, minAge, maxAge, description, brand, model, image]) controller.dispose();
    if (saved == true) { await loadDevices(); message(device == null ? 'Đã thêm thiết bị' : 'Đã cập nhật thiết bị'); }
  }

  Future<void> deleteDevice(Device device) async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('Xóa thiết bị?'), content: Text(device.name), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa'))])) ?? false;
    if (!confirmed) return;
    try { await widget.api.deleteDevice(device.id); await loadDevices(); message('Đã xóa thiết bị'); } catch (e) { message(e.toString().replaceFirst('Exception: ', ''), error: true); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Quản lý thiết bị')),
    floatingActionButton: FloatingActionButton.extended(onPressed: () => openEditor(), icon: const Icon(Icons.add), label: const Text('Thêm')),
    body: Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: Row(children: [Expanded(child: TextField(controller: searchController, onSubmitted: (_) => loadDevices(), decoration: const InputDecoration(labelText: 'Tìm thiết bị', prefixIcon: Icon(Icons.search)))), const SizedBox(width: 8), IconButton(onPressed: loadDevices, icon: const Icon(Icons.refresh))])),
      Expanded(child: loading ? const Center(child: CircularProgressIndicator()) : devices.isEmpty ? const Center(child: Text('Chưa có thiết bị')) : ListView.builder(padding: const EdgeInsets.all(16), itemCount: devices.length, itemBuilder: (_, index) { final device = devices[index]; return Card(child: ListTile(leading: device.imageUrl?.isNotEmpty == true ? Image.network(device.imageUrl!, width: 52, height: 52, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.devices)) : const Icon(Icons.devices), title: Text(device.name), subtitle: Text('${device.category} - ${device.price.toStringAsFixed(0)} | Kho: ${device.stockQuantity}'), trailing: PopupMenuButton<String>(onSelected: (value) { if (value == 'edit') openEditor(device: device); if (value == 'delete') deleteDevice(device); }, itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Sửa')), PopupMenuItem(value: 'delete', child: Text('Xóa'))]))); }))
    ]),
  );
}
