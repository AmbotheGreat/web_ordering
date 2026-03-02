import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web_ordering/src/core/theme/app_colors.dart';
import 'package:web_ordering/src/features/cart/domain/models/cart_item.dart';

// ── Status data ──────────────────────────────────────────────────────────────

const _statusLabels = {
  0: 'Pending',
  1: 'Preparing',
  2: 'Ready for Pickup',
  3: 'Completed',
};

const _statusColors = {
  0: Colors.red,
  1: Colors.blue,
  2: Colors.green,
  3: Colors.green,
};

const _statusMessages = {
  0: 'Show this QR code to the cashier to pay your order.',
  1: 'Your order is being prepared. Please wait.',
  2: 'Your order is ready for pickup! Please proceed to the counter.',
  3: 'Your order is completed. Thank you!',
};

// ── Screen ───────────────────────────────────────────────────────────────────

class QrScreen extends StatefulWidget {
  final String orderKey;
  final List<CartItem> items;

  const QrScreen({super.key, required this.orderKey, required this.items});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  int? _orderStatus;
  bool _loading = true;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _fetchStatus(),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchStatus() async {
    try {
      final supabase = Supabase.instance.client;
      final isNumericId = int.tryParse(widget.orderKey) != null;

      final data = isNumericId
          ? await supabase
                .from('self_orders')
                .select('order_status')
                .eq('id', int.parse(widget.orderKey))
                .maybeSingle()
          : await supabase
                .from('self_orders')
                .select('order_status')
                .eq('order_key', widget.orderKey)
                .maybeSingle();

      if (mounted) {
        setState(() {
          _orderStatus = (data?['order_status'] as num?)?.toInt();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onBackToHome() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'REMINDER',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'You cannot return to this QR once you leave.\n\nPlease ensure the cashier has scanned your code.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Stay',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF396cfd),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Go Home',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) context.go('/');
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusLabel = _statusLabels[_orderStatus] ?? 'Pending';
    final statusColor = _statusColors[_orderStatus] ?? _statusColors[0]!;
    final statusMessage = _statusMessages[_orderStatus] ?? _statusMessages[0]!;

    return Scaffold(
      backgroundColor: const Color(0xFF396cfd),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Opacity(
            opacity: 0.3,
            child: Image.asset('assets/images/qrbg.png', fit: BoxFit.cover),
          ),

          // Main card content
          Positioned(
            top: MediaQuery.of(context).size.height * 0.21,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Status badge
                    _loading
                        ? const SizedBox(
                            height: 48,
                            child: Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          )
                        : _buildStatusBadge(statusLabel, statusColor),
                    const SizedBox(height: 16),

                    // Status message
                    Text(
                      statusMessage,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // QR code with border overlay
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/images/qrborder.png',
                          height: 210,
                          width: 210,
                          fit: BoxFit.cover,
                        ),
                        QrImageView(
                          data: widget.orderKey,
                          version: QrVersions.auto,
                          size: 180,
                          backgroundColor: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Order key label
                    Text(
                      'Order Key',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.orderKey,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Back to Home button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onBackToHome,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: const Text(
                          'Back to Home',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Logo overlay at top
          Positioned(
            top: MediaQuery.of(context).size.height * 0.09,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.3,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF396cfd),
                  border: Border.fromBorderSide(
                    BorderSide(color: Colors.white, width: 1),
                  ),
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
