// // return SingleChildScrollView(
// //       child: Column(
// //         children: [
// //           ListView.builder(
// //             shrinkWrap: true,
// //             physics: const NeverScrollableScrollPhysics(),
// //             itemCount: widget.discoveredServices.length,
// //             itemBuilder: (BuildContext context, int index) {
// //               final service = widget.discoveredServices[index];
// //               return Padding(
// //                 padding: const EdgeInsets.all(8.0),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Row(
// //                       children: [
// //                         Text(
// //                           _getServiceName(
// //                             service.uuid,
// //                             // widget.discoveredServices[index].uuid),
// //                           ),
// //                           style: TextStyle(
// //                             fontSize: 14,
// //                             color: Colors.grey,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                     Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Card(
// //                           color: Colors.white,
// //                           elevation: 4,
// //                           margin: EdgeInsets.all(1),
// //                           shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.vertical(
// //                                   top: Radius.circular(6))),
// //                           child: ListTile(
// //                             title: Text(
// //                               'UUID: ${_formatUUID(service.uuid)}',
// //                               style: TextStyle(fontSize: 12),
// //                             ),
// //                             subtitle: Text("PRIMARY SERVICE",
// //                                 style: TextStyle(
// //                                     fontSize: 12, color: Colors.grey)),
// //                             trailing: Icon(
// //                               _expandedStates[index]
// //                                   ? Icons.expand_less
// //                                   : Icons.expand_more,
// //                               color: Colors.grey,
// //                             ),
// //                             onTap: () {
// //                               setState(() {
// //                                 _expandedStates[index] =
// //                                     !_expandedStates[index];
// //                               });
// //                             },
// //                           ),
// //                         ),
// //                         if (_expandedStates[index])
// //                           Column(
// //                             children: service.characteristics
// //                                 .map((e) => SizedBox(
// //                                       width: double.infinity,
// //                                       child: Card(
// //                                         color: Colors.white,
// //                                         elevation: 4,
// //                                         margin: EdgeInsets.all(0.5),
// //                                         shape: RoundedRectangleBorder(
// //                                             borderRadius: BorderRadius.zero),
// //                                         child: Padding(
// //                                           padding: const EdgeInsets.all(8.0),
// //                                           child: Column(
// //                                             crossAxisAlignment:
// //                                                 CrossAxisAlignment.start,
// //                                             children: [
// //                                               InkWell(
// //                                                 child: Column(
// //                                                   children: [
// //                                                     Row(
// //                                                       mainAxisAlignment:
// //                                                           MainAxisAlignment
// //                                                               .spaceBetween,
// //                                                       children: [
// //                                                         Flexible(
// //                                                           child: Column(
// //                                                             crossAxisAlignment:
// //                                                                 CrossAxisAlignment
// //                                                                     .start,
// //                                                             children: [
// //                                                               Text(
// //                                                                 BLECharacteristicHelper.getCharacteristicName(e.uuid.substring(0, 8)),

// //                                                                 // _getCharacteristicName(e
// //                                                                 //     .uuid
// //                                                                 //     .substring(
// //                                                                 //         0, 8)),
// //                                                                 style: TextStyle(
// //                                                                     fontSize:
// //                                                                         12,
// //                                                                     fontWeight:
// //                                                                         FontWeight
// //                                                                             .w500),
// //                                                                 softWrap: true,
// //                                                               ),
// //                                                               SizedBox(
// //                                                                   height: 4),

// //                                                               Text(
// //                                                                 'UUID: 0x${e.uuid.substring(0, 8).replaceFirst(RegExp(r'^0+'), '').toUpperCase()}',
// //                                                                 style: TextStyle(
// //                                                                     fontSize:
// //                                                                         12),
// //                                                                 softWrap: true,
// //                                                               ),

// //                                                               //SizedBox(height: 4),
// //                                                               Text(
// //                                                                 'Properties: ${e.properties.join(', ').toUpperCase()}',
// //                                                                 style:
// //                                                                     TextStyle(
// //                                                                   fontSize: 12,
// //                                                                 ),
// //                                                                 softWrap: true,
// //                                                               ),
// //                                                               if (e.properties.contains(
// //                                                                   CharacteristicProperty
// //                                                                       .indicate)) ...[
// //                                                                 const SizedBox(
// //                                                                     height: 4),
// //                                                                 const Text(
// //                                                                   'Descriptors:',
// //                                                                   style: TextStyle(
// //                                                                       fontSize:
// //                                                                           12,
// //                                                                       fontWeight:
// //                                                                           FontWeight
// //                                                                               .w500),
// //                                                                 ),
// //                                                                 const SizedBox(
// //                                                                     height: 4),
// //                                                                 const Text(
// //                                                                   'Client Characteristic Configuration',
// //                                                                   style: TextStyle(
// //                                                                       fontSize:
// //                                                                           12,
// //                                                                       fontStyle:
// //                                                                           FontStyle
// //                                                                               .italic,
// //                                                                       color: Colors
// //                                                                           .grey),
// //                                                                 ),
// //                                                               ],

