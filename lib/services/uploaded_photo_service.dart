import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:booth_admin/models/uploaded_photo.dart';

class UploadedPhotoService {
  static final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('uploaded_photos');

  static Future<List<UploadedPhoto>> fetchPhotos() async {
    final snapshot = await _collection
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map(UploadedPhoto.fromDoc)
        .where((photo) => photo.url.isNotEmpty)
        .toList();
  }

  static Future<void> deletePhoto(String id) {
    return _collection.doc(id).delete();
  }
}
