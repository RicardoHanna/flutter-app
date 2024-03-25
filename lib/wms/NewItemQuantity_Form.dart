import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project/app_notifier.dart';
import 'package:http/http.dart' as http;

class MewItemQuantity extends StatefulWidget {
  final String docEntry;
  final AppNotifier appNotifier;
  final String userCode;
  final Map<dynamic, dynamic> item;

  const MewItemQuantity(
      {super.key,
      required this.docEntry,
      required this.appNotifier,
      required this.userCode,
      required this.item});

  @override
  State<MewItemQuantity> createState() => _MewItemQuantityState();
}

class _MewItemQuantityState extends State<MewItemQuantity> {
  TextEditingController quantityController = TextEditingController();
  bool _isLoading = false;
  String apiurl = 'http://5.189.188.139:8081/api/';
  List<Map<dynamic,dynamic>> whs = [];
  String dropdownValue = '';

  Future<void> fetchWarehouses() async {
    setState(() {
      _isLoading = true;
    });
    try {
      Map<String, dynamic> requestBody = {'userCode': widget.userCode};

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
          whs = List<Map<dynamic, dynamic>>.from(data.map((item) {
            // Convert each item in the response to a map
            return Map<dynamic, dynamic>.from(item);
          }));
          _isLoading = false;
        });
        print(whs);
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
  void initState() {
    
    super.initState();
    fetchWarehouses().then((value){
      setState(() {
        dropdownValue = whs.isNotEmpty
            ? whs.first['ANY_VALUE(u.whsCode)'].toString()
            : ''; // Set default value to an empty string if fetched data is empty
        print('Dropdown Value: $dropdownValue');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Suppliers',
          style: TextStyle(
              color: Colors.white,
              fontSize: widget.appNotifier.fontSize.toDouble()),
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
              )),
        ],
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Item: ${widget.item['itemCode']}"),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    decoration: InputDecoration(
                        labelText: 'Quantity',
                        labelStyle: TextStyle(
                            fontSize:
                                widget.appNotifier.fontSize.toDouble() - 2)),
                    onChanged: (value) {},
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    decoration: InputDecoration(
                        labelText: 'Quantity',
                        labelStyle: TextStyle(
                            fontSize:
                                widget.appNotifier.fontSize.toDouble() - 2)),
                    onChanged: (value) {},
                  ),
                )
              ],
            ),
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
                  items: whs.map<DropdownMenuItem<String>>(
                      (Map<dynamic, dynamic> warehouse) {
                    return DropdownMenuItem<String>(
                      value: warehouse['ANY_VALUE(u.whsCode)'].toString(),
                      child: Text(warehouse['ANY_VALUE(w.whsName)'].toString()),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
