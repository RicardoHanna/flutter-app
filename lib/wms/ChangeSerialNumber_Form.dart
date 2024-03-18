import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project/app_notifier.dart';
import 'package:http/http.dart' as http;

class ChangeSerialNumber extends StatefulWidget {
  final AppNotifier appNotifier;
  final String usercode;
  final int index;
  final List<Map<dynamic, dynamic>> items;
  final int itemQuantities;
  final Map<int, List<String>> serials;
  final Function(BuildContext, int, int, int, Map<int, List<String>>)
      changeQuantitySerial;
  const ChangeSerialNumber(
      {Key? key,
      required this.appNotifier,
      required this.usercode,
      required this.items,
      required this.index,
      required this.changeQuantitySerial, // Add this line
      required this.itemQuantities,
      required this.serials})
      : super(key: key);

  @override
  State<ChangeSerialNumber> createState() => _ChangeSerialNumberState();
}

class _ChangeSerialNumberState extends State<ChangeSerialNumber> {
  TextEditingController quantityController = TextEditingController();
  List<Map<dynamic, dynamic>> itemsorders = [];
  String apiurl = 'http://5.189.188.139:8080/api/';
  bool _isLoading = false;
  List<Map<dynamic, dynamic>> fetchedData = []; // Define fetchedData list
  List<String> serialNumbers = []; // Maintain a list of serial numbers
  List<TextEditingController> serialControllers =
      []; // Maintain controllers for each serial text field

  @override
  void initState() {
    super.initState();
    itemsorders = widget.items;
  }

  void updateSerialNumbers(
      BuildContext context, ValueChanged<bool> updateReturnBack) {
    // Check if any serial number is changed to empty
    if (widget.serials.containsKey(widget.index)) {
      for (int i = 0; i < widget.serials[widget.index]!.length; i++) {
        if (widget.serials[widget.index]![i].isEmpty) {
          updateReturnBack(false); // Update the returnBack variable
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please do not change a serial number to empty'),
            ),
          );
          return; // Stop the update process
        }
      }
    }

    // Check if any serial number is changed to a value that already exists in the same map
    for (int i = 0; i < widget.serials[widget.index]!.length; i++) {
      String currentSerial = widget.serials[widget.index]![i];
      for (int j = 0; j < widget.serials[widget.index]!.length; j++) {
        if (i != j && currentSerial == widget.serials[widget.index]![j]) {
          updateReturnBack(false); // Update the returnBack variable
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Please do not enter a serial number that already exists'),
            ),
          );
          return; // Stop the update process
        }
      }
    }

    // Update the serial numbers and quantity
    widget.changeQuantitySerial(
      context,
      widget.index,
      int.tryParse(quantityController.text) ?? 0,
      serialNumbers.length, // Pass the count of serial numbers
      widget.serials, // Pass the updated serials map
    );

    // Navigate back
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Change Serial',
          style: TextStyle(
            color: Colors.white,
            fontSize: widget.appNotifier.fontSize.toDouble(),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.qr_code_scanner,
              color: Colors.white,
            ),
          ),
        ],
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${itemsorders[widget.index]['itemCode']} ${itemsorders[widget.index]['itemName']}',
                style: TextStyle(
                    fontSize: widget.appNotifier.fontSize.toDouble() - 2),
              ),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.serials.containsKey(widget.index))
                    for (int i = 0;
                        i < widget.serials[widget.index]!.length;
                        i++)
                      // Inside the TextFormField builder:
// Inside the TextFormField builder:
                      TextFormField(
                        initialValue: widget.serials[widget.index]![i],
                        onChanged: (value) {
                          // Update the serial number in the serials map
                          setState(() {
                            widget.serials[widget.index]![i] = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Serial ${i + 1}',
                          labelStyle: TextStyle(
                              fontSize:
                                  widget.appNotifier.fontSize.toDouble() - 2),
                          suffixText: 'Units',
                          suffixIcon: IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Delete Serial'),
                                    content: Text(
                                        'Are you sure you want to delete this serial?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            // Remove the corresponding serial number from the list
                                            widget.serials[widget.index]!
                                                .removeAt(i);
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Text('Delete'),
                                        
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: Icon(Icons.delete),
                            color: Colors.red
                          ),
                        ),
                      ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [],
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    bool returnBack = true;
                    updateSerialNumbers(context, (newValue) {
                      returnBack = newValue;
                    });

                    if (returnBack) {
                      Navigator.pop(context);
                    }
                  });
                },
                child: Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
