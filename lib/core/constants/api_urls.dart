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
}