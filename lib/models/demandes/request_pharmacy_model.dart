class RequestPharmacy {
  int? requestId;
  Pharmacy? pharmacy;
  String? status;
  String? dateUpdate;
  String? dateCreate;

  RequestPharmacy({
    this.requestId,
    this.pharmacy,
    this.status,
    this.dateUpdate,
    this.dateCreate,
  });

  RequestPharmacy.fromJson(Map<String, dynamic> json) {
    requestId = json['requestId'];
    pharmacy =
        json['pharmacy'] != null
            ? Pharmacy.fromJson(json['pharmacy'])
            : null;
    status = json['status'];
    dateUpdate = json['dateUpdate'];
    dateCreate = json['dateCreate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['requestId'] = requestId;
    if (pharmacy != null) {
      data['pharmacy'] = pharmacy!.toJson();
    }
    data['status'] = status;
    data['dateUpdate'] = dateUpdate;
    data['dateCreate'] = dateCreate;
    return data;
  }
}

class Pharmacy {
  int? id;
  String? name;
  String? address;
  String? openingHours;
  String? phoneNumber;
  String? whatsAppPhoneNumber;
  String? ownerName;
  String? facadeImage;
  String? gpsCoordinates;
  int? startGardeDate;
  int? endGardeDate;
  Commune? commune;

  Pharmacy({
    this.id,
    this.name,
    this.address,
    this.openingHours,
    this.phoneNumber,
    this.whatsAppPhoneNumber,
    this.ownerName,
    this.facadeImage,
    this.gpsCoordinates,
    this.startGardeDate,
    this.endGardeDate,
    this.commune,
  });

  Pharmacy.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    openingHours = json['openingHours'] ?? '';
    phoneNumber = json['phoneNumber'];
    whatsAppPhoneNumber = json['whatsAppPhoneNumber'];
    ownerName = json['ownerName'];
    facadeImage = json['facadeImage'] ?? '';
    gpsCoordinates = json['gpsCoordinates'] ?? '';
    startGardeDate = json['startGardeDate'];
    endGardeDate = json['endGardeDate'];
    commune =
        json['commune'] != null ? Commune.fromJson(json['commune']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['address'] = address;
    data['openingHours'] = openingHours;
    data['phoneNumber'] = phoneNumber;
    data['whatsAppPhoneNumber'] = whatsAppPhoneNumber;
    data['ownerName'] = ownerName;
    data['facadeImage'] = facadeImage;
    data['gpsCoordinates'] = gpsCoordinates;
    data['startGardeDate'] = startGardeDate;
    data['endGardeDate'] = endGardeDate;
    if (commune != null) {
      data['commune'] = commune!.toJson();
    }
    return data;
  }
}

class Commune {
  int? id;
  String? name;
  String? description;

  Commune({this.id, this.name, this.description});

  Commune.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    return data;
  }
}
