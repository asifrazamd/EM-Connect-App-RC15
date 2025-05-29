import 'dart:async';
import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_ble/universal_ble.dart';
import 'package:universal_ble_example/BeaconDetailPage.dart';
import 'package:universal_ble_example/FWUFirmwareInfoPage.dart';
import 'package:universal_ble_example/peripheral_details/widgets/services_list_widget.dart';
import 'package:universal_ble_example/widgets/responsive_view.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PeripheralDetailPage extends StatefulWidget {
  final String deviceId;
  final String deviceName;

  const PeripheralDetailPage(this.deviceId, this.deviceName, {super.key});
  @override
  State<StatefulWidget> createState() {
    return _PeripheralDetailPageState();
  }
}

class _PeripheralDetailPageState extends State<PeripheralDetailPage> {
  bool isConnected = false;
  int getComplete = 0;
  bool isFetchComplete = false;
  GlobalKey<FormState> valueFormKey = GlobalKey<FormState>();
  List<BleService> discoveredServices = [];
  final List<String> _logs = [];
  final binaryCode = TextEditingController();
  bool showButtons = false;
  bool isConnecting = true;
  int count = 0;

  ({
    BleService service,
    BleCharacteristic characteristic1,
    BleCharacteristic characteristic2,
  })? selectedCharacteristic;

  Future<void> connect() async {
    try {
      // await UniversalBle.stopScan(); // Always stop scanning first
      // await Future.delayed(
      //     Duration(milliseconds: 500)); // Allow stack to settle
      await UniversalBle.connect(
        widget.deviceId,
      );

      setState(() {
        // isConnected = true; // Added for faster connectivity
        isConnecting = false; // Stop showing the loading indicator
      });
      _addLog("ConnectionResult", true);
    } catch (e) {
      _addLog('ConnectError (${e.runtimeType})', e);
    }
  }

  @override
  void initState() {
    super.initState();
    UniversalBle.onConnectionChange = _handleConnectionChange;
    UniversalBle.onValueChange = _handleValueChange;
    UniversalBle.onPairingStateChange = _handlePairingStateChange;
    connect();
  }

  @override
  void dispose() {
    super.dispose();
    UniversalBle.onConnectionChange = null;
    UniversalBle.onValueChange = null;
    // Disconnect when leaving the page
    if (isConnected) UniversalBle.disconnect(widget.deviceId);
  }

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

  void _handleConnectionChange(
    String deviceId,
    bool isConnected,
    String? error,
  ) {
    print(
      '_handleConnectionChange $deviceId, $isConnected ${error != null ? 'Error: $error' : ''}',
    );

    setState(() {
      if (deviceId == widget.deviceId) {
        this.isConnected = isConnected;
      }
    });

    _addLog('Connection', isConnected ? "Connected" : "Disconnected");

    // Auto Discover Services
    if (this.isConnected) {
      _discoverServices(isFirmwareUpdate: false);
    }
  }

//Method to extract byte values for all beacon types from response
  void _handleValueChange(
      String deviceId, String characteristicId, Uint8List value) {
    String hexString =
        value.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('-');

    String s = String.fromCharCodes(value);
    String data = '$s\nRaw: ${value.toString()}\nHex: $hexString';

    print('_handleValueChange $deviceId, $characteristicId, $s');

    print('Received hex data: $hexString');
    _addLog("Received", hexString);

    isFetchComplete = true;
  }

  
  
  
  void _handlePairingStateChange(String deviceId, bool isPaired) {
    print('isPaired $deviceId, $isPaired');
    _addLog("PairingStateChange - isPaired", isPaired);
  }

  Future<List<BleService>> _discoverServices(
      {required bool isFirmwareUpdate}) async {
    try {
      var services = await UniversalBle.discoverServices(widget.deviceId);
      print('${services.length} services discovered');

      setState(() {
        discoveredServices = services;
        showButtons = true;
      });

      // Process discovered services based on operation type
      if (isFirmwareUpdate) {
        _processFirmwareUpdateServices();
      } else {
        _processBeaconTuningServices();
      }

      if (kIsWeb) {
        _addLog(
          "DiscoverServices",
          '${services.length} services discovered,\nNote: Only services added in ScanFilter or WebOptions will be discovered',
        );
      }
    } catch (e) {
      _addLog(
        "DiscoverServicesError",
        '$e\nNote: Only services added in ScanFilter or WebOptions will be discovered',
      );
    }
    return discoveredServices;
  }

