import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
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
    int branchId,
  ) {
    return {
      'order_type_id': 1,
      'order_status': 1,
      'branch_id': branchId,
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

  Future<String> submitOrder({
    required String customerName,
    required List<CartItem> items,
    required int branchId,
  }) async {
    if (items.isEmpty) {
      throw Exception('Cart is empty');
    }

    final deviceId = await _getDeviceId();
    final payload = _buildPayload(customerName, items, branchId);

    debugPrint('=== SUBMITTING ORDER ===');
    debugPrint('Payload: $payload');
    debugPrint('Headers: x-device-id: $deviceId');

    final response = await _supabase.functions
        .invoke(
          'create-self-order',
          body: payload,
          headers: {'x-device-id': deviceId},
        )
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw TimeoutException(
            'Order request timed out after 30 seconds. Please try again.',
          ),
        );

    debugPrint('=== ORDER COMPLETED ===');
    debugPrint('Status Code: ${response.status}');
    debugPrint('Response Data: ${response.data}');
    debugPrint('Response Data Type: ${response.data.runtimeType}');

    if (response.status != 200 && response.status != 201) {
      debugPrint('Submission Error Data: ${response.data}');
      throw Exception('Failed to submit order: ${response.status}');
    }

    dynamic data = response.data;
    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (_) {}
    }

    debugPrint('=== PARSED DATA TYPE: ${data.runtimeType} ===');
    debugPrint('=== PARSED DATA: $data ===');

    // Helper to extract order_key from any map level
    String? _extractKey(dynamic d) {
      if (d is! Map) return null;
      // Direct keys
      for (final k in [
        'order_key',
        'orderKey',
        'order_number',
        'orderNumber',
        'key',
      ]) {
        final v = d[k]?.toString();
        if (v != null && v.isNotEmpty) return v;
      }
      // One level deeper (e.g. { data: { order_key: ... } } or { order: { order_key: ... } })
      for (final k in ['data', 'order', 'result', 'payload']) {
        final nested = d[k];
        final v = _extractKey(nested);
        if (v != null) return v;
      }
      // Last resort: numeric id
      final id = d['id']?.toString();
      if (id != null && id.isNotEmpty) return id;
      return null;
    }

    final orderKey = _extractKey(data);
    debugPrint('=== EXTRACTED ORDER KEY: "$orderKey" ===');
    if (orderKey != null && orderKey.isNotEmpty) return orderKey;

    if (data is String && data.isNotEmpty) {
      debugPrint('=== DATA IS STRING: "$data" ===');
      return data;
    }

    debugPrint('=== WARNING: Could not extract order key from response ===');
    return '';
  }
}
