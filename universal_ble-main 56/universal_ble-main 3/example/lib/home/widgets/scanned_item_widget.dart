import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:universal_ble/universal_ble.dart';

final Map<String, Color> deviceColors = {};

Color getColorForDevice(String deviceId) {
  // Check if the device already has an assigned color
  if (deviceColors.containsKey(deviceId)) {
    return deviceColors[deviceId]!;
  }

  // If not, generate a new random color and store it
  final Random random = Random();
  Color newColor = Color.fromARGB(
    255, // Fully opaque
    random.nextInt(256), // Random red value
    random.nextInt(256), // Random green value
    random.nextInt(256), // Random blue value
  );

  deviceColors[deviceId] = newColor; // Store the color for future use
  return newColor;
}

class ScannedItemWidget extends StatelessWidget {
  final BleDevice bleDevice;
  final VoidCallback? onTap;
  const ScannedItemWidget({super.key, required this.bleDevice, this.onTap});

  @override
  Widget build(BuildContext context) {
    String? name = bleDevice.name;
    List<ManufacturerData> rawManufacturerData = bleDevice.manufacturerDataList;
    ManufacturerData? manufacturerData;
    String? deviceId = bleDevice.deviceId;
    debugPrint(bleDevice.deviceId);
    if (rawManufacturerData.isNotEmpty) {
      manufacturerData = rawManufacturerData.first;
    }

    String? identifyBeacon(ManufacturerData? manufacturerData) {
      return null;
    }

    // Identify the beacon type
    String? beaconType = identifyBeacon(manufacturerData);
    String beaconId = '';

    // If manufacturer data is available, extract the beacon ID
    if (manufacturerData != null) {
      // Convert the manufacturer ID to a string for display
      beaconId =
          'ID: 0x${manufacturerData.companyId.toRadixString(16).padLeft(4, '0').toUpperCase()}';
    }

    // If no name or name is empty, set it to 'NA'
    if (name == null || name.isEmpty) name = 'NA';

    // Append the specific beacon type if detected
    if (beaconType != null) {
      name = '$name ($beaconType)';
    }
    //if (name == null || name.isEmpty) name = 'N/A';
    return Padding(
      padding:
          const EdgeInsetsDirectional.only(start: 0, end: 0, top: 0, bottom: 0),
      child: Column(
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(10),
                  alignment: Alignment.center,
                  backgroundColor: (beaconType == null)
                      ? Color.fromARGB(255, 19, 237, 34)
                      : const Color.fromARGB(255, 248, 203, 3),
                  foregroundColor: Colors.black,
                ),
                child: (beaconType == null)
                    ? Icon(
                        Icons.bluetooth,
                        size: 30,
                      )
                    : (Icon(
                        Icons.rss_feed,
                        size: 30,
                      )),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Align items in the row
                      children: [
                        Container(
                          constraints: BoxConstraints.tightFor(width: 150),
                          child: Text(
                            name,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: SizedBox(
                            height: 28,
                            child: ElevatedButton(
                              onPressed: onTap,
                              style: ElevatedButton.styleFrom(
                                foregroundColor:
                                    Color.fromRGBO(250, 247, 243, 1),
                                backgroundColor:
                                    Color.fromRGBO(45, 127, 224, 1),
                                elevation: 4.0,
                                shadowColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              child: Text('Connect'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (Platform.isAndroid)
                      Text(
                        'Mac Address: $deviceId',
                        style: TextStyle(fontSize: 12),
                      ),
                    buildSignalAndInterval(
                        bleDevice.rssi, bleDevice.adv_interval),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSignalAndInterval(int? rssi, int? advInterval) {
    return Row(
      children: [
        getSignalIcon(rssi),
        Text(
          ' $rssi',
          style: TextStyle(fontSize: 12),
        ),
        Padding(padding: EdgeInsets.fromLTRB(30, 0, 0, 0)),
        Transform.rotate(
          angle: 45 * 3.14 / 180,
          child: Icon(
            Icons.open_in_full,
            color: Colors.grey,
            size: 18,
          ),
        ),
        Text(
          ' $advInterval ms',
          style: TextStyle(fontSize: 12),
        )
      ],
    );
  }

  Icon getSignalIcon(int? rssi) {
    double towerSize = 15.0;
    if (rssi! >= -60) {
      return Icon(
        Icons.signal_cellular_4_bar,
        color: const Color.fromARGB(255, 82, 137, 83),
        size: towerSize,
      ); // Excellent
    } else if (rssi >= -90) {
      return Icon(
        Icons.network_cell,
        color: const Color.fromARGB(
          255,
          212,
          202,
          110,
        ),
        size: towerSize,
      ); // Good
    } else {
      return Icon(
        Icons.signal_cellular_null,
        color: const Color.fromARGB(255, 235, 111, 103),
        size: towerSize,
      ); // Poor
    }
  }
}
