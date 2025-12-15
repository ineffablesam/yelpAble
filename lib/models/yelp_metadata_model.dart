import 'dart:convert';

class Welcome {
  List<YelpTag>? yelpTags;
  List<String>? yelpTypes;
  List<YelpEntity>? yelpEntities;

  Welcome({this.yelpTags, this.yelpTypes, this.yelpEntities});

  Welcome copyWith({
    List<YelpTag>? yelpTags,
    List<String>? yelpTypes,
    List<YelpEntity>? yelpEntities,
  }) => Welcome(
    yelpTags: yelpTags ?? this.yelpTags,
    yelpTypes: yelpTypes ?? this.yelpTypes,
    yelpEntities: yelpEntities ?? this.yelpEntities,
  );

  factory Welcome.fromJson(String str) => Welcome.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Welcome.fromMap(Map<String, dynamic> json) => Welcome(
    yelpTags: json["yelp_tags"] == null
        ? []
        : List<YelpTag>.from(json["yelp_tags"]!.map((x) => YelpTag.fromMap(x))),
    yelpTypes: json["yelp_types"] == null
        ? []
        : List<String>.from(json["yelp_types"]!.map((x) => x)),
    yelpEntities: json["yelp_entities"] == null
        ? []
        : List<YelpEntity>.from(
            json["yelp_entities"]!.map((x) => YelpEntity.fromMap(x)),
          ),
  );

  Map<String, dynamic> toMap() => {
    "yelp_tags": yelpTags == null
        ? []
        : List<dynamic>.from(yelpTags!.map((x) => x.toMap())),
    "yelp_types": yelpTypes == null
        ? []
        : List<dynamic>.from(yelpTypes!.map((x) => x)),
    "yelp_entities": yelpEntities == null
        ? []
        : List<dynamic>.from(yelpEntities!.map((x) => x.toMap())),
  };
}

class YelpEntity {
  List<Business>? businesses;

  YelpEntity({this.businesses});

  YelpEntity copyWith({List<Business>? businesses}) =>
      YelpEntity(businesses: businesses ?? this.businesses);

  factory YelpEntity.fromJson(String str) =>
      YelpEntity.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory YelpEntity.fromMap(Map<String, dynamic> json) => YelpEntity(
    businesses: json["businesses"] == null
        ? []
        : List<Business>.from(
            json["businesses"]!.map((x) => Business.fromMap(x)),
          ),
  );

  Map<String, dynamic> toMap() => {
    "businesses": businesses == null
        ? []
        : List<dynamic>.from(businesses!.map((x) => x.toMap())),
  };
}

class Business {
  String? id;
  String? url;
  String? name;
  String? alias;
  String? phone;
  String? price;
  double? rating;
  Location? location;
  Summaries? summaries;
  Attributes? attributes;
  List<Category>? categories;
  Coordinates? coordinates;
  int? reviewCount;
  ContextualInfo? contextualInfo;

  Business({
    this.id,
    this.url,
    this.name,
    this.alias,
    this.phone,
    this.price,
    this.rating,
    this.location,
    this.summaries,
    this.attributes,
    this.categories,
    this.coordinates,
    this.reviewCount,
    this.contextualInfo,
  });

  Business copyWith({
    String? id,
    String? url,
    String? name,
    String? alias,
    String? phone,
    String? price,
    double? rating,
    Location? location,
    Summaries? summaries,
    Attributes? attributes,
    List<Category>? categories,
    Coordinates? coordinates,
    int? reviewCount,
    ContextualInfo? contextualInfo,
  }) => Business(
    id: id ?? this.id,
    url: url ?? this.url,
    name: name ?? this.name,
    alias: alias ?? this.alias,
    phone: phone ?? this.phone,
    price: price ?? this.price,
    rating: rating ?? this.rating,
    location: location ?? this.location,
    summaries: summaries ?? this.summaries,
    attributes: attributes ?? this.attributes,
    categories: categories ?? this.categories,
    coordinates: coordinates ?? this.coordinates,
    reviewCount: reviewCount ?? this.reviewCount,
    contextualInfo: contextualInfo ?? this.contextualInfo,
  );

