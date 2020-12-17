import 'package:mobx/mobx.dart';
import 'package:polkawallet_plugin_laminar/common/constants.dart';
import 'package:polkawallet_plugin_laminar/store/cache/storeCache.dart';
import 'package:polkawallet_plugin_laminar/store/types/laminarSyntheticData.dart';
import 'package:polkawallet_plugin_laminar/store/types/laminarTxSwapData.dart';

part 'swap.g.dart';

class SwapStore extends _SwapStore with _$SwapStore {
  SwapStore(StoreCache cache) : super(cache);
}

abstract class _SwapStore with Store {
  _SwapStore(this.cache);

  final StoreCache cache;

  @observable
  ObservableList<LaminarTxSwapData> txs = ObservableList<LaminarTxSwapData>();

  @observable
  ObservableMap<String, LaminarSyntheticPoolInfoData> syntheticPoolInfo =
      ObservableMap();

  @computed
  List<LaminarSyntheticPoolTokenData> get syntheticTokens {
    List<LaminarSyntheticPoolTokenData> res = [];
    syntheticPoolInfo.keys.forEach((key) {
      final List<LaminarSyntheticPoolTokenData> ls =
          syntheticPoolInfo[key].options.toList();
      ls.retainWhere((e) => e.askSpread != null && e.bidSpread != null);
      res.addAll(ls);
    });
    return res;
  }

  @action
  void setSyntheticPoolInfo(Map info) {
    syntheticPoolInfo
        .addAll({info['poolId']: LaminarSyntheticPoolInfoData.fromJson(info)});
  }

  @action
  void addSwapTx(Map tx, String pubKey, int decimals) {
    txs.add(
        LaminarTxSwapData.fromJson(Map<String, dynamic>.from(tx), decimals));

    final cached = cache.swapTxs.val;
    List list = cached[pubKey];
    if (list != null) {
      list.add(tx);
    } else {
      list = [tx];
    }
    cached[pubKey] = list;
    cache.swapTxs.val = cached;
  }

  @action
  void loadCache(String pubKey) {
    if (pubKey == null || pubKey.isEmpty) return;

    final cached = cache.swapTxs.val;
    final list = cached[pubKey] as List;
    if (list != null) {
      txs = ObservableList<LaminarTxSwapData>.of(list.map((e) =>
          LaminarTxSwapData.fromJson(
              Map<String, dynamic>.from(e), laminar_token_decimals)));
    }
  }
}
