class NotificationModel {
  int? id;
  String? notificationType;
  String? type;
  String? message;
  String? status;
  String? auteur;
  String? createdAt;

  NotificationModel({
    this.id,
    this.notificationType,
    this.type,
    this.message,
    this.status,
    this.auteur,
    this.createdAt,
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    notificationType = json['notification_type'];
    type = json['type'];
    message = json['message'];
    status = json['status'];
    auteur = json['auteur'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['notification_type'] = notificationType;
    data['type'] = type;
    data['message'] = message;
    data['status'] = status;
    data['auteur'] = auteur;
    data['created_at'] = createdAt;
    return data;
  }
}