  factory Business.fromJson(String str) => Business.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Business.fromMap(Map<String, dynamic> json) => Business(
    id: json["id"],
    url: json["url"],
    name: json["name"],
    alias: json["alias"],
    phone: json["phone"],
    price: json["price"],
    rating: json["rating"]?.toDouble(),
    location: json["location"] == null
        ? null
        : Location.fromMap(json["location"]),
    summaries: json["summaries"] == null
        ? null
        : Summaries.fromMap(json["summaries"]),
    attributes: json["attributes"] == null
        ? null
        : Attributes.fromMap(json["attributes"]),
    categories: json["categories"] == null
        ? []
        : List<Category>.from(
            json["categories"]!.map((x) => Category.fromMap(x)),
          ),
    coordinates: json["coordinates"] == null
        ? null
        : Coordinates.fromMap(json["coordinates"]),
    reviewCount: json["review_count"],
    contextualInfo: json["contextual_info"] == null
        ? null
        : ContextualInfo.fromMap(json["contextual_info"]),
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "url": url,
    "name": name,
    "alias": alias,
    "phone": phone,
    "price": price,
    "rating": rating,
    "location": location?.toMap(),
    "summaries": summaries?.toMap(),
    "attributes": attributes?.toMap(),
    "categories": categories == null
        ? []
        : List<dynamic>.from(categories!.map((x) => x.toMap())),
    "coordinates": coordinates?.toMap(),
    "review_count": reviewCount,
    "contextual_info": contextualInfo?.toMap(),
  };
}

class Attributes {
  String? wiFi;
  bool? caters;
  dynamic menuUrl;
  dynamic groupName;
  dynamic storeCode;
  String? noiseLevel;
  bool? bikeParking;
  String? businessUrl;
  bool? dogsAllowed;
  bool? goodForKids;
  BizSummary? bizSummary;
  dynamic flowerDelivery;
  bool? goodForWorking;
  dynamic pokestopNearby;
  dynamic aboutThisBizBio;
  dynamic businessMovedTo;
  BusinessParking? businessParking;
  dynamic aboutThisBizRole;
  dynamic platformDelivery;
  BizSummary? bizSummaryLong;
  dynamic businessMovedFrom;
  bool? businessOpenToAll;
  dynamic businessDisplayUrl;
  dynamic businessTempClosed;
  dynamic onlineReservations;
  bool? restaurantsTakeOut;
  String? aboutThisBizHistory;
  dynamic businessCategorySic;
  int? businessOpeningDate;
  bool? restaurantsDelivery;
  dynamic waitlistReservation;
  bool? wheelchairAccessible;
  dynamic businessNameAlternate;
  bool? ongoingVigilanteEvent;
  dynamic businessAcceptsBitcoin;
  bool? genderNeutralRestrooms;
  dynamic offersCannabisProducts;
  dynamic offersMilitaryDiscount;
  int? restaurantsPriceRange2;
  dynamic aboutThisBizBioLastName;
  String? aboutThisBizSpecialties;
  bool? businessAcceptsApplePay;
  dynamic aboutThisBizBioFirstName;
  dynamic aboutThisBizBioPhotoDict;
  dynamic businessAddressAlternate;
  bool? businessAcceptsAndroidPay;
  bool? businessAcceptsCreditCards;
  dynamic nationalProviderIdentifier;
  String? aboutThisBizYearEstablished;
  List<dynamic>? aboutThisBizBusinessRecommendation;
  dynamic driveThru;

