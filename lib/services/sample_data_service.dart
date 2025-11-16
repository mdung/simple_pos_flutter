import '../services/product_service.dart';
import '../services/auth_service.dart';

class SampleDataService {
  final ProductService _productService = ProductService();
  final AuthService _authService = AuthService();

  Future<void> initializeSampleData() async {
    // Create default user if not exists
    await _authService.createDefaultUser();

    // Check if products already exist
    final existingProducts = await _productService.getAllProducts();
    if (existingProducts.isNotEmpty) {
      return; // Sample data already exists
    }

    // Add sample products
    final sampleProducts = [
      {
        'name': 'Coca Cola 500ml',
        'sku': 'COKE-500',
        'price': 2.50,
        'cost': 1.50,
        'category': 'Beverages',
        'stock': 100,
        'barcode': '1234567890123',
      },
      {
        'name': 'Bread White',
        'sku': 'BREAD-WH',
        'price': 3.00,
        'cost': 1.80,
        'category': 'Food',
        'stock': 50,
        'barcode': '1234567890124',
      },
      {
        'name': 'Milk 1L',
        'sku': 'MILK-1L',
        'price': 4.50,
        'cost': 3.00,
        'category': 'Dairy',
        'stock': 75,
        'barcode': '1234567890125',
      },
      {
        'name': 'Eggs Dozen',
        'sku': 'EGGS-12',
        'price': 5.00,
        'cost': 3.50,
        'category': 'Dairy',
        'stock': 30,
        'barcode': '1234567890126',
      },
      {
        'name': 'Rice 1kg',
        'sku': 'RICE-1KG',
        'price': 6.00,
        'cost': 4.00,
        'category': 'Food',
        'stock': 40,
        'barcode': '1234567890127',
      },
      {
        'name': 'Water Bottle 500ml',
        'sku': 'WATER-500',
        'price': 1.50,
        'cost': 0.80,
        'category': 'Beverages',
        'stock': 150,
        'barcode': '1234567890128',
      },
      {
        'name': 'Chocolate Bar',
        'sku': 'CHOC-BAR',
        'price': 2.00,
        'cost': 1.20,
        'category': 'Snacks',
        'stock': 80,
        'barcode': '1234567890129',
      },
      {
        'name': 'Soap Bar',
        'sku': 'SOAP-BAR',
        'price': 3.50,
        'cost': 2.00,
        'category': 'Personal Care',
        'stock': 60,
        'barcode': '1234567890130',
      },
    ];

    for (var product in sampleProducts) {
      await _productService.createProduct(
        name: product['name'] as String,
        sku: product['sku'] as String,
        price: product['price'] as double,
        cost: product['cost'] as double,
        category: product['category'] as String,
        stock: product['stock'] as int,
        barcode: product['barcode'] as String,
      );
    }
  }
}

