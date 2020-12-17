import 'dart:async';

import 'package:polkawallet_plugin_laminar/common/constants.dart';
import 'package:polkawallet_plugin_laminar/polkawallet_plugin_laminar.dart';
import 'package:polkawallet_plugin_laminar/store/index.dart';
import 'package:polkawallet_plugin_laminar/store/types/laminarCurrenciesData.dart';
import 'package:polkawallet_plugin_laminar/store/types/laminarMarginData.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_ui/utils/format.dart';

class ServiceMargin {
  ServiceMargin(this.plugin, this.keyring) : store = plugin.store;

  final PluginLaminar plugin;
  final Keyring keyring;
  final PluginStore store;

  final _marginPoolsSubscribeChannel = 'LaminarMarginPools';
  final _marginTraderInfoSubscribeChannel = 'LaminarMarginTraderInfo';

  Future<Map> subscribeMarginPools() async {
    Completer<Map> c = new Completer<Map>();
    plugin.sdk.api.service.webView.subscribeMessage(
      'laminar.subscribeMarginPools(laminarApi, "$_marginPoolsSubscribeChannel")',
      _marginPoolsSubscribeChannel,
      (Map res) {
        store.margin.setMarginPoolInfo(res);
        if (List.of(res['options']).length > 0 && !c.isCompleted) {
          c.complete(res);
        }
      },
    );
    return c.future;
  }

  Future<Map> subscribeMarginTraderInfo() async {
    final address = keyring.current.address;
    Completer<Map> c = new Completer<Map>();
    plugin.sdk.api.service.webView.subscribeMessage(
      'laminar.subscribeMarginTraderInfo(laminarApi, "$address", "$_marginTraderInfoSubscribeChannel")',
      _marginTraderInfoSubscribeChannel,
      (Map res) {
        store.margin.setMarginTraderInfo(res);
        if (!c.isCompleted) {
          c.complete(res);
        }
      },
    );
    return c.future;
  }

  BigInt _getTokenPrice(Map<String, LaminarPriceData> prices, String symbol) {
    if (symbol == acala_stable_coin) {
      return laminarIntDivisor;
    }
    final LaminarPriceData priceData = prices[symbol];
    if (priceData == null) {
      return BigInt.zero;
    }
    return Fmt.balanceInt(priceData.value ?? '0');
  }

  BigInt getPairPriceInt(
      Map<String, LaminarPriceData> prices, LaminarMarginPairData pairData) {
    final BigInt priceBase = _getTokenPrice(prices, pairData.pair.base);
    final BigInt priceQuote = _getTokenPrice(prices, pairData.pair.quote);
    BigInt priceInt = BigInt.zero;
    if (priceBase != BigInt.zero && priceQuote != BigInt.zero) {
      priceInt = priceBase * laminarIntDivisor ~/ priceQuote;
    }

    return priceInt;
  }

  BigInt getTradePriceInt({
    Map<String, LaminarPriceData> prices,
    LaminarMarginPairData pairData,
    String direction,
    BigInt priceInt,
  }) {
    final BigInt spreadAsk = Fmt.balanceInt(pairData.askSpread.toString());
    final BigInt spreadBid = Fmt.balanceInt(pairData.bidSpread.toString());
    BigInt price = priceInt ?? getPairPriceInt(prices, pairData);

    return direction == 'long' ? price + spreadAsk : price - spreadBid;
  }
}
