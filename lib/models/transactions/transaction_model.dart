class TransactionsModel {
  int? id;
  int? walletId;
  String? username;
  double? amount;
  String? date;
  String? libelle;
  String? designation;
  String? typeOperation;
  String? description;
  String? nameOfSecondParty;
  String? numberOfSecondParty;

  TransactionsModel({
    this.id,
    this.walletId,
    this.username,
    this.amount,
    this.date,
    this.libelle,
    this.designation,
    this.typeOperation,
    this.description,
    this.nameOfSecondParty,
    this.numberOfSecondParty,
  });

  TransactionsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    walletId = json['walletId'];
    username = json['username'];
    amount = json['amount'];
    date = json['date'];
    libelle = json['libelle'];
    designation = json['designation'];
    typeOperation = json['typeOperation'];
    description = json['description'];
    nameOfSecondParty = json['nameOfSecondParty'] ?? "";
    numberOfSecondParty = json['numberOfSecondParty'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['walletId'] = walletId;
    data['username'] = username;
    data['amount'] = amount;
    data['date'] = date;
    data['libelle'] = libelle;
    data['designation'] = designation;
    data['typeOperation'] = typeOperation;
    data['description'] = description;
    data['nameOfSecondParty'] = nameOfSecondParty;
    data['numberOfSecondParty'] = numberOfSecondParty;
    return data;
  }
}
