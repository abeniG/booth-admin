class CloudinaryResource {
  final String publicId;
  final String secureUrl;
  final String resourceType; // 'image' or 'video'
  final int bytes;
  final DateTime createdAt;
  final String? format;
  final int? width;
  final int? height;
  final double? duration; // seconds, videos only

  const CloudinaryResource({
    required this.publicId,
    required this.secureUrl,
    required this.resourceType,
    required this.bytes,
    required this.createdAt,
    this.format,
    this.width,
    this.height,
    this.duration,
  });

  factory CloudinaryResource.fromJson(Map<String, dynamic> json) {
    return CloudinaryResource(
      publicId: json['public_id'] as String,
      secureUrl: json['secure_url'] as String,
      resourceType: json['resource_type'] as String? ?? 'image',
      bytes: json['bytes'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      format: json['format'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      duration: (json['duration'] as num?)?.toDouble(),
    );
  }

  /// Returns a human-readable file size string.
  String get formattedSize {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Returns a Cloudinary thumbnail URL for videos (converts first frame to JPEG).
  String get thumbnailUrl {
    if (resourceType == 'video') {
      return secureUrl.replaceFirst(
          '/video/upload/', '/video/upload/f_jpg,so_0/');
    }
    return secureUrl;
  }

  /// Returns a formatted duration string for videos (e.g. "0:15").
  String get formattedDuration {
    if (duration == null) return '';
    final secs = duration!.round();
    final m = secs ~/ 60;
    final s = secs % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

class CloudinaryStats {
  final int totalPhotos;
  final int totalVideos;

  const CloudinaryStats({required this.totalPhotos, required this.totalVideos});
}
