import 'package:cloud_firestore/cloud_firestore.dart';

class Price {
  final double amount;

  const Price({required this.amount});

  factory Price.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final value = doc.data()?['amount'];
    return Price(
      amount:
          value is num ? value.toDouble() : double.tryParse('$value') ?? 400,
    );
  }
}
