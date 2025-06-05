import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:universal_ble/universal_ble.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ServicesListWidget extends StatefulWidget {
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

  const ServicesListWidget({
    super.key,
    required this.deviceId,
    required this.deviceName,
    required this.discoveredServices,
    this.scrollable = false,
    this.selectedCharacteristic,
    this.onTap,
  });

  @override
  _ServicesListWidgetState createState() => _ServicesListWidgetState();
}

class _ServicesListWidgetState extends State<ServicesListWidget> {
  late List<bool> _expandedStates;
  //bool isSubscribed(String uuid) => _characteristicSubscriptions[uuid] ?? false;
  bool isSubscribed(String serviceUuid, String charUuid) {
    final key = _getCharacteristicKey(serviceUuid, charUuid);
    return _characteristicSubscriptions[key] ?? false;
  }

  final Map<String, bool> _characteristicSubscriptions = {};
  final Map<String, String> _characteristicValues = {};
  final Map<String, bool> _showValueForCharacteristic = {};

  @override
  void initState() {
    super.initState();
    UniversalBle.onValueChange = _handleValueChange;

    _initializeExpandedStates();
  }

  void _initializeExpandedStates() {
    _expandedStates =
        List.generate(widget.discoveredServices.length, (index) => false);
  }

  @override
  void didUpdateWidget(ServicesListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.discoveredServices.length !=
        widget.discoveredServices.length) {
      _initializeExpandedStates();
    }
  }

  void _handleValueChange(
      String deviceId, String characteristicId, Uint8List value) {
    String hexString =
        value.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('-');

    String s = String.fromCharCodes(value);
    String data = '$s\nRaw: ${value.toString()}\nHex: $hexString';

    print('_handleValueChange $deviceId, $characteristicId, $s');

    print('Received hex data: $hexString');
    _addLog("Received", hexString);
  }

  final Map<String, IconData> propertyIcons = {
    'read': Icons.download,
    'write': Icons.upload,
    //'indicate': Icons.subscriptions,
  };
  // void toggleSubscription() {
  //   if (isSubscribed) {
  //     debugPrint('Unsubscribing from notifications');
  //     return; //unsubscribeNotification(BleInputProperty.notification);
  //   } else {
  //     subscribeNotification(BleInputProperty.notification);
  //   }
  //   setState(() {
  //     isSubscribed = !isSubscribed;
  //   });
  // }
//   void toggleSubscription() {
//   if (isSubscribed) {
//     debugPrint('Unsubscribing from notifications');
//     unsubscribeNotification(BleInputProperty.notification);
//     setState(() {
//       isSubscribed = false;
//     });
//   } else {
//     subscribeNotification(BleInputProperty.notification);
//     setState(() {
//       isSubscribed = true;
//     });
//   }
// }

  // void toggleSubscription(String uuid) {
  //   final currentlySubscribed = _characteristicSubscriptions[uuid] ?? false;

  //   if (currentlySubscribed) {
  //     debugPrint('Unsubscribing from $uuid');
  //     unsubscribeNotification(BleInputProperty.notification);
  //   } else {
  //     debugPrint('Subscribing to $uuid');
  //     subscribeNotification(BleInputProperty.notification);
  //   }

  //   setState(() {
  //     _characteristicSubscriptions[uuid] = !currentlySubscribed;
  //   });
  // }
  void toggleSubscription(String serviceUuid, String charUuid) {
    final key = _getCharacteristicKey(serviceUuid, charUuid);
    final isCurrentlySubscribed = _characteristicSubscriptions[key] ?? false;

    if (isCurrentlySubscribed) {
      debugPrint('Unsubscribing from $charUuid in $serviceUuid');
      unsubscribeNotification(BleInputProperty
          .notification); // You might need to pass charUuid here too!
    } else {
      debugPrint('Subscribing to $charUuid in $serviceUuid');
      subscribeNotification(
          BleInputProperty.notification); // Likewise, charUuid might be needed
    }

    setState(() {
      _characteristicSubscriptions[key] = !isCurrentlySubscribed;
    });
  }

  // String decodeCharacteristicValue(String uuid, Uint8List value) {
  //   switch (uuid.toLowerCase()) {
  //     case '00002a00': // Device Name
  //     case '00002a29': // Manufacturer Name
  //     case '00002a24': // Model Number
  //       return utf8.decode(value);

  //     case '00002a01': // Appearance
  //       if (value.length >= 2) {
  //         int appearance = value[0] + (value[1] << 8);
  //         return '0x${appearance.toRadixString(16)}';
  //       }
  //       return 'Unknown';

  //     case '00002aa6': // Central Address Resolution
  //       return value.isNotEmpty && value[0] == 1
  //           ? 'Supported'
  //           : 'Not supported';

  //     case '00002a19': // Battery Level
  //       return value.isNotEmpty ? '${value[0]}%' : 'Unknown';

  //     default:
  //       return utf8.decode(value, allowMalformed: true);
  //   }
  // }

  
  
  
  
  // Future<void> _readValue() async {
  //   if (widget.selectedCharacteristic == null) return;
  //   try {
  //     Uint8List value = await UniversalBle.readValue(
  //       widget.deviceId,
  //       widget.selectedCharacteristic!.service.uuid,
  //       widget.selectedCharacteristic!.characteristic1.uuid,
  //     );
  //     String s = String.fromCharCodes(value);
  //     String data = '$s\nraw :  ${value.toString()}';
  //     // _addLog('Read', data);
  //   } catch (e) {
  //     debugPrint('Error reading value: $e');
  //     // _addLog('ReadError', e);
  //   }
  // }

//   Future<void> _readValue() async {
//   final selected = widget.selectedCharacteristic;
//   if (selected == null) return;

//   if (!selected.characteristic1.properties.contains('read')) {
//     return;
//   }

//   try {
//     Uint8List value = await UniversalBle.readValue(
//       widget.deviceId,
//       selected.service.uuid,
//       selected.characteristic1.uuid,
//     );

//     String uuidShort = selected.characteristic1.uuid.substring(4, 8).toLowerCase();
//     String label = _getCharacteristicName('0000$uuidShort');
//     String decoded = decodeCharacteristicValue('0000$uuidShort', value);

