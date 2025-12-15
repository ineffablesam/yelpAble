class YelpBusiness {
  final String id;
  final String name;
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final List<String> categories;
  final String? price;

  final double? latitude;
  final double? longitude;

  final String? phone;
  final String? url;
  final String? formattedAddress;

  final double? distance;
  final bool isClosed;

  YelpBusiness({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.categories,
    this.price,
    this.latitude,
    this.longitude,
    this.phone,
    this.url,
    this.formattedAddress,
    this.distance,
    required this.isClosed,
  });

  factory YelpBusiness.fromJson(Map<String, dynamic> json) {
    return YelpBusiness(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['image_url'],
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      categories:
          (json['categories'] as List?)
              ?.map((e) => e['title'] as String)
              .toList() ??
          [],
      price: json['price'],

      latitude: json['coordinates']?['latitude']?.toDouble(),
      longitude: json['coordinates']?['longitude']?.toDouble(),

      phone: json['display_phone'] ?? json['phone'],
      url: json['url'],

      formattedAddress: (json['location']?['display_address'] as List?)?.join(
        ', ',
      ),

      distance: json['distance']?.toDouble(),
      isClosed: json['is_closed'] ?? false,
    );
  }
}
