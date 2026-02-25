import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web_ordering/src/features/cart/domain/models/cart_item.dart';

class CartService {
  final SupabaseClient _supabase;

  CartService({SupabaseClient? supabase}) : _supabase = supabase ?? Supabase.instance.client;

  Future<String> _getDeviceId() async {
    String deviceId = 'flutter-app';
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'flutter-ios';
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        deviceId = windowsInfo.deviceId;
      }
    } catch (_) {
      // Fallback if device info fails
    }
    return deviceId;
  }

  Map<String, dynamic> _buildPayload(
    String customerName,
    List<CartItem> items,
  ) {
    return {
      'order_type_id': 1,
      'order_status': 0,
      'branch_id': 1, // Currently hardcoded to 1
      'customer_name': customerName,
      'items': items.map((item) {
        final Map<String, dynamic> itemData = {
          'item_barcode': item.item.barcode ?? '',
          'quantity': item.quantity,
          'item_price': item.item.price,
        };

        if (item.note != null && item.note!.trim().isNotEmpty) {
          itemData['item_modifiers'] = item.note!.trim();
        }

        if (item.selectedCustomizations.isNotEmpty) {
          // Map customizations to the backend Record<string, string[]> format
          final Map<String, List<String>> formattedCustomizations = {};
          for (final c in item.selectedCustomizations) {
            if (!formattedCustomizations.containsKey(c.groupName)) {
              formattedCustomizations[c.groupName] = [];
            }
            formattedCustomizations[c.groupName]!.add(c.localId ?? c.barcode ?? '');
          }
          itemData['item_customization'] = formattedCustomizations;
        }

        return itemData;
      }).toList(),
    };
  }

  Future<void> submitOrder({
    required String customerName,
    required List<CartItem> items,
  }) async {
    if (items.isEmpty) {
      throw Exception('Cart is empty');
    }

    final deviceId = await _getDeviceId();
    final payload = _buildPayload(customerName, items);

    print('=== SUBMITTING ORDER ===');
    print('Payload: $payload');
    print('Headers: x-device-id: $deviceId');

    final response = await _supabase.functions.invoke(
      'create-self-order',
      body: payload,
      headers: {'x-device-id': deviceId},
    );

    print('=== ORDER COMPLETED ===');
    print('Status Code: ${response.status}');
    print('Response Data: ${response.data}');

    if (response.status != 200 && response.status != 201) {
      print('Submission Error Data: ${response.data}');
      throw Exception('Failed to submit order: ${response.status}');
    }
  }
}
