class ItemModel {
  final int id;
  final String name;
  final String? description;
  final int categoryId;
  final int branchId;
  final double price;
  final String? imageUrl;
  final int status;
  final String? barcode;

  ItemModel({
    required this.id,
    required this.name,
    this.description,
    required this.categoryId,
    required this.branchId,
    required this.price,
    this.imageUrl,
    required this.status,
    this.barcode,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    final displayImage = json['display_image'] as String?;
    String? fullImageUrl;

    if (displayImage != null && displayImage.isNotEmpty) {
      // Check if it's already a full URL
      if (displayImage.startsWith('http://') ||
          displayImage.startsWith('https://')) {
        fullImageUrl = displayImage;
      } else {
        // Generate Supabase storage public URL
        const supabaseUrl = 'https://llsxflpmyrpwcintfcfd.supabase.co';
        fullImageUrl = '$supabaseUrl/storage/v1/object/public/$displayImage';
      }
    }

    return ItemModel(
      id: json['id'],
      name: json['item_name'],
      description: json['item_desc'],
      categoryId: json['category_id'],
      branchId: json['branch_id'],
      price: (json['price'] as num).toDouble(),
      imageUrl: fullImageUrl,
      status: json['item_status'],
      barcode: json['barcode'],
    );
  }
}
