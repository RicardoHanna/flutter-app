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
import 'package:project/Forms/Price_Lists_Items_Form.dart';
import 'package:project/app_notifier.dart';
import 'package:project/classes/DataSearchPriceLists.dart';
import 'package:project/hive/hiveuser.dart';
import 'package:project/hive/items_hive.dart';
import 'package:project/hive/pricelist_hive.dart';
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

class PriceLists extends StatefulWidget {
  final AppNotifier appNotifier;

  PriceLists({required this.appNotifier});

  @override
  State<PriceLists> createState() => _PriceListsState();
}

class _PriceListsState extends State<PriceLists> {
 late List<PriceList> prices;
 TextEditingController searchController = TextEditingController();
  late List<PriceList> filteredPrices=[];

final TextEditingController codeFilterController = TextEditingController();
  final TextEditingController groupFilterController = TextEditingController();
  final TextEditingController priceNameFilterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
  //  await insertSamplePriceLists();
    prices=await _getPriceLists();
    filteredPrices = List.from(prices);
  }

  Future<void> insertSamplePriceLists() async {
  var priceListsBox = await Hive.openBox<PriceList>('pricelists');

  // Insert sample data
  var priceList1 = PriceList('PL001', 'Price List 1', 'USD', 100.0, 1.0, true, 'Group1');
  var priceList2 = PriceList('PL002', 'Price List 2', 'EUR', 150.0, 1.2, false, 'Group2');
  var priceList3 = PriceList('PL001', 'Price List 1', 'EUR', 150.0, 1.2, false, 'Group2');
  await priceListsBox.put(priceList1.plCode, priceList1);
  await priceListsBox.put(priceList2.plCode, priceList2);

  // Close the box when done
 
}

  Future<List<PriceList>> _getPriceLists() async {
    var priceListsBox = await Hive.openBox<PriceList>('pricelists');
    var allPriceLists = priceListsBox.values.toList();
   
    return allPriceLists;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        title: Text('Price Lists'),
        actions: [
          // Search Icon
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: DataSearchPriceLists(pricesList: prices, appNotifier:widget.appNotifier));
            },
          ),
          // Filter Icon
          IconButton(
      icon: Icon(Icons.filter_list),
      onPressed: () {
        _showFilterDialog(context);
      },
    ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<PriceList>>(
          future: _getPriceLists(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('No price lists found');
            } else {
              return ListView.builder(
                itemCount:filteredPrices.length,
                itemBuilder: (context, index) {
                  var priceList = filteredPrices[index];
                  return Card(
                    child: ListTile(
                      title: Text(priceList.plCode ?? ''),
                      subtitle: Text(priceList.plName ?? ''),
                      onTap: () {
                        // Navigate to the PriceListInfoForm page and pass the selected price list
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PriceListsItems(priceList: priceList,appNotifier: widget.appNotifier,),
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
                decoration: InputDecoration(labelText: 'Price Code'),
              ),
              TextFormField(
                controller: priceNameFilterController,
                decoration: InputDecoration(labelText: 'Price Name'),
              ),
              TextFormField(
                controller: groupFilterController,
                decoration: InputDecoration(labelText: 'Security Group'),
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
    filteredPrices = prices.where((price) {
      // Check conditions based on selected filters
      var codeMatch = price.plCode.contains(codeFilterController.text);
      var itemNameMatch = price.plName.contains(priceNameFilterController.text);
      var groupMatch = price.securityGroup.contains(groupFilterController.text);
     

      // Return true if all conditions are met, otherwise return false
      return codeMatch && itemNameMatch && groupMatch;
    }).toList();

    setState(() {
      // No need to update the items list here
    });
  }

}
