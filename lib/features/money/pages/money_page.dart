import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pharmaconsult/core/constants/constants.dart';
import 'package:pharmaconsult/core/utils/utils.dart';
import 'package:pharmaconsult/models/transactions/transaction_model.dart';
import 'package:sizer/sizer.dart';

import '../../../core/themes/themes.dart';

class MoneyPage extends StatefulWidget {
  const MoneyPage({super.key});

  @override
  State<MoneyPage> createState() => _MoneyPageState();
}

class _MoneyPageState extends State<MoneyPage> with TickerProviderStateMixin {
  late final TabController _tabController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<TransactionsModel>> fetchRequestTransactions() async {
    final http.Response response = await http.get(
      Uri.parse(
        ApiUrls.getTransactionsUrl(
          SharedPreferencesHelper().getString('phone')!,
        ),
      ),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(
        utf8.decode(response.bodyBytes),
      );

      List<TransactionsModel> communes =
          jsonResponse
              .map(
                (item) =>
                    TransactionsModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();

      return communes;
    } else {
      throw Exception("Une erreur s'est produite");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [appFondLogin, appWhite, appWhite],
            stops: [0.1, 0.4, .4],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                Container(
                  height: 35,
                  decoration: BoxDecoration(
                    color: appColorDivider,
                    borderRadius: BorderRadius.circular(6.w),
                  ),
                  child: TabBar(
                    tabAlignment: TabAlignment.start,
                    controller: _tabController,
                    indicatorColor: Colors.transparent,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.w),
                      color: appColor2,
                    ),
                    labelColor: appWhite,
                    indicatorSize: TabBarIndicatorSize.tab,
                    unselectedLabelColor: Colors.black,
                    isScrollable: true,
                    labelStyle: TextStyle(
                      color: appBlack,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: <Widget>[
                      Tab(text: "Tout"),
                      Tab(text: "Rechargements"),
                      Tab(text: "Transactions"),
                      Tab(text: "Souscriptions"),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<TransactionsModel>>(
                    future: fetchRequestTransactions(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text("Erreur : ${snapshot.error}"),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text("Aucune transaction disponible"),
                        );
                      }

                      final allTransactions = snapshot.data!;

                      return TabBarView(
                        controller: _tabController,
                        children: [
                          buildTransactionsList(allTransactions),
                          buildTransactionsList(
                            allTransactions
                                .where((t) => t.category == "RECHARGEMENT")
                                .toList(),
                          ),
                          buildTransactionsList(
                            allTransactions
                                .where((t) => t.category == "TRANSFERT")
                                .toList(),
                          ),
                          buildTransactionsList(
                            allTransactions
                                .where((t) => t.category == "ABONNEMENT")
                                .toList(),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String formatCustomDate(DateTime dateTime) {
    // Formatter la date
    final day = DateFormat('dd', 'fr_FR').format(dateTime);
    final month = DateFormat('MMMM', 'fr_FR').format(dateTime).toUpperCase();
    final year = DateFormat('yyyy', 'fr_FR').format(dateTime);

    // Formatter l'heure
    final hour = DateFormat('HH', 'fr_FR').format(dateTime);
    final minute = DateFormat('mm', 'fr_FR').format(dateTime);

    return "$day $month $year / ${hour}H : $minute";
  }

  Widget buildTransactionsList(List<TransactionsModel> transactions) {
    if (transactions.isEmpty) {
      return const Center(child: Text("Aucune transaction disponible"));
    }

    // Tri par date décroissante
    transactions.sort(
      (a, b) => DateTime.parse(b.date!).compareTo(DateTime.parse(a.date!)),
    );

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final date = DateTime.parse(tx.date!);

        // Choix de l'icône selon le type de transaction
        IconData iconData;
        Color iconColor;
        switch (tx.category) {
          case "TRANSFERT":
            iconData = Icons.swap_horiz;
            iconColor = Colors.orange;
            break;
          case "RECHARGEMENT":
            iconData = Icons.add_rounded;
            iconColor = Colors.green;
            break;
          case "ABONNEMENT":
            iconData = Icons.star;
            iconColor = appColorHtml;
            break;
          default:
            iconData = Icons.monetization_on_outlined;
            iconColor = appColor;
        }

        return Container(
          margin: EdgeInsets.only(top: 2.h),
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: appWhite,
            borderRadius: BorderRadius.circular(3.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Flutter
              CircleAvatar(
                radius: 20.sp,
                backgroundColor: iconColor.withValues(alpha: 0.2),
                child: Icon(iconData, size: 18.sp, color: iconColor),
              ),
              Gap(3.w),
              // Infos principales
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.label ?? "",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: appBlack,
                      ),
                    ),
                    if (tx.category == "TRANSFERT") ...[
                      Text(
                        tx.interlocuteurNom ?? "",
                        style: TextStyle(fontSize: 14.sp, color: appColorBlue),
                      ),
                      Text(
                        tx.description ?? "",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: appColorBlue.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                    if (tx.category == "ABONNEMENT") ...[
                      Text(
                        tx.description ?? "",
                        style: TextStyle(fontSize: 13.sp, color: appColorHtml),
                      ),
                    ],
                    Text(
                      formatCustomDate(date),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Montant
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${tx.amount ?? 0}",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: appBlack,
                    ),
                  ),
                  Text(
                    "FCFA",
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
