class TransactionsModel {
  int? id;
  String? category; // TRANSFERT | RECHARGEMENT | ABONNEMENT
  String? typeOperation; // DEBIT | CREDIT
  int? amount;
  String? date;

  String? label; // ← remplace libelle
  String? interlocuteurNom;
  String? type;

  String? senderUsername;
  String? receiverUsername;
  String? executeBy;

  String? description;
  int? duree;
  String? status;
  String? transactionId;
  String? paymentMethod;

  TransactionsModel({
    this.id,
    this.category,
    this.typeOperation,
    this.amount,
    this.date,
    this.label,
    this.interlocuteurNom,
    this.type,
    this.senderUsername,
    this.receiverUsername,
    this.executeBy,
    this.description,
    this.duree,
    this.status,
    this.transactionId,
    this.paymentMethod,
  });

  TransactionsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    category = json['category'];
    typeOperation = json['typeOperation'];
    amount = json['amount'];
    date = json['date'];

    label = json['label'];
    interlocuteurNom = json['interlocuteurNom'];
    type = json['type'];

    senderUsername = json['senderUsername'];
    receiverUsername = json['receiverUsername'];
    executeBy = json['executeBy'];

    description = json['description'];
    duree = json['duree'];
    status = json['status'];
    transactionId = json['transactionId'];
    paymentMethod = json['paymentMethod'];
  }
}