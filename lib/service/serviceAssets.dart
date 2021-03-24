import 'package:polkawallet_plugin_laminar/common/constants.dart';
import 'package:polkawallet_plugin_laminar/polkawallet_plugin_laminar.dart';
import 'package:polkawallet_plugin_laminar/store/index.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';

class ServiceAssets {
  ServiceAssets(this.plugin, this.keyring) : store = plugin.store;

  final PluginLaminar plugin;
  final Keyring keyring;
  final PluginStore store;

  final Map _tokenBalances = {};
  final _tokenBalanceChannel = 'tokenBalance';
  final _priceSubscribeChannel = 'LaminarPrices';

  Future<void> _subscribeTokenBalances(
      String address, List tokens, Function(Map) callback) async {
    tokens.forEach((e) {
      final channel = '$_tokenBalanceChannel$e';
      plugin.sdk.api.subscribeMessage(
        'api.query.tokens.accounts',
        [address, e],
        channel,
        (Map data) {
          callback({'symbol': e, 'balance': data});
        },
      );
    });
  }

  Future<void> subscribeTokenBalances(
      String address, Function(List<TokenBalanceData>) callback) async {
    final List tokens = [acala_stable_coin];
    tokens
        .addAll(plugin.networkConst['syntheticTokens']['syntheticCurrencyIds']);

    _tokenBalances.clear();

    await _subscribeTokenBalances(address, tokens, (Map data) {
      _tokenBalances[data['symbol']] = data;

      // do not callback if we did not receive enough data.
      if (_tokenBalances.keys.length < tokens.length) return;

      callback(_tokenBalances.values
          .map((e) => TokenBalanceData(
                name: e['symbol'],
                symbol: e['symbol'],
                decimals: 18,
                amount: e['balance']['free'].toString(),
              ))
          .toList());
    });
  }

  void unsubscribeTokenBalances(String address) async {
    final tokens =
        List.of(plugin.networkConst['syntheticTokens']['syntheticCurrencyIds']);
    tokens.forEach((e) {
      plugin.sdk.api.unsubscribeMessage('$_tokenBalanceChannel$e');
    });
  }

  Future<void> subscribeTokenPrices() async {
    await plugin.sdk.api.service.webView.subscribeMessage(
      'laminar.subscribeMessage(laminarApi, "currencies", "oracleValues", ["Aggregated"], "$_priceSubscribeChannel")',
      _priceSubscribeChannel,
      (List res) {
        store.assets.setTokenPrices(res);
      },
    );
  }
}