  void _processFirmwareUpdateServices() {
    for (var service in discoveredServices) {
      if (service.uuid.toLowerCase() ==
          '81cfa888-454d-11e8-adc0-fa7ae01bd428') {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toLowerCase() ==
              '81cfaab8-454d-11e8-adc0-fa7ae01bd428') {
            selectedCharacteristic = (
              service: service,
              characteristic1: characteristic,
              characteristic2: characteristic
            );

            print('Auto-subscribing to characteristic: ${characteristic.uuid}');
            _addLog('Subscription', 'Subscribed to ${characteristic.uuid}');
            return;
          }
        }
      }
    }
    // If no characteristic found, log an error
    print("Error: No valid firmware update characteristic found");
  }

  void _processBeaconTuningServices() {
    for (var service in discoveredServices) {
      for (var characteristic in service.characteristics) {
        if (characteristic.properties.contains(CharacteristicProperty.write) &&
            characteristic.properties
                .contains(CharacteristicProperty.indicate)) {
          selectedCharacteristic = (
            service: service,
            characteristic1: service.characteristics.first,
            characteristic2: service.characteristics.length > 1
                ? service.characteristics[1]
                : service.characteristics.first
          );

          print(
              'Selected characteristic for beacon tuning: ${characteristic.uuid}');
          return;
        }
      }
    }
    print("Error: No valid beacon tuning characteristic found");
  }

  Future<void> _readValue() async {
    if (selectedCharacteristic == null) return;
    try {
      Uint8List value = await UniversalBle.readValue(
        widget.deviceId,
        selectedCharacteristic!.service.uuid,
        selectedCharacteristic!.characteristic1.uuid,
      );
      String s = String.fromCharCodes(value);
      String data = '$s\nraw :  ${value.toString()}';
      _addLog('Read', data);
    } catch (e) {
      _addLog('ReadError', e);
    }
  }

  
  
  
  Future<void> _writeValue() async {
    if (selectedCharacteristic == null ||
        !valueFormKey.currentState!.validate() ||
        binaryCode.text.isEmpty) {
      return;
    }

    Uint8List value;
    try {
      value = Uint8List.fromList(hex.decode(binaryCode.text));
    } catch (e) {
      _addLog('WriteError', "Error parsing hex $e");
      return;
    }

    try {
      await UniversalBle.writeValue(
        widget.deviceId,
        selectedCharacteristic!.service.uuid,
        selectedCharacteristic!.characteristic1.uuid,
        value,
        _hasSelectedCharacteristicProperty(
                [CharacteristicProperty.writeWithoutResponse])
            ? BleOutputProperty.withoutResponse
            : BleOutputProperty.withResponse,
      );
      _addLog('Write', value);
    } catch (e) {
      print(e);
      _addLog('WriteError', e);
    }
  }

  Future<void> subscribeNotification(BleInputProperty inputProperty) async {
    if (selectedCharacteristic == null) return;
    try {
      if (inputProperty != BleInputProperty.disabled) {
        List<CharacteristicProperty> properties =
            selectedCharacteristic!.characteristic1.properties;
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
        selectedCharacteristic!.service.uuid,
        selectedCharacteristic!.characteristic1.uuid,
        inputProperty,
      );
      _addLog('BleInputProperty', inputProperty);
      setState(() {});
    } catch (e) {
      _addLog('NotifyError', e);
    }
  }

 
 
 
  Future<void> setBleInputProperty(BleInputProperty inputProperty) async {
    if (selectedCharacteristic == null) return;
    try {
      if (inputProperty != BleInputProperty.disabled) {
        List<CharacteristicProperty> properties =
            selectedCharacteristic!.characteristic1.properties;
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
        selectedCharacteristic!.service.uuid,
        selectedCharacteristic!.characteristic1.uuid,
        inputProperty,
      );
      _addLog('BleInputProperty', inputProperty);
      setState(() {});
    } catch (e) {
      _addLog('NotifyError', e);
    }
  }

  bool isValidProperty(List<CharacteristicProperty> properties) {
    for (CharacteristicProperty property in properties) {
      if (selectedCharacteristic?.characteristic1.properties
              .contains(property) ??
          false) {
        return true;
      }
    }
    return false;
  }

