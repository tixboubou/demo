import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

abstract class CheckPurchaseState extends Equatable {
  const CheckPurchaseState();
}

class InitialShopState extends CheckPurchaseState {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'InitialShopState';
}

class GetShopItemsListState extends CheckPurchaseState {
  final List<String> purchaseIdsList;
  final List<IAPItem> shopPricingList;
  final List<PurchasedItem> purchases;
  final List<PurchasedItem> purchasesHistory;

  GetShopItemsListState({
    @required this.purchaseIdsList,
    @required this.shopPricingList,
    @required this.purchases,
    @required this.purchasesHistory,
  });

  @override
  List<Object> get props => [
    purchaseIdsList,
    shopPricingList,
    purchases,
    purchasesHistory,
  ];

  @override
  String toString() => 'GetShopItemsListState';
}

class FinalizePurchaseState extends CheckPurchaseState {
  final bool ifAuthorized;
  final String messageText;
  final String purchaseId;

  FinalizePurchaseState({
    @required this.ifAuthorized,
    @required this.messageText,
    @required this.purchaseId,
  });

  @override
  List<Object> get props => [ifAuthorized, messageText, purchaseId];

  @override
  String toString() => 'PurchaseFinalizationState';
}

class ProcessPurchaseState extends CheckPurchaseState {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'FinalizePurchaseState';
}