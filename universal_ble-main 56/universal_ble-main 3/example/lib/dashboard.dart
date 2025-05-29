import 'dart:io';
import 'package:flutter/material.dart';
import 'package:universal_ble_example/BottomNavigation.dart';
import 'package:url_launcher/url_launcher.dart'
    show LaunchMode, canLaunch, canLaunchUrl, launch, launchUrl;
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BottomNavigationHandler(initialIndex: 0);
  }
}

class Beacontab extends StatelessWidget {
  const Beacontab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(247, 247, 244, 244),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Info',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(184, 252, 250, 250),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Existing Beacon tab content
              _buildSmallHeading('Beacon Details'),
              Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 10),
                  _buildHeading('DOCUMENT'),
                ],
              ),
              SizedBox(height: 10),
              _buildCard3('Factsheet (coming soon)', ''),
              _buildCard3('Datasheet (coming soon)', ''),
              _buildCard3('Flyer (coming soon)', ''),
              SizedBox(height: 40),
              Row(
                children: [
                  Icon(
                    Icons.videocam_outlined,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 10),
                  _buildHeading('VIDEO'),
                ],
              ),
              SizedBox(height: 10),
              _buildCard3('Starter Kit Presentation (coming soon)', ''),
              _buildCard3('Starter Kit Tutorial (coming soon)', ''),
              SizedBox(height: 40),
              Row(
                children: [
                  Icon(
                    Icons.language_outlined,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 10),
                  _buildHeading('RESOURCE'),
                ],
              ),
              SizedBox(height: 10),
              _buildCard('em Beacons', 'https://sclabsglobal.com/EmBeacons'),
              _buildCard('em Developer Forum',
                  'https://sclabsglobal.com/EmBeaconDeveloperForum'),

              SizedBox(height: 40),
              Row(
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 10),
                  _buildHeading('PURCHASE'),
                ],
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.zero,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8), // Adjust the radius as needed
                  ),
                  color: Color.fromARGB(255, 103, 173, 255),
                  margin: EdgeInsets.all(1),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8), // Add padding for inner content
                    constraints: BoxConstraints(
                      minHeight: 35, // Minimum height to maintain layout
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 20),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Text(
                              'Order em Beacons (coming soon)',
                              style: TextStyle(
                                overflow: TextOverflow
                                    .ellipsis, // Handle long text gracefully
                                color: Color.fromARGB(247, 247, 244, 244),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                          ),
                          onPressed: () async {
                            final Uri url = Uri.parse('');
                            _launchURL(url);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
              _buildSmallHeading('em | bleu Details'),

              // Em|bleu tab content
              Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 10),
                  _buildHeading('DOCUMENT (em | bleu)'),
                ],
              ),
              SizedBox(height: 10),
              _buildCard(
                  'Factsheet', 'https://sclabsglobal.com/EmBleuFactsheet'),
              _buildCard3('Datasheet',
                  'https://www.emmicroelectronic.com/sites/default/files/products/datasheets/9305-DS%201.pdf'),
              _buildCard3('Flyer (coming soon)', ''),
              SizedBox(height: 40),
              Row(
                children: [
                  Icon(
                    Icons.videocam_outlined,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 10),
                  _buildHeading('VIDEO (em | bleu)'),
                ],
              ),
              SizedBox(height: 10),
              _buildCard3('Starter Kit Presentation (coming soon)', ''),
              _buildCard3('Starter Kit Tutorial (coming soon)', ''),
              SizedBox(height: 40),
              Row(
                children: [
                  Icon(
                    Icons.language_outlined,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 10),
                  _buildHeading('RESOURCE (em | bleu)'),
                ],
              ),
              SizedBox(height: 10),
              _buildCard('em | bleu website',
                  'https://sclabsglobal.com/EmBleuWebsite'),
              _buildCard('em Developer Forum',
                  'https://sclabsglobal.com/EmBleuDeveloperForum'),
              SizedBox(height: 40),
              Row(
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 10),
                  _buildHeading('PURCHASE (em | bleu)'),
                ],
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.zero,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8), // Adjust the radius as needed
                  ),
                  color: Color.fromRGBO(45, 127, 224, 1),
                  margin: EdgeInsets.all(1),
                  child: SizedBox(
                    width: 500, // Set your desired width
                    height: 40, // Set your desired height
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 20),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Text(
                              'Order em | bleu',
                              style: TextStyle(
                                color: Colors
                                    .white, // Change this to your desired color
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            final Uri url = Uri.parse(
                                'https://sclabsglobal.com/OrderEmBleu');
                            _launchURL(url);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard3(String name, String link) {
    return Padding(
      padding: EdgeInsets.zero,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Adjust the radius as needed
        ),
        color: Colors.white,
        margin: EdgeInsets.all(1),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: 8), // Add padding for inner content
          constraints: BoxConstraints(
            minHeight: 35, // Minimum height to maintain layout
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  softWrap: true,
                  overflow:
                      TextOverflow.ellipsis, // Handle long text gracefully
                  style: TextStyle(
                    color: Colors.grey, // Set text color to grey
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right),
                color: Colors.grey,
                onPressed: () async {
                  final Uri url = Uri.parse(link);
                  _launchURL(url);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallHeading(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 4), // Small spacing between text and underline
      ],
    );
  }

  Widget _buildHeading(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 15, color: Colors.grey),
    );
  }

  Widget _buildCard(String name, String link) {
    return Padding(
      padding: EdgeInsets.zero,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Adjust the radius as needed
        ),
        color: Colors.white,
        margin: EdgeInsets.all(1),
        child: SizedBox(
          width: 500,
          height: 35,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 20),
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: InkWell(
                      child: Text(name),
                    )),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed: () async {
                  final Uri url = Uri.parse(link);
                  _launchURL(url);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(Uri url) async {
    if (true) {
      await launchUrl(url);
    }
  }
}

