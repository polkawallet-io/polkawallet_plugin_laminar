// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'margin.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$MarginStore on _MarginStore, Store {
  Computed<List<LaminarMarginPairData>> _$marginTokensComputed;

  @override
  List<LaminarMarginPairData> get marginTokens => (_$marginTokensComputed ??=
          Computed<List<LaminarMarginPairData>>(() => super.marginTokens,
              name: '_MarginStore.marginTokens'))
      .value;

  final _$marginPoolInfoAtom = Atom(name: '_MarginStore.marginPoolInfo');

  @override
  ObservableMap<String, LaminarMarginPoolInfoData> get marginPoolInfo {
    _$marginPoolInfoAtom.reportRead();
    return super.marginPoolInfo;
  }

  @override
  set marginPoolInfo(ObservableMap<String, LaminarMarginPoolInfoData> value) {
    _$marginPoolInfoAtom.reportWrite(value, super.marginPoolInfo, () {
      super.marginPoolInfo = value;
    });
  }

  final _$marginTraderInfoAtom = Atom(name: '_MarginStore.marginTraderInfo');

  @override
  ObservableMap<String, LaminarMarginTraderInfoData> get marginTraderInfo {
    _$marginTraderInfoAtom.reportRead();
    return super.marginTraderInfo;
  }

  @override
  set marginTraderInfo(
      ObservableMap<String, LaminarMarginTraderInfoData> value) {
    _$marginTraderInfoAtom.reportWrite(value, super.marginTraderInfo, () {
      super.marginTraderInfo = value;
    });
  }

  final _$_MarginStoreActionController = ActionController(name: '_MarginStore');

  @override
  void setMarginPoolInfo(Map<dynamic, dynamic> info) {
    final _$actionInfo = _$_MarginStoreActionController.startAction(
        name: '_MarginStore.setMarginPoolInfo');
    try {
      return super.setMarginPoolInfo(info);
    } finally {
      _$_MarginStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMarginTraderInfo(Map<dynamic, dynamic> info) {
    final _$actionInfo = _$_MarginStoreActionController.startAction(
        name: '_MarginStore.setMarginTraderInfo');
    try {
      return super.setMarginTraderInfo(info);
    } finally {
      _$_MarginStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
marginPoolInfo: ${marginPoolInfo},
marginTraderInfo: ${marginTraderInfo},
marginTokens: ${marginTokens}
    ''';
  }
}
