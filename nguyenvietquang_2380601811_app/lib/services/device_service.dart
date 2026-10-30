import '../models/device.dart';
import 'api_client.dart';

class DeviceService {
  final ApiClient apiClient;
  DeviceService({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  Future<List<Device>> getDevices({int pageNumber = 1, int pageSize = 20, String? search, String? category}) async {
    final query = <String, String>{'pageNumber': '$pageNumber', 'pageSize': '$pageSize'};
    if (search?.trim().isNotEmpty == true) query['search'] = search!.trim();
    if (category?.trim().isNotEmpty == true) query['category'] = category!.trim();
    final response = await apiClient.get('/Devices?${Uri(queryParameters: query).query}');
    final data = response is Map ? response['data'] : null;
    final items = data is Map && data['items'] is List ? data['items'] as List : <dynamic>[];
    return items.whereType<Map>().map((item) => Device.fromJson(Map<String, dynamic>.from(item))).toList();
  }

  Future<Device> getDevice(int id) async {
    final response = await apiClient.get('/Devices/$id');
    return Device.fromJson(Map<String, dynamic>.from(response['data'] as Map));
  }

  Future<Device> createDevice({required String name, required String description, required String category, required double price, required String brand, required String modelNumber, required int stockQuantity, required int minAge, required int maxAge, String? imageUrl}) async {
    final response = await apiClient.post('/Devices', auth: true, body: {'name': name, 'description': description, 'category': category, 'price': price, 'brand': brand, 'modelNumber': modelNumber, 'imageUrl': imageUrl?.isEmpty == true ? null : imageUrl, 'stockQuantity': stockQuantity, 'minAge': minAge, 'maxAge': maxAge});
    return Device.fromJson(Map<String, dynamic>.from(response['data'] as Map));
  }

  Future<void> deleteDevice(int id) async => apiClient.delete('/Devices/$id', auth: true);
}
