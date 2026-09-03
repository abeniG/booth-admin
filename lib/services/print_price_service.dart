import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:booth_admin/models/print_price.dart';

class PrintPriceService {
  static final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('prices');

  static Stream<List<PrintPrice>> streamPrices() {
    return _collection.snapshots().map(
          (snapshot) => snapshot.docs.map(PrintPrice.fromDoc).toList(),
        );
  }

  static Future<void> updatePrice(String printableId, double amount) {
    return _collection.doc(printableId).set({
      'printableId': printableId,
      'amount': amount,
    }, SetOptions(merge: true));
  }
}
