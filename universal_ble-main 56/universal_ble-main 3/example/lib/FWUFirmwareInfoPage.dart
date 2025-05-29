import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:universal_ble/universal_ble.dart';

import 'package:path_provider/path_provider.dart';
import 'package:universal_ble_example/FWUFirmwareUpdatePage.dart';
import 'package:universal_ble_example/dashboard.dart';

int icFamilyId = 0;
int commandStatus = 0;
int siliconVersion = 0;
int firmwareRevision = 0;
int firmwareType = 0;
bool isFirmwareInfoReceived = false; // To track if data is received
int count = 0;

class FwuFirmwareInfoPage extends StatefulWidget {
  final String deviceId;
  final String deviceName;

  final ({
    BleService service,
    BleCharacteristic characteristic1,
    BleCharacteristic characteristic2,
  }) selectedCharacteristic;

  const FwuFirmwareInfoPage({
    super.key,
    required this.deviceId,
    required this.deviceName,
    required this.selectedCharacteristic,
  });

  @override
  State<StatefulWidget> createState() {
    return _FwuFirmwareInfoPageState();
  }
}

class _FwuFirmwareInfoPageState extends State<FwuFirmwareInfoPage> {
  Future getFirmwareInfo() async {
    Uint8List opcode = Uint8List.fromList([0x01]);

    try {
      BleService selService = widget.selectedCharacteristic.service;
      BleCharacteristic selChar = widget.selectedCharacteristic.characteristic1;
      await UniversalBle.writeValue(
        widget.deviceId,
        selService.uuid,
        selChar.uuid,
        opcode,
        BleOutputProperty.withResponse,
      );
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint("Error writing advertising settings: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    UniversalBle.onValueChange = _handleValueChange;
    getFirmwareInfo();
  }

  @override
  void dispose() {
    super.dispose();
    UniversalBle.onValueChange = null;
  }

  //Method to extract byte values for all beacon types from response
  void _handleValueChange(
      String deviceId, String characteristicId, Uint8List value) {
    // Extract hex string with each byte joined with '-' (only for debug purpose)
    String responseString =
        value.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('-');

    debugPrint('Received hex data: $responseString');
    _addLog("Received", responseString);

    if (value.isNotEmpty && value[0] == 0x01) {
      if (value.length >= 11) {
        setState(() {
          commandStatus = value[1];
          icFamilyId =
              value[2] | (value[3] << 8) | (value[4] << 16) | (value[5] << 24);
          siliconVersion = value[6] | (value[7] << 8);
          firmwareRevision = (value[8] << 8) | value[9];
          firmwareType = value[10];
          isFirmwareInfoReceived = true; // Mark as received to update UI
        });

        debugPrint("Firmware Information:");
        debugPrint("Command Status: $commandStatus");
        debugPrint("IC Family ID: $icFamilyId");
        debugPrint("Silicon Version: $siliconVersion");
        debugPrint("Firmware Revision: $firmwareRevision");
        debugPrint("Firmware Type: $firmwareType");
      } else {
        debugPrint("Invalid firmware information packet received.");
      }
    }

    setState(() async {});
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

  Future<void> _showDialog(BuildContext context, String title, String message) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text(
                "OK",
                style: TextStyle(color: Color.fromRGBO(45, 127, 224, 1)),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void rebootToEmCore() async {
    Uint8List Infoopcode = Uint8List.fromList([0x04, 0x01]);

    try {
      BleService selService = widget.selectedCharacteristic.service;
      BleCharacteristic selChar =
          widget.selectedCharacteristic.characteristic1;

      await UniversalBle.writeValue(
        widget.deviceId,
        selService.uuid,
        selChar.uuid,
        Infoopcode,
        BleOutputProperty.withResponse,
      );
      setState(() {
        response = Infoopcode;
      });

      debugPrint("Data written to the device: $Infoopcode");
      debugPrint("Firmware update Information sent successfully");
    } catch (e) {
      debugPrint("Get Firmwareupdate Failed: $e");
    }
  }

  void rebootToApplication() async {
    Uint8List Infoopcode = Uint8List.fromList([0x04, 0x02]);

    try {
      BleService selService = widget.selectedCharacteristic.service;
      BleCharacteristic selChar =
          widget.selectedCharacteristic.characteristic1;

      await UniversalBle.writeValue(
        widget.deviceId,
        selService.uuid,
        selChar.uuid,
        Infoopcode,
        BleOutputProperty.withResponse,
      );
      setState(() {
        response = Infoopcode;
      });

      debugPrint("Data written to the device: $Infoopcode");
      debugPrint("Firmware update Information sent successfully");
    } catch (e) {
      debugPrint("Get Firmwareupdate Failed: $e");
    }
  }

  void FirmwareUpdate_mode() async {
    Uint8List Infoopcode = Uint8List.fromList([0x04, 0x03]);

    try {
      BleService selService = widget.selectedCharacteristic.service;
      BleCharacteristic selChar = widget.selectedCharacteristic.characteristic1;

      await UniversalBle.writeValue(
        widget.deviceId,
        selService.uuid,
        selChar.uuid,
        Infoopcode,
        BleOutputProperty.withResponse,
      );
      setState(() {
        response = Infoopcode;
      });

      debugPrint("Data written to the device: $Infoopcode");
      debugPrint("Firmware update Information sent successfully");
    } catch (e) {
      debugPrint("Get Firmwareupdate Failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(247, 247, 244, 244),
      appBar: AppBar(
        title: Text(
          "Firmware Information",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Text("Device ID: ${widget.deviceId}"),
            Text("Device Name: ${widget.deviceName}"),
            Text(
                "Characteristic UUID: ${widget.selectedCharacteristic.characteristic1.uuid}"),
            isFirmwareInfoReceived
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Card for Product ID
                      Container(
                        padding: EdgeInsets.all(12),
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Family ID",
                              style: TextStyle(fontSize: 15),
                            ),
                            Spacer(),
                            Text(
                              icFamilyId == 1 ? "EM9305" : "Unknown",
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(12),
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Hardware Identification",
                              style: TextStyle(fontSize: 15),
                            ),
                            Spacer(),
                            Text(
                              "$siliconVersion",
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(12),
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Firmware Revision",
                              style: TextStyle(fontSize: 15),
                            ),
                            Spacer(),
                            Text(
                              "$firmwareRevision",
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(12),
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Firmware Type",
                              style: TextStyle(fontSize: 15),
                            ),
                            Spacer(),
                            Text(
                              // "$firmwareType",
                              getFirmwareTypeName(firmwareType),
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Text("Fetching firmware details...",
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8.0, bottom: 0),
              child: firmwareType == 0
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        backgroundColor: const Color.fromRGBO(45, 127, 224, 1),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FwuFirmwareUpdatePage(
                              deviceId: widget.deviceId,
                              deviceName: widget.deviceName,
                              selectedCharacteristic:
                                  widget.selectedCharacteristic,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Proceed with Firmware Update',
                        style: TextStyle(
                          color: Color.fromRGBO(250, 247, 243, 1),
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        backgroundColor: const Color.fromRGBO(45, 127, 224, 1),
                      ),
                      onPressed: () {
                        _showDialog(context, "Info",
                                "Rebooted to Firmware Update mode.\nPlease connect again to the device EMXX_FWU")
                            .then((_) {
                          FirmwareUpdate_mode();

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyHomePage()),
                            (Route<dynamic> route) => false,
                          );
                        });
                      },
                      child: const Text(
                        'Reboot to Firmware Updater',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
            ),
            SizedBox(height: 10),
            firmwareType != 1
                ? Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8.0, bottom: 0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        backgroundColor: const Color.fromRGBO(45, 127, 224, 1),
                      ),
                      onPressed: () {
                        setState(() {});
                        rebootToEmCore();
                        _showDialog(context, "Info",
                                "Rebooted to EM Core mode.\nPlease connect again to the device EMXX_FWU")
                            .then((_) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyHomePage()),
                            (Route<dynamic> route) => false,
                          );
                        });
                      },
                      child: const Text(
                        'Reboot to EM Core Mode',
                        style: TextStyle(
                          color: Color.fromRGBO(250, 247, 243, 1),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            SizedBox(height: 10),
            firmwareType != 3
                ? Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8.0, bottom: 0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        backgroundColor: const Color.fromRGBO(45, 127, 224, 1),
                      ),
                      onPressed: () {
                        setState(() {});
                        _showDialog(context, "Info",
                                "Rebooted to Application mode.\nPlease connect again to the device EMXX_FWU")
                            .then((_) {
                          rebootToApplication();

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyHomePage()),
                            (Route<dynamic> route) => false,
                          );
                        });
                      },
                      child: const Text(
                        'Reboot to Application Mode',
                        style: TextStyle(
                          color: Color.fromRGBO(250, 247, 243, 1),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

String getFirmwareTypeName(int firmwareType) {
  switch (firmwareType) {
    case 0:
      return "Firmware Updater";
    case 1:
      return "EM Core";
    case 3:
      return "Application";
    case 4:
      return "Custom Bootloader";
    default:
      return "Unknown";
  }
}