//     debugPrint('$label $decoded');
//   } catch (e) {
//     debugPrint('Error reading value: $e');
//   }
// }

  // Future<void> _readValue() async {
  //   debugPrint('reading');
  //   for (var service in widget.discoveredServices) {
  //     for (var char in service.characteristics) {
  //       if (!char.properties.contains('read')) continue;

  //       try {
  //         Uint8List value = await UniversalBle.readValue(
  //           widget.deviceId,
  //           service.uuid,
  //           char.uuid,
  //         );

  //         debugPrint(
  //             'Trying to read from ${char.uuid} with properties ${char.properties}');
  //         debugPrint('Raw value: $value');

  //         final uuidShort = char.uuid.substring(4, 8).toLowerCase();
  //         final label = _getCharacteristicName('0000$uuidShort');
  //         final decoded = decodeCharacteristicValue('0000$uuidShort', value);

  //         debugPrint('$label: $decoded');
  //       } catch (e) {
  //         debugPrint('Error reading ${char.uuid}: $e');
  //       }
  //     }
  //   }
  //   debugPrint('reading completed');
  // }

//   Future<void> _readValue() async {
//   if (widget.selectedCharacteristic == null) return;
//   try {
//     final serviceUuid = widget.selectedCharacteristic!.service.uuid;
//     final charUuid = widget.selectedCharacteristic!.characteristic1.uuid;
//     final deviceId = widget.deviceId;

//     Uint8List value = await UniversalBle.readValue(deviceId, serviceUuid, charUuid);

//     String decodedValue;
//     bool isValidString = true;
//     try {
//       decodedValue = utf8.decode(value);
//       if (decodedValue.trim().isEmpty) {
//         isValidString = false;
//       }
//     } catch (_) {
//       isValidString = false;
//       decodedValue = '<invalid utf8>';
//     }

//     // Helper to convert bytes to hex string
//     String bytesToHex(Uint8List bytes) {
//       return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
//     }

//     String hexValue = bytesToHex(value);

//     if (isValidString) {
//       debugPrint('Read Value: String="$decodedValue", Hex="$hexValue"');
//       // _addLog('Read', 'String="$decodedValue", Hex="$hexValue"');
//     } else {
//       if (value.isEmpty) {
//         debugPrint('Read Value: (no data)');
//         // _addLog('Read', '(no data)');
//       } else {
//         debugPrint('Read Value: Hex="$hexValue" (no valid UTF-8 string)');
//         // _addLog('Read', 'Hex="$hexValue" (no valid UTF-8 string)');
//       }
//     }
//   } catch (e) {
//     debugPrint('Error reading value: $e');
//     // _addLog('ReadError', e.toString());
//   }
// }
// Future<void> _readValue(String deviceId, List<BleService> services) async {
//   for (var service in services) {
//     final serviceUuid = service.uuid;
//     for (var characteristic in service.characteristics) {
//       if (characteristic.properties.map((e) => e.toString()).contains('read'))
//       {
//         try {
//           Uint8List value = await UniversalBle.readValue(deviceId, serviceUuid, characteristic.uuid);

//           String decodedValue;
//           bool isValidString = true;
//           try {
//             decodedValue = utf8.decode(value);
//             if (decodedValue.trim().isEmpty) isValidString = false;
//           } catch (_) {
//             isValidString = false;
//             decodedValue = '<invalid utf8>';
//           }
//           String hexValue = value.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');

//           if (isValidString) {
//             debugPrint('Service $serviceUuid, Characteristic ${characteristic.uuid}: String="$decodedValue", Hex="$hexValue"');
//           } else {
//             debugPrint('Service $serviceUuid, Characteristic ${characteristic.uuid}: Hex="$hexValue" (no valid UTF-8 string)');
//           }
//         } catch (e) {
//           debugPrint('Failed to read Characteristic ${characteristic.uuid} from Service $serviceUuid: $e');
//         }
//       }
//     }
//   }
// }

  Future<void> _readValue(String deviceId, List<BleService> services,
      String characteristicUuid) async {
    for (var service in services) {
      final serviceUuid = service.uuid;
      for (var characteristic in service.characteristics) {
        if (characteristic.properties
            .map((e) => e.toString())
            .contains('read')) {
          try {
            Uint8List value = await UniversalBle.readValue(
                deviceId, serviceUuid, characteristic.uuid);
            debugPrint("values: $value");

            // Prepare hex
            String hexValue =
                value.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
            debugPrint("hexValue: $hexValue");

            //check if its contains zero
            //bool isZero = value.every((b) => b == 0);
            bool isZero = value.isNotEmpty && value.every((b) => b == 0);


            // Try decoding to string
            String decodedValue='';
            bool isValidString = true;
            try {
              decodedValue = utf8.decode(value);
              debugPrint("decodedValue: $decodedValue");
              if (decodedValue.trim().isEmpty) isValidString = false;
            } catch (_) {
              isValidString = false;
              //decodedValue = '';
            }

            // Fallback to hex or 0
            // final displayValue = isValidString && !isZero
            //     ? decodedValue
            //     : hexValue.isNotEmpty
            //         ? hexValue
            //         : "";

                      final displayValue = isZero
              ? "0"
              : isValidString
                  ? decodedValue
                  : hexValue;

            debugPrint("displayValue: $displayValue");

            // Update state
            setState(() {
              _characteristicValues[characteristic.uuid] = displayValue;
            });
          } catch (e) {
            debugPrint('Error reading ${characteristic.uuid}: $e');
            setState(() {
              _characteristicValues[characteristic.uuid] = "0";
            });
          }
        }
      }
    }
  }






// Future<void> _readValue(String deviceId, List<BleService> services) async {
//   for (var service in services) {
//     final serviceUuid = service.uuid;
//     for (var characteristic in service.characteristics) {
//       if (characteristic.properties.map((e) => e.toString()).contains('read')) {
//         try {
//           Uint8List value = await UniversalBle.readValue(deviceId, serviceUuid, characteristic.uuid);

//           // Convert to hex
//           String hexValue = value.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');

//           // Try decoding UTF-8
//           String decodedValue = '';
//           bool isValidString = true;

