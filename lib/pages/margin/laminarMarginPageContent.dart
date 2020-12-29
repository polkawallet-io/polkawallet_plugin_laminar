import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_laminar/common/constants.dart';
import 'package:polkawallet_plugin_laminar/pages/margin/laminarMarginTradePairSelector.dart';
import 'package:polkawallet_plugin_laminar/pages/margin/laminarMarginTradePanel.dart';
import 'package:polkawallet_plugin_laminar/pages/margin/laminarMarginTraderInfoPanel.dart';
import 'package:polkawallet_plugin_laminar/polkawallet_plugin_laminar.dart';
import 'package:polkawallet_plugin_laminar/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/utils/format.dart';

class LaminarMarginPageContent extends StatefulWidget {
  LaminarMarginPageContent(this.plugin, this.keyring,
      {this.child, this.onRefresh});

  final PluginLaminar plugin;
  final Keyring keyring;
  final Widget child;
  final Future<void> Function() onRefresh;

  @override
  _LaminarMarginPageContentState createState() =>
      _LaminarMarginPageContentState();
}

class _LaminarMarginPageContentState extends State<LaminarMarginPageContent> {
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();

  String _poolId = '1';
  String _pairId = 'BTCUSD';

  int _leverageIndex = 0;

  Future<void> _fetchData() async {
    widget.plugin.service.margin.subscribeMarginPools();
    await widget.plugin.service.margin.subscribeMarginTraderInfo();
    widget.onRefresh();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshKey.currentState.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_laminar, 'laminar');
    final decimals = widget.plugin.networkState.tokenDecimals;
    return Scaffold(
      appBar: AppBar(title: Text(dic['flow.margin']), centerTitle: true),
      body: SafeArea(
        child: Observer(
          builder: (_) {
            final String balance = Fmt.balance(
              widget.plugin.store.margin.marginPoolInfo[_poolId]?.balance ??
                  '0',
              decimals,
            );
            final poolInfo = widget.plugin.store.margin.marginPoolInfo[_poolId];

            return RefreshIndicator(
              key: _refreshKey,
              onRefresh: _fetchData,
              child: Container(
                color: Theme.of(context).cardColor,
                child: ListView(
                  children: <Widget>[
                    ListTile(
                      title: Text(_pairId),
                      subtitle: Text(
                        '${margin_pool_name_map[_poolId]} $balance aUSD',
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (_) => LaminarMarginTradePairSelector(
                            widget.plugin,
                            initialPoolId: _poolId,
                            initialPairId: _pairId,
                            onSelect: (pool, pair) {
                              setState(() {
                                _poolId = pool;
                                _pairId = pair;
                                _leverageIndex = 0;
                              });
                            },
                          ),
                        );
                      },
                    ),
                    Divider(height: 2),
                    LaminarTraderInfoPanel(
                      balanceInt: Fmt.balanceInt(widget.plugin.store.assets
                              .tokenBalanceMap[acala_stable_coin]?.amount ??
                          '0'),
                      info:
                          widget.plugin.store.margin.marginTraderInfo[_poolId],
                      decimals: decimals,
                      onRefresh: _fetchData,
                    ),
                    poolInfo != null
                        ? LaminarMarginTradePanel(
                            widget.plugin,
                            info: widget
                                .plugin.store.margin.marginTraderInfo[_poolId],
                            decimals: decimals,
                            pairData: widget.plugin.store.margin
                                .marginPoolInfo[_poolId].options
                                .firstWhere((e) {
                              return e.pairId == _pairId;
                            }),
                            priceMap: widget.plugin.store.assets.tokenPrices,
                            leverageIndex: _leverageIndex,
                            onLeverageChange: (int i) {
                              setState(() {
                                _leverageIndex = i;
                              });
                            },
                            onRefresh: widget.onRefresh,
                          )
                        : Container(),
                    Divider(height: 2),
                    widget.child,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
