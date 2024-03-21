import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project/app_notifier.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ChangeItemQuantity extends StatefulWidget {
  final AppNotifier appNotifier;
  final String usercode;
  final int index;
  final List<Map<dynamic, dynamic>> items;
  final int itemQuantities;
  final Map<int, List<String>> quantities;
  final Map<int, String> updatedWarehouses;
  final Map<int, String> updatedUOM;

  final Function(
      BuildContext,
      int,
      int,
      Map<int,List<String>>,
      String,
      String) changeQuantity;
  const ChangeItemQuantity(
      {Key? key,
      required this.appNotifier,
      required this.usercode,
      required this.items,
      required this.index,
      required this.changeQuantity, // Add this line
      required this.itemQuantities,
      required this.quantities,
      required this.updatedWarehouses,
      required this.updatedUOM})
      : super(key: key);

  @override
  State<ChangeItemQuantity> createState() => _ChangeItemQuantityState();
}

class _ChangeItemQuantityState extends State<ChangeItemQuantity> {
  List<TextEditingController> quantityControllers = [];
  String dropdownValueUOM = '';
  String dropdownValue = 'Each';
  List<Map<dynamic, dynamic>> itemsorders = [];
  String apiurl = 'http://5.189.188.139:8080/api/';
  bool _isLoading = false;
  List<Map<dynamic, dynamic>> fetchedData = []; // Define fetchedData list
  List<Map<dynamic, dynamic>> fetchedDataUOM = []; // Define fetchedData list
late TextEditingController quantityController;
  String quantity = '';

  int totalQuantity = 0;
  @override
  void initState() {
    super.initState();
    itemsorders = widget.items;
print(widget.itemQuantities);
    quantityController = TextEditingController(text: widget.itemQuantities.toString());

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

    print('%%%%%%%%%');
    print(widget.updatedUOM[widget.index]);
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

  



  void updateQuantityNumbers(
    BuildContext context,
    ValueChanged<bool> updateReturnBack,
  ) {
    // Check if any serial number is changed to empty
    

    if (widget.quantities.containsKey(widget.index)) {
      for (int i = 0; i < widget.quantities[widget.index]!.length; i++) {
        if (widget.quantities[widget.index]![i].isEmpty) {
          updateReturnBack(false); // Update the returnBack variable
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please do not change a quanity number to empty'),
            ),
          );
          return; // Stop the update process
        }
      }
    }

    // Check if any serial number is changed to a value that already exists in the same map
    


    print('hiii');
    // print(quantityController.text);
    // Update the serial numbers and quantity
   int newQuantity = int.tryParse(quantityController.text) ?? 0;
    // Update the serial numbers and quantity
    widget.changeQuantity(
      context,
      widget.index,
      newQuantity,
      widget.quantities,
      dropdownValue,
      dropdownValueUOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Change Quantity',
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
                    value: widget.updatedWarehouses[widget.index] ??
                        dropdownValue ??
                        '',
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
                    value: widget.updatedUOM[widget.index] ??
                        dropdownValueUOM ??
                        '',
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValueUOM = newValue ?? '';
                        widget.updatedUOM[widget.index] = newValue ?? '';
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
                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                 
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text field for batch number
                              // Text field for quantity
                            TextFormField(
        controller: quantityController, // Use the controller for the TextFormField
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Quantity',
          // Other decoration properties as needed
        ),
        onChanged: (value) {
          // You can remove this onChanged callback if you don't need it
        },
      ),

                              // Row for production date and expiry date
                           
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
                            updateQuantityNumbers(context, (newValue) {
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
                ]),
          ),
        ));
  }
}
