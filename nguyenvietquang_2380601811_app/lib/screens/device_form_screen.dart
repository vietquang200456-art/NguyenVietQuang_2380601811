import 'package:flutter/material.dart';
import '../controllers/device_controller.dart';
import '../services/device_service.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class DeviceFormScreen extends StatefulWidget {
  final DeviceController deviceController;
  const DeviceFormScreen({super.key, required this.deviceController});
  @override
  State<DeviceFormScreen> createState() => _DeviceFormScreenState();
}

class _DeviceFormScreenState extends State<DeviceFormScreen> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final stockController = TextEditingController();
  final minAgeController = TextEditingController();
  final maxAgeController = TextEditingController();
  final imageUrlController = TextEditingController();
  String category = 'SmartWatch';
  bool loading = false;
  final categories = const ['EducationalToy', 'ElectronicDevice', 'SafetyDevice', 'Monitor', 'SmartWatch', 'Tablet', 'Other'];

  Future<void> _submit() async {
    setState(() => loading = true);
    try {
      await DeviceService().createDevice(name: nameController.text.trim(), description: descriptionController.text.trim(), category: category, price: double.tryParse(priceController.text) ?? 0, brand: brandController.text.trim(), modelNumber: modelController.text.trim(), stockQuantity: int.tryParse(stockController.text) ?? 0, minAge: int.tryParse(minAgeController.text) ?? 0, maxAge: int.tryParse(maxAgeController.text) ?? 0, imageUrl: imageUrlController.text.trim());
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm thiết bị')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        AppTextField(controller: nameController, label: 'Tên thiết bị', icon: Icons.devices),
        const SizedBox(height: 12),
        AppTextField(controller: descriptionController, label: 'Mô tả', icon: Icons.description),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(value: category, decoration: const InputDecoration(labelText: 'Danh mục', border: OutlineInputBorder()), items: categories.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: (value) { if (value != null) setState(() => category = value); }),
        const SizedBox(height: 12),
        AppTextField(controller: priceController, label: 'Giá', icon: Icons.payments, keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        AppTextField(controller: brandController, label: 'Thương hiệu', icon: Icons.branding_watermark),
        const SizedBox(height: 12),
        AppTextField(controller: modelController, label: 'Model', icon: Icons.model_training),
        const SizedBox(height: 12),
        AppTextField(controller: stockController, label: 'Số lượng', icon: Icons.inventory, keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: AppTextField(controller: minAgeController, label: 'Tuổi nhỏ nhất', icon: Icons.child_care, keyboardType: TextInputType.number)), const SizedBox(width: 12), Expanded(child: AppTextField(controller: maxAgeController, label: 'Tuổi lớn nhất', icon: Icons.escalator_warning, keyboardType: TextInputType.number))]),
        const SizedBox(height: 12),
        AppTextField(controller: imageUrlController, label: 'Image URL', icon: Icons.image),
        const SizedBox(height: 24),
        AppButton(text: 'Tạo thiết bị', loading: loading, onPressed: _submit)
      ]))
    );
  }
}
