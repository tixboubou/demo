import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:demo/blocs/blocs.dart';
import 'package:demo/models/ble/ble_data_model.dart';
import './ble.dart';

class BleBloc extends Bloc<BleEvent, BleState> {
  final SettingsBloc settingsBloc;
  final PlayerActionBloc playerActionBloc;

  BleDataModel _globalBleDataModel = BleDataModel(
    scale: 0,
    pos: 0,
    speed: 0,
    stat: 0,
    total: 0,
  );
  // ble device uuid
  static const String SERVICE_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
  static const String WRITE_TO_BT_CHARACTERISTIC_UUID =
      "6e400002-b5a3-f393-e0a9-e50e24dcca9e";
  static const String READ_FROM_BT_CHARACTERISTIC_UUID =
      "6e400003-b5a3-f393-e0a9-e50e24dcca9e";

  FlutterBlue _flutterBlue = FlutterBlue.instance;
  // ignore: cancel_subscriptions
  StreamSubscription<ScanResult> scanSubscription;
  // ignore: cancel_subscriptions
  StreamSubscription dataFromBle;
  BluetoothDevice targetDevice;
  BluetoothCharacteristic writeCharacteristic;
  BluetoothCharacteristic readCharacteristic;
  List<BluetoothService> bluetoothServices;

  int globalStat = 0;
  int globalSpeed = 0;
  int globalPos = 0;
  int globalTotal = 0;
  int globalScale = 0;

  BleBloc({
    @required this.settingsBloc,
    @required this.playerActionBloc,
  });

  // get flutter blue instance
  FlutterBlue getFlutterBlueInstance() {
    return _flutterBlue;
  }

  bool connectToDevice({@required ScanResult result}) {
    if (result == null) return false;
    disconnectFromDevice();
    targetDevice = result.device;
    // connect to the device
    try {
      targetDevice.connect();
    } catch (e) {
      print('ble_bloc.connectToDevice error ${e.toString()}');
      return false;
    }
    return true;
  }

  changeMTU() {
    if (targetDevice == null) return;
    targetDevice.requestMtu(185);
  }

  // =============

  void stopScan() {
    scanSubscription?.cancel();
    scanSubscription = null;
  }

  void disconnectFromDevice() {
    if (targetDevice == null) return;

    targetDevice.disconnect();
  }

  Future discoverServices() async {
    // pause status
    bool isPause = false;
    globalStat = isPause ? 1 : 0;
    if (targetDevice == null) return;
    bluetoothServices = await targetDevice.discoverServices();
    readCharacteristic = bluetoothServices[2].characteristics[0];
    await readCharacteristic.setNotifyValue(true);
    // ignore: cancel_subscriptions
    dataFromBle = readCharacteristic.value.listen(
          (data) {
        if (data.length != 0) {
          String stringData = utf8.decode(data);
          BleDataModel bleDataModel = BleDataModel.fromJson(
            json.decode(stringData),
          );
          // check if something is changed
          if (bleDataModel != _globalBleDataModel) {
            // save settings
            settingsBloc.add(
              ChangeSettingsWithBleEvent(
                bleDataModel: bleDataModel,
              ),
            );
            // renew global data
            _globalBleDataModel = bleDataModel;
          }
        }
      },
    );
  }

  sendBleModelToDevice() async {
    if (targetDevice == null) return;
    try {
      BluetoothCharacteristic character =
      bluetoothServices[2].characteristics[1];
      String data =
          '{"stat":${_globalBleDataModel.stat},"speed":${_globalBleDataModel.speed},"pos":${_globalBleDataModel.pos},"total":${_globalBleDataModel.total},"scale":${_globalBleDataModel.scale}}';
      List<int> bytes = utf8.encode(data);
      await character.write(bytes);
    } catch (e) {
      print('ble_bloc.sendDataToDevice.error is ${e.toString()}');

      bluetoothServices = await targetDevice.discoverServices();
    }

  }

  @override
  BleState get initialState => InitialBleState();

  @override
  Stream<BleState> mapEventToState(
    BleEvent event,
  ) async* {
    if (event is StartBleConnectionEvent) {}
    if (event is GetBleDataEvent) {
      yield DataBleState(bleDataModel: event.bleDataModel);
    } else if (event is SetScrollDataEvent) {
      yield* _mapSetScrollDataEventToState(event);
    } else if (event is ReceivedBleEvent) {
      yield* _mapReceivedBleEventToState();
    }
  }

  Stream<BleState> _mapSetScrollDataEventToState(
      SetScrollDataEvent event) async* {
    if (_globalBleDataModel != event.bleDataModel) {
      _globalBleDataModel = event.bleDataModel;
      // send data to device
      add(ReceivedBleEvent());
    }
  }

  Stream<BleState> _mapReceivedBleEventToState() async* {
    // send data to device
    sendBleModelToDevice();
  }
}
