import 'package:cloud_firestore/cloud_firestore.dart';

class Printable {
  final String id;
  final int amountToPrint;
  final int copies;
  final String imageUrl;
  final int pages;
  final double printHeightInches;
  final String printSize;
  final double printWidthInches;
  final String status;
  final double price;

  const Printable({
    required this.id,
    required this.amountToPrint,
    required this.copies,
    required this.imageUrl,
    required this.pages,
    required this.printHeightInches,
    required this.printSize,
    required this.printWidthInches,
    required this.status,
    required this.price,
  });

  factory Printable.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return Printable(
      id: doc.id,
      amountToPrint: _intValue(
        data['amountToPrint'] ??
            data['amount_to_print'] ??
            data['amount to print'],
        fallback: 1,
      ),
      copies: _intValue(data['copies'], fallback: 1),
      imageUrl: (data['imageUrl'] ?? data['image_url'] ?? '').toString(),
      pages: _intValue(data['pages'], fallback: 1),
      printHeightInches: _doubleValue(
          data['printHeightInches'] ?? data['print_height_inches']),
      printSize: (data['printSize'] ?? data['print_size'] ?? '').toString(),
      printWidthInches:
          _doubleValue(data['printWidthInches'] ?? data['print_width_inches']),
      status: (data['status'] ?? 'pending').toString().toLowerCase(),
      price: _doubleValue(data['price'], fallback: 400),
    );
  }

  static int _intValue(Object? value, {int fallback = 0}) {
    return value is num ? value.toInt() : int.tryParse('$value') ?? fallback;
  }

  static double _doubleValue(Object? value, {double fallback = 0}) {
    return value is num
        ? value.toDouble()
        : double.tryParse('$value') ?? fallback;
  }
}
