class Settings {
  final String id;
  final String shopName;
  final String? address;
  final String? phone;
  final double taxRate;
  final String currencySymbol;

  Settings({
    required this.id,
    required this.shopName,
    this.address,
    this.phone,
    required this.taxRate,
    required this.currencySymbol,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shop_name': shopName,
      'address': address,
      'phone': phone,
      'tax_rate': taxRate,
      'currency_symbol': currencySymbol,
    };
  }

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      id: map['id'] as String,
      shopName: map['shop_name'] as String,
      address: map['address'] as String?,
      phone: map['phone'] as String?,
      taxRate: (map['tax_rate'] as num).toDouble(),
      currencySymbol: map['currency_symbol'] as String,
    );
  }

  Settings copyWith({
    String? id,
    String? shopName,
    String? address,
    String? phone,
    double? taxRate,
    String? currencySymbol,
  }) {
    return Settings(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      taxRate: taxRate ?? this.taxRate,
      currencySymbol: currencySymbol ?? this.currencySymbol,
    );
  }
}

