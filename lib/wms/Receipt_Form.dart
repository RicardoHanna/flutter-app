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
import 'package:project/wms/Receipt_Info_Form.dart';
import 'package:project/wms/Receiving_Form.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/resources/add_data.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project/hive/usergroup_hive.dart';
import 'package:project/Synchronize/DataSynchronizer.dart';

class ReceiptForm extends StatefulWidget {
  final AppNotifier appNotifier;
  final String usercode;

  ReceiptForm({required this.appNotifier, required this.usercode});

  @override
  State<ReceiptForm> createState() => _ReceiptFormState();
}

class _ReceiptFormState extends State<ReceiptForm> {
  String apiurl = 'http://5.189.188.139:8080/api/';
  List<Map<String, dynamic>> receipts = [];
  List<Map<String, dynamic>> filteredReceipts = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Example: Initialize receipts list
    receipts = [
      {'name': 'Receipt 1', 'code': '524', 'deliveryDate': '2024-03-08'},
      {'name': 'Receipt 2', 'code': '567', 'deliveryDate': '2024-03-09'},
      {'name': 'Receipt 3', 'code': '555', 'deliveryDate': '2024-03-10'},
    ];
    filteredReceipts = receipts;
  }

  void filteredReceipt(String query) {
    setState(() {
      if (query.isNotEmpty) {
        filteredReceipts = receipts.where((receipt) {
          final name = receipt['name'].toString().toLowerCase();
          final code = receipt['code'].toString().toLowerCase();
          final deliveryDate = receipt['deliveryDate'].toString().toLowerCase();
          return name.contains(query.toLowerCase()) ||
              code.contains(query.toLowerCase()) ||
              deliveryDate.contains(query.toLowerCase());
        }).toList();
      } else {
        // If search query is empty, show all receipts
        filteredReceipts = receipts;
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
        title: Text('Receipt'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                // Call filter function when text in search field changes
                filteredReceipt(value);
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
                    'Receipt Number',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: widget.appNotifier.fontSize.toDouble() - 6),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Booking Date',
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
              itemCount: filteredReceipts.length,
              itemBuilder: (context, index) {
                // Display filtered list of receipts
                final receipt = filteredReceipts[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${receipt['code']}'),
                          Text(
                            '${receipt['deliveryDate']}',
                            style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize:
                                    widget.appNotifier.fontSize.toDouble() - 4),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        receipt['name'],
                        style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize:
                                widget.appNotifier.fontSize.toDouble() - 4),
                      ),

                      // Add onTap action for the receipt tile
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReceiptInfoForm(
                             appNotifier: widget.appNotifier,
                             usercode: widget.usercode,
                             recCode:receipt['code'].toString()
                            ),
                          ),
                        );
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
        ],
      ),
    );
  }
}
