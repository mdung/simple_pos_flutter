import 'sale_item.dart';

class Sale {
  final String id;
  final String receiptNumber;
  final DateTime dateTime;
  final List<SaleItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final String paymentType;
  final double amountReceived;
  final double change;

  Sale({
    required this.id,
    required this.receiptNumber,
    required this.dateTime,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.paymentType,
    required this.amountReceived,
    required this.change,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'receipt_number': receiptNumber,
      'date_time': dateTime.toIso8601String(),
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'total': total,
      'payment_type': paymentType,
      'amount_received': amountReceived,
      'change': change,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] as String,
      receiptNumber: map['receipt_number'] as String? ?? map['id'] as String,
      dateTime: DateTime.parse(map['date_time'] as String),
      items: [], // Items loaded separately
      subtotal: (map['subtotal'] as num).toDouble(),
      discount: (map['discount'] as num).toDouble(),
      tax: (map['tax'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      paymentType: map['payment_type'] as String,
      amountReceived: (map['amount_received'] as num).toDouble(),
      change: (map['change'] as num).toDouble(),
    );
  }
}