  Attributes({
    this.wiFi,
    this.caters,
    this.menuUrl,
    this.groupName,
    this.storeCode,
    this.noiseLevel,
    this.bikeParking,
    this.businessUrl,
    this.dogsAllowed,
    this.goodForKids,
    this.bizSummary,
    this.flowerDelivery,
    this.goodForWorking,
    this.pokestopNearby,
    this.aboutThisBizBio,
    this.businessMovedTo,
    this.businessParking,
    this.aboutThisBizRole,
    this.platformDelivery,
    this.bizSummaryLong,
    this.businessMovedFrom,
    this.businessOpenToAll,
    this.businessDisplayUrl,
    this.businessTempClosed,
    this.onlineReservations,
    this.restaurantsTakeOut,
    this.aboutThisBizHistory,
    this.businessCategorySic,
    this.businessOpeningDate,
    this.restaurantsDelivery,
    this.waitlistReservation,
    this.wheelchairAccessible,
    this.businessNameAlternate,
    this.ongoingVigilanteEvent,
    this.businessAcceptsBitcoin,
    this.genderNeutralRestrooms,
    this.offersCannabisProducts,
    this.offersMilitaryDiscount,
    this.restaurantsPriceRange2,
    this.aboutThisBizBioLastName,
    this.aboutThisBizSpecialties,
    this.businessAcceptsApplePay,
    this.aboutThisBizBioFirstName,
    this.aboutThisBizBioPhotoDict,
    this.businessAddressAlternate,
    this.businessAcceptsAndroidPay,
    this.businessAcceptsCreditCards,
    this.nationalProviderIdentifier,
    this.aboutThisBizYearEstablished,
    this.aboutThisBizBusinessRecommendation,
    this.driveThru,
  });

