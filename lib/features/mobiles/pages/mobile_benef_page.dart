import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:gap/gap.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/themes/themes.dart';
import '../../../core/widgets/widgets.dart';
import '../mobiles.dart';

class MobileBenefPage extends StatefulWidget {
  const MobileBenefPage({super.key});

  @override
  State<MobileBenefPage> createState() => _MobileBenefPageState();
}

class _MobileBenefPageState extends State<MobileBenefPage> {
  var number = TextEditingController();

  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];
  bool isLoading = false;
  bool permissionDenied = false;

  @override
  void initState() {
    super.initState();
    loadContacts();
    number.addListener(() {
      filterContacts(number.text);
    });
  }

  Future<void> loadContacts() async {
    setState(() {
      isLoading = true;
      permissionDenied = false;
    });

    final status = await Permission.contacts.request();
    if (status.isGranted) {
      try {
        contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: true,
        );
        filteredContacts = contacts;
      } catch (e) {}
    } else {
      permissionDenied = true;
    }

    setState(() => isLoading = false);
  }

  void filterContacts(String query) {
    final result =
        contacts.where((contact) {
          final name = contact.displayName.toLowerCase();
          final phone =
              contact.phones.isNotEmpty ? contact.phones.first.number : '';
          return name.contains(query.toLowerCase()) || phone.contains(query);
        }).toList();

    setState(() {
      filteredContacts = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bénéficiaire"), backgroundColor: appWhite),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputText(
                hintText: "Nom ou Numéro de téléphone",
                colorFille: appWhite,
                keyboardType: TextInputType.text,
                controller: number,
                prefixIcon: Icon(Icons.search_outlined, color: appBlack),
                validatorMessage: "Veuillez saisir numéro ou nom",
              ),
              Card(
                surfaceTintColor: appWhite,
                color: appWhite,
                child: ListTile(
                  onTap: () async {
                    String? enteredNumber = await showDialog<String>(
                      context: context,
                      barrierDismissible: false, // ⛔️ Empêche de fermer en cliquant dehors
                      builder: (context) {
                        final TextEditingController numberController = TextEditingController();
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3.w),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3.w),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.phone_iphone_outlined,
                                    size: 48, color: appColor),
                                Gap(1.h),
                                Text(
                                  "Entrer un numéro",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: appBlack,
                                  ),
                                ),
                                Gap(1.5.h),
                                InputText(
                                  hintText: "Ex: 0700000000",
                                  keyboardType: TextInputType.phone,
                                  controller: numberController,
                                  prefixIcon: Icon(Icons.phone, color: appColor),
                                  validatorMessage: "Veuillez saisir numéro",
                                ),
                                Gap(2.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: appColor),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(3.w),
                                        ),
                                      ),
                                      child: Text("Annuler",
                                          style: TextStyle(color: appColor)),
                                    ),
                                    Gap(1.w),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (numberController.text.isNotEmpty) {
                                          Navigator.pop(context, numberController.text);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: appColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(3.w),
                                        ),
                                      ),
                                      child: Text("Valider",
                                          style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );

                    if (enteredNumber != null && enteredNumber.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MobileAmountPage(
                            phoneNumber: enteredNumber,
                            type: "trans",
                          ),
                        ),
                      );
                    }
                  },
                  leading: Icon(Icons.numbers_outlined, color: appColorBlue),
                  title: Text(
                    "Saisir numéro de téléphone",
                    style: TextStyle(
                      color: appColorBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                  subtitle: Text(
                    "Si le numéro ne se trouve pas dans vos contacts",
                    style: TextStyle(
                      color: appColor,
                      fontWeight: FontWeight.normal,
                      fontSize: 12.sp,
                    ),
                  ),
                  trailing: Icon(
                    Icons.navigate_next_outlined,
                    color: appColorBlue,
                  ),
                ),
              ),
              Gap(2.h),
              Text("Mes contacts"),
              Expanded(
                child:
                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        : permissionDenied
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Permission refusée'),
                              ElevatedButton(
                                onPressed: openAppSettings,
                                child: Text('Ouvrir les paramètres'),
                              ),
                              ElevatedButton(
                                onPressed: loadContacts,
                                child: Text('Réessayer'),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          itemCount: filteredContacts.length,
                          itemBuilder: (context, index) {
                            final contact = filteredContacts[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 1.w),
                              decoration: BoxDecoration(
                                color: appWhite,
                                border: Border.all(
                                  color: appColor.withValues(alpha: .12),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(3.w),
                              ),
                              child: ListTile(
                                onTap: () {
                                  String phoneNumber = contact.phones.isNotEmpty
                                      ? contact.phones.first.number
                                      : '';

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MobileAmountPage(
                                        phoneNumber: phoneNumber,
                                        type: "trans",
                                      ),
                                    ),
                                  );
                                },
                                leading:
                                    contact.photo != null
                                        ? CircleAvatar(
                                          backgroundImage: MemoryImage(
                                            contact.photo!,
                                          ),
                                        )
                                        : CircleAvatar(
                                          backgroundColor: Colors.grey
                                              .withValues(alpha: .2),
                                          child: Text(
                                            "${contact.displayName[0]}"
                                            "${contact.displayName[1]}",
                                            style: TextStyle(
                                              color: appBlack,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                title: Text(
                                  contact.displayName,
                                  style: TextStyle(
                                    color: appBlack,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  contact.phones.isNotEmpty
                                      ? contact.phones.first.number
                                      : 'Aucun numéro',
                                  style: TextStyle(
                                    color: appColor,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.navigate_next_outlined,
                                  color: appColor,
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: appColor,
        onPressed: loadContacts,
        child: Icon(Icons.refresh, color: appWhite),
      ),
    );
  }
}
