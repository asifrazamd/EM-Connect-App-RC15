library;

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_ble/universal_ble.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:universal_ble_example/EddystoneTLM.dart';
import 'dart:io';
import 'package:universal_ble_example/global.dart';
import 'package:universal_ble_example/AltBeaconScreen.dart';
import 'package:universal_ble_example/EddystoneUID.dart';
import 'package:universal_ble_example/ManufacturerspecificdataScreen.dart';

bool isEddystoneTlmAvailable = false;
bool isEddystoneTlmSelected = false;
bool showCteCard = true;
String AoA_Enable = '';
String AoA_Interval = '';
String AoA_CTE_length = '';
String AoA_CTE_count = '';
int interval = 0;
int cteLength = 0;
int cteCount = 0;
int blockSize = 0;
bool isOn = true;
bool ibeacon = true;
String uuid = '';
int? majorId;
int? minorId;
String namespaceID = '';
String instanceID = '';
int? prefix;
String url = "";
String displayurl = "";
int? suffix;
int packetType = 0;
int? interval1;
int? txPowerLevel;
Uint8List? response;
String mfgID = '';
String beaconID = '';
String mfgData = '';
int? selectedRadioIndex;
String manufacturerId = "";
String userData = "";
String dynamicdata = "";
String? _deviceProductId;
String? _firmwareversion_Major;
String? _firmwareversion_Minor;
String? HW_Version;
String? Battery_Voltage;

class BeaconDetailPage extends StatefulWidget {
  final String deviceId;
  final String deviceName;

  final ({
    BleService service,
    BleCharacteristic characteristic1,
    BleCharacteristic characteristic2,
  })? selectedCharacteristic;
  const BeaconDetailPage({
    super.key,
    required this.deviceId,
    required this.deviceName,
    required this.selectedCharacteristic,
  });

  @override
  State<StatefulWidget> createState() {
    return _BeaconDetailPageState();
  }
}

class _BeaconDetailPageState extends State<BeaconDetailPage> {
  final _formKey = GlobalKey<FormState>();
  bool cteEnabled = false;
  String? calculatedIntervalDisplay;

  final TextEditingController _CTEintervalController = TextEditingController();
  final TextEditingController _CTElengthController = TextEditingController();
  final TextEditingController _CTEcountController = TextEditingController();

  String? errortext_interval;
  String? errortext_txpower;
  String? errortext1;
  String? errortext_CTEinterval;
  int getComplete = 0;
  bool isFetchComplete = false;

  @override
  void initState() {
    super.initState();

    UniversalBle.onValueChange = _handleValueChange;
    readBeacon();
  }

