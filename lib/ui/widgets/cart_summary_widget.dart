import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../providers/cart_provider.dart';
import '../../providers/settings_provider.dart';
import 'package:provider/provider.dart';

class CartSummaryWidget extends StatelessWidget {
  final VoidCallback? onCompleteSale;
  final VoidCallback? onApplyDiscount;

  const CartSummaryWidget({
    Key? key,
    this.onCompleteSale,
    this.onApplyDiscount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<CartProvider, SettingsProvider>(
      builder: (context, cartProvider, settingsProvider, child) {
        final settings = settingsProvider.settings;
        final currencySymbol = settings?.currencySymbol ?? '\$';
        final taxRate = settings?.taxRate ?? 0.0;

        final subtotal = cartProvider.subtotal;
        final discount = cartProvider.discount;
        final afterDiscount = subtotal - discount;
        final tax = afterDiscount * (taxRate / 100);
        final total = afterDiscount + tax;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cartBackground,
            border: const Border(
              top: BorderSide(color: AppColors.borderColor),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.subtotal,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    Formatters.formatCurrency(subtotal, symbol: currencySymbol),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.discount,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '-${Formatters.formatCurrency(discount, symbol: currencySymbol)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
              if (taxRate > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${AppStrings.tax} (${taxRate.toStringAsFixed(1)}%)',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(tax, symbol: currencySymbol),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.total,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    Formatters.formatCurrency(total, symbol: currencySymbol),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (onApplyDiscount != null)
                OutlinedButton(
                  onPressed: onApplyDiscount,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(AppStrings.discount),
                ),
              const SizedBox(height: 8),
              if (onCompleteSale != null)
                ElevatedButton(
                  onPressed: cartProvider.isEmpty ? null : onCompleteSale,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    AppStrings.completeSale,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

