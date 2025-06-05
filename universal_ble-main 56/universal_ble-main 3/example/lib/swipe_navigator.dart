import 'package:flutter/material.dart';
import 'package:universal_ble_example/peripheral_details/widgets/services_list_widget.dart';
import 'package:universal_ble_example/logs.dart';

class SwipeNavigator extends StatefulWidget {
  const SwipeNavigator({super.key});

  @override
  State<SwipeNavigator> createState() => _SwipeNavigatorState();
}

class _SwipeNavigatorState extends State<SwipeNavigator> {
  final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      scrollDirection: Axis.horizontal,
      children: const [
        ServicesListWidget(
          deviceId: '', // TODO: Provide the actual deviceId
          deviceName: '', // TODO: Provide the actual deviceName
          discoveredServices: [], // TODO: Provide the actual list of discovered services
        ), // <-- Your main BLE services screen
        Logs(),     // <-- Logs screen
      ],
    );
  }
}