  @override
  void dispose() {
    super.dispose();

    UniversalBle.onValueChange = null;
  }

//Method to read beacon values
  Future readBeacon() async {
    Uint8List deviceInfoopcode = Uint8List.fromList([0x30]);

    try {
      BleService selService = widget.selectedCharacteristic!.service;
      BleCharacteristic selChar =
          widget.selectedCharacteristic!.characteristic1;

      for (int i = 0; i < 9; i++) {
        isFetchComplete = false;
        if (i == 0) {
          debugPrint("into adv settings\n");
          deviceInfoopcode = Uint8List.fromList([0x21]);
        } else if (i == 1) {
          debugPrint("into ibeacon get\n");
          deviceInfoopcode = Uint8List.fromList([0x30]);
        } else if (i == 2) {
          debugPrint("into substitution get\n");
          deviceInfoopcode = Uint8List.fromList([0x60]);
        } else if (i == 3) {
          debugPrint("into eddystone-url get\n");
          deviceInfoopcode = Uint8List.fromList([0x34]);
        } else if (i == 4) {
          debugPrint("into altbeacon get\n");
          deviceInfoopcode = Uint8List.fromList([0x36]);
        } else if (i == 5) {
          debugPrint("into Manufacturer Specific Data\n");
          deviceInfoopcode = Uint8List.fromList([0x38]);
        } else if (i == 6) {
          debugPrint("into Device status\n");
          deviceInfoopcode = Uint8List.fromList([0x02]);
        } else if (i == 7) {
          debugPrint("into Eddystone TLM\n");
          deviceInfoopcode = Uint8List.fromList([0x3A]);
        } else if (i == 8) {
          debugPrint("into AoA \n");
          deviceInfoopcode = Uint8List.fromList([0x70]);
        }

        await UniversalBle.writeValue(
          widget.deviceId,
          selService.uuid,
          selChar.uuid,
          deviceInfoopcode,
          BleOutputProperty.withResponse,
        );
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (e) {
      print("Error writing advertising settings: $e");
    }
  }

  bool check = false; // Flag to track dialog state

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

    if (value.length > 3) {
      if (value[1] == 0x21) {
        setState(() {
          selectedRadioIndex = value[3];
          interval1 = (value[5] << 8) | value[4];
          interval1 = (interval1! * 0.625).round();
          txPowerLevel = value[6] > 127 ? (value[6] - 256) : value[6];
          getComplete += 1;
        });
      }
      if (value[1] == 0x02) {
        String productId = value
            .sublist(3, 4) // Extract only the 3rd byte
            .map((byte) =>
                byte.toRadixString(16).padLeft(2, '0')) // Convert to hex
            .join(); // Join into a string
        debugPrint("Product ID: $productId");

        String firmwareverMajor = value
            .sublist(4, 5)
            .map((byte) =>
                byte.toRadixString(16).padLeft(2, '0')) // Convert to hex
            .join();
        debugPrint("Firmware Version Major: $firmwareverMajor");

        String firmwareverMinor = value
            .sublist(5, 6)
            .map((byte) =>
                byte.toRadixString(16).padLeft(2, '0')) // Convert to hex
            .join(); // Join into a string
        debugPrint("Firmware Version Minor: $firmwareverMinor");

        String hwver = value
            .sublist(6, 7)
            .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
            .join();
        debugPrint("Hardware Version : $hwver");

        String batteryvoltage = value
            .sublist(7, 8)
            .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
            .join();
        debugPrint("Battery Voltage : $batteryvoltage");
        // Convert the hex string to a numeric value and multiply by 0.1
        double batteryVoltageValue = int.parse(batteryvoltage, radix: 16) * 0.1;
        String formattedBatteryVoltage = batteryVoltageValue.toStringAsFixed(1);
        debugPrint("Battery Voltage : $formattedBatteryVoltage");

        setState(() {
          _deviceProductId = productId;
          _firmwareversion_Major = firmwareverMajor;
          _firmwareversion_Minor = firmwareverMinor;
          HW_Version = hwver;
          Battery_Voltage = formattedBatteryVoltage;
          getComplete += 1;
        });
      }
      if (value[1] == 0x60) {
        print("entered into sustituion layer");
        setState(() {
          sharedText = value
              .sublist(3)
              .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
              .join();
        });
      }

      if (value[1] == 0x32) {
        print("entered eddystone");
        setState(() {
          namespaceID = value
              .sublist(3, 13)
              .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
              .join();
          instanceID = value
              .sublist(13, 19) // From 4th to 19th byte
              .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
              .join();
          getComplete += 1;
        });
      }

      if (value[1] == 0x30) {
        print("ibeacon");

        setState(() {
          uuid = value
              .sublist(3, 19)
              .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
              .join();
          uuid = '${uuid.substring(0, 8)}-'
              '${uuid.substring(8, 12)}-'
              '${uuid.substring(12, 16)}-'
              '${uuid.substring(16, 20)}-'
              '${uuid.substring(20)}';

          ByteData byteData = ByteData.sublistView(value);

          majorId = byteData.getUint16(19, Endian.big); // Bytes 19-20
          minorId = byteData.getUint16(21, Endian.big);
          getComplete += 1;
        });
      }
      if (value[1] == 0x34) {
        print("entered eddystone url");
        setState(() {
          prefix = value[3];
          print("prefix : $prefix");
          List<int> urlBytes = [];

          for (int i = 4; i < value.length; i++) {
            int byte = value[i];

            // Check for suffix termination condition
            if (byte >= 0x00 && byte < 0x0d) {
              suffix = byte;
              displayurl = String.fromCharCodes(urlBytes);
              // Store suffix
              break;
            }
            // Add byte to URL bytes list
            urlBytes.add(byte);
          }
          print('displayurl : $displayurl');
          print(' suffix : $suffix');
          getComplete += 1;
        });
      }

      if (value[1] == 0x36) {
        print("entered altbeacon");
        setState(() {
          mfgID = value
              .sublist(3, 5)
              .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
              .join();
          beaconID = value
              .sublist(5, 25)
              .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
              .join();

          mfgData = value
              .sublist(25, 26)
              .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
              .join();
          getComplete += 1;
        });
        check = true;
        print('mfid $mfgID');
        print('beaconid $beaconID');
        print('mfgData: $mfgData');
      }

      if (value[1] == 0x38) {
        print("Entered Manufacturer Specific Data");
        setState(() {
          manufacturerId = value
              .sublist(3, 5)
              .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
              .join();
          userData = value
              .sublist(5)
              .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
              .join();

          getComplete += 1;
        });
        print('user data: $userData');
        print('mfid: $manufacturerId');
        print('UserData: $userData');
        check = true;
      }
      if (value[1] == 0x70) {
        print("entered AoA");
        debugPrint("CTE opcode received");
        setState(() {
          showCteCard = value.length > 3 && value[3] == 0x01;
          showCteCard = true;

          ByteData aoaData = ByteData.sublistView(value);

          int enable = aoaData.getUint8(3); // Byte 3
          int interval = aoaData.getUint16(4, Endian.little); // Bytes 4-5
          int cteLength = aoaData.getUint8(6); // Byte 6
          int cteCount = aoaData.getUint8(7); // Byte 7

          // Apply default fallbacks for invalid values (0)
          interval =
              (interval < 6 || interval > 65535) ? 80 : interval; // 80 = 100ms
          // interval = (interval / 1.25).round();
          double intervalMs = (interval * 1.25);

          cteLength = (cteLength < 2 || cteLength > 20) ? 10 : cteLength;
          cteCount = (cteCount < 1 || cteCount > 16) ? 1 : cteCount;

          setState(() {
            AoA_Enable = enable.toString();
            AoA_Interval = intervalMs.toString();
            AoA_CTE_length = cteLength.toString();
            AoA_CTE_count = cteCount.toString();

            cteEnabled = enable == 1;
            getComplete += 1;
          });

          print("Enable: $AoA_Enable");
          print("Interval: $AoA_Interval");
          print("CTE Length: $AoA_CTE_length");
          print("CTE Count: $AoA_CTE_count");

          _CTEintervalController.text = intervalMs.toString();
          _CTElengthController.text = cteLength.toString();
          _CTEcountController.text = cteCount.toString();

          getComplete += 1;
        });
      } else {
        setState(() {
          showCteCard = false;
        });
      }

      if (value[1] == 0x3A) {
        print("Entered Eddystone-TLM");
        setState(() {
          isEddystoneTlmAvailable = true;
          isEddystoneTlmSelected =
              value[3] == 0x01; // Select only if value is 0x01
          getComplete += 1;
        });

        // Decode Battery Voltage (2 bytes, UINT16, big endian)
        int batteryVoltage = (value[3] << 8) | value[4];

        // Decode Temperature (2 bytes, INT16, big endian, divided by 256)
        int tempRaw = (value[5] << 8) | value[6];
        double temperature;
        if (tempRaw == 0x8000) {
          temperature = double.nan; // Not supported
        } else {
          temperature = tempRaw / 256.0;
        }

        // Decode PDU Counter (4 bytes, UINT32, big endian)
        int pduCounter =
            (value[7] << 24) | (value[8] << 16) | (value[9] << 8) | value[10];

        // Decode Time (4 bytes, UINT32, big endian, 0.1s units)
        int timeSinceResetRaw = (value[11] << 24) |
            (value[12] << 16) |
            (value[13] << 8) |
            value[14];
        double timeSinceReset = timeSinceResetRaw / 10.0; // convert to seconds

        setState(() {
          Batteryvoltage = '$batteryVoltage mV';
          Temperature = temperature.isNaN ? 'Not supported' : '$temperature °C';
          PDUcounter = '$pduCounter';
          Time = '$timeSinceReset seconds';
          getComplete += 1;
          check = true;
        });
      }
      if (!value.contains(0x3A)) {
        setState(() {
          isEddystoneTlmAvailable = false;
          isEddystoneTlmSelected = false;
        });
      }

      setState(() async {});
    }
    isFetchComplete = true;
  }

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(title, style: TextStyle(color: Colors.black)),
          content: Text(message, style: TextStyle(color: Colors.black)),
          actions: <Widget>[
            TextButton(
              child: Text(
                "OK",
                style: TextStyle(color: Color.fromRGBO(45, 127, 224, 1)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Uint8List createAdvertisingSettings(
      Uint8List Advopcode, int packetType, interval, int txPowerLevel) {
    if (interval < 20 || interval > 10240) {
      throw Exception(
          "Invalid advertising interval. Accepted values: 20 – 10240.");
    }
    interval = (interval * 1.6).round();
    debugPrint("@@txpowerLevel1: $txPowerLevel ");
    if (txPowerLevel < -60 || txPowerLevel > 10) {
      throw Exception(
          "Invalid Tx Power Level. Accepted values: -60 to 10 dBm.");
    }

    return Uint8List.fromList([
      Advopcode[0],
      packetType, // Advertising Packet Type
      interval & 0xFF, // Lower byte of interval
      (interval >> 8) & 0xFF, // Upper byte of interval
      txPowerLevel, // Tx Power Level
    ]);
  }

  void Set_Advertising_Settings(
      int packetType, int interval, int txPowerLevel) async {
    Uint8List Advopcode = Uint8List.fromList([0x22]);

    try {
      BleService selService = widget.selectedCharacteristic!.service;
      BleCharacteristic selChar =
          widget.selectedCharacteristic!.characteristic1;
      Uint8List advertisingSettings = createAdvertisingSettings(
          Advopcode, packetType, interval, txPowerLevel);

      print("characteristics: ${selChar.uuid}");
      print("DeviceID: ${widget.deviceId}");
      print("Advertising Settings: $advertisingSettings");

      await UniversalBle.writeValue(
        widget.deviceId,
        selService.uuid,
        selChar.uuid,
        advertisingSettings,
        BleOutputProperty.withResponse,
      );

      setState(() {
        response = advertisingSettings;
      });

      print(
          "Advertising Settings data written to device: $advertisingSettings");
    } catch (e) {
      print("Error writing advertising settings: $e");
    }
  }

// // Radio button widget
  Widget _buildRadioRow(String option, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedRadioIndex = index;
          packetType = index;
          _handleRadioChange(index); // Open the respective page
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Text(
              option,
              style: TextStyle(
                color: Colors.black,
                fontWeight: (option == 'Eddystone-UID' ||
                        option == 'Eddystone-URL' ||
                        option == 'iBeacon' ||
                        option == 'AltBeacon' ||
                        option == 'Manufacturer Specific Data' ||
                        option == 'Eddystone-TLM')
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
          Radio<int>(
            value: index,
            groupValue: selectedRadioIndex,

            activeColor:
                Color.fromRGBO(45, 127, 224, 1), // Set the active color to blue
            onChanged: (int? value) {
              setState(() {
                selectedRadioIndex = value!;
                packetType = value;
                _handleRadioChange(value);
              });
            },

            focusColor: Color.fromRGBO(45, 127, 224, 1), // Add focus color
            hoverColor: Color.fromRGBO(45, 127, 224, 1), // Add hover color
            visualDensity:
                VisualDensity(vertical: -3.0), // Adjust vertical spacing
          ),
        ],
      ),
    );
  }

//Configuration page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(247, 247, 244, 244),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize
              .min, // Ensure the Row doesn't take up all available space
          children: [
            Text(
              "EM Beacon Tuner Configuration",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
            SizedBox(width: 8),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                !check
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 20),
                            Text("Connecting to device..."),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          Container(
                            width: double
                                .infinity, // Set the desired width for the button
                            margin: const EdgeInsets.only(
                                top: 0.0, bottom: 8.0), // Add spacing
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(200, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                backgroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Scaffold(
                                      backgroundColor:
                                          Color.fromARGB(247, 247, 244, 244),
                                      appBar: AppBar(
                                        backgroundColor: Colors.white,
                                        title: Text(
                                          'Device status',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        centerTitle: true,
                                      ),
                                      body: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            // Card for Product ID
                                            Container(
                                              padding: EdgeInsets.all(12),
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 8, horizontal: 16),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                    blurRadius: 6,
                                                    offset: Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "Product ID",
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  Text(
                                                    "$_deviceProductId",
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Card for Firmware Version Major
                                            Container(
                                              padding: EdgeInsets.all(12),
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 8, horizontal: 16),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                    blurRadius: 6,
                                                    offset: Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "Firmware Version Major",
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  Text(
                                                    "$_firmwareversion_Major",
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Card for Firmware Version Minor
                                            Container(
                                              padding: EdgeInsets.all(12),
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 8, horizontal: 16),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                    blurRadius: 6,
                                                    offset: Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "Firmware Version Minor",
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  Text(
                                                    "$_firmwareversion_Minor",
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Card for Hardware Version
                                            Container(
                                              padding: EdgeInsets.all(12),
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 8, horizontal: 16),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                    blurRadius: 6,
                                                    offset: Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "Hardware Version",
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  Text(
                                                    "$HW_Version",
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Card for Battery Voltage
                                            Container(
                                              padding: EdgeInsets.all(12),
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 8, horizontal: 16),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                    blurRadius: 6,
                                                    offset: Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "Battery Voltage",
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  Text(
                                                    "$Battery_Voltage V",
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'Read Device Status',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 15),
                              ),
                            ),
                          ),
                          // Toggle Switch Inside White Textbox
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            margin: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Beaconing State',
                                  style: TextStyle(color: Colors.black),
                                ),
                                Spacer(),
                                Switch(
                                  value: isOn,
                                  activeColor: Colors.white,

                                  activeTrackColor:
                                      Color.fromRGBO(45, 127, 224, 1),
                                  inactiveThumbColor:
                                      Colors.white, // Thumb color when OFF
                                  inactiveTrackColor:
                                      Color.fromARGB(247, 247, 244, 244),

                                  onChanged: (value) {
                                    setState(() {
                                      isOn = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),

                          Row(
                            children: [
                              Text('Interval (20 to 10240 ms)',
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.grey)),
                            ],
                          ),
                          SizedBox(height: 10),
                          Material(
                            elevation: 2,
                            borderRadius: BorderRadius.circular(10),
                            child: TextFormField(
                              style: TextStyle(fontSize: 15),
                              onTapOutside: (event) =>
                                  FocusManager.instance.primaryFocus?.unfocus,
                              inputFormatters: _interval,
                              initialValue: interval1!.toString(),
                              decoration: InputDecoration(
                                isDense: true,
                                errorText: errortext_interval,
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 5, 10, 5),
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                int? intervalValue = int.tryParse(value ?? '');
                                if (intervalValue == null ||
                                    intervalValue < 20 ||
                                    intervalValue > 10240) {
                                  return 'Enter a valid interval (20 to 10240 ms).';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                int? enteredValue = int.tryParse(value) ?? 20;
                                setState(() {
                                  if (enteredValue > 10240) {
                                    errortext_interval =
                                        'Enter a valid interval (20 to 10240 ms). ';
                                  } else if (enteredValue < 20) {
                                    errortext_interval =
                                        'Enter a valid interval (20 to 10240 ms). ';
                                  } else {
                                    errortext_interval = null;
                                    interval1 = enteredValue;
                                  }
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Text('TX Power Level (-60 to +10 dBm)',
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.grey)),
                            ],
                          ),
                          SizedBox(height: 10),

                          Material(
                            elevation: 2,
                            borderRadius: BorderRadius.circular(10),
                            child: TextFormField(
                              style: TextStyle(fontSize: 15),
                              onTapOutside: (event) =>
                                  FocusManager.instance.primaryFocus?.unfocus,
                              inputFormatters: _txpowerlevel,
                              initialValue: txPowerLevel.toString(),
                              decoration: InputDecoration(
                                isDense: true,
                                errorText: errortext_txpower,
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 5, 10, 5),
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                int? txPowerValue = int.tryParse(value ?? '');
                                if (txPowerValue == null ||
                                    txPowerValue < -60 ||
                                    txPowerValue > 10) {
                                  return 'Please enter a valid TX power level (-60 to 10 dBm).';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                int? txPowerValue = int.tryParse(value);
                                setState(() {
                                  if (txPowerValue! > 10) {
                                    errortext_txpower =
                                        'Enter a valid txpower (-60 to 10 dBm). ';
                                  } else if (txPowerValue < -60) {
                                    errortext_txpower =
                                        'Enter a valid txpower (-60 to 10 dBm). ';
                                  } else {
                                    errortext_txpower = null;
                                    txPowerLevel = txPowerValue;
                                  }
                                });
                                if (txPowerValue != null) {
                                  txPowerLevel = txPowerValue;
                                  debugPrint('txPowerlevel: $txPowerLevel');
                                }
                              },
                            ),
                          ),
                          SizedBox(height: 10),

                          SizedBox(height: 20),
                          Card(
                            elevation: 2.0,
                            color: Colors.white,
                            margin: EdgeInsets.all(0),
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Advertising Packet',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    height: 1.0,
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                  _buildRadioRow('iBeacon', 0),
                                  _buildRadioRow('Eddystone-UID', 1),
                                  _buildRadioRow('Eddystone-URL', 2),
                                  _buildRadioRow(
                                    'Eddystone-TLM',
                                    3,
                                  ),
                                  _buildRadioRow('AltBeacon', 4),
                                  _buildRadioRow(
                                      'Manufacturer Specific Data', 5),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          if (showCteCard)
                            SizedBox(
                              height: cteEnabled
                                  ? 350
                                  : 70, // Adjust collapsed height as needed
                              child: Card(
                                elevation: 2.0,
                                color: Colors.white,
                                margin: EdgeInsets.all(0),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start, // Ensure alignment starts from left
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'CTE Enable', // Change text as needed
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                          Spacer(), // This creates the space between the text and the toggle
                                          Switch(
                                            value: cteEnabled,
                                            activeColor: Colors.white,
                                            activeTrackColor:
                                                Color.fromRGBO(45, 127, 224, 1),
                                            inactiveThumbColor: Colors.white,
                                            inactiveTrackColor: Color.fromARGB(
                                                247, 247, 244, 244),
                                            onChanged: (val) {
                                              setState(() {
                                                cteEnabled = val;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      if (cteEnabled)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Interval Units (6 to 65535)',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Material(
                                              elevation: 2,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: TextFormField(
                                                controller:
                                                    _CTEintervalController,
                                                style: TextStyle(fontSize: 15),
                                                inputFormatters:
                                                    _intervalInputFormatters,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                          10, 5, 10, 5),
                                                  fillColor: Colors.white,
                                                  filled: true,
                                                  border: OutlineInputBorder(),
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter a value';
                                                  }
                                                  if (!RegExp(r'^\d+$')
                                                      .hasMatch(value)) {
                                                    return 'Only numbers are allowed';
                                                  }
                                                  final intValue =
                                                      int.tryParse(value);
                                                  if (intValue == null ||
                                                      intValue < 6 ||
                                                      intValue > 65535) {
                                                    return 'Interval must be between 6 and 65535';
                                                  }
                                                  return null;
                                                },
                                                onChanged: (value) {
                                                  AoA_Interval = value;
                                                  _formKey.currentState
                                                      ?.validate();

                                                  final intValue =
                                                      int.tryParse(value);

                                                  if (intValue != null &&
                                                      intValue >= 6 &&
                                                      intValue <= 65535) {
                                                    final calculated =
                                                        (intValue * 1.25)
                                                            .toStringAsFixed(2);
                                                    setState(() {
                                                      calculatedIntervalDisplay =
                                                          'Equivalent Interval Time: $calculated ms ';
                                                    });
                                                  } else {
                                                    setState(() {
                                                      calculatedIntervalDisplay =
                                                          null;
                                                    });
                                                  }
                                                },
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            if (calculatedIntervalDisplay !=
                                                null)
                                              Text(
                                                calculatedIntervalDisplay!,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.blue[600],
                                                ),
                                              ),
                                            //  ],
                                            //  ),

                                            SizedBox(height: 16),
                                            // CTE Length Field
                                            Row(
                                              children: [
                                                Text(
                                                  'CTE Length (2 to 20)',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10),

                                            Material(
                                              elevation: 2,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: TextFormField(
                                                controller:
                                                    _CTElengthController,
                                                style: TextStyle(fontSize: 15),
                                                inputFormatters:
                                                    _ctelengthInputFormatters,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                          10, 5, 10, 5),
                                                  fillColor: Colors.white,
                                                  filled: true,
                                                  border: OutlineInputBorder(),
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter a value';
                                                  }
                                                  if (!RegExp(r'^\d+$')
                                                      .hasMatch(value)) {
                                                    return 'Only numbers are allowed';
                                                  }
                                                  final intValue =
                                                      int.tryParse(value);
                                                  if (intValue == null ||
                                                      intValue < 2 ||
                                                      intValue > 20) {
                                                    return 'CTE Length must be between 2 and 20';
                                                  }
                                                  return null;
                                                },
                                                onChanged: (value) {
                                                  AoA_CTE_length = value;
                                                  _formKey.currentState
                                                      ?.validate(); // Re-validate on every change
                                                },
                                              ),
                                            ),
                                            SizedBox(height: 16),
                                            // CTE Count Field
                                            Row(
                                              children: [
                                                Text(
                                                  'CTE Count (1 to 16)',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10),

                                            Material(
                                              elevation: 2,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: TextFormField(
                                                controller: _CTEcountController,
                                                style: TextStyle(fontSize: 15),
                                                inputFormatters:
                                                    _ctecountInputFormatters,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                          10, 5, 10, 5),
                                                  fillColor: Colors.white,
                                                  filled: true,
                                                  border: OutlineInputBorder(),
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter a value';
                                                  }
                                                  if (!RegExp(r'^\d+$')
                                                      .hasMatch(value)) {
                                                    return 'Only numbers are allowed';
                                                  }
                                                  final intValue =
                                                      int.tryParse(value);
                                                  if (intValue == null ||
                                                      intValue < 1 ||
                                                      intValue > 16) {
                                                    return 'CTE Count must be between 1 and 16';
                                                  }
                                                  return null;
                                                },
                                                onChanged: (value) {
                                                  AoA_CTE_count = value;
                                                  _formKey.currentState
                                                      ?.validate(); // Re-validate on every change
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(
            16.0, 0, 16.0, 40), // Adjust bottom padding

        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  backgroundColor: Color.fromRGBO(45, 127, 224, 1),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (txPowerLevel! > 6) {
                      _showHighRfOutputDialog();
                    } else {
                      _applySettings();
                      String enableHex = cteEnabled ? "01" : "00";

                      setAOA(enableHex, AoA_Interval, AoA_CTE_length,
                          AoA_CTE_count);
                    }
                  }
                },
                child: Text(
                  'Apply',
                  style: TextStyle(
                      color: Color.fromRGBO(250, 247, 243, 1), fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void setAOA(
      String enableHex, // 1 byte
      String intervalHex, // 2 bytes
      String cteLengthHex, // 1 byte
      String cteCountHex // 1 byte
      ) async {
    Uint8List Advopcode = Uint8List.fromList([0x71]); // Example opcode for AOA

    try {
      BleService selService = widget.selectedCharacteristic!.service;
      BleCharacteristic selChar =
          widget.selectedCharacteristic!.characteristic1;

      Uint8List aoaSettings = createAOASettings(
        Advopcode,
        enableHex,
        intervalHex,
        cteLengthHex,
        cteCountHex,
      );

      _addLog(
        "Sent",
        aoaSettings.map((b) => b.toRadixString(16).padLeft(2, '0')).join('-'),
      );

      await UniversalBle.writeValue(
        widget.deviceId,
        selService.uuid,
        selChar.uuid,
        aoaSettings,
        BleOutputProperty.withResponse,
      );

      setState(() {
        response = aoaSettings;
      });

      String hex =
          aoaSettings.map((b) => b.toRadixString(16).padLeft(2, '0')).join('-');
      print("AoA data written to device: $hex");
    } catch (e) {
      print("Error writing AOA settings: $e");
    }
  }

  Uint8List createAOASettings(Uint8List Advopcode, String enableHex,
      String intervalHex, String cteLengthHex, String cteCountHex) {
    // Step 1: Convert hex string to decimal integers
    int enable = int.parse(enableHex); // 1 byte
    interval = int.parse(intervalHex); // 2 bytes
    int cteLength = int.parse(cteLengthHex); // 1 byte
    int cteCount = int.parse(cteCountHex); // 1 byte
    print("interval value:$interval");
    print("intervalhex:$intervalHex");
    print("cte length: $cteLength");
    print("cte count: $cteCount");

    // Step 2: Split 2-byte interval into 2 bytes (Little Endian format)
    Uint8List intervalBytes = Uint8List(2);
    intervalBytes[0] = interval & 0xFF; // LSB
    intervalBytes[1] = (interval >> 8) & 0xFF; // MSB

    return Uint8List.fromList([
      Advopcode[0],
      enable,
      intervalBytes[0],
      intervalBytes[1],
      cteLength,
      cteCount
    ]);
  }

  // Success Dialog Method after applying configuration
  void _applySettings() {
    try {
      if (isOn) {
        // Enable advertising (Opcode: 0x20, Enable response: 20-01)
        _setAdvertisingState(true);
      } else {
        // Disable advertising (Opcode: 0x20, Disable response: 20-00)
        _setAdvertisingState(false);
      }

      Set_Advertising_Settings(selectedRadioIndex!, interval1!, txPowerLevel!);
      _showDialog(
          context, "Success", "Changes have been applied successfully.");
    } catch (e) {
      _showDialog(
          context, "Error", "Changes could not be applied: ${e.toString()}");
    }
  }

  void _setAdvertisingState(bool enable) async {
    try {
      BleService selService = widget.selectedCharacteristic!.service;
      BleCharacteristic selChar =
          widget.selectedCharacteristic!.characteristic1;

      // Create advertising command
      Uint8List Advopcode = enable
          ? Uint8List.fromList([0x20, 0x01]) // Enable advertising
          : Uint8List.fromList([0x20, 0x00]); // Disable advertising

      print("characteristics: ${selChar.uuid}");
      print("DeviceID: ${widget.deviceId}");
      print("Advertising Command: $Advopcode");

      await UniversalBle.writeValue(
        widget.deviceId,
        selService.uuid,
        selChar.uuid,
        Advopcode,
        BleOutputProperty.withResponse,
      );

      print(
          "Advertising ${enable ? "enabled" : "disabled"} successfully: $Advopcode");
    } catch (e) {
      print("Error updating advertising state: $e");
    }
  }

  // Regular expression to validate UUID (32 hexadecimal characters)
  final List<TextInputFormatter> _enableInputFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
    LengthLimitingTextInputFormatter(2),
    _ENABLETextFormatter(),
  ];
  final List<TextInputFormatter> _intervalInputFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
    LengthLimitingTextInputFormatter(5),
    _INTERVALTextFormatter(),
  ];
  final List<TextInputFormatter> _ctelengthInputFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
    LengthLimitingTextInputFormatter(2),
    _CTELENGTHTextFormatter(),
  ];
  final List<TextInputFormatter> _ctecountInputFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
    LengthLimitingTextInputFormatter(2),
    _CTECOUNTTextFormatter(),
  ];

  final _uuidRegex = RegExp(r'^[0-9a-fA-F]{32}$');
  final List<TextInputFormatter> _uuidInputFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
    LengthLimitingTextInputFormatter(32),
    _UUIDTextFormatter(),
  ];
  final List<TextInputFormatter> _interval = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
    LengthLimitingTextInputFormatter(5),
  ];

  final List<TextInputFormatter> _txpowerlevel = [
    FilteringTextInputFormatter.allow(RegExp(r'-?[0-9]*')),
    LengthLimitingTextInputFormatter(3),
  ];

  final List<TextInputFormatter> _majoridInputFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
    LengthLimitingTextInputFormatter(5),
    _MAJORIDTextFormatter(),
  ];

  final List<TextInputFormatter> _minoridInputFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
    LengthLimitingTextInputFormatter(5),
    _MINORIDTextFormatter(),
  ];

  final List<TextInputFormatter> _urlInputFormatters = [
    LengthLimitingTextInputFormatter(16),
    _URLTextFormatter(),
  ];

//Method to open respective page for each beacon type
  void _handleRadioChange(int value) {
    switch (value) {
      case 0:
        final GlobalKey<FormState> formKey = GlobalKey<FormState>();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: Color.fromARGB(247, 247, 244, 244),
              appBar: AppBar(
                backgroundColor: Colors.white,
                title: Text(
                  "iBeacon",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // UUID TextBox
                              Row(
                                children: [
                                  Text(' Proximity UUID (16 Bytes)',
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.grey)),
                                ],
                              ),
                              Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(10),
                                child: TextFormField(
                                  style: TextStyle(fontSize: 15),
                                  inputFormatters: _uuidInputFormatters,
                                  initialValue: uuid,
                                  decoration: InputDecoration(
                                    hintText:
                                        'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    isDense: false,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 5, 10, 5),
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'UUID cannot be empty.';
                                    } else if (!_uuidRegex
                                        .hasMatch(value.replaceAll('-', ''))) {
                                      return 'Invalid UUID format. It should be 32 hex characters.';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      uuid = value.replaceAll('-', '');
                                    });
                                  },
                                ),
                              ),
                              SizedBox(height: 16),
                              // Major ID TextBox
                              Row(
                                children: [
                                  Text(' Major ID (0 to 65535)',
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.grey)),
                                ],
                              ),
                              Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(10),
                                child: TextFormField(
                                  style: TextStyle(fontSize: 15),
                                  inputFormatters: _majoridInputFormatters,
                                  initialValue: majorId.toString(),
                                  decoration: InputDecoration(
                                    errorText: errortext1,
                                    isDense: true,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 5, 10, 5),
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    int? majorIdValue =
                                        int.tryParse(value ?? '');
                                    if (majorIdValue == null ||
                                        majorIdValue < 0 ||
                                        majorIdValue > 65535) {
                                      return 'Please enter a valid Major ID (0 - 65535).';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    majorId = int.tryParse(value) ?? 1;
                                    setState(() {
                                      if (majorId! > 65535) {
                                        errortext1 =
                                            'Please enter a valid Minor ID (0 - 65535).';
                                      } else {
                                        errortext1 = null;
                                      }
                                    });
                                  },
                                ),
                              ),
                              SizedBox(height: 16),
                              // Minor ID TextBox
                              Row(
                                children: [
                                  Text(' Minor ID (0 to 65535)',
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.grey)),
                                ],
                              ),
                              Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(10),
                                child: TextFormField(
                                  style: TextStyle(fontSize: 15),
                                  inputFormatters: _minoridInputFormatters,
                                  initialValue: minorId.toString(),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    errorText: errortext1,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 5, 10, 5),
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    int? minorIdValue =
                                        int.tryParse(value ?? '');
                                    if (minorIdValue == null ||
                                        minorIdValue < 0 ||
                                        minorIdValue > 65535) {
                                      return 'Please enter a valid Minor ID (0 - 65535).';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    minorId = int.tryParse(value);
                                    setState(() {
                                      if (minorId! > 65535) {
                                        errortext1 =
                                            'Please enter a valid Minor ID (0 - 65535).';
                                      } else {
                                        errortext1 = null;
                                      }
                                    });
                                  },
                                ),
                              ),
                              SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Button at the bottom
                    Container(
                      width: double
                          .infinity, // Ensures the button spans the full width

                      margin: const EdgeInsets.only(
                          top: 16.0,
                          bottom:
                              32.0), // Adds spacing without shrinking the button
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          backgroundColor: Color.fromRGBO(45, 127, 224, 1),
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            Set_ibeacon_Packet(uuid, majorId!, minorId!);
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Apply',
                            style: TextStyle(
                                color: Color.fromRGBO(250, 247, 243, 1),
                                fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        break;

      case 1:
        final GlobalKey<FormState> formKey = GlobalKey<FormState>();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EddystoneScreen(
                    deviceId: widget.deviceId,
                    deviceName: widget.deviceName,
                    selectedCharacteristic: widget.selectedCharacteristic,
                  )),
        );

        break;

      case 2:
        final GlobalKey<FormState> formKey = GlobalKey<FormState>();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              backgroundColor: Color.fromARGB(247, 247, 244, 244),
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                backgroundColor: Colors.white,
                title: Text(
                  "Eddystone-URL",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 16),

                              // URL Scheme Prefix Input
                              Row(
                                children: [
                                  Text(' Encoding',
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.grey)),
                                ],
                              ),
                              DropdownButtonFormField<int>(
                                value: prefix,
                                items: [
                                  DropdownMenuItem(
                                      value: 0, child: Text("http://www.")),
                                  DropdownMenuItem(
                                      value: 1, child: Text("https://www.")),
                                  DropdownMenuItem(
                                      value: 2, child: Text("http://")),
                                  DropdownMenuItem(
                                      value: 3, child: Text("https://")),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    prefix = value;
                                  }
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(' URL (max 16 char)',
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.grey)),
                                ],
                              ),
                              Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(10),
                                child: TextFormField(
                                  style: TextStyle(fontSize: 15),
                                  inputFormatters: _urlInputFormatters,
                                  initialValue: displayurl,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 5, 10, 5),
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'URL cannot be empty.';
                                    }

                                    final regex = RegExp(r'^[a-zA-Z0-9/_]+$');
                                    if (!regex.hasMatch(value)) {
                                      return 'URL should contain only letters, numbers, slashes (/), and underscores (_).';
                                    }

                                    final encodedUrl = utf8.encode(value);
                                    if (encodedUrl.isEmpty ||
                                        encodedUrl.length > 16) {
                                      return 'URL length should be between 1 to 16 values.';
                                    }

                                    return null;
                                  },
                                  onChanged: (value) {
                                    if (formKey.currentState?.validate() ==
                                        true) {
                                      displayurl = value;
                                      url = utf8
                                          .encode(value)
                                          .map((byte) => byte
                                              .toRadixString(16)
                                              .padLeft(2, '0'))
                                          .join();
                                    }
                                  },
                                ),
                              ),
                              SizedBox(height: 16),

                              // Suffix Input
                              Row(
                                children: [
                                  Text(' Suffix',
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.grey)),
                                ],
                              ),
                              DropdownButtonFormField<int?>(
                                value: suffix,
                                items: [
                                  // DropdownMenuItem(
                                  //     value: null, child: Text("-no suffix-")),
                                  DropdownMenuItem(
                                      value: 0x00, child: Text(".com/")),
                                  DropdownMenuItem(
                                      value: 0x01, child: Text(".org/")),
                                  DropdownMenuItem(
                                      value: 0x02, child: Text(".edu/")),
                                  DropdownMenuItem(
                                      value: 0x03, child: Text(".net/")),
                                  DropdownMenuItem(
                                      value: 0x04, child: Text(".info/")),
                                  DropdownMenuItem(
                                      value: 0x05, child: Text(".biz/")),
                                  DropdownMenuItem(
                                      value: 0x06, child: Text(".gov/")),
                                  DropdownMenuItem(
                                      value: 0x07, child: Text(".com")),
                                  DropdownMenuItem(
                                      value: 0x08, child: Text(".org")),
                                  DropdownMenuItem(
                                      value: 0x09, child: Text(".edu")),
                                  DropdownMenuItem(
                                      value: 0x0a, child: Text(".net")),
                                  DropdownMenuItem(
                                      value: 0x0b, child: Text(".info")),
                                  DropdownMenuItem(
                                      value: 0x0c, child: Text(".biz")),
                                  DropdownMenuItem(
                                      value: 0x0d, child: Text(".gov")),
                                ],
                                onChanged: (value) {
                                  suffix = value;
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Apply Button at the bottom
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 16.0, bottom: 32.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          backgroundColor: Color.fromRGBO(45, 127, 224, 1),
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            // Process the validated input
                            setEddystoneURLPacket(prefix!, url, suffix);
                            Navigator.pop(
                                context); // Navigate only if validation is successful
                          } else {
                            // Optionally show a message or handle invalid input cases
                            print(
                                'Validation failed. Please correct the inputs.');
                          }
                        },
                        child: const Text(
                          'Apply',
                          style: TextStyle(
                              color: Color.fromRGBO(250, 247, 243, 1),
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EddystoneTLMScreen(
                    deviceId: widget.deviceId,
                    deviceName: widget.deviceName,
                    selectedCharacteristic: widget.selectedCharacteristic,
                  )),
        );
        break;

      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AltBeaconScreen(
                    deviceId: widget.deviceId,
                    deviceName: widget.deviceName,
                    selectedCharacteristic: widget.selectedCharacteristic,
                  )),
        );

        break;

      case 5:
        // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ManufacturerspecificdataScreen(
                    deviceId: widget.deviceId,
                    deviceName: widget.deviceName,
                    selectedCharacteristic: widget.selectedCharacteristic,
                  )),
        );
    }
  }

