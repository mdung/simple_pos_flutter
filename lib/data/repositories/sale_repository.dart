import 'package:sqflite/sqflite.dart';
import '../../models/sale.dart';
import '../../models/sale_item.dart';
import '../db/app_database.dart';

class SaleRepository {
  final AppDatabase _db = AppDatabase();

  Future<String> insertSale(Sale sale, List<SaleItem> items) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.insert('sales', sale.toMap());
      for (var item in items) {
        await txn.insert('sale_items', item.toMap());
      }
    });
    return sale.id;
  }

  Future<List<Sale>> getAllSales() async {
    final db = await _db.database;
    final maps = await db.query(
      'sales',
      orderBy: 'date_time DESC',
    );
    return maps.map((map) => Sale.fromMap(map)).toList();
  }

  Future<List<Sale>> getSalesByDate(DateTime date) async {
    final db = await _db.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final maps = await db.query(
      'sales',
      where: 'date_time >= ? AND date_time < ?',
      whereArgs: [
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String(),
      ],
      orderBy: 'date_time DESC',
    );
    return maps.map((map) => Sale.fromMap(map)).toList();
  }

  Future<Sale?> getSaleById(String id) async {
    final db = await _db.database;
    final maps = await db.query(
      'sales',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Sale.fromMap(maps.first);
  }

  Future<List<SaleItem>> getSaleItems(String saleId) async {
    final db = await _db.database;
    final maps = await db.query(
      'sale_items',
      where: 'sale_id = ?',
      whereArgs: [saleId],
      orderBy: 'product_name ASC',
    );
    return maps.map((map) => SaleItem.fromMap(map)).toList();
  }

  Future<Sale> getSaleWithItems(String id) async {
    final sale = await getSaleById(id);
    if (sale == null) {
      throw Exception('Sale not found');
    }
    final items = await getSaleItems(id);
    return Sale(
      id: sale.id,
      receiptNumber: sale.receiptNumber,
      dateTime: sale.dateTime,
      items: items,
      subtotal: sale.subtotal,
      discount: sale.discount,
      tax: sale.tax,
      total: sale.total,
      paymentType: sale.paymentType,
      amountReceived: sale.amountReceived,
      change: sale.change,
    );
  }

  Future<double> getTotalRevenueByDate(DateTime date) async {
    final db = await _db.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final result = await db.rawQuery('''
      SELECT SUM(total) as total FROM sales
      WHERE date_time >= ? AND date_time < ?
    ''', [
      startOfDay.toIso8601String(),
      endOfDay.toIso8601String(),
    ]);
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> getSalesCountByDate(DateTime date) async {
    final db = await _db.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM sales
      WHERE date_time >= ? AND date_time < ?
    ''', [
      startOfDay.toIso8601String(),
      endOfDay.toIso8601String(),
    ]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getTopProductsByDate(
    DateTime date,
    int limit,
  ) async {
    final db = await _db.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final result = await db.rawQuery('''
      SELECT 
        product_name,
        product_sku,
        SUM(quantity) as total_quantity,
        SUM(subtotal) as total_revenue
      FROM sale_items si
      INNER JOIN sales s ON si.sale_id = s.id
      WHERE s.date_time >= ? AND s.date_time < ?
      GROUP BY product_id, product_name, product_sku
      ORDER BY total_quantity DESC
      LIMIT ?
    ''', [
      startOfDay.toIso8601String(),
      endOfDay.toIso8601String(),
      limit,
    ]);
    return result;
  }
}

