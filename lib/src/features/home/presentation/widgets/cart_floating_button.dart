import 'package:flutter/material.dart';
import 'package:web_ordering/src/core/theme/app_colors.dart';

/// Floating button at the bottom of the screen to view cart
class CartFloatingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final int itemCount;

  const CartFloatingButton({super.key, this.onPressed, this.itemCount = 0});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 50,
          width: MediaQuery.of(context).size.width * 0.8,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.dark,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 10),
              Text(
                "View your cart",
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
