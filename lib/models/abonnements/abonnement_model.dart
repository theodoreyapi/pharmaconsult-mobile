class AbonnementModel {
  int? id;
  String? libelle;
  String? description;
  int? price;
  int? duration;
  String? dateCreate;
  String? dateUpdate;
  ModuleDto? moduleDto;

  AbonnementModel(
      {this.id,
        this.libelle,
        this.description,
        this.price,
        this.duration,
        this.dateCreate,
        this.dateUpdate,
        this.moduleDto});

  AbonnementModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    libelle = json['libelle'];
    description = json['description'];
    price = json['price'];
    duration = json['duration'];
    dateCreate = json['dateCreate'];
    dateUpdate = json['dateUpdate'];
    moduleDto = json['moduleDto'] != null
        ? ModuleDto.fromJson(json['moduleDto'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['libelle'] = libelle;
    data['description'] = description;
    data['price'] = price;
    data['duration'] = duration;
    if (moduleDto != null) {
      data['moduleDto'] = moduleDto!.toJson();
    }
    return data;
  }
}

class ModuleDto {
  int? id;

  ModuleDto(
      {this.id,});

  ModuleDto.fromJson(Map<String, dynamic> json) {
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    return data;
  }
}