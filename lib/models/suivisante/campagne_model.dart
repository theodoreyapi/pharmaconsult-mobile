class CampagneModel {
  int? idCampagne;
  String? name;
  String? description;
  String? status;
  String? portee;
  String? channel;
  String? messageTemplate;
  String? scheduledAt;
  String? startedAt;
  String? endedAt;
  int? patientsCount;
  int? pathologieId;
  int? pharmacyId;
  int? createdBy;
  String? createdAt;
  String? updatedAt;
  String? pathologieCode;
  String? pathologieName;
  String? pharmacyName;

  CampagneModel({
    this.idCampagne,
    this.name,
    this.description,
    this.status,
    this.portee,
    this.channel,
    this.messageTemplate,
    this.scheduledAt,
    this.startedAt,
    this.endedAt,
    this.patientsCount,
    this.pathologieId,
    this.pharmacyId,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.pathologieCode,
    this.pathologieName,
    this.pharmacyName,
  });

  CampagneModel.fromJson(Map<String, dynamic> json) {
    idCampagne = json['id_campagne'];
    name = json['name'];
    description = json['description'];
    status = json['status'];
    portee = json['portee'];
    channel = json['channel'];
    messageTemplate = json['message_template'];
    scheduledAt = json['scheduled_at'];
    startedAt = json['started_at'];
    endedAt = json['ended_at'];
    patientsCount = json['patients_count'];
    pathologieId = json['pathologie_id'];
    pharmacyId = json['pharmacy_id'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    pathologieCode = json['pathologie_code'];
    pathologieName = json['pathologie_name'];
    pharmacyName = json['pharmacy_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id_campagne'] = idCampagne;
    data['name'] = name;
    data['description'] = description;
    data['status'] = status;
    data['portee'] = portee;
    data['channel'] = channel;
    data['message_template'] = messageTemplate;
    data['scheduled_at'] = scheduledAt;
    data['started_at'] = startedAt;
    data['ended_at'] = endedAt;
    data['patients_count'] = patientsCount;
    data['pathologie_id'] = pathologieId;
    data['pharmacy_id'] = pharmacyId;
    data['created_by'] = createdBy;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['pathologie_code'] = pathologieCode;
    data['pathologie_name'] = pathologieName;
    data['pharmacy_name'] = pharmacyName;
    return data;
  }
}
