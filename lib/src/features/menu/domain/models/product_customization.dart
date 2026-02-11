class ProductCustomizationModel {
  final int id;
  final String name;
  final String? description;
  final List<CustomizationOption> options;

  ProductCustomizationModel({
    required this.id,
    required this.name,
    this.description,
    required this.options,
  });

  factory ProductCustomizationModel.fromJson(Map<String, dynamic> json) {
    return ProductCustomizationModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      options:
          (json['options'] as List<dynamic>?)
              ?.map(
                (e) => CustomizationOption.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'options': options.map((e) => e.toJson()).toList(),
    };
  }
}

class CustomizationOption {
  final int id;
  final String name;
  final double? price;

  CustomizationOption({required this.id, required this.name, this.price});

  factory CustomizationOption.fromJson(Map<String, dynamic> json) {
    return CustomizationOption(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'price': price};
  }
}
