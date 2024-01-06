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


late List<String> itemCodeList = [];
  late List<String> uomList = [];
 
  late List<String> selectedItemCode= [];
  late List<String> selectedUOM = [];

   late String selectedSortingOption = 'Price';
  late Box<ItemsPrices> itemspriceBox;

  final TextEditingController codeFilterController = TextEditingController();
  final TextEditingController uomFilterController = TextEditingController();
  final TextEditingController itemCodeFilterController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
     itemspriceBox = Hive.box<ItemsPrices>('itemprices');
    initializeData();
    printUserDataTranslations();
  }

Future<void> printUserDataTranslations() async {
 var itemsBox = await Hive.openBox<ItemsPrices>('itemprices');
    
    print('Printing Users:');
    for (var item in itemsBox.values) {
      print('Username: ${item.plCode}');
      print('Email: ${item.price}');
      
      print('-------------------------');
    }
  // Open 'translationsBox' for Translations

  print('Printed all data');


}
  Future<void> initializeData() async {
   // await insertSamplePriceLists();
    pricesitems = await _getItemsPrices();
    filteredPrices = List.from(pricesitems);

     itemCodeList = await getDistinctValuesFromBox('itemCode', itemspriceBox);
    uomList = await getDistinctValuesFromBox('uom', itemspriceBox);
   

       filterItems(); // Initial filter
       _getFilteredItemsPrices();

  }

  
  Future<List<String>> getDistinctValuesFromBox(String fieldName, Box<ItemsPrices> box) async {
    var distinctValues = <String>[];
    var distinctSet = <String>{};

    for (var item in box.values) {
      var value = getField(item, fieldName);
      if (value != null && distinctSet.add(value)) {
        distinctValues.add(value);
      }
    }

    return distinctValues;
  }
dynamic getField(ItemsPrices item, String fieldName) {
    switch (fieldName) {
      case 'itemCode':
        return item.itemCode;
      case 'uom':
        return item.uom;
      // Add cases for other fields as needed
      default:
        return null;
    }
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
  var itemPrices1 = ItemsPrices('PL001', '003', 'Piece', 100.0, 'USD', true, 10.0, 200.0);
  var itemPrices2 = ItemsPrices('PL002', '002', 'Piece', 130.0, 'EUR', false, 12.0, 270.0);
  var itemPrices3 = ItemsPrices('PL001', '001', 'lop', 149.0, 'USD', true, 14.0, 290.0);
  var itemPrices4 = ItemsPrices('PL002', '002', 'lop', 140.0, 'USD', true, 14.0, 240.0);
 
 // await itempricesBox.add( itemPrices1);
//await itempricesBox.add(itemPrices3);
////await itempricesBox.add(itemPrices4);




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
         TextStyle   _appTextStyle = TextStyle(fontSize:widget.appNotifier.fontSize.toDouble());
                  TextStyle   _appTextStyleAppBar = TextStyle(fontSize:widget.appNotifier.fontSize.toDouble());
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.itemprices+widget.priceList.plName,style: _appTextStyleAppBar,),
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

              PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                selectedSortingOption = value;
                _applySorting();
              });
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'PLCode',
                child: Text(AppLocalizations.of(context)!.sortbycode,style: _appTextStyle,),
              ),
              PopupMenuItem<String>(
                value: 'ItemCode',
                child: Text(AppLocalizations.of(context)!.sortbyitem,style: _appTextStyle,),
              ),
              PopupMenuItem<String>(
                value: 'Price',
                child: Text(AppLocalizations.of(context)!.sortbyprice,style: _appTextStyle,),
              ),
            ],
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
                title: Text(itemsPrices.itemCode ?? '',style: _appTextStyle,),
                subtitle: Text(itemsPrices.uom ?? '',style: _appTextStyle,),
                trailing: Text(itemsPrices.price.toString(),style: _appTextStyle,),
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

    void _applySorting() {
    switch (selectedSortingOption) {
      case 'PLCode':
        filteredPrices.sort((a, b) => a.plCode!.compareTo(b.plCode!));
        break;
      case 'ItemCode':
        filteredPrices.sort((a, b) => a.itemCode!.compareTo(b.itemCode!));
        break;
      case 'Price':
        filteredPrices.sort((a, b) => a.price!.compareTo(b.price!));
        break;
    }

    setState(() {
      // Update the UI with the sorted items
    });
  }

  void _showFilterDialog(BuildContext context) {
       TextStyle   _appTextStyle = TextStyle(fontSize:widget.appNotifier.fontSize.toDouble());
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.filteritems,style: _appTextStyle,),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMultiSelectChip('Item Code', itemCodeList, selectedItemCode, setState),
                  _buildMultiSelectChip('UOM', uomList, selectedUOM, setState),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.apply,style:_appTextStyle,),
                ),
                TextButton(
                  onPressed: () {
                    _applyFilters();
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.cancel,style: _appTextStyle,),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMultiSelectChip(
    String label,
    List<String> options,
    List<String> selectedValues,
    Function(void Function()) setStateCallback,
  ) {
       TextStyle   _appTextStyle = TextStyle(fontSize:widget.appNotifier.fontSize.toDouble()-6);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,style: _appTextStyle,),
        Wrap(
          spacing: 8.0,
          children: options.map((option) {
            final isSelected = selectedValues.contains(option);
            return FilterChip(
              label: Text(option,style: _appTextStyle,),
              selected: isSelected,
              onSelected: (bool selected) {
                setStateCallback(() {
                  if (selected) {
                    selectedValues.add(option);
                  } else {
                    selectedValues.remove(option);
                  }
                });
              },
              backgroundColor: isSelected ? Colors.blue : null,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight: isSelected ? FontWeight.bold : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

void _applyFilters() {
    filteredPrices = pricesitems.where((price) {

      var itemcodeMatch = selectedItemCode.isEmpty || selectedItemCode.contains(price.itemCode);
      var uomMatch = selectedUOM.isEmpty || selectedUOM.contains(price.uom);


      return itemcodeMatch && uomMatch;
    }).toList();

    setState(() {
      // Update the UI with the filtered items
    });
  }

}