import 'cart_item.dart';

class TransactionModel {
  final String id;
  final DateTime date;
  final List<CartItem> items;
  final int total;
  final int cash;
  final int change;

  TransactionModel({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.cash,
    required this.change,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      items: (json['items'] as List)
          .map((e) => CartItem.fromJson(e))
          .toList(),
      total: json['total'],
      cash: json['cash'],
      change: json['change'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
        'total': total,
        'cash': cash,
        'change': change,
      };
}
