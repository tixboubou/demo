import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:demo/models/models.dart';

abstract class BleState extends Equatable {
  const BleState();
}

class InitialBleState extends BleState {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'InitialBleState';
}

class DataBleState extends BleState {
  final BleDataModel bleDataModel;

  DataBleState({
    @required this.bleDataModel,
  });

  @override
  List<Object> get props => [bleDataModel];

  @override
  String toString() => 'DataBleState {bleDataModel: ${bleDataModel.toString()}}';
}

class ReceivedBleState extends BleState {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'ReceivedBleState';
}