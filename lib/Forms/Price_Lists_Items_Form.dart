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
import 'package:project/Forms/Price_Items_Info_Form.dart';
import 'package:project/app_notifier.dart';
import 'package:project/classes/DataSearchPriceListsItems.dart';
import 'package:project/hive/hiveuser.dart';
import 'package:project/hive/items_hive.dart';
import 'package:project/hive/itemsprices_hive.dart';
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

class PriceListsItems extends StatefulWidget {
  final AppNotifier appNotifier;
  final PriceList priceList;
  PriceListsItems({required this.appNotifier, required this.priceList});

  @override
  State<PriceListsItems> createState() => _PriceListsItemsState();
}

class _PriceListsItemsState extends State<PriceListsItems> {
  late List<ItemsPrices> pricesitems;
  late List<ItemsPrices> filteredPrices=[];


  final TextEditingController codeFilterController = TextEditingController();
  final TextEditingController uomFilterController = TextEditingController();
  final TextEditingController itemCodeFilterController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    //await insertSamplePriceLists();
    pricesitems = await _getItemsPrices();
    filteredPrices = List.from(pricesitems);
       filterItems(); // Initial filter

  }

  Future<List<ItemsPrices>> _getFilteredItemsPrices() async {
    var itempricesBox = await Hive.openBox<ItemsPrices>('itemprices');
    var filteredItemsPrices = itempricesBox.values
        .where((itemPrices) => itemPrices.plCode == widget.priceList.plCode)
        .toList();
        
    return filteredItemsPrices;
  }

  Future<void> insertSamplePriceLists() async {
  var itempricesBox = await Hive.openBox<ItemsPrices>('itemprices');

  // Insert sample data
  var itemPrices1 = ItemsPrices('PL001', '001', 'Piece', 100.0, 'USD', true, 10.0, 200.0);
  var itemPrices2 = ItemsPrices('PL002', '002', 'Piece', 130.0, 'EUR', false, 12.0, 270.0);
  var itemPrices3 = ItemsPrices('PL001', '001', 'lop', 140.0, 'USD', true, 14.0, 240.0);
  var itemPrices4 = ItemsPrices('PL002', '002', 'lop', 140.0, 'USD', true, 14.0, 240.0);
  await itempricesBox.put(itemPrices1.plCode, itemPrices1);
  await itempricesBox.put(itemPrices2.plCode, itemPrices2);
//await itempricesBox.add(itemPrices3);
//await itempricesBox.add(itemPrices4);

}

  Future<List<ItemsPrices>> _getItemsPrices() async {
    var itempricesBox = await Hive.openBox<ItemsPrices>('itemprices');
    var allItemPrices = itempricesBox.values.toList();

    return allItemPrices;
  }
void filterItems() {
    filteredPrices = pricesitems
        .where((price) =>
            price.plCode == widget.priceList.plCode &&
            price.itemCode.contains(itemCodeFilterController.text) &&
            price.uom.contains(uomFilterController.text))
        .toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item Prices for ${widget.priceList.plName}'),
        actions: [
          // Search Icon
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: DataSearchPriceListsItems(
                  pricesitemsList: pricesitems,
                  appNotifier: widget.appNotifier,
                  plCode: widget.priceList.plCode,
                ),
              );
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
        child: ListView.builder(
          itemCount: filteredPrices.length,
          itemBuilder: (context, index) {
            var itemsPrices = filteredPrices[index];
            return Card(
              child: ListTile(
                title: Text(itemsPrices.itemCode ?? ''),
                subtitle: Text(itemsPrices.uom ?? ''),
                trailing: Text(itemsPrices.price.toString()),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PriceItemsInfo(itemsPrices: itemsPrices, appNotifier: widget.appNotifier),
                    ),
                  );
                },
              ),
            );
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
              // Your filter fields here
              TextFormField(
                controller: itemCodeFilterController,
                decoration: InputDecoration(labelText: 'Item Code'),
              ),
              TextFormField(
                controller: uomFilterController,
                decoration: InputDecoration(labelText: 'UOM'),
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
                filterItems(); // Apply the filters
                Navigator.pop(context);
              },
              child: Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}