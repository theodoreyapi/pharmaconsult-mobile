class PlanningModel {
  int? id;
  String? frequencyType;
  String? frequencyLabel;
  List<String>? jours;
  String? heure;
  List<MesuresTypes>? mesuresTypes;
  String? rappelAvant;
  String? canal;
  String? notes;
  String? status;

  PlanningModel(
      {this.id,
      this.frequencyType,
      this.frequencyLabel,
      this.jours,
      this.heure,
      this.mesuresTypes,
      this.rappelAvant,
      this.canal,
      this.notes,
      this.status});

  PlanningModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    frequencyType = json['frequency_type'];
    frequencyLabel = json['frequency_label'];
    jours = json['jours'] != null ? json['jours'].cast<String>() : [];
    heure = json['heure'];
    if (json['mesures_types'] != null) {
      mesuresTypes = <MesuresTypes>[];
      json['mesures_types'].forEach((v) {
        mesuresTypes!.add(MesuresTypes.fromJson(v));
      });
    }
    rappelAvant = json['rappel_avant'];
    canal = json['canal'];
    notes = json['notes'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['frequency_type'] = frequencyType;
    data['frequency_label'] = frequencyLabel;
    data['jours'] = jours;
    data['heure'] = heure;
    if (mesuresTypes != null) {
      data['mesures_types'] = mesuresTypes!.map((v) => v.toJson()).toList();
    }
    data['rappel_avant'] = rappelAvant;
    data['canal'] = canal;
    data['notes'] = notes;
    data['status'] = status;
    return data;
  }
}

class MesuresTypes {
  String? code;
  String? label;

  MesuresTypes({this.code, this.label});

  MesuresTypes.fromJson(Map<String, dynamic> json) {
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