// Helper function to check if a string is a valid hex string of a specific length
  bool isValidHex(String hex, int expectedLength) {
    if (hex.length != expectedLength) return false;
    final validHex = RegExp(r'^[0-9A-Fa-f]+$');
    return validHex.hasMatch(hex);
  }

  Uint8List createibeaconSettings(
      Uint8List Advopcode, String uuid, int majorId, int minorId) {
    // Remove hyphens from the UUID
    String cleanUuid = uuid.replaceAll('-', '');

    // Convert the clean UUID string to a Uint8List
    Uint8List uuidBytes = Uint8List.fromList(List.generate(16, (i) {
      return int.parse(cleanUuid.substring(i * 2, i * 2 + 2), radix: 16);
    }));

    return Uint8List.fromList([
      Advopcode[0],
      ...uuidBytes, // Spread the uuidBytes
      (majorId >> 8) & 0xFF, // Major ID high byte
      majorId & 0xFF, // Major ID low byte
      (minorId >> 8) & 0xFF, // Minor ID high byte
      minorId & 0xFF, // Minor ID low byte
    ]);
  }

  void Set_ibeacon_Packet(String uuid, int majorId, int minorId) async {
    Uint8List Advopcode = Uint8List.fromList([0x31]);
    // Uint8List? response;
    try {
      BleService selService = widget.selectedCharacteristic!.service;
      BleCharacteristic selChar =
          widget.selectedCharacteristic!.characteristic1;
      Uint8List iBeaconSettings =
          createibeaconSettings(Advopcode, uuid, majorId, minorId);

      print("characteristics: ${selChar.uuid}");
      print("DeviceID: ${widget.deviceId}");
      print("Advertising Settings: $createibeaconSettings");
      _addLog(
          "Sent",
          iBeaconSettings
              .map((b) => b.toRadixString(16).padLeft(2, '0'))
              .join('-'));
      await UniversalBle.writeValue(
        widget.deviceId,
        selService.uuid,
        selChar.uuid,
        iBeaconSettings,
        BleOutputProperty.withResponse,
      );

      setState(() {
        response = iBeaconSettings;
      });

      print("iBeacon data written to the device: $iBeaconSettings");
    } catch (e) {
      print("Error writing advertising settings: $e");
    }
  }