//           try {
//             decodedValue = utf8.decode(value);
//             if (decodedValue.trim().isEmpty) isValidString = false;
//           } catch (_) {
//             isValidString = false;
//           }

//           // Final displayed value
//           String finalValue;
//           if (isValidString) {
//             finalValue = decodedValue;
//             debugPrint('Service $serviceUuid, Characteristic ${characteristic.uuid}: String="$decodedValue", Hex="$hexValue"');
//           } else if (hexValue.trim().isNotEmpty) {
//             finalValue = hexValue;
//             debugPrint('Service $serviceUuid, Characteristic ${characteristic.uuid}: Hex="$hexValue" (no valid UTF-8 string)');
//           } else {
//             finalValue = '0';
//             debugPrint('Service $serviceUuid, Characteristic ${characteristic.uuid}: Empty value. Set to "0".');
//           }

//           // Update UI
//           setState(() {
//             _characteristicValues[characteristic.uuid] = finalValue;
//           });

//         } catch (e) {
//           debugPrint('Failed to read Characteristic ${characteristic.uuid} from Service $serviceUuid: $e');
//           setState(() {
//             _characteristicValues[characteristic.uuid] = "0";
//           });
//         }
//       }
//     }
//   }
// }

//   Future<void> _readValue(String deviceId, List<BleService> services) async {
//   for (var service in services) {
//     final serviceUuid = service.uuid;
//     for (var characteristic in service.characteristics) {
//       if (characteristic.properties.map((e) => e.toString()).contains('read'))

//        {
//         try {
//           Uint8List value = await UniversalBle.readValue(deviceId, serviceUuid, characteristic.uuid);

//           String decodedValue;
//           bool isValidString = true;
//           try {
//             decodedValue = utf8.decode(value);
//             if (decodedValue.trim().isEmpty) isValidString = false;
//           } catch (_) {
//             isValidString = false;
//             decodedValue = '<invalid utf8>';
//           }

//           // Default to 0 if not valid
//           final displayValue = isValidString ? decodedValue : "0";

//           // Store the value in state
//           setState(() {
//             _characteristicValues[characteristic.uuid] = displayValue;
//           });

//           debugPrint('notavailable ${characteristic.uuid}: $displayValue');
//         } catch (e) {
//           debugPrint('Error reading ${characteristic.uuid}: $e');
//           setState(() {
//             _characteristicValues[characteristic.uuid] = "0";
//           });
//         }
//       }
//     }
//   }
// }

  Future<void> subscribeNotification(BleInputProperty inputProperty) async {
    if (widget.selectedCharacteristic == null) return;
    try {
      if (inputProperty != BleInputProperty.disabled) {
        List<CharacteristicProperty> properties =
            widget.selectedCharacteristic!.characteristic1.properties;
        if (properties.contains(CharacteristicProperty.notify)) {
          inputProperty = BleInputProperty.notification;
        } else if (properties.contains(CharacteristicProperty.indicate)) {
          inputProperty = BleInputProperty.indication;
        } else {
          throw 'No notify or indicate property';
        }
      }
      await UniversalBle.setNotifiable(
        widget.deviceId,
        widget.selectedCharacteristic!.service.uuid,
        widget.selectedCharacteristic!.characteristic1.uuid,
        inputProperty,
      );
      _addLog('BleInputProperty', inputProperty);
      setState(() {});
    } catch (e) {
      _addLog('NotifyError', e);
    }
  }

  Future<void> unsubscribeNotification(BleInputProperty inputProperty) async {
    if (widget.selectedCharacteristic == null) return;
    try {
      await UniversalBle.setNotifiable(
        widget.deviceId,
        widget.selectedCharacteristic!.service.uuid,
        widget.selectedCharacteristic!.characteristic1.uuid,
        BleInputProperty.disabled, // <--- Unsubscribe from notifications
      );
      _addLog('BleInputProperty', 'disabled');
      setState(() {});
    } catch (e) {
      _addLog('UnsubscribeError', e);
    }
  }

  final List<String> _logs = [];
  void _addLog(String type, dynamic data) async {
    // Get the current timestamp and manually format it as YYYY-MM-DD HH:mm:ss
    DateTime now = DateTime.now();
    String timestamp =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    // Log entry with just the formatted timestamp
    String logEntry = '[$timestamp]:$type: ${data.toString()}\n';

    _logs.add(logEntry);

    await _writeLogToFile(logEntry);
  }

  Future<void> _writeLogToFile(String logEntry) async {
    final directory = await getApplicationDocumentsDirectory();
    final logFile = File('${directory.path}/logs.txt');
    await logFile.writeAsString(logEntry, mode: FileMode.append);
  }

  String _getCharacteristicKey(String serviceUuid, String charUuid) {
    return '$serviceUuid|$charUuid';
  }

  // Future<void> readBleValue(String serviceUuid, String charUuid) async {
  //   if (serviceUuid.contains('read')) {
  //     print('Characteristic does not support read.');
  //     return;
  //   } else {
  //     final result=UniversalBle.readValue(
  //       widget.deviceId,
  //       serviceUuid,
  //       charUuid,
  //     );
  //     print(
  //         'Reading value from characteristic: $charUuid in service: $serviceUuid');
  //   }
  //   // try {
  //   //   final result = await UniversalBle.readValue(
  //   //     widget.deviceId,
  //   //     serviceUuid,
  //   //     charUuid,
  //   //   );

  //   //   final decoded = utf8.decode(result);
  //   //   print('Read from ${charUuid}:$decoded');
  //   // } catch (e) {
  //   //   print('Error reading value: $e');
  //   // }
  // }
  // Future<void> readBleValue(
  //     String serviceUuid, String charUuid, List<String> properties) async {
  //   if (!properties.contains('read')) {
  //     print('Characteristic does not support read.');
  //     return;
  //   }

  //   try {
  //     print(
  //         'Reading value from characteristic: $charUuid in service: $serviceUuid');
  //     final result = await UniversalBle.readValue(
  //       widget.deviceId,
  //       serviceUuid,
  //       charUuid,
  //     );
  //     final decoded = utf8.decode(result);
  //     print('Read from $charUuid: $decoded');
  //   } catch (e) {
  //     print('Error reading value from $charUuid: $e');
  //   }
  // }

