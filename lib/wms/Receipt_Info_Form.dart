import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:another_flushbar/flushbar.dart';
import 'package:barcode_scan2/model/scan_result.dart';
import 'package:barcode_scan2/platform_wrapper.dart';
import 'dart:ui'; // Import dart:ui for accessing AssetImage

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:project/Forms/Customers_Form.dart';
import 'package:project/Forms/Items_Form.dart';
import 'package:project/Forms/Price_Lists_Form.dart';
import 'package:project/Forms/Report_Form.dart';
import 'package:project/Forms/settings_edit_user_form.dart';
import 'package:project/app_notifier.dart';
import 'package:project/Synchronize/DataSynchronizerFromFirebaseToHive.dart';
import 'package:project/hive/authorization_hive.dart';
import 'package:project/hive/companies_hive.dart';
import 'package:project/hive/companiesusers_hive.dart';
import 'package:project/hive/customers_hive.dart';
import 'package:project/hive/hiveuser.dart';
import 'package:project/hive/itemsprices_hive.dart';
import 'package:project/hive/menu_hive.dart';
import 'package:project/hive/translations_hive.dart';
import 'package:project/hive/userssalesemployees_hive.dart';
import 'package:project/screens/admin_page.dart';
import 'package:project/screens/login_page.dart';
import 'package:project/screens/synchronize_data_page.dart';
import 'package:project/utils.dart';
import 'package:project/wms/Receiving_Form.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/resources/add_data.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project/hive/usergroup_hive.dart';
import 'package:project/Synchronize/DataSynchronizer.dart';

class ReceiptInfoForm extends StatefulWidget {
  final AppNotifier appNotifier;
  final String usercode;
  final String recCode;

  ReceiptInfoForm(
      {required this.appNotifier,
      required this.usercode,
      required this.recCode});

  @override
  State<ReceiptInfoForm> createState() => _ReceiptInfoFormState();
}

class _ReceiptInfoFormState extends State<ReceiptInfoForm> {
  String apiurl = 'http://5.189.188.139:8080/api/';
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filteredItems = [];
  TextEditingController searchController = TextEditingController();
    String selectedValue = 'Value 1'; // Initial selected value
  String selectedBarcodeType = 'Code_128'; // Initial selected barcode type

  @override
  void initState() {
    super.initState();

    // Example: Initialize receipts list
    items = [
      {
        'name': 'Item 1',
        'code': 0023422,
        'quantity': '1 Units',
        'barcode': 'A920e2233232323',
        'warehouse': 'A01'
      },
      {
        'name': 'Item 2',
        'code': 0331323,
        'quantity': '1 Units',
        'barcode': 'A920e2233232323',
        'warehouse': 'B01'
      },
      {
        'name': 'Item 3',
        'code': 0222344,
        'quantity': '1 Units',
        'barcode': 'A920e2233232323',
        'warehouse': 'C01'
      },
    ];
    filteredItems = items;
  }

  void filteredItem(String query) {
    setState(() {
      if (query.isNotEmpty) {
        filteredItems = items.where((item) {
          final name = item['name'].toString().toLowerCase();
          final code = item['code'].toString().toLowerCase();
          final quantity = item['quantity'].toString().toLowerCase();
          final barcode = item['barcode'].toString().toLowerCase();
          final warehouse = item['warehouse'].toString().toLowerCase();

          return name.contains(query.toLowerCase()) ||
              code.contains(query.toLowerCase()) ||
              quantity.contains(query.toLowerCase()) ||
              barcode.contains(query.toLowerCase()) ||
              warehouse.contains(query.toLowerCase());
        }).toList();
      } else {
        // If search query is empty, show all receipts
        filteredItems = items;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _appTextStyleLead =
        TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    TextStyle _appTextStyle =
        TextStyle(fontSize: widget.appNotifier.fontSize.toDouble() - 8);
    return Scaffold(
      appBar: AppBar(
        title: Text('GRPO' + widget.recCode),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Date: 2024-03-08',
                    style: TextStyle(
                        fontSize: widget.appNotifier.fontSize.toDouble() - 4),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Due: 2024-03-08',
                    style: TextStyle(
                        fontSize: widget.appNotifier.fontSize.toDouble() - 4),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Receipt',
                    style: TextStyle(
                        fontSize: widget.appNotifier.fontSize.toDouble() - 4),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                // Call filter function when text in search field changes
                filteredItem(value);
              },
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'Item',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: widget.appNotifier.fontSize.toDouble() - 6),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Quantity',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: widget.appNotifier.fontSize.toDouble() - 6),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
      Expanded(
      child: ListView.builder(
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          // Display filtered list of receipts
          final item = filteredItems[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item['code']}'),
                    Text(
                      '${item['quantity']}',
                      style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize:
                              widget.appNotifier.fontSize.toDouble() - 4),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['name'],
                        style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize:
                                widget.appNotifier.fontSize.toDouble() - 4)),
                    Text('Barcode : ' + item['barcode'],
                        style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize:
                                widget.appNotifier.fontSize.toDouble() - 4)),
                    Text('warehouse: ' + item['warehouse'],
                        style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize:
                                widget.appNotifier.fontSize.toDouble() - 4)),
                  ],
                ),
                // Add onTap action for the receipt tile
                onTap: () {
                  _showPrintLabelDialog(context,item['code'].toString());
                 // _showDialog(context, item['code'].toString());
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Divider(),
              ),
            ],
          );
        },
      ),
    ),
          ElevatedButton(
            onPressed: () {
               Navigator.pop(context);
                  },
            style: ButtonStyle(
              fixedSize: MaterialStateProperty.all(
                  Size(280, 10)), // Set the width and height
            ),
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

   void _showDialog(BuildContext context, String code) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose an action",style: TextStyle(fontSize: widget.appNotifier.fontSize.toDouble())),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  _showPrintLabelDialog(context, code);
                },
                child: Text("Print Label",style: TextStyle(fontSize: widget.appNotifier.fontSize.toDouble()-3),),
              ),
            ),
          
          ],
        );
      },
    );
  }

  void _showPrintLabelDialog(BuildContext context, String code) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Choose a label",style: TextStyle(fontSize: widget.appNotifier.fontSize.toDouble())),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
              //  _showPrintBarcode(context, code);
              },
              child: Text("Label 1",style: TextStyle(fontSize: widget.appNotifier.fontSize.toDouble()-3)),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () async {
                 //_showSelectValueDialog(context, code); // Wait for selection
              },
              child: Text("Label 2",style: TextStyle(fontSize: widget.appNotifier.fontSize.toDouble()-3)),
            ),
          ),
        ],
      );
    },
  );
}


  
}