  Attributes copyWith({
    String? wiFi,
    bool? caters,
    dynamic menuUrl,
    dynamic groupName,
    dynamic storeCode,
    String? noiseLevel,
    bool? bikeParking,
    String? businessUrl,
    bool? dogsAllowed,
    bool? goodForKids,
    BizSummary? bizSummary,
    dynamic flowerDelivery,
    bool? goodForWorking,
    dynamic pokestopNearby,
    dynamic aboutThisBizBio,
    dynamic businessMovedTo,
    BusinessParking? businessParking,
    dynamic aboutThisBizRole,
    dynamic platformDelivery,
    BizSummary? bizSummaryLong,
    dynamic businessMovedFrom,
    bool? businessOpenToAll,
    dynamic businessDisplayUrl,
    dynamic businessTempClosed,
    dynamic onlineReservations,
    bool? restaurantsTakeOut,
    String? aboutThisBizHistory,
    dynamic businessCategorySic,
    int? businessOpeningDate,
    bool? restaurantsDelivery,
    dynamic waitlistReservation,
    bool? wheelchairAccessible,
    dynamic businessNameAlternate,
    bool? ongoingVigilanteEvent,
    dynamic businessAcceptsBitcoin,
    bool? genderNeutralRestrooms,
    dynamic offersCannabisProducts,
    dynamic offersMilitaryDiscount,
    int? restaurantsPriceRange2,
    dynamic aboutThisBizBioLastName,
    String? aboutThisBizSpecialties,
    bool? businessAcceptsApplePay,
    dynamic aboutThisBizBioFirstName,
    dynamic aboutThisBizBioPhotoDict,
    dynamic businessAddressAlternate,
    bool? businessAcceptsAndroidPay,
    bool? businessAcceptsCreditCards,
    dynamic nationalProviderIdentifier,
    String? aboutThisBizYearEstablished,
    List<dynamic>? aboutThisBizBusinessRecommendation,
    dynamic driveThru,
  }) => Attributes(
    wiFi: wiFi ?? this.wiFi,
    caters: caters ?? this.caters,
    menuUrl: menuUrl ?? this.menuUrl,
    groupName: groupName ?? this.groupName,
    storeCode: storeCode ?? this.storeCode,
    noiseLevel: noiseLevel ?? this.noiseLevel,
    bikeParking: bikeParking ?? this.bikeParking,
    businessUrl: businessUrl ?? this.businessUrl,
    dogsAllowed: dogsAllowed ?? this.dogsAllowed,
    goodForKids: goodForKids ?? this.goodForKids,
    bizSummary: bizSummary ?? this.bizSummary,
    flowerDelivery: flowerDelivery ?? this.flowerDelivery,
    goodForWorking: goodForWorking ?? this.goodForWorking,
    pokestopNearby: pokestopNearby ?? this.pokestopNearby,
    aboutThisBizBio: aboutThisBizBio ?? this.aboutThisBizBio,
    businessMovedTo: businessMovedTo ?? this.businessMovedTo,
    businessParking: businessParking ?? this.businessParking,
    aboutThisBizRole: aboutThisBizRole ?? this.aboutThisBizRole,
    platformDelivery: platformDelivery ?? this.platformDelivery,
    bizSummaryLong: bizSummaryLong ?? this.bizSummaryLong,
    businessMovedFrom: businessMovedFrom ?? this.businessMovedFrom,
    businessOpenToAll: businessOpenToAll ?? this.businessOpenToAll,
    businessDisplayUrl: businessDisplayUrl ?? this.businessDisplayUrl,
    businessTempClosed: businessTempClosed ?? this.businessTempClosed,
    onlineReservations: onlineReservations ?? this.onlineReservations,
    restaurantsTakeOut: restaurantsTakeOut ?? this.restaurantsTakeOut,
    aboutThisBizHistory: aboutThisBizHistory ?? this.aboutThisBizHistory,
    businessCategorySic: businessCategorySic ?? this.businessCategorySic,
    businessOpeningDate: businessOpeningDate ?? this.businessOpeningDate,
    restaurantsDelivery: restaurantsDelivery ?? this.restaurantsDelivery,
    waitlistReservation: waitlistReservation ?? this.waitlistReservation,
    wheelchairAccessible: wheelchairAccessible ?? this.wheelchairAccessible,
    businessNameAlternate: businessNameAlternate ?? this.businessNameAlternate,
    ongoingVigilanteEvent: ongoingVigilanteEvent ?? this.ongoingVigilanteEvent,
    businessAcceptsBitcoin:
        businessAcceptsBitcoin ?? this.businessAcceptsBitcoin,
    genderNeutralRestrooms:
        genderNeutralRestrooms ?? this.genderNeutralRestrooms,
    offersCannabisProducts:
        offersCannabisProducts ?? this.offersCannabisProducts,
    offersMilitaryDiscount:
        offersMilitaryDiscount ?? this.offersMilitaryDiscount,
    restaurantsPriceRange2:
        restaurantsPriceRange2 ?? this.restaurantsPriceRange2,
    aboutThisBizBioLastName:
        aboutThisBizBioLastName ?? this.aboutThisBizBioLastName,
    aboutThisBizSpecialties:
        aboutThisBizSpecialties ?? this.aboutThisBizSpecialties,
    businessAcceptsApplePay:
        businessAcceptsApplePay ?? this.businessAcceptsApplePay,
    aboutThisBizBioFirstName:
        aboutThisBizBioFirstName ?? this.aboutThisBizBioFirstName,
    aboutThisBizBioPhotoDict:
        aboutThisBizBioPhotoDict ?? this.aboutThisBizBioPhotoDict,
    businessAddressAlternate:
        businessAddressAlternate ?? this.businessAddressAlternate,
    businessAcceptsAndroidPay:
        businessAcceptsAndroidPay ?? this.businessAcceptsAndroidPay,
    businessAcceptsCreditCards:
        businessAcceptsCreditCards ?? this.businessAcceptsCreditCards,
    nationalProviderIdentifier:
        nationalProviderIdentifier ?? this.nationalProviderIdentifier,
    aboutThisBizYearEstablished:
        aboutThisBizYearEstablished ?? this.aboutThisBizYearEstablished,
    aboutThisBizBusinessRecommendation:
        aboutThisBizBusinessRecommendation ??
        this.aboutThisBizBusinessRecommendation,
    driveThru: driveThru ?? this.driveThru,
  );

