import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  String _searchQuery = '';
  String? _selectedCategory;

  List<Product> get products => _filteredProducts.isEmpty ? _products : _filteredProducts;
  List<Product> get allProducts => _products;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  Future<void> loadProducts() async {
    _products = await _productService.getAllProducts();
    _applyFilters();
    notifyListeners();
  }

  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredProducts = [];
      _applyFilters();
    } else {
      _filteredProducts = await _productService.searchProducts(query);
      if (_selectedCategory != null) {
        _filteredProducts = _filteredProducts
            .where((p) => p.category == _selectedCategory)
            .toList();
      }
    }
    notifyListeners();
  }

  void filterByCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    if (_searchQuery.isEmpty && _selectedCategory == null) {
      _filteredProducts = [];
      return;
    }

    _filteredProducts = _products.where((product) {
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.sku.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == null ||
          product.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _filteredProducts = [];
    notifyListeners();
  }

  Future<List<String>> getCategories() async {
    return await _productService.getCategories();
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
    final id = await _productService.createProduct(
      name: name,
      sku: sku,
      price: price,
      cost: cost,
      category: category,
      stock: stock,
      barcode: barcode,
    );
    await loadProducts();
    return id;
  }

  Future<void> updateProduct(Product product) async {
    await _productService.updateProduct(product);
    await loadProducts();
  }

  Future<void> deleteProduct(String id) async {
    await _productService.deleteProduct(id);
    await loadProducts();
  }
}

