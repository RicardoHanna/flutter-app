import 'dart:convert';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project/app_notifier.dart';
import 'package:http/http.dart' as http;

class AddSerialNumber extends StatefulWidget {
  final AppNotifier appNotifier;
  final String usercode;
  final int index;
  final List<Map<dynamic, dynamic>> items;
  final int itemQuantities;
  final Map<int,List<String>>serials;
  final Function(BuildContext, int, int, String, int, Map<int,List<String>>)
      addQuantitySerial;
  const AddSerialNumber({
    Key? key,
    required this.appNotifier,
    required this.usercode,
    required this.items,
    required this.index,
    required this.addQuantitySerial, // Add this line
    required this.itemQuantities,
    required this.serials
  }) : super(key: key);

  @override
  State<AddSerialNumber> createState() => _AddSerialNumberState();
}

class _AddSerialNumberState extends State<AddSerialNumber> {
  TextEditingController quantityController = TextEditingController();
  String dropdownValue = 'Units';
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
    fetchWarehouses().then((_) {
      setState(() {
        print('Fetched Data: $fetchedData');
        dropdownValue = fetchedData.isNotEmpty
            ? fetchedData.first['ANY_VALUE(u.whsCode)'].toString()
            : ''; // Set default value to an empty string if fetched data is empty
        print('Dropdown Value: $dropdownValue');
      });
    });
  }

Future<void> scanBarcode() async {
  try {
    ScanResult result = await BarcodeScanner.scan();
    String barcode = result.rawContent.replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '');
    print(barcode);

    // Split the scanned content by the delimiter (e.g., comma or newline)
    List<String> serials = barcode.split('\n');

    for (String serial in serials) {
      if (serialNumbers.contains(serial)) {
        // If the serial number has already been scanned, show a SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('This serial has already been scanned: $serial')),
        );
      } else {
        // If the serial number hasn't been scanned yet, add it to the list
        setState(() {
          serialNumbers.add(serial);
          serialControllers.add(TextEditingController(text: serial));
        });
      }
    }
  } on PlatformException catch (e) {
    if (e.code == BarcodeScanner.cameraAccessDenied) {
      print('Camera permission denied');
    } else {
      print('Error: $e');
    }
  }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Serial',
          style: TextStyle(
            color: Colors.white,
            fontSize: widget.appNotifier.fontSize.toDouble(),
          ),
        ),
        actions: [
          IconButton(
  onPressed: () async {
    await scanBarcode();
  },
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
                  Text(
                    'Warehouse',
                    style: TextStyle(
                        fontSize: widget.appNotifier.fontSize.toDouble() - 2,
                        color: Colors.black54),
                  ),
                  DropdownButton<String>(
                    value: dropdownValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
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
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Serial',
                        labelStyle: TextStyle(
                            fontSize:
                                widget.appNotifier.fontSize.toDouble() - 2),
                        suffixText: 'Units', // Text next to the text field
                      ),
                    ),
                  ),
                ],
              ),

              for (int i = 0; i < serialNumbers.length; i++)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: serialControllers[i],
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'Serial ${i + 1}',
                          labelStyle: TextStyle(
                              fontSize:
                                  widget.appNotifier.fontSize.toDouble() - 2),
                          suffixText: 'Units',
                        ),
                      ),
                    ),
                  ],
                ),
              // Button to add more text fields
          ElevatedButton(
  onPressed: () {
    setState(() {
      String newSerial = quantityController.text.trim();
      
      // Check if the new serial is empty
      if (newSerial.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a serial number first'),
          ),
        );
        return;
      }

      if (serialControllers.any((controller) => controller.text == newSerial)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('This serial number has already been entered'),
          ),
        );
      } else {
        // Check if the serial number already exists in the accumulated list
        if (widget.serials.containsKey(widget.index) &&
            widget.serials[widget.index]!.contains(newSerial)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('This serial number has already been entered'),
            ),
          );
          return;
        }

        // If not, add the serial number
        serialNumbers.add(newSerial);
        serialControllers.add(
          TextEditingController(text: newSerial),
        );
        quantityController.clear();
      }
    });
  },
  child: Text('Add Serial Number'),
),

ElevatedButton(
  onPressed: () {
    setState(() {
      int newQuantity = int.tryParse(quantityController.text) ?? 0;

      // Check if any of the serial numbers are empty
      if (serialControllers.any((controller) => controller.text.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter all serial numbers'),
          ),
        );
        return;
      }

      // Add the new serial number entered directly into the last controller
      String newSerial = quantityController.text.trim();
      if (serialControllers.any((controller) => controller.text == newSerial)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('This serial number has already been entered'),
          ),
        );
        return;
      } else {
        // Check if the serial number already exists in the accumulated list
        if (widget.serials.containsKey(widget.index) &&
            widget.serials[widget.index]!.contains(newSerial)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('This serial number has already been entered in the list'),
            ),
          );
          return;
        }
      }
      if (newSerial.isNotEmpty) {
                serialNumbers.add(newSerial);
        serialControllers.add(TextEditingController(text: newSerial));
      }

      

      

      // Filter out empty serial numbers
      List<String> nonEmptySerials = serialControllers
          .map((controller) => controller.text.trim())
          .where((serial) => serial.isNotEmpty)
          .toList();

      // Check if serials already exist for the given index
      if (widget.serials.containsKey(widget.index)) {
        // If they exist, accumulate the serials
        widget.serials[widget.index] = [
          ...widget.serials[widget.index]!,
          ...nonEmptySerials,
        ];
      } else {
        // If not, assign the serials directly
        widget.serials[widget.index] = nonEmptySerials;
      }

      widget.addQuantitySerial(
        context,
        widget.index,
        newQuantity,
        dropdownValue,
        nonEmptySerials.length,
        widget.serials,
      );
      Navigator.pop(context);
      Navigator.pop(context);
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
