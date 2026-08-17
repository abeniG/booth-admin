import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:booth_admin/models/cloudinary_resource.dart';
import 'package:booth_admin/services/cloudinary_service.dart';

/// Provides a list of images from Cloudinary.
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
