class DepartmentModel {
  final int id;
  final String name;
  final String? imageUrl;
  final bool isAvailable;

  DepartmentModel({
    required this.id,
    required this.name,
    this.imageUrl,
    this.isAvailable = true,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    // Support both 'display_image' and 'image_url' column names
    final rawImage = (json['display_image'] ?? json['image_url']) as String?;

    String? fullImageUrl;
    if (rawImage != null && rawImage.isNotEmpty) {
      if (rawImage.startsWith('http://') || rawImage.startsWith('https://')) {
        fullImageUrl = rawImage;
      } else {
        // Construct Supabase Storage public URL for relative paths
        fullImageUrl = rawImage;
      }
    }

    return DepartmentModel(
      id: json['dept_id'] as int,
      name: json['dept_name'] as String? ?? '',
      imageUrl: fullImageUrl,
      isAvailable: json['is_available'] != false,
    );
  }
}
