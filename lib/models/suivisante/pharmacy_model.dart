class PharmacyModel {
  int? id;
  String? name;
  String? ownerName;
  int? rating;
  int? reviewsCount;
  String? phone;
  String? whatsapp;
  String? address;
  String? openingHours;
  String? closingHours;
  String? gpsCoordinates;
  String? googleMapsUrl;
  bool? isActive;
  String? badge;

  PharmacyModel({
    this.id,
    this.name,
    this.ownerName,
    this.rating,
    this.reviewsCount,
    this.phone,
    this.whatsapp,
    this.address,
    this.openingHours,
    this.closingHours,
    this.gpsCoordinates,
    this.googleMapsUrl,
    this.isActive,
    this.badge,
  });

  PharmacyModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    ownerName = json['owner_name'];
    rating = json['rating'];
    reviewsCount = json['reviews_count'];
    phone = json['phone'];
    whatsapp = json['whatsapp'];
    address = json['address'];
    openingHours = json['opening_hours'] ?? "";
    closingHours = json['closing_hours'] ?? "";
    gpsCoordinates = json['gps_coordinates'];
    googleMapsUrl = json['google_maps_url'];
    isActive = json['is_active'];
    badge = json['badge'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['owner_name'] = ownerName;
    data['rating'] = rating;
    data['reviews_count'] = reviewsCount;
    data['phone'] = phone;
    data['whatsapp'] = whatsapp;
    data['address'] = address;
    data['opening_hours'] = openingHours;
    data['closing_hours'] = closingHours;
    data['gps_coordinates'] = gpsCoordinates;
    data['google_maps_url'] = googleMapsUrl;
    data['is_active'] = isActive;
    data['badge'] = badge;
    return data;
  }
}
