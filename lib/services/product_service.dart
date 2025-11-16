import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../data/repositories/product_repository.dart';

class ProductService {
  final ProductRepository _repository = ProductRepository();
  final Uuid _uuid = const Uuid();

  Future<List<Product>> getAllProducts() async {
    return await _repository.getAllProducts();
  }

  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) {
      return await getAllProducts();
    }
    return await _repository.searchProducts(query);
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    return await _repository.getProductsByCategory(category);
  }

  Future<List<String>> getCategories() async {
    return await _repository.getCategories();
  }

  Future<Product?> getProductById(String id) async {
    return await _repository.getProductById(id);
  }

  Future<String> createProduct({
    required String name,
    required String sku,
    required double price,
    double? cost,
    required String category,
    required int stock,
    String? barcode,
  }) async {
    final now = DateTime.now();
    final product = Product(
      id: _uuid.v4(),
      name: name,
      sku: sku,
      price: price,
      cost: cost,
      category: category,
      stock: stock,
      barcode: barcode,
      createdAt: now,
      updatedAt: now,
    );
    return await _repository.insertProduct(product);
  }

  Future<void> updateProduct(Product product) async {
    final updatedProduct = product.copyWith(updatedAt: DateTime.now());
    await _repository.updateProduct(updatedProduct);
  }

  Future<void> deleteProduct(String id) async {
    await _repository.deleteProduct(id);
  }

  Future<void> updateStock(String id, int newStock) async {
    await _repository.updateStock(id, newStock);
  }

  Future<void> reduceStock(String id, int quantity) async {
    final product = await getProductById(id);
    if (product != null) {
      final newStock = (product.stock - quantity).clamp(0, double.infinity).toInt();
      await updateStock(id, newStock);
    }
  }
}

