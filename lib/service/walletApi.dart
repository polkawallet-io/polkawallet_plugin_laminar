import 'dart:convert';

import 'package:http/http.dart';

class WalletApi {
  static Future<String> getLaminarTokens(String address) async {
    try {
      Response res = await post(
        Uri.parse('https://laminar-faucet.herokuapp.com/faucet/web-endpoint'),
        headers: {"Content-type": "application/json"},
        body: jsonEncode({"address": address}),
      );
      if (res.statusCode == 200) {
        return utf8.decode(res.bodyBytes);
      }
      return null;
    } catch (err) {
      print(err);
      return null;
    }
  }
}
