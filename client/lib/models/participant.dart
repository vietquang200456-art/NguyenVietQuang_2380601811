class Participant {
  final String identity;
  final String name;
  final String role;
  final DateTime? joinedAt;
  final bool isConnected;

  const Participant({
    required this.identity,
    required this.name,
    required this.role,
    required this.joinedAt,
    required this.isConnected,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      identity: (json['identity'] ?? json['Identity'] ?? '').toString(),
      name: (json['name'] ?? json['Name'] ?? '').toString(),
      role: (json['role'] ?? json['Role'] ?? '').toString(),
      joinedAt: DateTime.tryParse(
        (json['joinedAt'] ?? json['JoinedAt'] ?? '').toString(),
      ),
      isConnected: json['isConnected'] ?? json['IsConnected'] ?? false,
    );
  }
}