// //                                                               //SizedBox(height: 4),
// //                                                               _showValueForCharacteristic[e
// //                                                                           .uuid] ==
// //                                                                       true
// //                                                                   ? Text(
// //                                                                       'value: ${_characteristicValues[e.uuid]}',
// //                                                                       style: TextStyle(
// //                                                                           fontSize:
// //                                                                               12),
// //                                                                       softWrap:
// //                                                                           true,
// //                                                                       overflow:
// //                                                                           TextOverflow
// //                                                                               .visible,
// //                                                                       maxLines:
// //                                                                           null,
// //                                                                     )
// //                                                                   : SizedBox
// //                                                                       .shrink(),
// //                                                             ],
// //                                                           ),
// //                                                         ),
// //                                                         Row(
// //                                                           children: e.properties
// //                                                               .map((prop) {
// //                                                             String type = prop
// //                                                                 .name
// //                                                                 .toLowerCase();

// //                                                           }).toList(),
// //                                                         )
// //                                                       ],
// //                                                     ),
// //                                                   ],
// //                                                 ),
// //                                               ),
// //                                             ],
// //                                           ),
// //                                         ),
// //                                       ),
// //                                     ))
// //                                 .toList(),
// //                           ),
// //                       ],
// //                     )
// //                   ],
// //                 ),
// //               );
// //             },
// //           ),
// //         ],
// //       ),
// //     );
  
  
  


//     @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     body: GestureDetector(
//       behavior: HitTestBehavior.translucent,
//       onHorizontalDragEnd: (details) {
//         if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => Logs()),
//           );
//         }
//       },
//       child: ListView.builder(
//         itemCount: widget.discoveredServices.length,
//         itemBuilder: (BuildContext context, int index) {
//           final service = widget.discoveredServices[index];
//           return Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   _getServiceName(service.uuid),
//                   style: const TextStyle(fontSize: 14, color: Colors.grey),
//                 ),
//                 Card(
//                   color: Colors.white,
//                   elevation: 4,
//                   margin: const EdgeInsets.all(1),
//                   shape: const RoundedRectangleBorder(
//                     borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
//                   ),
//                   child: ListTile(
//                     title: Text(
//                       'UUID: ${_formatUUID(service.uuid)}',
//                       style: const TextStyle(fontSize: 12),
//                     ),
//                     subtitle: const Text(
//                       "PRIMARY SERVICE",
//                       style: TextStyle(fontSize: 12, color: Colors.grey),
//                     ),
//                     trailing: Icon(
//                       _expandedStates[index]
//                           ? Icons.expand_less
//                           : Icons.expand_more,
//                       color: Colors.grey,
//                     ),
//                     onTap: () {
//                       setState(() {
//                         _expandedStates[index] = !_expandedStates[index];
//                       });
//                     },
//                   ),
//                 ),
//                 if (_expandedStates[index])
//                   Column(
//                     children: service.characteristics.map((e) {
//                       final showValue = _showValueForCharacteristic[e.uuid] ?? false;
//                       return Card(
//                         color: Colors.white,
//                         elevation: 4,
//                         margin: const EdgeInsets.all(0.5),
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Flexible(
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           BLECharacteristicHelper.getCharacteristicName(
//                                             e.uuid.substring(0, 8),
//                                           ),
//                                           style: const TextStyle(
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                           softWrap: true,
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Text(
//                                           'UUID: 0x${e.uuid.substring(0, 8).replaceFirst(RegExp(r'^0+'), '').toUpperCase()}',
//                                           style: const TextStyle(fontSize: 12),
//                                           softWrap: true,
//                                         ),
//                                         Text(
//                                           'Properties: ${e.properties.join(', ').toUpperCase()}',
//                                           style: const TextStyle(fontSize: 12),
//                                           softWrap: true,
//                                         ),
//                                         if (e.properties.contains(CharacteristicProperty.indicate)) ...[
//                                           const SizedBox(height: 4),
//                                           const Text(
//                                             'Descriptors:',
//                                             style: TextStyle(
//                                               fontSize: 12,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ),
//                                           const SizedBox(height: 4),
//                                           const Text(
//                                             'Client Characteristic Configuration',
//                                             style: TextStyle(
//                                               fontSize: 12,
//                                               fontStyle: FontStyle.italic,
//                                               color: Colors.grey,
//                                             ),
//                                           ),
//                                         ],
//                                         if (showValue)
//                                           Text(
//                                             'value: ${_characteristicValues[e.uuid] ?? ""}',
//                                             style: const TextStyle(fontSize: 12),
//                                             softWrap: true,
//                                             overflow: TextOverflow.visible,
//                                             maxLines: null,
//                                           ),
//                                       ],
//                                     ),
//                                   ),
//                                   Row(
//                                     children: e.properties.map((prop) {
//                                       String type = prop.name.toLowerCase();
//                                       return const SizedBox.shrink(); // Placeholder
//                                     }).toList(),
//                                   )
//                                 ],
//                               )
//                             ],
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//               ],
//             ),
//           );
//         },
//       ),
//     ),
//   );
// }

  