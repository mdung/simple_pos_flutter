import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/sale.dart';
import '../../../providers/settings_provider.dart';

class ReceiptScreen extends StatelessWidget {
  final Sale sale;

  const ReceiptScreen({Key? key, required this.sale}) : super(key: key);

  String _generateReceiptText(Sale sale, SettingsProvider settingsProvider) {
    final settings = settingsProvider.settings;
    final currencySymbol = settings?.currencySymbol ?? '\$';
    final shopName = settings?.shopName ?? 'My Shop';
    final address = settings?.address ?? '';
    final phone = settings?.phone ?? '';

    final buffer = StringBuffer();
    buffer.writeln(shopName);
    if (address.isNotEmpty) buffer.writeln(address);
    if (phone.isNotEmpty) buffer.writeln('Phone: $phone');
    buffer.writeln('=' * 40);
    buffer.writeln('Receipt #: ${sale.receiptNumber}');
    buffer.writeln('Date: ${Formatters.formatDateTime(sale.dateTime)}');
    buffer.writeln('=' * 40);
    buffer.writeln('');

    for (var item in sale.items) {
      buffer.writeln('${item.productName}');
      buffer.writeln('  ${item.quantity} x ${Formatters.formatCurrency(item.price, symbol: currencySymbol)} = ${Formatters.formatCurrency(item.subtotal, symbol: currencySymbol)}');
    }

    buffer.writeln('');
    buffer.writeln('-' * 40);
    buffer.writeln('Subtotal: ${Formatters.formatCurrency(sale.subtotal, symbol: currencySymbol)}');
    if (sale.discount > 0) {
      buffer.writeln('Discount: -${Formatters.formatCurrency(sale.discount, symbol: currencySymbol)}');
    }
    if (sale.tax > 0) {
      buffer.writeln('Tax: ${Formatters.formatCurrency(sale.tax, symbol: currencySymbol)}');
    }
    buffer.writeln('=' * 40);
    buffer.writeln('TOTAL: ${Formatters.formatCurrency(sale.total, symbol: currencySymbol)}');
    buffer.writeln('');
    buffer.writeln('Payment: ${sale.paymentType}');
    if (sale.paymentType == 'Cash') {
      buffer.writeln('Received: ${Formatters.formatCurrency(sale.amountReceived, symbol: currencySymbol)}');
      buffer.writeln('Change: ${Formatters.formatCurrency(sale.change, symbol: currencySymbol)}');
    }
    buffer.writeln('');
    buffer.writeln('=' * 40);
    buffer.writeln('Thank you for your business!');
    buffer.writeln('');

    return buffer.toString();
  }

  Future<void> _shareReceipt(BuildContext context) async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final receiptText = _generateReceiptText(sale, settingsProvider);
    await Share.share(receiptText, subject: 'Receipt ${sale.receiptNumber}');
  }

  Future<void> _copyReceipt(BuildContext context) async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final receiptText = _generateReceiptText(sale, settingsProvider);
    await Clipboard.setData(ClipboardData(text: receiptText));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receipt copied to clipboard'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareReceipt(context),
            tooltip: 'Share Receipt',
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _copyReceipt(context),
            tooltip: 'Copy Receipt',
          ),
        ],
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          final settings = settingsProvider.settings;
          final currencySymbol = settings?.currencySymbol ?? '\$';
          final shopName = settings?.shopName ?? 'My Shop';
          final address = settings?.address ?? '';
          final phone = settings?.phone ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Shop Header
                    Text(
                      shopName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (address.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        address,
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Phone: $phone',
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const Divider(height: 32),
                    // Receipt Info
                    Text(
                      'Receipt #: ${sale.receiptNumber}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.formatDateTime(sale.dateTime),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const Divider(height: 32),
                    // Items
                    ...sale.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'SKU: ${item.productSku}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${item.quantity} x ${Formatters.formatCurrency(item.price, symbol: currencySymbol)}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    Formatters.formatCurrency(item.subtotal, symbol: currencySymbol),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                    const Divider(height: 24),
                    // Totals
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          AppStrings.subtotal,
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          Formatters.formatCurrency(sale.subtotal, symbol: currencySymbol),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    if (sale.discount > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            AppStrings.discount,
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '-${Formatters.formatCurrency(sale.discount, symbol: currencySymbol)}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (sale.tax > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            AppStrings.tax,
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            Formatters.formatCurrency(sale.tax, symbol: currencySymbol),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          AppStrings.total,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(sale.total, symbol: currencySymbol),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Payment Info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Payment Type:',
                                style: TextStyle(fontSize: 14),
                              ),
                              Text(
                                sale.paymentType,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          if (sale.paymentType == 'Cash') ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  AppStrings.amountReceived,
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  Formatters.formatCurrency(sale.amountReceived, symbol: currencySymbol),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  AppStrings.change,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  Formatters.formatCurrency(sale.change, symbol: currencySymbol),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Thank you for your business!',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

