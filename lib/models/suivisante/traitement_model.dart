class TraitementModel {
  String? pharmacyPhone;
  int? totalTraitements;
  List<Traitements>? traitements;

  TraitementModel(
      {this.pharmacyPhone, this.totalTraitements, this.traitements});

  TraitementModel.fromJson(Map<String, dynamic> json) {
    pharmacyPhone = json['pharmacy_phone'];
    totalTraitements = json['total_traitements'];
    if (json['traitements'] != null) {
      traitements = <Traitements>[];
      json['traitements'].forEach((v) {
        traitements!.add(Traitements.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pharmacy_phone'] = pharmacyPhone;
    data['total_traitements'] = totalTraitements;
    if (traitements != null) {
      data['traitements'] = traitements!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Traitements {
  String? pathologie;
  List<Medicaments>? medicaments;

  Traitements({this.pathologie, this.medicaments});

  Traitements.fromJson(Map<String, dynamic> json) {
    pathologie = json['pathologie'];
    if (json['medicaments'] != null) {
      medicaments = <Medicaments>[];
      json['medicaments'].forEach((v) {
        medicaments!.add(Medicaments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pathologie'] = pathologie;
    if (medicaments != null) {
      data['medicaments'] = medicaments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Medicaments {
  int? id;
  String? name;
  String? dosage;
  int? frequencyPerDay;
  int? quantityDelivered;
  String? dispensedAt;
  String? estimatedEndDate;
  double? daysRemaining;
  int? delayDays;
  String? status;
  String? statusColor;
  double? progress;

  Medicaments(
      {this.id,
        this.name,
        this.dosage,
        this.frequencyPerDay,
        this.quantityDelivered,
        this.dispensedAt,
        this.estimatedEndDate,
        this.daysRemaining,
        this.delayDays,
        this.status,
        this.statusColor,
        this.progress});

  Medicaments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    dosage = json['dosage'];
    frequencyPerDay = json['frequency_per_day'];
    quantityDelivered = json['quantity_delivered'];
    dispensedAt = json['dispensed_at'];
    estimatedEndDate = json['estimated_end_date'];
    daysRemaining = json['days_remaining'];
    delayDays = json['delay_days'];
    status = json['status'];
    statusColor = json['status_color'];
    progress = json['progress'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['dosage'] = dosage;
    data['frequency_per_day'] = frequencyPerDay;
    data['quantity_delivered'] = quantityDelivered;
    data['dispensed_at'] = dispensedAt;
    data['estimated_end_date'] = estimatedEndDate;
    data['days_remaining'] = daysRemaining;
    data['delay_days'] = delayDays;
    data['status'] = status;
    data['status_color'] = statusColor;
    data['progress'] = progress;
    return data;
  }
}