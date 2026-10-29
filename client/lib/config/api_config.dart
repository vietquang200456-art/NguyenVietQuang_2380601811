class ApiConfig {
  // Android Emulator dùng 10.0.2.2 để truy cập localhost của máy tính.
  static const String baseUrl = 'http://192.168.1.110:5057/api';

  // Nếu chạy Flutter Web hoặc Windows trên cùng máy với Server:
  // static const String baseUrl = 'http://localhost:5057/api';

  // Nếu chạy trên điện thoại thật, dùng IP của máy tính:
  // static const String baseUrl = 'http://192.168.1.10:5057/api';
}