class RendezVousModel {
  int? id;
  String? date;
  String? dateLabel;
  String? heure;
  String? status;
  String? statusLabel;
  bool? isToday;
  bool? isPast;
  List<MesuresTypesRdv>? mesuresTypes;
  String? notes;
  bool? isRecurrent;
  String? createdAt;

  RendezVousModel(
      {this.id,
      this.date,
      this.dateLabel,
      this.heure,
      this.status,
      this.statusLabel,
      this.isToday,
      this.isPast,
      this.mesuresTypes,
      this.notes,
      this.isRecurrent,
      this.createdAt});

  RendezVousModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    dateLabel = json['date_label'];
    heure = json['heure'];
    status = json['status'];
    statusLabel = json['status_label'];
    isToday = json['is_today'];
    isPast = json['is_past'];
    if (json['mesures_types'] != null) {
      mesuresTypes = <MesuresTypesRdv>[];
      json['mesures_types'].forEach((v) {
        mesuresTypes!.add(MesuresTypesRdv.fromJson(v));
      });
    }
    notes = json['notes'];
    isRecurrent = json['is_recurrent'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['date'] = date;
    data['date_label'] = dateLabel;
    data['heure'] = heure;
    data['status'] = status;
    data['status_label'] = statusLabel;
    data['is_today'] = isToday;
    data['is_past'] = isPast;
    if (mesuresTypes != null) {
      data['mesures_types'] = mesuresTypes!.map((v) => v.toJson()).toList();
    }
    data['notes'] = notes;
    data['is_recurrent'] = isRecurrent;
    data['created_at'] = createdAt;
    return data;
  }
}

class MesuresTypesRdv {
  String? code;
  String? label;

  MesuresTypesRdv({this.code, this.label});

  MesuresTypesRdv.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    label = json['label'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['label'] = label;
    return data;
  }
}
