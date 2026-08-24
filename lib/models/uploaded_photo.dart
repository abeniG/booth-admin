import 'package:cloud_firestore/cloud_firestore.dart';

class UploadedPhoto {
  final String id;
  final String name;
  final String url;
  final DateTime createdAt;
  final int bytes;

  const UploadedPhoto({
    required this.id,
    required this.name,
    required this.url,
    required this.createdAt,
    this.bytes = 0,
  });

  factory UploadedPhoto.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final createdAt = data['createdAt'];

    return UploadedPhoto(
      id: doc.id,
      name: (data['name'] ?? doc.id).toString(),
      url: (data['url'] ?? '').toString(),
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
      bytes: (data['bytes'] as num?)?.toInt() ?? 0,
    );
  }

  String get formattedSize {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
