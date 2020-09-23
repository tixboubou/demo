import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:demo/models/models.dart';
import 'package:demo/repository/demo_repository.dart';
import 'package:demo/utils/utils.dart';
import './check_purchase.dart';

class CheckPurchaseBloc extends Bloc<CheckPurchaseEvent, CheckPurchaseState> {
  final DemoRepository demoRepository;

  List<String> _purchaseIdsList = List();
  List<IAPItem> _items = List();
  List<PurchasedItem> _purchases = List();
  List<PurchasedItem> _purchasesHistory = List();

  final List<String> _productLists = DemoRepository.SUBSCRIPTIONS_LIST;

  StreamSubscription _purchaseUpdatedSubscription;
  StreamSubscription _purchaseErrorSubscription;
  StreamSubscription _connectionSubscription;

  NetworkInfoImpl networkInfo = NetworkInfoImpl(DataConnectionChecker());

  CheckPurchaseBloc({@required this.demoRepository});

  @override
  CheckPurchaseState get initialState => InitialShopState();

  @override
  Stream<CheckPurchaseState> mapEventToState(
    CheckPurchaseEvent event,
  ) async* {
    if (event is GetListShopEvent) {
      yield* _mapGetListShopEventToState();
    } else if (event is RestorePurchaseEvent) {
      yield* _mapRestorePurchaseEventToState();
    } else if (event is BuyShopEvent) {
      yield* _mapBuyShopEventToState(event);
    } else if (event is InitializePurchasesShopEvent) {
      yield* _mapInitializePurchasesShopEventToState();
    } else if (event is FinalizePurchaseEvent) {
      yield* _mapFinalizePurchaseEventToState(event);
    } else if (event is ProcessPurchaseEvent) {
      yield* _mapProcessPurchaseEventToState(event);
    }
  }

  @override
  Future<void> close() async {
    _connectionSubscription?.cancel();
    _purchaseUpdatedSubscription?.cancel();
    _purchaseErrorSubscription?.cancel();
    await FlutterInappPurchase.instance?.endConnection;
    return super.close();
  }

  Future<List<IAPItem>> _getProduct() async {
    List<IAPItem> items = await FlutterInappPurchase.instance.getSubscriptions(
      _productLists,
    );
    return items;
  }

  Future<List<PurchasedItem>> _getPurchases() async {
    List<PurchasedItem> purchases =
        await FlutterInappPurchase.instance.getAvailablePurchases();
    return purchases;
  }

  Future<List<PurchasedItem>> _getPurchaseHistory() async {
    List<PurchasedItem> purchases =
        await FlutterInappPurchase.instance.getPurchaseHistory();
    // purchases ids
    List<String> _oldPurchasesIds = List();
    for (var item in purchases) {
      print('purchase history ${item.toString()}');
      _purchases.add(item);
      _oldPurchasesIds.add(item.productId);
    }

    await demoRepository.saveOldPurchases(purchases: _oldPurchasesIds);
    return purchases;
  }

  // purchase in process
  Stream<CheckPurchaseState> _mapProcessPurchaseEventToState(ProcessPurchaseEvent event) async* {
    // initialize purchase
    FlutterInappPurchase.instance.requestSubscription(event.productId);
    yield InitialShopState();
    yield ProcessPurchaseState();
  }

  Stream<CheckPurchaseState> _mapGetListShopEventToState() async* {
    bool ifConnected = await networkInfo.isConnected;
    if (ifConnected) {
      try {
        _items = await _getProduct();
        _purchaseIdsList = await demoRepository.getOldPurchases();
        _purchases = await _getPurchases();
        _purchasesHistory = await _getPurchaseHistory();
      } catch (e) {
        print('get purchases lists error: $e');
      }
    } else {
      _purchaseIdsList = await demoRepository.getOldPurchases();
    }

    yield InitialShopState();
    yield GetShopItemsListState(
      purchaseIdsList: _purchaseIdsList,
      shopPricingList: _items,
      purchases: _purchases,
      purchasesHistory: _purchasesHistory,
    );
  }

