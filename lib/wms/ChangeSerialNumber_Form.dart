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
    final Map<int,String>updatedUOM;
    final Map<int,String>updatedWarehouses;
  final Function(BuildContext, int, int, int, Map<int, List<String>>,String,String)
      changeQuantitySerial;
  const ChangeSerialNumber(
      {Key? key,
      required this.appNotifier,
      required this.usercode,
      required this.items,
      required this.index,
      required this.changeQuantitySerial, // Add this line
      required this.itemQuantities,
      required this.serials,
      required this.updatedWarehouses,
      required this.updatedUOM,
      })
      : super(key: key);

  @override
  State<ChangeSerialNumber> createState() => _ChangeSerialNumberState();
}

class _ChangeSerialNumberState extends State<ChangeSerialNumber> {
  TextEditingController quantityController = TextEditingController();
  List<Map<dynamic, dynamic>> itemsorders = [];
  String apiurl = 'http://5.189.188.139:8080/api/';
  bool _isLoading = false;
  String dropdownValueUOM='';
String dropdownValue='';
  List<Map<dynamic, dynamic>> fetchedData = []; // Define fetchedData list
  List<String> serialNumbers = []; // Maintain a list of serial numbers
  List<TextEditingController> serialControllers =
      []; // Maintain controllers for each serial text field
    List<Map<dynamic, dynamic>> fetchedDataUOM = []; // Define fetchedData list
  @override
  void initState() {
    super.initState();
    itemsorders = widget.items;
     fetchWarehouses().then((_) {
      setState(() {
        print('Fetched Data: $fetchedData');
        dropdownValue = fetchedData.isNotEmpty
            ? fetchedData.first['ANY_VALUE(u.whsCode)'].toString()
            : ''; // Set default value to an empty string if fetched data is empty
        print('Dropdown Value: $dropdownValue');
      });
    });
    fetchUOM().then((_) {
      setState(() {
        print('Fetched uom Data: $fetchedDataUOM');
        dropdownValueUOM = fetchedDataUOM.isNotEmpty
            ? fetchedDataUOM.first['ANY_VALUE(i.uom)'].toString()
            : ''; // Set default value to an empty string if fetched data is empty
        print('Dropdown uom Value: $dropdownValueUOM');
      });
    }); 
  }

   Future<void> fetchWarehouses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> requestBody = {'userCode': widget.usercode};

      // Make a POST request with the request body
      final response = await http.post(
        Uri.parse('${apiurl}getWarehousesUsers'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          // Update state with the fetched data
          fetchedData = List<Map<dynamic, dynamic>>.from(data.map((item) {
            // Convert each item in the response to a map
            return Map<dynamic, dynamic>.from(item);
          }));
          _isLoading = false;
        });
        print(fetchedData);
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchUOM() async {
  setState(() {
    _isLoading = true;
  });

  try {
    Map<String, dynamic> requestBody = {
      'itemCode': itemsorders[widget.index]['itemCode']
    };

    // Make a POST request with the request body
    final response = await http.post(
      Uri.parse('${apiurl}getItemUOMReceiving'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody), // Encode the request body as JSON
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        // Update state with the fetched data
        fetchedDataUOM = List<Map<dynamic, dynamic>>.from(data.map((item) {
          // Convert each item in the response to a map
          return Map<dynamic, dynamic>.from(item);
        }));
        _isLoading = false;
      });
      print(fetchedDataUOM);
    } else {
      throw Exception('Failed to fetch data uom');
    }
  } catch (error) {
    print('Error fetching data uom: $error');
    setState(() {
      _isLoading = false;
    });
  }
}

  void updateSerialNumbers(
    BuildContext context,
    ValueChanged<bool> updateReturnBack,
  ) {
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
                'Please do not enter a serial number that already exists',
              ),
            ),
          );
          return; // Stop the update process
        }
      }
    }

    // Calculate the updated quantity after deleting serial number(s)
    int updatedQuantity = widget.serials[widget.index]!.length;
    quantityController.text = updatedQuantity.toString();

    // Update the serial numbers and quantity
    widget.changeQuantitySerial(
      context,
      widget.index,
      int.tryParse(quantityController.text) ?? 0,
      widget.serials[widget.index]!.length, // Pass the updated serials count
      widget.serials,dropdownValue,dropdownValueUOM // Pass the updated serials map
    );
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
         Text(
                    'Warehouse',
                    style: TextStyle(
                        fontSize: widget.appNotifier.fontSize.toDouble() - 2,
                        color: Colors.black54),
                  ),
                  DropdownButton<String>(
                    value: widget.updatedWarehouses[widget.index] ?? dropdownValue ?? '',
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                              widget.updatedWarehouses[widget.index] = newValue ?? '';

                      });
                    },
                    items: fetchedData.map<DropdownMenuItem<String>>(
                        (Map<dynamic, dynamic> warehouse) {
                      return DropdownMenuItem<String>(
                        value: warehouse['ANY_VALUE(u.whsCode)'].toString(),
                        child:
                            Text(warehouse['ANY_VALUE(w.whsName)'].toString()),
                      );
                    }).toList(),
                  ),
                  Text(
                  'UOM',
                  style: TextStyle(
                      fontSize: widget.appNotifier.fontSize.toDouble() - 2,
                      color: Colors.black54),
                ),
                
              DropdownButton<String>(
  value: widget.updatedUOM[widget.index] ?? dropdownValueUOM ?? '',
  onChanged: (String? newValue) {
    setState(() {
      dropdownValueUOM = newValue ?? '';
      // Update widget.updatedUOM if needed
      widget.updatedUOM[widget.index] = newValue ?? '';
    });
  },
  items: fetchedDataUOM.map<DropdownMenuItem<String>>(
    (Map<dynamic, dynamic> uom) {
      return DropdownMenuItem<String>(
        value: uom['ANY_VALUE(i.uom)'].toString(),
        child: Text(uom['ANY_VALUE(i.uom)'].toString()),
      );
    },
  ).toList(),
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
                                              int updatedQuantity = widget
                                                  .serials[widget.index]!
                                                  .length;
                                              quantityController.text =
                                                  updatedQuantity.toString();
                                              print(quantityController.text);
                                              if (quantityController.text ==
                                                  '1') {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'At least should be 1 serial',
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }
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
                              color: Colors.red),
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