// Function to convert hex string to Uint8List
  Uint8List hexStringToBytes(String hex) {
    hex = hex.replaceAll(
        RegExp(r'[^0-9A-Fa-f]'), ''); // Remove non-hexadecimal characters
    if (hex.length % 2 != 0) {
      hex = "0$hex"; // Pad with a leading 0 if the length is odd
    }
    return Uint8List.fromList(List.generate(hex.length ~/ 2,
        (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16)));
  }

  Uint8List createEddystoneUrlPacket(
      Uint8List Advopcode, int prefix, String url, int? suffix) {
    // Convert the URL (hexadecimal string) to a byte array
    List<int> urlBytes = _hexStringToBytes(url);
    List<int> extraBytesArray = [];
    debugPrint("urlBytes:${urlBytes.length}");

    // If a suffix is provided (not null), append it to the URL bytes
    if (suffix != null) {
      urlBytes.add(suffix);
    }
    if (urlBytes.length < 17) {
      while (urlBytes.length < 17) {
        urlBytes.add(0x20);
      }
    }

    // Construct the Eddystone-URL packet
    return Uint8List.fromList([
      Advopcode[0],
      prefix,
      ...urlBytes,
      ...extraBytesArray,
    ]);
  }

// Method to convert a hex string to bytes
  List<int> _hexStringToBytes(String hex) {
    List<int> bytes = [];
    for (int i = 0; i < hex.length; i += 2) {
      String byteString = hex.substring(i, i + 2);
      int byteValue = int.parse(byteString, radix: 16);
      bytes.add(byteValue);
    }
    return bytes;
  }

  void setEddystoneURLPacket(
    int prefix,
    String encodedUrlHex,
    int? suffix,
  ) async {
    Uint8List Advopcode = Uint8List.fromList([0x35]);

    try {
      BleService selService = widget.selectedCharacteristic!.service;
      BleCharacteristic selChar =
          widget.selectedCharacteristic!.characteristic1;

      // Create Eddystone URL Settings
      Uint8List eddyBeaconSettings =
          createEddystoneUrlPacket(Advopcode, prefix, encodedUrlHex, suffix);

      print("Characteristics UUID: ${selChar.uuid}");
      print("Device ID: ${widget.deviceId}");
      print("Advertising Settings: $eddyBeaconSettings");
      _addLog(
          "Sent",
          eddyBeaconSettings
              .map((b) => b.toRadixString(16).padLeft(2, '0'))
              .join('-'));
      await UniversalBle.writeValue(
        widget.deviceId,
        selService.uuid,
        selChar.uuid,
        eddyBeaconSettings,
        BleOutputProperty.withResponse,
      );

      setState(() {});

      print("Eddystone-URL data written to the device: $eddyBeaconSettings");
    } catch (e) {
      print("Error writing advertising settings: $e");
    }
  }

  Uint8List stringToHex(String input) {
    List<int> hexBytes = [];
    for (int i = 0; i < input.length; i++) {
      int hexValue =
          input.codeUnitAt(i); // Get the ASCII value of each character
      hexBytes.add(hexValue); // Add to the list as bytes
    }
    return Uint8List.fromList(hexBytes);
  }

  // High RF Output Power Dialog
  void _showHighRfOutputDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
              'Warning!\nThe requested output power level is greater than 6 dbm and is subjected to device compliance.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _applySettings(); // Apply settings after the dialog is closed
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
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
}

