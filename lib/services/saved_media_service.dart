import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:booth_admin/models/saved_media.dart';

class SavedMediaService {
  static final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('saved');

  static Stream<List<SavedMedia>> streamSavedMedia() {
    return _collection.snapshots().map((snapshot) => snapshot.docs
        .map(SavedMedia.fromDoc)
        .where((media) => media.imageUrl.isNotEmpty)
        .toList());
  }
}