// Future<void> readBleValue() async {
//   for (var service in widget.discoveredServices) {
//     for (var char in service.characteristics) {
//       // Skip non-readable characteristics
//       if (!char.properties.contains('read')) continue;

//       try {
//         Uint8List value = await UniversalBle.readValue(
//           widget.deviceId,
//           service.uuid,
//           char.uuid,
//         );
//         final uuidShort = char.uuid.substring(4, 8).toLowerCase();
//         final label = _getCharacteristicName('0000$uuidShort');
//         final decoded = decodeCharacteristicValue('0000$uuidShort', value);
//         debugPrint('$label $decoded');
//       } catch (e) {
//         debugPrint('Error reading ${char.uuid}: $e');
//       }
//     }
//   }
// }
// Make sure this function is async
  // Future<void> readDeviceNameHardcoded() async {
  //   try {
  //     Uint8List value = await UniversalBle.readValue(
  //       widget.deviceId,
  //       '00001800-0000-1000-8000-00805f9b34fb', // Generic Access service UUID
  //       '00002a00-0000-1000-8000-00805f9b34fb', // Device Name characteristic UUID
  //     );

  //     String deviceName = utf8.decode(value);
  //     debugPrint('Device Name: $deviceName');
  //   } catch (e) {
  //     debugPrint('Error reading Device Name: $e');
  //   }
  // }

// Your BLE services JSON data as a Dart list of maps
// final List<Map<String, dynamic>> bleServices = [
//   {
//     "uuid": "00001800-0000-1000-8000-00805f9b34fb",
//     "characteristics": [
//       {
//         "uuid": "00002a00-0000-1000-8000-00805f9b34fb",
//         "properties": ["read"]
//       },
//       {
//         "uuid": "00002a01-0000-1000-8000-00805f9b34fb",
//         "properties": ["read"]
//       },
//       {
//         "uuid": "00002aa6-0000-1000-8000-00805f9b34fb",
//         "properties": ["read"]
//       }
//     ]
//   },
//   {
//     "uuid": "00001801-0000-1000-8000-00805f9b34fb",
//     "characteristics": [
//       {
//         "uuid": "00002a05-0000-1000-8000-00805f9b34fb",
//         "properties": ["indicate"]
//       },
//       {
//         "uuid": "00002b29-0000-1000-8000-00805f9b34fb",
//         "properties": ["read", "write"]
//       },
//       {
//         "uuid": "00002b2a-0000-1000-8000-00805f9b34fb",
//         "properties": ["read"]
//       },
//       {
//         "uuid": "00002b3a-0000-1000-8000-00805f9b34fb",
//         "properties": ["read"]
//       }
//     ]
//   },
//   {
//     "uuid": "81cf7a98-454d-11e8-adc0-fa7ae01bd428",
//     "characteristics": [
//       {
//         "uuid": "81cf7bb0-454d-11e8-adc0-fa7ae01bd428",
//         "properties": ["write", "indicate"]
//       }
//     ]
//   }
// ];

// Helper to convert bytes to hex string
  String bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
  }

// Future<void> readDeviceNameHardcoded(String deviceId) async {
//   for (var service in bleServices) {
//     String serviceUuid = service['uuid'];
//     for (var characteristic in service['characteristics']) {
//       String charUuid = characteristic['uuid'];
//       List<dynamic> properties = characteristic['properties'];

//       if (properties.contains('read')) {
//         try {
//           Uint8List value = await UniversalBle.readValue(deviceId, serviceUuid, charUuid);

//           // Decode UTF-8 string safely
//           String decodedValue;
//           bool isValidString = true;
//           try {
//             decodedValue = utf8.decode(value);
//             // Check if string is empty or non-printable
//             if (decodedValue.trim().isEmpty) {
//               isValidString = false;
//             }
//           } catch (_) {
//             // Invalid UTF-8
//             isValidString = false;
//             decodedValue = '<invalid utf8>';
//           }

//           String hexValue = bytesToHex(value);

//           if (isValidString) {
//             debugPrint('Service $serviceUuid, Characteristic $charUuid: String="$decodedValue", Hex="$hexValue"');
//           } else {
//             debugPrint('Service $serviceUuid, Characteristic $charUuid: Hex="$hexValue" (no valid UTF-8 string)');
//           }
//         } catch (e) {
//           debugPrint('Failed to read Characteristic $charUuid from Service $serviceUuid: $e');
//         }
//       }
//     }
//   }
// }

//   Future<void> readDeviceNameHardcoded() async {
//   for (var service in widget.discoveredServices) {
//     for (var characteristic in service.characteristics) {
//       // Check if characteristic supports 'read'
//       if (characteristic.properties.contains('read')) {
//         try {
//           // Read value from the device
//           Uint8List value = await UniversalBle.readValue(
//             widget.deviceId,
//             service.uuid,
//             characteristic.uuid,
//           );

//           // Extract the short UUID (4 hex chars) for name lookup
//           String uuidShort = characteristic.uuid.substring(4, 8).toLowerCase();
//           String label = _getCharacteristicName('0000$uuidShort');

//           // Decode value, fallback to hex string if UTF8 decode fails
//           String decoded;
//           try {
//             decoded = utf8.decode(value);
//           } catch (_) {
//             decoded = value.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
//           }

