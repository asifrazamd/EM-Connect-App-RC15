import 'dart:async';
import 'package:flutter/material.dart';
import 'package:universal_ble_example/BleScanState.dart';
import 'package:universal_ble_example/dashboard.dart';
import 'package:provider/provider.dart';
import 'package:universal_ble_example/peripheral_details/widgets/char.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await BLECharacteristicHelper.loadCharacteristicsFromYaml(); // Load once

  runApp(
    ChangeNotifierProvider(
      create: (_) => BleScanState(), // Provide the BLE scan state
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        darkTheme: ThemeData.light(),
        themeMode: ThemeMode.system,
        home: const DashboardPage(),
      ),
    ),
  );
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: 1),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MyHomePage())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "em | connect",
                style: TextStyle(
                  color: Color.fromARGB(255, 50, 127, 168),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Image.asset(
                  'assets/splash.png',
                  width: 220,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
