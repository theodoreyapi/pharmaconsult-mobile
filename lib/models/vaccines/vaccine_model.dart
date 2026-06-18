class VaccineModel {
  int? idVaccine;
  String? name;
  String? slug;
  String? shortName;
  String? description;
  String? publicPrice;
  String? currency;
  String? importantInfo;
  List<Categories>? categories;
  List<Equivalents>? equivalents;

  VaccineModel({
    this.idVaccine,
    this.name,
    this.slug,
    this.shortName,
    this.description,
    this.publicPrice,
    this.currency,
    this.importantInfo,
    this.categories,
    this.equivalents,
  });

  VaccineModel.fromJson(Map<String, dynamic> json) {
    idVaccine = json['id_vaccine'];
    name = json['name'];
    slug = json['slug'];
    shortName = json['short_name'];
    description = json['description'];
    publicPrice = json['public_price']?.toString();
    currency = json['currency'];
    importantInfo = json['important_info'];
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(Categories.fromJson(v));
      });
    }
    if (json['equivalents'] != null) {
      equivalents = <Equivalents>[];
      json['equivalents'].forEach((v) {
        equivalents!.add(Equivalents.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id_vaccine'] = idVaccine;
    data['name'] = name;
    data['slug'] = slug;
    data['short_name'] = shortName;
    data['description'] = description;
    data['public_price'] = publicPrice;
    data['currency'] = currency;
    data['important_info'] = importantInfo;
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    if (equivalents != null) {
      data['equivalents'] = equivalents!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Categories {
  int? idCategorie;
  String? name;
  String? slug;

  Categories({this.idCategorie, this.name, this.slug});

  Categories.fromJson(Map<String, dynamic> json) {
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

class Equivalents {
  int? idEquivalent;
  String? name;
  String? description;
  String? price;

  Equivalents({this.idEquivalent, this.name, this.description, this.price});

  Equivalents.fromJson(Map<String, dynamic> json) {
    idEquivalent = json['id_equivalent'];
    name = json['name'];
    description = json['description'];
    price = json['price']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id_equivalent'] = idEquivalent;
    data['name'] = name;
    data['description'] = description;
    data['price'] = price;
    return data;
  }
}
