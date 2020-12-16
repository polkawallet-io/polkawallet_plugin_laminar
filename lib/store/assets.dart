import 'package:mobx/mobx.dart';
import 'package:polkawallet_plugin_laminar/store/cache/storeCache.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';

part 'assets.g.dart';

class AssetsStore extends _AssetsStore with _$AssetsStore {
  AssetsStore(StoreCache cache) : super(cache);
}

abstract class _AssetsStore with Store {
  _AssetsStore(this.cache);

  final StoreCache cache;
  final String cacheTxsTransferKey = 'transfer_txs';

  @observable
  Map<String, TokenBalanceData> tokenBalanceMap =
      Map<String, TokenBalanceData>();

  @observable
  Map<String, BigInt> prices = {};

  @action
  void setTokenBalanceMap(List<TokenBalanceData> list) {
    final data = Map<String, TokenBalanceData>();
    list.forEach((e) {
      data[e.symbol] = e;
    });
    tokenBalanceMap = data;
  }

  @action
  void setPrices(Map<String, BigInt> data) {
    prices = data;
  }
}
