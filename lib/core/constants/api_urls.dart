class ApiUrls {
  ApiUrls._();

  // Change base URL
  static const bool change = true;

  // Base URL
  static const baseUrlProd = "https://admin.pharma-consults.com";
  static const baseUrlTest = "http://new-version.sodalite-consulting.com";

  // Pour obtenir la bonne base URL
  static String get baseUrl => change ? baseUrlProd : baseUrlTest;
  static String get internalAuth => "$baseUrl/api/internal/v1/auth";
  static String get internalUser => "$baseUrl/api/internal/v1/user";
  static String get internal => "$baseUrl/api/internal/v1";

  static String get internalPharma => "$baseUrl/api/internal/v1/pharma";
  static String get internalMedicament => "$baseUrl/api/internal/v1/requests-medicament";
  static String get internalRequest => "$baseUrl/api/internal/v1/request-pharmacies";
  static String get internalGarde => "$baseUrl/api/internal/v1/periodes-garde";

  // Authentication
  static String get postLoginUrl => "$internalAuth/login";
  static String get postGenerateTokenUrl => "$internalAuth/generateToken";
  static String get postRegisterUrl => "$internalUser/save";
  static String get postValidateOtpUrl => "$internalUser/otp/validate";
  static String get postGenerateOtpUrl => "$internalUser/otp/generate";
  static String get postChangePasswordUrl => "$internalUser/reinitialiser/password";

  // Communes
  static String get getListCity => "$internalPharma/communes/search";
  static String get getListCommune => "$internalPharma/communes";
  static String get postAddNotice => "$internalPharma/notices/add";
  static String getListNotice(int id) => "$internalPharma/notices/get/$id";

  static String getListPharmaByCity(int id) =>
      "$internalPharma/pharmacies/gardeIntervalByCommune?communeId=$id";
  static String get getListDate => internalGarde;

  // Médicaments
  static String get getMedicamentUrl => "$internalPharma/medicaments/search";
  static String get postRequestUrl => internalMedicament;
  static String getRequestUrl(String username) => "$internalMedicament/user/$username";
  static String get postSendRequestUrl => "$internal/reservations-medicament/create";
  static String getRequestPharmacyUrl(int id) => "$internalRequest/request/$id";
  static String getReserveRequestUrl(String username) => "$internal/reservations-medicament/user/$username";

  // Assurance
  static String get getAssureUrl => "$internalPharma/assurances/getAll";
  static String getPharmaAssureUrl(int id) => "$internalPharma/pharmacies/$id/pharmacies";

  // Forfaits
  static String getForfaitUrl(String forfait) => "$internalPharma/forfaits/byModuleName/$forfait";

  // Profile
  static String get putUpdateProfileUrl => "$internalUser/update";
  static String get putUpdatePictureProfileUrl => "$internalUser/updateProfilePicture";
  static String get postUpdatePasswordProfileUrl => "$internalUser/changePassword";

  // Token Notification
  static String get postNotificationUrl => "$internal/notifications/register";

  // Publicities
  static String get getAdsUrl => "$internal/publicites/get/actives";

  // Transactions
  static String getTransactionsUrl(String username) => "$internalPharma/operations/byUsername/$username";
  static String get postSendMoneyUrl => "$internalPharma/transfers/process";
  static String getCheckUserUrl(String username) => "$internal/user/getUserByUsername/$username";

  // CINETPAY
  static String get postIntialUrl => "$internalPharma/cinetpay/payment";
  //static String get getIntialUrl => "$internalPharma/rechargements/initier";
  static String getCheckWalletUrl(String username) => "$internalPharma/wallet/getWalletByUserName/$username";

  // SOUSCRIPTIONS
  static String get postSubscribeUrl => "$internalPharma/subscriptions/subscribe";
  static String getCheckAllSubscribeUrl(String username) => "$internalPharma/subscriptions/valid/$username";
  static String getCheckByModuleSubscribeUrl(String username) => "$internalPharma/subscriptions/valid/module/$username";

  // GENERAUX
  static String get getAboutUrl => "$internalPharma/parametres-generaux/getbyType/APROPOS";
  static String get getPolicyUrl => "$internalPharma/parametres-generaux/getbyType/POLITIQUE CONFIDENTIALITES";
  static String get getConditionUrl => "$internalPharma/parametres-generaux/getbyType/CONDITIONS GENERALES";
  static String get getHelpUrl => "$internalPharma/parametres-generaux/getbyType/AIDE";
  static String get getMentionUrl => "$internalPharma/parametres-generaux/getbyType/MENTIONS LEGALES";

  // VACCINS
  static String get getVaccine => "$internal/vaccins";
  static String get getCategories => "$internal/vaccins/categories";
  static String get postAppointments => "$internal/vaccins/appointments";
  static String getCheckByAppointmentsUrl(String identifiant) => "$internal/vaccins/appointments/$identifiant";
  static String getListVaccinByTypesUrl(String type) => "$internal/vaccins/type/$type";

  // PROFIL VACCINS
  static String getListProfile(String identifiant) => "$internal/health-profiles/$identifiant";
  static String get postCreateProfile => "$internal/health-profiles";
  static String putUpdateProfile(int profileId) => "$internal/health-profiles/$profileId";
  static String deleteProfile(int profileId) => "$internal/health-profiles/$profileId";
  static String getListVaccinationByProfile(int profileId, String userId) => "$internal/health-profiles/$profileId/vaccinations?id_user=$userId";
  static String postUpdateVaccinationByProfile(int profileId, String userId, int vaccinationId) => "$internal/health-profiles/$profileId/vaccinations/$vaccinationId?id_user=$userId";
  static String postCreateVaccinationByProfile(int profileId) => "$internal/health-profiles/$profileId/vaccinations";
  static String deleteVaccinationByProfile(int profileId, String userId, int vaccinationId) => "$internal/health-profiles/$profileId/vaccinations/$vaccinationId?id_user=$userId";
  static String getCalendarByProfile(int profileId) => "$internal/health-profiles/calendar/$profileId";
  static String get postRemindersByProfile => "$internal/health-profiles/reminders/store";
  static String getRemindersByIdentifiant(String identifiant) => "$internal/health-profiles/reminders-category/$identifiant";

  // PROFIL SUIVI SANTE
  static String getListMesure(String identifiant) => "$internal/patients/$identifiant/dashboard-mesures";
  static String getListBilan(String identifiant, String start, String end) => "$internal/patients/$identifiant/bilan?start_date=$start&end_date=$end";
  static String getListTraitement(String identifiant) => "$internal/patients/$identifiant/traitements";
  static String getRappel(String identifiant) => "$internal/patients/$identifiant/rappel";
  static String getNotification(String identifiant) => "$internal/patients/$identifiant/notifications";
  static String getPharmacyByPatient(String identifiant) => "$internal/patients/$identifiant/pharmacy";
  static String getVerifyPatient(String cmu) => "$internal/patients/cmu/$cmu";
  static String getConseil(String cmu) => "$internal/conseils?cmu=$cmu";
  static String getCampagne(String pharmacieId) => "$internal/campagnes/$pharmacieId";
}