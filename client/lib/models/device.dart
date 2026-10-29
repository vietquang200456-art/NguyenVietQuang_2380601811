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

  const Device({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.brand,
    required this.modelNumber,
    required this.imageUrl,
    required this.stockQuantity,
    required this.minAge,
    required this.maxAge,
    required this.isAvailable,
    required this.averageRating,
    required this.reviewCount,
    required this.createdAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    num number(dynamic value) => value is num ? value : num.tryParse('$value') ?? 0;

    return Device(
      id: (json['id'] ?? json['Id'] ?? 0) as int,
      name: (json['name'] ?? json['Name'] ?? '').toString(),
      description: (json['description'] ?? json['Description'])?.toString(),
      category: (json['category'] ?? json['Category'] ?? '').toString(),
      price: number(json['price'] ?? json['Price']).toDouble(),
      brand: (json['brand'] ?? json['Brand'])?.toString(),
      modelNumber: (json['modelNumber'] ?? json['ModelNumber'])?.toString(),
      imageUrl: (json['imageUrl'] ?? json['ImageUrl'])?.toString(),
      stockQuantity: number(json['stockQuantity'] ?? json['StockQuantity']).toInt(),
      minAge: number(json['minAge'] ?? json['MinAge']).toInt(),
      maxAge: number(json['maxAge'] ?? json['MaxAge']).toInt(),
      isAvailable: json['isAvailable'] ?? json['IsAvailable'] ?? true,
      averageRating: number(json['averageRating'] ?? json['AverageRating']).toDouble(),
      reviewCount: number(json['reviewCount'] ?? json['ReviewCount']).toInt(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? json['CreatedAt'] ?? '').toString()),
    );
  }
}
