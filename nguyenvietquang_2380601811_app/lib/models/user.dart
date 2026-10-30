class User {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String role;
  final DateTime? createdAt;

  const User({required this.id, this.username = '', required this.email, required this.fullName, this.phoneNumber, required this.role, this.createdAt});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: _asInt(json['id']),
    username: (json['username'] ?? json['email'] ?? '').toString(),
    email: (json['email'] ?? '').toString(),
    fullName: (json['fullName'] ?? '').toString(),
    phoneNumber: json['phoneNumber']?.toString(),
    role: (json['role'] ?? 'User').toString(),
    createdAt: _asDate(json['createdAt']),
  );

  User copyWith({String? username, String? email, String? fullName, String? phoneNumber, String? role, DateTime? createdAt}) => User(
    id: id,
    username: username ?? this.username,
    email: email ?? this.email,
    fullName: fullName ?? this.fullName,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    role: role ?? this.role,
    createdAt: createdAt ?? this.createdAt,
  );

  static int _asInt(dynamic value) => value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  static DateTime? _asDate(dynamic value) => value == null ? null : DateTime.tryParse(value.toString());
  bool get isAdmin => role.toLowerCase() == 'admin';
}