class _UUIDTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove existing dashes from the new text
    String rawText = newValue.text.replaceAll('-', '');
    String formattedText = '';
    int rawCursorPosition = newValue.selection.baseOffset;

    // Build the formatted string by inserting dashes at appropriate positions
    for (int i = 0; i < rawText.length; i++) {
      if (i == 8 || i == 12 || i == 16 || i == 20) {
        formattedText += '-';
      }
      formattedText += rawText[i];
    }

    // Calculate the new cursor position
    int cursorPosition = rawCursorPosition;
    int dashCountBeforeCursor = 0;

    // Count dashes that would be added before the raw cursor position
    for (int i = 0; i < cursorPosition; i++) {
      if (i == 8 || i == 12 || i == 16 || i == 20) {
        dashCountBeforeCursor++;
      }
    }

    cursorPosition += dashCountBeforeCursor;

    // Ensure the cursor doesn't exceed the formatted text length
    cursorPosition = cursorPosition.clamp(0, formattedText.length);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

class _MAJORIDTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    // Format the new text if needed
    String formattedText = newText;

    // Calculate the new cursor position based on the user's input
    int newOffset =
        newValue.selection.baseOffset + (formattedText.length - newText.length);

    // Ensure the new offset is within bounds
    newOffset = newOffset.clamp(0, formattedText.length);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}

