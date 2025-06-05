// import 'package:flutter/material.dart';

// class Logs extends StatelessWidget {
//   // ... your code ...
//   @override
//   Widget build(BuildContext context) {
//     // Replace with your actual UI
//     return Scaffold(
//       appBar: AppBar(title: Text('Logs')),
//       body: Center(child: Text('Logs content here')),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Logs extends StatefulWidget {
  const Logs({super.key});

  @override
  State<Logs> createState() => _LogsState();
}

class _LogsState extends State<Logs> {
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogsFromFile();
  }

  Future<void> _loadLogsFromFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final logFile = File('${directory.path}/logs.txt');

    if (await logFile.exists()) {
      final contents = await logFile.readAsLines();
      setState(() {
        _logs.addAll(contents);
      });
    }
  }

  void _addLog(String type, dynamic data) async {
    DateTime now = DateTime.now();
    String timestamp =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    String logEntry = '[$timestamp] $type: ${data.toString()}';

    setState(() {
      _logs.add(logEntry);
    });

    await _writeLogToFile(logEntry);
  }

  Future<void> _writeLogToFile(String logEntry) async {
    final directory = await getApplicationDocumentsDirectory();
    final logFile = File('${directory.path}/logs.txt');
    await logFile.writeAsString('$logEntry\n', mode: FileMode.append);
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: const Text('Logs')),
  //     body: Column(
  //       children: [
  //         Expanded(
  //           child: _logs.isEmpty
  //               ? const Center(child: Text("No logs yet."))
  //               : ListView.builder(
  //                   padding: const EdgeInsets.all(8),
  //                   itemCount: _logs.length,
  //                   itemBuilder: (context, index) {
  //                     return Text(
  //                       _logs[index],
  //                       style: const TextStyle(fontSize: 14),
  //                     );
  //                   },
  //                 ),
  //         ),
  //         // Padding(
  //         //   padding: const EdgeInsets.all(8.0),
  //         //   child: ElevatedButton.icon(
  //         //     icon: const Icon(Icons.add),
  //         //     label: const Text("Add Test Log"),
  //         //     onPressed: () {
  //         //       _addLog("INFO", "Sample log data");
  //         //     },
  //         //   ),
  //         // ),
  //       ],
  //     ),
  //   );
  // }










// @override
// Widget build(BuildContext context) {
//   return GestureDetector(
//     onHorizontalDragEnd: (details) {
//       if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
//         // Right to left swipe → pop back
//         debugPrint("Right to left swipe detected");
//         if (Navigator.canPop(context)) {
//           Navigator.pop(context);
//         }
//       }
//     },
//     child: Scaffold(
//       appBar: AppBar(title: const Text('Logs')),
//       body: Column(
//         children: [
//           Expanded(
//             child: _logs.isEmpty
//                 ? const Center(child: Text("No logs yet."))
//                 : ListView.builder(
//                     padding: const EdgeInsets.all(8),
//                     itemCount: _logs.length,
//                     itemBuilder: (context, index) {
//                       return Text(
//                         _logs[index],
//                         style: const TextStyle(fontSize: 14),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     ),
//   );
// }



@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Logs')),
    body: GestureDetector(
      behavior: HitTestBehavior.opaque, // Detect swipe even on blank space
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx < -10) {
          // Swiping left fast
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Column(
        children: [
          Expanded(
            child: _logs.isEmpty
                ? const Center(child: Text("No logs yet."))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      return Text(
                        _logs[index],
                        style: const TextStyle(fontSize: 14),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
  );
}





}
