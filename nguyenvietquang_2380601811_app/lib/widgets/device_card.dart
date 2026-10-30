import 'package:flutter/material.dart';
import '../models/device.dart';

class DeviceCard extends StatelessWidget {
  final Device device;
  final VoidCallback? onDelete;
  final bool isAdmin;

  const DeviceCard({super.key, required this.device, this.onDelete, this.isAdmin = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
              child: device.imageUrl == null ? const Icon(Icons.devices, size: 38, color: Colors.blue) : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(device.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.devices))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(device.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(device.category),
                  const SizedBox(height: 6),
                  Text('${device.price.toStringAsFixed(0)} VNĐ', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  Text('Kho: ${device.stockQuantity}', style: TextStyle(color: device.stockQuantity > 0 ? Colors.green : Colors.red)),
                ],
              ),
            ),
            if (isAdmin && onDelete != null) IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline, color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
