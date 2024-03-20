import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project/app_notifier.dart';
import 'package:http/http.dart' as http;

class ItemQuantityScreen extends StatefulWidget {
  final AppNotifier appNotifier;
  final String usercode;
  final int index;
  final List<Map<dynamic, dynamic>> items;
  final int itemQuantities;
  final Function(BuildContext, int, int,String) addQuantity;
  const ItemQuantityScreen({
    Key? key,
    required this.appNotifier,
    required this.usercode,
    required this.items,
    required this.index,
    required this.addQuantity, // Add this line
    required this.itemQuantities,
  }) : super(key: key);

  @override
  State<ItemQuantityScreen> createState() => _ItemQuantityScreenState();
}

class _ItemQuantityScreenState extends State<ItemQuantityScreen> {
  TextEditingController quantityController = TextEditingController();
  String dropdownValue = '';
  List<Map<dynamic, dynamic>> itemsorders = [];
    String apiurl = 'http://5.189.188.139:8080/api/';
    bool _isLoading=false;
  List<Map<dynamic, dynamic>> fetchedData = []; // Define fetchedData list

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


 Future<void> fetchWarehouses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> requestBody = {
        'userCode': widget.usercode
        
      };

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
          'Add Quantity',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${itemsorders[widget.index]['itemCode']} ${itemsorders[widget.index]['itemName']}',
              style: TextStyle(
                  fontSize: widget.appNotifier.fontSize.toDouble() - 2),
            ),
            SizedBox(height: 10),
            Text(
              'Remaining Quantity: ${widget.itemQuantities.toString() ?? 0}',
              style: TextStyle(
                  fontSize: widget.appNotifier.fontSize.toDouble() - 2,
                  color: Colors.black54),
            ),
            SizedBox(
                height: 10), // Add space between the text field and the button
              Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    Text(
      'Warehouse',
      style: TextStyle(
        fontSize: widget.appNotifier.fontSize.toDouble() - 2,
        color: Colors.black54
      ),
    ),
    DropdownButton<String>(
      value: dropdownValue,
      onChanged: (String? newValue) {
        setState(() {
          dropdownValue = newValue!;
        });
      },
      items: fetchedData.map<DropdownMenuItem<String>>((Map<dynamic, dynamic> warehouse) {
        return DropdownMenuItem<String>(
          value: warehouse['ANY_VALUE(u.whsCode)'].toString(),
          child: Text(warehouse['ANY_VALUE(w.whsName)'].toString()),
        );
      }).toList(),
    ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      labelStyle: TextStyle(
                          fontSize: widget.appNotifier.fontSize.toDouble() - 2),
                      suffixText: 'Units', // Text next to the text field
                    ),
                  ),
                ),
              ],
            ),
            
  ],
),



            SizedBox(height: 10),


            ElevatedButton(
              onPressed: () {
                int newQuantity = int.tryParse(quantityController.text) ?? 0;

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
                widget.addQuantity(context, widget.index,
                    newQuantity,dropdownValue); // Pass the context here
                Navigator.pop(context); // Close the screen
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}
