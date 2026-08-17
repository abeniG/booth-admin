import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:booth_admin/models/cloudinary_resource.dart';

/// Calls the Cloudinary Search API directly with HTTP Basic Auth.
/// This works from Flutter Web because Cloudinary supports CORS on this endpoint.
class CloudinaryService {
  static const _cloudName = 'dxdrm5jjw';
  static const _apiKey = '758911877223425';
  static const _apiSecret = '-TRqKvDFSRJzQbyBYiz3hIQTTbI';

  static const _searchUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/resources/search';

  // Auth header — Basic base64(apiKey:apiSecret)
  static String get _authHeader {
    final creds = base64Encode(utf8.encode('$_apiKey:$_apiSecret'));
    return 'Basic $creds';
  }

  // ── Public API ──────────────────────────────────────────────────────────────

  static Future<List<CloudinaryResource>> fetchImages({
    int maxResults = 50,
  }) async {
    return _search(expression: 'resource_type:image', maxResults: maxResults);
  }

  static Future<List<CloudinaryResource>> fetchVideos({
    int maxResults = 30,
  }) async {
    return _search(expression: 'resource_type:video', maxResults: maxResults);
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

  static Future<List<CloudinaryResource>> _search({
    required String expression,
    required int maxResults,
  }) async {
    final uri = Uri.parse(_searchUrl);

    final requestBody = jsonEncode({
      'expression': expression,
      'sort_by': [
        {'created_at': 'desc'}
      ],
      'max_results': maxResults,
      'fields': [
        'public_id',
        'secure_url',
        'resource_type',
        'bytes',
        'created_at',
        'format',
        'width',
        'height',
        'duration',
      ],
    });

    // Print request information to console
    print('[CloudinaryService] START FETCH IMAGE/VIDEO REQUEST');
    print('[CloudinaryService] URL: $_searchUrl');
    print('[CloudinaryService] Request Method: POST');
    print('[CloudinaryService] Request Body: $requestBody');
    print(
        '[CloudinaryService] Authorization Header: Basic ${_authHeader.substring(0, 15)}...');

    http.Response response;
    try {
      response = await http.post(
        uri,
        headers: {
          'Authorization': _authHeader,
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );
    } catch (e) {
      print('[CloudinaryService] ❌ CRITICAL REQUEST ERROR: $e');
      if (e is http.ClientException) {
        print(
            '[CloudinaryService] ClientException Details: Message: ${e.message}, URI: ${e.uri}');
      }
      print(
          '[CloudinaryService] 💡 HINT: If you see "XMLHttpRequest error" in the browser logs, it means the browser is blocking this request due to CORS policies on the Cloudinary core API. You MUST use a proxy server (like a Cloudflare Worker) or run Chrome with web security disabled during development (e.g. using flutter run -d chrome --web-browser-flag "--disable-web-security").');
      rethrow;
    }

    print(
        '[CloudinaryService] Received response status: ${response.statusCode}');
    print('[CloudinaryService] Response headers: ${response.headers}');

    if (response.statusCode != 200) {
      print(
          '[CloudinaryService] ❌ Request failed with status code ${response.statusCode}');
      print('[CloudinaryService] Error Response Body: ${response.body}');
      throw Exception(
        'Cloudinary API error ${response.statusCode}: ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final resources = data['resources'] as List<dynamic>? ?? [];

    print('[CloudinaryService] Success! Parsed ${resources.length} resources.');
    return resources
        .map((r) => CloudinaryResource.fromJson(r as Map<String, dynamic>))
        .toList();
  }
}
