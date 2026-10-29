class AuthResponse {
  final String token;
  final int? userId;
  final String email;
  final String fullName;
  final String? role;

  const AuthResponse({
    required this.token,
    required this.userId,
    required this.email,
    required this.fullName,
    this.role,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json['Data'] ?? {};
    final user = data['user'] ?? data['User'] ?? {};

    return AuthResponse(
      token: (data['token'] ?? data['Token'] ?? '').toString(),
      userId: int.tryParse(
        (user['id'] ?? user['Id'] ?? '').toString(),
      ),
      email: (user['email'] ?? user['Email'] ?? '').toString(),
      fullName: (user['fullName'] ?? user['FullName'] ?? '').toString(),
      role: (user['role'] ?? user['Role'])?.toString(),
    );
  }
}
