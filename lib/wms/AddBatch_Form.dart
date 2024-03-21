import 'dart:convert';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project/app_notifier.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import this package to format the date

class AddBatch extends StatefulWidget {
  final AppNotifier appNotifier;
  final String usercode;
  final int index;
  final List<Map<dynamic, dynamic>> items;
  final int itemQuantities;
  final Map<int, List<String>> batches;
  final Map<int, List<String>> quantities;
  final Map<int, List<DateTime>> prodDate;
  final Map<int, List<DateTime>> expDate;

  final Function(
      BuildContext,
      int,
      int,
      String,
      int,
      Map<int, List<String>>,
      Map<int, List<String>>,
      Map<int, List<DateTime>>,
      Map<int, List<DateTime>>,String) addBatchSerial;
  const AddBatch(
      {Key? key,
      required this.appNotifier,
      required this.usercode,
      required this.items,
      required this.index,
      required this.addBatchSerial, // Add this line
      required this.itemQuantities,
      required this.batches,
      required this.quantities,
      required this.prodDate,
      required this.expDate})
      : super(key: key);

  @override
  State<AddBatch> createState() => _AddBatchState();
}

class _AddBatchState extends State<AddBatch> {
  TextEditingController batchController = TextEditingController();
  String dropdownValue = 'Units';
  List<Map<dynamic, dynamic>> itemsorders = [];
  String apiurl = 'http://5.189.188.139:8080/api/';
  bool _isLoading = false;
  List<Map<dynamic, dynamic>> fetchedData = []; // Define fetchedData list
    List<Map<dynamic, dynamic>> fetchedDataUOM = []; // Define fetchedData list
  List<String> batchNumbers = []; // Maintain a list of serial numbers
  List<String> quantityNumbers = []; // Maintain a list of serial numbers
  List<TextEditingController> batchControllers =
      []; // Maintain controllers for each serial text field
  List<TextEditingController> quantityControllers =
      []; // Maintain controllers for each serial text field
  List<TextEditingController> prodDateControllers = [];
  List<TextEditingController> expDateControllers = [];
  TextEditingController quantityControllerPerUnit = TextEditingController();
  TextEditingController productionDateController = TextEditingController();
  String dropdownValueUOM='';

  TextEditingController expiryDateController = TextEditingController();
  DateTime? _productionDate;
  DateTime? _expiryDate;

  // This function shows the date picker and updates the date
  Future<void> _selectDate(BuildContext context, bool isProductionDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null)
      setState(() {
        if (isProductionDate) {
          _productionDate = picked;
          productionDateController.text =
              DateFormat.yMd().format(picked); // Format the date as you want
        } else {
          _expiryDate = picked;
          expiryDateController.text =
              DateFormat.yMd().format(picked); // Format the date as you want
        }
      });
  }

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

  Future<void> scanBarcode() async {
    try {
      ScanResult result = await BarcodeScanner.scan();
      String barcode =
          result.rawContent.replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '');
      print(barcode);

      // Split the scanned content by the delimiter (e.g., comma or newline)
      List<String> batches = barcode.split('\n');

      for (String batch in batches) {
        // If the serial number hasn't been scanned yet, add it to the list
        setState(() {
          batchNumbers.add(batch);
          // Automatically fill the batch field with the scanned barcode
          batchController.text = batch;
          // Check if batch already exists
          if (widget.batches[widget.index]!.contains(batch)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('This batch number has already been entered'),
              ),
            );
            return;
          }
        });
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        print('Camera permission denied');
      } else {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Batch',
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
                  Text(
                  'UOM',
                  style: TextStyle(
                      fontSize: widget.appNotifier.fontSize.toDouble() - 2,
                      color: Colors.black54),
                ),
                DropdownButton<String>(
                  value: dropdownValueUOM ??'',
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValueUOM = newValue??'';
                    });
                  },
                  items: fetchedDataUOM.map<DropdownMenuItem<String>>(
                      (Map<dynamic, dynamic> uom) {
                    return DropdownMenuItem<String>(
                      value: uom['ANY_VALUE(i.uom)'].toString(),
                      child: Text(uom['ANY_VALUE(i.uom)'].toString()),
                    );
                  }).toList(),
                ),
                ],
              ),
              SizedBox(height: 5),
              Column(
                children: [
                  TextField(
                    controller: quantityControllerPerUnit,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      labelStyle: TextStyle(
                          fontSize: widget.appNotifier.fontSize.toDouble() - 2),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: batchController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'Batch',
                      labelStyle: TextStyle(
                          fontSize: widget.appNotifier.fontSize.toDouble() - 2),
                      suffixText: 'Units', // Text next to the text field
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: productionDateController,
                          keyboardType: TextInputType.datetime,
                          decoration: InputDecoration(
                            labelText: 'Production Date',
                            labelStyle: TextStyle(
                                fontSize:
                                    widget.appNotifier.fontSize.toDouble() - 2),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () {
                                _selectDate(context, true);
                              },
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TextField(
                          controller: expiryDateController,
                          keyboardType: TextInputType.datetime,
                          decoration: InputDecoration(
                            labelText: 'Expiry Date',
                            labelStyle: TextStyle(
                                fontSize:
                                    widget.appNotifier.fontSize.toDouble() - 2),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () {
                                _selectDate(context, false);
                              },
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Button to add more text fields

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    int newQuantity =
                        int.tryParse(quantityControllerPerUnit.text) ?? 0;
                    if (widget.itemQuantities < 0 ||
                        widget.itemQuantities == 0 ||
                        newQuantity > widget.itemQuantities) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Over Quantity Not Allowed!'),
                        ),
                      );
                      return;
                    }

                    // Check if any of the serial numbers are empty
                    if (quantityControllers
                        .any((controller) => controller.text.isEmpty)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please enter a Quantity Number'),
                        ),
                      );
                      return;
                    }

                    int newBatch = int.tryParse(batchController.text) ?? 0;

                    // Check if any of the serial numbers are empty
                    if (batchControllers
                        .any((controller) => controller.text.isEmpty)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please enter a Batch Number'),
                        ),
                      );
                      return;
                    }

