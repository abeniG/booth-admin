import 'package:cloud_firestore/cloud_firestore.dart';

class SavedMedia {
  final String id;
  final String imageUrl;
  final String videoUrl;
  final DateTime createdAt;

  const SavedMedia({
    required this.id,
    required this.imageUrl,
    required this.videoUrl,
    required this.createdAt,
  });

  factory SavedMedia.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final createdAt = data['createdAt'];

    return SavedMedia(
      id: doc.id,
      imageUrl: (data['imageUrl'] ?? data['image_url'] ?? data['image'] ??
              data['photoUrl'] ?? data['photo_url'] ?? '')
          .toString(),
      videoUrl: (data['videoUrl'] ??
              data['video_url'] ??
              data['compositeVideoUrl'] ??
              data['composite_video_url'] ??
              data['video'] ??
              '')
          .toString(),
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }
}