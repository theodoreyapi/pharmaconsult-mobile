class ConseilModel {
  int? idConseil;
  String? type;
  int? pathologieId;
  String? titre;
  String? description;
  String? createdAt;
  String? updatedAt;
  String? code;
  String? name;

  ConseilModel({
    this.idConseil,
    this.type,
    this.pathologieId,
    this.titre,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.code,
    this.name,
  });

  ConseilModel.fromJson(Map<String, dynamic> json) {
    idConseil = json['id_conseil'];
    type = json['type'];
    pathologieId = json['pathologie_id'];
    titre = json['titre'];
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    code = json['code'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id_conseil'] = idConseil;
    data['type'] = type;
    data['pathologie_id'] = pathologieId;
    data['titre'] = titre;
    data['description'] = description;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['code'] = code;
    data['name'] = name;
    return data;
  }
}
