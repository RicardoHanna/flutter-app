import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project/app_notifier.dart';
import 'package:project/wms/Receiving_Form.dart';
import 'package:http/http.dart' as http;

class SearchBySupplierScreen extends StatefulWidget {
  final AppNotifier appNotifier;
  final String usercode;
  const SearchBySupplierScreen(
      {super.key, required this.appNotifier, required this.usercode});

  @override
  State<SearchBySupplierScreen> createState() => _SearchBySupplierScreenState();
}

class _SearchBySupplierScreenState extends State<SearchBySupplierScreen> {
  TextEditingController supplierNameController = TextEditingController();
  List<dynamic> suppliers = [];
  List<dynamic> filteredSuppliers = [];
  String baseUrl = "http://5.189.188.139:8081/api/";

  Future<void> getSuppliers() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}getSuppliers'));
      if (response.statusCode == 200) {
        setState(() {
          suppliers = jsonDecode(response.body);
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

  userGroupWaiter() async {
    await getSuppliers();
  }

  @override
  void initState() {
    userGroupWaiter();
    super.initState();
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
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
              )),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: supplierNameController,
              decoration: InputDecoration(
                  labelText: 'Search',
                  labelStyle: TextStyle(
                      fontSize: widget.appNotifier.fontSize.toDouble() - 2)),
              onChanged: (value) {
                // itemName = value;
                _updateFilteredOrders(value);
              },
            ),
            SizedBox(
              height: 10,
            ),
            suppliers.length!=0?Expanded(
              child: ListView.builder(
                  itemCount: filteredSuppliers.length == 0
                      ? suppliers.length
                      : filteredSuppliers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 1.0),
                      child: Card(
                        child: ListTile(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (builder) => ReceivingScreen(
                                          appNotifier: widget.appNotifier,
                                          usercode: widget.usercode,searchedSupplier: suppliers[index]["cardCode"],)));
                            },
                            title: Text(
                              "SupplierCode: ${filteredSuppliers.length == 0 ? suppliers[index]["cardCode"] : filteredSuppliers[index]["cardCode"]}",
                              style: TextStyle(
                                fontSize:
                                    widget.appNotifier.fontSize.toDouble() - 2,
                              ),
                            ),
                            subtitle: Text(
                              "SupplierName: ${filteredSuppliers.length == 0 ? suppliers[index]["cardName"] : filteredSuppliers[index]["cardName"]}",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize:
                                    widget.appNotifier.fontSize.toDouble() - 5,
                              ),
                            )),
                      ),
                    );
                  }),
            ):Center(child: CircularProgressIndicator(),)
          ],
        ),
      ),
    );
  }

  void _updateFilteredOrders(String query) {
    setState(() {
      print(query);

      filteredSuppliers = suppliers.where((order) {
        final lowerCaseQuery = query.toLowerCase();
        return order['cardCode']!.toLowerCase().contains(lowerCaseQuery)||order['cardName']!.toLowerCase().contains(lowerCaseQuery);
      }).toList();
    });
  }
}
