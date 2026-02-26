class ProductCustomizationModel {
  final int id;
  final String name;
  final String? description;
  final bool isRequired;
  final int selectionType; // 0 = single select, 1 = multi select
  final int maxSelect;
  final List<CustomizationOption> options;

  ProductCustomizationModel({
    required this.id,
    required this.name,
    this.description,
    required this.isRequired,
    required this.selectionType,
    required this.maxSelect,
    required this.options,
  });

  factory ProductCustomizationModel.fromJson(Map<String, dynamic> json) {
    return ProductCustomizationModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      isRequired: json['is_required'] ?? false,
      selectionType: json['selection_type'] ?? 0,
      maxSelect: json['max_select'] ?? 1,
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
      'is_required': isRequired,
      'selection_type': selectionType,
      'max_select': maxSelect,
      'options': options.map((e) => e.toJson()).toList(),
    };
  }
}

class CustomizationOption {
  final int id;
  final String name;
  final double? price;
  final String? barcode;

  CustomizationOption({
    required this.id,
    required this.name,
    this.price,
    this.barcode,
  });

  factory CustomizationOption.fromJson(Map<String, dynamic> json) {
    return CustomizationOption(
      id: json['id'] ?? 0,
      name: json['label'] ?? json['name'] ?? '', // API uses 'label'
      price: json['price_delta'] != null
          ? (json['price_delta'] as num).toDouble()
          : (json['price'] != null
                ? (json['price'] as num).toDouble()
                : null), // API uses 'price_delta'
      barcode: json['barcode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'price': price, 'barcode': barcode};
  }
}