  Stream<CheckPurchaseState> _mapInitializePurchasesShopEventToState() async* {
    // check for internet
    bool ifConnected = await networkInfo.isConnected;
    if (ifConnected) {
      // prepare
      var result = await FlutterInappPurchase.instance.initConnection;
      print('result: $result');

      // refresh items for android
      try {
        String msg = await FlutterInappPurchase.instance.consumeAllItems;
        print('consumeAllItems: $msg');
      } catch (e) {
        print('consumeAllItems error: $e');
      }

      _connectionSubscription =
          FlutterInappPurchase.connectionUpdated.listen((connected) {
            print('connected: $connected');
          });

      _purchaseUpdatedSubscription =
          FlutterInappPurchase.purchaseUpdated.listen((productItem) async {
            // finalize purchase
            try {
              if (Platform.isAndroid) {
                String purchaseResult =
                await FlutterInappPurchase.instance.acknowledgePurchaseAndroid(
                  productItem.purchaseToken,
                );

                PurchaseModel purchaseModel = await demoRepository.readPurchaseDetails(
                  purchaseString: purchaseResult,
                );

                // check if purchase is authorized
                bool ifAuthorized = purchaseModel.code == 'OK';
                String purchaseMessage = purchaseModel.message;
                this.add(
                  FinalizePurchaseEvent(
                    ifAuthorized: ifAuthorized,
                    messageText: purchaseMessage,
                    purchaseId: productItem.productId,
                  ),
                );
              } else {
                String purchaseResult =
                await FlutterInappPurchase.instance.finishTransaction(
                  productItem,
                );
                print('purchaseResult iOS is $purchaseResult');

                this.add(
                  FinalizePurchaseEvent(
                    ifAuthorized: true,
                    messageText: purchaseResult,
                    purchaseId: productItem.productId,
                  ),
                );
              }
            } catch (e) {
              print('_purchaseUpdatedSubscription error ${e.toString()}');
              this.add(
                FinalizePurchaseEvent(
                  ifAuthorized: false,
                  messageText: e.toString(),
                  purchaseId: productItem.productId,
                ),
              );
            }
          });

      _purchaseErrorSubscription =
          FlutterInappPurchase.purchaseError.listen((purchaseError) {
            print('purchase-error: $purchaseError');
          });

      try {
        _items = await _getProduct();
        _purchaseIdsList = await demoRepository.getOldPurchases();
        _purchases = await _getPurchases();
        _purchasesHistory = await _getPurchaseHistory();
      } catch (e) {
        print('get purchases lists error: $e');
      }
    } else {
      _purchaseIdsList = await demoRepository.getOldPurchases();
    }

    yield InitialShopState();
    yield GetShopItemsListState(
      purchaseIdsList: _purchaseIdsList,
      shopPricingList: _items,
      purchases: _purchases,
      purchasesHistory: _purchasesHistory,
    );
  }

  // restore purchases
  Stream<CheckPurchaseState> _mapRestorePurchaseEventToState() async* {
    // clear purchases list
    bool ifConnected = await networkInfo.isConnected;
    if (ifConnected) {
      try {
        // get purchases list
        List<String> oldPurchasesIds =
        _purchases.map((purchase) => purchase.productId).toList();
        // save old purchases
        await demoRepository.saveOldPurchases(purchases: oldPurchasesIds);

        _items = await _getProduct();
        _purchaseIdsList = await demoRepository.getOldPurchases();
        _purchases = await _getPurchases();
        _purchasesHistory = await _getPurchaseHistory();
      } catch (e) {
        print('get purchases lists error: $e');
      }
    } else {
      _purchaseIdsList = await demoRepository.getOldPurchases();
    }

    yield InitialShopState();
    yield GetShopItemsListState(
      purchaseIdsList: _purchaseIdsList,
      shopPricingList: _items,
      purchases: _purchases,
      purchasesHistory: _purchasesHistory,
    );
  }

  // buy product with product details
  Stream<CheckPurchaseState> _mapBuyShopEventToState(BuyShopEvent event) async* {
    // buy item
    demoRepository.rememberPurchase(
      purchaseId: event.purchaseId,
    );
    bool ifConnected = await networkInfo.isConnected;
    if (ifConnected) {
      try {
        _items = await _getProduct();
        _purchaseIdsList = await demoRepository.getOldPurchases();
        _purchases = await _getPurchases();
        _purchasesHistory = await _getPurchaseHistory();
      } catch (e) {
        print('get purchases lists error: $e');
      }
    } else {
      _purchaseIdsList = await demoRepository.getOldPurchases();
    }

    yield InitialShopState();
    yield GetShopItemsListState(
      purchaseIdsList: _purchaseIdsList,
      shopPricingList: _items,
      purchases: _purchases,
      purchasesHistory: _purchasesHistory,
    );
  }

  // finalize purchase
  Stream<CheckPurchaseState> _mapFinalizePurchaseEventToState(
      FinalizePurchaseEvent event,
      ) async* {
    yield InitialShopState();
    yield FinalizePurchaseState(
      ifAuthorized: event.ifAuthorized,
      messageText: event.messageText,
      purchaseId: event.purchaseId,
    );
  }
}
