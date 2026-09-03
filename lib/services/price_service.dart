import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:booth_admin/models/price.dart';

class PriceService {
  static final DocumentReference<Map<String, dynamic>> _document =
      FirebaseFirestore.instance.collection('price').doc('default');

  static Stream<Price> streamPrice() {
    return _document.snapshots().map(Price.fromDoc);
  }

  static Future<void> updatePrice(double amount) {
    return _document.set({'amount': amount}, SetOptions(merge: true));
  }
}
