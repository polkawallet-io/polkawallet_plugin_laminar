import 'package:polkawallet_plugin_laminar/store/assets.dart';
import 'package:polkawallet_plugin_laminar/store/cache/storeCache.dart';
import 'package:polkawallet_plugin_laminar/store/swap.dart';

class PluginStore {
  PluginStore(StoreCache cache)
      : assets = AssetsStore(cache),
        swap = SwapStore(cache);
  final AssetsStore assets;
  final SwapStore swap;
}
