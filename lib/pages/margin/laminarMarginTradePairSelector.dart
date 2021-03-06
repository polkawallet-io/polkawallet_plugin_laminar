import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_laminar/common/constants.dart';
import 'package:polkawallet_plugin_laminar/polkawallet_plugin_laminar.dart';
import 'package:polkawallet_plugin_laminar/store/types/laminarCurrenciesData.dart';
import 'package:polkawallet_plugin_laminar/store/types/laminarMarginData.dart';
import 'package:polkawallet_ui/utils/format.dart';

class LaminarMarginTradePairSelector extends StatefulWidget {
  LaminarMarginTradePairSelector(
    this.plugin, {
    this.initialPoolId,
    this.initialPairId,
    this.onSelect,
  });

  final PluginLaminar plugin;
  final String initialPoolId;
  final String initialPairId;
  final Function(String, String) onSelect;
  @override
  _LaminarMarginTradePairSelectorState createState() =>
      _LaminarMarginTradePairSelectorState();
}

class _LaminarMarginTradePairSelectorState
    extends State<LaminarMarginTradePairSelector> {
  String _poolId;

  BigInt _getPrice(String symbol) {
    if (symbol == acala_stable_coin) {
      return BigInt.parse('1000000000000000000');
    }
    final LaminarPriceData priceData =
        widget.plugin.store.assets.tokenPrices[symbol];
    if (priceData == null) {
      return BigInt.zero;
    }
    return Fmt.balanceInt(
        widget.plugin.store.assets.tokenPrices[symbol]?.value ?? '0');
  }

  Widget _formatPrice(String price, {bool highlight = false}) {
    final TextStyle style = TextStyle(
      fontSize: 12,
      color: highlight
          ? Theme.of(context).primaryColor
          : Theme.of(context).unselectedWidgetColor,
      decoration: TextDecoration.none,
    );
    final TextStyle styleBold = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: highlight
          ? Theme.of(context).primaryColor
          : Theme.of(context).unselectedWidgetColor,
      decoration: TextDecoration.none,
    );
    return Row(
      children: <Widget>[
        Text(price.substring(0, price.length - 3), style: style),
        Text(
          price.substring(price.length - 3, price.length - 1),
          style: styleBold,
        ),
        Text(price.substring(price.length - 1), style: style),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle styleHeader = TextStyle(
      fontSize: 12,
      color: Theme.of(context).unselectedWidgetColor,
      decoration: TextDecoration.none,
    );
    return Observer(
      builder: (_) {
        final decimals = (widget.plugin.networkState.tokenDecimals ?? [18])[0];
        final poolId = _poolId ?? widget.initialPoolId;
        final List<LaminarMarginPairData> pairs =
            widget.plugin.store.margin.marginPoolInfo[poolId].options.toList();
        pairs.retainWhere((e) => e.askSpread != null && e.bidSpread != null);
        return Container(
          height: MediaQuery.of(context).copyWith().size.height / 2,
          color: Theme.of(context).cardColor,
          child: Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 8, left: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8.0, // has the effect of softening the shadow
                      spreadRadius: 2.0, // ha
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: margin_pool_name_map.keys.map((e) {
                    return GestureDetector(
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              width: 2,
                              color: e == poolId
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).cardColor,
                            ),
                          ),
                        ),
                        child: Text(
                          margin_pool_name_map[e],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: e == poolId
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).unselectedWidgetColor,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _poolId = e;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('symbol', style: styleHeader),
                          Text('bid', style: styleHeader),
                          Text('ask', style: styleHeader),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8, right: 8),
                      child: Divider(height: 2),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: pairs.length,
                        itemBuilder: (_, int i) {
                          final Color primaryColor =
                              Theme.of(context).primaryColor;
                          final TextStyle styleHighlight = TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                            decoration: TextDecoration.none,
                          );
                          final isCurrentPair =
                              pairs[i].pairId == widget.initialPairId;
                          final BigInt spreadAsk =
                              Fmt.balanceInt(pairs[i].askSpread.toString());
                          final BigInt spreadBid =
                              Fmt.balanceInt(pairs[i].bidSpread.toString());
                          final BigInt priceBase =
                              _getPrice(pairs[i].pair.base);
                          final BigInt priceQuote =
                              _getPrice(pairs[i].pair.quote);
                          BigInt price = BigInt.zero;
                          if (priceBase != BigInt.zero &&
                              priceQuote != BigInt.zero) {
                            price = priceBase *
                                BigInt.parse('1000000000000000000') ~/
                                priceQuote;
                          }
                          return GestureDetector(
                            child: Container(
                              padding: EdgeInsets.only(bottom: 20),
                              color: Theme.of(context).cardColor,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    pairs[i].pairId,
                                    style: isCurrentPair
                                        ? styleHighlight
                                        : styleHeader,
                                  ),
                                  price == BigInt.zero
                                      ? Text('-',
                                          style: isCurrentPair
                                              ? styleHighlight
                                              : styleHeader)
                                      : _formatPrice(
                                          Fmt.priceFloorBigInt(
                                            price - spreadBid,
                                            decimals,
                                            lengthFixed: 5,
                                          ),
                                          highlight: isCurrentPair),
                                  price == BigInt.zero
                                      ? Text('-',
                                          style: isCurrentPair
                                              ? styleHighlight
                                              : styleHeader)
                                      : _formatPrice(
                                          Fmt.priceCeilBigInt(
                                            price + spreadAsk,
                                            decimals,
                                            lengthFixed: 5,
                                          ),
                                          highlight: isCurrentPair),
                                ],
                              ),
                            ),
                            onTap: () {
                              if (price == BigInt.zero) return;
                              widget.onSelect(poolId, pairs[i].pairId);
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