  factory Attributes.fromJson(String str) =>
      Attributes.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Attributes.fromMap(Map<String, dynamic> json) => Attributes(
    wiFi: json["WiFi"],
    caters: json["Caters"],
    menuUrl: json["MenuUrl"],
    groupName: json["GroupName"],
    storeCode: json["StoreCode"],
    noiseLevel: json["NoiseLevel"],
    bikeParking: json["BikeParking"],
    businessUrl: json["BusinessUrl"],
    dogsAllowed: json["DogsAllowed"],
    goodForKids: json["GoodForKids"],
    bizSummary: json["biz_summary"] == null
        ? null
        : BizSummary.fromMap(json["biz_summary"]),
    flowerDelivery: json["FlowerDelivery"],
    goodForWorking: json["GoodForWorking"],
    pokestopNearby: json["PokestopNearby"],
    aboutThisBizBio: json["AboutThisBizBio"],
    businessMovedTo: json["BusinessMovedTo"],
    businessParking: json["BusinessParking"] == null
        ? null
        : BusinessParking.fromMap(json["BusinessParking"]),
    aboutThisBizRole: json["AboutThisBizRole"],
    platformDelivery: json["PlatformDelivery"],
    bizSummaryLong: json["biz_summary_long"] == null
        ? null
        : BizSummary.fromMap(json["biz_summary_long"]),
    businessMovedFrom: json["BusinessMovedFrom"],
    businessOpenToAll: json["BusinessOpenToAll"],
    businessDisplayUrl: json["BusinessDisplayUrl"],
    businessTempClosed: json["BusinessTempClosed"],
    onlineReservations: json["OnlineReservations"],
    restaurantsTakeOut: json["RestaurantsTakeOut"],
    aboutThisBizHistory: json["AboutThisBizHistory"],
    businessCategorySic: json["BusinessCategorySic"],
    businessOpeningDate: json["BusinessOpeningDate"],
    restaurantsDelivery: json["RestaurantsDelivery"],
    waitlistReservation: json["WaitlistReservation"],
    wheelchairAccessible: json["WheelchairAccessible"],
    businessNameAlternate: json["BusinessNameAlternate"],
    ongoingVigilanteEvent: json["OngoingVigilanteEvent"],
    businessAcceptsBitcoin: json["BusinessAcceptsBitcoin"],
    genderNeutralRestrooms: json["GenderNeutralRestrooms"],
    offersCannabisProducts: json["OffersCannabisProducts"],
    offersMilitaryDiscount: json["OffersMilitaryDiscount"],
    restaurantsPriceRange2: json["RestaurantsPriceRange2"],
    aboutThisBizBioLastName: json["AboutThisBizBioLastName"],
    aboutThisBizSpecialties: json["AboutThisBizSpecialties"],
    businessAcceptsApplePay: json["BusinessAcceptsApplePay"],
    aboutThisBizBioFirstName: json["AboutThisBizBioFirstName"],
    aboutThisBizBioPhotoDict: json["AboutThisBizBioPhotoDict"],
    businessAddressAlternate: json["BusinessAddressAlternate"],
    businessAcceptsAndroidPay: json["BusinessAcceptsAndroidPay"],
    businessAcceptsCreditCards: json["BusinessAcceptsCreditCards"],
    nationalProviderIdentifier: json["NationalProviderIdentifier"],
    aboutThisBizYearEstablished: json["AboutThisBizYearEstablished"],
    aboutThisBizBusinessRecommendation:
        json["AboutThisBizBusinessRecommendation"] == null
        ? []
        : List<dynamic>.from(
            json["AboutThisBizBusinessRecommendation"]!.map((x) => x),
          ),
    driveThru: json["DriveThru"],
  );

