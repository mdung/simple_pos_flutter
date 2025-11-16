import 'package:sqflite/sqflite.dart';
import '../../models/product.dart';
import '../db/app_database.dart';

class ProductRepository {
  final AppDatabase _db = AppDatabase();

  Future<List<Product>> getAllProducts() async {
    final db = await _db.database;
    final maps = await db.query('products', orderBy: 'name ASC');
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await _db.database;
    final maps = await db.query(
      'products',
      where: 'name LIKE ? OR sku LIKE ? OR barcode LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final db = await _db.database;
    final maps = await db.query(
      'products',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<List<String>> getCategories() async {
    final db = await _db.database;
    final maps = await db.rawQuery('SELECT DISTINCT category FROM products ORDER BY category');
    return maps.map((map) => map['category'] as String).toList();
  }

  Future<Product?> getProductById(String id) async {
    final db = await _db.database;
    final maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  Future<Product?> getProductBySku(String sku) async {
    final db = await _db.database;
    final maps = await db.query(
      'products',
      where: 'sku = ?',
      whereArgs: [sku],
    );
    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  Future<String> insertProduct(Product product) async {
    final db = await _db.database;
    await db.insert('products', product.toMap());
    return product.id;
  }

  Future<void> updateProduct(Product product) async {
    final db = await _db.database;
    await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> deleteProduct(String id) async {
    final db = await _db.database;
    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateStock(String id, int newStock) async {
    final db = await _db.database;
    await db.update(
      'products',
      {'stock': newStock},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

