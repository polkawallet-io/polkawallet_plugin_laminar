import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/currencyWithIcon.dart';
import 'package:polkawallet_plugin_laminar/polkawallet_plugin_laminar.dart';
import 'package:polkawallet_plugin_laminar/utils/i18n/index.dart';

class CurrencySelectPage extends StatelessWidget {
  CurrencySelectPage(this.plugin);
  final PluginLaminar plugin;
  static const String route = '/assets/currency';

  @override
  Widget build(BuildContext context) {
    final List currencyIds = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context)
            .getDic(i18n_full_dic_laminar, 'common')['currency.select']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          children: currencyIds.map((i) {
            return ListTile(
              title: CurrencyWithIcon(
                i,
                TokenIcon(i, plugin.tokenIcons),
                textStyle: Theme.of(context).textTheme.headline4,
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 18,
              ),
              onTap: () {
                Navigator.of(context).pop(i);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class TokenIcon extends StatelessWidget {
  TokenIcon(this.symbol, this.tokenIcons);
  final String symbol;
  final Map<String, Widget> tokenIcons;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: tokenIcons[symbol.toUpperCase()] ??
          CircleAvatar(
            child: Text(symbol.toUpperCase().substring(0, 2)),
          ),
      width: 32,
      height: 32,
    );
  }
}