class Logtab extends StatefulWidget {
  const Logtab({super.key});

  @override
  _LogtabState createState() => _LogtabState();
}

class _LogtabState extends State<Logtab> with WidgetsBindingObserver {
  List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLogs(); // Load logs after checking
  }

  // Handling lifecycle state changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      _deleteLogFile(); // Delete the log file when the app is paused or detached
    }
  }

  // Load logs for display in UI
  Future<void> _loadLogs() async {
    List<String> logs = await _readLastConnectionLogs();
    setState(() {
      _logs = logs;
    });
  }

  // Read the last connection logs only from file
  Future<List<String>> _readLastConnectionLogs() async {
    final directory = await getApplicationDocumentsDirectory();
    final logFile = File('${directory.path}/logs.txt');

    if (await logFile.exists()) {
      String contents = await logFile.readAsString();
      List<String> connections = contents.split('--Connection Start--');
      if (connections.isNotEmpty) {
        return connections.last
            .split('\n')
            .where((line) => line.isNotEmpty)
            .toList();
      }
    }
    return [];
  }

  // Delete the log file
  Future<void> _deleteLogFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final logFile = File('${directory.path}/logs.txt');
    if (await logFile.exists()) {
      await logFile.delete();
      print("Log file deleted"); // Print confirmation for debugging
    } else {
      print("Log file not found"); // If file does not exist
    }
  }

  // Clear the logs in the UI and the log file
  Future<void> _clearLogs() async {
    setState(() {
      _logs.clear(); // Clear the logs in the UI
    });

    // Also delete the log file
    final directory = await getApplicationDocumentsDirectory();
    final logFile = File('${directory.path}/logs.txt');
    if (await logFile.exists()) {
      await logFile.delete(); // Delete the file
      print("Log file deleted");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(248, 247, 245, 1),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text("Logs",
            style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold)),
        backgroundColor: Color.fromRGBO(248, 247, 245, 1),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () {
              _clearLogs(); // Trigger the clear functionality
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _logs.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              _logs[index],
              style: TextStyle(
                fontSize: 13.0, // Set the font size here
                color: Colors.black, // Optional: Adjust the color
              ),
            ),
          );
        },
      ),
    );
  }
}

