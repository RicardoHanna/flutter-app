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
import 'package:project/hive/companiesusers_hive.dart';
import 'package:project/hive/hiveuser.dart';
import 'package:project/hive/items_hive.dart';
import 'package:project/hive/pricelist_hive.dart';
import 'package:project/hive/pricelistauthorization_hive.dart';
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
  final String usercode;
  final String defltCompanyCode;


  PriceLists({required this.appNotifier,required this.usercode,required this.defltCompanyCode});

  @override
  State<PriceLists> createState() => _PriceListsState();
}

class _PriceListsState extends State<PriceLists> {
 late List<PriceList> prices;
 TextEditingController searchController = TextEditingController();
  late List<PriceList> filteredPrices=[];

late List<String> priceCodeList = [];
  late List<String> priceNameList = [];
  late List<String> securityGroupList= [];
  late List<String> selectedPriceCode = [];
  late List<String> selectedPriceName = [];
  late List<String> selectedSecurityGroup = [];
   late String selectedSortingOption = 'Alphabetic';
  late Box<PriceList> pricelistBox;

TextStyle _appTextStyle=TextStyle();
final TextEditingController codeFilterController = TextEditingController();
  final TextEditingController groupFilterController = TextEditingController();
  final TextEditingController priceNameFilterController = TextEditingController();

  @override
  void initState() {
    super.initState();
         pricelistBox = Hive.box<PriceList>('pricelists');
    initializeData();
   select();
    
  }

Future<void> select() async {
  print('hisss');
  var authBox = await Hive.openBox<PriceList>('pricelists');
  var o = authBox.values.toList();
  print('dsdsdsd');
  print(o);
  for (var l in o) {
    print('hiii');
    print(l.cmpCode + l.authoGroup);
  }
}

  Future<void> initializeData() async {
  //  await insertSamplePriceLists();
    prices=await _getPriceLists(widget.usercode);
    filteredPrices = List.from(prices);

    priceCodeList = await getDistinctValuesFromBox('plCode', pricelistBox);
    priceNameList = await getDistinctValuesFromBox('plName', pricelistBox);
    securityGroupList = await getDistinctValuesFromBox('securityGroup', pricelistBox);
  }

  
  Future<List<String>> getDistinctValuesFromBox(String fieldName, Box<PriceList> box) async {
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
dynamic getField(PriceList item, String fieldName) {
    switch (fieldName) {
      case 'plCode':
        return item.plCode;
      case 'plName':
        return item.plName;

      // Add cases for other fields as needed
      default:
        return null;
    }
  }



Future<List<PriceList>> _getPriceLists(String usercode) async {
  // Open both boxes
var compusers = await Hive.openBox<CompaniesUsers>('companiesUsersBox');
  var authBox = await Hive.openBox<PriceListAuthorization>('pricelistAuthorizationBox');
  var priceListsBox = await Hive.openBox<PriceList>('pricelists');

 var user = compusers.values.firstWhere(
    (user) => user.userCode == widget.usercode,
  );
 var defaultCmpCode='';
  if (user != null) {
    defaultCmpCode= user.defaultcmpCode;
  }
  // Retrieve authoGroup value based on usercode
  var authorizations = authBox.values.where(
    (auth) => auth.userCode == usercode && auth.cmpCode==defaultCmpCode,
  ).toList();

  if (authorizations.isNotEmpty) {
    // Use authoGroup to filter priceLists
    var filteredPriceLists = <PriceList>[];
    for (var authorization in authorizations) {
      filteredPriceLists.addAll(priceListsBox.values.where(
        (priceList) => priceList.authoGroup == authorization.authoGroup && priceList.cmpCode==defaultCmpCode,
      ));
    }

    return filteredPriceLists;
  } else {
    // Handle the case where no authorization is found for the given usercode
    return [];
  }
}



    void _applySorting() {
    switch (selectedSortingOption) {
      case 'PLCode':
        filteredPrices.sort((a, b) => a.plCode!.compareTo(b.plCode!));
        break;
      case 'Alphabetic':
        filteredPrices.sort((a, b) => a.plName!.compareTo(b.plName!));
        break;
    }

    setState(() {
      // Update the UI with the sorted items
    });
  }

  @override
  Widget build(BuildContext context) {
     TextStyle   _appTextStyle = TextStyle(fontSize:widget.appNotifier.fontSize.toDouble());
        TextStyle   _appTextStyleAppBar = TextStyle(fontSize:widget.appNotifier.fontSize.toDouble());
    return Scaffold(
     appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.pricelists,style: _appTextStyleAppBar,),
        actions: [
          // Search Icon
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: DataSearchPriceLists(pricesList: prices, appNotifier:widget.appNotifier));
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
                value: 'SecurityGroup',
                child: Text(AppLocalizations.of(context)!.sortbysecurity,style: _appTextStyle,),
              ),
              PopupMenuItem<String>(
                value: 'Alphabetic',
                child: Text(AppLocalizations.of(context)!.sortalphabetic,style: _appTextStyle,),
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
        child: FutureBuilder<List<PriceList>>(
          future: _getPriceLists(widget.usercode),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('No price lists found');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('No price lists found');
            } else {
              return ListView.builder(
                itemCount:filteredPrices.length,
                itemBuilder: (context, index) {
                  var priceList = filteredPrices[index];
                  return Card(
                    child: ListTile(
                      title: Text(priceList.plCode ?? '',style: _appTextStyle,),
                      subtitle: Text(priceList.plName ?? '',style: _appTextStyle,),
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

 void _showFilterDialog(BuildContext context) {
  TextStyle _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.filterpricelists, style: _appTextStyle,),
            content: SingleChildScrollView( // Wrap the Column with SingleChildScrollView
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMultiSelectChip(AppLocalizations.of(context)!.plcode, priceCodeList, selectedPriceCode, setState),
                  _buildMultiSelectChip(AppLocalizations.of(context)!.pricelistname, priceNameList, selectedPriceName, setState),
                  _buildMultiSelectChip(AppLocalizations.of(context)!.securitygroup, securityGroupList, selectedSecurityGroup, setState),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context)!.cancel, style: _appTextStyle,),
              ),
              TextButton(
                onPressed: () {
                  _applyFilters();
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context)!.apply, style: _appTextStyle,),
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
    filteredPrices = prices.where((price) {

      var pricecodeMatch = selectedPriceCode.isEmpty || selectedPriceCode.contains(price.plCode);
      var pricenameMatch = selectedPriceName.isEmpty || selectedPriceName.contains(price.plName);


      return pricecodeMatch && pricenameMatch;
    }).toList();

    setState(() {
      // Update the UI with the filtered items
    });
  }

}