  Map<String, dynamic> toMap() => {
    "WiFi": wiFi,
    "Caters": caters,
    "MenuUrl": menuUrl,
    "GroupName": groupName,
    "StoreCode": storeCode,
    "NoiseLevel": noiseLevel,
    "BikeParking": bikeParking,
    "BusinessUrl": businessUrl,
    "DogsAllowed": dogsAllowed,
    "GoodForKids": goodForKids,
    "biz_summary": bizSummary?.toMap(),
    "FlowerDelivery": flowerDelivery,
    "GoodForWorking": goodForWorking,
    "PokestopNearby": pokestopNearby,
    "AboutThisBizBio": aboutThisBizBio,
    "BusinessMovedTo": businessMovedTo,
    "BusinessParking": businessParking?.toMap(),
    "AboutThisBizRole": aboutThisBizRole,
    "PlatformDelivery": platformDelivery,
    "biz_summary_long": bizSummaryLong?.toMap(),
    "BusinessMovedFrom": businessMovedFrom,
    "BusinessOpenToAll": businessOpenToAll,
    "BusinessDisplayUrl": businessDisplayUrl,
    "BusinessTempClosed": businessTempClosed,
    "OnlineReservations": onlineReservations,
    "RestaurantsTakeOut": restaurantsTakeOut,
    "AboutThisBizHistory": aboutThisBizHistory,
    "BusinessCategorySic": businessCategorySic,
    "BusinessOpeningDate": businessOpeningDate,
    "RestaurantsDelivery": restaurantsDelivery,
    "WaitlistReservation": waitlistReservation,
    "WheelchairAccessible": wheelchairAccessible,
    "BusinessNameAlternate": businessNameAlternate,
    "OngoingVigilanteEvent": ongoingVigilanteEvent,
    "BusinessAcceptsBitcoin": businessAcceptsBitcoin,
    "GenderNeutralRestrooms": genderNeutralRestrooms,
    "OffersCannabisProducts": offersCannabisProducts,
    "OffersMilitaryDiscount": offersMilitaryDiscount,
    "RestaurantsPriceRange2": restaurantsPriceRange2,
    "AboutThisBizBioLastName": aboutThisBizBioLastName,
    "AboutThisBizSpecialties": aboutThisBizSpecialties,
    "BusinessAcceptsApplePay": businessAcceptsApplePay,
    "AboutThisBizBioFirstName": aboutThisBizBioFirstName,
    "AboutThisBizBioPhotoDict": aboutThisBizBioPhotoDict,
    "BusinessAddressAlternate": businessAddressAlternate,
    "BusinessAcceptsAndroidPay": businessAcceptsAndroidPay,
    "BusinessAcceptsCreditCards": businessAcceptsCreditCards,
    "NationalProviderIdentifier": nationalProviderIdentifier,
    "AboutThisBizYearEstablished": aboutThisBizYearEstablished,
    "AboutThisBizBusinessRecommendation":
        aboutThisBizBusinessRecommendation == null
        ? []
        : List<dynamic>.from(aboutThisBizBusinessRecommendation!.map((x) => x)),
    "DriveThru": driveThru,
  };
}

class BizSummary {
  String? summary;
  bool? isInactive;
  int? eligibleReviewsConsidered;
  bool? allowsAutoSummaryGeneration;

  BizSummary({
    this.summary,
    this.isInactive,
    this.eligibleReviewsConsidered,
    this.allowsAutoSummaryGeneration,
  });

  BizSummary copyWith({
    String? summary,
    bool? isInactive,
    int? eligibleReviewsConsidered,
    bool? allowsAutoSummaryGeneration,
  }) => BizSummary(
    summary: summary ?? this.summary,
    isInactive: isInactive ?? this.isInactive,
    eligibleReviewsConsidered:
        eligibleReviewsConsidered ?? this.eligibleReviewsConsidered,
    allowsAutoSummaryGeneration:
        allowsAutoSummaryGeneration ?? this.allowsAutoSummaryGeneration,
  );

  factory BizSummary.fromJson(String str) =>
      BizSummary.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BizSummary.fromMap(Map<String, dynamic> json) => BizSummary(
    summary: json["summary"],
    isInactive: json["is_inactive"],
    eligibleReviewsConsidered: json["eligible_reviews_considered"],
    allowsAutoSummaryGeneration: json["allows_auto_summary_generation"],
  );

  Map<String, dynamic> toMap() => {
    "summary": summary,
    "is_inactive": isInactive,
    "eligible_reviews_considered": eligibleReviewsConsidered,
    "allows_auto_summary_generation": allowsAutoSummaryGeneration,
  };
}

class BusinessParking {
  bool? lot;
  bool? valet;
  bool? garage;
  bool? street;
  bool? validated;

  BusinessParking({
    this.lot,
    this.valet,
    this.garage,
    this.street,
    this.validated,
  });

  BusinessParking copyWith({
    bool? lot,
    bool? valet,
    bool? garage,
    bool? street,
    bool? validated,
  }) => BusinessParking(
    lot: lot ?? this.lot,
    valet: valet ?? this.valet,
    garage: garage ?? this.garage,
    street: street ?? this.street,
    validated: validated ?? this.validated,
  );