//Connection page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(234, 234, 234, 1),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          Platform.isAndroid
              ? "${widget.deviceName}\n${widget.deviceId}" // Display device name and ID on Android
              : widget.deviceName, // Display only device name on iOS
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            color: Colors.black,
          ),
        ),
        backgroundColor: Color.fromRGBO(248, 247, 245, 1),
        leading: IconButton(
          icon:
              Icon(Icons.chevron_left, color: Color.fromARGB(255, 12, 11, 11)),
          onPressed: () {
            dispose();
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              isConnected
                  ? Icons.bluetooth_connected
                  : Icons.bluetooth_disabled,
              color: isConnected ? Colors.greenAccent : Colors.red,
              size: 20,
            ),
          ),
        ],
      ),
      body: ResponsiveView(builder: (_, DeviceType deviceType) {
        return Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  if (deviceType == DeviceType.desktop)
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Theme.of(context).secondaryHeaderColor,
                        child: discoveredServices.isEmpty
                            ? const Center(
                                child: Text('No Services Discovered'))
                            : ServicesListWidget(
                              deviceId: widget.deviceId,
                                deviceName: widget.deviceName,
                                                                discoveredServices: discoveredServices,
                                scrollable: false,

                                selectedCharacteristic:
                                    selectedCharacteristic,
                                onTap: (BleService service,
                                    BleCharacteristic characteristic) {
                                  setState(() {
                                    selectedCharacteristic = (
                                      service: service,
                                      characteristic1:
                                          service.characteristics.first,
                                      characteristic2:
                                          service.characteristics[1]
                                    );
                                  });
                                },
                              ),
                      ),
                    ),
                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Expanded(
                                    flex: 3,
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: Column(children: [
                                        isConnecting
                                            ? const Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    CircularProgressIndicator(),
                                                    SizedBox(height: 20),
                                                    Text(
                                                        "Connecting to device..."),
                                                  ],
                                                ),
                                              )
                                            : ServicesListWidget(

                                                deviceId: widget.deviceId,
                                                deviceName: widget.deviceName,
                                                discoveredServices:
                                                    discoveredServices,

                                                  scrollable: true, // Add this line to fix the issue

                                                selectedCharacteristic:selectedCharacteristic,
                                                onTap: (BleService service,
                                                    BleCharacteristic
                                                        characteristic) {
                                                  setState(() {
                                                    selectedCharacteristic = (
                                                      service: service,
                                                      characteristic1: service
                                                          .characteristics
                                                          .first,
                                                      characteristic2: service
                                                          .characteristics[1]
                                                    );
                                                  });
                                                },
                                              ),
                                      ]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_hasSelectedCharacteristicProperty([
                              CharacteristicProperty.write,
                              CharacteristicProperty.writeWithoutResponse
                            ]))
                              const Divider(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 20),
              child: SizedBox(
                width: double.infinity, // Makes the button take the full width
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    backgroundColor: Color.fromRGBO(45, 127, 224, 1),
                  ),
                  onPressed: isConnected &&
                          discoveredServices.any((service) =>
                              service.uuid.toLowerCase() ==
                              '81cf7a98-454d-11e8-adc0-fa7ae01bd428')
                      ? () async {
                          subscribeNotification(BleInputProperty.notification);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BeaconDetailPage(
                                      deviceId: widget.deviceId,
                                      deviceName: widget.deviceName,
                                      selectedCharacteristic:
                                          selectedCharacteristic,
                                    )),
                          );
                        }
                      : null,
                  child: Text(
                    'Configuration',
                    style: TextStyle(
                      color: Color.fromRGBO(250, 247, 243, 1),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 20),
              child: SizedBox(
                width: double.infinity, // Makes the button take the full width
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    backgroundColor: Color.fromRGBO(45, 127, 224, 1),
                  ),
                  onPressed: isConnected &&
                          discoveredServices.any((service) =>
                              service.uuid.toLowerCase() ==
                              '81cf7a98-454d-11e8-adc0-fa7ae01bd428')
                      ? () async {
                          subscribeNotification(BleInputProperty.notification);

                          reset_in_UpdaterMode();
                        }
                      : null,
                  child: Text(
                    'Reset in Updater Mode',
                    style: TextStyle(
                      color: Color.fromRGBO(250, 247, 243, 1),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 70),
              child: SizedBox(
                width: double.infinity, // Makes the button take the full width
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    backgroundColor: Color.fromRGBO(45, 127, 224, 1),
                  ),
                  onPressed: isConnected &&
                          discoveredServices.any((service) =>
                              service.uuid.toLowerCase() ==
                              '81cfa888-454d-11e8-adc0-fa7ae01bd428')
                      ? () async {
                          subscribeNotification(BleInputProperty.notification);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FwuFirmwareInfoPage(
                                deviceId: widget.deviceId,
                                deviceName: widget.deviceName,
                                selectedCharacteristic: selectedCharacteristic!,
                              ),
                            ),
                          );
                        }
                      : null,
                  child: Text(
                    'Firmware Update',
                    style: TextStyle(
                      color: Color.fromRGBO(250, 247, 243, 1),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void reset_in_UpdaterMode() async {
    Uint8List Resetopcode = Uint8List.fromList([0x01, 0x04]);

    print("DeviceID: ${widget.deviceId}");

    try {
      BleService selService = selectedCharacteristic!.service;
      BleCharacteristic selChar = selectedCharacteristic!.characteristic1;
      print("DeviceID: ${widget.deviceId}");

      await UniversalBle.writeValue(
        widget.deviceId,
        selService.uuid,
        selChar.uuid,
        Resetopcode,
        BleOutputProperty.withResponse,
      );
      setState(() {
        response = Resetopcode;
      });

      print("Data written to device: $Resetopcode");
    } catch (e) {
      print("Reset Failed: $e");
    }
  }

  bool _hasSelectedCharacteristicProperty(
          List<CharacteristicProperty> properties) =>
      properties.any((property) =>
          selectedCharacteristic?.characteristic1.properties
              .contains(property) ??
          false);

  void processDiscoveredServices() {
    for (var service in discoveredServices) {
      for (var characteristic in service.characteristics) {
        if (characteristic.properties.contains(CharacteristicProperty.write) &&
            characteristic.properties
                .contains(CharacteristicProperty.indicate)) {
          selectedCharacteristic = (
            service: service,
            characteristic1: service.characteristics.first,
            characteristic2: service.characteristics[1]
          );

          return; // Exit after finding the first matching characteristic
        }
      }
    }
  }
}
