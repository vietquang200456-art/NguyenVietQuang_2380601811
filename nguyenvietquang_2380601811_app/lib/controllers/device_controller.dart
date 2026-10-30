import 'package:flutter/foundation.dart';
import '../models/device.dart';
import '../services/device_service.dart';

class DeviceController extends ChangeNotifier {
  final DeviceService deviceService;
  DeviceController({DeviceService? deviceService}) : deviceService = deviceService ?? DeviceService();

  List<Device> devices = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadDevices({String? search, String? category}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      devices = await deviceService.getDevices(search: search, category: category);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteDevice(int id) async {
    try {
      await deviceService.deleteDevice(id);
      devices.removeWhere((device) => device.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
