import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:booth_admin/models/printable.dart';

class PrintableService {
  static final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('printables');

  static Stream<List<Printable>> streamPrintables() {
    return _collection
        .orderBy('status')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Printable.fromDoc).toList());
  }

  static Future<void> markAsSuccess(String id) {
    return _collection.doc(id).update({'status': 'success'});
  }

  static Future<void> updatePrice(String id, double price) {
    return _collection.doc(id).update({'price': price});
  }
}
