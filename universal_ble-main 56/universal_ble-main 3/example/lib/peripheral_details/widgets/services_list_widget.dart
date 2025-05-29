import 'dart:convert';
import 'dart:typed_data';

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
  bool isSubscribed = false;

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
    'indicate': Icons.subscriptions,
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
  void toggleSubscription() {
  if (isSubscribed) {
    debugPrint('Unsubscribing from notifications');
    unsubscribeNotification(BleInputProperty.notification);
    setState(() {
      isSubscribed = false;
    });
  } else {
    subscribeNotification(BleInputProperty.notification);
    setState(() {
      isSubscribed = true;
    });
  }
}


  Future<void> _readValue() async {
    if (widget.selectedCharacteristic == null) return;
    try {
      Uint8List value = await UniversalBle.readValue(
        widget.deviceId,
        widget.selectedCharacteristic!.service.uuid,
        widget.selectedCharacteristic!.characteristic1.uuid,
      );
      String s = String.fromCharCodes(value);
      String data = '$s\nraw :  ${value.toString()}';
      _addLog('Read', data);
    } catch (e) {
      _addLog('ReadError', e);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.discoveredServices.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _getServiceName(
                              widget.discoveredServices[index].uuid),
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
                              'UUID: ${_formatUUID(widget.discoveredServices[index].uuid)}',
                              style: TextStyle(fontSize: 12),
                            ),
                            subtitle: widget.discoveredServices[index]
                                    .characteristics.isEmpty
                                ? Text('No characteristics')
                                : null,
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
                            children:
                                widget.discoveredServices[index].characteristics
                                    .map((e) => SizedBox(
                                          width: double.infinity,
                                          child: Card(
                                            color: Colors.white,
                                            elevation: 4,
                                            margin: EdgeInsets.all(0.5),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.zero),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
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
                                                            Text(
                                                              _getCharacteristicName(e
                                                                  .uuid
                                                                  .substring(
                                                                      0, 8)),
                                                              style: TextStyle(
                                                                  fontSize: 12),
                                                            ),
                                                            Row(
                                                              children: e
                                                                  .properties
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
                                                                          () {
                                                                        print(
                                                                            'Download icon tapped');
                                                                      },
                                                                      child: Icon(
                                                                          propertyIcons[
                                                                              type]!,
                                                                          size:
                                                                              16),
                                                                    ),
                                                                  );
                                                                } else if (type ==
                                                                    'write') {
                                                                  return Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            2.0),
                                                                    child:
                                                                        GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        showDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (BuildContext context) {
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
                                                                              builder: (context, setState) {
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

                                                                                          print('Converted bytes to write: $bytes');
                                                                                          print('User Input: "$inputValue"');
                                                                                          print('Selected Format: $selectedFormat');

                                                                                          print('Writing bytes to BLE characteristic: $bytes (length: ${bytes.length})');
                                                                                          print('Writing to Service UUID: ${selService.uuid}, Characteristic UUID: ${selChar.uuid}');
                                                                                          //_addLog('write', 'Writing bytes: $bytes to ${selService.uuid} / ${selChar.uuid}');
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
                                                                          size:
                                                                              16),
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
                                                                else {
  // Unknown or multiple properties (read + write)
return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 2.0),
  child: GestureDetector(
    onTap: toggleSubscription,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.subscriptions,
          size: 20,
          color: isSubscribed ? Colors.blue : Colors.grey, // Highlight if subscribed
        ),
      ],
    ),
  ),
);
}

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
