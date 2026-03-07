class MedicamentsModels {
  int? id;
  String? name;
  String? principeActif;
  String? medicamentPicture;
  String? notice;
  String? codeCip;
  String? price;
  List<Substitutes>? substitutes;

  MedicamentsModels({
    this.id,
    this.name,
    this.principeActif,
    this.medicamentPicture,
    this.notice,
    this.codeCip,
    this.price,
    this.substitutes,
  });

  MedicamentsModels.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    principeActif = json['principeActif'] ?? '';
    medicamentPicture = json['medicamentPicture'] ?? '';
    notice = json['notice'] ?? '' ?? '';
    codeCip = json['codeCip'];
    price = json['price'] ?? '';
    if (json['substitutes'] != null) {
      substitutes = <Substitutes>[];
      json['substitutes'].forEach((v) {
        substitutes!.add(Substitutes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['principeActif'] = principeActif;
    data['medicamentPicture'] = medicamentPicture;
    data['notice'] = notice;
    data['codeCip'] = codeCip;
    data['price'] = price;
    if (substitutes != null) {
      data['substitutes'] = substitutes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Substitutes {
  int? id;
  int? substitutId;
  String? substitutName;
  String? substitutImageId;
  String? substitutPrincipleActif;
  String? substitutPrice;
  String? substitutNotice;
  int? medicamentId;

  Substitutes({
    this.id,
    this.substitutId,
    this.substitutName,
    this.substitutImageId,
    this.substitutPrincipleActif,
    this.substitutPrice,
    this.substitutNotice,
    this.medicamentId,
  });

  Substitutes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    substitutId = json['substitutId'] ?? 0;
    substitutName = json['substitutName'] ?? '';
    substitutImageId = json['substitutImageId'] ?? '';
    substitutPrincipleActif = json['substitutPrincipleActif'] ?? '';
    substitutPrice = json['substitutPrice'] ?? '';
    substitutNotice = json['substitutNotice'] ?? '';
    medicamentId = json['medicamentId'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['substitutId'] = substitutId;
    data['substitutName'] = substitutName;
    data['substitutImageId'] = substitutImageId;
    data['substitutPrincipleActif'] = substitutPrincipleActif;
    data['substitutPrice'] = substitutPrice;
    data['substitutNotice'] = substitutNotice;
    data['medicamentId'] = medicamentId;
    return data;
  }
}
