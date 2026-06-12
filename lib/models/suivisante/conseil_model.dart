class ConseilModel {
  int? idConseil;
  String? type;
  String? categorie;
  String? titre;
  String? description;
  String? createdAt;
  String? updatedAt;

  ConseilModel({
    this.idConseil,
    this.type,
    this.categorie,
    this.titre,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  ConseilModel.fromJson(Map<String, dynamic> json) {
    idConseil = json['id_conseil'];
    type = json['type'];
    categorie = json['categorie'];
    titre = json['titre'];
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id_conseil'] = idConseil;
    data['type'] = type;
    data['categorie'] = categorie;
    data['titre'] = titre;
    data['description'] = description;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
