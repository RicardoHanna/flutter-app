import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:project/Forms/Items_Info_Form.dart';
import 'package:project/app_notifier.dart';
import 'package:project/classes/DataSearch.dart';
import 'package:project/hive/hiveuser.dart';
import 'package:project/hive/items_hive.dart';
import 'package:project/hive/translations_hive.dart';
import 'package:project/screens/login_page.dart';
import 'package:project/utils.dart';
import 'package:project/screens/admin_users_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/resources/add_data.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project/hive/usergroup_hive.dart';
import 'package:project/Synchronize/DataSynchronizer.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/services.dart';


class ItemsForm extends StatefulWidget {
 
  final AppNotifier appNotifier;
  ItemsForm({required this.appNotifier});
  @override
  State<ItemsForm> createState() => _itemsFormState();
}

class _itemsFormState extends State<ItemsForm> {

 String? itemCode;
 String? itemName;
 bool? active;
 late List<Items> items;
  late List<Items> filteredItems=[];

final TextEditingController codeFilterController = TextEditingController();
  final TextEditingController groupFilterController = TextEditingController();
  final TextEditingController brandFilterController = TextEditingController();
  final TextEditingController itemNameFilterController = TextEditingController();
  final TextEditingController categoryFilterController = TextEditingController();
 TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // Call async method within initState
    initializeData();
  }

  // Initialize data asynchronously
  Future<void> initializeData() async {
   
   //insertSampleData();
    printUserDataTranslations();
   items= await _getItems();
   filteredItems = List.from(items);
  }
  
Future<void> insertSampleData() async {
  var itemsBox = await Hive.openBox<Items>('items');
  itemsBox.add(
    Items(
      '001',
      'Sample Item 1',
      'Sample Pr Name 1',
      'Sample F Name 1',
      'Sample Pr F Name 1',
      'Sample Group Code 1',
      'Sample Categ Code 1',
      'Sample Brand Code 1',
      'Sample ItemType 1',
      'Sample Bar Code 1',
      'Sample UOM 1',
      'https://firebasestorage.googleapis.com/v0/b/sales-bab47.appspot.com/o/profileImage?alt=media&token=c74746f0-cb07-422b-8428-fc236d0e1339', // Replace with an actual base64-encoded image
      'Sample Remark 1',
      'Sample Brand 1',
      'Sample ManageBy 1',
      10.0, // Sample VATRate
      true, // Sample Active
      1.5, // Sample Weight
      'Sample Charect1 1',
      'Sample Charact2 1',
    ),
  );

  itemsBox.add(
    Items(
      '002',
      'Sample Item 2',
      'Sample Pr Name 2',
      'Sample F Name 2',
      'Sample Pr F Name 2',
      'Sample Group Code 2',
      'Sample Categ Code 2',
      'Sample Brand Code 2',
      'Sample ItemType 2',
      'Sample Bar Code 2',
      'Sample UOM 2',
      'https://firebasestorage.googleapis.com/v0/b/sales-bab47.appspot.com/o/profileImage?alt=media&token=c74746f0-cb07-422b-8428-fc236d0e1339', // Replace with an actual base64-encoded image
      'Sample Remark 2',
      'Sample Brand 2',
      'Sample ManageBy 2',
      15.0, // Sample VATRate
      false, // Sample Active
      2.0, // Sample Weight
      'Sample Charect1 2',
      'Sample Charact2 2',
    ),
  );

  print('Sample data inserted successfully');

}

Future<void> printUserDataTranslations() async {
 var itemsBox = await Hive.openBox<Items>('items');
    
    print('Printing Users:');
    for (var item in itemsBox.values) {
      print('Username: ${item.itemCode}');
      print('Email: ${item.itemName}');
      print('Email: ${item.active}');
      print('-------------------------');
    }
  // Open 'translationsBox' for Translations

  print('Printed all data');


}

Future<List<Items>> _getItems() async {
  // Retrieve changes from the local database
  var itemsBox = await Hive.openBox<Items>('items');
  
  // Assuming 'Items' class has properties itemCode, itemName, and active
  var allItems = itemsBox.values.toList();
  
  for (var item in allItems) {
    // Access properties of each item
    var itemCode = item.itemCode;
    var itemName = item.itemName;
    var active = item.active;

    // Now you can use itemCode, itemName, and active as needed
    print('Item Code: $itemCode, Item Name: $itemName, Active: $active');
    
    // Perform your synchronization with Firestore or any other logic here
  }

  // Close the box when done
  return allItems;
  
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Items Form'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: DataSearch(itemsList: items));
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
          // Add the barcode scan icon here
          IconButton(
            icon: Icon(Icons.camera),
            onPressed: () async {
              String barcode = await scanBarcode();
              if (barcode.isNotEmpty) {
                // Perform logic to check if the scanned barcode exists in the items
                // and display the corresponding item details.
                // You can use a method similar to how you display items in the list.
                // For example:
                var scannedItem = items.firstWhere((item) => item.barCode == barcode, orElse: null);
                if (scannedItem != null) {
                  // Show item details for the scanned item
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemsInfoForm(item: scannedItem),
                    ),
                  );
                } else {
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
  body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<Items>>(
  future: _getItems(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    } else if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Text('No items found');
    } else {
      return ListView.builder(
        itemCount: filteredItems.length, // Use filteredItems.length
        itemBuilder: (context, index) {
          var item = filteredItems[index]; // Use filteredItems[index] instead of snapshot.data![index]
          return Card(
            child: ListTile(
              title: Text(item.itemCode ?? ''),
              subtitle: Text(item.itemName ?? ''),
              trailing: Text(item.active.toString()),
              onTap: () {
                // Navigate to the ItemsInfoForm page and pass the selected item
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemsInfoForm(item: item),
                  ),
                );
              },
            ),
          );
        },
      );
    }
  },
),

      ),
    );
    
  }
   _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter Items'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: codeFilterController,
                decoration: InputDecoration(labelText: 'Item Code'),
              ),
              TextFormField(
                controller: groupFilterController,
                decoration: InputDecoration(labelText: 'Group'),
              ),
              TextFormField(
                controller: brandFilterController,
                decoration: InputDecoration(labelText: 'Brand'),
              ),
              TextFormField(
                controller: itemNameFilterController,
                decoration: InputDecoration(labelText: 'Item Name'),
              ),
              TextFormField(
                controller: categoryFilterController,
                decoration: InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _applyFilters();
                Navigator.pop(context);
              },
              child: Text('Apply'),
            ),
          ],
        );
      },
    );
  }

   void _applyFilters() {
    // Update the filteredItems list based on the selected filters
    filteredItems = items.where((item) {
      // Check conditions based on selected filters
      var codeMatch = item.itemCode.contains(codeFilterController.text);
      var groupMatch = item.groupCode.contains(groupFilterController.text);
      var brandMatch = item.brand.contains(brandFilterController.text);
      var itemNameMatch = item.itemName.contains(itemNameFilterController.text);
      var categoryMatch = item.categCode.contains(categoryFilterController.text);

      // Return true if all conditions are met, otherwise return false
      return codeMatch && groupMatch && brandMatch && itemNameMatch && categoryMatch;
    }).toList();

    setState(() {
      // No need to update the items list here
    });
  }
Future<String> scanBarcode() async {
  try {
    ScanResult result = await BarcodeScanner.scan();
    String barcode = result.rawContent;
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

