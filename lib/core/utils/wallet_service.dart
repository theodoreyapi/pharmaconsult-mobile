import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pharmaconsult/core/constants/constants.dart';
import 'package:pharmaconsult/core/utils/utils.dart';

class WalletService {
  Timer? _timer;

  void startListening(Function(double) onUpdate) {
    // Appel toutes les 5 secondes
    _timer = Timer.periodic(Duration(seconds: 10), (_) async {
      final url = Uri.parse(
        "${ApiUrls.getCheckWalletUrl}${SharedPreferencesHelper().getString('phone')}",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAmount = data["amount"]?.toDouble() ?? 0.0;
        onUpdate(newAmount); // callback pour mettre à jour ton UI
      }
    });
  }

  void stopListening() {
    _timer?.cancel();
  }
}