  factory BusinessParking.fromJson(String str) =>
      BusinessParking.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BusinessParking.fromMap(Map<String, dynamic> json) => BusinessParking(
    lot: json["lot"],
    valet: json["valet"],
    garage: json["garage"],
    street: json["street"],
    validated: json["validated"],
  );

  Map<String, dynamic> toMap() => {
    "lot": lot,
    "valet": valet,
    "garage": garage,
    "street": street,
    "validated": validated,
  };
}

class Category {
  String? alias;
  String? title;

  Category({this.alias, this.title});

  Category copyWith({String? alias, String? title}) =>
      Category(alias: alias ?? this.alias, title: title ?? this.title);

  factory Category.fromJson(String str) => Category.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Category.fromMap(Map<String, dynamic> json) =>
      Category(alias: json["alias"], title: json["title"]);

  Map<String, dynamic> toMap() => {"alias": alias, "title": title};
}

class ContextualInfo {
  List<Photo>? photos;
  dynamic summary;
  List<dynamic>? businessHours;
  String? reviewSnippet;
  List<dynamic>? reviewSnippets;
  dynamic reservationAvailability;
  bool? acceptsReservationsThroughYelp;

  ContextualInfo({
    this.photos,
    this.summary,
    this.businessHours,
    this.reviewSnippet,
    this.reviewSnippets,
    this.reservationAvailability,
    this.acceptsReservationsThroughYelp,
  });

  ContextualInfo copyWith({
    List<Photo>? photos,
    dynamic summary,
    List<dynamic>? businessHours,
    String? reviewSnippet,
    List<dynamic>? reviewSnippets,
    dynamic reservationAvailability,
    bool? acceptsReservationsThroughYelp,
  }) => ContextualInfo(
    photos: photos ?? this.photos,
    summary: summary ?? this.summary,
    businessHours: businessHours ?? this.businessHours,
    reviewSnippet: reviewSnippet ?? this.reviewSnippet,
    reviewSnippets: reviewSnippets ?? this.reviewSnippets,
    reservationAvailability:
        reservationAvailability ?? this.reservationAvailability,
    acceptsReservationsThroughYelp:
        acceptsReservationsThroughYelp ?? this.acceptsReservationsThroughYelp,
  );

  factory ContextualInfo.fromJson(String str) =>
      ContextualInfo.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ContextualInfo.fromMap(Map<String, dynamic> json) => ContextualInfo(
    photos: json["photos"] == null
        ? []
        : List<Photo>.from(json["photos"]!.map((x) => Photo.fromMap(x))),
    summary: json["summary"],
    businessHours: json["business_hours"] == null
        ? []
        : List<dynamic>.from(json["business_hours"]!.map((x) => x)),
    reviewSnippet: json["review_snippet"],
    reviewSnippets: json["review_snippets"] == null
        ? []
        : List<dynamic>.from(json["review_snippets"]!.map((x) => x)),
    reservationAvailability: json["reservation_availability"],
    acceptsReservationsThroughYelp: json["accepts_reservations_through_yelp"],
  );

  Map<String, dynamic> toMap() => {
    "photos": photos == null
        ? []
        : List<dynamic>.from(photos!.map((x) => x.toMap())),
    "summary": summary,
    "business_hours": businessHours == null
        ? []
        : List<dynamic>.from(businessHours!.map((x) => x)),
    "review_snippet": reviewSnippet,
    "review_snippets": reviewSnippets == null
        ? []
        : List<dynamic>.from(reviewSnippets!.map((x) => x)),
    "reservation_availability": reservationAvailability,
    "accepts_reservations_through_yelp": acceptsReservationsThroughYelp,
  };
}

class Photo {
  String? originalUrl;

  Photo({this.originalUrl});

  Photo copyWith({String? originalUrl}) =>
      Photo(originalUrl: originalUrl ?? this.originalUrl);

  factory Photo.fromJson(String str) => Photo.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Photo.fromMap(Map<String, dynamic> json) =>
      Photo(originalUrl: json["original_url"]);

