/// Domain model for ad/marketing banner (Sanity adBanner type).
class AdBanner {
  final String id;
  final String? headline;
  final String? imageUrl;
  final String? callToAction;
  final bool active;

  const AdBanner({
    required this.id,
    this.headline,
    this.imageUrl,
    this.callToAction,
    this.active = true,
  });

  factory AdBanner.fromMap(Map<String, dynamic> map) {
    String? imageUrl;
    final img = map['image'];
    if (img is Map && img['asset'] != null && img['asset']['url'] != null) imageUrl = img['asset']['url'] as String?;

    return AdBanner(
      id: map['_id'] as String? ?? '',
      headline: map['headline'] as String?,
      imageUrl: imageUrl,
      callToAction: map['callToAction'] as String?,
      active: map['active'] as bool? ?? true,
    );
  }
}
