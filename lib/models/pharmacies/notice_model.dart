class NoticesModel {
  List<Notices>? notices;
  Rating? ratingSummary;

  NoticesModel({this.notices, this.ratingSummary});

  NoticesModel.fromJson(Map<String, dynamic> json) {
    if (json['notices'] != null) {
      notices = <Notices>[];
      json['notices'].forEach((v) {
        notices!.add(Notices.fromJson(v));
      });
    }
    ratingSummary = json['ratingSummary'] != null
        ? Rating.fromJson(json['ratingSummary'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (notices != null) {
      data['notices'] = notices!.map((v) => v.toJson()).toList();
    }
    if (ratingSummary != null) {
      data['ratingSummary'] = ratingSummary!.toJson();
    }
    return data;
  }
}

class Notices {
  int? id;
  int? note;
  String? userName;
  String? userPicture;
  String? dateNotice;
  String? details;
  int? pharmacyId;

  Notices(
      {this.id,
        this.note,
        this.userName,
        this.userPicture,
        this.dateNotice,
        this.details,
        this.pharmacyId});

  Notices.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    note = json['note'];
    userName = json['userName'];
    userPicture = json['userPicture'] ?? '';
    dateNotice = json['dateNotice'];
    details = json['details'];
    pharmacyId = json['pharmacyId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['note'] = note;
    data['userName'] = userName;
    data['userPicture'] = userPicture;
    data['dateNotice'] = dateNotice;
    data['details'] = details;
    data['pharmacyId'] = pharmacyId;
    return data;
  }
}

class Rating {
  int? counter;
  double? average;
  int? counterFiveStars;
  int? counterFourStars;
  int? counterThreeStars;
  int? counterTwoStars;
  int? counterOneStars;

  Rating(
      {this.counter,
        this.average,
        this.counterFiveStars,
        this.counterFourStars,
        this.counterThreeStars,
        this.counterTwoStars,
        this.counterOneStars});

  Rating.fromJson(Map<String, dynamic> json) {
    counter = json['counter'] ?? 0;
    average = json['average'] ?? 0;
    counterFiveStars = json['counterFiveStars'] ?? 0;
    counterFourStars = json['counterFourStars'] ?? 0;
    counterThreeStars = json['counterThreeStars'] ?? 0;
    counterTwoStars = json['counterTwoStars'] ?? 0;
    counterOneStars = json['counterOneStars'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['counter'] = counter;
    data['average'] = average;
    data['counterFiveStars'] = counterFiveStars;
    data['counterFourStars'] = counterFourStars;
    data['counterThreeStars'] = counterThreeStars;
    data['counterTwoStars'] = counterTwoStars;
    data['counterOneStars'] = counterOneStars;
    return data;
  }
}