//           debugPrint('$label $decoded');
//         } catch (e) {
//           debugPrint('Error reading ${characteristic.uuid}: $e');
//         }
//       } else {
//         debugPrint('Characteristic ${characteristic.uuid} does not support reading.');
//       }
//     }
//   }
// }

  @override
  Widget build(BuildContext context) {
    // debugPrint("Building ServicesListWidget for device: ${widget.discoveredServices}");
    return SingleChildScrollView(
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.discoveredServices.length,
            itemBuilder: (BuildContext context, int index) {
              final service = widget.discoveredServices[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _getServiceName(
                            service.uuid,
                            // widget.discoveredServices[index].uuid),
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          color: Colors.white,
                          elevation: 4,
                          margin: EdgeInsets.all(1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(6))),
                          child: ListTile(
                            title: Text(
                              //'UUID: ${_formatUUID(widget.discoveredServices[index].uuid)}',
                              'UUID: ${_formatUUID(service.uuid)}',
                              style: TextStyle(fontSize: 12),
                            ),
                            // subtitle: widget.discoveredServices[index]
                            //         .characteristics.isEmpty
                            //     ? Text('No characteristics')
                            //     : null,
                            trailing: Icon(
                              _expandedStates[index]
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: Colors.grey,
                            ),
                            onTap: () {
                              setState(() {
                                _expandedStates[index] =
                                    !_expandedStates[index];
                              });
                            },
                          ),
                        ),
                        if (_expandedStates[index])
                          Column(
                            children: service.characteristics
                                //widget.discoveredServices[index].characteristics
                                .map((e) => SizedBox(
                                      width: double.infinity,
                                      child: Card(
                                        color: Colors.white,
                                        elevation: 4,
                                        margin: EdgeInsets.all(0.5),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.zero),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              InkWell(
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Flexible(
                                                          // <-- Wrap this Column with Flexible
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
  'UUID: 0x${e.uuid.substring(0, 8).replaceFirst(RegExp(r'^0+'), '').toUpperCase()}',
  style: TextStyle(fontSize: 12),
  softWrap: true,
),

                                                              // Text(
                                                              //   'UUID: ${e.uuid.substring(0, 8)}',
                                                              //   style: TextStyle(
                                                              //       fontSize:
                                                              //           12),
                                                              //   softWrap: true,
                                                              // ),
                                                              Text(
                                                                _getCharacteristicName(e
                                                                    .uuid
                                                                    .substring(
                                                                        0, 8)),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12),
                                                                softWrap: true,
                                                              ),
                                                              SizedBox(
                                                                  height: 4),
                                                              Text(
                                                                'Properties: [${e.properties.join(', ')}]',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                                softWrap: true,
                                                              ),
                                                              SizedBox(
                                                                  height: 4),
                                                              _showValueForCharacteristic[e
                                                                          .uuid] ==
                                                                      true
                                                                  ? Text(
                                                                      'value: ${_characteristicValues[e.uuid]}',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              12),
                                                                      softWrap:
                                                                          true,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .visible,
                                                                      maxLines:
                                                                          null,
                                                                    )
                                                                  : SizedBox
                                                                      .shrink(),
                                                            ],
                                                          ),
                                                        ),

//                                                         Column(
//                                                           crossAxisAlignment:
//                                                               CrossAxisAlignment
//                                                                   .start,
//                                                           children: [
//                                                             Text(
//                                                               _getCharacteristicName(e
//                                                                   .uuid
//                                                                   .substring(
//                                                                       0, 8)),
//                                                               style: TextStyle(
//                                                                   fontSize: 12),
//                                                             ),
//                                                             SizedBox(height: 4),
//                                                             Text(
//                                                               'Properties: [${e.properties.join(', ')}]',
//                                                               style: TextStyle(
//                                                                   fontSize: 12,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .w500),
//                                                             ),
//                                                             SizedBox(height: 4),

// _showValueForCharacteristic[e.uuid] == true
//                           ? Text(
//                               'value: ${_characteristicValues[e.uuid] ?? "0"}',
//                               style: TextStyle(fontSize: 12),
//                               softWrap: true,
//                               overflow: TextOverflow.visible,
//                               maxLines: null, // Allow unlimited lines to wrap
//                             )
//                           : SizedBox.shrink(),
//                                                           ],
//                                                         ),
                                                        Row(
                                                          children: e.properties
                                                              .map((prop) {
                                                            String type = prop
                                                                .name
                                                                .toLowerCase();

                                                            if (type ==
                                                                'read') {
                                                              return Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        2.0),
                                                                child:
                                                                    GestureDetector(
                                                                  onTap:
                                                                      () async {
                                                                    //await readDeviceNameHardcoded(widget.deviceId);
                                                                    await _readValue(
                                                                        widget
                                                                            .deviceId,
                                                                        widget
                                                                            .discoveredServices,
                                                                        e.uuid);
                                                                    setState(
                                                                        () {
                                                                      _showValueForCharacteristic[
                                                                              e.uuid] =
                                                                          true;
                                                                    });
                                                                  },
                                                                  child: Icon(
                                                                      propertyIcons[
                                                                          type]!,
                                                                      size: 20),
                                                                ),
                                                              );
                                                            } 
                                                            else if (type ==
                                                                'write') {
                                                              return Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        2.0),
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        String
                                                                            inputValue =
                                                                            '';
                                                                        String
                                                                            selectedFormat =
                                                                            'Byte Array';
                                                                        final formats =
                                                                            [
                                                                          'Text (UTF-8)',
                                                                          'Byte',
                                                                          'Byte Array',
                                                                          'UInt8',
                                                                          'UInt16 (Little Endian)',
                                                                          'UInt16 (Big Endian)',
                                                                          'UInt32 (Little Endian)',
                                                                          'UInt32 (Big Endian)',
                                                                          'SInt8',
                                                                          'SInt16 (Big Endian)',
                                                                          'SInt32 (Little Endian)',
                                                                          'SInt32 (Big Endian)',
                                                                          'Float16 (IEEE-11073)',
                                                                          'Float32 (IEEE-11073)',
                                                                        ];

                                                                        return StatefulBuilder(
                                                                          builder:
                                                                              (context, setState) {
                                                                            return AlertDialog(
                                                                              title: Text('Write value'),
                                                                              content: Column(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                children: [
                                                                                  Row(
                                                                                    children: [
                                                                                      //                                                                                           TextField(
                                                                                      //   autofocus: true,
                                                                                      //   decoration: InputDecoration(
                                                                                      //     labelText: 'Enter value',
                                                                                      //     hintText: '0xNew value',
                                                                                      //   ),
                                                                                      //   onChanged: (value) {
                                                                                      //     inputValue = value;
                                                                                      //   },
                                                                                      // ),
                                                                                      // Expanded(
                                                                                      //   child:TextField(
                                                                                      //     autofocus: true,
                                                                                      //   decoration: InputDecoration(
                                                                                      //     labelText: 'Enter value',
                                                                                      //     hintText: 'New value',
                                                                                      //   ),
                                                                                      //   onChanged: (value) {
                                                                                      //     inputValue = value;
                                                                                      //   },
                                                                                      //   ),
                                                                                      // ),

                                                                                      Expanded(
                                                                                        child: TextField(
                                                                                          autofocus: true,
                                                                                          keyboardType: selectedFormat == 'Text (UTF-8)' ? TextInputType.text : TextInputType.number,
                                                                                          decoration: InputDecoration(hintText: 'Enter value'),
                                                                                          onChanged: (value) {
                                                                                            inputValue = value;
                                                                                          },
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(width: 8),
                                                                                      DropdownButton<String>(
                                                                                        value: selectedFormat,
                                                                                        items: formats.map((format) {
                                                                                          return DropdownMenuItem(
                                                                                            value: format,
                                                                                            child: Text(format, style: TextStyle(fontSize: 12)),
                                                                                          );
                                                                                        }).toList(),
                                                                                        onChanged: (value) {
                                                                                          if (value != null) {
                                                                                            setState(() {
                                                                                              selectedFormat = value;
                                                                                            });
                                                                                          }
                                                                                        },
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  // Add Value Button
                                                                                  // TextButton(
                                                                                  //   onPressed: () {
                                                                                  //     // Logic to add value
                                                                                  //   },
                                                                                  //   child: Text('ADD VALUE'),
                                                                                  // ),
                                                                                  // // Save As Section
                                                                                  // TextField(
                                                                                  //   decoration: InputDecoration(
                                                                                  //     labelText: 'Save as...',
                                                                                  //   ),
                                                                                  // ),
                                                                                ],
                                                                              ),
                                                                              actions: [
                                                                                TextButton(
                                                                                  onPressed: () {
                                                                                    Navigator.of(context).pop();
                                                                                  },
                                                                                  child: Text('CANCEL'),
                                                                                ),
                                                                                TextButton(
                                                                                  onPressed: () async {
                                                                                    Navigator.of(context).pop();
                                                                                    List<int> bytes = [];

                                                                                    try {
                                                                                      BleService selService = widget.selectedCharacteristic!.service;
                                                                                      BleCharacteristic selChar = widget.selectedCharacteristic!.characteristic1;

                                                                                      switch (selectedFormat) {
                                                                                        case 'Text (UTF-8)':
                                                                                          bytes = inputValue.codeUnits;
                                                                                          break;

                                                                                        case 'Byte':
                                                                                          bytes = [
                                                                                            int.parse(inputValue)
                                                                                          ];
                                                                                          break;

                                                                                        case 'Byte Array':
                                                                                          bytes = inputValue.split(',').map((s) => int.parse(s.trim())).toList();
                                                                                          break;

                                                                                        case 'UInt8':
                                                                                          int val = int.parse(inputValue);
                                                                                          if (val < 0 || val > 255) throw Exception("UInt8 out of range");
                                                                                          bytes = [val];
                                                                                          break;

                                                                                        case 'UInt16 (Little Endian)':
                                                                                          int val = int.parse(inputValue);
                                                                                          bytes = [
                                                                                            val & 0xFF,
                                                                                            (val >> 8) & 0xFF
                                                                                          ];
                                                                                          break;

                                                                                        case 'UInt16 (Big Endian)':
                                                                                          int val = int.parse(inputValue);
                                                                                          bytes = [
                                                                                            (val >> 8) & 0xFF,
                                                                                            val & 0xFF
                                                                                          ];
                                                                                          break;

                                                                                        case 'UInt32 (Little Endian)':
                                                                                          int val = int.parse(inputValue);
                                                                                          bytes = [
                                                                                            val & 0xFF,
                                                                                            (val >> 8) & 0xFF,
                                                                                            (val >> 16) & 0xFF,
                                                                                            (val >> 24) & 0xFF,
                                                                                          ];
                                                                                          break;

                                                                                        case 'UInt32 (Big Endian)':
                                                                                          int val = int.parse(inputValue);
                                                                                          bytes = [
                                                                                            (val >> 24) & 0xFF,
                                                                                            (val >> 16) & 0xFF,
                                                                                            (val >> 8) & 0xFF,
                                                                                            val & 0xFF,
                                                                                          ];
                                                                                          break;

                                                                                        case 'SInt8':
                                                                                          int val = int.parse(inputValue);
                                                                                          if (val < -128 || val > 127) throw Exception("SInt8 out of range");
                                                                                          bytes = [val & 0xFF];
                                                                                          break;

                                                                                        case 'SInt16 (Big Endian)':
                                                                                          int val = int.parse(inputValue);
                                                                                          if (val < -32768 || val > 32767) throw Exception("SInt16 out of range");
                                                                                          bytes = [
                                                                                            ((val >> 8) & 0xFF),
                                                                                            val & 0xFF,
                                                                                          ];
                                                                                          break;

                                                                                        case 'SInt32 (Little Endian)':
                                                                                          int val = int.parse(inputValue);
                                                                                          bytes = [
                                                                                            val & 0xFF,
                                                                                            (val >> 8) & 0xFF,
                                                                                            (val >> 16) & 0xFF,
                                                                                            (val >> 24) & 0xFF,
                                                                                          ];
                                                                                          break;

                                                                                        case 'SInt32 (Big Endian)':
                                                                                          int val = int.parse(inputValue);
                                                                                          bytes = [
                                                                                            (val >> 24) & 0xFF,
                                                                                            (val >> 16) & 0xFF,
                                                                                            (val >> 8) & 0xFF,
                                                                                            val & 0xFF,
                                                                                          ];
                                                                                          break;

                                                                                        case 'Float16 (IEEE-11073)':
                                                                                          int val = int.parse(inputValue); // For now simulate as 2-byte int
                                                                                          bytes = [
                                                                                            val & 0xFF,
                                                                                            (val >> 8) & 0xFF
                                                                                          ];
                                                                                          break;

                                                                                        case 'Float32 (IEEE-11073)':
                                                                                          double floatVal = double.parse(inputValue);
                                                                                          var byteData = ByteData(4);
                                                                                          byteData.setFloat32(0, floatVal, Endian.little);
                                                                                          bytes = byteData.buffer.asUint8List();
                                                                                          break;

                                                                                        default:
                                                                                          bytes = inputValue.codeUnits;
                                                                                      }
                                                                                      //subscribeNotification(BleInputProperty.notification);

                                                                                      await UniversalBle.writeValue(
                                                                                        widget.deviceId,
                                                                                        selService.uuid,
                                                                                        selChar.uuid,
                                                                                        Uint8List.fromList(bytes),
                                                                                        BleOutputProperty.withResponse,
                                                                                        //deviceInfoopcode,
                                                                                        //BleOutputProperty.withResponse,
                                                                                      );
                                                                                      print('Write command sent successfully');
                                                                                      await Future.delayed(const Duration(milliseconds: 500));
                                                                                      // final readValue = await UniversalBle.readValue(
                                                                                      //   widget.deviceId,
                                                                                      //   selService.uuid,
                                                                                      //   selChar.uuid,
                                                                                      // );

                                                                                      // print("📖 Read after write: $readValue");

                                                                                      // String responseStr = utf8.decode(readValue);
                                                                                      // print("📄 Decoded response: $responseStr");

                                                                                      // TODO: Call BLE write with these bytes
                                                                                    } catch (e) {
                                                                                      print('Error: $e');
                                                                                      // ScaffoldMessenger.of(context).showSnackBar(
                                                                                      //   SnackBar(content: Text('Invalid input: $e')),
                                                                                      // );
                                                                                      if (!mounted) return;

                                                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                                                        //SnackBar(content: Text('Write successful')),
                                                                                        SnackBar(content: Text('Invalid input: $e')), //   SnackBar(content: Text('Invalid input: $e')),
                                                                                      );
                                                                                    }
                                                                                  },
                                                                                  child: Text('SEND'),
                                                                                ),
                                                                              ],
                                                                            );
                                                                          },
                                                                        );
                                                                      },
                                                                    );
                                                                  },
                                                                  child: Icon(
                                                                      propertyIcons[
                                                                          type]!,
                                                                      size: 18),
                                                                ),
                                                              );
                                                            } 
                                                            else {
                                                              return Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        2.0),
                                                                child:
                                                                    GestureDetector(
                                                                  onTap:
                                                                      () async {
                                                                    toggleSubscription(
                                                                        service
                                                                            .uuid,
                                                                        e.uuid);
                                                                    debugPrint(
                                                                        "showing toogle: ${_showValueForCharacteristic[e.uuid]}");
                                                                          bool subscribed = isSubscribed(service.uuid, e.uuid);

  String displayValue;
  // if (subscribed) {
  //   displayValue = "Notifications and indications are enabled";
  // } else {
  //   displayValue = "Notifications and indications are disabled";
  // }
    if (subscribed) {
    if (type == 'indicate') {
      displayValue = "Indications are enabled";
    } else if (type == 'notify' || type == 'notification') {
      displayValue = "Notifications are enabled";
    } else {
      displayValue = "Notifications and indications are enabled";
    }
  } else {
    if (type == 'indicate') {
      displayValue = "Indications are disabled";
    } else if (type == 'notify' || type == 'notification') {
      displayValue = "Notifications are disabled";
    } else {
      displayValue = "Notifications and indications are disabled";
    }
  }


  setState(() {
    _showValueForCharacteristic[e.uuid] = true;
    _characteristicValues[e.uuid] = displayValue;
  });

  debugPrint("Status: $displayValue");


                                                                    // Also read the value when subscribing/unsubscribing
                                                                    // await _readValue(
                                                                    //     widget
                                                                    //         .deviceId,
                                                                    //     widget
                                                                    //         .discoveredServices,
                                                                    //     e.uuid);
                                                                    // setState(
                                                                    //     () {
                                                                    //   _showValueForCharacteristic[
                                                                    //           e.uuid] =
                                                                    //       true;
                                                                    // });
                                                                    // debugPrint(
                                                                    //     "showing toogle after read: ${_showValueForCharacteristic[e.uuid]}");
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            4.0),
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      border:
                                                                          Border(
                                                                        bottom: BorderSide(
                                                                            color:
                                                                                Colors.black,
                                                                            width: 1.5),
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        Stack(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      children: [
                                                                        const Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            Icon(Icons.notifications_off,
                                                                                size: 28,
                                                                                color: Colors.black),
                                                                          ],
                                                                        ),
                                                                        if (isSubscribed(
                                                                            service
                                                                                .uuid,
                                                                            e
                                                                                .uuid))
                                                                          const Icon(
                                                                              Icons.notifications_active,
                                                                              size: 28,
                                                                              color: Colors.blue),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }

                                                            // else {
                                                            //   // Unknown or multiple properties (read + write)
                                                            //   return Padding(
                                                            //     padding: const EdgeInsets
                                                            //         .symmetric(
                                                            //         horizontal:
                                                            //             2.0),
                                                            //     child:
                                                            //         GestureDetector(
                                                            //       onTap:
                                                            //           () {
                                                            //         subscribeNotification(
                                                            //             BleInputProperty.notification);
                                                            //       },
                                                            //       child:
                                                            //           Row(
                                                            //         mainAxisSize:
                                                            //             MainAxisSize.min,
                                                            //         children: [
                                                            //           Icon(
                                                            //               propertyIcons['indicate']!,
                                                            //               size: 16),
                                                            //         ],
                                                            //       ),
                                                            //     ),
                                                            //   );
                                                            // }
                                                            //else {
                                                            // debugPrint(
                                                            //     "reading");
                                                            // // readBleValue(
                                                            // //     service.uuid,
                                                            // //     e.uuid,
                                                            // //     e.properties.map((p) => p.name).toList());
                                                            // //_readValue();

                                                            // debugPrint(
                                                            //     "reading completed");

                                                            // final result=readBleValue(
                                                            //     service
                                                            //         .uuid,
                                                            //     e.uuid);
                                                            //     debugPrint("Reading the result values are $result");

                                                            // Unknown or multiple properties (read + write)
                                                            // return Padding(
                                                            //   padding: const EdgeInsets
                                                            //       .symmetric(
                                                            //       horizontal:
                                                            //           2.0),
                                                            //   child:
                                                            // GestureDetector(
                                                            //   onTap: toggleSubscription,
                                                            //   child: Row(
                                                            //     mainAxisSize: MainAxisSize.min,
                                                            //     children: [
                                                            //       Icon(
                                                            //         Icons.subscriptions,
                                                            //         size: 20,
                                                            //         color: isSubscribed ? Colors.blue : Colors.grey, // Highlight if subscribed
                                                            //       ),
                                                            //     ],
                                                            //   ),
                                                            // ),
                                                            //     GestureDetector(
                                                            //   onTap: () =>
                                                            //       toggleSubscription(e.uuid),
                                                            //   child:
                                                            //       Container(
                                                            //     padding: const EdgeInsets
                                                            //         .all(
                                                            //         4.0),
                                                            //     decoration:
                                                            //         const BoxDecoration(
                                                            //       border:
                                                            //           Border(
                                                            //         bottom: BorderSide(color: Colors.black, width: 1.5),
                                                            //       ),
                                                            //     ),
                                                            //     child:
                                                            //         Stack(
                                                            //       alignment:
                                                            //           Alignment.center,
                                                            //       children: [
                                                            //         Row(
                                                            //           mainAxisSize: MainAxisSize.min,
                                                            //           children: const [
                                                            //             Icon(Icons.upload, size: 20, color: Colors.grey),
                                                            //             Icon(Icons.download, size: 20, color: Colors.grey),
                                                            //           ],
                                                            //         ),
                                                            //         if (isSubscribed(e.uuid))
                                                            //           const Icon(Icons.close, size: 18, color: Colors.red),
                                                            //       ],
                                                            //     ),
                                                            //   ),
                                                            // )
                                                            //       GestureDetector(
                                                            //     onTap: () =>
                                                            //         toggleSubscription(
                                                            //             service
                                                            //                 .uuid,
                                                            //             e.uuid),
                                                            //     child:
                                                            //         Container(
                                                            //       padding:
                                                            //           const EdgeInsets
                                                            //               .all(
                                                            //               4.0),
                                                            //       decoration:
                                                            //           const BoxDecoration(
                                                            //         border:
                                                            //             Border(
                                                            //           bottom: BorderSide(
                                                            //               color:
                                                            //                   Colors.black,
                                                            //               width: 1.5),
                                                            //         ),
                                                            //       ),
                                                            //       child:
                                                            //           Stack(
                                                            //         alignment:
                                                            //             Alignment
                                                            //                 .center,
                                                            //         children: [
                                                            //           Row(
                                                            //             mainAxisSize:
                                                            //                 MainAxisSize.min,
                                                            //             children: const [
                                                            //               Icon(Icons.notifications_off,
                                                            //                   size: 28,
                                                            //                   color: Colors.black),
                                                            //             ],
                                                            //           ),
                                                            //           if (isSubscribed(
                                                            //               service
                                                            //                   .uuid,
                                                            //               e
                                                            //                   .uuid))
                                                            //             const Icon(
                                                            //                 Icons.notifications_active,
                                                            //                 size: 28,
                                                            //                 color: Colors.blue),

                                                            //         ],
                                                            //       ),

                                                            //     ),

                                                            //   ),
                                                            // );
// return Padding(
//   padding: const EdgeInsets.symmetric(horizontal: 2.0),
//   child: GestureDetector(
//     onTap: toggleSubscription,
//     child: Container(
//       padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
//       decoration: const BoxDecoration(
//         border: Border(
//           bottom: BorderSide(
//             color: Colors.black, // underline color
//             width: 1.5,
//           ),
//         ),
//       ),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: const [
//               Icon(Icons.upload, size: 20, color: Colors.grey),
//               Icon(Icons.download, size: 20, color: Colors.grey),
//             ],
//           ),
//           if (isSubscribed)
//             const Icon(
//               Icons.close,
//               size: 25,
//               color: Colors.red,
//             ),
//         ],
//       ),
//     ),
//   ),
// );
                                                            // }
                                                          }).toList(),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatUUID(String uuid) {
    // Format the UUID based on its type
    if (uuid.toLowerCase() == "81cf7a98-454d-11e8-adc0-fa7ae01bd428") {
      // Beacon Tuning Service - Display full 128-bit UUID
      return uuid;
    } else if (uuid.toLowerCase().contains("00001800") ||
        uuid.toLowerCase().contains("00001801")) {
      // Generic Access and Generic Attribute - Display 16-bit UUID
      return '0x${uuid.substring(4, 8)}'; // Extract 16-bit portion and prefix with 0x
    } else if (uuid.length > 8) {
      // Default - Display first 32 bits with 0x prefix
      return '0x${uuid.substring(0, 8)}';
    } else {
      // Short UUIDs
      return '0x$uuid';
    }
  }

  String _getServiceName(String uuid) {
    if (uuid.length == 36 &&
        uuid.toLowerCase() == "81cf7a98-454d-11e8-adc0-fa7ae01bd428") {
      return 'BEACON TUNER';
    }

    String shortUuid = uuid.length > 8
        ? uuid.substring(4, 8).toLowerCase()
        : uuid.toLowerCase();

    switch (shortUuid) {
      case "1800":
        return 'GENERIC ACCESS';
      case "1801":
        return 'GENERIC ATTRIBUTE';
      default:
        return 'UNNAMED';
    }
  }

  String _getCharacteristicName(String uuid) {
    switch (uuid) {
      case "00002a00":
        return 'Device Name : ';
      case "00002b29":
        return 'Client Supported Feature : ';
      case "00002a01":
        return 'Appearance : ';
      case "00002a04":
        return 'Peripheral Preferred Connection  : ';
      case "00002b2a":
        return 'Database Hash : ';
      case "00002a05":
        return 'Service Changed : ';
      case "00002a19":
        return 'Battery Level : ';
      case "00002a29":
        return 'Manufacturer Name String : ';
      case "00002a24":
        return 'Model Number String : ';
      case "00002a37":
        return 'Heart Rate Measurement : ';
      case "00002a1c":
        return 'Temperature Measurement : ';
      case "00002aa6":
        return 'Central Address Resolution :';
      case "00002b3a":
        return 'Server Supported Feature :';
      default:
        return '$uuid : '; // Return UUID if not recognized
    }
  }
}
