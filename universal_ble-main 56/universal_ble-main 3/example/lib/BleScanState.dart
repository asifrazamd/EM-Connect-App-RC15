import 'package:flutter/material.dart';
import 'package:universal_ble/universal_ble.dart';

class BleScanState extends ChangeNotifier {
  final List<BleDevice> _devices = [];
  String _macFilter = '';
  String _nameFilter = '';
  int _rssiFilter = -100;

  bool isScanning = true;

  List<BleDevice> get devices => _devices;

  String get macFilter => _macFilter;
  String get nameFilter => _nameFilter;
  int get rssiFilter => _rssiFilter;

  void updateFilters(String mac, String name, int rssi) {
    _macFilter = mac;
    _nameFilter = name;
    _rssiFilter = rssi;
    notifyListeners();
  }

  void addOrUpdateDevice(BleDevice device) {
    final index = _devices.indexWhere((e) => e.deviceId == device.deviceId);
    if (index == -1) {
      _devices.add(device);
    } else {
      _devices[index] = device;
    }
    notifyListeners();
  }

  void clearDevices() {
    _devices.clear();
    notifyListeners();
  }
}
