class PharmaciesModels {
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
  Notices? notices;
  List<PaymentMethods>? paymentMethods;
  List<Assurances>? assurances;

  PharmaciesModels(
      {this.id,
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
        this.notices,
        this.paymentMethods,
        this.assurances});

  PharmaciesModels.fromJson(Map<String, dynamic> json) {
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
    notices =
    json['notices'] != null ? Notices.fromJson(json['notices']) : null;
    if (json['paymentMethods'] != null) {
      paymentMethods = <PaymentMethods>[];
      json['paymentMethods'].forEach((v) {
        paymentMethods!.add(PaymentMethods.fromJson(v));
      });
    }
    if (json['assurances'] != null) {
      assurances = <Assurances>[];
      json['assurances'].forEach((v) {
        assurances!.add(Assurances.fromJson(v));
      });
    }
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
    if (notices != null) {
      data['notices'] = notices!.toJson();
    }
    if (paymentMethods != null) {
      data['paymentMethods'] =
          paymentMethods!.map((v) => v.toJson()).toList();
    }
    if (assurances != null) {
      data['assurances'] = assurances!.map((v) => v.toJson()).toList();
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

class Notices {
  List<NoticesItem>? notices;
  Rating? ratingSummary;

  Notices({this.notices, this.ratingSummary});

  Notices.fromJson(Map<String, dynamic> json) {
    if (json['notices'] != null) {
      notices = <NoticesItem>[];
      json['notices'].forEach((v) {
        notices!.add(NoticesItem.fromJson(v));
      });
    }
    ratingSummary = json['ratingSummary'] != null
        ? Rating.fromJson(json['ratingSummary'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (notices != null) {
      data['notices'] = notices!.map((v) => v.toJson()).toList();
    }
    if (ratingSummary != null) {
      data['ratingSummary'] = ratingSummary!.toJson();
    }
    return data;
  }
}

class NoticesItem {
  int? id;
  int? note;
  String? userName;
  String? userPicture;
  String? dateNotice;
  String? details;
  int? pharmacyId;

  NoticesItem(
      {this.id,
        this.note,
        this.userName,
        this.userPicture,
        this.dateNotice,
        this.details,
        this.pharmacyId});

  NoticesItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    note = json['note'];
    userName = json['userName'];
    userPicture = json['userPicture'] ?? '';
    dateNotice = json['dateNotice'];
    details = json['details'];
    pharmacyId = json['pharmacyId'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['note'] = note;
    data['userName'] = userName;
    data['userPicture'] = userPicture;
    data['dateNotice'] = dateNotice;
    data['details'] = details;
    data['pharmacyId'] = pharmacyId;
    return data;
  }
}

class Rating {
  int? counter;
  double? average;
  int? counterFiveStars;
  int? counterFourStars;
  int? counterThreeStars;
  int? counterTwoStars;
  int? counterOneStars;

  Rating(
      {this.counter,
        this.average,
        this.counterFiveStars,
        this.counterFourStars,
        this.counterThreeStars,
        this.counterTwoStars,
        this.counterOneStars});

  Rating.fromJson(Map<String, dynamic> json) {
    counter = json['counter'] ?? 0;
    average = json['average'] ?? 0;
    counterFiveStars = json['counterFiveStars'] ?? 0;
    counterFourStars = json['counterFourStars'] ?? 0;
    counterThreeStars = json['counterThreeStars'] ?? 0;
    counterTwoStars = json['counterTwoStars'] ?? 0;
    counterOneStars = json['counterOneStars'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['counter'] = counter;
    data['average'] = average;
    data['counterFiveStars'] = counterFiveStars;
    data['counterFourStars'] = counterFourStars;
    data['counterThreeStars'] = counterThreeStars;
    data['counterTwoStars'] = counterTwoStars;
    data['counterOneStars'] = counterOneStars;
    return data;
  }
}

class PaymentMethods {
  int? id;
  String? name;
  String? description;
  String? paymentMethodPicture;

  PaymentMethods({this.id, this.name, this.description, this.paymentMethodPicture});

  PaymentMethods.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    paymentMethodPicture = json['paymentMethodPicture'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['paymentMethodPicture'] = paymentMethodPicture;
    return data;
  }
}

class Assurances {
  int? id;
  String? name;
  String? description;
  String? assurancePicture;

  Assurances({this.id, this.name, this.description, this.assurancePicture});

  Assurances.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    assurancePicture = json['assurancePicture'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['assurancePicture'] = assurancePicture;
    return data;
  }
}