import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class CheckPurchaseEvent extends Equatable {
  const CheckPurchaseEvent();
}

class GetListShopEvent extends CheckPurchaseEvent {
  @override
  List<Object> get props => null;

  @override
  String toString() => 'GetListShopEvent';
}

class InitializePurchasesShopEvent extends CheckPurchaseEvent {
  @override
  List<Object> get props => null;

  @override
  String toString() => 'InitializePurchasesShopEvent';
}

class BuyShopEvent extends CheckPurchaseEvent {
  final String purchaseId;

  BuyShopEvent({
    @required this.purchaseId,
  });

  @override
  List<Object> get props => [purchaseId];

  @override
  String toString() => 'BuyShopEvent';
}

class RestorePurchaseEvent extends CheckPurchaseEvent {
  @override
  List<Object> get props => null;

  @override
  String toString() => 'RestorePurchaseEvent';
}

class FinalizePurchaseEvent extends CheckPurchaseEvent {
  final bool ifAuthorized;
  final String messageText;
  final String purchaseId;

  FinalizePurchaseEvent({
    @required this.ifAuthorized,
    @required this.messageText,
    @required this.purchaseId,
  });

  @override
  List<Object> get props => [ifAuthorized, messageText, purchaseId];

  @override
  String toString() => 'FinalizePurchaseEvent';
}

class ProcessPurchaseEvent extends CheckPurchaseEvent {
  final String productId;

  ProcessPurchaseEvent({
    @required this.productId
  });

  @override
  List<Object> get props => [productId];

  @override
  String toString() => 'ProcessPurchaseEvent';
}