// Add the new serial number entered directly into the last controller
                    String newBatchtext = batchController.text.trim();
                    print(widget.batches[widget.index]);
                    print(batchControllers.toList().toString());
                    print('bbbbbbbbbbbb');
                    print(newBatchtext);

// Check if the new batch number already exists
                    if (widget.batches[widget.index] != null) {
                      if (widget.batches[widget.index]!
                          .contains(newBatchtext)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'This batch number has already been entered'),
                          ),
                        );
                        return;
                      } else {
                        // Check if the serial number already exists in the accumulated list
                        if (widget.batches.containsKey(widget.index) &&
                            widget.batches[widget.index]!.contains(newBatch)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'This batch number has already been entered in the list'),
                            ),
                          );
                          return;
                        }
                      }
                    }
                    if (batchController.text.isEmpty ||
                        productionDateController.text.isEmpty ||
                        expiryDateController.text.isEmpty ||
                        quantityControllerPerUnit.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please fill in all the fields'),
                        ),
                      );
                      return;
                    }
                    if (newBatchtext.isNotEmpty) {
                      batchControllers
                          .add(TextEditingController(text: newBatchtext));
                    }
                    String newQuantitytext =
                        quantityControllerPerUnit.text.trim();
                    if (newQuantitytext.isNotEmpty) {
                      quantityControllers
                          .add(TextEditingController(text: newQuantitytext));
                    }
                    String newProdDatetext =
                        productionDateController.text.trim();
                    if (newProdDatetext.isNotEmpty) {
                      prodDateControllers
                          .add(TextEditingController(text: newProdDatetext));
                    }

                    String newExpDatetext = expiryDateController.text.trim();
                    if (newExpDatetext.isNotEmpty) {
                      expDateControllers
                          .add(TextEditingController(text: newExpDatetext));
                    }

                    // Filter out empty serial numbers
                    List<String> nonEmptyBatches = batchControllers
                        .map((controller) => controller.text.trim())
                        .where((batch) => batch.isNotEmpty)
                        .toList();

                    // Check if serials already exist for the given index
                    if (widget.batches.containsKey(widget.index)) {
                      // If they exist, accumulate the serials
                      widget.batches[widget.index] = [
                        ...widget.batches[widget.index]!,
                        ...nonEmptyBatches,
                      ];
                    } else {
                      // If not, assign the serials directly
                      widget.batches[widget.index] = nonEmptyBatches;
                    }

                    ///------
                    // Filter out empty serial numbers
                    List<String> nonEmptyQuantities = quantityControllers
                        .map((controller) => controller.text.trim())
                        .where((quantity) => quantity.isNotEmpty)
                        .toList();

                    // Check if serials already exist for the given index
                    if (widget.quantities.containsKey(widget.index)) {
                      // If they exist, accumulate the serials
                      widget.quantities[widget.index] = [
                        ...widget.quantities[widget.index]!,
                        ...nonEmptyQuantities,
                      ];
                    } else {
                      // If not, assign the serials directly
                      widget.quantities[widget.index] = nonEmptyQuantities;
                    }

                    ///------
                    // Filter out empty serial numbers

// Then you can convert it to a DateTime object if necessary

// Filter out empty serial numbers
                    List<DateTime> parsedProdDates = prodDateControllers
                        .map((controller) => controller.text
                            .trim()) // Get the text from the controllers
                        .where((dateString) => dateString
                            .isNotEmpty) // Filter out empty date strings
                        .map((dateString) => DateFormat.yMd().parse(
                            dateString)) // Parse date strings into DateTime objects
                        .toList();

                    // Check if serials already exist for the given index
                    if (widget.prodDate.containsKey(widget.index)) {
                      // If they exist, accumulate the serials
                      widget.prodDate[widget.index] = [
                        ...widget.prodDate[widget.index]!,
                        ...parsedProdDates,
                      ];
                    } else {
                      // If not, assign the serials directly
                      widget.prodDate[widget.index] = parsedProdDates;
                    }

                    // Then you can convert it to a DateTime object if necessary

// Filter out empty serial numbers
                    List<DateTime> parsedExpDate = expDateControllers
                        .map((controller) => controller.text
                            .trim()) // Get the text from the controllers
                        .where((dateString) => dateString
                            .isNotEmpty) // Filter out empty date strings
                        .map((dateString) => DateFormat.yMd().parse(
                            dateString)) // Parse date strings into DateTime objects
                        .toList();

                    // Check if serials already exist for the given index
                    if (widget.expDate.containsKey(widget.index)) {
                      // If they exist, accumulate the serials
                      widget.expDate[widget.index] = [
                        ...widget.expDate[widget.index]!,
                        ...parsedExpDate,
                      ];
                    } else {
                      // If not, assign the serials directly
                      widget.expDate[widget.index] = parsedExpDate;
                    }

                    widget.addBatchSerial(
                        context,
                        widget.index,
                        newQuantity,
                        dropdownValue,
                        nonEmptyBatches.length,
                        widget.batches,
                        widget.quantities,
                        widget.prodDate,
                        widget.expDate,
                        dropdownValueUOM
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
