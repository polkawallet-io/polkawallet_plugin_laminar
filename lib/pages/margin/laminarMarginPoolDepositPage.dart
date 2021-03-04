import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_laminar/common/constants.dart';
import 'package:polkawallet_plugin_laminar/polkawallet_plugin_laminar.dart';
import 'package:polkawallet_plugin_laminar/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/addressFormItem.dart';
import 'package:polkawallet_ui/components/infoItemRow.dart';
import 'package:polkawallet_ui/components/roundedButton.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/pages/txConfirmPage.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/i18n.dart';
import 'package:polkawallet_ui/utils/index.dart';

class LaminarMarginPoolDepositPageParams {
  LaminarMarginPoolDepositPageParams({this.poolId, this.isWithdraw = false});
  String poolId;
  bool isWithdraw;
}

class LaminarMarginPoolDepositPage extends StatefulWidget {
  LaminarMarginPoolDepositPage(this.plugin, this.keyring);
  final PluginLaminar plugin;
  final Keyring keyring;

  static const String route = '/laminar/margin/pool';

  @override
  _LaminarMarginPoolDepositPageState createState() =>
      _LaminarMarginPoolDepositPageState();
}

class _LaminarMarginPoolDepositPageState
    extends State<LaminarMarginPoolDepositPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountCtrl = new TextEditingController();

  Future<void> _onSubmit() async {
    if (_formKey.currentState.validate()) {
      final decimals = (widget.plugin.networkState.tokenDecimals ?? [18])[0];
      final LaminarMarginPoolDepositPageParams args =
          ModalRoute.of(context).settings.arguments;
      final String amt = _amountCtrl.text.trim();

      final params = [
        // params.poolId
        args.poolId,
        // params.amount
        Fmt.tokenInt(amt, decimals).toString(),
      ];
      final res = (await Navigator.of(context).pushNamed(TxConfirmPage.route,
          arguments: TxConfirmParams(
            module: 'marginProtocol',
            call: args.isWithdraw ? 'withdraw' : 'deposit',
            txTitle: I18n.of(context).getDic(i18n_full_dic_laminar, 'laminar')[
                args.isWithdraw ? 'margin.withdraw' : 'margin.deposit'],
            txDisplay: {
              "pool": margin_pool_name_map[args.poolId],
              "amount": '$amt aUSD',
            },
            params: params,
          ))) as Map;
      if (res != null) {
        Navigator.of(context).pop(res);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final LaminarMarginPoolDepositPageParams params =
          ModalRoute.of(context).settings.arguments;
      if (params.isWithdraw) {
        widget.plugin.service.margin.subscribeMarginTraderInfo();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_laminar, 'laminar');
    final dicAssets = I18n.of(context).getDic(i18n_full_dic_laminar, 'common');
    final LaminarMarginPoolDepositPageParams params =
        ModalRoute.of(context).settings.arguments;
    final decimals = (widget.plugin.networkState.tokenDecimals ?? [18])[0];
    final balance = params.isWithdraw
        ? Fmt.balanceDouble(
            widget
                .plugin.store.margin.marginTraderInfo[params.poolId].freeMargin,
            decimals)
        : Fmt.balanceDouble(
            widget
                .plugin.store.assets.tokenBalanceMap[acala_stable_coin].amount,
            decimals);
    return Scaffold(
      appBar: AppBar(
        title: Text(
            params.isWithdraw ? dic['margin.withdraw'] : dic['margin.deposit']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16),
                children: <Widget>[
                  AddressFormItem(
                    widget.keyring.current,
                    label:
                        params.isWithdraw ? dicAssets['to'] : dicAssets['from'],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: InfoItemRow(
                      dic['margin.pool'],
                      margin_pool_name_map[params.poolId],
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: dicAssets['amount'],
                        labelText:
                            '${dicAssets['amount']} (${dicAssets['amount.available']} ${balance.toStringAsFixed(3)} aUSD)',
                        suffix: GestureDetector(
                          child: Icon(
                            CupertinoIcons.clear_thick_circled,
                            color: Theme.of(context).disabledColor,
                            size: 18,
                          ),
                          onTap: () {
                            WidgetsBinding.instance.addPostFrameCallback(
                                (_) => _amountCtrl.clear());
                          },
                        ),
                      ),
                      inputFormatters: [UI.decimalInputFormatter(decimals)],
                      controller: _amountCtrl,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v.isEmpty) {
                          return dicAssets['amount.error'];
                        }
                        if (double.parse(v.trim()) > balance) {
                          return dicAssets['amount.low'];
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: RoundedButton(
                text: I18n.of(context)
                    .getDic(i18n_full_dic_ui, 'common')['tx.submit'],
                onPressed: () => _onSubmit(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
