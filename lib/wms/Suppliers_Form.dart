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

class SuppliersForm extends StatefulWidget {
  final AppNotifier appNotifier;
  final String usercode;


  SuppliersForm({required this.appNotifier, required this.usercode});

  @override
  State<SuppliersForm> createState() => _SuppliersFormState();
}class _SuppliersFormState extends State<SuppliersForm> {
  String apiurl = 'http://5.189.188.139:8080/api/';
  List<Map<String, dynamic>> suppliers = []; // List to store supplier data (name and code)
  List<Map<String, dynamic>> filteredSuppliers = []; // Filtered list based on search query
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize suppliers list
    // Example: Fetch suppliers from API or set them manually
    suppliers = [
      {'name': 'Supplier 1', 'code': 1001},
      {'name': 'Supplier 2', 'code': 1002},
      {'name': 'Supplier 3', 'code': 1003},
    ]; // Replace with actual supplier list
    filteredSuppliers = suppliers; // Initially, filtered list is same as suppliers list
  }

  // Function to filter suppliers based on search query
  void filterSuppliers(String query) {
    setState(() {
      if (query.isNotEmpty) {
        // Filter the suppliers list based on search query
        filteredSuppliers = suppliers.where((supplier) {
          final name = supplier['name'].toString().toLowerCase();
          final code = supplier['code'].toString().toLowerCase();
          return name.contains(query.toLowerCase()) || code.contains(query.toLowerCase());
        }).toList();
      } else {
        // If search query is empty, show all suppliers
        filteredSuppliers = suppliers;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suppliers'),
        actions: [
          IconButton(
  icon: Icon(Icons.qr_code),
  onPressed: () async {
    String barcode = await scanBarcode();
    if (barcode.isNotEmpty) {
      // Perform logic to check if the scanned barcode exists in the items
      // and display the corresponding item details.
      // You can use a method similar to how you display items in the list.
   
      // For example:
      bool itemFound = false;
  /*    for (var item in filteredItems) {

        if (item.barCode == barcode) {
          itemFound = true;
          // Show item details for the scanned item
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemsInfoForm(item: item, appNotifier: widget.appNotifier,),
            ),
          );
          break; // Exit the loop since the item is found
        }
      }*/
      if (!itemFound) {
        // Display a message indicating that the scanned item was not found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scanned item not found'),
          ),
        );
      }
    }
  },
),
         
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                // Call filter function when text in search field changes
                filterSuppliers(value);
              },
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredSuppliers.length,
              itemBuilder: (context, index) {
                // Display filtered list of suppliers
                final supplier = filteredSuppliers[index];
                return ListTile(
                  title: Text(supplier['name']),
                  subtitle: Text('Code: ${supplier['code']}'),
                  // Add onTap action for the supplier tile
                  onTap: () {
                    // Handle onTap action
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<String> scanBarcode() async {
  try {
    ScanResult result = await BarcodeScanner.scan();
    String barcode = result.rawContent.replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '');
    // This regular expression removes control characters from the string.
    print(barcode);
    return barcode;
  } on PlatformException catch (e) {
    if (e.code == BarcodeScanner.cameraAccessDenied) {
      // Handle camera permission denied
      print('Camera permission denied');
    } else {
      // Handle other exceptions
      print('Error: $e');
    }
    return '';
  }
}
}
