import 'package:polkawallet_plugin_laminar/store/assets.dart';
import 'package:polkawallet_plugin_laminar/store/cache/storeCache.dart';

class PluginStore {
  PluginStore(StoreCache cache) : assets = AssetsStore(cache);
  final AssetsStore assets;
}
