class ReservationModel {
  int? id;
  Pharmacy? pharmacy;
  Medicament? medicament;
  String? userName;
  String? status;
  String? expirationDate;
  String? dateReservation;

  ReservationModel({
    this.id,
    this.pharmacy,
    this.medicament,
    this.userName,
    this.status,
    this.expirationDate,
    this.dateReservation,
  });

  ReservationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pharmacy =
        json['pharmacy'] != null ? Pharmacy.fromJson(json['pharmacy']) : null;
    medicament =
        json['medicament'] != null
            ? Medicament.fromJson(json['medicament'])
            : null;
    userName = json['userName'];
    status = json['status'];
    expirationDate = json['expirationDate'];
    dateReservation = json['dateReservation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (pharmacy != null) {
      data['pharmacy'] = pharmacy!.toJson();
    }
    if (medicament != null) {
      data['medicament'] = medicament!.toJson();
    }
    data['userName'] = userName;
    data['status'] = status;
    data['expirationDate'] = expirationDate;
    data['dateReservation'] = dateReservation;
    return data;
  }
}

class Pharmacy {
  int? id;
  String? name;
  String? address;
  String? gpsCoordinates;
  Commune? commune;

  Pharmacy({this.id, this.name, this.address, this.gpsCoordinates, this.commune});

  Pharmacy.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    gpsCoordinates = json['gpsCoordinates'];
    commune =
        json['commune'] != null ? Commune.fromJson(json['commune']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['address'] = address;
    data['gpsCoordinates'] = gpsCoordinates;
    if (commune != null) {
      data['commune'] = commune!.toJson();
    }
    return data;
  }
}

class Commune {
  int? id;
  String? name;

  Commune({this.id, this.name});

  Commune.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class Medicament {
  int? id;
  String? name;

  Medicament({this.id, this.name});

  Medicament.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
