import 'dart:async';

import 'package:polkawallet_plugin_laminar/polkawallet_plugin_laminar.dart';
import 'package:polkawallet_plugin_laminar/store/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';

class ServiceSwap {
  ServiceSwap(this.plugin, this.keyring) : store = plugin.store;

  final PluginLaminar plugin;
  final Keyring keyring;
  final PluginStore store;

  final _syntheticPoolsSubscribeChannel = 'LaminarSyntheticPools';

  Future<Map> subscribeSyntheticPools() async {
    Completer<Map> c = new Completer<Map>();
    plugin.sdk.api.service.webView.subscribeMessage(
      'laminar.subscribeSyntheticPools(laminarApi, "$_syntheticPoolsSubscribeChannel")',
      _syntheticPoolsSubscribeChannel,
      (Map res) {
        store.swap.setSyntheticPoolInfo(res);
        if (List.of(res['options']).length > 0 && !c.isCompleted) {
          c.complete(res);
        }
      },
    );
    return c.future;
  }
}
