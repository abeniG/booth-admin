import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:booth_admin/models/cloudinary_resource.dart';
import 'package:booth_admin/models/uploaded_photo.dart';
import 'package:booth_admin/services/cloudinary_service.dart';
import 'package:booth_admin/services/uploaded_photo_service.dart';

/// Provides uploaded photos from Firestore.
final uploadedPhotosProvider = FutureProvider<List<UploadedPhoto>>((ref) async {
  return UploadedPhotoService.fetchPhotos();
});

/// Provides a list of images from Cloudinary for Cloudinary-only consumers.
final cloudinaryPhotosProvider =
    FutureProvider<List<CloudinaryResource>>((ref) async {
  return CloudinaryService.fetchImages(maxResults: 50);
});

/// Provides a list of videos from Cloudinary.
final cloudinaryVideosProvider =
    FutureProvider<List<CloudinaryResource>>((ref) async {
  return CloudinaryService.fetchVideos(maxResults: 30);
});

/// Provides aggregate media statistics.
final cloudinaryStatsProvider = FutureProvider<CloudinaryStats>((ref) async {
  return CloudinaryService.fetchStats();
});