void _showDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class Settingstab extends StatelessWidget {
  const Settingstab({super.key});

  Future<Map<String, String>> _getAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return {
      'version': packageInfo.version, // Get the version number
      'buildNumber': packageInfo.buildNumber, // Get the build number
    };
  }

  Future<void> _launchURL(Uri url) async {
    if (true) {
      await launchUrl(url);
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(247, 247, 244, 244),
      appBar: AppBar(
        title: Text(
          'About',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(184, 252, 250, 250),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 10),
                  _buildHeading('ABOUT THIS APP'),
                ],
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.zero,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8), // Adjust the radius as needed
                  ),
                  color: Colors.white,
                  margin: EdgeInsets.all(1),
                  child: SizedBox(
                    width: 500, // Set your desired width
                    height: 35, // Set your desired height
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Row(
                                children: [
                                  SizedBox(width: 20),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: Text('Application Version'),
                                    ),
                                  ),
                                  FutureBuilder<Map<String, String>>(
                                    future: _getAppInfo(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        return Text('Error');
                                      } else {
                                        final version =
                                            snapshot.data?['version'] ?? 'N/A';
                                        final buildNumber =
                                            snapshot.data?['buildNumber'] ??
                                                'N/A';
                                        // return Text('$version (Build: $buildNumber)');
                                        return Text('$version($buildNumber)');
                                      }
                                    },
                                  ),
                                  SizedBox(width: 20),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildCard1('Feedback & Report Issue', ''),
              _buildCard1('Acknowledgements', ''),
              _buildCard2(
                  'Privacy Policy', 'https://sclabsglobal.com/PrivacyPolicy'),
              SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(width: 10),
                  _buildHeading('WHO ARE WE'),
                ],
              ),
              SizedBox(height: 10),
              _buildCard2('About Us', 'https://sclabsglobal.com/AboutUs'),
              _buildCard3('Services and Capabilities', ''),
              _buildCard3('Project Inquiry', ''),
              SizedBox(height: 10),
              Center(
                child: Text(
                  'Copyright © 2025 EM Microelectronic - Marin SA',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              SizedBox(height: 40),
              Center(
                child: Text(
                  "em | connect",
                  style: TextStyle(
                      color: Color.fromARGB(255, 50, 127, 168),
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
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
      ),
    );
  }

  Widget _buildHeading(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 15, color: Colors.grey),
    );
  }

  Widget _buildCard1(String name, String link) {
    return Padding(
      padding: EdgeInsets.zero,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Adjust the radius as needed
        ),
        color: Colors.white,
        margin: EdgeInsets.all(1),
        child: SizedBox(
          width: 500, // Set desired width
          height: 35, // Set desired height
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Text(
                    name,
                    style: TextStyle(
                      color: Colors.grey, // Set text color to grey
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right),
                color: Colors.grey,
                onPressed: () async {
                  final Uri url = Uri.parse(link);
                  _launchURL(url);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard2(String name, String link) {
    return Padding(
      padding: EdgeInsets.zero,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Adjust the radius as needed
        ),
        color: Colors.white,
        margin: EdgeInsets.all(1),
        child: SizedBox(
          width: 500,
          height: 35,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Text(
                    name,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed: () async {
                  final Uri url = Uri.parse(link);
                  _launchURL(url);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard3(String name, String link) {
    return Padding(
      padding: EdgeInsets.zero,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Adjust the radius as needed
        ),
        color: Colors.white,
        margin: EdgeInsets.all(1),
        child: SizedBox(
          width: 500, // Set your desired width
          height: 35, // Set your desired height
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Text(
                    name,
                    style: TextStyle(
                      color: Colors.grey, // Set text color to grey
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right),
                color: Colors.grey,
                onPressed: () async {
                  final Uri url = Uri.parse(link);
                  _launchURL(url);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
