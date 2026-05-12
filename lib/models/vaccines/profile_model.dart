class ProfileModel {
  int? idProfile;
  int? userId;
  String? name;
  String? profileType;
  String? relation;
  String? animalType;
  String? gender;
  String? birthDate;
  bool? isFrequentTraveler;
  bool? isActive;
  String? createdAt;
  int? vaccinationsCount;
  bool? hasActiveSubscription;
  ActiveSubscription? activeSubscription;

  ProfileModel({
    this.idProfile,
    this.userId,
    this.name,
    this.profileType,
    this.relation,
    this.animalType,
    this.gender,
    this.birthDate,
    this.isFrequentTraveler,
    this.isActive,
    this.createdAt,
    this.vaccinationsCount,
    this.hasActiveSubscription,
    this.activeSubscription,
  });

  ProfileModel.fromJson(Map<String, dynamic> json) {
    idProfile = json['id_profile'];
    userId = json['user_id'];
    name = json['name'];
    profileType = json['profile_type'];
    relation = json['relation'];
    animalType = json['animal_type'];
    gender = json['gender'];
    birthDate = json['birth_date'];
    isFrequentTraveler = json['is_frequent_traveler'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
    vaccinationsCount = json['vaccinations_count'];
    hasActiveSubscription = json['has_active_subscription'];
    activeSubscription =
        json['active_subscription'] != null
            ? ActiveSubscription.fromJson(json['active_subscription'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id_profile'] = idProfile;
    data['user_id'] = userId;
    data['name'] = name;
    data['profile_type'] = profileType;
    data['relation'] = relation;
    data['animal_type'] = animalType;
    data['gender'] = gender;
    data['birth_date'] = birthDate;
    data['is_frequent_traveler'] = isFrequentTraveler;
    data['is_active'] = isActive;
    data['created_at'] = createdAt;
    data['vaccinations_count'] = vaccinationsCount;
    data['has_active_subscription'] = hasActiveSubscription;
    if (activeSubscription != null) {
      data['active_subscription'] = activeSubscription!.toJson();
    }
    return data;
  }
}

class ActiveSubscription {
  int? idSubscription;
  int? profileId;
  int? userId;
  int? amount;
  String? currency;
  String? status;
  String? startDate;
  String? endDate;
  String? paymentReference;
  String? paymentMethod;
  String? paidAt;
  String? createdAt;
  String? updatedAt;

  ActiveSubscription({
    this.idSubscription,
    this.profileId,
    this.userId,
    this.amount,
    this.currency,
    this.status,
    this.startDate,
    this.endDate,
    this.paymentReference,
    this.paymentMethod,
    this.paidAt,
    this.createdAt,
    this.updatedAt,
  });

  ActiveSubscription.fromJson(Map<String, dynamic> json) {
    idSubscription = json['id_subscription'];
    profileId = json['profile_id'];
    userId = json['user_id'];
    amount = json['amount'];
    currency = json['currency'];
    status = json['status'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    paymentReference = json['payment_reference'];
    paymentMethod = json['payment_method'] ?? 'GRATUIT';
    paidAt = json['paid_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id_subscription'] = idSubscription;
    data['profile_id'] = profileId;
    data['user_id'] = userId;
    data['amount'] = amount;
    data['currency'] = currency;
    data['status'] = status;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['payment_reference'] = paymentReference;
    data['payment_method'] = paymentMethod;
    data['paid_at'] = paidAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }

  bool get isGracious {
    return paymentReference == 'FREE-FIRST-PROFILE';
  }

  int get daysRemaining {

    if (endDate == null) {
      return 0;
    }

    try {

      final end = DateTime.parse(endDate!);

      return end.difference(DateTime.now()).inDays;

    } catch (_) {

      return 0;
    }
  }
}
