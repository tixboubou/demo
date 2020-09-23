import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:demo/models/models.dart';

abstract class BleEvent extends Equatable {
  const BleEvent();
}

class StartBleConnectionEvent extends BleEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'StartBleConnectionEvent';
}

class GetBleDataEvent extends BleEvent {
  final BleDataModel bleDataModel;

  GetBleDataEvent({
    @required this.bleDataModel,
  });

  @override
  List<Object> get props => [bleDataModel];

  @override
  String toString() => 'GetBleDataEvent {bleDataModel: ${bleDataModel.toString()}}';
}

class SetScrollDataEvent extends BleEvent {
  final BleDataModel bleDataModel;

  SetScrollDataEvent({
    @required this.bleDataModel,
  });

  @override
  List<Object> get props => [bleDataModel];

  @override
  String toString() => 'SetScrollDataEvent';
}

class ReceivedBleEvent extends BleEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'ReceivedBleEvent';
}