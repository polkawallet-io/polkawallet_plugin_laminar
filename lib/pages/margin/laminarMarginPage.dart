import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:polkawallet_plugin_laminar/pages/margin/laminarMarginPageContent.dart';
import 'package:polkawallet_plugin_laminar/pages/margin/laminarMarginPositionItem.dart';
import 'package:polkawallet_plugin_laminar/polkawallet_plugin_laminar.dart';
import 'package:polkawallet_plugin_laminar/store/types/laminarCurrenciesData.dart';
import 'package:polkawallet_plugin_laminar/store/types/laminarMarginData.dart';
import 'package:polkawallet_plugin_laminar/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/listTail.dart';
import 'package:polkawallet_ui/components/outlinedButtonSmall.dart';

class LaminarMarginPage extends StatefulWidget {
  LaminarMarginPage(this.plugin, this.keyring);
  final PluginLaminar plugin;
  final Keyring keyring;

  static const String route = '/laminar/margin';

  @override
  _LaminarMarginPageState createState() => _LaminarMarginPageState();
}

class _LaminarMarginPageState extends State<LaminarMarginPage> {
  int _positionTab = 0;

  final String openedPositionQuery = r'''
          subscription positionsSubscription($signer: String!) {
            Events(
              order_by: { phaseIndex: desc }
              where: {
                method: { _eq: "PositionOpened" }
                extrinsic: { result: { _eq: "ExtrinsicSuccess" }, signer: { _eq: $signer } }
              }
            ) {
              args
              block {
                timestamp
              }
              extrinsic {
                hash
              }
            }
          }
        ''';

  final String closedPositionQuery = r'''
          subscription positionsSubscription($signer: jsonb!) {
            Events(
              order_by: { phaseIndex: desc }
              where: {
                method: { _eq: "PositionClosed" }
                args: { _contains: $signer }
                extrinsic: { result: { _eq: "ExtrinsicSuccess" } }
              }
            ) {
              args
              block {
                timestamp
              }
              extrinsic {
                hash
              }
            }
          }
        ''';

  void _changeTab(int tab, Future<QueryResult> Function() refetch,
      Future<QueryResult> Function() refetchClosed) {
    if (_positionTab != tab) {
      refetch();
      refetchClosed();
      setState(() {
        _positionTab = tab;
      });
    }
  }

  LaminarMarginPairData _getPairData(Map position) {
    final int pairIndex =
        widget.plugin.store.margin.marginTokens.indexWhere((i) {
      return i.poolId == position['args'][2].toString() &&
          i.pair.base == position['args'][3]['base'] &&
          i.pair.quote == position['args'][3]['quote'];
    });
    if (pairIndex < 0) {
      return null;
    }
    return widget.plugin.store.margin.marginTokens[pairIndex];
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_laminar, 'laminar');
    return Query(
      options: QueryOptions(
        document: gql(openedPositionQuery),
        variables: <String, String>{
          'signer': widget.keyring.current.address,
        },
      ),
      builder: (
        QueryResult result, {
        Future<QueryResult> Function() refetch,
        FetchMore fetchMore,
      }) {
        // print(JsonEncoder.withIndent('  ').convert(result.data));
        final Future<QueryResult> Function() refreshOpened = refetch;
        return Query(
          options: QueryOptions(
            document: gql(closedPositionQuery),
            variables: <String, String>{
              'signer': widget.keyring.current.address,
            },
          ),
          builder: (
            QueryResult resultClosed, {
            Future<QueryResult> Function() refetch,
            FetchMore fetchMore,
          }) {
            Future<void> _refreshData() async {
              Timer(Duration(seconds: 2), () {
                refreshOpened();
                refetch();
              });
            }

            return Observer(
              builder: (_) {
                final decimals =
                    (widget.plugin.networkState.tokenDecimals ?? [18])[0];
                final Map<String, LaminarPriceData> priceMap =
                    widget.plugin.store.assets.tokenPrices;
                Widget render;
                if (result.hasException || resultClosed.hasException) {
                  render = Text(result.exception.toString());
                } else if (result.data == null ||
                    resultClosed.data == null ||
                    widget.plugin.store.margin.marginTokens.length == 0) {
                  render = const Center(
                    child: CupertinoActivityIndicator(),
                  );
                } else {
//            print(JsonEncoder.withIndent('  ').convert(resultClosed.data));
                  final List listAll = List.of(result.data['Events']);
                  final List list = List.of(result.data['Events']);
                  list.retainWhere((e) {
                    final int positionId = e['args'][1];
                    return List.of(resultClosed.data['Events']).indexWhere((c) {
                          return c['args'][1] == positionId;
                        }) <
                        0;
                  });
                  final List listClosed = List.of(resultClosed.data['Events']);
                  render = Column(
                    children: <Widget>[
                      Container(
                        color: Theme.of(context).cardColor,
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                OutlinedButtonSmall(
                                  content: dic['margin.position'],
                                  active: _positionTab == 0,
                                  margin: EdgeInsets.only(right: 16),
                                  onPressed: () =>
                                      _changeTab(0, refreshOpened, refetch),
                                ),
                                OutlinedButtonSmall(
                                  content: dic['margin.position.closed'],
                                  active: _positionTab == 1,
                                  onPressed: () =>
                                      _changeTab(1, refreshOpened, refetch),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: _positionTab == 1
                              ? listAll.length == 0 || listClosed.length == 0
                                  ? <Widget>[
                                      ListTail(
                                        isEmpty: true,
                                        isLoading: false,
                                      )
                                    ]
                                  : listClosed.reversed.map((c) {
                                      final positionIndex =
                                          listAll.indexWhere((e) {
                                        return e['args'][1] == c['args'][1];
                                      });
                                      if (positionIndex < 0) {
                                        return Container();
                                      }
                                      final position = listAll[positionIndex];
                                      final LaminarMarginPairData pairData =
                                          _getPairData(position);
                                      return LaminarMarginPosition(
                                        widget.plugin.service,
                                        position,
                                        pairData,
                                        priceMap,
                                        closed: c,
                                        decimals: decimals,
                                        onRefresh: _refreshData,
                                      );
                                    }).toList()
                              : list.length == 0
                                  ? <Widget>[
                                      ListTail(
                                        isEmpty: true,
                                        isLoading: false,
                                      )
                                    ]
                                  : list.map((e) {
                                      final LaminarMarginPairData pairData =
                                          _getPairData(e);
                                      return LaminarMarginPosition(
                                        widget.plugin.service,
                                        e,
                                        pairData,
                                        priceMap,
                                        decimals: decimals,
                                        onRefresh: _refreshData,
                                      );
                                    }).toList(),
                        ),
                      )
                    ],
                  );
                }
                return LaminarMarginPageContent(
                  widget.plugin,
                  widget.keyring,
                  onRefresh: _refreshData,
                  child: render,
                );
              },
            );
          },
        );
      },
    );
  }
}
