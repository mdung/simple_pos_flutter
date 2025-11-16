import 'package:flutter/foundation.dart';
import '../models/sale.dart';
import '../services/sale_service.dart';

class SaleProvider with ChangeNotifier {
  final SaleService _saleService = SaleService();
  List<Sale> _sales = [];
  bool _isLoading = false;

  List<Sale> get sales => _sales;
  bool get isLoading => _isLoading;

  Future<void> loadSales() async {
    _isLoading = true;
    notifyListeners();
    try {
      _sales = await _saleService.getAllSales();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSalesByDate(DateTime date) async {
    _isLoading = true;
    notifyListeners();
    try {
      _sales = await _saleService.getSalesByDate(date);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Sale> getSaleWithItems(String id) async {
    return await _saleService.getSaleWithItems(id);
  }

  Future<double> getTotalRevenueByDate(DateTime date) async {
    return await _saleService.getTotalRevenueByDate(date);
  }

  Future<int> getSalesCountByDate(DateTime date) async {
    return await _saleService.getSalesCountByDate(date);
  }

  Future<List<Map<String, dynamic>>> getTopProductsByDate(
    DateTime date,
    int limit,
  ) async {
    return await _saleService.getTopProductsByDate(date, limit);
  }
}

