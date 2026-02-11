class CategoryModel {
  final int
  id; // This will map to category_id aka the business key derived in the schema
  final int branchId;
  final String name;
  final String? description;
  final bool isAvailableInWeb;
  final int? orderingIndex;

  CategoryModel({
    required this.id,
    required this.branchId,
    required this.name,
    this.description,
    this.isAvailableInWeb = false,
    this.orderingIndex,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['category_id'],
      branchId: json['branch_id'],
      name: json['category_name'],
      description: json['category_desc'],
      isAvailableInWeb: json['is_available_in_web_table'] ?? false,
      orderingIndex: json['ordering_index'],
    );
  }
}
