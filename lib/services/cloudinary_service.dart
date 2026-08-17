import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:booth_admin/models/cloudinary_resource.dart';

/// Calls the Cloudinary Search API directly with HTTP Basic Auth.
/// This works from Flutter Web because Cloudinary supports CORS on this endpoint.
class CloudinaryService {
  // Use relative path so it hits same-origin API deployments by default.
  // When running locally in debug, points to `wrangler dev` running on port 8787.
  static String get _baseUrl => kDebugMode ? 'http://localhost:8787' : '';

  static Future<List<CloudinaryResource>> fetchImages({
    int maxResults = 50,
  }) async {
    return _get('$_baseUrl/api/cloudinary/images');
  }

  static Future<List<CloudinaryResource>> fetchVideos({
    int maxResults = 30,
  }) async {
    return _get('$_baseUrl/api/cloudinary/videos');
  }

  static Future<CloudinaryStats> fetchStats() async {
    final results = await Future.wait([
      fetchImages(maxResults: 50),
      fetchVideos(maxResults: 30),
    ]);
    return CloudinaryStats(
      totalPhotos: results[0].length,
      totalVideos: results[1].length,
    );
  }

  // ── Private ─────────────────────────────────────────────────────────────────

  static Future<List<CloudinaryResource>> _get(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception(
        'Cloudinary proxy error ${response.statusCode}: ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final resources = data['resources'] as List<dynamic>? ?? [];

    return resources
        .map((r) => CloudinaryResource.fromJson(r as Map<String, dynamic>))
        .toList();
  }
}
