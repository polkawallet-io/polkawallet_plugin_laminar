import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/entryPageCard.dart';
import 'package:polkawallet_plugin_laminar/polkawallet_plugin_laminar.dart';
import 'package:polkawallet_plugin_laminar/utils/i18n/index.dart';

class LaminarEntry extends StatefulWidget {
  LaminarEntry(this.plugin, this.keyring);

  final PluginLaminar plugin;
  final Keyring keyring;

  @override
  _LaminarEntryState createState() => _LaminarEntryState();
}

class _LaminarEntryState extends State<LaminarEntry> {
  bool _faucetSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_laminar, 'laminar');
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    dic['flow'] ?? 'Flow Exchange',
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).cardColor,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Observer(
                builder: (_) {
                  if (widget.plugin.sdk.api.connectedNode == null) {
                    return Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.width / 2),
                      child: Column(
                        children: [
                          CupertinoActivityIndicator(),
                          Text(I18n.of(context).getDic(i18n_full_dic_laminar,
                              'common')['node.connecting']),
                        ],
                      ),
                    );
                  }
                  return ListView(
                    padding: EdgeInsets.all(16),
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          child: EntryPageCard(
                            dic['flow.swap'],
                            dic['flow.swap.brief'],
                            SvgPicture.asset(
                                'packages/polkawallet_plugin_laminar/assets/images/swap.svg',
                                height: 56),
                            color: Theme.of(context).primaryColor,
                          ),
                          // onTap: () => Navigator.of(context)
                          //     .pushNamed(LaminarSwapPage.route),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          child: EntryPageCard(
                            dic['flow.margin'],
                            dic['flow.margin.brief'],
                            SvgPicture.asset(
                                'packages/polkawallet_plugin_laminar/assets/images/loan.svg',
                                height: 56),
                            color: Theme.of(context).primaryColor,
                          ),
                          // onTap: () => Navigator.of(context)
                          //     .pushNamed(LaminarMarginPage.route),
                        ),
                      ),
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
