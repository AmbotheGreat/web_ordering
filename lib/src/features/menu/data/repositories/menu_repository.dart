import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web_ordering/src/features/menu/domain/models/category.dart';
import 'package:web_ordering/src/features/menu/domain/models/department.dart';
import 'package:web_ordering/src/features/menu/domain/models/item.dart';
import 'package:web_ordering/src/features/menu/domain/models/product_customization.dart';

class MenuRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<CategoryModel>> fetchCategories(
    int branchId,
    int departmentId,
  ) async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .eq('branch_id', branchId)
          .eq('department_id', departmentId)
          .eq('status', true)
          .order('ordering_index', ascending: true);

      return (response as List).map((e) => CategoryModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  Future<List<ItemModel>> fetchItems(int branchId, int departmentId) async {
    try {
      final response = await _client
          .from('items')
          .select()
          .eq('branch_id', branchId)
          .eq('department_id', departmentId);
      return (response as List).map((e) => ItemModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch items: $e');
    }
  }

  Future<List<DepartmentModel>> fetchDepartments(int branchId) async {
    try {
      final response = await _client
          .from('departments')
          .select()
          .eq('branch_id', branchId)
          .order('dept_id', ascending: true);
      return (response as List)
          .map((e) => DepartmentModel.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch departments: $e');
    }
  }

  // Fetch customizations for a single item by barcode
  Future<List<ProductCustomizationModel>> fetchProductCustomizationByBarcode(
    String barcode,
    int branchId,
  ) async {
    try {
      print(
        '📡 Calling edge function for barcode: $barcode, branchId: $branchId',
      );

      final response = await _client.functions.invoke(
        'get-product-customizations',
        body: {'barcode': barcode, 'branch_id': branchId},
      );

      print('📦 Edge function response status: ${response.status}');
      print('📦 Edge function response data: ${response.data}');

      if (response.data != null) {
        // The API returns {barcode: "...", option_groups: [...]}
        // Extract option_groups from the response
        final List<dynamic> customizationsData = response.data is List
            ? response.data
            : (response.data['option_groups'] ??
                  []); // Changed from 'customizations' to 'option_groups'

        print('📋 Parsed customizations data: $customizationsData');
        print('📊 Number of customizations: ${customizationsData.length}');

        return customizationsData
            .map(
              (e) =>
                  ProductCustomizationModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      }

      print('⚠️ Edge function returned null data');
      return [];
    } catch (e) {
      print('❌ Edge function error: $e');
      throw Exception('Failed to fetch product customizations: $e');
    }
  }

  Future<Map<String, List<ProductCustomizationModel>>>
  fetchProductCustomizations(List<ItemModel> items, int branchId) async {
    try {
      final Map<String, List<ProductCustomizationModel>> customizationsMap = {};

      // Filter items that have barcodes
      final itemsWithBarcodes = items
          .where((item) => item.barcode != null && item.barcode!.isNotEmpty)
          .toList();

      // If no items with barcodes, return empty map
      if (itemsWithBarcodes.isEmpty) {
        return customizationsMap;
      }

      // Fetch customizations for each item with a barcode
      for (final item in itemsWithBarcodes) {
        try {
          final response = await _client.functions.invoke(
            'get-product-customizations',
            body: {'barcode': item.barcode, 'branch_id': branchId},
          );

          if (response.data != null) {
            final List<dynamic> customizationsData = response.data is List
                ? response.data
                : (response.data['customizations'] ?? []);

            final customizations = customizationsData
                .map(
                  (e) => ProductCustomizationModel.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList();

            if (customizations.isNotEmpty) {
              customizationsMap[item.barcode!] = customizations;
            }
          }
        } catch (e) {
          // Silently continue with other items if one fails
          // This ensures one failing item doesn't block the entire app
        }
      }

      return customizationsMap;
    } catch (e) {
      // Don't throw - return empty map instead to prevent blocking the app
      // The app will still work, just without customizations
      return {};
    }
  }
}
