class CategorieModel {
  int? idCategorie;
  String? name;
  String? slug;

  CategorieModel({this.idCategorie, this.name, this.slug});

  CategorieModel.fromJson(Map<String, dynamic> json) {
    idCategorie = json['id_categorie'];
    name = json['name'];
    slug = json['slug'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id_categorie'] = idCategorie;
    data['name'] = name;
    data['slug'] = slug;
    return data;
  }
}
