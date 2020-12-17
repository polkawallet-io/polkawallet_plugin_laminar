import 'package:mobx/mobx.dart';
import 'package:polkawallet_plugin_laminar/store/cache/storeCache.dart';
import 'package:polkawallet_plugin_laminar/store/types/laminarMarginData.dart';

part 'margin.g.dart';

class MarginStore extends _MarginStore with _$MarginStore {
  MarginStore(StoreCache cache) : super(cache);
}

abstract class _MarginStore with Store {
  _MarginStore(this.cache);

  final StoreCache cache;

  @observable
  ObservableMap<String, LaminarMarginPoolInfoData> marginPoolInfo =
      ObservableMap();

  @observable
  ObservableMap<String, LaminarMarginTraderInfoData> marginTraderInfo =
      ObservableMap();

  @computed
  List<LaminarMarginPairData> get marginTokens {
    List<LaminarMarginPairData> res = [];
    marginPoolInfo.keys.forEach((key) {
      res.addAll(marginPoolInfo[key].options);
    });
    return res;
  }

  @action
  void setMarginPoolInfo(Map info) {
    marginPoolInfo
        .addAll({info['poolId']: LaminarMarginPoolInfoData.fromJson(info)});
  }

  @action
  void setMarginTraderInfo(Map info) {
    marginTraderInfo
        .addAll({info['poolId']: LaminarMarginTraderInfoData.fromJson(info)});
  }
}