  Map<String, dynamic> toMap() => {"original_url": originalUrl};
}

class Coordinates {
  double? latitude;
  double? longitude;

  Coordinates({this.latitude, this.longitude});

  Coordinates copyWith({double? latitude, double? longitude}) => Coordinates(
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
  );

  factory Coordinates.fromJson(String str) =>
      Coordinates.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Coordinates.fromMap(Map<String, dynamic> json) => Coordinates(
    latitude: json["latitude"]?.toDouble(),
    longitude: json["longitude"]?.toDouble(),
  );

  Map<String, dynamic> toMap() => {
    "latitude": latitude,
    "longitude": longitude,
  };
}

class Location {
  String? city;
  String? state;
  String? country;
  String? address1;
  String? address2;
  String? address3;
  dynamic zipCode;
  String? formattedAddress;

  Location({
    this.city,
    this.state,
    this.country,
    this.address1,
    this.address2,
    this.address3,
    this.zipCode,
    this.formattedAddress,
  });

  Location copyWith({
    String? city,
    String? state,
    String? country,
    String? address1,
    String? address2,
    String? address3,
    dynamic zipCode,
    String? formattedAddress,
  }) => Location(
    city: city ?? this.city,
    state: state ?? this.state,
    country: country ?? this.country,
    address1: address1 ?? this.address1,
    address2: address2 ?? this.address2,
    address3: address3 ?? this.address3,
    zipCode: zipCode ?? this.zipCode,
    formattedAddress: formattedAddress ?? this.formattedAddress,
  );

  factory Location.fromJson(String str) => Location.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Location.fromMap(Map<String, dynamic> json) => Location(
    city: json["city"],
    state: json["state"],
    country: json["country"],
    address1: json["address1"],
    address2: json["address2"],
    address3: json["address3"],
    zipCode: json["zip_code"],
    formattedAddress: json["formatted_address"],
  );

  Map<String, dynamic> toMap() => {
    "city": city,
    "state": state,
    "country": country,
    "address1": address1,
    "address2": address2,
    "address3": address3,
    "zip_code": zipCode,
    "formatted_address": formattedAddress,
  };
}

class Summaries {
  String? long;
  String? short;
  String? medium;

  Summaries({this.long, this.short, this.medium});

  Summaries copyWith({String? long, String? short, String? medium}) =>
      Summaries(
        long: long ?? this.long,
        short: short ?? this.short,
        medium: medium ?? this.medium,
      );

  factory Summaries.fromJson(String str) => Summaries.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Summaries.fromMap(Map<String, dynamic> json) => Summaries(
    long: json["long"],
    short: json["short"],
    medium: json["medium"],
  );

  Map<String, dynamic> toMap() => {
    "long": long,
    "short": short,
    "medium": medium,
  };
}

class YelpTag {
  int? end;
  Meta? meta;
  int? start;
  String? tagType;

  YelpTag({this.end, this.meta, this.start, this.tagType});

  YelpTag copyWith({int? end, Meta? meta, int? start, String? tagType}) =>
      YelpTag(
        end: end ?? this.end,
        meta: meta ?? this.meta,
        start: start ?? this.start,
        tagType: tagType ?? this.tagType,
      );

  factory YelpTag.fromJson(String str) => YelpTag.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory YelpTag.fromMap(Map<String, dynamic> json) => YelpTag(
    end: json["end"],
    meta: json["meta"] == null ? null : Meta.fromMap(json["meta"]),
    start: json["start"],
    tagType: json["tag_type"],
  );

  Map<String, dynamic> toMap() => {
    "end": end,
    "meta": meta?.toMap(),
    "start": start,
    "tag_type": tagType,
  };
}

class Meta {
  String? businessId;

  Meta({this.businessId});

  Meta copyWith({String? businessId}) =>
      Meta(businessId: businessId ?? this.businessId);

  factory Meta.fromJson(String str) => Meta.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Meta.fromMap(Map<String, dynamic> json) =>
      Meta(businessId: json["business_id"]);

  Map<String, dynamic> toMap() => {"business_id": businessId};
}
