import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/sale_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../services/sale_service.dart';
import '../../sales/receipt_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _amountController = TextEditingController();
  final _saleService = SaleService();
  bool _isProcessing = false;
  String _paymentType = 'Cash';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _completeSale() async {
    if (_isProcessing) return;

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    if (cartProvider.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cart is empty'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final settings = settingsProvider.settings;
    final currencySymbol = settings?.currencySymbol ?? '\$';
    final taxRate = settings?.taxRate ?? 0.0;

    final subtotal = cartProvider.subtotal;
    final discount = cartProvider.discount;
    final afterDiscount = subtotal - discount;
    final tax = afterDiscount * (taxRate / 100);
    final total = afterDiscount + tax;

    double amountReceived;
    if (_paymentType == 'Cash') {
      final amountText = _amountController.text.trim();
      if (amountText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter amount received'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      amountReceived = double.tryParse(amountText) ?? 0.0;
      if (amountReceived < total) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insufficient payment'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    } else {
      amountReceived = total;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final saleId = await _saleService.createSale(
        cartItems: cartProvider.items,
        discount: discount,
        paymentType: _paymentType,
        amountReceived: amountReceived,
      );

      cartProvider.clear();

      if (mounted) {
        // Get the complete sale with items
        final saleProvider = Provider.of<SaleProvider>(context, listen: false);
        final sale = await saleProvider.getSaleWithItems(saleId);

        // Navigate to receipt screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ReceiptScreen(sale: sale),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.payment),
      ),
      body: Consumer2<CartProvider, SettingsProvider>(
        builder: (context, cartProvider, settingsProvider, child) {
          final settings = settingsProvider.settings;
          final currencySymbol = settings?.currencySymbol ?? '\$';
          final taxRate = settings?.taxRate ?? 0.0;

          final subtotal = cartProvider.subtotal;
          final discount = cartProvider.discount;
          final afterDiscount = subtotal - discount;
          final tax = afterDiscount * (taxRate / 100);
          final total = afterDiscount + tax;
          final change = _amountController.text.isNotEmpty
              ? (double.tryParse(_amountController.text) ?? 0.0) - total
              : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              AppStrings.subtotal,
                              style: TextStyle(fontSize: 16),
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
                        if (discount > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                AppStrings.discount,
                                style: TextStyle(fontSize: 16),
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
                        ],
                        if (taxRate > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${AppStrings.tax} (${taxRate.toStringAsFixed(1)}%)',
                                style: const TextStyle(fontSize: 16),
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
                            const Text(
                              AppStrings.total,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Payment Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'Cash',
                      label: Text('Cash'),
                      icon: Icon(Icons.money),
                    ),
                    ButtonSegment(
                      value: 'Card',
                      label: Text('Card'),
                      icon: Icon(Icons.credit_card),
                    ),
                  ],
                  selected: {_paymentType},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _paymentType = newSelection.first;
                      if (_paymentType == 'Card') {
                        _amountController.text = total.toStringAsFixed(2);
                      }
                    });
                  },
                ),
                const SizedBox(height: 24),
                if (_paymentType == 'Cash') ...[
                  TextField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: AppStrings.amountReceived,
                      hintText: 'Enter amount',
                      prefixText: currencySymbol,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  if (change >= 0) ...[
                    const SizedBox(height: 16),
                    Card(
                      color: AppColors.success.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              AppStrings.change,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              Formatters.formatCurrency(change, symbol: currencySymbol),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (_amountController.text.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Card(
                      color: AppColors.error.withOpacity(0.1),
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Insufficient payment',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isProcessing ? null : _completeSale,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
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
      ),
    );
  }
}

