class AppointmentModel {
  final int?    idAppointment;
  final String? reference;
  final String? patientName;
  final String? patientPhone;
  final String? patientEmail;
  final String? appointmentDate;
  final String? status;
  final String? notes;
  final String? createdAt;
  final String? confirmedAt;
  final String? cancelledAt;

  // Vaccin
  final int?    idVaccine;
  final String? vaccineName;
  final String? shortName;
  final String? publicPrice;
  final String? privatePriceMin;
  final String? privatePriceMax;
  final String? description;
  final String? importantInfo;
  final String? currency;

  // Pharmacie
  final int?    idPharmacy;
  final String? pharmacyName;
  final String? address;
  final String? phoneNumber;
  final String? whatsAppPhoneNumber;
  final String? openingHours;
  final String? closingHours;

  const AppointmentModel({
    this.idAppointment,
    this.reference,
    this.patientName,
    this.patientPhone,
    this.patientEmail,
    this.appointmentDate,
    this.status,
    this.notes,
    this.createdAt,
    this.confirmedAt,
    this.cancelledAt,
    this.idVaccine,
    this.vaccineName,
    this.shortName,
    this.publicPrice,
    this.privatePriceMin,
    this.privatePriceMax,
    this.description,
    this.importantInfo,
    this.currency,
    this.idPharmacy,
    this.pharmacyName,
    this.address,
    this.phoneNumber,
    this.whatsAppPhoneNumber,
    this.openingHours,
    this.closingHours,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      idAppointment      : json['id_appointment'],
      reference          : json['reference'],
      patientName        : json['patient_name'],
      patientPhone       : json['patient_phone'],
      patientEmail       : json['patient_email'],
      appointmentDate    : json['appointment_date'],
      status             : json['status'],
      notes              : json['notes'],
      createdAt          : json['created_at'],
      confirmedAt        : json['confirmed_at'],
      cancelledAt        : json['cancelled_at'],
      idVaccine          : json['id_vaccine'],
      vaccineName        : json['vaccine_name'],
      shortName          : json['short_name'],
      publicPrice        : json['public_price']?.toString(),
      privatePriceMin    : json['private_price_min']?.toString(),
      privatePriceMax    : json['private_price_max']?.toString(),
      description        : json['description'],
      importantInfo      : json['important_info'],
      currency           : json['currency'],
      idPharmacy         : json['id_pharmacy'],
      pharmacyName       : json['pharmacy_name'],
      address            : json['address'],
      phoneNumber        : json['phone_number'],
      whatsAppPhoneNumber: json['whats_app_phone_number'],
      openingHours       : json['opening_hours'],
      closingHours       : json['closing_hours'],
    );
  }
}