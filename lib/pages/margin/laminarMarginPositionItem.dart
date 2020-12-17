import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_laminar/common/constants.dart';
import 'package:polkawallet_plugin_laminar/pages/margin/laminarMarginTradePnl.dart';
import 'package:polkawallet_plugin_laminar/service/index.dart';
import 'package:polkawallet_plugin_laminar/store/types/laminarCurrenciesData.dart';
import 'package:polkawallet_plugin_laminar/store/types/laminarMarginData.dart';
import 'package:polkawallet_plugin_laminar/utils/i18n/index.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/infoItem.dart';
import 'package:polkawallet_ui/components/outlinedButtonSmall.dart';
import 'package:polkawallet_ui/components/textTag.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/pages/txConfirmPage.dart';
import 'package:polkawallet_ui/utils/format.dart';

class LaminarMarginPosition extends StatelessWidget {
  LaminarMarginPosition(
    this.service,
    this.position,
    this.pairData,
    this.prices, {
    this.closed,
    this.decimals,
    this.onRefresh,
  });

  final PluginService service;
  final LaminarMarginPairData pairData;
  final Map<String, LaminarPriceData> prices;
  final Map position;
  final Map closed;
  final int decimals;
  final Future<void> Function() onRefresh;

  String getLeverage(String str) {
    final bool isLong = RegExp(r'^Long(.*)$').hasMatch(str);
    return laminar_leverage_map[isLong ? str.substring(4) : str.substring(5)];
  }

  Future<void> _onClose(
    BuildContext context,
    int positionId,
    String direction,
  ) async {
    final params = [
      // params.poolId
      positionId,
      // params.price
      direction == 'long'
          ? '0'
          : Fmt.tokenInt('100000000', decimals).toString(),
    ];
    final res = (await Navigator.of(context).pushNamed(TxConfirmPage.route,
        arguments: TxConfirmParams(
          module: 'marginProtocol',
          call: 'closePosition',
          txTitle: I18n.of(context)
              .getDic(i18n_full_dic_laminar, 'laminar')['margin.close'],
          txDisplay: {"positionId": positionId},
          params: params,
        ))) as Map;
    if (res != null) {
      onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (pairData == null) return Container();

    final dic = I18n.of(context).getDic(i18n_full_dic_laminar, 'laminar');
    final String direction =
        RegExp(r'^Long(.*)$').hasMatch(position['args'][4]) ? 'long' : 'short';
    final leverage = getLeverage(position['args'][4]);
    final int positionId = position['args'][1];

    final amtInt = BigInt.parse(position['args'][5].toString());
    final String amt = Fmt.token(
      amtInt,
      decimals,
    );
    final rawPriceQuote = Fmt.balanceInt(prices[pairData.pair.quote]?.value);
    final BigInt openPriceInt = BigInt.parse(position['args'][6].toString());
    final String openPrice = Fmt.token(
      openPriceInt,
      decimals,
      length: 5,
    );
    final BigInt currentPriceInt = service.margin.getTradePriceInt(
      prices: prices,
      pairData: pairData,
      direction: direction == 'long' ? 'short' : 'long',
    );
    final bool isClosed = closed != null;
    final BigInt closePriceInt =
        isClosed ? BigInt.parse(closed['args'][3]) : BigInt.zero;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 36,
          child: Row(
            children: <Widget>[
              TextTag(
                direction,
                color: direction == 'long' ? Colors.green : Colors.red,
                fontSize: 12,
                padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                margin: EdgeInsets.only(right: 8),
              ),
              Expanded(
                child: Text(
                    '${pairData.pairId} ($leverage) #${positionId.toString()}'),
              ),
              isClosed
                  ? Container()
                  : OutlinedButtonSmall(
                      content: dic['margin.close'],
                      onPressed: () => _onClose(context, positionId, direction),
                    )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 8),
          child: Row(
            children: <Widget>[
              InfoItem(
                title: '${dic['margin.amount']}(${pairData.pair.base})',
                content: amt,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      isClosed ? dic['margin.pnl.close'] : dic['margin.pnl'],
                      style: TextStyle(fontSize: 12),
                    ),
                    LaminarMarginTradePnl(
                      pairData: pairData,
                      decimals: decimals,
                      amount: amtInt,
                      rawPriceQuote: rawPriceQuote,
                      openPrice: openPriceInt,
                      closePrice: isClosed ? closePriceInt : currentPriceInt,
                      isShort: direction != 'long',
                    )
                  ],
                ),
              ),
              InfoItem(
                title: isClosed
                    ? dic['margin.price.close']
                    : dic['margin.price.now'],
                content: Fmt.token(
                  isClosed ? closePriceInt : currentPriceInt,
                  decimals,
                  length: 5,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 8),
          child: Row(
            children: <Widget>[
              InfoItem(
                title: 'TxHash',
                content: Fmt.address(position['extrinsic']['hash'], pad: 4),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      dic['margin.time'],
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(DateTime.fromMillisecondsSinceEpoch(
                            position['block']['timestamp'])
                        .toString()
                        .split('.')[0]),
                  ],
                ),
              ),
              InfoItem(
                title: dic['margin.price.open'],
                content: openPrice,
              ),
            ],
          ),
        ),
        Divider(height: 24),
      ],
    );
  }
}
