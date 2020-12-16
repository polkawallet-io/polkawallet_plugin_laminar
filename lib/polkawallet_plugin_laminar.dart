library polkawallet_plugin_laminar;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:polkawallet_plugin_laminar/pages/swap/laminarSwapHistoryPage.dart';
import 'package:polkawallet_plugin_laminar/pages/swap/laminarSwapPage.dart';
import 'package:polkawallet_sdk/api/types/networkParams.dart';
import 'package:polkawallet_sdk/plugin/homeNavItem.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_ui/pages/accountQrCodePage.dart';
import 'package:polkawallet_ui/pages/txConfirmPage.dart';
import 'package:polkawallet_plugin_laminar/pages/currencySelectPage.dart';
import 'package:polkawallet_plugin_laminar/pages/laminarEntry.dart';
import 'package:polkawallet_plugin_laminar/store/cache/storeCache.dart';
import 'package:polkawallet_plugin_laminar/store/index.dart';
import 'package:polkawallet_plugin_laminar/service/index.dart';
import 'package:polkawallet_plugin_laminar/common/constants.dart';

class PluginLaminar extends PolkawalletPlugin {
  @override
  final basic = PluginBasicData(
    name: 'laminar',
    ss58: 42,
    primaryColor: Colors.deepPurple,
    icon: Image.asset(
        'packages/polkawallet_plugin_laminar/assets/images/logo.png'),
    iconDisabled: Image.asset(
        'packages/polkawallet_plugin_laminar/assets/images/logo_gray.png'),
  );

  @override
  List<NetworkParams> get nodeList {
    return node_list.map((e) => NetworkParams.fromJson(e)).toList();
  }

  @override
  Map<String, Widget> get tokenIcons => {
        'LAMI': Image.asset(
            'packages/polkawallet_plugin_laminar/assets/images/LAMI.png'),
        'AUSD': Image.asset(
            'packages/polkawallet_plugin_laminar/assets/images/AUSD.png'),
      };

  @override
  List<HomeNavItem> getNavItems(BuildContext context, Keyring keyring) {
    return [
      HomeNavItem(
        text: 'Flow',
        icon: Image(
            image: AssetImage('assets/images/flow_dark.png',
                package: 'polkawallet_plugin_laminar')),
        iconActive: Image(
            image: AssetImage('assets/images/flow.png',
                package: 'polkawallet_plugin_laminar')),
        content: LaminarEntry(this, keyring),
      )
    ];
  }

  @override
  Map<String, WidgetBuilder> getRoutes(Keyring keyring) {
    return {
      TxConfirmPage.route: (_) =>
          TxConfirmPage(this, keyring, _service.getPassword),
      CurrencySelectPage.route: (_) => CurrencySelectPage(this),
      AccountQrCodePage.route: (_) => AccountQrCodePage(this, keyring),

      // TokenDetailPage.route: (_) => TokenDetailPage(this, keyring),
      // TransferPage.route: (_) => TransferPage(this, keyring),

      // swap pages
      LaminarSwapPage.route: (_) => LaminarSwapPage(this, keyring),
      LaminarSwapHistoryPage.route: (_) =>
          LaminarSwapHistoryPage(this, keyring),
    };
  }

  @override
  Future<String> loadJSCode() => rootBundle.loadString(
      'packages/polkawallet_plugin_laminar/lib/js_service_laminar/dist/main.js');

  final StoreCache _cache = StoreCache();
  PluginStore _store;
  PluginService _service;
  PluginStore get store => _store;
  PluginService get service => _service;

  Future<void> _subscribeTokenBalances(KeyPairData acc) async {
    _service.assets.subscribeTokenBalances(acc.address, (data) {
      balances.setTokens(data);
      _store.assets.setTokenBalanceMap(data);
    });
  }

  void _loadCacheData(KeyPairData acc) {
    balances.setTokens([]);

    _store.swap.loadCache(acc.pubKey);
  }

  @override
  Future<void> onWillStart(Keyring keyring) async {
    await GetStorage.init(laminar_plugin_cache_key);

    _store = PluginStore(_cache);
    _loadCacheData(keyring.current);

    _service = PluginService(this, keyring);
  }

  @override
  Future<void> onStarted(Keyring keyring) async {
    _service.connected = true;

    _service.assets.subscribeTokenPrices();
    if (keyring.current.address != null) {
      _subscribeTokenBalances(keyring.current);
    }
  }

  @override
  Future<void> onAccountChanged(KeyPairData acc) async {
    _loadCacheData(acc);

    if (_service.connected) {
      _service.assets.unsubscribeTokenBalances(acc.address);
      _subscribeTokenBalances(acc);
    }
  }
}
