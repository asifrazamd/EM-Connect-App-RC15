import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:universal_ble/universal_ble.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:universal_ble_example/peripheral_details/widgets/char.dart';
import 'package:universal_ble_example/peripheral_details/widgets/services_list_widget.dart';

import 'package:universal_ble_example/logs.dart';



class ServiceLogsSwipeScreen extends StatelessWidget {
  final String deviceId;
  final String deviceName;
  final List<BleService> discoveredServices;
  final bool scrollable;
  final ({
    BleService service,
    BleCharacteristic characteristic1,
    BleCharacteristic characteristic2,
  })? selectedCharacteristic;
  final Function(BleService service, BleCharacteristic characteristic)? onTap;

  const ServiceLogsSwipeScreen({
    super.key,
    required this.deviceId,
    required this.deviceName,
    required this.discoveredServices,
    this.scrollable = false,
    this.selectedCharacteristic,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        scrollDirection: Axis.horizontal,
        children: [
          ServicesListWidget(
            deviceId: deviceId,
            deviceName: deviceName,
            discoveredServices: discoveredServices,
            scrollable: scrollable,
            selectedCharacteristic: selectedCharacteristic,
            onTap: onTap,
          ),
          const Logs(),
        ],
      ),
    );
  }
}