class _MINORIDTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    // Format the new text if needed
    String formattedText = newText;

    // Calculate the new cursor position based on the user's input
    int newOffset =
        newValue.selection.baseOffset + (formattedText.length - newText.length);

    // Ensure the new offset is within bounds
    newOffset = newOffset.clamp(0, formattedText.length);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}

class _URLTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    // Format the new text if needed
    String formattedText = newText;

    // Calculate the new cursor position based on the user's input
    int newOffset =
        newValue.selection.baseOffset + (formattedText.length - newText.length);

    // Ensure the new offset is within bounds
    newOffset = newOffset.clamp(0, formattedText.length);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}

class _ENABLETextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    // Format the new text if needed
    String formattedText = newText;

    // Calculate the new cursor position based on the user's input
    int newOffset =
        newValue.selection.baseOffset + (formattedText.length - newText.length);

    // Ensure the new offset is within bounds
    newOffset = newOffset.clamp(0, formattedText.length);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}

class _INTERVALTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    // Format the new text if needed
    String formattedText = newText;

    // Calculate the new cursor position based on the user's input
    int newOffset =
        newValue.selection.baseOffset + (formattedText.length - newText.length);

    // Ensure the new offset is within bounds
    newOffset = newOffset.clamp(0, formattedText.length);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}

class _CTELENGTHTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    // Format the new text if needed
    String formattedText = newText;

    // Calculate the new cursor position based on the user's input
    int newOffset =
        newValue.selection.baseOffset + (formattedText.length - newText.length);

    // Ensure the new offset is within bounds
    newOffset = newOffset.clamp(0, formattedText.length);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}

class _CTECOUNTTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    // Format the new text if needed
    String formattedText = newText;

    // Calculate the new cursor position based on the user's input
    int newOffset =
        newValue.selection.baseOffset + (formattedText.length - newText.length);

    // Ensure the new offset is within bounds
    newOffset = newOffset.clamp(0, formattedText.length);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}
