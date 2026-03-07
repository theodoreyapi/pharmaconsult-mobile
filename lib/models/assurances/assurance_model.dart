class AssuranceModel {
  int? id;
  String? name;
  String? assurancePicture;

  AssuranceModel({this.id, this.name, this.assurancePicture});

  AssuranceModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    assurancePicture = json['assurancePicture'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['assurancePicture'] = assurancePicture;
    return data;
  }
}
