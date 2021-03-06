import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_laminar/common/constants.dart';
import 'package:polkawallet_plugin_laminar/polkawallet_plugin_laminar.dart';
import 'package:polkawallet_plugin_laminar/store/types/laminarTxSwapData.dart';
import 'package:polkawallet_plugin_laminar/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/listTail.dart';

class LaminarSwapHistoryPage extends StatefulWidget {
  LaminarSwapHistoryPage(this.plugin, this.keyring);
  final PluginLaminar plugin;
  final Keyring keyring;

  static const String route = '/laminar/swap/txs';

  @override
  _LaminarSwapHistoryPageState createState() => _LaminarSwapHistoryPageState();
}

class _LaminarSwapHistoryPageState extends State<LaminarSwapHistoryPage> {
  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_laminar, 'laminar');
    return Scaffold(
      appBar: AppBar(
        title: Text(dic['dex.txs']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Observer(
          builder: (_) {
            final list = widget.plugin.store.swap.txs.reversed.toList();

            return ListView.builder(
              itemCount: list.length + 1,
              itemBuilder: (BuildContext context, int i) {
                if (i == list.length) {
                  return ListTail(isLoading: false, isEmpty: list.length == 0);
                }

                final LaminarTxSwapData detail = list[i];
                final bool isRedeem = detail.call == 'redeem';
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(width: 0.5, color: Colors.black12)),
                  ),
                  child: ListTile(
                    title: Text(
                        '${detail.call} ${isRedeem ? acala_stable_coin_view : detail.tokenId}'),
                    subtitle: Text(list[i].time.toString()),
                    trailing: Container(
                      width: 140,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Text(
                                '${detail.amountPay} ${isRedeem ? detail.tokenId : acala_stable_coin_view}',
                                style: Theme.of(context).textTheme.headline4,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ),
                          Image.asset(
                              'packages/polkawallet_plugin_laminar/assets/images/assets_up.png',
                              width: 16)
                        ],
                      ),
                    ),
//                        onTap: () {
//                          Navigator.pushNamed(context, LoanTxDetailPage.route,
//                              arguments: list[i]);
//                        },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
