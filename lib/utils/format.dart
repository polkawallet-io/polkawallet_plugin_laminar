import 'package:polkawallet_plugin_laminar/common/constants.dart';

class PluginFmt {
  static String tokenView(String token) {
    String tokenView = token ?? '';
    if (token == acala_stable_coin) {
      tokenView = acala_stable_coin_view;
    }
    return tokenView;
  }
}
