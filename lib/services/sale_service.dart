import 'package:uuid/uuid.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../models/cart_item.dart';
import '../data/repositories/sale_repository.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/settings_repository.dart';

class SaleService {
  final SaleRepository _saleRepository = SaleRepository();
  final ProductRepository _productRepository = ProductRepository();
  final SettingsRepository _settingsRepository = SettingsRepository();
  final Uuid _uuid = const Uuid();

  Future<String> createSale({
    required List<CartItem> cartItems,
    required double discount,
    required String paymentType,
    required double amountReceived,
  }) async {
    if (cartItems.isEmpty) {
      throw Exception('Cart is empty');
    }

    final settings = await _settingsRepository.getSettings();
    final subtotal = cartItems.fold<double>(
      0.0,
      (sum, item) => sum + item.subtotal,
    );
    final discountAmount = discount;
    final afterDiscount = subtotal - discountAmount;
    final tax = afterDiscount * (settings.taxRate / 100);
    final total = afterDiscount + tax;
    final change = amountReceived - total;

    if (change < 0) {
      throw Exception('Insufficient payment');
    }

    // Generate receipt number (format: REC-YYYYMMDD-XXXXX)
    final now = DateTime.now();
    final receiptNumber = 'REC-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(7)}';

    final sale = Sale(
      id: _uuid.v4(),
      receiptNumber: receiptNumber,
      dateTime: now,
      items: [],
      subtotal: subtotal,
      discount: discountAmount,
      tax: tax,
      total: total,
      paymentType: paymentType,
      amountReceived: amountReceived,
      change: change,
    );

    final saleItems = cartItems.map((cartItem) {
      return SaleItem(
        id: _uuid.v4(),
        saleId: sale.id,
        productId: cartItem.product.id,
        productName: cartItem.product.name,
        productSku: cartItem.product.sku,
        price: cartItem.product.price,
        quantity: cartItem.quantity,
        subtotal: cartItem.subtotal,
      );
    }).toList();

    // Update product stock
    for (var cartItem in cartItems) {
      await _productRepository.updateStock(
        cartItem.product.id,
        cartItem.product.stock - cartItem.quantity,
      );
    }

    return await _saleRepository.insertSale(sale, saleItems);
  }

  Future<List<Sale>> getAllSales() async {
    return await _saleRepository.getAllSales();
  }

  Future<List<Sale>> getSalesByDate(DateTime date) async {
    return await _saleRepository.getSalesByDate(date);
  }

  Future<Sale> getSaleWithItems(String id) async {
    return await _saleRepository.getSaleWithItems(id);
  }

  Future<double> getTotalRevenueByDate(DateTime date) async {
    return await _saleRepository.getTotalRevenueByDate(date);
  }

  Future<int> getSalesCountByDate(DateTime date) async {
    return await _saleRepository.getSalesCountByDate(date);
  }

  Future<List<Map<String, dynamic>>> getTopProductsByDate(
    DateTime date,
    int limit,
  ) async {
    return await _saleRepository.getTopProductsByDate(date, limit);
  }
}

