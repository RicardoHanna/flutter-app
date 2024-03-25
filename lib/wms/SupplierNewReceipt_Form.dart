import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project/Forms/Inventory_Form.dart';
import 'package:project/app_notifier.dart';
import 'package:project/wms/InventoryList_Form.dart';
import 'package:http/http.dart' as http;

class SupplierNewReceipt extends StatefulWidget {
  final AppNotifier appNotifier;
  final String usercode;
  final String supplierCode;
  final String docEntry;
  const SupplierNewReceipt(
      {super.key,
      required this.appNotifier,
      required this.usercode,
      required this.supplierCode, required this.docEntry});

  @override
  State<SupplierNewReceipt> createState() => _SupplierNewReceiptState();
}

class _SupplierNewReceiptState extends State<SupplierNewReceipt> {
  String baseUrl = "http://5.189.188.139:8081/api/";
  List<dynamic> items = [];


  Future<void> getItemsFromPdn1()async{
    try {
      final cmpCode = await fetchCmpCode(widget.usercode);


      final response = await http.post(
        Uri.parse('${baseUrl}geteItemsOfNewPO'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'docEntry':widget.docEntry,'cmpCode':cmpCode})
        );
      if (response.statusCode == 200) {
        setState(() {
          items = jsonDecode(response.body);
        });
        print(response.body);
      } else {
        print('Failed to fetch user groups: ${response.statusCode}');
        // Handle error accordingly
      }
    } catch (e) {
      print('Error fetching user groups: $e');
      // Handle error accordingly
    }
  }

  Future<String?> fetchCmpCode(String userCode) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}getDefaultCompCode?userCode=$userCode'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return data[0]['cmpCode'].toString();
        }
      }
    } catch (error) {
      print('Error fetching cmpCode: $error');
    }
    return null;
  }

  supplierWaiter() async {
    await getItemsFromPdn1();
  }

  @override
  void initState() {
    supplierWaiter();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Receipt',
          style: TextStyle(
              color: Colors.white,
              fontSize: widget.appNotifier.fontSize.toDouble()),
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.attach_file,
                color: Colors.white,
              )),
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
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (builder)=>InventoryList(appNotifier: widget.appNotifier, usercode: widget.usercode, docEntry: '',))
                );
              },
              child: Text(
                "Add Item",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.appNotifier.fontSize.toDouble()),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      20), // Adjust borderRadius to maintain button shape
                ),
                backgroundColor: Colors.blue,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Item",
                  style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                      fontSize: widget.appNotifier.fontSize.toDouble() - 5),
                ),
                Text(
                  "Quantity",
                  style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                      fontSize: widget.appNotifier.fontSize.toDouble() - 5),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Card(
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ItemCode: ',
                              style: TextStyle(
                                fontSize:
                                    widget.appNotifier.fontSize.toDouble() - 2,
                              ),
                            ),
                            Text(
                              '4 Units',
                              style: TextStyle(
                                fontSize:
                                    widget.appNotifier.fontSize.toDouble() - 5,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BarCode: ',
                              style: TextStyle(
                                fontSize:
                                    widget.appNotifier.fontSize.toDouble() - 5,
                              ),
                            ),
                            Text(
                              'ItemName: ',
                              style: TextStyle(
                                fontSize:
                                    widget.appNotifier.fontSize.toDouble() - 5,
                              ),
                            ),
                            Text(
                              'WareHouse: ',
                              style: TextStyle(
                                fontSize:
                                    widget.appNotifier.fontSize.toDouble() - 5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}


