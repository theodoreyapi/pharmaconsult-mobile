class DemandeModel {
  int? requestId;
  Medicament? medicament;
  String? userName;
  String? firstAndLastName;
  String? status;
  String? dateUpdate;
  String? dateCreate;

  DemandeModel(
      {this.requestId,
        this.medicament,
        this.userName,
        this.firstAndLastName,
        this.status,
        this.dateUpdate,
        this.dateCreate});

  DemandeModel.fromJson(Map<String, dynamic> json) {
    requestId = json['requestId'];
    medicament = json['medicament'] != null
        ? Medicament.fromJson(json['medicament'])
        : null;
    userName = json['userName'];
    firstAndLastName = json['firstAndLastName'];
    status = json['status'];
    dateUpdate = json['dateUpdate'];
    dateCreate = json['dateCreate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['requestId'] = requestId;
    if (medicament != null) {
      data['medicament'] = medicament!.toJson();
    }
    data['userName'] = userName;
    data['firstAndLastName'] = firstAndLastName;
    data['status'] = status;
    data['dateUpdate'] = dateUpdate;
    data['dateCreate'] = dateCreate;
    return data;
  }
}

class Medicament {
  int? id;
  String? name;
  String? principeActif;
  String? imageId;
  String? notice;
  String? codeCip;
  String? price;

  Medicament(
      {this.id,
        this.name,
        this.principeActif,
        this.imageId,
        this.notice,
        this.codeCip,
        this.price,});

  Medicament.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    principeActif = json['principeActif'] ?? '';
    imageId = json['imageId'] ?? '';
    notice = json['notice'] ?? '';
    codeCip = json['codeCip'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['principeActif'] = principeActif;
    data['imageId'] = imageId;
    data['notice'] = notice;
    data['codeCip'] = codeCip;
    data['price'] = price;
    return data;
  }
}