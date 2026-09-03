import 'package:cloud_firestore/cloud_firestore.dart';

class DesignAsset {
  final String id;
  final String name;
  final String url;
  final bool enabled;
  final DateTime? createdAt;

  const DesignAsset({
    required this.id,
    required this.name,
    required this.url,
    required this.enabled,
    this.createdAt,
  });

  factory DesignAsset.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return DesignAsset(
      id: doc.id,
      name: (data['name'] ?? '').toString(),
      url: (data['url'] ?? '').toString(),
      enabled: data['enabled'] == true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

class DesignAssetService {
  static String _collectionName(String itemType) {
    switch (itemType.toLowerCase()) {
      case 'sticker':
        return 'stickers';
      case 'background':
        return 'backgrounds';
      case 'filter':
        return 'filters';
      case 'cover page':
        return 'cover_pages';
      default:
        return '${itemType.toLowerCase()}s';
    }
  }

  static CollectionReference<Map<String, dynamic>> _collection(
      String itemType) {
    return FirebaseFirestore.instance.collection(_collectionName(itemType));
  }

  static Stream<List<DesignAsset>> streamAssets(String itemType) {
    return _collection(itemType)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => DesignAsset.fromDoc(doc)).toList());
  }

  static Future<void> saveAsset({
    required String itemType,
    required String name,
    required String url,
    required bool enabled,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty || url.isEmpty) {
      throw Exception('Asset name and URL are required.');
    }

    await _collection(itemType).add({
      'name': trimmedName,
      'url': url,
      'enabled': enabled,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateEnabled(
    String itemType,
    String id,
    bool enabled,
  ) async {
    await _collection(itemType).doc(id).update({'enabled': enabled});
  }

  static Future<void> deleteAsset(String itemType, String id) async {
    await _collection(itemType).doc(id).delete();
  }
}
