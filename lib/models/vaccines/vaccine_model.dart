class VaccineModel {
  int? idVaccine;
  String? name;
  String? slug;
  String? shortName;
  String? description;
  String? publicPrice;
  String? privatePriceMin;
  String? privatePriceMax;
  String? currency;
  String? importantInfo;
  List<Categories>? categories;

  VaccineModel({
    this.idVaccine,
    this.name,
    this.slug,
    this.shortName,
    this.description,
    this.publicPrice,
    this.privatePriceMin,
    this.privatePriceMax,
    this.currency,
    this.importantInfo,
    this.categories,
  });

  VaccineModel.fromJson(Map<String, dynamic> json) {
    idVaccine = json['id_vaccine'];
    name = json['name'];
    slug = json['slug'];
    shortName = json['short_name'];
    description = json['description'];
    publicPrice = json['public_price'];
    privatePriceMin = json['private_price_min'];
    privatePriceMax = json['private_price_max'];
    currency = json['currency'];
    importantInfo = json['important_info'];
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(new Categories.fromJson(v));
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
    data['private_price_min'] = privatePriceMin;
    data['private_price_max'] = privatePriceMax;
    data['currency'] = currency;
    data['important_info'] = importantInfo;
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
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
