class PublicitiesModel {
  int? id;
  String? name;
  String? lien;
  String? image;
  String? startDate;
  String? endDate;
  String? status;

  PublicitiesModel({
    this.id,
    this.name,
    this.lien,
    this.image,
    this.startDate,
    this.endDate,
    this.status,
  });

  PublicitiesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    lien = json['lien'];
    image = json['image'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['lien'] = lien;
    data['image'] = image;
    data['startDate'] = startDate;
    data['endDate'] = endDate;
    data['status'] = status;
    return data;
  }
}
