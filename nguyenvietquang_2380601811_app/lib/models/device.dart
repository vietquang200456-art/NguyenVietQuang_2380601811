class Device {
  final int id;
  final String name;
  final String? description;
  final String category;
  final double price;
  final String? brand;
  final String? modelNumber;
  final String? imageUrl;
  final int stockQuantity;
  final int minAge;
  final int maxAge;
  final bool isAvailable;
  final double averageRating;
  final int reviewCount;
  final DateTime? createdAt;

  const Device({required this.id, required this.name, this.description, required this.category, required this.price, this.brand, this.modelNumber, this.imageUrl, required this.stockQuantity, required this.minAge, required this.maxAge, required this.isAvailable, required this.averageRating, required this.reviewCount, this.createdAt});

  factory Device.fromJson(Map<String, dynamic> json) => Device(
    id: _int(json['id']), name: '${json['name'] ?? ''}', description: json['description']?.toString(), category: '${json['category'] ?? ''}', price: _double(json['price']), brand: json['brand']?.toString(), modelNumber: json['modelNumber']?.toString(), imageUrl: json['imageUrl']?.toString(), stockQuantity: _int(json['stockQuantity']), minAge: _int(json['minAge']), maxAge: _int(json['maxAge']), isAvailable: json['isAvailable'] == true, averageRating: _double(json['averageRating']), reviewCount: _int(json['reviewCount']), createdAt: json['createdAt'] == null ? null : DateTime.tryParse('${json['createdAt']}'),
  );
  static int _int(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
  static double _double(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
}
