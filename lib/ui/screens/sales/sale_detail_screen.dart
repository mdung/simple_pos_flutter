import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/sale_provider.dart';
import '../../../providers/settings_provider.dart';

class SaleDetailScreen extends StatefulWidget {
  final String saleId;

  const SaleDetailScreen({Key? key, required this.saleId}) : super(key: key);

  @override
  State<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends State<SaleDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.saleDetails),
      ),
      body: FutureBuilder(
        future: Provider.of<SaleProvider>(context, listen: false)
            .getSaleWithItems(widget.saleId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Sale not found'));
          }

          final sale = snapshot.data!;
          final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
          final currencySymbol = settingsProvider.settings?.currencySymbol ?? '\$';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${AppStrings.date}: ${Formatters.formatDate(sale.dateTime)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${AppStrings.time}: ${Formatters.formatTime(sale.dateTime)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${AppStrings.paymentType}: ${sale.paymentType}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  AppStrings.items,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...sale.items.map((item) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(item.productName),
                        subtitle: Text('SKU: ${item.productSku}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${item.quantity} x ${Formatters.formatCurrency(item.price, symbol: currencySymbol)}',
                              style: const TextStyle(fontSize: 12),
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
                      ),
                    )),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
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
                        const Divider(height: 24),
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
                        if (sale.paymentType == 'Cash') ...[
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                AppStrings.amountReceived,
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                Formatters.formatCurrency(sale.amountReceived, symbol: currencySymbol),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                AppStrings.change,
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                Formatters.formatCurrency(sale.change, symbol: currencySymbol),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

