import 'package:cloud_firestore/cloud_firestore.dart';

class PrintPrice {
  final String printableId;
  final double amount;

  const PrintPrice({
    required this.printableId,
    required this.amount,
  });

  factory PrintPrice.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final printableId = (data['printableId'] ?? doc.id).toString();
    final value = data['amount'] ?? data['price'];

    return PrintPrice(
      printableId: printableId,
      amount:
          value is num ? value.toDouble() : double.tryParse('$value') ?? 400,
    );
  }
}
