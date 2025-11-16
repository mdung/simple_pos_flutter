import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/sale_provider.dart';
import '../../../providers/settings_provider.dart';
import 'sale_detail_screen.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({Key? key}) : super(key: key);

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSales();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSales() async {
    final provider = Provider.of<SaleProvider>(context, listen: false);
    if (_startDate != null && _endDate != null) {
      // Load sales by date range
      final allSales = await provider.getAllSales();
      final filtered = allSales.where((sale) {
        final saleDate = DateTime(sale.dateTime.year, sale.dateTime.month, sale.dateTime.day);
        final start = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
        final end = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
        return saleDate.isAfter(start.subtract(const Duration(days: 1))) &&
            saleDate.isBefore(end.add(const Duration(days: 1)));
      }).toList();
      // Note: This is a workaround since we don't have getSalesByDateRange in repository
      // In production, you'd add that method
    } else {
      await provider.loadSales();
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      await _loadSales();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _loadSales();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.salesHistory),
        actions: [
          if (_startDate != null && _endDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearDateFilter,
              tooltip: 'Clear Date Filter',
            ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
            tooltip: 'Filter by Date Range',
          ),
        ],
      ),
      body: Consumer2<SaleProvider, SettingsProvider>(
        builder: (context, saleProvider, settingsProvider, child) {
          final currencySymbol = settingsProvider.settings?.currencySymbol ?? '\$';

          // Filter sales by date range if set
          List<Sale> displayedSales = saleProvider.sales;
          if (_startDate != null && _endDate != null) {
            displayedSales = saleProvider.sales.where((sale) {
              final saleDate = DateTime(sale.dateTime.year, sale.dateTime.month, sale.dateTime.day);
              final start = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
              final end = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
              return saleDate.isAfter(start.subtract(const Duration(days: 1))) &&
                  saleDate.isBefore(end.add(const Duration(days: 1)));
            }).toList();
          }

          // Filter by search query
          if (_searchController.text.isNotEmpty) {
            final query = _searchController.text.toLowerCase();
            displayedSales = displayedSales.where((sale) {
              return sale.receiptNumber.toLowerCase().contains(query) ||
                  Formatters.formatDateTime(sale.dateTime).toLowerCase().contains(query) ||
                  sale.paymentType.toLowerCase().contains(query);
            }).toList();
          }

          if (saleProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (displayedSales.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.noSales,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by receipt number, date, or payment type...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              // Date Range Display
              if (_startDate != null && _endDate != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Chip(
                    label: Text(
                      '${Formatters.formatDate(_startDate!)} - ${Formatters.formatDate(_endDate!)}',
                    ),
                    onDeleted: _clearDateFilter,
                  ),
                ),
              // Sales List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadSales,
                  child: ListView.builder(
                    itemCount: displayedSales.length,
                    itemBuilder: (context, index) {
                      final sale = displayedSales[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: const Icon(Icons.receipt, color: Colors.white),
                    ),
                    title: Text(
                      sale.receiptNumber,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(Formatters.formatDateTime(sale.dateTime)),
                        Text('${AppStrings.paymentType}: ${sale.paymentType}'),
                        Text('${AppStrings.items}: ${sale.items.length}'),
                      ],
                    ),
                    trailing: Text(
                      Formatters.formatCurrency(sale.total, symbol: currencySymbol),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SaleDetailScreen(saleId: sale.id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

