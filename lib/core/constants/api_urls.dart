class ApiUrls {
  ApiUrls._();

  // Change base URL
  static const bool change = false;

  // Base URL
  static const baseUrlProd = "http://candidat.aptiotalent.com/api";
  static const baseUrlTest = "http://pharma-consults.com:9091";

  // Pour obtenir la bonne base URL
  static String get baseUrl => change ? baseUrlProd : baseUrlTest;
  static String get internalAuth => "$baseUrl/api/internal/v1/auth";
  static String get internalUser => "$baseUrl/api/internal/v1/user";
  static String get internal => "$baseUrl/api/internal/v1";

  static String get internalPharma => "$baseUrl/api/internal/v1/pharma";
  static String get internalMedicament => "$baseUrl/api/internal/v1/requests-medicament";
  static String get internalRequest => "$baseUrl/api/internal/vi/request-pharmacies";
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
  static String get postAddNotice => "$internalPharma/notices/add";
  static String get getListNotice => "$internalPharma/notices/get/";

  static String get getListPharmaByCity =>
      "$internalPharma/pharmacies/gardeIntervalByCommune?";
  static String get getListDate => internalGarde;

  // Médicaments
  static String get getMedicamentUrl => "$internalPharma/medicaments/search";
  static String get postRequestUrl => internalMedicament;
  static String get getRequestUrl => "$internalMedicament/user/";
  static String get postSendRequestUrl => "$internal/reservations-medicament/create";
  static String get getRequestPharmacyUrl => "$internalRequest/request/";
  static String get getReserveRequestUrl => "$internal/reservations-medicament/user/";

  // Assurance
  static String get getAssureUrl => "$internalPharma/assurances/getAll";
  static String get getPharmaAssureUrl => "$internalPharma/pharmacies/";

  // Forfaits
  static String get getForfaitUrl => "$internalPharma/forfaits/byModuleName/";

  // Profile
  static String get putUpdateProfileUrl => "$internalUser/update";
  static String get putUpdatePictureProfileUrl => "$internalUser/updateProfilePicture";
  static String get postUpdatePasswordProfileUrl => "$internalUser/changePassword";

  // Token Notification
  static String get postNotificationUrl => "$internal/notifications/register";

  // Publicities
  static String get getAdsUrl => "$internal/publicites/get/actives";

  // Transactions
  static String get getTransactionsUrl => "$internalPharma/operations/byUsername/";
  static String get postSendMoneyUrl => "$internalPharma/transfers/process";
  static String get getCheckUserUrl => "$internal/user/getUserByUsername/";

  // CINETPAY
  static String get getIntialUrl => "$internalPharma/cinetpay/payment";
  //static String get getIntialUrl => "$internalPharma/rechargements/initier";
  static String get getCheckWalletUrl => "$internalPharma/wallet/getWalletByUserName/";

  // SOUSCRIPTIONS
  static String get postSubscribeUrl => "$internalPharma/subscriptions/subscribe";
  static String get getCheckAllSubscribeUrl => "$internalPharma/subscriptions/valid/";
  static String get getCheckByModuleSubscribeUrl => "$internalPharma/subscriptions/valid/module/";

  // GENERAUX
  static String get getAboutUrl => "$internalPharma/parametres-generaux/getbyType/APROPOS";
  static String get getPolicyUrl => "$internalPharma/parametres-generaux/getbyType/POLITIQUE CONFIDENTIALITES";
  static String get getConditionUrl => "$internalPharma/parametres-generaux/getbyType/CONDITIONS GENERALES";
  static String get getHelpUrl => "$internalPharma/parametres-generaux/getbyType/AIDE";
  static String get getMentionUrl => "$internalPharma/parametres-generaux/getbyType/MENTIONS LEGALES";
}