class BoxSize {
  final int id;
  final String description;
  final double height;
  final double width;
  final double length;
  final double volume;
  final double weight;
  final double price;
  final int customSize;

  BoxSize({
    required this.id,
    required this.description,
    required this.height,
    required this.width,
    required this.length,
    required this.volume,
    required this.weight,
    required this.price,
    required this.customSize,
  });

  factory BoxSize.fromJson(Map<String, dynamic> json) {
    return BoxSize(
      id: json['id'] ?? 0,
      description: json['description'] ?? '',
      height: double.tryParse(json['height']?.toString() ?? '0') ?? 0.0,
      width: double.tryParse(json['width']?.toString() ?? '0') ?? 0.0,
      length: double.tryParse(json['length']?.toString() ?? '0') ?? 0.0,
      volume: double.tryParse(json['volume']?.toString() ?? '0') ?? 0.0,
      weight: double.tryParse(json['weight']?.toString() ?? '0') ?? 0.0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      customSize: int.tryParse(json['custom_size']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'height': height,
      'width': width,
      'length': length,
      'volume': volume,
      'weight': weight,
      'price': price,
      'custom_size': customSize,
    };
  }

  // Helper method to get display text for dropdown
  String get displayText {
    if (customSize == 1) {
      return 'Custom Size';
    }
    return '$description (${width}×${height}×${length} cm)';
  }

  // Check if this is a custom size option
  bool get isCustomSize => customSize == 1;
}