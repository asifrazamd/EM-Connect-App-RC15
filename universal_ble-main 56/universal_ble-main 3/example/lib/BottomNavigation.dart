import 'package:flutter/material.dart';
import 'package:universal_ble_example/dashboard.dart';
import 'package:universal_ble_example/home/home.dart';

class BottomNavigationHandler extends StatefulWidget {
  final int initialIndex;
  const BottomNavigationHandler({super.key, this.initialIndex = 0});

  @override
  _BottomNavigationHandlerState createState() =>
      _BottomNavigationHandlerState();
}

class _BottomNavigationHandlerState extends State<BottomNavigationHandler> {
  late int _selectedIndex;

  final List<Widget> _widgetOptions = <Widget>[
    MyApp(),
    Beacontab(),
    Logtab(),
    Settingstab(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromARGB(255, 249, 247, 247),
        items: [
          BottomNavigationBarItem(
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [Icon(Icons.sensors), Text('Scan')],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [Icon(Icons.info_outline), Text('Info')],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [Icon(Icons.list), Text('Log')],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [Icon(Icons.settings_outlined), Text('About')],
            ),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromRGBO(45, 127, 224, 1),
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}
