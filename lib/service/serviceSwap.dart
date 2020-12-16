import 'package:polkawallet_plugin_laminar/common/constants.dart';
import 'package:polkawallet_plugin_laminar/polkawallet_plugin_laminar.dart';
import 'package:polkawallet_plugin_laminar/store/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_ui/utils/format.dart';

class ServiceSwap {
  ServiceSwap(this.plugin, this.keyring) : store = plugin.store;

  final PluginLaminar plugin;
  final Keyring keyring;
  final PluginStore store;
}
