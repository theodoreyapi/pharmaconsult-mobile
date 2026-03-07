class Subscription {
  int? id;
  ModuleDto? moduleDto;
  int? duree;
  String? dateCreate;
  String? dateUpdate;
  DateTime? validUntil;
  String? description;
  String? status;
  String? userName;

  Subscription({
    this.id,
    this.moduleDto,
    this.duree,
    this.dateCreate,
    this.dateUpdate,
    this.validUntil,
    this.description,
    this.status,
    this.userName,
  });

  Subscription.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    moduleDto =
        json['moduleDto'] != null
            ? ModuleDto.fromJson(json['moduleDto'])
            : null;
    duree = json['duree'];
    dateCreate = json['dateCreate'];
    dateUpdate = json['dateUpdate'];
    validUntil = DateTime.parse(json['validUntil']);
    description = json['description'];
    status = json['status'];
    userName = json['userName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (moduleDto != null) {
      data['moduleDto'] = moduleDto!.toJson();
    }
    data['duree'] = duree;
    data['dateCreate'] = dateCreate;
    data['dateUpdate'] = dateUpdate;
    data['validUntil'] = validUntil;
    data['description'] = description;
    data['status'] = status;
    data['userName'] = userName;
    return data;
  }
}

class ModuleDto {
  int? id;
  String? libelle;
  String? description;
  String? dateCreate;
  String? dateUpdate;

  ModuleDto({
    this.id,
    this.libelle,
    this.description,
    this.dateCreate,
    this.dateUpdate,
  });

  ModuleDto.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    libelle = json['libelle'];
    description = json['description'];
    dateCreate = json['dateCreate'];
    dateUpdate = json['dateUpdate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['libelle'] = libelle;
    data['description'] = description;
    data['dateCreate'] = dateCreate;
    data['dateUpdate'] = dateUpdate;
    return data;
  }
}
