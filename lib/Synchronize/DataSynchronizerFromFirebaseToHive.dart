import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:project/classes/PriceItemKey.dart';
import 'package:project/hive/adminsubmenu_hive.dart';
import 'package:project/hive/authorization_hive.dart';
import 'package:project/hive/companies_hive.dart';
import 'package:project/hive/companiesconnection_hive.dart';
import 'package:project/hive/companiesusers_hive.dart';
import 'package:project/hive/currencies_hive.dart';
import 'package:project/hive/custgroups_hive.dart';
import 'package:project/hive/customeraddresses_hive.dart';
import 'package:project/hive/customerattachments_hive.dart';
import 'package:project/hive/customerbrandsspecialprice_hive.dart';
import 'package:project/hive/customercategspecialprice_hive.dart';
import 'package:project/hive/customercontacts_hive.dart';
import 'package:project/hive/customergroupbrandspecialprice_hive.dart';
import 'package:project/hive/customergroupcategspecialprice_hive.dart';
import 'package:project/hive/customergroupgroupspecialprice_hive.dart';
import 'package:project/hive/customergroupitemsspecialprice_hive.dart';
import 'package:project/hive/customergroupsspecialprice_hive.dart';
import 'package:project/hive/customeritemsspecialprice_hive.dart';
import 'package:project/hive/customerpropbrandspecialprice_hive.dart';
import 'package:project/hive/customerpropcategspecialprice_hive.dart';
import 'package:project/hive/customerproperties_hive.dart';
import 'package:project/hive/customerpropgroupspecialprice_hive.dart';
import 'package:project/hive/customerpropitemsspecialprice_hive.dart';
import 'package:project/hive/customers_hive.dart';
import 'package:project/hive/custproperties_hive.dart';
import 'package:project/hive/departements_hive.dart';
import 'package:project/hive/exchangerate_hive.dart';
import 'package:project/hive/itembrand_hive.dart';
import 'package:project/hive/itemcateg_hive.dart';
import 'package:project/hive/itemgroup_hive.dart';
import 'package:project/hive/items_hive.dart';
import 'package:project/hive/itemsprices_hive.dart';
import 'package:project/hive/itemattach_hive.dart';
import 'package:project/hive/itemuom_hive.dart';
import 'package:project/hive/menu_hive.dart';
import 'package:project/hive/paymentterms_hive.dart';
import 'package:project/hive/pricelist_hive.dart';
import 'package:project/hive/pricelistauthorization_hive.dart';
import 'package:project/hive/regions_hive.dart';
import 'package:project/hive/salesemployees_hive.dart';
import 'package:project/hive/salesemployeescustomers_hive.dart';
import 'package:project/hive/salesemployeesdepartments_hive.dart';
import 'package:project/hive/salesemployeesitems_hive.dart';
import 'package:project/hive/salesemployeesitemsbrands_hive.dart';
import 'package:project/hive/salesemployeesitemscategories_hive.dart';
import 'package:project/hive/salesemployeesitemsgroups_hive.dart';
import 'package:project/hive/syncronizesubmenu_hive.dart';
import 'package:project/hive/systemadmin_hive.dart';
import 'package:project/hive/translations_hive.dart';
import 'package:project/hive/usergroup_hive.dart';
import 'package:project/hive/userpl_hive.dart';
import 'package:project/hive/hiveuser.dart';
import 'package:project/hive/userssalesemployees_hive.dart';
import 'package:project/hive/vatgroups_hive.dart';
import 'package:project/hive/warehouses_hive.dart';
import 'package:http/http.dart' as http; 

class DataSynchronizerFromFirebaseToHive {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
String apiurl='http://5.189.188.139/api/';

Future<List<String>> retrieveSeCodes(String usercode) async {
  List<String> seCodes = [];
  try {
    // Send HTTP GET request to fetch seCodes from the server
    final response = await http.get(Uri.parse('${apiurl}getSeCodes?usercode=$usercode'));
    if (response.statusCode == 200) {
      // Parse response body and extract seCodes
      // Adjust this part based on your server's response format
      String seCode = response.body;
      seCodes.add(seCode); // Wrap the single value in a list
    } else {
      print('Failed to retrieve seCodes: ${response.statusCode}');
    }
  } catch (e) {
    print('Error retrieving seCodes: $e');
  }
  return seCodes;
}

  
Future<List<String>> retrieveItemCodes(List<String> seCodes) async {
  List<String> itemCodes = [];
  try {
    for (String seCode in seCodes) {
      // Send HTTP GET request to fetch item codes from the server
      final response = await http.get(Uri.parse('${apiurl}getSalesItems?seCode=$seCode'));
      if (response.statusCode == 200) {
        // Parse response body using jsonDecode
        List<dynamic> responseData = jsonDecode(response.body);
        // Extract item codes from each object
        for (var data in responseData) {
          itemCodes.add(data['itemCode']);
        }
      } else {
        print('Failed to retrieve item codes: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error retrieving item codes: $e');
  }
  return itemCodes;
}

Future<List<Map<String, dynamic>>> _fetchItemsData(List<String> itemCodes) async {
  List<Map<String, dynamic>> itemsData = [];
  try {
    for (String itemCode in itemCodes) {
      final response = await http.get(Uri.parse('${apiurl}getItems?itemCode=$itemCode'));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        if (responseData is List) {
          // If the response is a list, append each item to the itemsData list
          for (var item in responseData) {
            if (item is Map<String, dynamic>) {
              itemsData.add(item);
            }
          }
        } else if (responseData is Map<String, dynamic>) {
          // If the response is a map, directly append it to the itemsData list
          itemsData.add(responseData);
        } else {
          print('Invalid response format for item code $itemCode');
        }
      } else {
        print('Failed to retrieve item details for item code $itemCode: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error fetching item data: $e');
  }
  return itemsData;
}


   Future<void> synchronizeData(List<String> itemCodes) async {
    try {
      // Open Hive boxes
      var itemsBox = await Hive.openBox<Items>('items');
      // Open other boxes if needed

      // Fetch data from API endpoints
      List <dynamic> itemsData = await _fetchItemsData(itemCodes);

      // Synchronize data
      await _synchronizeItems(itemsData, itemsBox);
      // Synchronize other data if needed

      
      // Close other boxes if needed
    } catch (e) {
      print('Error synchronizing data from API to Hive: $e');
    }
  }

  Future<void> _synchronizeItems(List<dynamic> itemsData, Box<Items> itemsBox) async {
    try {
      for (var data in itemsData) {
        var itemCode = data['itemCode'];
        var hiveItem = itemsBox.get(itemCode);

        if (hiveItem == null) {
          var newItem = Items(
            data['itemCode'],
            data['itemName'],
            data['itemPrName'],
            data['itemFName'],
            data['itemPrFName'],
            data['groupCode'],
            data['categCode'],
            data['brandCode'],
            data['itemType'],
            data['barCode'],
            data['uom'],
            data['picture'],
            data['remark'],
            data['brand'],
            data['manageBy'],
            data['vatRate'].toDouble(),
            data['active']==1,
            data['weight'].toDouble(),
            data['charect1'],
            data['charact2'],
            data['cmpCode']
          );
          await itemsBox.put(itemCode, newItem);
        } else {
          var updatedItem = Items(
            data['itemCode'],
            data['itemName'],
            data['itemPrName'],
            data['itemFName'],
            data['itemPrFName'],
            data['groupCode'],
            data['categCode'],
            data['brandCode'],
            data['itemType'],
            data['barCode'],
            data['uom'],
            data['picture'],
            data['remark'],
            data['brand'],
            data['manageBy'],
            data['vatRate'].toDouble(),
            data['active']==1,
            data['weight'].toDouble(),
            data['charect1'],
            data['charact2'],
            data['cmpCode']
          );
          await itemsBox.put(itemCode, updatedItem);
        }
      }

      itemsBox.keys.toList().forEach((hiveItemCode) {
          if (!itemsData.any((data) => data['itemCode'] == hiveItemCode)) {
            itemsBox.delete(hiveItemCode);
          }
        });

    } catch (e) {
      print('Error synchronizing items from API to Hive: $e');
    }
  }




//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<List<String>> retrievePriceList(List<String> itemCodes) async {
  List<String> priceLists = [];
  try {
    for (String itemCode in itemCodes) {
      final response = await http.get(Uri.parse('${apiurl}getItemPrice?itemCode=$itemCode'));
      if (response.statusCode == 200) {
        List<dynamic> responseData = jsonDecode(response.body);
        for (var data in responseData) {
          priceLists.add(data['plCode']);
        }
      } else {
        print('Failed to retrieve price list Codes for item code $itemCode: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error retrieving price list Codes: $e');
  }
  return priceLists;
}
Future<List<Map<String, dynamic>>> _fetchPriceListData(List<String> priceLists) async {
  List<Map<String, dynamic>> priceListData = [];
  try {
    for (String plCode in priceLists) {
      final response = await http.get(Uri.parse('${apiurl}getPriceList?plCode=$plCode'));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        if (responseData is List) {
          // If the response is a list, append each item to the priceListData list
          for (var item in responseData) {
            if (item is Map<String, dynamic>) {
              priceListData.add(item);
            }
          }
        } else if (responseData is Map<String, dynamic>) {
          // If the response is a map, directly append it to the priceListData list
          priceListData.add(responseData);
        } else {
          print('Invalid response format for plCode $plCode');
        }
      } else {
        print('Failed to retrieve price list data for plCode $plCode: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error fetching price list data: $e');
  }
  return priceListData;
}


Future<void> synchronizeDataPriceLists(List<String> priceLists) async {
  try {
    // Open Hive boxes
    var pricelistsBox = await Hive.openBox<PriceList>('pricelists');
    // Open other boxes if needed

    // Fetch data from API endpoints
    List<Map<String, dynamic>> priceListData = await _fetchPriceListData(priceLists);

    // Synchronize data
    await _synchronizePriceList(priceListData, pricelistsBox);
    // Synchronize other data if needed

    // Close Hive boxes
    // await pricelistsBox.close();
    // Close other boxes if needed
  } catch (e) {
    print('Error synchronizing data from API to Hive: $e');
  }
}

Future<void> _synchronizePriceList(
  List<Map<String, dynamic>> priceListData,
  Box<PriceList> pricelistsBox,
) async {
  try {
    for (var data in priceListData) {
      var plCode = data['plCode'];
      var hivePrice = pricelistsBox.get(plCode);

      if (hivePrice == null) {
        var newPrice = PriceList(
          data['plCode'],
          data['plName'],
          data['currency'],
          data['basePL'],
          data['factor'].toDouble(),
          data['incVAT']==1,
          data['securityGroup'],
          data['cmpCode'],
          data['authoGroup']
        );
        await pricelistsBox.put(plCode, newPrice);
      } else {
        var updatedPrice = PriceList(
          data['plCode'],
          data['plName'],
          data['currency'],
          data['basePL'],
          data['factor'].toDouble(),
          data['incVAT']==1,
          data['securityGroup'],
          data['cmpCode'],
          data['authoGroup']
        );
        await pricelistsBox.put(plCode, updatedPrice);
      }
    }

    // Check for price lists in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedPriceCodes = Set.from(priceListData.map((data) => data['plCode']));
    Set<String> hivePriceCodes = Set.from(pricelistsBox.keys);

    // Identify price lists in Hive that don't exist in the fetched data
    Set<String> priceListsToDelete = hivePriceCodes.difference(fetchedPriceCodes);

    // Delete price lists in Hive that don't exist in the fetched data
    priceListsToDelete.forEach((hivePriceCode) {
      pricelistsBox.delete(hivePriceCode);
    });
  } catch (e) {
    print('Error synchronizing PriceLists from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<List<Map<String, dynamic>>> _fetchItemPricesData(List<String> itemCodes) async {
  List<Map<String, dynamic>> itemPricesData = [];
  try {
    for (String itemCode in itemCodes) {
      final response = await http.get(Uri.parse('${apiurl}getItemPrice?itemCode=$itemCode'));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        if (responseData is List) {
          // If the response is a list, append each item price to the itemPricesData list
          for (var itemPrice in responseData) {
            if (itemPrice is Map<String, dynamic>) {
              itemPricesData.add(itemPrice);
            }
          }
        } else if (responseData is Map<String, dynamic>) {
          // If the response is a map, directly append it to the itemPricesData list
          itemPricesData.add(responseData);
        } else {
          print('Invalid response format for item code $itemCode');
        }
      } else {
        print('Failed to retrieve item prices for item code $itemCode: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error fetching item prices data: $e');
  }
  return itemPricesData;
}

Future<void> synchronizeDataItemPrice(List<String> itemCodes) async {
  try {
    // Open Hive boxes
    var itempriceBox = await Hive.openBox<ItemsPrices>('itemprices');
    // Open other boxes if needed

    // Fetch data from API endpoints
    List<Map<String, dynamic>> itemPricesData = await _fetchItemPricesData(itemCodes);

    // Synchronize data
    await _synchronizeItemPrice(itemPricesData, itempriceBox);
    // Synchronize other data if needed

    // Close Hive boxes
    // await itempriceBox.close();
    // Close other boxes if needed
  } catch (e) {
    print('Error synchronizing data from API to Hive: $e');
  }
}

Future<void> _synchronizeItemPrice(
  List<Map<String, dynamic>> itemPricesData,
  Box<ItemsPrices> itempriceBox,
) async {
  try {
    for (var data in itemPricesData) {
      var plCode = data['plCode'];
      var itemCode = data['itemCode'];

      var hivePriceItem = itempriceBox.get('$plCode$itemCode');

      if (hivePriceItem == null) {
        var newPriceItem = ItemsPrices(
          plCode,
          itemCode,
          data['uom'],
          data['basePrice'].toDouble(),
          data['currency'],
          data['auto']==1,
          data['disc'].toDouble(),
          data['price'].toDouble(),
          data['cmpCode']
        );
        await itempriceBox.put('$plCode$itemCode', newPriceItem);
      } else {
        var updatedPriceItem = ItemsPrices(
          plCode,
          itemCode,
          data['uom'],
          data['basePrice'].toDouble(),
          data['currency'],
          data['auto']==1,
          data['disc'].toDouble(),
          data['price'].toDouble(),
          data['cmpCode']
        );
        await itempriceBox.put('$plCode$itemCode', updatedPriceItem);
      }
    }

    // Check for price items in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedPriceItemKeys = Set.from(itemPricesData.map((data) => '${data['plCode']}${data['itemCode']}'));
    Set<String> hivePriceItemKeys = Set.from(itempriceBox.keys);

    // Identify price items in Hive that don't exist in the fetched data
    Set<String> priceItemsToDelete = hivePriceItemKeys.difference(fetchedPriceItemKeys);

    // Delete price items in Hive that don't exist in the fetched data
    priceItemsToDelete.forEach((hivePriceItemKey) {
      itempriceBox.delete(hivePriceItemKey);
    });
  } catch (e) {
    print('Error synchronizing ItemPrices from API to Hive: $e');
  }
}


//---------------------------------------

Future<List<Map<String, dynamic>>> _fetchItemAttachData(List<String> itemCodes) async {
  List<Map<String, dynamic>> itemAttachData = [];
  try {
    for (String itemCode in itemCodes) {
      final response = await http.get(Uri.parse('${apiurl}getItemAttach?itemCode=$itemCode'));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        if (responseData is List) {
          // If the response is a list, append each item attach data to the itemAttachData list
          for (var itemAttach in responseData) {
            if (itemAttach is Map<String, dynamic>) {
              itemAttachData.add(itemAttach);
            }
          }
        } else if (responseData is Map<String, dynamic>) {
          // If the response is a map, directly append it to the itemAttachData list
          itemAttachData.add(responseData);
        } else {
          print('Invalid response format for item code $itemCode');
        }
      } else {
        print('Failed to retrieve item attach for item code $itemCode: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error fetching item attach data: $e');
  }
  return itemAttachData;
}


Future<void> synchronizeDataItemAttach(List<String> itemCodes) async {
  try {
    // Fetch data from API endpoints
    List<Map<String, dynamic>> apiResponse = await _fetchItemAttachData(itemCodes);

    // Open Hive boxes
    var itemattachBox = await Hive.openBox<ItemAttach>('itemattach');
    // Open other boxes if needed

    // Synchronize data
    await _synchronizeItemAttach(apiResponse, itemattachBox);
    // Synchronize other data if needed

    // Close Hive boxes
    // await itemattachBox.close();
    // Close other boxes if needed
  } catch (e) {
    print('Error synchronizing data from API to Hive: $e');
  }
}


Future<void> _synchronizeItemAttach(
  List<Map<String, dynamic>> itemAttachData,
  Box<ItemAttach> itemattachBox,
) async {
  try {
    for (var data in itemAttachData) {
      var itemCode = data['itemCode'];

      var hiveAttachItem = itemattachBox.get(itemCode);

      if (hiveAttachItem == null) {
        var newAttachItem = ItemAttach(
          data['itemCode'],
          data['attachmentType'],
          data['attachmentPath'],
          data['note'],
          data['cmpCode']
        );
        await itemattachBox.put(itemCode, newAttachItem);
      } else {
        var updatedAttachItem = ItemAttach(
          data['itemCode'],
          data['attachmentType'],
          data['attachmentPath'],
          data['note'],
          data['cmpCode']
        );
        await itemattachBox.put(itemCode, updatedAttachItem);
      }
    }

    // Check for items in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedItemAttachCodes = Set.from(itemAttachData.map((data) => data['itemCode']));
    Set<String> hiveItemAttachCodes = Set.from(itemattachBox.keys);

    // Identify items in Hive that don't exist in the fetched data
    Set<String> itemsToDelete = hiveItemAttachCodes.difference(fetchedItemAttachCodes);

    // Delete items in Hive that don't exist in the fetched data
    itemsToDelete.forEach((hiveItemAttachCode) {
      itemattachBox.delete(hiveItemAttachCode);
    });
  } catch (e) {
    print('Error synchronizing ItemAttach from API to Hive: $e');
  }
}



//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

 Future<List<String>> retrieveItemGroupCodes(List<String> seCodes) async {
  List<String> itemGroupCodes = [];
  try {
    for (String seCode in seCodes) {
      // Make API call to retrieve item group codes for the given sales employee code
      var response = await http.get(Uri.parse('${apiurl}getSalesEmployeesItemsGroups?seCode=$seCode'));
      if (response.statusCode == 200) {
        // Parse the response data
        dynamic responseData = jsonDecode(response.body);
        if (responseData is List) {
          for (var item in responseData) {
            if (item is Map<String, dynamic>) {
              itemGroupCodes.add(item['groupCode']);
            }
          }
        } else {
          print('Invalid response format for item group codes');
        }
      } else {
        print('Failed to retrieve item group codes: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error retrieving item group codes: $e');
  }
  return itemGroupCodes;
}


  Future<List<Map<String, dynamic>>> _fetchItemGroupData(List<String> itemGroupCodes) async {
  List<Map<String, dynamic>> itemGroupData = [];
  try {
    for (String groupCode in itemGroupCodes) {
      final response = await http.get(Uri.parse('${apiurl}getItemGroup?groupCode=$groupCode'));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        if (responseData is List) {
          // If the response is a list, append each item group data to the itemGroupData list
          for (var itemGroup in responseData) {
            if (itemGroup is Map<String, dynamic>) {
              itemGroupData.add(itemGroup);
            }
          }
        } else if (responseData is Map<String, dynamic>) {
          // If the response is a map, directly append it to the itemGroupData list
          itemGroupData.add(responseData);
        } else {
          print('Invalid response format for group code $groupCode');
        }
      } else {
        print('Failed to retrieve item group for group code $groupCode: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error fetching item group data: $e');
  }
  return itemGroupData;
}

Future<void> synchronizeDataItemGroup(List<String> itemGroupCodes) async {
  try {
    // Fetch data from API endpoints
    List<Map<String, dynamic>> apiResponse = await _fetchItemGroupData(itemGroupCodes);

    // Open Hive boxes
    var itemgroupBox = await Hive.openBox<ItemGroup>('itemgroup');
    // Open other boxes if needed

    // Synchronize data
    await _synchronizeItemGroup(apiResponse, itemgroupBox);
    // Synchronize other data if needed

    // Close Hive boxes
    // await itemgroupBox.close();
    // Close other boxes if needed
  } catch (e) {
    print('Error synchronizing data from API to Hive: $e');
  }
}



Future<void> _synchronizeItemGroup(
  List<Map<String, dynamic>> itemGroupData,
  Box<ItemGroup> itemgroupBox,
) async {
  try {
    for (var data in itemGroupData) {
      var groupCode = data['groupCode'];
      var cmpCode = data['cmpCode'];

      var hiveGroupItem = itemgroupBox.get('$groupCode$cmpCode');

      if (hiveGroupItem == null) {
        var newGroupItem = ItemGroup(
          data['groupCode'],
          data['groupName'],
          data['groupFName'],
          data['cmpCode']
        );
        await itemgroupBox.put('$groupCode$cmpCode', newGroupItem);
      } else {
        var updatedGroupItem = ItemGroup(
          data['groupCode'],
          data['groupName'],
          data['groupFName'],
          data['cmpCode']
        );
        await itemgroupBox.put('$groupCode$cmpCode', updatedGroupItem);
      }
    }

    // Check for items in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedItemGroupCodes =
        Set.from(itemGroupData.map((data) => '${data['groupCode']}${data['cmpCode']}'));
    Set<String> hiveItemGroupCodes = Set.from(itemgroupBox.keys);

    // Identify items in Hive that don't exist in the fetched data
    Set<String> itemsToDelete = hiveItemGroupCodes.difference(fetchedItemGroupCodes);

    // Delete items in Hive that don't exist in the fetched data
    itemsToDelete.forEach((hiveItemGroupCode) {
      itemgroupBox.delete(hiveItemGroupCode);
    });
  } catch (e) {
    print('Error synchronizing ItemGroup from API to Hive: $e');
  }
}



//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<List<String>> retrieveItemCateg(List<String> seCodes) async {
  List<String> itemCategCodes = [];
  try {
    for (String seCode in seCodes) {
      // Make API call to retrieve item category codes for the given sales employee code
      var response = await http.get(Uri.parse('${apiurl}getSalesEmployeesItemsCategories?seCode=$seCode'));
      if (response.statusCode == 200) {
        // Parse the response data
        dynamic responseData = jsonDecode(response.body);
        if (responseData is List) {
          for (var item in responseData) {
            if (item is Map<String, dynamic>) {
              itemCategCodes.add(item['categCode']);
            }
          }
        } else {
          print('Invalid response format for item category codes');
        }
      } else {
        print('Failed to retrieve item category codes: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error retrieving item category codes: $e');
  }
  return itemCategCodes;
}


Future<List<Map<String, dynamic>>> _fetchItemCategData(List<String> itemCateg) async {
  List<Map<String, dynamic>> itemCategData = [];
  try {
    for (String categCode in itemCateg) {
      final response = await http.get(Uri.parse('${apiurl}getItemCateg?categCode=$categCode'));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        if (responseData is List) {
          // If the response is a list, append each item categ data to the itemCategData list
          for (var itemCateg in responseData) {
            if (itemCateg is Map<String, dynamic>) {
              itemCategData.add(itemCateg);
            }
          }
        } else if (responseData is Map<String, dynamic>) {
          // If the response is a map, directly append it to the itemCategData list
          itemCategData.add(responseData);
        } else {
          print('Invalid response format for category code $categCode');
        }
      } else {
        print('Failed to retrieve item category for category code $categCode: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error fetching item category data: $e');
  }
  return itemCategData;
}


Future<void> synchronizeDataItemCateg(List<String> itemCateg) async {
  try {
    // Fetch data from API endpoints
    List<Map<String, dynamic>> apiResponse = await _fetchItemCategData(itemCateg);

    // Open Hive boxes
    var itemcategBox = await Hive.openBox<ItemCateg>('itemcateg');
    // Open other boxes if needed

    // Synchronize data
    await _synchronizeItemCateg(apiResponse, itemcategBox);
    // Synchronize other data if needed

    // Close Hive boxes
    // await itemcategBox.close();
    // Close other boxes if needed
  } catch (e) {
    print('Error synchronizing data from API to Hive: $e');
  }
}


Future<void> _synchronizeItemCateg(
  List<Map<String, dynamic>> itemCategData,
  Box<ItemCateg> itemcategBox,
) async {
  try {
    for (var data in itemCategData) {
      var categCode = data['categCode'];
      var cmpCode = data['cmpCode'];

      var hiveCategItem = itemcategBox.get('$categCode$cmpCode');

      if (hiveCategItem == null) {
        var newCategItem = ItemCateg(
          data['categCode'],
          data['categName'],
          data['categFName'],
          data['cmpCode']
        );
        await itemcategBox.put('$categCode$cmpCode', newCategItem);
      } else {
        var updatedCategItem = ItemCateg(
          data['categCode'],
          data['categName'],
          data['categFName'],
          data['cmpCode']
        );
        await itemcategBox.put('$categCode$cmpCode', updatedCategItem);
      }
    }

    // Check for items in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedItemCategCodes =
        Set.from(itemCategData.map((data) => '${data['categCode']}${data['cmpCode']}'));
    Set<String> hiveItemCategCodes = Set.from(itemcategBox.keys);

    // Identify items in Hive that don't exist in the fetched data
    Set<String> itemsToDelete = hiveItemCategCodes.difference(fetchedItemCategCodes);

    // Delete items in Hive that don't exist in the fetched data
    itemsToDelete.forEach((hiveItemCategCode) {
      itemcategBox.delete(hiveItemCategCode);
    });
  } catch (e) {
    print('Error synchronizing ItemCateg from API to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<List<String>> retrieveItemBrand(List<String> seCodes) async {
  List<String> itemBrandCodes = [];
  try {
    for (String seCode in seCodes) {
      // Make API call to retrieve item brand codes for the given sales employee code
      var response = await http.get(Uri.parse('${apiurl}getSalesEmployeesItemsBrands?seCode=$seCode'));
      if (response.statusCode == 200) {
        // Parse the response data
        dynamic responseData = jsonDecode(response.body);
        if (responseData is List) {
          for (var item in responseData) {
            if (item is Map<String, dynamic>) {
              itemBrandCodes.add(item['brandCode']);
            }
          }
        } else {
          print('Invalid response format for item brand codes');
        }
      } else {
        print('Failed to retrieve item brand codes: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error retrieving item brand codes: $e');
  }
  return itemBrandCodes;
}

Future<List<Map<String, dynamic>>> _fetchItemBrandData(List<String> itemBrand) async {
  List<Map<String, dynamic>> itemBrandData = [];
  try {
    for (String brandCode in itemBrand) {
      final response = await http.get(Uri.parse('${apiurl}getItemBrand?brandCode=$brandCode'));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        if (responseData is List) {
          // If the response is a list, append each item brand data to the itemBrandData list
          for (var itemBrand in responseData) {
            if (itemBrand is Map<String, dynamic>) {
              itemBrandData.add(itemBrand);
            }
          }
        } else if (responseData is Map<String, dynamic>) {
          // If the response is a map, directly append it to the itemBrandData list
          itemBrandData.add(responseData);
        } else {
          print('Invalid response format for brand code $brandCode');
        }
      } else {
        print('Failed to retrieve item brand for brand code $brandCode: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error fetching item brand data: $e');
  }
  return itemBrandData;
}



Future<void> synchronizeDataItemBrand(List<String> itemBrand) async {
  try {
    // Fetch data from API endpoints
    List<Map<String, dynamic>> apiResponse = await _fetchItemBrandData(itemBrand);

    // Open Hive boxes
    var itembrandBox = await Hive.openBox<ItemBrand>('itembrand');
    // Open other boxes if needed

    // Synchronize data
    await _synchronizeItemBrand(apiResponse, itembrandBox);
    // Synchronize other data if needed

    // Close Hive boxes
    // await itembrandBox.close();
    // Close other boxes if needed
  } catch (e) {
    print('Error synchronizing data from API to Hive: $e');
  }
}


Future<void> _synchronizeItemBrand(
  List<Map<String, dynamic>> itemBrandData,
  Box<ItemBrand> itembrandBox,
) async {
  try {
    for (var data in itemBrandData) {
      var brandCode = data['brandCode'];
      var cmpCode = data['cmpCode'];

      var hiveBrandItem = itembrandBox.get('$brandCode$cmpCode');

      if (hiveBrandItem == null) {
        var newBrandItem = ItemBrand(
          data['brandCode'],
          data['brandName'],
          data['brandFName'],
          data['cmpCode']
        );
        await itembrandBox.put('$brandCode$cmpCode', newBrandItem);
      } else {
        var updatedBrandItem = ItemBrand(
          data['brandCode'],
          data['brandName'],
          data['brandFName'],
          data['cmpCode']
        );
        await itembrandBox.put('$brandCode$cmpCode', updatedBrandItem);
      }
    }

    // Check for items in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedItemBrandCodes =
        Set.from(itemBrandData.map((data) => '${data['brandCode']}${data['cmpCode']}'));
    Set<String> hiveItemBrandCodes = Set.from(itembrandBox.keys);

    // Identify items in Hive that don't exist in the fetched data
    Set<String> itemsToDelete = hiveItemBrandCodes.difference(fetchedItemBrandCodes);

    // Delete items in Hive that don't exist in the fetched data
    itemsToDelete.forEach((hiveItemBrandCode) {
      itembrandBox.delete(hiveItemBrandCode);
    });
  } catch (e) {
    print('Error synchronizing ItemBrand from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<List<Map<String, dynamic>>> _fetchItemUOMData(List<String> itemCodes) async {
  List<Map<String, dynamic>> itemUOMData = [];
  try {
    for (String itemCode in itemCodes) {
      final response = await http.get(Uri.parse('${apiurl}getItemUOM?itemCode=$itemCode'));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        if (responseData is List) {
          // If the response is a list, append each item UOM data to the itemUOMData list
          for (var itemUOM in responseData) {
            if (itemUOM is Map<String, dynamic>) {
              itemUOMData.add(itemUOM);
            }
          }
        } else if (responseData is Map<String, dynamic>) {
          // If the response is a map, directly append it to the itemUOMData list
          itemUOMData.add(responseData);
        } else {
          print('Invalid response format for item code $itemCode');
        }
      } else {
        print('Failed to retrieve item UOM for item code $itemCode: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error fetching item UOM data: $e');
  }
  return itemUOMData;
}

Future<void> synchronizeDataItemUOM(List<String> itemCodes) async {
  try {
    // Fetch data from API endpoints
    List<Map<String, dynamic>> apiResponse = await _fetchItemUOMData(itemCodes);

    // Open Hive boxes
    var itemuomBox = await Hive.openBox<ItemUOM>('itemuom');
    // Open other boxes if needed

    // Synchronize data
    await _synchronizeItemUOM(apiResponse, itemuomBox);
    // Synchronize other data if needed

    // Close Hive boxes
    // await itemuomBox.close();
    // Close other boxes if needed
  } catch (e) {
    print('Error synchronizing data from API to Hive: $e');
  }
}



Future<void> _synchronizeItemUOM(
  List<Map<String, dynamic>> itemUOMData,
  Box<ItemUOM> itemuomBox,
) async {
  try {
    for (var data in itemUOMData) {
      var uom = data['uom'];
      var itemCode = data['itemCode'];
      var cmpCode = data['cmpCode'];

      var hiveUOMItem = itemuomBox.get('$uom$itemCode$cmpCode');

      if (hiveUOMItem == null) {
        var newUOMItem = ItemUOM(
          data['itemCode'],
          data['uom'],
          data['qtyperUOM'].toDouble(),
          data['barCode'],
          data['cmpCode']
        );
        await itemuomBox.put('$uom$itemCode$cmpCode', newUOMItem);
      } else {
        var updatedUOMItem = ItemUOM(
          data['itemCode'],
          data['uom'],
          data['qtyperUOM'].toDouble(),
          data['barCode'],
          data['cmpCode']
        );
        await itemuomBox.put('$uom$itemCode$cmpCode', updatedUOMItem);
      }
    }

    // Check for items in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedItemUOMCodes =
        Set.from(itemUOMData.map((data) => '${data['uom']}${data['itemCode']}${data['cmpCode']}'));
    Set<String> hiveItemUOMCodes = Set.from(itemuomBox.keys);

    // Identify items in Hive that don't exist in the fetched data
    Set<String> itemsToDelete = hiveItemUOMCodes.difference(fetchedItemUOMCodes);

    // Delete items in Hive that don't exist in the fetched data
    itemsToDelete.forEach((hiveItemUOMCode) {
      itemuomBox.delete(hiveItemUOMCode);
    });
  } catch (e) {
    print('Error synchronizing ItemUOM from API to Hive: $e');
  }
}



//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<List<Map<String, dynamic>>> _fetchUserPLData() async {
  List<Map<String, dynamic>> userPLData = [];
  try {
    final response = await http.get(Uri.parse('${apiurl}getUserPl'));
    if (response.statusCode == 200) {
      dynamic responseData = jsonDecode(response.body);
      if (responseData is List) {
        userPLData = List<Map<String, dynamic>>.from(responseData);
      } else {
        print('Invalid response format for user PL');
      }
    } else {
      print('Failed to retrieve user PL data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching user PL data: $e');
  }
  return userPLData;
}

Future<void> synchronizeDataUserPL() async {
  try {
    // Fetch data from API endpoints
    List<Map<String, dynamic>> apiResponse = await _fetchUserPLData();

    // Open Hive boxes
    var userplBox = await Hive.openBox<UserPL>('userpl');
    // Open other boxes if needed

    // Synchronize data
    await _synchronizeUserPL(apiResponse, userplBox);
    // Synchronize other data if needed

    // Close Hive boxes
    // await userplBox.close();
    // Close other boxes if needed
  } catch (e) {
    print('Error synchronizing data from API to Hive: $e');
  }
}



Future<void> _synchronizeUserPL(
  List<Map<String, dynamic>> userPLData,
  Box<UserPL> userplBox,
) async {
  try {
    for (var data in userPLData) {
      var userCode = data['userCode'];

      var hiveUserPL = userplBox.get(userCode);

      if (hiveUserPL == null) {
        var newUserPL = UserPL(
          data['userCode'],
          data['plSecGroup'],
        );
        await userplBox.put(userCode, newUserPL);
      } else {
        var updatedUserPL = UserPL(
          data['userCode'],
          data['plSecGroup'],
        );
        await userplBox.put(userCode, updatedUserPL);
      }
    }

    // Check for items in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedUserPLCodes =
        Set.from(userPLData.map((data) => data['userCode']));
    Set<String> hiveUserPLCodes = Set.from(userplBox.keys);

    // Identify items in Hive that don't exist in the fetched data
    Set<String> itemsToDelete = hiveUserPLCodes.difference(fetchedUserPLCodes);

    // Delete items in Hive that don't exist in the fetched data
    itemsToDelete.forEach((hiveUserPLCode) {
      userplBox.delete(hiveUserPLCode);
    });
  } catch (e) {
    print('Error synchronizing USERPL from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<List<Map<String, dynamic>>> _fetchUserData() async {
  List<Map<String, dynamic>> userData = [];
  try {
    final response = await http.get(Uri.parse('${apiurl}getUsers'));
    if (response.statusCode == 200) {
      dynamic responseData = jsonDecode(response.body);
      if (responseData is List) {
        userData = List<Map<String, dynamic>>.from(responseData);
      } else {
        print('Invalid response format for users');
      }
    } else {
      print('Failed to retrieve user data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching user data: $e');
  }
  return userData;
}


Future<void> synchronizeDataUser() async {
  try {
    // Fetch data from API endpoints
    List<Map<String, dynamic>> apiResponse = await _fetchUserData();

    // Synchronize data
    await _synchronizeUsers(apiResponse);

    // Close other boxes if needed
  } catch (e) {
    print('Error synchronizing data from API to Hive: $e');
  }
}


Future<void> _synchronizeUsers(
  List<Map<String, dynamic>> userData,
) async {
  try {
    var userBox = await Hive.openBox('userBox');

    // Get the list of user codes from the API response
    Set<dynamic> apiUserCodes = Set.from(userData.map((data) => data['usercode']));

    // Get the list of user codes in the Hive box
    Set<dynamic> hiveUserCodes = Set.from(userBox.keys);

    // Identify user codes in Hive that don't exist in the API response
    Set<dynamic> userCodesToDelete = hiveUserCodes.difference(apiUserCodes);

    // Iterate over API response
    for (var data in userData) {
      var usercode = data['usercode'];

      // If the user code doesn't exist in Hive, add it
      if (!hiveUserCodes.contains(usercode)) {
        await userBox.put(usercode, data);
      }
      // If the user code exists in Hive, update it if needed
      else {
        await userBox.put(usercode, data);
      }
    }

    // Delete users in Hive that don't exist in the API response
    userCodesToDelete.forEach((userCodeToDelete) {
      userBox.delete(userCodeToDelete);
    });
  } catch (e) {
    print('Error synchronizing Users from API to Hive: $e');
  }
}




//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<List<Map<String, dynamic>>> _fetchUserGroupData() async {
  List<Map<String, dynamic>> userGroupData = [];
  try {
    final response = await http.get(Uri.parse('${apiurl}getUserGroup'));
    if (response.statusCode == 200) {
      dynamic responseData = jsonDecode(response.body);
      if (responseData is List) {
        userGroupData = List<Map<String, dynamic>>.from(responseData);
      } else {
        print('Invalid response format for user groups');
      }
    } else {
      print('Failed to retrieve user group data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching user group data: $e');
  }
  return userGroupData;
}


Future<void> synchronizeDataUserGroup() async {
  try {
    // Fetch data from API endpoints
    List<Map<String, dynamic>> apiResponse = await _fetchUserGroupData();

    // Open Hive boxes
    var userGroupBox = await Hive.openBox<UserGroup>('userGroupBox');
    // Open other boxes if needed

    // Print all data in the group database
    print('All data in group database: ${userGroupBox.values.toList()}');

    // Synchronize data
    await _synchronizeUsersGroup(apiResponse, userGroupBox);
    // Synchronize other data if needed

    // Close Hive boxes
    // await userGroupBox.close();
    // Close other boxes if needed
  } catch (e) {
    print('Error synchronizing data from API to Hive: $e');
  }
}


Future<void> _synchronizeUsersGroup(
  List<Map<String, dynamic>> userGroupData,
  Box<UserGroup> usersGroup,
) async {
  try {
    // Iterate over API response
    for (var data in userGroupData) {
      var groupcode = data['groupcode'];

      // If the item doesn't exist in Hive, add it
      if (!usersGroup.containsKey(groupcode)) {
        var newUserGroup = UserGroup(
          groupcode: data['groupcode'],
          groupname: data['groupname'],
        );
        await usersGroup.put(groupcode, newUserGroup);
      }
      // If the item exists in Hive, update it if needed
      else {
        var updatedUserGroup = UserGroup(
          groupcode: data['groupcode'],
          groupname: data['groupname'],
        );
        // Update the item in Hive
        await usersGroup.put(groupcode, updatedUserGroup);
      }
    }

    // Check for items in Hive that don't exist in the fetched data and delete them
    Set<dynamic> fetchedUserGroupCodes =
        Set.from(userGroupData.map((data) => data['groupcode']));
    Set<dynamic> hiveUserGroupCodes = Set.from(usersGroup.keys);

    // Identify items in Hive that don't exist in the fetched data
    Set<dynamic> itemsToDelete = hiveUserGroupCodes.difference(fetchedUserGroupCodes);

    // Delete items in Hive that don't exist in the fetched data
    itemsToDelete.forEach((hiveUserGroupCode) {
      usersGroup.delete(hiveUserGroupCode);
    });
  } catch (e) {
    print('Error synchronizing User Groups from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<List<Map<String, dynamic>>> _fetchUserGroupTranslationsData() async {
  try {
    // Make HTTP GET request to the API endpoint
    final response = await http.get(Uri.parse('${apiurl}getTranslation'));

    // Check if the request was successful (status code 200)
    if (response.statusCode == 200) {
      // Decode the response body
      List<dynamic> jsonData = jsonDecode(response.body);
      
      // Convert dynamic list to Map<String, dynamic>
      List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(jsonData);
      
      return data;
    } else {
      // If the request was not successful, print error message
      print('Failed to fetch data. Status code: ${response.statusCode}');
      return []; // Return an empty list
    }
  } catch (e) {
    // Handle any errors that occur during the HTTP request
    print('Error fetching data: $e');
    return []; // Return an empty list
  }
}

Future<void> synchronizeDataUserGroupTranslations() async {
  try {
    // Fetch data from MySQL
    List<Map<String, dynamic>> mysqlData = await _fetchUserGroupTranslationsData();

    // Open Hive boxes
    var translationBox = await Hive.openBox<Translations>('translationsBox');
    // Open other boxes if needed

    // Synchronize data
    await _synchronizeUserGroupTranslations(mysqlData, translationBox);
    // Synchronize other data if needed

    // Close Hive boxes
    // await translationBox.close();
    // Close other boxes if needed
  } catch (e) {
    print('Error synchronizing data from MySQL to Hive: $e');
  }
}



Future<void> _synchronizeUserGroupTranslations(
  List<Map<String, dynamic>> mysqlData,
  Box<Translations> translationBox,
) async {
  try {
    // Iterate over MySQL data
    for (var data in mysqlData) {
      var groupcode = data['groupcode'];

      // If the item doesn't exist in Hive, add it
      if (!translationBox.containsKey(groupcode)) {
        var newTranslations = Translations(
          groupcode: groupcode,
          translations: {'en': data['en'], 'ar': data['ar']},
        );
        await translationBox.put(groupcode, newTranslations);
      }
      // If the item exists in Hive, update it if needed
      else {
        var updatedTranslations = Translations(
          groupcode: groupcode,
          translations: {'en': data['en'], 'ar': data['ar']},
        );
        // Update the item in Hive
        await translationBox.put(groupcode, updatedTranslations);
      }
    }

    // Delete items in Hive that don't exist in MySQL data
    Set<dynamic> mysqlGroupCodes = Set.from(mysqlData.map((data) => data['groupcode']));
    Set<dynamic> hiveGroupCodes = Set.from(translationBox.keys);

    // Identify items in Hive that don't exist in MySQL data
    Set<dynamic> itemsToDelete = hiveGroupCodes.difference(mysqlGroupCodes);

    // Delete items in Hive that don't exist in MySQL data
    itemsToDelete.forEach((groupcode) {
      translationBox.delete(groupcode);
    });
  } catch (e) {
    print('Error synchronizing User Group Translations from MySQL to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------



Future<void> synchronizeDataMenu() async {
  try {
    // Fetch data from API endpoint for menus
    var apiResponse = await _fetchMenusData();
    var apiSubAdminResponse = await _fetchAdminSubMenusData();
    var apiSubSyncResponse = await _fetchSynchronizeSubMenusData();

    // Open Hive boxes
    var menuBox = await Hive.openBox<Menu>('menuBox');
    var userGroupBox = await Hive.openBox<AdminSubMenu>('adminSubMenuBox');
    var syncGroupBox = await Hive.openBox<SynchronizeSubMenu>('synchronizeSubMenu');
    
    // Synchronize data
    await _synchronizeMenu(apiResponse,apiSubAdminResponse,apiSubSyncResponse , menuBox, userGroupBox, syncGroupBox);

    // Close Hive boxes if needed
  } catch (e) {
    print('Error synchronizing data from API to Hive: $e');
  }
}

Future<List<Map<String, dynamic>>> _fetchMenusData() async {
  try {
    // Make HTTP GET request to the API endpoint to fetch menu data
    var response = await http.get(Uri.parse('${apiurl}getMenu'));

    // Check if the request was successful (status code 200)
    if (response.statusCode == 200) {
      // Decode the response body
      List<dynamic> jsonData = jsonDecode(response.body);
      
      // Convert dynamic list to Map<String, dynamic>
      List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(jsonData);
      
      return data;
    } else {
      // If the request was not successful, print error message
      print('Failed to fetch menu data. Status code: ${response.statusCode}');
      return []; // Return an empty list
    }
  } catch (e) {
    // Handle any errors that occur during the HTTP request
    print('Error fetching menu data: $e');
    return []; // Return an empty list
  }
}

Future<List<Map<String, dynamic>>> _fetchAdminSubMenusData() async {
  try {
    // Make HTTP GET request to the API endpoint to fetch menu data
    var response = await http.get(Uri.parse('${apiurl}getAdminSubMenu'));

    // Check if the request was successful (status code 200)
    if (response.statusCode == 200) {
      // Decode the response body
      List<dynamic> jsonData = jsonDecode(response.body);
      
      // Convert dynamic list to Map<String, dynamic>
      List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(jsonData);
      
      return data;
    } else {
      // If the request was not successful, print error message
      print('Failed to fetch Admin sub menu data. Status code: ${response.statusCode}');
      return []; // Return an empty list
    }
  } catch (e) {
    // Handle any errors that occur during the HTTP request
    print('Error fetching menu data: $e');
    return []; // Return an empty list
  }
}

Future<List<Map<String, dynamic>>> _fetchSynchronizeSubMenusData() async {
  try {
    // Make HTTP GET request to the API endpoint to fetch menu data
    var response = await http.get(Uri.parse('${apiurl}getSyncSubMenu'));

    // Check if the request was successful (status code 200)
    if (response.statusCode == 200) {
      // Decode the response body
      List<dynamic> jsonData = jsonDecode(response.body);
      
      // Convert dynamic list to Map<String, dynamic>
      List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(jsonData);
      
      return data;
    } else {
      // If the request was not successful, print error message
      print('Failed to fetch Admin sub menu data. Status code: ${response.statusCode}');
      return []; // Return an empty list
    }
  } catch (e) {
    // Handle any errors that occur during the HTTP request
    print('Error fetching menu data: $e');
    return []; // Return an empty list
  }
}


Future<void> _synchronizeMenu(
  List<Map<String, dynamic>> apiResponse,
   List<Map<String, dynamic>> apiSubAdminResponse,
    List<Map<String, dynamic>> apiSubSynchronizeResponse,
  Box<Menu> menuBox,
  Box<AdminSubMenu> adminGroupBox,
  Box<SynchronizeSubMenu> syncGroupBox,
) async {
  try {
    // Iterate over API response data
    for (var data in apiResponse) {
      var menucode = data['menucode'];

      // Check if the menu item exists in Hive
      var hiveMenu = menuBox.get(menucode);

      // If the menu item doesn't exist in Hive, add it
      if (hiveMenu == null) {
        var newMenu = Menu(
          menucode: data['menucode'],
          menuname: data['menuname'],
          menuarname: data['menuarname'],
        );
        await menuBox.put(menucode, newMenu);
      } else {
        // If the menu item exists in Hive, update it if needed
        var updatedMenu = Menu(
          menucode: data['menucode'],
          menuname: data['menuname'],
          menuarname: data['menuarname'],
        );
        // Update the item in Hive
        await menuBox.put(menucode, updatedMenu);
      }

      // Synchronize the usergroups and syncgroups subcollections
      await _synchronizeSubMenu(menucode, apiSubAdminResponse, adminGroupBox);
      await synchronizeIESubMenu(menucode, apiSubSynchronizeResponse, syncGroupBox);
    }

    // Delete menu items from Hive that don't exist in API response
    menuBox.keys.toList().forEach((hiveMenuCode) {
      if (!apiResponse.any((data) => data['menucode'] == hiveMenuCode)) {
        // Menu item exists in Hive but not in API response, so delete it from Hive
        menuBox.delete(hiveMenuCode);
      }
    });
  } catch (e) {
    print('Error synchronizing Menus from API to Hive: $e');
  }
}

Future<void> _synchronizeSubMenu(int menucode, List<dynamic> subMenuData, Box<dynamic> groupBox) async {
  try {
    // Iterate over subMenuData
    for (var subMenu in subMenuData) {
      var groupcode = subMenu['groupcode'];

      // Check if the usergroup/syncgroup exists in Hive
      var hiveGroup = groupBox.get(groupcode);

      // If the usergroup/syncgroup doesn't exist in Hive, add it
      if (hiveGroup == null) {
        var newGroup = AdminSubMenu(
          groupcode: subMenu['groupcode'],
          groupname: subMenu['groupname'],
          grouparname: subMenu['grouparname'],
          
        );
        await groupBox.put(groupcode, newGroup);
      } else {
        // If the usergroup/syncgroup exists in Hive, update it if needed
        var updatedGroup = AdminSubMenu(
          groupcode: subMenu['groupcode'],
          groupname: subMenu['groupname'],
          grouparname: subMenu['grouparname'],
        );
        // Update the item in Hive
        await groupBox.put(groupcode, updatedGroup);
      }
    }
  } catch (e) {
    print('Error synchronizing admin SubMenus from API to Hive: $e');
  }
}

Future<void> synchronizeIESubMenu(int menucode, List<dynamic> subSyncData, Box<SynchronizeSubMenu> syncGroupBox) async {
 try {
    // Iterate over subMenuData
    for (var subMenu in subSyncData) {
      var syncronizecode = subMenu['syncronizecode'];

      // Check if the usergroup/syncgroup exists in Hive
      var hiveGroup = syncGroupBox.get(syncronizecode);

      // If the usergroup/syncgroup doesn't exist in Hive, add it
      if (hiveGroup == null) {
        var newGroup = SynchronizeSubMenu(
          syncronizecode: subMenu['syncronizecode'],
          syncronizename: subMenu['syncronizename'],
          syncronizearname: subMenu['syncronizearname'],
          
        );
        await syncGroupBox.put(syncronizecode, newGroup);
      } else {
        // If the usergroup/syncgroup exists in Hive, update it if needed
        var updatedGroup = SynchronizeSubMenu(
             syncronizecode: subMenu['syncronizecode'],
          syncronizename: subMenu['syncronizename'],
          syncronizearname: subMenu['syncronizearname'],
        );
        // Update the item in Hive
        await syncGroupBox.put(syncGroupBox, updatedGroup);
      }
    }
  } catch (e) {
    print('Error synchronizing Synchronize SubMenus from API to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<List<Map<String, dynamic>>> _fetchAuthorizationData() async {
  List<Map<String, dynamic>> authorizationData = [];
  try {
    // Perform HTTP GET request to fetch authorization data from the API endpoint
    final response = await http.get(Uri.parse('${apiurl}getAuthorization'));
    if (response.statusCode == 200) {
      dynamic responseData = jsonDecode(response.body);
      if (responseData is List) {
        // If the response is a list, append each authorization data to the authorizationData list
        for (var authData in responseData) {
          if (authData is Map<String, dynamic>) {
            authorizationData.add(authData);
          }
        }
      } else if (responseData is Map<String, dynamic>) {
        // If the response is a map, directly append it to the authorizationData list
        authorizationData.add(responseData);
      } else {
        print('Invalid response format for authorization data');
      }
    } else {
      print('Failed to retrieve authorization data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching authorization data: $e');
  }
  return authorizationData;
}

Future<void> synchronizeDataAuthorization() async {
  try {
    // Fetch data from API endpoint
    List<Map<String, dynamic>> apiResponse = await _fetchAuthorizationData();

    // Open Hive box
    var authoBox = await Hive.openBox<Authorization>('authorizationBox');
    // Open other boxes if needed

    // Synchronize data
    await _synchronizeAutho(apiResponse, authoBox);
    // Synchronize other data if needed

    // Close Hive boxes
    // await authoBox.close();
    // Close other boxes if needed
  } catch (e) {
    print('Error synchronizing data from API to Hive: $e');
  }
}

Future<void> _synchronizeAutho(
  List<Map<String, dynamic>> authorizationData,
  Box<Authorization> authoBox,
) async {
  try {
    for (var data in authorizationData) {
      var menucode = data['menucode'];
      var groupcode = data['groupcode'];

      // Check if the item exists in Hive
      var hiveAutho = authoBox.get('$menucode$groupcode');

      // If the item doesn't exist in Hive, add it
      if (hiveAutho == null) {
        var newAutho = Authorization(
          menucode: menucode,
          groupcode: groupcode,
        );
        await authoBox.put('$menucode$groupcode', newAutho);
      }
      // If the item exists in Hive, update it if needed
      else {
        var updatedAutho = Authorization(
          menucode: menucode,
          groupcode: groupcode,
        );
        // Update the item in Hive
        await authoBox.put('$menucode$groupcode', updatedAutho);
      }
    }

    // Check for items in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedAuthoCodes =
        Set.from(authorizationData.map((data) => '${data['menucode']}${data['groupcode']}'));
    Set<String> hiveAuthoCodes = Set.from(authoBox.keys);

    // Identify items in Hive that don't exist in the fetched data
    Set<String> itemsToDelete = hiveAuthoCodes.difference(fetchedAuthoCodes);

    // Delete items in Hive that don't exist in the fetched data
    itemsToDelete.forEach((hiveAuthoCode) {
      authoBox.delete(hiveAuthoCode);
    });
  } catch (e) {
    print('Error synchronizing Authorization from API to Hive: $e');
  }
}




//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
Future<List<Map<String, dynamic>>> _fetchGeneralSettingsData() async {
  List<Map<String, dynamic>> generalSettingsData = [];
  try {
    // Perform HTTP GET request to fetch general settings data from the API endpoint
    final response = await http.get(Uri.parse('${apiurl}getSystemAdmin'));
    if (response.statusCode == 200) {
      dynamic responseData = jsonDecode(response.body);
      if (responseData is List) {
        // If the response is a list, append each general settings data to the generalSettingsData list
        for (var settingsData in responseData) {
          if (settingsData is Map<String, dynamic>) {
            generalSettingsData.add(settingsData);
          }
        }
      } else if (responseData is Map<String, dynamic>) {
        // If the response is a map, directly append it to the generalSettingsData list
        generalSettingsData.add(responseData);
      } else {
        print('Invalid response format for general settings data');
      }
    } else {
      print('Failed to retrieve general settings data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching general settings data: $e');
  }
  return generalSettingsData;
}

Future<void> synchronizeDataGeneralSettings() async {
  try {
    // Fetch data from API endpoint
    List<Map<String, dynamic>> apiResponse = await _fetchGeneralSettingsData();

    // Open Hive box
    var systemAdminBox = await Hive.openBox<SystemAdmin>('systemAdminBox');
    // Open other boxes if needed

    // Synchronize data
    await _synchronizeSystem(apiResponse, systemAdminBox);
    // Synchronize other data if needed

    // Close Hive boxes
    // await systemAdminBox.close();
    // Close other boxes if needed
  } catch (e) {
    print('Error synchronizing data from API to Hive: $e');
  }
}

Future<void> _synchronizeSystem(
  List<Map<String, dynamic>> generalSettingsData,
  Box<SystemAdmin> systemAdminBox,
) async {
  try {
    for (var data in generalSettingsData) {
      var groupcode = data['groupcode'];

      // Check if the item exists in Hive
      var hiveSystem = systemAdminBox.get(groupcode);

      // If the item doesn't exist in Hive, add it
      if (hiveSystem == null) {
        var newSystem = SystemAdmin(
          autoExport: data['autoExport'],
          groupcode: data['groupcode'],
          importFromErpToMobile: data['importFromErpToMobile'],
          importFromBackendToMobile: data['importFromBackendToMobile'],
        );
        await systemAdminBox.put(groupcode, newSystem);
      }
      // If the item exists in Hive, update it if needed
      else {
        var updatedSystem = SystemAdmin(
          autoExport: data['autoExport'],
          groupcode: data['groupcode'],
          importFromErpToMobile: data['importFromErpToMobile'],
          importFromBackendToMobile: data['importFromBackendToMobile'],
        );
        // Update the item in Hive
        await systemAdminBox.put(groupcode, updatedSystem);
      }
    }

    // Check for items in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedSystemCodes =
        Set.from(generalSettingsData.map((data) => data['groupcode']));
    Set<String> hiveSystemCodes = Set.from(systemAdminBox.keys);

    // Identify items in Hive that don't exist in the fetched data
    Set<String> itemsToDelete = hiveSystemCodes.difference(fetchedSystemCodes);

    // Delete items in Hive that don't exist in the fetched data
    itemsToDelete.forEach((hiveSystemCode) {
      systemAdminBox.delete(hiveSystemCode);
    });
  } catch (e) {
    print('Error synchronizing General Settings from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
Future<List<Map<String, dynamic>>> _fetchCompaniesData() async {
  List<Map<String, dynamic>> companiesData = [];
  try {
    // Perform HTTP GET request to fetch companies data from the API endpoint
    final response = await http.get(Uri.parse('${apiurl}getCompanies'));
    if (response.statusCode == 200) {
      dynamic responseData = jsonDecode(response.body);
      if (responseData is List) {
        // If the response is a list, append each company data to the companiesData list
        for (var companyData in responseData) {
          if (companyData is Map<String, dynamic>) {
            companiesData.add(companyData);
          }
        }
      } else {
        print('Invalid response format for companies data');
      }
    } else {
      print('Failed to retrieve companies data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching companies data: $e');
  }
  return companiesData;
}

Future<void> synchronizeCompanies() async {
  try {
    // Fetch data from API endpoint
    List<Map<String, dynamic>> apiResponse = await _fetchCompaniesData();

    // Open Hive box
    var companiesBox = await Hive.openBox<Companies>('companiesBox');

    // Synchronize data
    await _synchronizeCompanies(apiResponse, companiesBox);

    // Close Hive box
    // await companiesBox.close();
  } catch (e) {
    print('Error synchronizing data from API to Hive for Companies: $e');
  }
}

Future<void> _synchronizeCompanies(
  List<Map<String, dynamic>> companiesData,
  Box<Companies> companiesBox,
) async {
  try {
    for (var data in companiesData) {
      var cmpCode = data['cmpCode'];

      // Check if the company exists in Hive
      var hiveCompany = companiesBox.get(cmpCode);

      if (hiveCompany == null) {
        var newCompany = Companies(
          cmpCode: data['cmpCode'],
          cmpName: data['cmpName'],
          cmpFName: data['cmpFName'],
          tel: data['tel'],
          mobile: data['mobile'],
          address: data['address'],
          fAddress: data['fAddress'],
          prHeader: data['prHeader'],
          prFHeader: data['prFHeader'],
          prFooter: data['prFooter'],
          prFFooter: data['prFFooter'],
          mainCurCode: data['mainCurCode'],
          secCurCode: data['secCurCode'],
          rateType: data['rateType'],
          issueBatchMethod: data['issueBatchMethod'],
          systemAdminID: data['systemAdminID'],
          notes: data['notes'],
        );
        await companiesBox.put(cmpCode, newCompany);
      } else {
        var updatedCompany = Companies(
          cmpCode: data['cmpCode'],
          cmpName: data['cmpName'],
          cmpFName: data['cmpFName'],
          tel: data['tel'],
          mobile: data['mobile'],
          address: data['address'],
          fAddress: data['fAddress'],
          prHeader: data['prHeader'],
          prFHeader: data['prFHeader'],
          prFooter: data['prFooter'],
          prFFooter: data['prFFooter'],
          mainCurCode: data['mainCurCode'],
          secCurCode: data['secCurCode'],
          rateType: data['rateType'],
          issueBatchMethod: data['issueBatchMethod'],
          systemAdminID: data['systemAdminID'],
          notes: data['notes'],
        );
        await companiesBox.put(cmpCode, updatedCompany);
      }
    }

    // Check for companies in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedCompanyCodes = Set.from(companiesData.map((data) => data['cmpCode']));
    Set<String> hiveCompanyCodes = Set.from(companiesBox.keys);

    // Identify companies in Hive that don't exist in the fetched data
    Set<String> companiesToDelete = hiveCompanyCodes.difference(fetchedCompanyCodes);

    // Delete companies in Hive that don't exist in the fetched data
    companiesToDelete.forEach((hiveCompanyCode) {
      companiesBox.delete(hiveCompanyCode);
    });
  } catch (e) {
    print('Error synchronizing Companies from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<List<Map<String, dynamic>>> _fetchDepartmentsData() async {
  List<Map<String, dynamic>> departmentsData = [];
  try {
    // Perform HTTP GET request to fetch departments data from the API endpoint
    final response = await http.get(Uri.parse('${apiurl}getDepartments'));
    if (response.statusCode == 200) {
      dynamic responseData = jsonDecode(response.body);
      if (responseData is List) {
        // If the response is a list, append each department data to the departmentsData list
        for (var departmentData in responseData) {
          if (departmentData is Map<String, dynamic>) {
            departmentsData.add(departmentData);
          }
        }
      } else {
        print('Invalid response format for departments data');
      }
    } else {
      print('Failed to retrieve departments data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching departments data: $e');
  }
  return departmentsData;
}

Future<void> synchronizeDepartments() async {
  try {
    // Fetch data from API endpoint
    List<Map<String, dynamic>> apiResponse = await _fetchDepartmentsData();

    // Open Hive box
    var departmentsBox = await Hive.openBox<Departements>('departmentsBox');

    // Synchronize data
    await _synchronizeDepartments(apiResponse, departmentsBox);

    // Close Hive box
    // await departmentsBox.close();
  } catch (e) {
    print('Error synchronizing data from API to Hive for Departments: $e');
  }
}

Future<void> _synchronizeDepartments(
  List<Map<String, dynamic>> departmentsData,
  Box<Departements> departmentsBox,
) async {
  try {
    for (var data in departmentsData) {
      var cmpCode = data['cmpCode'];
      var depCode = data['depCode'];

      // Check if the department exists in Hive
      var hiveDepartment = departmentsBox.get('$cmpCode$depCode');

      if (hiveDepartment == null) {
        var newDepartment = Departements(
          cmpCode: cmpCode,
          depCode: depCode,
          depName: data['depName'],
          depFName: data['depFName'],
          notes: data['notes'],
        );
        await departmentsBox.put('$cmpCode$depCode', newDepartment);
      } else {
        var updatedDepartment = Departements(
          cmpCode: cmpCode,
          depCode: depCode,
          depName: data['depName'],
          depFName: data['depFName'],
          notes: data['notes'],
        );
        await departmentsBox.put('$cmpCode$depCode', updatedDepartment);
      }
    }

    // Check for departments in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedDepartmentKeys =
        Set.from(departmentsData.map((data) => '${data['cmpCode']}${data['depCode']}'));
    Set<String> hiveDepartmentKeys = Set.from(departmentsBox.keys);

    // Identify departments in Hive that don't exist in the fetched data
    Set<String> departmentsToDelete = hiveDepartmentKeys.difference(fetchedDepartmentKeys);

    // Delete departments in Hive that don't exist in the fetched data
    departmentsToDelete.forEach((hiveDepartmentKey) {
      departmentsBox.delete(hiveDepartmentKey);
    });
  } catch (e) {
    print('Error synchronizing Departments from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
Future<List<Map<String, dynamic>>> _fetchExchangeRatesData() async {
  List<Map<String, dynamic>> exchangeRatesData = [];
  try {
    // Perform HTTP GET request to fetch exchange rates data from the API endpoint
    final response = await http.get(Uri.parse('${apiurl}getExchangeRate'));
    if (response.statusCode == 200) {
      dynamic responseData = jsonDecode(response.body);
      if (responseData is List) {
        // If the response is a list, append each exchange rate data to the exchangeRatesData list
        for (var exchangeRateData in responseData) {
          if (exchangeRateData is Map<String, dynamic>) {
            exchangeRatesData.add(exchangeRateData);
          }
        }
      } else {
        print('Invalid response format for exchange rates data');
      }
    } else {
      print('Failed to retrieve exchange rates data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching exchange rates data: $e');
  }
  return exchangeRatesData;
}

Future<void> synchronizeExchangeRates() async {
  try {
    // Fetch data from API endpoint
    List<Map<String, dynamic>> apiResponse = await _fetchExchangeRatesData();

    // Open Hive box
    var exchangeRateBox = await Hive.openBox<ExchangeRate>('exchangeRateBox');

    // Synchronize data
    await _synchronizeExchangeRates(apiResponse, exchangeRateBox);

    // Close Hive box
    // await exchangeRateBox.close();
  } catch (e) {
    print('Error synchronizing data from API to Hive for ExchangeRates: $e');
  }
}

Future<void> _synchronizeExchangeRates(
  List<Map<String, dynamic>> exchangeRatesData,
  Box<ExchangeRate> exchangeRatesBox,
) async {
  try {
    for (var data in exchangeRatesData) {
      var cmpCode = data['cmpCode'];
      var curCode = data['curCode'];

      // Check if the exchange rate exists in Hive
      var hiveExchangeRate = exchangeRatesBox.get('$cmpCode$curCode');

      if (hiveExchangeRate == null) {
        var newExchangeRate = ExchangeRate(
          cmpCode: cmpCode,
          curCode: curCode,
          fDate: DateTime.parse(data['fDate']),
          tDate: DateTime.parse(data['tDate']),
          rate: data['rate'],
        );
        await exchangeRatesBox.put('$cmpCode$curCode', newExchangeRate);
      } else {
        var updatedExchangeRate = ExchangeRate(
          cmpCode: cmpCode,
          curCode: curCode,
          fDate: DateTime.parse(data['fDate']),
          tDate: DateTime.parse(data['tDate']),
          rate: data['rate'],
        );
        await exchangeRatesBox.put('$cmpCode$curCode', updatedExchangeRate);
      }
    }

    // Check for exchange rates in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedExchangeRateKeys =
        Set.from(exchangeRatesData.map((data) => '${data['cmpCode']}${data['curCode']}'));
    Set<String> hiveExchangeRateKeys = Set.from(exchangeRatesBox.keys);

    // Identify exchange rates in Hive that don't exist in the fetched data
    Set<String> exchangeRatesToDelete = hiveExchangeRateKeys.difference(fetchedExchangeRateKeys);

    // Delete exchange rates in Hive that don't exist in the fetched data
    exchangeRatesToDelete.forEach((hiveExchangeRateKey) {
      exchangeRatesBox.delete(hiveExchangeRateKey);
    });
  } catch (e) {
    print('Error synchronizing ExchangeRates from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
Future<List<Map<String, dynamic>>> _fetchCurrenciesData() async {
  List<Map<String, dynamic>> currenciesData = [];
  try {
    // Perform HTTP GET request to fetch currency data from the API endpoint
    final response = await http.get(Uri.parse('${apiurl}getCurrencies'));
    if (response.statusCode == 200) {
      dynamic responseData = jsonDecode(response.body);
      if (responseData is List) {
        // If the response is a list, append each currency data to the currenciesData list
        for (var currencyData in responseData) {
          if (currencyData is Map<String, dynamic>) {
            currenciesData.add(currencyData);
          }
        }
      } else {
        print('Invalid response format for currency data');
      }
    } else {
      print('Failed to retrieve currency data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching currency data: $e');
  }
  return currenciesData;
}

Future<void> synchronizeCurrencies() async {
  try {
    // Fetch data from API endpoint
    List<Map<String, dynamic>> apiResponse = await _fetchCurrenciesData();

    // Open Hive box
    var currenciesBox = await Hive.openBox<Currencies>('currenciesBox');

    // Synchronize data
    await _synchronizeCurrencies(apiResponse, currenciesBox);

    // Close Hive box
    // await currenciesBox.close();
  } catch (e) {
    print('Error synchronizing data from API to Hive for Currencies: $e');
  }
}

Future<void> _synchronizeCurrencies(
  List<Map<String, dynamic>> currenciesData,
  Box<Currencies> currenciesBox,
) async {
  try {
    for (var data in currenciesData) {
      var cmpCode = data['cmpCode'];
      var curCode = data['curCode'];

      // Check if the currency exists in Hive
      var hiveCurrency = currenciesBox.get('$cmpCode$curCode');

      if (hiveCurrency == null) {
        var newCurrency = Currencies(
          cmpCode: cmpCode,
          curCode: curCode,
          curName: data['curName'],
          curFName: data['curFName'],
          notes: data['notes'],
        );
        await currenciesBox.put('$cmpCode$curCode', newCurrency);
      } else {
        var updatedCurrency = Currencies(
          cmpCode: cmpCode,
          curCode: curCode,
          curName: data['curName'],
          curFName: data['curFName'],
          notes: data['notes'],
        );
        await currenciesBox.put('$cmpCode$curCode', updatedCurrency);
      }
    }

    // Check for currencies in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedCurrencyKeys =
        Set.from(currenciesData.map((data) => '${data['cmpCode']}${data['curCode']}'));
    Set<String> hiveCurrencyKeys = Set.from(currenciesBox.keys);

    // Identify currencies in Hive that don't exist in the fetched data
    Set<String> currenciesToDelete = hiveCurrencyKeys.difference(fetchedCurrencyKeys);

    // Delete currencies in Hive that don't exist in the fetched data
    currenciesToDelete.forEach((hiveCurrencyKey) {
      currenciesBox.delete(hiveCurrencyKey);
    });
  } catch (e) {
    print('Error synchronizing Currencies from API to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
Future<List<Map<String, dynamic>>> _fetchVATGroupsData() async {
  List<Map<String, dynamic>> vatGroupsData = [];
  try {
    // Perform HTTP GET request to fetch VAT groups data from the API endpoint
    final response = await http.get(Uri.parse('${apiurl}getVATGroups'));
    if (response.statusCode == 200) {
      dynamic responseData = jsonDecode(response.body);
      if (responseData is List) {
        // If the response is a list, append each VAT group data to the vatGroupsData list
        for (var vatGroupData in responseData) {
          if (vatGroupData is Map<String, dynamic>) {
            vatGroupsData.add(vatGroupData);
          }
        }
      } else {
        print('Invalid response format for VAT groups data');
      }
    } else {
      print('Failed to retrieve VAT groups data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching VAT groups data: $e');
  }
  return vatGroupsData;
}

Future<void> synchronizeVATGroups() async {
  try {
    // Fetch data from API endpoint
    List<Map<String, dynamic>> apiResponse = await _fetchVATGroupsData();

    // Open Hive box
    var vatGroupsBox = await Hive.openBox<VATGroups>('vatGroupsBox');

    // Synchronize data
    await _synchronizeVATGroups(apiResponse, vatGroupsBox);

    // Close Hive box
    // await vatGroupsBox.close();
  } catch (e) {
    print('Error synchronizing data from API to Hive for VATGroups: $e');
  }
}

Future<void> _synchronizeVATGroups(
  List<Map<String, dynamic>> vatGroupsData,
  Box<VATGroups> vatGroupsBox,
) async {
  try {
    for (var data in vatGroupsData) {
      var cmpCode = data['cmpCode'];
      var vatCode = data['vatCode'];

      // Check if the VAT group exists in Hive
      var hiveVATGroup = vatGroupsBox.get('$cmpCode$vatCode');

      if (hiveVATGroup == null) {
        var newVATGroup = VATGroups(
          cmpCode: cmpCode,
          vatCode: vatCode,
          vatName: data['vatName'],
          vatRate: data['vatRate'],
          baseCurCode: data['baseCurCode'],
          notes: data['notes'],
        );
        await vatGroupsBox.put('$cmpCode$vatCode', newVATGroup);
      } else {
        var updatedVATGroup = VATGroups(
          cmpCode: cmpCode,
          vatCode: vatCode,
          vatName: data['vatName'],
          vatRate: data['vatRate'],
          baseCurCode: data['baseCurCode'],
          notes: data['notes'],
        );
        await vatGroupsBox.put('$cmpCode$vatCode', updatedVATGroup);
      }
    }

    // Check for VAT groups in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedVATGroupKeys =
        Set.from(vatGroupsData.map((data) => '${data['cmpCode']}${data['vatCode']}'));
    Set<String> hiveVATGroupKeys = Set.from(vatGroupsBox.keys);

    // Identify VAT groups in Hive that don't exist in the fetched data
    Set<String> vatGroupsToDelete = hiveVATGroupKeys.difference(fetchedVATGroupKeys);

    // Delete VAT groups in Hive that don't exist in the fetched data
    vatGroupsToDelete.forEach((hiveVATGroupKey) {
      vatGroupsBox.delete(hiveVATGroupKey);
    });
  } catch (e) {
    print('Error synchronizing VATGroups from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
Future<List<Map<String, dynamic>>> _fetchCustGroupsData() async {
  List<Map<String, dynamic>> custGroupsData = [];
  try {
    // Perform HTTP GET request to fetch customer groups data from the API endpoint
    final response = await http.get(Uri.parse('${apiurl}getCustGroups'));
    if (response.statusCode == 200) {
      dynamic responseData = jsonDecode(response.body);
      if (responseData is List) {
        // If the response is a list, append each customer group data to the custGroupsData list
        for (var custGroupData in responseData) {
          if (custGroupData is Map<String, dynamic>) {
            custGroupsData.add(custGroupData);
          }
        }
      } else {
        print('Invalid response format for customer groups data');
      }
    } else {
      print('Failed to retrieve customer groups data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching customer groups data: $e');
  }
  return custGroupsData;
}

Future<void> synchronizeCustGroups() async {
  try {
    // Fetch data from API endpoint
    List<Map<String, dynamic>> apiResponse = await _fetchCustGroupsData();

    // Open Hive box
    var custGroupsBox = await Hive.openBox<CustGroups>('custGroupsBox');

    // Synchronize data
    await _synchronizeCustGroups(apiResponse, custGroupsBox);

    // Close Hive box
    // await custGroupsBox.close();
  } catch (e) {
    print('Error synchronizing data from API to Hive for CustGroups: $e');
  }
}

Future<void> _synchronizeCustGroups(
  List<Map<String, dynamic>> custGroupsData,
  Box<CustGroups> custGroupsBox,
) async {
  try {
    for (var data in custGroupsData) {
      var cmpCode = data['cmpCode'];
      var grpCode = data['grpCode'];

      // Check if the customer group exists in Hive
      var hiveCustGroup = custGroupsBox.get('$cmpCode$grpCode');

      if (hiveCustGroup == null) {
        var newCustGroup = CustGroups(
          cmpCode: cmpCode,
          grpCode: grpCode,
          grpName: data['grpName'],
          grpFName: data['grpFName'],
          notes: data['notes'],
        );
        await custGroupsBox.put('$cmpCode$grpCode', newCustGroup);
      } else {
        var updatedCustGroup = CustGroups(
          cmpCode: cmpCode,
          grpCode: grpCode,
          grpName: data['grpName'],
          grpFName: data['grpFName'],
          notes: data['notes'],
        );
        await custGroupsBox.put('$cmpCode$grpCode', updatedCustGroup);
      }
    }

    // Check for customer groups in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedCustGroupKeys =
        Set.from(custGroupsData.map((data) => '${data['cmpCode']}${data['grpCode']}'));
    Set<String> hiveCustGroupKeys = Set.from(custGroupsBox.keys);

    // Identify customer groups in Hive that don't exist in the fetched data
    Set<String> custGroupsToDelete = hiveCustGroupKeys.difference(fetchedCustGroupKeys);

    // Delete customer groups in Hive that don't exist in the fetched data
    custGroupsToDelete.forEach((hiveCustGroupKey) {
      custGroupsBox.delete(hiveCustGroupKey);
    });
  } catch (e) {
    print('Error synchronizing CustGroups from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
Future<List<Map<String, dynamic>>> _fetchCustPropertiesData() async {
  List<Map<String, dynamic>> custPropertiesData = [];
  try {
    // Perform HTTP GET request to fetch customer properties data from the API endpoint
    final response = await http.get(Uri.parse('${apiurl}getCustProperties'));
    if (response.statusCode == 200) {
      dynamic responseData = jsonDecode(response.body);
      if (responseData is List) {
        // If the response is a list, append each customer property data to the custPropertiesData list
        for (var custPropertyData in responseData) {
          if (custPropertyData is Map<String, dynamic>) {
            custPropertiesData.add(custPropertyData);
          }
        }
      } else {
        print('Invalid response format for customer properties data');
      }
    } else {
      print('Failed to retrieve customer properties data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching customer properties data: $e');
  }
  return custPropertiesData;
}

Future<void> synchronizeCustProperties() async {
  try {
    // Fetch data from API endpoint
    List<Map<String, dynamic>> apiResponse = await _fetchCustPropertiesData();

    // Open Hive box
    var custPropertiesBox = await Hive.openBox<CustProperties>('custPropertiesBox');

    // Synchronize data
    await _synchronizeCustProperties(apiResponse, custPropertiesBox);

    // Close Hive box
    // await custPropertiesBox.close();
  } catch (e) {
    print('Error synchronizing data from API to Hive for CustProperties: $e');
  }
}

Future<void> _synchronizeCustProperties(
  List<Map<String, dynamic>> custPropertiesData,
  Box<CustProperties> custPropertiesBox,
) async {
  try {
    for (var data in custPropertiesData) {
      var cmpCode = data['cmpCode'];
      var propCode = data['propCode'];

      // Check if the customer property exists in Hive
      var hiveCustProperty = custPropertiesBox.get('$cmpCode$propCode');

      if (hiveCustProperty == null) {
        var newCustProperty = CustProperties(
          cmpCode: cmpCode,
          propCode: propCode,
          propName: data['propName'],
          propFName: data['propFName'],
          notes: data['notes'],
        );
        await custPropertiesBox.put('$cmpCode$propCode', newCustProperty);
      } else {
        var updatedCustProperty = CustProperties(
          cmpCode: cmpCode,
          propCode: propCode,
          propName: data['propName'],
          propFName: data['propFName'],
          notes: data['notes'],
        );
        await custPropertiesBox.put('$cmpCode$propCode', updatedCustProperty);
      }
    }

    // Check for customer properties in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedCustPropertyKeys =
        Set.from(custPropertiesData.map((data) => '${data['cmpCode']}${data['propCode']}'));
    Set<String> hiveCustPropertyKeys = Set.from(custPropertiesBox.keys);

    // Identify customer properties in Hive that don't exist in the fetched data
    Set<String> custPropertiesToDelete = hiveCustPropertyKeys.difference(fetchedCustPropertyKeys);

    // Delete customer properties in Hive that don't exist in the fetched data
    custPropertiesToDelete.forEach((hiveCustPropertyKey) {
      custPropertiesBox.delete(hiveCustPropertyKey);
    });
  } catch (e) {
    print('Error synchronizing CustProperties from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------


Future<List<Map<String, dynamic>>> _fetchRegionsData() async {
  List<Map<String, dynamic>> regionsData = [];
  try {
    // Perform HTTP GET request to fetch regions data from the API endpoint
    final response = await http.get(Uri.parse('${apiurl}getRegions'));
    if (response.statusCode == 200) {
      dynamic responseData = jsonDecode(response.body);
      if (responseData is List) {
        // If the response is a list, append each region data to the regionsData list
        for (var regionData in responseData) {
          if (regionData is Map<String, dynamic>) {
            regionsData.add(regionData);
          }
        }
      } else {
        print('Invalid response format for regions data');
      }
    } else {
      print('Failed to retrieve regions data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching regions data: $e');
  }
  return regionsData;
}

Future<void> synchronizeRegions() async {
  try {
    // Fetch data from API endpoint
    List<Map<String, dynamic>> apiResponse = await _fetchRegionsData();

    // Open Hive box
    var regionsBox = await Hive.openBox<Regions>('regionsBox');

    // Synchronize data
    await _synchronizeRegions(apiResponse, regionsBox);
  } catch (e) {
    print('Error synchronizing data from API to Hive for Regions: $e');
  }
}

Future<void> _synchronizeRegions(
  List<Map<String, dynamic>> regionsData,
  Box<Regions> regionsBox,
) async {
  try {
    for (var data in regionsData) {
      var cmpCode = data['cmpCode'];
      var regCode = data['regCode'];

      // Check if the region exists in Hive
      var hiveRegion = regionsBox.get('$cmpCode$regCode');

      if (hiveRegion == null) {
        var newRegion = Regions(
          cmpCode: cmpCode,
          regCode: regCode,
          regName: data['regName'],
          regFName: data['regFName'],
          notes: data['notes'],
        );
        await regionsBox.put('$cmpCode$regCode', newRegion);
      } else {
        var updatedRegion = Regions(
          cmpCode: cmpCode,
          regCode: regCode,
          regName: data['regName'],
          regFName: data['regFName'],
          notes: data['notes'],
        );
        await regionsBox.put('$cmpCode$regCode', updatedRegion);
      }
    }

    // Check for regions in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedRegionKeys =
        Set.from(regionsData.map((data) => '${data['cmpCode']}${data['regCode']}'));
    Set<String> hiveRegionKeys = Set.from(regionsBox.keys);

    // Identify regions in Hive that don't exist in the fetched data
    Set<String> regionsToDelete = hiveRegionKeys.difference(fetchedRegionKeys);

    // Delete regions in Hive that don't exist in the fetched data
    regionsToDelete.forEach((hiveRegionKey) {
      regionsBox.delete(hiveRegionKey);
    });
  } catch (e) {
    print('Error synchronizing Regions from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<List<Map<String, dynamic>>> _fetchWarehousesData() async {
  List<Map<String, dynamic>> warehousesData = [];
  try {
    // Perform HTTP GET request to fetch warehouses data from the API endpoint
    final response = await http.get(Uri.parse('${apiurl}getWarehouses'));
    if (response.statusCode == 200) {
      dynamic responseData = jsonDecode(response.body);
      if (responseData is List) {
        // If the response is a list, append each warehouse data to the warehousesData list
        for (var warehouseData in responseData) {
          if (warehouseData is Map<String, dynamic>) {
            warehousesData.add(warehouseData);
          }
        }
      } else {
        print('Invalid response format for warehouses data');
      }
    } else {
      print('Failed to retrieve warehouses data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching warehouses data: $e');
  }
  return warehousesData;
}

Future<void> synchronizeWarehouses() async {
  try {
    // Fetch data from API endpoint
    List<Map<String, dynamic>> apiResponse = await _fetchWarehousesData();

    // Open Hive box
    var warehousesBox = await Hive.openBox<Warehouses>('warehousesBox');

    // Synchronize data
    await _synchronizeWarehouses(apiResponse, warehousesBox);
  } catch (e) {
    print('Error synchronizing data from API to Hive for Warehouses: $e');
  }
}

Future<void> _synchronizeWarehouses(
  List<Map<String, dynamic>> warehousesData,
  Box<Warehouses> warehousesBox,
) async {
  try {
    for (var data in warehousesData) {
      var cmpCode = data['cmpCode'];
      var whsCode = data['whsCode'];

      // Check if the warehouse exists in Hive
      var hiveWarehouse = warehousesBox.get('$cmpCode$whsCode');

      if (hiveWarehouse == null) {
        var newWarehouse = Warehouses(
          cmpCode: cmpCode,
          whsCode: whsCode,
          whsName: data['whsName'],
          whsFName: data['whsFName'],
          notes: data['notes'],
        );
        await warehousesBox.put('$cmpCode$whsCode', newWarehouse);
      } else {
        var updatedWarehouse = Warehouses(
          cmpCode: cmpCode,
          whsCode: whsCode,
          whsName: data['whsName'],
          whsFName: data['whsFName'],
          notes: data['notes'],
        );
        await warehousesBox.put('$cmpCode$whsCode', updatedWarehouse);
      }
    }

    // Check for warehouses in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedWarehouseKeys =
        Set.from(warehousesData.map((data) => '${data['cmpCode']}${data['whsCode']}'));
    Set<String> hiveWarehouseKeys = Set.from(warehousesBox.keys);

    // Identify warehouses in Hive that don't exist in the fetched data
    Set<String> warehousesToDelete = hiveWarehouseKeys.difference(fetchedWarehouseKeys);

    // Delete warehouses in Hive that don't exist in the fetched data
    warehousesToDelete.forEach((hiveWarehouseKey) {
      warehousesBox.delete(hiveWarehouseKey);
    });
  } catch (e) {
    print('Error synchronizing Warehouses from API to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------


Future<List<Map<String, dynamic>>> _fetchPaymentTermsData() async {
  List<Map<String, dynamic>> paymentTermsData = [];
  try {
    // Perform HTTP GET request to fetch payment terms data from the API endpoint
    final response = await http.get(Uri.parse('${apiurl}getPaymentTerms'));
    if (response.statusCode == 200) {
      dynamic responseData = jsonDecode(response.body);
      if (responseData is List) {
        // If the response is a list, append each payment term data to the paymentTermsData list
        for (var paymentTermData in responseData) {
          if (paymentTermData is Map<String, dynamic>) {
            paymentTermsData.add(paymentTermData);
          }
        }
      } else {
        print('Invalid response format for payment terms data');
      }
    } else {
      print('Failed to retrieve payment terms data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching payment terms data: $e');
  }
  return paymentTermsData;
}

Future<void> synchronizePaymentTerms() async {
  try {
    // Fetch data from API endpoint
    List<Map<String, dynamic>> apiResponse = await _fetchPaymentTermsData();

    // Open Hive box
    var paymentTermsBox = await Hive.openBox<PaymentTerms>('paymentTermsBox');

    // Synchronize data
    await _synchronizePaymentTerms(apiResponse, paymentTermsBox);
  } catch (e) {
    print('Error synchronizing data from API to Hive for PaymentTerms: $e');
  }
}

Future<void> _synchronizePaymentTerms(
  List<Map<String, dynamic>> paymentTermsData,
  Box<PaymentTerms> paymentTermsBox,
) async {
  try {
    for (var data in paymentTermsData) {
      var cmpCode = data['cmpCode'];
      var ptCode = data['ptCode'];

      // Check if the payment term exists in Hive
      var hivePaymentTerm = paymentTermsBox.get('$cmpCode$ptCode');

      if (hivePaymentTerm == null) {
        var newPaymentTerm = PaymentTerms(
          cmpCode: cmpCode,
          ptCode: ptCode,
          ptName: data['ptName'],
          ptFName: data['ptFName'],
          startFrom: data['startFrom'],
          nbrofDays: data['nbrofDays'],
          notes: data['notes'],
        );
        await paymentTermsBox.put('$cmpCode$ptCode', newPaymentTerm);
      } else {
        var updatedPaymentTerm = PaymentTerms(
          cmpCode: cmpCode,
          ptCode: ptCode,
          ptName: data['ptName'],
          ptFName: data['ptFName'],
          startFrom: data['startFrom'],
          nbrofDays: data['nbrofDays'],
          notes: data['notes'],
        );
        await paymentTermsBox.put('$cmpCode$ptCode', updatedPaymentTerm);
      }
    }

    // Check for payment terms in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedPaymentTermKeys =
        Set.from(paymentTermsData.map((data) => '${data['cmpCode']}${data['ptCode']}'));
    Set<String> hivePaymentTermKeys = Set.from(paymentTermsBox.keys);

    // Identify payment terms in Hive that don't exist in the fetched data
    Set<String> paymentTermsToDelete = hivePaymentTermKeys.difference(fetchedPaymentTermKeys);

    // Delete payment terms in Hive that don't exist in the fetched data
    paymentTermsToDelete.forEach((hivePaymentTermKey) {
      paymentTermsBox.delete(hivePaymentTermKey);
    });
  } catch (e) {
    print('Error synchronizing PaymentTerms from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
Future<void> synchronizeSalesEmployees(List<String> seCodes) async {
  try {
    // Fetch data from API endpoint using seCodes
    List<Map<String, dynamic>> apiResponse = await _fetchSalesEmployeesData(seCodes);

    // Open Hive box
    var salesEmployeesBox = await Hive.openBox<SalesEmployees>('salesEmployeesBox');

    // Synchronize data
    await _synchronizeSalesEmployees(apiResponse, salesEmployeesBox);
  } catch (e) {
    print('Error synchronizing data from API to Hive for SalesEmployees: $e');
  }
}
Future<List<Map<String, dynamic>>> _fetchSalesEmployeesData(List<String> seCodes) async {
  List<Map<String, dynamic>> salesEmployeesData = [];
  try {
    // Iterate over each seCode and fetch data for each one
    for (String seCode in seCodes) {
      final response = await http.get(Uri.parse('${apiurl}getSalesEmployees?seCode=$seCode'));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        if (responseData is List) {
          // If the response is a list, append each sales employee data to the salesEmployeesData list
          for (var item in responseData) {
            if (item is Map<String, dynamic>) {
              salesEmployeesData.add(item);
            }
          }
        } else {
          print('Invalid response format for sales employees data');
        }
      } else {
        print('Failed to retrieve sales employees data for seCode $seCode: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error fetching sales employees data: $e');
  }
  return salesEmployeesData;
}

Future<void> _synchronizeSalesEmployees(
  List<Map<String, dynamic>> salesEmployeesData,
  Box<SalesEmployees> salesEmployeesBox,
) async {
  try {
    for (var data in salesEmployeesData) {
      var cmpCode = data['cmpCode'];
      var seCode = data['seCode'];

      // Check if the sales employee exists in Hive
      var hiveSalesEmployee = salesEmployeesBox.get('$cmpCode$seCode');

      if (hiveSalesEmployee == null) {
        var newSalesEmployee = SalesEmployees(
          cmpCode: cmpCode,
          seCode: seCode,
          seName: data['seName'],
          seFName: data['seFName'],
          mobile: data['mobile'],
          email: data['email'],
          whsCode: data['whsCode'],
          reqFromWhsCode: data['reqFromWhsCode'],
          notes: data['notes'],
        );
        await salesEmployeesBox.put('$cmpCode$seCode', newSalesEmployee);
      } else {
        var updatedSalesEmployee = SalesEmployees(
          cmpCode: cmpCode,
          seCode: seCode,
          seName: data['seName'],
          seFName: data['seFName'],
          mobile: data['mobile'],
          email: data['email'],
          whsCode: data['whsCode'],
          reqFromWhsCode: data['reqFromWhsCode'],
          notes: data['notes'],
        );
        await salesEmployeesBox.put('$cmpCode$seCode', updatedSalesEmployee);
      }
    }

    // Check for sales employees in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedSalesEmployeeKeys =
        Set.from(salesEmployeesData.map((data) => '${data['cmpCode']}${data['seCode']}'));
    Set<String> hiveSalesEmployeeKeys = Set.from(salesEmployeesBox.keys);

    // Identify sales employees in Hive that don't exist in the fetched data
    Set<String> salesEmployeesToDelete = hiveSalesEmployeeKeys.difference(fetchedSalesEmployeeKeys);

    // Delete sales employees in Hive that don't exist in the fetched data
    salesEmployeesToDelete.forEach((hiveSalesEmployeeKey) {
      salesEmployeesBox.delete(hiveSalesEmployeeKey);
    });
  } catch (e) {
    print('Error synchronizing SalesEmployees from API to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
Future<void> synchronizeSalesEmployeesCustomers(List<String> seCodes) async {
  try {
    // Fetch data from API endpoint using seCodes
    List<Map<String, dynamic>> apiResponse = await _fetchSalesEmployeesCustomersData(seCodes);

    // Open Hive box
    var salesEmployeesCustomersBox = await Hive.openBox<SalesEmployeesCustomers>('salesEmployeesCustomersBox');

    // Synchronize data
    await _synchronizeSalesEmployeesCustomers(apiResponse, salesEmployeesCustomersBox);
  } catch (e) {
    print('Error synchronizing data from API to Hive for SalesEmployeesCustomers: $e');
  }
}

Future<List<Map<String, dynamic>>> _fetchSalesEmployeesCustomersData(List<String> seCodes) async {
  List<Map<String, dynamic>> salesEmployeesCustomersData = [];
  try {
    // Iterate over each seCode and fetch data for each one
    for (String seCode in seCodes) {
      final response = await http.get(Uri.parse('${apiurl}getSalesEmployeesCustomers?seCode=$seCode'));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        if (responseData is List) {
          // If the response is a list, append each sales employee customer data to the salesEmployeesCustomersData list
          for (var item in responseData) {
            if (item is Map<String, dynamic>) {
              salesEmployeesCustomersData.add(item);
            }
          }
        } else {
          print('Invalid response format for sales employees customers data');
        }
      } else {
        print('Failed to retrieve sales employees customers data for seCode $seCode: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error fetching sales employees customers data: $e');
  }
  return salesEmployeesCustomersData;
}

Future<void> _synchronizeSalesEmployeesCustomers(
  List<Map<String, dynamic>> salesEmployeesCustomersData,
  Box<SalesEmployeesCustomers> salesEmployeesCustomersBox,
) async {
  try {
    for (var data in salesEmployeesCustomersData) {
      var cmpCode = data['cmpCode'];
      var seCode = data['seCode'];
      var custCode = data['custCode'];

      // Check if the sales employee customer relationship exists in Hive
      var hiveSalesEmployeesCustomers = salesEmployeesCustomersBox.get('$cmpCode$seCode$custCode');

      if (hiveSalesEmployeesCustomers == null) {
        var newSalesEmployeesCustomers = SalesEmployeesCustomers(
          cmpCode: cmpCode,
          seCode: seCode,
          custCode: custCode,
          notes: data['notes'],
        );
        await salesEmployeesCustomersBox.put('$cmpCode$seCode$custCode', newSalesEmployeesCustomers);
      } else {
        var updatedSalesEmployeesCustomers = SalesEmployeesCustomers(
          cmpCode: cmpCode,
          seCode: seCode,
          custCode: custCode,
          notes: data['notes'],
        );
        await salesEmployeesCustomersBox.put('$cmpCode$seCode$custCode', updatedSalesEmployeesCustomers);
      }
    }

    // Check for sales employee customers in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedSalesEmployeesCustomersKeys =
        Set.from(salesEmployeesCustomersData.map((data) => '${data['cmpCode']}${data['seCode']}${data['custCode']}'));
    Set<String> hiveSalesEmployeesCustomersKeys = Set.from(salesEmployeesCustomersBox.keys);

    // Identify sales employee customers relationships in Hive that don't exist in the fetched data
    Set<String> salesEmployeesCustomersToDelete = hiveSalesEmployeesCustomersKeys.difference(fetchedSalesEmployeesCustomersKeys);

    // Delete sales employee customers relationships in Hive that don't exist in the fetched data
    salesEmployeesCustomersToDelete.forEach((hiveSalesEmployeesCustomersKey) {
      salesEmployeesCustomersBox.delete(hiveSalesEmployeesCustomersKey);
    });
  } catch (e) {
    print('Error synchronizing SalesEmployeesCustomers from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<void> synchronizeSalesEmployeesDepartments(List<String> seCodes) async {
  try {
    // Fetch data from API endpoint using seCodes
    List<Map<String, dynamic>> apiResponse = await _fetchSalesEmployeesDepartmentsData(seCodes);

    // Open Hive box
    var salesEmployeesDepartmentsBox = await Hive.openBox<SalesEmployeesDepartements>('salesEmployeesDepartmentsBox');

    // Synchronize data
    await _synchronizeSalesEmployeesDepartments(apiResponse, salesEmployeesDepartmentsBox);
  } catch (e) {
    print('Error synchronizing data from API to Hive for SalesEmployeesDepartments: $e');
  }
}

Future<List<Map<String, dynamic>>> _fetchSalesEmployeesDepartmentsData(List<String> seCodes) async {
  List<Map<String, dynamic>> salesEmployeesDepartmentsData = [];
  try {
    // Iterate over each seCode and fetch data for each one
    for (String seCode in seCodes) {
      final response = await http.get(Uri.parse('${apiurl}getSalesEmployeesDepartments?seCode=$seCode'));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        if (responseData is List) {
          // If the response is a list, append each sales employee department data to the salesEmployeesDepartmentsData list
          for (var item in responseData) {
            if (item is Map<String, dynamic>) {
              salesEmployeesDepartmentsData.add(item);
            }
          }
        } else {
          print('Invalid response format for sales employees departments data');
        }
      } else {
        print('Failed to retrieve sales employees departments data for seCode $seCode: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error fetching sales employees departments data: $e');
  }
  return salesEmployeesDepartmentsData;
}

Future<void> _synchronizeSalesEmployeesDepartments(
  List<Map<String, dynamic>> salesEmployeesDepartmentsData,
  Box<SalesEmployeesDepartements> salesEmployeesDepartmentsBox,
) async {
  try {
    for (var data in salesEmployeesDepartmentsData) {
      var cmpCode = data['cmpCode'];
      var seCode = data['seCode'];
      var deptCode = data['deptCode'];

      // Check if the sales employee department relationship exists in Hive
      var hiveSalesEmployeesDepartments = salesEmployeesDepartmentsBox.get('$cmpCode$seCode$deptCode');

      if (hiveSalesEmployeesDepartments == null) {
        var newSalesEmployeesDepartments = SalesEmployeesDepartements(
          cmpCode: cmpCode,
          seCode: seCode,
          deptCode: deptCode,
          reqFromWhsCode: data['reqFromWhsCode'],
          notes: data['notes'],
        );
        await salesEmployeesDepartmentsBox.put('$cmpCode$seCode$deptCode', newSalesEmployeesDepartments);
      } else {
        var updatedSalesEmployeesDepartments = SalesEmployeesDepartements(
          cmpCode: cmpCode,
          seCode: seCode,
          deptCode: deptCode,
          reqFromWhsCode: data['reqFromWhsCode'],
          notes: data['notes'],
        );
        await salesEmployeesDepartmentsBox.put('$cmpCode$seCode$deptCode', updatedSalesEmployeesDepartments);
      }
    }

    // Check for sales employee departments in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedSalesEmployeesDepartmentsKeys =
        Set.from(salesEmployeesDepartmentsData.map((data) => '${data['cmpCode']}${data['seCode']}${data['deptCode']}'));
    Set<String> hiveSalesEmployeesDepartmentsKeys = Set.from(salesEmployeesDepartmentsBox.keys);

    // Identify sales employee departments relationships in Hive that don't exist in the fetched data
    Set<String> salesEmployeesDepartmentsToDelete = hiveSalesEmployeesDepartmentsKeys.difference(fetchedSalesEmployeesDepartmentsKeys);

    // Delete sales employee departments relationships in Hive that don't exist in the fetched data
    salesEmployeesDepartmentsToDelete.forEach((hiveSalesEmployeesDepartmentsKey) {
      salesEmployeesDepartmentsBox.delete(hiveSalesEmployeesDepartmentsKey);
    });
  } catch (e) {
    print('Error synchronizing SalesEmployeesDepartments from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
Future<void> synchronizeSalesEmployeesItemsBrands(List<String> seCodes) async {
  try {
    // Fetch data from API endpoint using seCodes
    List<Map<String, dynamic>> apiResponse = await _fetchSalesEmployeesItemsBrandsData(seCodes);

    // Open Hive box
    var salesEmployeesItemsBrandsBox = await Hive.openBox<SalesEmployeesItemsBrands>('salesEmployeesItemsBrandsBox');

    // Synchronize data
    await _synchronizeSalesEmployeesItemsBrands(apiResponse, salesEmployeesItemsBrandsBox);
  } catch (e) {
    print('Error synchronizing data from API to Hive for SalesEmployeesItemsBrands: $e');
  }
}
Future<List<Map<String, dynamic>>> _fetchSalesEmployeesItemsBrandsData(List<String> seCodes) async {
  List<Map<String, dynamic>> salesEmployeesItemsBrandsData = [];
  try {
    // Iterate over each seCode and fetch data for each one
    for (String seCode in seCodes) {
      final response = await http.get(Uri.parse('${apiurl}getSalesEmployeesItemsBrands?seCode=$seCode'));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        if (responseData is List) {
          // If the response is a list, append each sales employee items brands data to the salesEmployeesItemsBrandsData list
          for (var item in responseData) {
            if (item is Map<String, dynamic>) {
              salesEmployeesItemsBrandsData.add(item);
            }
          }
        } else {
          print('Invalid response format for sales employees items brands data');
        }
      } else {
        print('Failed to retrieve sales employees items brands data for seCode $seCode: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error fetching sales employees items brands data: $e');
  }
  return salesEmployeesItemsBrandsData;
}


Future<void> _synchronizeSalesEmployeesItemsBrands(
  List<Map<String, dynamic>> salesEmployeesItemsBrandsData,
  Box<SalesEmployeesItemsBrands> salesEmployeesItemsBrandsBox,
) async {
  try {
    for (var data in salesEmployeesItemsBrandsData) {
      var cmpCode = data['cmpCode'];
      var seCode = data['seCode'];
      var brandCode = data['brandCode'];

      // Check if the sales employee items brands relationship exists in Hive
      var hiveSalesEmployeesItemsBrands = salesEmployeesItemsBrandsBox.get('$cmpCode$seCode$brandCode');

      if (hiveSalesEmployeesItemsBrands == null) {
        var newSalesEmployeesItemsBrands = SalesEmployeesItemsBrands(
          cmpCode: cmpCode,
          seCode: seCode,
          brandCode: brandCode,
          reqFromWhsCode: data['reqFromWhsCode'],
          notes: data['notes'],
        );
        await salesEmployeesItemsBrandsBox.put('$cmpCode$seCode$brandCode', newSalesEmployeesItemsBrands);
      } else {
        var updatedSalesEmployeesItemsBrands = SalesEmployeesItemsBrands(
          cmpCode: cmpCode,
          seCode: seCode,
          brandCode: brandCode,
          reqFromWhsCode: data['reqFromWhsCode'],
          notes: data['notes'],
        );
        await salesEmployeesItemsBrandsBox.put('$cmpCode$seCode$brandCode', updatedSalesEmployeesItemsBrands);
      }
    }

    // Check for sales employee items brands in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedSalesEmployeesItemsBrandsKeys =
        Set.from(salesEmployeesItemsBrandsData.map((data) => '${data['cmpCode']}${data['seCode']}${data['brandCode']}'));
    Set<String> hiveSalesEmployeesItemsBrandsKeys = Set.from(salesEmployeesItemsBrandsBox.keys);

    // Identify sales employee items brands relationships in Hive that don't exist in the fetched data
    Set<String> salesEmployeesItemsBrandsToDelete = hiveSalesEmployeesItemsBrandsKeys.difference(fetchedSalesEmployeesItemsBrandsKeys);

    // Delete sales employee items brands relationships in Hive that don't exist in the fetched data
    salesEmployeesItemsBrandsToDelete.forEach((hiveSalesEmployeesItemsBrandsKey) {
      salesEmployeesItemsBrandsBox.delete(hiveSalesEmployeesItemsBrandsKey);
    });
  } catch (e) {
    print('Error synchronizing SalesEmployeesItemsBrands from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<void> synchronizeSalesEmployeesItemsCategories(List<String> seCodes) async {
  try {
    // Fetch data from API endpoint using seCodes
    List<Map<String, dynamic>> apiResponse = await _fetchSalesEmployeesItemsCategoriesData(seCodes);

    // Open Hive box
    var salesEmployeesItemsCategoriesBox =
        await Hive.openBox<SalesEmployeesItemsCategories>('salesEmployeesItemsCategoriesBox');

    // Synchronize data
    await _synchronizeSalesEmployeesItemsCategories(apiResponse, salesEmployeesItemsCategoriesBox);
  } catch (e) {
    print('Error synchronizing data from API to Hive for SalesEmployeesItemsCategories: $e');
  }
}

Future<List<Map<String, dynamic>>> _fetchSalesEmployeesItemsCategoriesData(List<String> seCodes) async {
  List<Map<String, dynamic>> salesEmployeesItemsCategoriesData = [];
  try {
    // Iterate over each seCode and fetch data for each one
    for (String seCode in seCodes) {
      final response = await http.get(Uri.parse('${apiurl}getSalesEmployeesItemsCategories?seCode=$seCode'));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        if (responseData is List) {
          // If the response is a list, append each sales employee items categories data to the salesEmployeesItemsCategoriesData list
          for (var item in responseData) {
            if (item is Map<String, dynamic>) {
              salesEmployeesItemsCategoriesData.add(item);
            }
          }
        } else {
          print('Invalid response format for sales employees items categories data');
        }
      } else {
        print('Failed to retrieve sales employees items categories data for seCode $seCode: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error fetching sales employees items categories data: $e');
  }
  return salesEmployeesItemsCategoriesData;
}

Future<void> _synchronizeSalesEmployeesItemsCategories(
  List<Map<String, dynamic>> salesEmployeesItemsCategoriesData,
  Box<SalesEmployeesItemsCategories> salesEmployeesItemsCategoriesBox,
) async {
  try {
    for (var data in salesEmployeesItemsCategoriesData) {
      var cmpCode = data['cmpCode'];
      var seCode = data['seCode'];
      var categCode = data['categCode'];

      // Check if the sales employee items categories relationship exists in Hive
      var hiveSalesEmployeesItemsCategories = salesEmployeesItemsCategoriesBox.get('$cmpCode$seCode$categCode');

      if (hiveSalesEmployeesItemsCategories == null) {
        var newSalesEmployeesItemsCategories = SalesEmployeesItemsCategories(
          cmpCode: cmpCode,
          seCode: seCode,
          categCode: categCode,
          reqFromWhsCode: data['reqFromWhsCode'],
          notes: data['notes'],
        );
        await salesEmployeesItemsCategoriesBox.put('$cmpCode$seCode$categCode', newSalesEmployeesItemsCategories);
      } else {
        var updatedSalesEmployeesItemsCategories = SalesEmployeesItemsCategories(
          cmpCode: cmpCode,
          seCode: seCode,
          categCode: categCode,
          reqFromWhsCode: data['reqFromWhsCode'],
          notes: data['notes'],
        );
        await salesEmployeesItemsCategoriesBox.put('$cmpCode$seCode$categCode', updatedSalesEmployeesItemsCategories);
      }
    }

    // Check for sales employee items categories in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedSalesEmployeesItemsCategoriesKeys =
        Set.from(salesEmployeesItemsCategoriesData.map((data) => '${data['cmpCode']}${data['seCode']}${data['categCode']}'));
    Set<String> hiveSalesEmployeesItemsCategoriesKeys = Set.from(salesEmployeesItemsCategoriesBox.keys);

    // Identify sales employee items categories relationships in Hive that don't exist in the fetched data
    Set<String> salesEmployeesItemsCategoriesToDelete = hiveSalesEmployeesItemsCategoriesKeys.difference(fetchedSalesEmployeesItemsCategoriesKeys);

    // Delete sales employee items categories relationships in Hive that don't exist in the fetched data
    salesEmployeesItemsCategoriesToDelete.forEach((hiveSalesEmployeesItemsCategoriesKey) {
      salesEmployeesItemsCategoriesBox.delete(hiveSalesEmployeesItemsCategoriesKey);
    });
  } catch (e) {
    print('Error synchronizing SalesEmployeesItemsCategories from API to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
Future<void> synchronizeSalesEmployeesItemsGroups(List<String> seCodes) async {
  try {
    // Fetch data from API endpoint using seCodes
    List<Map<String, dynamic>> apiResponse = await _fetchSalesEmployeesItemsGroupsData(seCodes);

    // Open Hive box
    var salesEmployeesItemsGroupsBox =
        await Hive.openBox<SalesEmployeesItemsGroups>('salesEmployeesItemsGroupsBox');

    // Synchronize data
    await _synchronizeSalesEmployeesItemsGroups(apiResponse, salesEmployeesItemsGroupsBox);
  } catch (e) {
    print('Error synchronizing data from API to Hive for SalesEmployeesItemsGroups: $e');
  }
}

Future<List<Map<String, dynamic>>> _fetchSalesEmployeesItemsGroupsData(List<String> seCodes) async {
  List<Map<String, dynamic>> salesEmployeesItemsGroupsData = [];
  try {
    // Iterate over each seCode and fetch data for each one
    for (String seCode in seCodes) {
      final response = await http.get(Uri.parse('${apiurl}getSalesEmployeesItemsGroups?seCode=$seCode'));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        if (responseData is List) {
          // If the response is a list, append each sales employee items groups data to the salesEmployeesItemsGroupsData list
          for (var item in responseData) {
            if (item is Map<String, dynamic>) {
              salesEmployeesItemsGroupsData.add(item);
            }
          }
        } else {
          print('Invalid response format for sales employees items groups data');
        }
      } else {
        print('Failed to retrieve sales employees items groups data for seCode $seCode: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error fetching sales employees items groups data: $e');
  }
  return salesEmployeesItemsGroupsData;
}

Future<void> _synchronizeSalesEmployeesItemsGroups(
  List<Map<String, dynamic>> salesEmployeesItemsGroupsData,
  Box<SalesEmployeesItemsGroups> salesEmployeesItemsGroupsBox,
) async {
  try {
    for (var data in salesEmployeesItemsGroupsData) {
      var cmpCode = data['cmpCode'];
      var seCode = data['seCode'];
      var groupCode = data['groupCode'];

      // Check if the sales employee items groups relationship exists in Hive
      var hiveSalesEmployeesItemsGroups = salesEmployeesItemsGroupsBox.get('$cmpCode$seCode$groupCode');

      if (hiveSalesEmployeesItemsGroups == null) {
        var newSalesEmployeesItemsGroups = SalesEmployeesItemsGroups(
          cmpCode: cmpCode,
          seCode: seCode,
          groupCode: groupCode,
          reqFromWhsCode: data['reqFromWhsCode'],
          notes: data['notes'],
        );
        await salesEmployeesItemsGroupsBox.put('$cmpCode$seCode$groupCode', newSalesEmployeesItemsGroups);
      } else {
        var updatedSalesEmployeesItemsGroups = SalesEmployeesItemsGroups(
          cmpCode: cmpCode,
          seCode: seCode,
          groupCode: groupCode,
          reqFromWhsCode: data['reqFromWhsCode'],
          notes: data['notes'],
        );
        await salesEmployeesItemsGroupsBox.put('$cmpCode$seCode$groupCode', updatedSalesEmployeesItemsGroups);
      }
    }

    // Check for sales employee items groups in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedSalesEmployeesItemsGroupsKeys =
        Set.from(salesEmployeesItemsGroupsData.map((data) => '${data['cmpCode']}${data['seCode']}${data['groupCode']}'));
    Set<String> hiveSalesEmployeesItemsGroupsKeys = Set.from(salesEmployeesItemsGroupsBox.keys);

    // Identify sales employee items groups relationships in Hive that don't exist in the fetched data
    Set<String> salesEmployeesItemsGroupsToDelete = hiveSalesEmployeesItemsGroupsKeys.difference(fetchedSalesEmployeesItemsGroupsKeys);

    // Delete sales employee items groups relationships in Hive that don't exist in the fetched data
    salesEmployeesItemsGroupsToDelete.forEach((hiveSalesEmployeesItemsGroupsKey) {
      salesEmployeesItemsGroupsBox.delete(hiveSalesEmployeesItemsGroupsKey);
    });
  } catch (e) {
    print('Error synchronizing SalesEmployeesItemsGroups from API to Hive: $e');
  }
}



//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
Future<void> synchronizeSalesEmployeesItems(List<String> seCodes) async {
  try {
    // Fetch data from API endpoint using seCodes
    List<Map<String, dynamic>> apiResponse = await _fetchSalesEmployeesItemsData(seCodes);

    // Open Hive box
    var salesEmployeesItemsBox = await Hive.openBox<SalesEmployeesItems>('salesEmployeesItemsBox');

    // Synchronize data
    await _synchronizeSalesEmployeesItems(apiResponse, salesEmployeesItemsBox);
  } catch (e) {
    print('Error synchronizing data from API to Hive for SalesEmployeesItems: $e');
  }
}

Future<List<Map<String, dynamic>>> _fetchSalesEmployeesItemsData(List<String> seCodes) async {
  List<Map<String, dynamic>> salesEmployeesItemsData = [];
  try {
    // Iterate over each seCode and fetch data for each one
    for (String seCode in seCodes) {
      final response = await http.get(Uri.parse('${apiurl}getSalesEmployeesItems?seCode=$seCode'));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        if (responseData is List) {
          // If the response is a list, append each sales employee items data to the salesEmployeesItemsData list
          for (var item in responseData) {
            if (item is Map<String, dynamic>) {
              salesEmployeesItemsData.add(item);
            }
          }
        } else {
          print('Invalid response format for sales employees items data');
        }
      } else {
        print('Failed to retrieve sales employees items data for seCode $seCode: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error fetching sales employees items data: $e');
  }
  return salesEmployeesItemsData;
}

Future<void> _synchronizeSalesEmployeesItems(
  List<Map<String, dynamic>> salesEmployeesItemsData,
  Box<SalesEmployeesItems> salesEmployeesItemsBox,
) async {
  try {
    for (var data in salesEmployeesItemsData) {
      var cmpCode = data['cmpCode'];
      var seCode = data['seCode'];
      var itemCode = data['itemCode'];

      // Check if the sales employee items relationship exists in Hive
      var hiveSalesEmployeesItems = salesEmployeesItemsBox.get('$cmpCode$seCode$itemCode');

      if (hiveSalesEmployeesItems == null) {
        var newSalesEmployeesItems = SalesEmployeesItems(
          cmpCode: cmpCode,
          seCode: seCode,
          itemCode: itemCode,
          reqFromWhsCode: data['reqFromWhsCode'],
          notes: data['notes'],
        );
        await salesEmployeesItemsBox.put('$cmpCode$seCode$itemCode', newSalesEmployeesItems);
      } else {
        var updatedSalesEmployeesItems = SalesEmployeesItems(
          cmpCode: cmpCode,
          seCode: seCode,
          itemCode: itemCode,
          reqFromWhsCode: data['reqFromWhsCode'],
          notes: data['notes'],
        );
        await salesEmployeesItemsBox.put('$cmpCode$seCode$itemCode', updatedSalesEmployeesItems);
      }
    }

    // Check for sales employee items in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedSalesEmployeesItemsKeys =
        Set.from(salesEmployeesItemsData.map((data) => '${data['cmpCode']}${data['seCode']}${data['itemCode']}'));
    Set<String> hiveSalesEmployeesItemsKeys = Set.from(salesEmployeesItemsBox.keys);

    // Identify sales employee items relationships in Hive that don't exist in the fetched data
    Set<String> salesEmployeesItemsToDelete = hiveSalesEmployeesItemsKeys.difference(fetchedSalesEmployeesItemsKeys);

    // Delete sales employee items relationships in Hive that don't exist in the fetched data
    salesEmployeesItemsToDelete.forEach((hiveSalesEmployeesItemsKey) {
      salesEmployeesItemsBox.delete(hiveSalesEmployeesItemsKey);
    });
  } catch (e) {
    print('Error synchronizing SalesEmployeesItems from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
Future<void> synchronizeUserSalesEmployees() async {
  try {
    // Fetch data from API endpoint
    List<Map<String, dynamic>> apiResponse = await _fetchUserSalesEmployeesData();

    // Open Hive box
    var userSalesEmployeesBox = await Hive.openBox<UserSalesEmployees>('userSalesEmployeesBox');

    // Synchronize data
    await _synchronizeUserSalesEmployees(apiResponse, userSalesEmployeesBox);
  } catch (e) {
    print('Error synchronizing data from API to Hive for UserSalesEmployees: $e');
  }
}

Future<List<Map<String, dynamic>>> _fetchUserSalesEmployeesData() async {
  List<Map<String, dynamic>> userSalesEmployeesData = [];
  try {
    // Perform HTTP GET request to fetch user sales employees data from the API endpoint
    final response = await http.get(Uri.parse('${apiurl}getUserSalesEmployees'));
    if (response.statusCode == 200) {
      dynamic responseData = jsonDecode(response.body);
      if (responseData is List) {
        // If the response is a list, append each user sales employees data to the userSalesEmployeesData list
        for (var item in responseData) {
          if (item is Map<String, dynamic>) {
            userSalesEmployeesData.add(item);
          }
        }
      } else {
        print('Invalid response format for user sales employees data');
      }
    } else {
      print('Failed to retrieve user sales employees data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching user sales employees data: $e');
  }
  return userSalesEmployeesData;
}

Future<void> _synchronizeUserSalesEmployees(
  List<Map<String, dynamic>> userSalesEmployeesData,
  Box<UserSalesEmployees> userSalesEmployeesBox,
) async {
  try {
    for (var data in userSalesEmployeesData) {
      var userCode = data['userCode'];
      var cmpCode = data['cmpCode'];
      var seCode = data['seCode'];

      // Check if the user sales employees relationship exists in Hive
      var hiveUserSalesEmployees = userSalesEmployeesBox.get('$userCode$cmpCode$seCode');

      if (hiveUserSalesEmployees == null) {
        var newUserSalesEmployees = UserSalesEmployees(
          cmpCode: cmpCode,
          userCode: userCode,
          seCode: seCode,
          notes: data['notes'],
        );
        await userSalesEmployeesBox.put('$userCode$cmpCode$seCode', newUserSalesEmployees);
      } else {
        var updatedUserSalesEmployees = UserSalesEmployees(
          cmpCode: cmpCode,
          userCode: userCode,
          seCode: seCode,
          notes: data['notes'],
        );
        await userSalesEmployeesBox.put('$userCode$cmpCode$seCode', updatedUserSalesEmployees);
      }
    }

    // Check for user sales employees in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedUserSalesEmployeesKeys =
        Set.from(userSalesEmployeesData.map((data) => '${data['userCode']}${data['cmpCode']}${data['seCode']}'));
    Set<String> hiveUserSalesEmployeesKeys = Set.from(userSalesEmployeesBox.keys);

    // Identify user sales employees relationships in Hive that don't exist in the fetched data
    Set<String> userSalesEmployeesToDelete = hiveUserSalesEmployeesKeys.difference(fetchedUserSalesEmployeesKeys);

    // Delete user sales employees relationships in Hive that don't exist in the fetched data
    userSalesEmployeesToDelete.forEach((hiveUserSalesEmployeesKey) {
      userSalesEmployeesBox.delete(hiveUserSalesEmployeesKey);
    });
  } catch (e) {
    print('Error synchronizing UserSalesEmployees from API to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
Future<List<String>> retrieveCustCodes(List<String> seCodes) async {
  List<String> custCodes = [];
  try {
    for (String seCode in seCodes) {
      final response = await http.get(Uri.parse('${apiurl}getSalesEmployeesCustomers?seCode=$seCode'));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        if (responseData is List) {
          responseData.forEach((item) {
            if (item is Map<String, dynamic>) {
              custCodes.add(item['custCode']);
            }
          });
        } else {
          print('Invalid response format for customer codes data');
        }
      } else {
        print('Failed to retrieve customer codes data for seCode $seCode: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error retrieving customer codes: $e');
  }
  return custCodes;
}

Future<void> synchronizeCustomers(List<String> custCodes) async {
  try {
    // Fetch data from API endpoint using custCodes
    List<Map<String, dynamic>> apiResponse = await _fetchCustomersData(custCodes);

    // Open Hive box
    var customersBox = await Hive.openBox<Customers>('customersBox');

    // Synchronize data
    await _synchronizeCustomers(apiResponse, customersBox);
  } catch (e) {
    print('Error synchronizing data from API to Hive for Customers: $e');
  }
}

Future<List<Map<String, dynamic>>> _fetchCustomersData(List<String> custCodes) async {
  List<Map<String, dynamic>> customersData = [];
  try {
    for (String custCode in custCodes) {
      final response = await http.get(Uri.parse('${apiurl}getCustomers?custCode=$custCode'));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        if (responseData is Map<String, dynamic>) {
          customersData.add(responseData);
        } else {
          print('Invalid response format for customer data');
        }
      } else {
        print('Failed to retrieve customer data for custCode $custCode: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error fetching customer data: $e');
  }
  return customersData;
}

Future<void> _synchronizeCustomers(
  List<Map<String, dynamic>> customersData,
  Box<Customers> customers,
) async {
  try {
    for (var data in customersData) {
      var cmpCode = data['cmpCode'];
      var custCode = data['custCode'];

      // Check if the customer exists in Hive
      var hiveCustomer = customers.get('$cmpCode$custCode');

      if (hiveCustomer == null) {
        var newCustomer = Customers(
          cmpCode: data['cmpCode'],
          custCode: data['custCode'],
          custName: data['custName'],
          custFName: data['custFName'],
          groupCode: data['groupCode'],
          mofNum: data['mofNum'],
          barcode: data['barcode'],
          phone: data['phone'],
          mobile: data['mobile'],
          fax: data['fax'],
          website: data['website'],
          email: data['email'],
          active: data['active'],
          printLayout: data['printLayout'],
          dfltAddressID: data['dfltAddressID'],
          dfltContactID: data['dfltContactID'],
          curCode: data['curCode'],
          cashClient: data['cashClient'],
          discType: data['discType'],
          vatCode: data['vatCode'],
          prListCode: data['prListCode'],
          payTermsCode: data['payTermsCode'],
          discount: data['discount'],
          creditLimit: data['creditLimit'],
          balance: data['balance'],
          balanceDue: data['balanceDue'],
          notes: data['notes'],
        );
        await customers.put('$cmpCode$custCode', newCustomer);
      } else {
        var updatedCustomer = Customers(
          cmpCode: data['cmpCode'],
          custCode: data['custCode'],
          custName: data['custName'],
          custFName: data['custFName'],
          groupCode: data['groupCode'],
          mofNum: data['mofNum'],
          barcode: data['barcode'],
          phone: data['phone'],
          mobile: data['mobile'],
          fax: data['fax'],
          website: data['website'],
          email: data['email'],
          active: data['active'],
          printLayout: data['printLayout'],
          dfltAddressID: data['dfltAddressID'],
          dfltContactID: data['dfltContactID'],
          curCode: data['curCode'],
          cashClient: data['cashClient'],
          discType: data['discType'],
          vatCode: data['vatCode'],
          prListCode: data['prListCode'],
          payTermsCode: data['payTermsCode'],
          discount: data['discount'],
          creditLimit: data['creditLimit'],
          balance: data['balance'],
          balanceDue: data['balanceDue'],
          notes: data['notes'],
        );
        await customers.put('$cmpCode$custCode', updatedCustomer);
      }
    }

    Set<String> customersKeys = Set.from(customersData.map((data) => '${data['cmpCode']}${data['custCode']}'));
    Set<String> hiveCustomersKeys = Set.from(customers.keys);

    // Identify customers in Hive that don't exist in the fetched data
    Set<String> customersToDelete = hiveCustomersKeys.difference(customersKeys);

    // Delete customers in Hive that don't exist in the fetched data
    customersToDelete.forEach((hiveCustomerKey) {
      customers.delete(hiveCustomerKey);
    });
  } catch (e) {
    print('Error synchronizing Customers from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
Future<void> synchronizeCustomerAddresses(List<String> custCodes) async {
  try {
    // Fetch data from API endpoint
    List<Map<String, dynamic>> apiResponse = await _fetchCustomerAddressesData(custCodes);

    // Open Hive box
    var addressesBox = await Hive.openBox<CustomerAddresses>('customerAddressesBox');

    // Synchronize data
    await _synchronizeCustomerAddresses(apiResponse, addressesBox);
  } catch (e) {
    print('Error synchronizing data from API to Hive for CustomerAddresses: $e');
  }
}

Future<List<Map<String, dynamic>>> _fetchCustomerAddressesData(List<String> custCodes) async {
  List<Map<String, dynamic>> addressesData = [];
  try {
    for (String custCode in custCodes) {
      final response = await http.get(Uri.parse('${apiurl}getCustomerAddresses?custCode=$custCode'));
      if (response.statusCode == 200) {
       List<Map<String, dynamic>> responseData = jsonDecode(response.body);
        if (responseData is List) {
          addressesData.addAll(responseData);
        } else {
          print('Invalid response format for customer addresses data');
        }
      } else {
        print('Failed to retrieve customer addresses data for custCode $custCode: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error fetching customer addresses data: $e');
  }
  return addressesData;
}

Future<void> _synchronizeCustomerAddresses(
  List<Map<String, dynamic>> addressesData,
  Box<CustomerAddresses> addresses,
) async {
  try {
    for (var data in addressesData) {
      var cmpCode = data['cmpCode'];
      var addressID = data['addressID'];
      var custCode = data['custCode'];

      // Check if the address exists in Hive
      var hiveAddress = addresses.get('$cmpCode$addressID$custCode');

      if (hiveAddress == null) {
        var newAddress = CustomerAddresses(
          cmpCode: data['cmpCode'],
          custCode: data['custCode'],
          addressID: data['addressID'],
          address: data['address'],
          fAddress: data['fAddress'],
          regCode: data['regCode'],
          gpslat: data['gpslat'],
          gpslong: data['gpslong'],
          notes: data['notes'],
        );
        await addresses.put('$cmpCode$addressID$custCode', newAddress);
      } else {
        var updatedAddress = CustomerAddresses(
          cmpCode: data['cmpCode'],
          custCode: data['custCode'],
          addressID: data['addressID'],
          address: data['address'],
          fAddress: data['fAddress'],
          regCode: data['regCode'],
          gpslat: data['gpslat'],
          gpslong: data['gpslong'],
          notes: data['notes'],
        );
        await addresses.put('$cmpCode$addressID$custCode', updatedAddress);
      }
    }

    Set<String> addressesKeys = Set.from(addressesData.map((data) => '${data['cmpCode']}${data['addressID']}${data['custCode']}'));
    Set<String> hiveAddressesKeys = Set.from(addresses.keys);

    // Identify addresses in Hive that don't exist in the fetched data
    Set<String> addressesToDelete = hiveAddressesKeys.difference(addressesKeys);

    // Delete addresses in Hive that don't exist in the fetched data
    addressesToDelete.forEach((hiveAddressKey) {
      addresses.delete(hiveAddressKey);
    });
  } catch (e) {
    print('Error synchronizing CustomerAddresses from API to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
Future<void> synchronizeCustomerContacts(List<String> custCodes) async {
  try {
    // Fetch data from API endpoint
    List<Map<String, dynamic>> apiResponse = await _fetchCustomerContactsData(custCodes);

    // Open Hive box
    var contactsBox = await Hive.openBox<CustomerContacts>('customerContactsBox');

    // Synchronize data
    await _synchronizeCustomerContacts(apiResponse, contactsBox);
  } catch (e) {
    print('Error synchronizing data from API to Hive for CustomerContacts: $e');
  }
}
Future<List<Map<String, dynamic>>> _fetchCustomerContactsData(List<String> custCodes) async {
  List<Map<String, dynamic>> contactsData = [];
  try {
    for (String custCode in custCodes) {
      final response = await http.get(Uri.parse('${apiurl}getCustomerContacts?custCode=$custCode'));
      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        if (responseData is List) {
          contactsData.addAll(responseData.cast<Map<String, dynamic>>());
        } else {
          print('Invalid response format for customer contacts data');
        }
      } else {
        print('Failed to retrieve customer contacts data for custCode $custCode: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error fetching customer contacts data: $e');
  }
  return contactsData;
}

Future<void> _synchronizeCustomerContacts(
  List<Map<String, dynamic>> contactsData,
  Box<CustomerContacts> contacts,
) async {
  try {
    for (var data in contactsData) {
      var cmpCode = data['cmpCode'];
      var contactID = data['contactID'];
      var custCode = data['custCode'];

      // Check if the contact exists in Hive
      var hiveContact = contacts.get('$cmpCode$contactID$custCode');

      if (hiveContact == null) {
        var newContact = CustomerContacts(
          cmpCode: data['cmpCode'],
          custCode: data['custCode'],
          contactID: data['contactID'],
          contactName: data['contactName'],
          contactFName: data['contactFName'],
          phone: data['phone'],
          mobile: data['mobile'],
          email: data['email'],
          position: data['position'],
          notes: data['notes'],
        );
        await contacts.put('$cmpCode$contactID$custCode', newContact);
      } else {
        var updatedContact = CustomerContacts(
          cmpCode: data['cmpCode'],
          custCode: data['custCode'],
          contactID: data['contactID'],
          contactName: data['contactName'],
          contactFName: data['contactFName'],
          phone: data['phone'],
          mobile: data['mobile'],
          email: data['email'],
          position: data['position'],
          notes: data['notes'],
        );
        await contacts.put('$cmpCode$contactID$custCode', updatedContact);
      }
    }

    Set<String> contactsKeys = Set.from(contactsData.map((data) => '${data['cmpCode']}${data['contactID']}${data['custCode']}'));
    Set<String> hiveContactsKeys = Set.from(contacts.keys);

    // Identify contacts in Hive that don't exist in the fetched data
    Set<String> contactsToDelete = hiveContactsKeys.difference(contactsKeys);

    // Delete contacts in Hive that don't exist in the fetched data
    contactsToDelete.forEach((hiveContactKey) {
      contacts.delete(hiveContactKey);
    });
  } catch (e) {
    print('Error synchronizing CustomerContacts from API to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
Future<void> synchronizeCustomerProperties(List<String> custCodes) async {
  try {
    // Fetch data from API endpoint
    List<Map<String, dynamic>> apiResponse = await _fetchCustomerPropertiesData(custCodes);

    // Open Hive box
    var propertiesBox = await Hive.openBox<CustomerProperties>('customerPropertiesBox');

    // Synchronize data
    await _synchronizeCustomerProperties(apiResponse, propertiesBox);
  
  } catch (e) {
    print('Error synchronizing data from API to Hive for CustomerProperties: $e');
  }
}

Future<List<Map<String, dynamic>>> _fetchCustomerPropertiesData(List<String> custCodes) async {
  List<Map<String, dynamic>> customerPropertiesData = [];
  try {
    // Iterate over each custCode and fetch data for each one
    for (String custCode in custCodes) {
      // Make API call to fetch customer properties data
      var response = await http.get(Uri.parse('${apiurl}getCustomerProperties?custCode=$custCode'));
      if (response.statusCode == 200) {
        // Parse the response data
        dynamic responseData = jsonDecode(response.body);
        if (responseData is List) {
          // If the response is a list, append each customer properties data to the customerPropertiesData list
          for (var item in responseData) {
            if (item is Map<String, dynamic>) {
              customerPropertiesData.add(item);
            }
          }
        } else {
          print('Invalid response format for customer properties data');
        }
      } else {
        print('Failed to retrieve customer properties data for custCode $custCode: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error fetching customer properties data: $e');
  }
  return customerPropertiesData;
}

Future<void> _synchronizeCustomerProperties(
  List<Map<String, dynamic>> customerPropertiesData,
  Box<CustomerProperties> properties,
) async {
  try {
    // Iterate over the retrieved data
    for (var data in customerPropertiesData) {
      var cmpCode = data['cmpCode'];
      var custCode = data['custCode'];
      var propCode = data['propCode'];

      // Check if the property exists in Hive
      var hiveProperty = properties.get('$cmpCode$propCode$custCode');

      // If the property doesn't exist in Hive, add it
      if (hiveProperty == null) {
        var newProperty = CustomerProperties(
          cmpCode: cmpCode,
          custCode: custCode,
          propCode: propCode,
          notes: data['notes'],
        );
        await properties.put('$cmpCode$propCode$custCode', newProperty);
      }
      // If the property exists in Hive, update it if needed
      else {
        var updatedProperty = CustomerProperties(
          cmpCode: cmpCode,
          custCode: custCode,
          propCode: propCode,
          notes: data['notes'],
        );
        // Update the property in Hive
        await properties.put('$cmpCode$propCode$custCode', updatedProperty);
      }
    }

    // Check for properties in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedPropertiesKeys = Set.from(customerPropertiesData.map((data) => '${data['cmpCode']}${data['propCode']}${data['custCode']}'));
    Set<String> hivePropertiesKeys = Set.from(properties.keys);

    // Identify properties in Hive that don't exist in the fetched data
    Set<String> propertiesToDelete = hivePropertiesKeys.difference(fetchedPropertiesKeys);

    // Delete properties in Hive that don't exist in the fetched data
    propertiesToDelete.forEach((hivePropertyKey) {
      properties.delete(hivePropertyKey);
    });
  } catch (e) {
    print('Error synchronizing CustomerProperties from API to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
Future<void> synchronizeCustomerAttachments(List<String> custCodes) async {
  try {
    // Fetch data from API endpoint
    List<Map<String, dynamic>> apiResponse = await _fetchCustomerAttachmentsData(custCodes);

    // Open Hive box
    var attachmentsBox = await Hive.openBox<CustomerAttachments>('customerAttachmentsBox');

    // Synchronize data
    await _synchronizeCustomerAttachments(apiResponse, attachmentsBox);
  
  } catch (e) {
    print('Error synchronizing data from API to Hive for CustomerAttachments: $e');
  }
}

Future<List<Map<String, dynamic>>> _fetchCustomerAttachmentsData(List<String> custCodes) async {
  List<Map<String, dynamic>> customerAttachmentsData = [];
  try {
    // Iterate over each custCode and fetch data for each one
    for (String custCode in custCodes) {
      // Make API call to fetch customer attachments data
      var response = await http.get(Uri.parse('${apiurl}getCustomerAttachments?custCode=$custCode'));
      if (response.statusCode == 200) {
        // Parse the response data
        dynamic responseData = jsonDecode(response.body);
        if (responseData is List) {
          // If the response is a list, append each customer attachments data to the customerAttachmentsData list
          for (var item in responseData) {
            if (item is Map<String, dynamic>) {
              customerAttachmentsData.add(item);
            }
          }
        } else {
          print('Invalid response format for customer attachments data');
        }
      } else {
        print('Failed to retrieve customer attachments data for custCode $custCode: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error fetching customer attachments data: $e');
  }
  return customerAttachmentsData;
}

Future<void> _synchronizeCustomerAttachments(
  List<Map<String, dynamic>> customerAttachmentsData,
  Box<CustomerAttachments> attachments,
) async {
  try {
    // Iterate over the retrieved data
    for (var data in customerAttachmentsData) {
      var cmpCode = data['cmpCode'];
      var custCode = data['custCode'];

      // Check if the attachment exists in Hive
      var hiveAttachment = attachments.get('$cmpCode$custCode');

      // If the attachment doesn't exist in Hive, add it
      if (hiveAttachment == null) {
        var newAttachment = CustomerAttachments(
          cmpCode: cmpCode,
          custCode: custCode,
          attach: data['attach'],
          attachType: data['attachType'],
          notes: data['notes'],
        );
        await attachments.put('$cmpCode$custCode', newAttachment);
      }
      // If the attachment exists in Hive, update it if needed
      else {
        var updatedAttachment = CustomerAttachments(
          cmpCode: cmpCode,
          custCode: custCode,
          attach: data['attach'],
          attachType: data['attachType'],
          notes: data['notes'],
        );
        // Update the attachment in Hive
        await attachments.put('$cmpCode$custCode', updatedAttachment);
      }
    }

    // Check for attachments in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedAttachmentsKeys = Set.from(customerAttachmentsData.map((data) => '${data['cmpCode']}${data['custCode']}'));
    Set<String> hiveAttachmentsKeys = Set.from(attachments.keys);

    // Identify attachments in Hive that don't exist in the fetched data
    Set<String> attachmentsToDelete = hiveAttachmentsKeys.difference(fetchedAttachmentsKeys);

    // Delete attachments in Hive that don't exist in the fetched data
    attachmentsToDelete.forEach((hiveAttachmentKey) {
      attachments.delete(hiveAttachmentKey);
    });
  } catch (e) {
    print('Error synchronizing CustomerAttachments from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
Future<void> synchronizeCustomerItemsSpecialPrice(List<String> custCodes, List<String> itemCodes) async {
  try {
    // Fetch data from API endpoint without filtering by itemCodes in the query
    var apiResponse = await _fetchCustomerItemsSpecialPriceData(custCodes);

    // Filter the results based on itemCodes in Dart code
    var filteredApiResponse = apiResponse.where((data) => itemCodes.contains(data['itemCode'])).toList();

    // Open Hive box
    var specialPriceBox = await Hive.openBox<CustomerItemsSpecialPrice>('customerItemsSpecialPriceBox');

    // Synchronize data
    await _synchronizeCustomerItemsSpecialPrice(filteredApiResponse, specialPriceBox);
  } catch (e) {
    print('Error synchronizing data from API to Hive for CustomerItemsSpecialPrice: $e');
  }
}

Future<List<Map<String, dynamic>>> _fetchCustomerItemsSpecialPriceData(List<String> custCodes) async {
  List<Map<String, dynamic>> customerItemsSpecialPriceData = [];
  try {
    // Iterate over each custCode and fetch data for each one
    for (String custCode in custCodes) {
      // Make API call to fetch customer items special price data
      var response = await http.get(Uri.parse('${apiurl}getCustomerItemsSpecialPrice?custCode=$custCode'));
      if (response.statusCode == 200) {
        // Parse the response data
        dynamic responseData = jsonDecode(response.body);
        if (responseData is List) {
          // If the response is a list, append each customer items special price data to the customerItemsSpecialPriceData list
          for (var item in responseData) {
            if (item is Map<String, dynamic>) {
              customerItemsSpecialPriceData.add(item);
            }
          }
        } else {
          print('Invalid response format for customer items special price data');
        }
      } else {
        print('Failed to retrieve customer items special price data for custCode $custCode: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error fetching customer items special price data: $e');
  }
  return customerItemsSpecialPriceData;
}

Future<void> _synchronizeCustomerItemsSpecialPrice(
  List<Map<String, dynamic>> customerItemsSpecialPriceData,
  Box<CustomerItemsSpecialPrice> specialPrice,
) async {
  try {
    // Iterate over the retrieved data
    for (var data in customerItemsSpecialPriceData) {
      var cmpCode = data['cmpCode'];
      var custCode = data['custCode'];
      var itemCode = data['itemCode'];
      var uom = data['uom'];

      // Check if the special price exists in Hive
      var hiveSpecialPrice = specialPrice.get('$cmpCode$itemCode$custCode$uom');

      // If the special price doesn't exist in Hive, add it
      if (hiveSpecialPrice == null) {
        var newSpecialPrice = CustomerItemsSpecialPrice(
          cmpCode: cmpCode,
          custCode: custCode,
          itemCode: itemCode,
          uom: uom,
          basePrice: data['basePrice'],
          currency: data['currency'],
          auto: data['auto'],
          disc: data['disc'],
          price: data['price'],
          notes: data['notes'],
        );
        await specialPrice.put('$cmpCode$itemCode$custCode$uom', newSpecialPrice);
      }
      // If the special price exists in Hive, update it if needed
      else {
        var updatedSpecialPrice = CustomerItemsSpecialPrice(
          cmpCode: cmpCode,
          custCode: custCode,
          itemCode: itemCode,
          uom: uom,
          basePrice: data['basePrice'],
          currency: data['currency'],
          auto: data['auto'],
          disc: data['disc'],
          price: data['price'],
          notes: data['notes'],
        );
        // Update the special price in Hive
        await specialPrice.put('$cmpCode$itemCode$custCode$uom', updatedSpecialPrice);
      }
    }

    // Check for special prices in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedSpecialPriceKeys = Set.from(customerItemsSpecialPriceData.map((data) => '${data['cmpCode']}${data['itemCode']}${data['custCode']}${data['uom']}'));
    Set<String> hiveSpecialPriceKeys = Set.from(specialPrice.keys);

    // Identify special prices in Hive that don't exist in the fetched data
    Set<String> specialPricesToDelete = hiveSpecialPriceKeys.difference(fetchedSpecialPriceKeys);

    // Delete special prices in Hive that don't exist in the fetched data
    specialPricesToDelete.forEach((hiveSpecialPriceKey) {
      specialPrice.delete(hiveSpecialPriceKey);
    });
  } catch (e) {
    print('Error synchronizing CustomerItemsSpecialPrice from API to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
Future<void> synchronizeCustomerBrandsSpecialPrice(List<String> custCodes, List<String> brandCodes) async {
  try {
    // Fetch data from API endpoint without filtering by brandCodes in the query
    var apiResponse = await _fetchCustomerBrandsSpecialPriceData(custCodes);

    // Filter the results based on brandCodes in Dart code
    var filteredApiResponse = apiResponse.where((data) => brandCodes.contains(data['brandCode'])).toList();

    // Open Hive box
    var brandsSpecialPriceBox = await Hive.openBox<CustomerBrandsSpecialPrice>('customerBrandsSpecialPriceBox');

    // Synchronize data
    await _synchronizeCustomerBrandsSpecialPrice(filteredApiResponse, brandsSpecialPriceBox);
  } catch (e) {
    print('Error synchronizing data from API to Hive for CustomerBrandsSpecialPrice: $e');
  }
}

Future<List<Map<String, dynamic>>> _fetchCustomerBrandsSpecialPriceData(List<String> custCodes) async {
  List<Map<String, dynamic>> customerBrandsSpecialPriceData = [];
  try {
    // Iterate over each custCode and fetch data for each one
    for (String custCode in custCodes) {
      // Make API call to fetch customer brands special price data
      var response = await http.get(Uri.parse('${apiurl}getCustomerBrandsSpecialPrice?custCode=$custCode'));
      if (response.statusCode == 200) {
        // Parse the response data
        dynamic responseData = jsonDecode(response.body);
        if (responseData is List) {
          // If the response is a list, append each customer brands special price data to the customerBrandsSpecialPriceData list
          for (var item in responseData) {
            if (item is Map<String, dynamic>) {
              customerBrandsSpecialPriceData.add(item);
            }
          }
        } else {
          print('Invalid response format for customer brands special price data');
        }
      } else {
        print('Failed to retrieve customer brands special price data for custCode $custCode: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error fetching customer brands special price data: $e');
  }
  return customerBrandsSpecialPriceData;
}

Future<void> _synchronizeCustomerBrandsSpecialPrice(
  List<Map<String, dynamic>> customerBrandsSpecialPriceData,
  Box<CustomerBrandsSpecialPrice> brandsSpecialPrice,
) async {
  try {
    // Iterate over the retrieved data
    for (var data in customerBrandsSpecialPriceData) {
      var cmpCode = data['cmpCode'];
      var custCode = data['custCode'];
      var brandCode = data['brandCode'];

      // Check if the brand special price exists in Hive
      var hiveBrandSpecialPrice = brandsSpecialPrice.get('$cmpCode$custCode$brandCode');

      // If the brand special price doesn't exist in Hive, add it
      if (hiveBrandSpecialPrice == null) {
        var newBrandSpecialPrice = CustomerBrandsSpecialPrice(
          cmpCode: cmpCode,
          custCode: custCode,
          brandCode: brandCode,
          disc: data['disc'],
          notes: data['notes'],
        );
        await brandsSpecialPrice.put('$cmpCode$custCode$brandCode', newBrandSpecialPrice);
      }
      // If the brand special price exists in Hive, update it if needed
      else {
        var updatedBrandSpecialPrice = CustomerBrandsSpecialPrice(
          cmpCode: cmpCode,
          custCode: custCode,
          brandCode: brandCode,
          disc: data['disc'],
          notes: data['notes'],
        );
        // Update the brand special price in Hive
        await brandsSpecialPrice.put('$cmpCode$custCode$brandCode', updatedBrandSpecialPrice);
      }
    }

    // Check for brand special prices in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedBrandSpecialPriceKeys = Set.from(customerBrandsSpecialPriceData.map((data) => '${data['cmpCode']}${data['custCode']}${data['brandCode']}'));
    Set<String> hiveBrandSpecialPriceKeys = Set.from(brandsSpecialPrice.keys);

    // Identify brand special prices in Hive that don't exist in Firestore
    Set<String> brandSpecialPricesToDelete = hiveBrandSpecialPriceKeys.difference(fetchedBrandSpecialPriceKeys);

    // Delete brand special prices in Hive that don't exist in the fetched data
    brandSpecialPricesToDelete.forEach((hiveBrandSpecialPriceKey) {
      brandsSpecialPrice.delete(hiveBrandSpecialPriceKey);
    });
  } catch (e) {
    print('Error synchronizing CustomerBrandsSpecialPrice from API to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
Future<void> synchronizeCustomerGroupsSpecialPrice(List<String> custCodes, List<String> itemGroupCodes) async {
  try {
    // Fetch data from API endpoint without filtering by itemGroupCodes in the query
    var apiResponse = await _fetchCustomerGroupsSpecialPriceData(custCodes);

    // Filter the results based on itemGroupCodes in Dart code
    var filteredApiResponse = apiResponse.where((data) => itemGroupCodes.contains(data['groupCode'])).toList();

    // Open Hive box
    var groupsSpecialPriceBox = await Hive.openBox<CustomerGroupsSpecialPrice>('customerGroupsSpecialPriceBox');

    // Synchronize data
    await _synchronizeCustomerGroupsSpecialPrice(filteredApiResponse, groupsSpecialPriceBox);
  } catch (e) {
    print('Error synchronizing data from API to Hive for CustomerGroupsSpecialPrice: $e');
  }
}

Future<List<Map<String, dynamic>>> _fetchCustomerGroupsSpecialPriceData(List<String> custCodes) async {
  List<Map<String, dynamic>> customerGroupsSpecialPriceData = [];
  try {
    // Iterate over each custCode and fetch data for each one
    for (String custCode in custCodes) {
      // Make API call to fetch customer groups special price data
      var response = await http.get(Uri.parse('${apiurl}getCustomerGroupsSpecialPrice?custCode=$custCode'));
      if (response.statusCode == 200) {
        // Parse the response data
        dynamic responseData = jsonDecode(response.body);
        if (responseData is List) {
          // If the response is a list, append each customer groups special price data to the customerGroupsSpecialPriceData list
          for (var item in responseData) {
            if (item is Map<String, dynamic>) {
              customerGroupsSpecialPriceData.add(item);
            }
          }
        } else {
          print('Invalid response format for customer groups special price data');
        }
      } else {
        print('Failed to retrieve customer groups special price data for custCode $custCode: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error fetching customer groups special price data: $e');
  }
  return customerGroupsSpecialPriceData;
}

Future<void> _synchronizeCustomerGroupsSpecialPrice(
  List<Map<String, dynamic>> customerGroupsSpecialPriceData,
  Box<CustomerGroupsSpecialPrice> groupsSpecialPrice,
) async {
  try {
    // Iterate over the retrieved data
    for (var data in customerGroupsSpecialPriceData) {
      var cmpCode = data['cmpCode'];
      var custCode = data['custCode'];
      var groupCode = data['groupCode'];

      // Check if the group special price exists in Hive
      var hiveGroupSpecialPrice = groupsSpecialPrice.get('$cmpCode$custCode$groupCode');

      // If the group special price doesn't exist in Hive, add it
      if (hiveGroupSpecialPrice == null) {
        var newGroupSpecialPrice = CustomerGroupsSpecialPrice(
          cmpCode: cmpCode,
          custCode: custCode,
          groupCode: groupCode,
          disc: data['disc'],
          notes: data['notes'],
        );
        await groupsSpecialPrice.put('$cmpCode$custCode$groupCode', newGroupSpecialPrice);
      }
      // If the group special price exists in Hive, update it if needed
      else {
        var updatedGroupSpecialPrice = CustomerGroupsSpecialPrice(
          cmpCode: cmpCode,
          custCode: custCode,
          groupCode: groupCode,
          disc: data['disc'],
          notes: data['notes'],
        );
        // Update the group special price in Hive
        await groupsSpecialPrice.put('$cmpCode$custCode$groupCode', updatedGroupSpecialPrice);
      }
    }

    // Check for group special prices in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedGroupSpecialPriceKeys = Set.from(customerGroupsSpecialPriceData.map((data) => '${data['cmpCode']}${data['custCode']}${data['groupCode']}'));
    Set<String> hiveGroupSpecialPriceKeys = Set.from(groupsSpecialPrice.keys);

    // Identify group special prices in Hive that don't exist in Firestore
    Set<String> groupSpecialPricesToDelete = hiveGroupSpecialPriceKeys.difference(fetchedGroupSpecialPriceKeys);

    // Delete group special prices in Hive that don't exist in the fetched data
    groupSpecialPricesToDelete.forEach((hiveGroupSpecialPriceKey) {
      groupsSpecialPrice.delete(hiveGroupSpecialPriceKey);
    });
  } catch (e) {
    print('Error synchronizing CustomerGroupsSpecialPrice from API to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
Future<void> synchronizeCustomerCategSpecialPrice(List<String> custCodes, List<String> categCodes) async {
  try {
    // Fetch data from API endpoint without filtering by categCodes in the query
    var apiResponse = await _fetchCustomerCategSpecialPriceData(custCodes);

    // Filter the results based on categCodes in Dart code
    var filteredApiResponse = apiResponse.where((data) => categCodes.contains(data['categCode'])).toList();

    // Open Hive box
    var categSpecialPriceBox = await Hive.openBox<CustomerCategSpecialPrice>('customerCategSpecialPriceBox');

    // Synchronize data
    await _synchronizeCustomerCategSpecialPrice(filteredApiResponse, categSpecialPriceBox);
  } catch (e) {
    print('Error synchronizing data from API to Hive for CustomerCategSpecialPrice: $e');
  }
}

Future<List<Map<String, dynamic>>> _fetchCustomerCategSpecialPriceData(List<String> custCodes) async {
  List<Map<String, dynamic>> customerCategSpecialPriceData = [];
  try {
    // Iterate over each custCode and fetch data for each one
    for (String custCode in custCodes) {
      // Make API call to fetch customer category special price data
      var response = await http.get(Uri.parse('${apiurl}getCustomerCategSpecialPrice?custCode=$custCode'));
      if (response.statusCode == 200) {
        // Parse the response data
        dynamic responseData = jsonDecode(response.body);
        if (responseData is List) {
          // If the response is a list, append each customer category special price data to the customerCategSpecialPriceData list
          for (var item in responseData) {
            if (item is Map<String, dynamic>) {
              customerCategSpecialPriceData.add(item);
            }
          }
        } else {
          print('Invalid response format for customer category special price data');
        }
      } else {
        print('Failed to retrieve customer category special price data for custCode $custCode: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error fetching customer category special price data: $e');
  }
  return customerCategSpecialPriceData;
}

Future<void> _synchronizeCustomerCategSpecialPrice(
  List<Map<String, dynamic>> customerCategSpecialPriceData,
  Box<CustomerCategSpecialPrice> categSpecialPrice,
) async {
  try {
    // Iterate over the retrieved data
    for (var data in customerCategSpecialPriceData) {
      var cmpCode = data['cmpCode'];
      var custCode = data['custCode'];
      var categCode = data['categCode'];

      // Check if the categ special price exists in Hive
      var hiveCategSpecialPrice = categSpecialPrice.get('$cmpCode$custCode$categCode');

      // If the categ special price doesn't exist in Hive, add it
      if (hiveCategSpecialPrice == null) {
        var newCategSpecialPrice = CustomerCategSpecialPrice(
          cmpCode: cmpCode,
          custCode: custCode,
          categCode: categCode,
          disc: data['disc'],
          notes: data['notes'],
        );
        await categSpecialPrice.put('$cmpCode$custCode$categCode', newCategSpecialPrice);
      }
      // If the categ special price exists in Hive, update it if needed
      else {
        var updatedCategSpecialPrice = CustomerCategSpecialPrice(
          cmpCode: cmpCode,
          custCode: custCode,
          categCode: categCode,
          disc: data['disc'],
          notes: data['notes'],
        );
        // Update the categ special price in Hive
        await categSpecialPrice.put('$cmpCode$custCode$categCode', updatedCategSpecialPrice);
      }
    }

    // Check for categ special prices in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedCategSpecialPriceKeys = Set.from(customerCategSpecialPriceData.map((data) => '${data['cmpCode']}${data['custCode']}${data['categCode']}'));
    Set<String> hiveCategSpecialPriceKeys = Set.from(categSpecialPrice.keys);

    // Identify categ special prices in Hive that don't exist in Firestore
    Set<String> categSpecialPricesToDelete = hiveCategSpecialPriceKeys.difference(fetchedCategSpecialPriceKeys);

    // Delete categ special prices in Hive that don't exist in the fetched data
    categSpecialPricesToDelete.forEach((hiveCategSpecialPriceKey) {
      categSpecialPrice.delete(hiveCategSpecialPriceKey);
    });
  } catch (e) {
    print('Error synchronizing CustomerCategSpecialPrice from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
Future<List<String>> retrieveCustGroupCode(List<String> custCodes) async {
  List<String> custGroupCodes = [];
  try {
    for (String custCode in custCodes) {
      // Make API call to fetch customer group code based on custCode
      var response = await http.get(Uri.parse('${apiurl}getCustomers?custCode=$custCode'));
      if (response.statusCode == 200) {
        // Parse the response data
        dynamic responseData = jsonDecode(response.body);
        if (responseData is List && responseData.isNotEmpty) {
          // Assuming the API response contains the groupCode
          custGroupCodes.add(responseData[0]['groupCode']);
        }
      } else {
        print('Failed to retrieve custGroupCode for custCode $custCode: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error retrieving custGroupCodes: $e');
  }
  return custGroupCodes;
}

Future<void> synchronizeCustomerGroupItemsSpecialPrice(List<String> itemCodes, List<String> custGroupCodes) async {
  try {
    // Fetch data from API endpoint
    var apiResponse = await _fetchCustomerGroupItemsSpecialPriceData(itemCodes, custGroupCodes);

    // Open Hive box
    var groupItemsSpecialPriceBox = await Hive.openBox<CustomerGroupItemsSpecialPrice>('customerGroupItemsSpecialPriceBox');

    // Synchronize data
    await _synchronizeCustomerGroupItemsSpecialPrice(apiResponse, groupItemsSpecialPriceBox);

  } catch (e) {
    print('Error synchronizing data from API to Hive for CustomerGroupItemsSpecialPrice: $e');
  }
}

Future<List<Map<String, dynamic>>> _fetchCustomerGroupItemsSpecialPriceData(List<String> itemCodes, List<String> custGroupCodes) async {
  List<Map<String, dynamic>> customerGroupItemsSpecialPriceData = [];
  try {
    for (String itemCode in itemCodes) {
      for (String custGroupCode in custGroupCodes) {
        // Make API call to fetch customer group items special price data
        var response = await http.get(Uri.parse('${apiurl}getCustomerGroupItemsSpecialPrice?itemCode=$itemCode&custGroupCode=$custGroupCode'));
        if (response.statusCode == 200) {
          // Parse the response data
          dynamic responseData = jsonDecode(response.body);
          if (responseData is List) {
            for (var item in responseData) {
              if (item is Map<String, dynamic>) {
                customerGroupItemsSpecialPriceData.add(item);
              }
            }
          } else {
            print('Invalid response format for customer group items special price data');
          }
        } else {
          print('Failed to retrieve customer group items special price data for itemCode $itemCode and custGroupCode $custGroupCode: ${response.statusCode}');
        }
      }
    }
  } catch (e) {
    print('Error fetching customer group items special price data: $e');
  }
  return customerGroupItemsSpecialPriceData;
}

Future<void> _synchronizeCustomerGroupItemsSpecialPrice(
  List<Map<String, dynamic>> customerGroupItemsSpecialPriceData,
  Box<CustomerGroupItemsSpecialPrice> groupItemsSpecialPrice,
) async {
  try {
    // Iterate over the retrieved data
    for (var data in customerGroupItemsSpecialPriceData) {
      var cmpCode = data['cmpCode'];
      var custGroupCode = data['custGroupCode'];
      var itemCode = data['itemCode'];
      var uom = data['uom'];

      // Check if the group item special price exists in Hive
      var hiveGroupItemSpecialPrice = groupItemsSpecialPrice.get('$cmpCode$custGroupCode$itemCode$uom');

      // If the group item special price doesn't exist in Hive, add it
      if (hiveGroupItemSpecialPrice == null) {
        var newGroupItemSpecialPrice = CustomerGroupItemsSpecialPrice(
          cmpCode: cmpCode,
          custGroupCode: custGroupCode,
          itemCode: itemCode,
          uom: uom,
          basePrice: data['basePrice'],
          currency: data['currency'],
          auto: data['auto'],
          disc: data['disc'],
          price: data['price'],
          notes: data['notes'],
        );
        await groupItemsSpecialPrice.put('$cmpCode$custGroupCode$itemCode$uom', newGroupItemSpecialPrice);
      }
      // If the group item special price exists in Hive, update it if needed
      else {
        var updatedGroupItemSpecialPrice = CustomerGroupItemsSpecialPrice(
          cmpCode: cmpCode,
          custGroupCode: custGroupCode,
          itemCode: itemCode,
          uom: uom,
          basePrice: data['basePrice'],
          currency: data['currency'],
          auto: data['auto'],
          disc: data['disc'],
          price: data['price'],
          notes: data['notes'],
        );
        // Update the group item special price in Hive
        await groupItemsSpecialPrice.put('$cmpCode$custGroupCode$itemCode$uom', updatedGroupItemSpecialPrice);
      }
    }

    // Check for group item special prices in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedGroupItemsSpecialPriceKeys = Set.from(customerGroupItemsSpecialPriceData.map((data) => '${data['cmpCode']}${data['custGroupCode']}${data['itemCode']}${data['uom']}'));
    Set<String> hiveGroupItemsSpecialPriceKeys = Set.from(groupItemsSpecialPrice.keys);

    // Identify group item special prices in Hive that don't exist in Firestore
    Set<String> groupItemsSpecialPricesToDelete = hiveGroupItemsSpecialPriceKeys.difference(fetchedGroupItemsSpecialPriceKeys);

    // Delete group item special prices in Hive that don't exist in the fetched data
    groupItemsSpecialPricesToDelete.forEach((hiveGroupItemSpecialPriceKey) {
      groupItemsSpecialPrice.delete(hiveGroupItemSpecialPriceKey);
    });
  } catch (e) {
    print('Error synchronizing CustomerGroupItemsSpecialPrice from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
Future<void> synchronizeCustomerGroupBrandSpecialPrice(List<String> brandCodes, List<String> custGroupCodes) async {
  try {
    // Fetch data from API endpoint
    var apiResponse = await _fetchCustomerGroupBrandSpecialPriceData(brandCodes, custGroupCodes);

    // Open Hive box
    var groupBrandSpecialPriceBox = await Hive.openBox<CustomerGroupBrandSpecialPrice>('customerGroupBrandSpecialPriceBox');

    // Synchronize data
    await _synchronizeCustomerGroupBrandSpecialPrice(apiResponse, groupBrandSpecialPriceBox);

  } catch (e) {
    print('Error synchronizing data from API to Hive for CustomerGroupBrandSpecialPrice: $e');
  }
}

Future<List<Map<String, dynamic>>> _fetchCustomerGroupBrandSpecialPriceData(List<String> brandCodes, List<String> custGroupCodes) async {
  List<Map<String, dynamic>> customerGroupBrandSpecialPriceData = [];
  try {
    for (String brandCode in brandCodes) {
      for (String custGroupCode in custGroupCodes) {
        // Make API call to fetch customer group brand special price data
        var response = await http.get(Uri.parse('${apiurl}getCustomerGroupBrandSpecialPrice?brandCode=$brandCode&custGroupCode=$custGroupCode'));
        if (response.statusCode == 200) {
          // Parse the response data
          dynamic responseData = jsonDecode(response.body);
          if (responseData is List) {
            for (var item in responseData) {
              if (item is Map<String, dynamic>) {
                customerGroupBrandSpecialPriceData.add(item);
              }
            }
          } else {
            print('Invalid response format for customer group brand special price data');
          }
        } else {
          print('Failed to retrieve customer group brand special price data for brandCode $brandCode and custGroupCode $custGroupCode: ${response.statusCode}');
        }
      }
    }
  } catch (e) {
    print('Error fetching customer group brand special price data: $e');
  }
  return customerGroupBrandSpecialPriceData;
}

Future<void> _synchronizeCustomerGroupBrandSpecialPrice(
  List<Map<String, dynamic>> customerGroupBrandSpecialPriceData,
  Box<CustomerGroupBrandSpecialPrice> groupBrandSpecialPrice,
) async {
  try {
    // Iterate over the retrieved data
    for (var data in customerGroupBrandSpecialPriceData) {
      var cmpCode = data['cmpCode'];
      var custGroupCode = data['custGroupCode'];
      var brandCode = data['brandCode'];

      // Check if the group brand special price exists in Hive
      var hiveGroupBrandSpecialPrice = groupBrandSpecialPrice.get('$cmpCode$custGroupCode$brandCode');

      // If the group brand special price doesn't exist in Hive, add it
      if (hiveGroupBrandSpecialPrice == null) {
        var newGroupBrandSpecialPrice = CustomerGroupBrandSpecialPrice(
          cmpCode: cmpCode,
          custGroupCode: custGroupCode,
          brandCode: brandCode,
          disc: data['disc'],
          notes: data['notes'],
        );
        await groupBrandSpecialPrice.put('$cmpCode$custGroupCode$brandCode', newGroupBrandSpecialPrice);
      }
      // If the group brand special price exists in Hive, update it if needed
      else {
        var updatedGroupBrandSpecialPrice = CustomerGroupBrandSpecialPrice(
          cmpCode: cmpCode,
          custGroupCode: custGroupCode,
          brandCode: brandCode,
          disc: data['disc'],
          notes: data['notes'],
        );
        // Update the group brand special price in Hive
        await groupBrandSpecialPrice.put('$cmpCode$custGroupCode$brandCode', updatedGroupBrandSpecialPrice);
      }
    }

    // Check for group brand special prices in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedGroupBrandSpecialPriceKeys = Set.from(customerGroupBrandSpecialPriceData.map((data) => '${data['cmpCode']}${data['custGroupCode']}${data['brandCode']}'));
    Set<String> hiveGroupBrandSpecialPriceKeys = Set.from(groupBrandSpecialPrice.keys);

    // Identify group brand special prices in Hive that don't exist in the fetched data
    Set<String> groupBrandSpecialPricesToDelete = hiveGroupBrandSpecialPriceKeys.difference(fetchedGroupBrandSpecialPriceKeys);

    // Delete group brand special prices in Hive that don't exist in the fetched data
    groupBrandSpecialPricesToDelete.forEach((hiveGroupBrandSpecialPriceKey) {
      groupBrandSpecialPrice.delete(hiveGroupBrandSpecialPriceKey);
    });
  } catch (e) {
    print('Error synchronizing CustomerGroupBrandSpecialPrice from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
Future<void> synchronizeCustomerGroupGroupSpecialPrice(List<String> groupCodes, List<String> custGroupCodes) async {
  try {
    // Fetch data from API endpoint
    var apiResponse = await _fetchCustomerGroupGroupSpecialPriceData(groupCodes, custGroupCodes);

    // Open Hive box
    var groupGroupSpecialPriceBox = await Hive.openBox<CustomerGroupGroupSpecialPrice>('customerGroupGroupSpecialPriceBox');

    // Synchronize data
    await _synchronizeCustomerGroupGroupSpecialPrice(apiResponse, groupGroupSpecialPriceBox);

  } catch (e) {
    print('Error synchronizing data from API to Hive for CustomerGroupGroupSpecialPrice: $e');
  }
}

Future<List<Map<String, dynamic>>> _fetchCustomerGroupGroupSpecialPriceData(List<String> groupCodes, List<String> custGroupCodes) async {
  List<Map<String, dynamic>> customerGroupGroupSpecialPriceData = [];
  try {
    for (String groupCode in groupCodes) {
      for (String custGroupCode in custGroupCodes) {
        // Make API call to fetch customer group group special price data
        var response = await http.get(Uri.parse('${apiurl}getCustomerGroupGroupSpecialPrice?groupCode=$groupCode&custGroupCode=$custGroupCode'));
        if (response.statusCode == 200) {
          // Parse the response data
          dynamic responseData = jsonDecode(response.body);
          if (responseData is List) {
            for (var item in responseData) {
              if (item is Map<String, dynamic>) {
                customerGroupGroupSpecialPriceData.add(item);
              }
            }
          } else {
            print('Invalid response format for customer group group special price data');
          }
        } else {
          print('Failed to retrieve customer group group special price data for groupCode $groupCode and custGroupCode $custGroupCode: ${response.statusCode}');
        }
      }
    }
  } catch (e) {
    print('Error fetching customer group group special price data: $e');
  }
  return customerGroupGroupSpecialPriceData;
}

Future<void> _synchronizeCustomerGroupGroupSpecialPrice(
  List<Map<String, dynamic>> customerGroupGroupSpecialPriceData,
  Box<CustomerGroupGroupSpecialPrice> groupGroupSpecialPrice,
) async {
  try {
    // Iterate over the retrieved data
    for (var data in customerGroupGroupSpecialPriceData) {
      var cmpCode = data['cmpCode'];
      var custGroupCode = data['custGroupCode'];
      var groupCode = data['groupCode'];

      // Check if the group group special price exists in Hive
      var hiveGroupGroupSpecialPrice = groupGroupSpecialPrice.get('$cmpCode$custGroupCode$groupCode');

      // If the group group special price doesn't exist in Hive, add it
      if (hiveGroupGroupSpecialPrice == null) {
        var newGroupGroupSpecialPrice = CustomerGroupGroupSpecialPrice(
          cmpCode: cmpCode,
          custGroupCode: custGroupCode,
          groupCode: groupCode,
          disc: data['disc'],
          notes: data['notes'],
        );
        await groupGroupSpecialPrice.put('$cmpCode$custGroupCode$groupCode', newGroupGroupSpecialPrice);
      }
      // If the group group special price exists in Hive, update it if needed
      else {
        var updatedGroupGroupSpecialPrice = CustomerGroupGroupSpecialPrice(
          cmpCode: cmpCode,
          custGroupCode: custGroupCode,
          groupCode: groupCode,
          disc: data['disc'],
          notes: data['notes'],
        );
        // Update the group group special price in Hive
        await groupGroupSpecialPrice.put('$cmpCode$custGroupCode$groupCode', updatedGroupGroupSpecialPrice);
      }
    }

    // Check for group group special prices in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedGroupGroupSpecialPriceKeys = Set.from(customerGroupGroupSpecialPriceData.map((data) => '${data['cmpCode']}${data['custGroupCode']}${data['groupCode']}'));
    Set<String> hiveGroupGroupSpecialPriceKeys = Set.from(groupGroupSpecialPrice.keys);

    // Identify group group special prices in Hive that don't exist in the fetched data
    Set<String> groupGroupSpecialPricesToDelete = hiveGroupGroupSpecialPriceKeys.difference(fetchedGroupGroupSpecialPriceKeys);

    // Delete group group special prices in Hive that don't exist in the fetched data
    groupGroupSpecialPricesToDelete.forEach((hiveGroupGroupSpecialPriceKey) {
      groupGroupSpecialPrice.delete(hiveGroupGroupSpecialPriceKey);
    });
  } catch (e) {
    print('Error synchronizing CustomerGroupGroupSpecialPrice from API to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<void> synchronizeCustomerGroupCategSpecialPrice(List<String> categCodes, List<String> custGroupCodes) async {
  try {
    // Fetch data from API endpoint
    var apiResponse = await _fetchCustomerGroupCategSpecialPriceData(categCodes, custGroupCodes);

    // Open Hive box
    var groupCategSpecialPriceBox = await Hive.openBox<CustomerGroupCategSpecialPrice>('customerGroupCategSpecialPriceBox');

    // Synchronize data
    await _synchronizeCustomerGroupCategSpecialPrice(apiResponse, groupCategSpecialPriceBox);

  } catch (e) {
    print('Error synchronizing data from API to Hive for CustomerGroupCategSpecialPrice: $e');
  }
}

Future<List<Map<String, dynamic>>> _fetchCustomerGroupCategSpecialPriceData(List<String> categCodes, List<String> custGroupCodes) async {
  List<Map<String, dynamic>> customerGroupCategSpecialPriceData = [];
  try {
    for (String categCode in categCodes) {
      for (String custGroupCode in custGroupCodes) {
        // Make API call to fetch customer group categ special price data
        var response = await http.get(Uri.parse('${apiurl}getCustomerGroupCategSpecialPrice?categCode=$categCode&custGroupCode=$custGroupCode'));
        if (response.statusCode == 200) {
          // Parse the response data
          dynamic responseData = jsonDecode(response.body);
          if (responseData is List) {
            for (var item in responseData) {
              if (item is Map<String, dynamic>) {
                customerGroupCategSpecialPriceData.add(item);
              }
            }
          } else {
            print('Invalid response format for customer group categ special price data');
          }
        } else {
          print('Failed to retrieve customer group categ special price data for categCode $categCode and custGroupCode $custGroupCode: ${response.statusCode}');
        }
      }
    }
  } catch (e) {
    print('Error fetching customer group categ special price data: $e');
  }
  return customerGroupCategSpecialPriceData;
}

Future<void> _synchronizeCustomerGroupCategSpecialPrice(
  List<Map<String, dynamic>> customerGroupCategSpecialPriceData,
  Box<CustomerGroupCategSpecialPrice> groupCategSpecialPrice,
) async {
  try {
    // Iterate over the retrieved data
    for (var data in customerGroupCategSpecialPriceData) {
      var cmpCode = data['cmpCode'];
      var custGroupCode = data['custGroupCode'];
      var categCode = data['categCode'];

      // Check if the group categ special price exists in Hive
      var hiveGroupCategSpecialPrice = groupCategSpecialPrice.get('$cmpCode$custGroupCode$categCode');

      // If the group categ special price doesn't exist in Hive, add it
      if (hiveGroupCategSpecialPrice == null) {
        var newGroupCategSpecialPrice = CustomerGroupCategSpecialPrice(
          cmpCode: cmpCode,
          custGroupCode: custGroupCode,
          categCode: categCode,
          disc: data['disc'],
          notes: data['notes'],
        );
        await groupCategSpecialPrice.put('$cmpCode$custGroupCode$categCode', newGroupCategSpecialPrice);
      }
      // If the group categ special price exists in Hive, update it if needed
      else {
        var updatedGroupCategSpecialPrice = CustomerGroupCategSpecialPrice(
          cmpCode: cmpCode,
          custGroupCode: custGroupCode,
          categCode: categCode,
          disc: data['disc'],
          notes: data['notes'],
        );
        // Update the group categ special price in Hive
        await groupCategSpecialPrice.put('$cmpCode$custGroupCode$categCode', updatedGroupCategSpecialPrice);
      }
    }

    // Check for group categ special prices in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedGroupCategSpecialPriceKeys = Set.from(customerGroupCategSpecialPriceData.map((data) => '${data['cmpCode']}${data['custGroupCode']}${data['categCode']}'));
    Set<String> hiveGroupCategSpecialPriceKeys = Set.from(groupCategSpecialPrice.keys);

    // Identify group categ special prices in Hive that don't exist in the fetched data
    Set<String> groupCategSpecialPricesToDelete = hiveGroupCategSpecialPriceKeys.difference(fetchedGroupCategSpecialPriceKeys);

    // Delete group categ special prices in Hive that don't exist in the fetched data
    groupCategSpecialPricesToDelete.forEach((hiveGroupCategSpecialPriceKey) {
      groupCategSpecialPrice.delete(hiveGroupCategSpecialPriceKey);
    });
  } catch (e) {
    print('Error synchronizing CustomerGroupCategSpecialPrice from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
Future<List<String>> retrievePropCodes(List<String> custCodes) async {
  List<String> propCodes = [];
  try {
    for (String custCode in custCodes) {
      // Make API call to fetch customer properties data
      var response = await http.get(Uri.parse('${apiurl}getCustomerProperties?custCode=$custCode'));
      if (response.statusCode == 200) {
        // Parse the response data
        dynamic responseData = jsonDecode(response.body);
        if (responseData is List) {
          for (var item in responseData) {
            if (item is Map<String, dynamic> && item.containsKey('propCode')) {
              propCodes.add(item['propCode']);
            }
          }
        } else {
          print('Invalid response format for customer properties data');
        }
      } else {
        print('Failed to retrieve customer properties data for custCode $custCode: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error retrieving propCodes: $e');
  }
  return propCodes;
}

Future<void> synchronizeCustomerPropItemsSpecialPrice(List<String> itemCodes, List<String> custCodes) async {
  List<String> propCodes = await retrievePropCodes(custCodes);

  try {
    // Fetch data from API endpoint
    var apiResponse = await _fetchCustomerPropItemsSpecialPriceData(itemCodes, propCodes);

    // Open Hive box
    var propItemsSpecialPriceBox = await Hive.openBox<CustomerPropItemsSpecialPrice>('customerPropItemsSpecialPriceBox');

    // Synchronize data
    await _synchronizeCustomerPropItemsSpecialPrice(apiResponse, propItemsSpecialPriceBox);

    // Close Hive box if needed
    // await propItemsSpecialPriceBox.close();
  } catch (e) {
    print('Error synchronizing data from API to Hive for CustomerPropItemsSpecialPrice: $e');
  }
}

Future<List<Map<String, dynamic>>> _fetchCustomerPropItemsSpecialPriceData(List<String> itemCodes, List<String> propCodes) async {
  List<Map<String, dynamic>> customerPropItemsSpecialPriceData = [];
  try {
    for (String itemCode in itemCodes) {
      for (String propCode in propCodes) {
        // Make API call to fetch customer prop items special price data
        var response = await http.get(Uri.parse('${apiurl}getCustomerPropItemsSpecialPrice?itemCode=$itemCode&propCode=$propCode'));
        if (response.statusCode == 200) {
          // Parse the response data
          dynamic responseData = jsonDecode(response.body);
          if (responseData is List) {
            for (var item in responseData) {
              if (item is Map<String, dynamic>) {
                customerPropItemsSpecialPriceData.add(item);
              }
            }
          } else {
            print('Invalid response format for customer prop items special price data');
          }
        } else {
          print('Failed to retrieve customer prop items special price data for itemCode $itemCode and propCode $propCode: ${response.statusCode}');
        }
      }
    }
  } catch (e) {
    print('Error fetching customer prop items special price data: $e');
  }
  return customerPropItemsSpecialPriceData;
}

Future<void> _synchronizeCustomerPropItemsSpecialPrice(
  List<Map<String, dynamic>> customerPropItemsSpecialPriceData,
  Box<CustomerPropItemsSpecialPrice> propItemsSpecialPrice,
) async {
  try {
    // Iterate over the retrieved data
    for (var data in customerPropItemsSpecialPriceData) {
      var cmpCode = data['cmpCode'];
      var custPropCode = data['custPropCode'];
      var itemCode = data['itemCode'];
      var uom = data['uom'];

      // Check if the prop items special price exists in Hive
      var hivePropItemsSpecialPrice = propItemsSpecialPrice.get('$cmpCode$custPropCode$itemCode$uom');

      // If the prop items special price doesn't exist in Hive, add it
      if (hivePropItemsSpecialPrice == null) {
        var newPropItemsSpecialPrice = CustomerPropItemsSpecialPrice(
          cmpCode: cmpCode,
          custPropCode: custPropCode,
          itemCode: itemCode,
          uom: uom,
          basePrice: data['basePrice'],
          currency: data['currency'],
          auto: data['auto'],
          disc: data['disc'],
          price: data['price'],
          notes: data['notes'],
        );
        await propItemsSpecialPrice.put('$cmpCode$custPropCode$itemCode$uom', newPropItemsSpecialPrice);
      }
      // If the prop items special price exists in Hive, update it if needed
      else {
        var updatedPropItemsSpecialPrice = CustomerPropItemsSpecialPrice(
          cmpCode: cmpCode,
          custPropCode: custPropCode,
          itemCode: itemCode,
          uom: uom,
          basePrice: data['basePrice'],
          currency: data['currency'],
          auto: data['auto'],
          disc: data['disc'],
          price: data['price'],
          notes: data['notes'],
        );
        // Update the prop items special price in Hive
        await propItemsSpecialPrice.put('$cmpCode$custPropCode$itemCode$uom', updatedPropItemsSpecialPrice);
      }
    }

    // Check for prop items special prices in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedPropItemsSpecialPriceKeys = Set.from(customerPropItemsSpecialPriceData.map((data) => '${data['cmpCode']}${data['custPropCode']}${data['itemCode']}${data['uom']}'));
    Set<String> hivePropItemsSpecialPriceKeys = Set.from(propItemsSpecialPrice.keys);

    // Identify prop items special prices in Hive that don't exist in the fetched data
    Set<String> propItemsSpecialPricesToDelete = hivePropItemsSpecialPriceKeys.difference(fetchedPropItemsSpecialPriceKeys);

    // Delete prop items special prices in Hive that don't exist in the fetched data
    propItemsSpecialPricesToDelete.forEach((hivePropItemsSpecialPriceKey) {
      propItemsSpecialPrice.delete(hivePropItemsSpecialPriceKey);
    });
  } catch (e) {
    print('Error synchronizing CustomerPropItemsSpecialPrice from API to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
Future<void> synchronizeCustomerPropBrandSpecialPrice(List<String> brandCodes, List<String> custCodes) async {
  List<String> propCodes = await retrievePropCodes(custCodes);

  try {
    // Fetch data from API endpoint
    var apiResponse = await _fetchCustomerPropBrandSpecialPriceData(brandCodes, propCodes);

    // Open Hive box
    var propBrandSpecialPriceBox = await Hive.openBox<CustomerPropBrandSpecialPrice>('customerPropBrandSpecialPriceBox');

    // Synchronize data
    await _synchronizeCustomerPropBrandSpecialPrice(apiResponse, propBrandSpecialPriceBox);

    // Close Hive box if needed
    // await propBrandSpecialPriceBox.close();
  } catch (e) {
    print('Error synchronizing data from API to Hive for CustomerPropBrandSpecialPrice: $e');
  }
}

Future<List<Map<String, dynamic>>> _fetchCustomerPropBrandSpecialPriceData(List<String> brandCodes, List<String> propCodes) async {
  List<Map<String, dynamic>> customerPropBrandSpecialPriceData = [];
  try {
    for (String brandCode in brandCodes) {
      for (String propCode in propCodes) {
        // Make API call to fetch customer prop brand special price data
        var response = await http.get(Uri.parse('${apiurl}getCustomerPropBrandSpecialPrice?brandCode=$brandCode&propCode=$propCode'));
        if (response.statusCode == 200) {
          // Parse the response data
          dynamic responseData = jsonDecode(response.body);
          if (responseData is List) {
            for (var item in responseData) {
              if (item is Map<String, dynamic>) {
                customerPropBrandSpecialPriceData.add(item);
              }
            }
          } else {
            print('Invalid response format for customer prop brand special price data');
          }
        } else {
          print('Failed to retrieve customer prop brand special price data for brandCode $brandCode and propCode $propCode: ${response.statusCode}');
        }
      }
    }
  } catch (e) {
    print('Error fetching customer prop brand special price data: $e');
  }
  return customerPropBrandSpecialPriceData;
}

Future<void> _synchronizeCustomerPropBrandSpecialPrice(
  List<Map<String, dynamic>> customerPropBrandSpecialPriceData,
  Box<CustomerPropBrandSpecialPrice> propBrandSpecialPrice,
) async {
  try {
    // Iterate over the retrieved data
    for (var data in customerPropBrandSpecialPriceData) {
      var cmpCode = data['cmpCode'];
      var custPropCode = data['custPropCode'];
      var brandCode = data['brandCode'];

      // Check if the prop brand special price exists in Hive
      var hivePropBrandSpecialPrice = propBrandSpecialPrice.get('$cmpCode$custPropCode$brandCode');

      // If the prop brand special price doesn't exist in Hive, add it
      if (hivePropBrandSpecialPrice == null) {
        var newPropBrandSpecialPrice = CustomerPropBrandSpecialPrice(
          cmpCode: cmpCode,
          custPropCode: custPropCode,
          brandCode: brandCode,
          disc: data['disc'],
          notes: data['notes'],
        );
        await propBrandSpecialPrice.put('$cmpCode$custPropCode$brandCode', newPropBrandSpecialPrice);
      }
      // If the prop brand special price exists in Hive, update it if needed
      else {
        var updatedPropBrandSpecialPrice = CustomerPropBrandSpecialPrice(
          cmpCode: cmpCode,
          custPropCode: custPropCode,
          brandCode: brandCode,
          disc: data['disc'],
          notes: data['notes'],
        );
        // Update the prop brand special price in Hive
        await propBrandSpecialPrice.put('$cmpCode$custPropCode$brandCode', updatedPropBrandSpecialPrice);
      }
    }

    // Check for prop brand special prices in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedPropBrandSpecialPriceKeys = Set.from(customerPropBrandSpecialPriceData.map((data) => '${data['cmpCode']}${data['custPropCode']}${data['brandCode']}'));
    Set<String> hivePropBrandSpecialPriceKeys = Set.from(propBrandSpecialPrice.keys);

    // Identify prop brand special prices in Hive that don't exist in the fetched data
    Set<String> propBrandSpecialPricesToDelete = hivePropBrandSpecialPriceKeys.difference(fetchedPropBrandSpecialPriceKeys);

    // Delete prop brand special prices in Hive that don't exist in the fetched data
    propBrandSpecialPricesToDelete.forEach((hivePropBrandSpecialPriceKey) {
      propBrandSpecialPrice.delete(hivePropBrandSpecialPriceKey);
    });
  } catch (e) {
    print('Error synchronizing CustomerPropBrandSpecialPrice from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<void> synchronizeCustomerPropGroupSpecialPrice(List<String> custGroupCodes, List<String> custCodes) async {
  List<String> propCodes = await retrievePropCodes(custCodes);

  try {
    // Fetch data from API endpoint
    var apiResponse = await _fetchCustomerPropGroupSpecialPriceData(propCodes, custGroupCodes);

    // Open Hive box
    var propGroupSpecialPriceBox = await Hive.openBox<CustomerPropGroupSpecialPrice>('customerPropGroupSpecialPriceBox');

    // Synchronize data
    await _synchronizeCustomerPropGroupSpecialPrice(apiResponse, propGroupSpecialPriceBox);

    // Close Hive box if needed
    // await propGroupSpecialPriceBox.close();
  } catch (e) {
    print('Error synchronizing data from API to Hive for CustomerPropGroupSpecialPrice: $e');
  }
}

Future<List<Map<String, dynamic>>> _fetchCustomerPropGroupSpecialPriceData(List<String> propCodes, List<String> custGroupCodes) async {
  List<Map<String, dynamic>> customerPropGroupSpecialPriceData = [];
  try {
    for (String propCode in propCodes) {
      for (String custGroupCode in custGroupCodes) {
        // Make API call to fetch customer prop group special price data
        var response = await http.get(Uri.parse('${apiurl}getCustomerPropGroupSpecialPrice?propCode=$propCode&custGroupCode=$custGroupCode'));
        if (response.statusCode == 200) {
          // Parse the response data
          dynamic responseData = jsonDecode(response.body);
          if (responseData is List) {
            for (var item in responseData) {
              if (item is Map<String, dynamic>) {
                customerPropGroupSpecialPriceData.add(item);
              }
            }
          } else {
            print('Invalid response format for customer prop group special price data');
          }
        } else {
          print('Failed to retrieve customer prop group special price data for propCode $propCode and custGroupCode $custGroupCode: ${response.statusCode}');
        }
      }
    }
  } catch (e) {
    print('Error fetching customer prop group special price data: $e');
  }
  return customerPropGroupSpecialPriceData;
}

Future<void> _synchronizeCustomerPropGroupSpecialPrice(
  List<Map<String, dynamic>> customerPropGroupSpecialPriceData,
  Box<CustomerPropGroupSpecialPrice> propGroupSpecialPrice,
) async {
  try {
    // Iterate over the retrieved data
    for (var data in customerPropGroupSpecialPriceData) {
      var cmpCode = data['cmpCode'];
      var custGroupCode = data['custGroupCode'];
      var propCode = data['propCode'];

      // Check if the prop group special price exists in Hive
      var hivePropGroupSpecialPrice = propGroupSpecialPrice.get('$cmpCode$custGroupCode$propCode');

      // If the prop group special price doesn't exist in Hive, add it
      if (hivePropGroupSpecialPrice == null) {
        var newPropGroupSpecialPrice = CustomerPropGroupSpecialPrice(
          cmpCode: cmpCode,
          custGroupCode: custGroupCode,
          propCode: propCode,
          disc: data['disc'],
          notes: data['notes'],
        );
        await propGroupSpecialPrice.put('$cmpCode$custGroupCode$propCode', newPropGroupSpecialPrice);
      }
      // If the prop group special price exists in Hive, update it if needed
      else {
        var updatedPropGroupSpecialPrice = CustomerPropGroupSpecialPrice(
          cmpCode: cmpCode,
          custGroupCode: custGroupCode,
          propCode: propCode,
          disc: data['disc'],
          notes: data['notes'],
        );
        // Update the prop group special price in Hive
        await propGroupSpecialPrice.put('$cmpCode$custGroupCode$propCode', updatedPropGroupSpecialPrice);
      }
    }

    // Check for prop group special prices in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedPropGroupSpecialPriceKeys = Set.from(customerPropGroupSpecialPriceData.map((data) => '${data['cmpCode']}${data['custGroupCode']}${data['propCode']}'));
    Set<String> hivePropGroupSpecialPriceKeys = Set.from(propGroupSpecialPrice.keys);

    // Identify prop group special prices in Hive that don't exist in the fetched data
    Set<String> propGroupSpecialPricesToDelete = hivePropGroupSpecialPriceKeys.difference(fetchedPropGroupSpecialPriceKeys);

    // Delete prop group special prices in Hive that don't exist in the fetched data
    propGroupSpecialPricesToDelete.forEach((hivePropGroupSpecialPriceKey) {
      propGroupSpecialPrice.delete(hivePropGroupSpecialPriceKey);
    });
  } catch (e) {
    print('Error synchronizing CustomerPropGroupSpecialPrice from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
Future<void> synchronizeCustomerPropCategSpecialPrice(List<String> categCodes, List<String> custCodes) async {
  List<String> propCodes = await retrievePropCodes(custCodes);

  try {
    // Fetch data from API endpoint
    var apiResponse = await _fetchCustomerPropCategSpecialPriceData(propCodes, categCodes);

    // Open Hive box
    var propCategSpecialPriceBox =
        await Hive.openBox<CustomerPropCategSpecialPrice>('customerPropCategSpecialPriceBox');

    // Synchronize data
    await _synchronizeCustomerPropCategSpecialPrice(
        apiResponse, propCategSpecialPriceBox);

    // Close Hive box if needed
    // await propCategSpecialPriceBox.close();
  } catch (e) {
    print('Error synchronizing data from API to Hive for CustomerPropCategSpecialPrice: $e');
  }
}

Future<List<Map<String, dynamic>>> _fetchCustomerPropCategSpecialPriceData(List<String> propCodes, List<String> categCodes) async {
  List<Map<String, dynamic>> customerPropCategSpecialPriceData = [];
  try {
    for (String propCode in propCodes) {
      for (String categCode in categCodes) {
        // Make API call to fetch customer prop categ special price data
        var response = await http.get(Uri.parse('${apiurl}getCustomerPropCategSpecialPrice?propCode=$propCode&categCode=$categCode'));
        if (response.statusCode == 200) {
          // Parse the response data
          dynamic responseData = jsonDecode(response.body);
          if (responseData is List) {
            for (var item in responseData) {
              if (item is Map<String, dynamic>) {
                customerPropCategSpecialPriceData.add(item);
              }
            }
          } else {
            print('Invalid response format for customer prop categ special price data');
          }
        } else {
          print('Failed to retrieve customer prop categ special price data for propCode $propCode and categCode $categCode: ${response.statusCode}');
        }
      }
    }
  } catch (e) {
    print('Error fetching customer prop categ special price data: $e');
  }
  return customerPropCategSpecialPriceData;
}

Future<void> _synchronizeCustomerPropCategSpecialPrice(
  List<Map<String, dynamic>> customerPropCategSpecialPriceData,
  Box<CustomerPropCategSpecialPrice> propCategSpecialPrice,
) async {
  try {
    // Iterate over the retrieved data
    for (var data in customerPropCategSpecialPriceData) {
      var cmpCode = data['cmpCode'];
      var custPropCode = data['custPropCode'];
      var categCode = data['categCode'];

      // Check if the prop categ special price exists in Hive
      var hivePropCategSpecialPrice = propCategSpecialPrice.get('$cmpCode$custPropCode$categCode');

      // If the prop categ special price doesn't exist in Hive, add it
      if (hivePropCategSpecialPrice == null) {
        var newPropCategSpecialPrice = CustomerPropCategSpecialPrice(
          cmpCode: cmpCode,
          custPropCode: custPropCode,
          categCode: categCode,
          disc: data['disc'],
          notes: data['notes'],
        );
        await propCategSpecialPrice.put('$cmpCode$custPropCode$categCode', newPropCategSpecialPrice);
      }
      // If the prop categ special price exists in Hive, update it if needed
      else {
        var updatedPropCategSpecialPrice = CustomerPropCategSpecialPrice(
          cmpCode: cmpCode,
          custPropCode: custPropCode,
          categCode: categCode,
          disc: data['disc'],
          notes: data['notes'],
        );
        // Update the prop categ special price in Hive
        await propCategSpecialPrice.put('$cmpCode$custPropCode$categCode', updatedPropCategSpecialPrice);
      }
    }

    // Check for prop categ special prices in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedPropCategSpecialPriceKeys = Set.from(customerPropCategSpecialPriceData.map((data) => '${data['cmpCode']}${data['custPropCode']}${data['categCode']}'));
    Set<String> hivePropCategSpecialPriceKeys = Set.from(propCategSpecialPrice.keys);

    // Identify prop categ special prices in Hive that don't exist in the fetched data
    Set<String> propCategSpecialPricesToDelete = hivePropCategSpecialPriceKeys.difference(fetchedPropCategSpecialPriceKeys);

    // Delete prop categ special prices in Hive that don't exist in the fetched data
    propCategSpecialPricesToDelete.forEach((hivePropCategSpecialPriceKey) {
      propCategSpecialPrice.delete(hivePropCategSpecialPriceKey);
    });
  } catch (e) {
    print('Error synchronizing CustomerPropCategSpecialPrice from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<List<Map<String, dynamic>>> _fetchPriceListAuthoData() async {
  List<Map<String, dynamic>> priceListAuthoData = [];
  try {
    // Make an HTTP request to fetch price list authorization data
    final response = await http.get(Uri.parse('${apiurl}getPriceListAutho'));
    if (response.statusCode == 200) {
      // Parse the response body
      List<dynamic> responseData = jsonDecode(response.body);
      // Add each item to the priceListAuthoData list
      for (var data in responseData) {
        if (data is Map<String, dynamic>) {
          priceListAuthoData.add(data);
        }
      }
    } else {
      print('Failed to retrieve price list authorization data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching price list authorization data: $e');
  }
  return priceListAuthoData;
}

Future<void> synchronizeDataPriceListsAutho() async {
  try {
    // Fetch data from the API endpoint
    List<Map<String, dynamic>> priceListAuthoData = await _fetchPriceListAuthoData();

    // Open Hive box
    var pricelistsauthoBox = await Hive.openBox<PriceListAuthorization>('pricelistAuthorizationBox');

    // Synchronize data
    await _synchronizePriceListAutho(priceListAuthoData, pricelistsauthoBox);

    // Close Hive box
    await pricelistsauthoBox.close();
  } catch (e) {
    print('Error synchronizing data from API to Hive for price list authorizations: $e');
  }
}
Future<void> _synchronizePriceListAutho(
  List<Map<String, dynamic>> priceListAuthoData,
  Box<PriceListAuthorization> priceListAuthoBox,
) async {
  try {
    for (var data in priceListAuthoData) {
      var userCode = data['userCode'] as String?;
      var cmpCode = data['cmpCode'] as String?;
      var authoGroup = data['authoGroup'] as String?;
      
      // Print the data map to inspect its structure
      print('Data Map: $data');

      // Check if any of the required keys are missing or null
      if (userCode != null && cmpCode != null && authoGroup != null) {
        var key = '$userCode$cmpCode$authoGroup';
  
        var hivePrice = priceListAuthoBox.get(key);
  
        if (hivePrice == null) {
          var newPrice = PriceListAuthorization(
            userCode: userCode,
            cmpCode: cmpCode,
            authoGroup: authoGroup
          );
          await priceListAuthoBox.put(key, newPrice);
        } else {
          var updatedPrice = PriceListAuthorization(
            userCode: userCode,
            cmpCode: cmpCode,
            authoGroup: authoGroup
          );
          await priceListAuthoBox.put(key, updatedPrice);
        }
      } else {
        // Print a message if any of the required keys are missing or null
        print('One or more required keys (userCode, cmpCode, authoGroup) are missing or null in the data map: $data');
      }
    }

    // Check for price lists in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedPriceAuthoKeys = Set.from(priceListAuthoData.map((data) => '${data['userCode']}${data['cmpCode']}${data['authoGroup']}'));
    Set<String> hivePriceAuthoKeys = Set.from(priceListAuthoBox.keys);

    // Identify price lists in Hive that don't exist in the fetched data
    Set<String> priceAuthoToDelete = hivePriceAuthoKeys.difference(fetchedPriceAuthoKeys);

    // Delete price lists in Hive that don't exist in the fetched data
    priceAuthoToDelete.forEach((key) {
      priceListAuthoBox.delete(key);
    });
  } catch (e) {
    print('Error synchronizing PriceListAuthorization data from API to Hive: $e');
  }
}





//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<void> synchronizeDataCompaniesConnection() async {
  try {
    // Fetch data from API endpoint
    var apiResponse = await _fetchCompaniesConnectionData();

    // Open Hive box
    var companiesConnectionBox = await Hive.openBox<CompaniesConnection>('companiesConnectionBox');

    // Synchronize data
    await _synchronizeCompaniesConnection(apiResponse, companiesConnectionBox);

    // Close Hive box if needed
    // await companiesConnectionBox.close();
  } catch (e) {
    print('Error synchronizing data from API to Hive: $e');
  }
}

Future<List<Map<String, dynamic>>> _fetchCompaniesConnectionData() async {
  List<Map<String, dynamic>> companiesConnectionData = [];
  try {
    // Make API call to fetch companies connection data
    var response = await http.get(Uri.parse('${apiurl}getCompaniesConnections'));
    if (response.statusCode == 200) {
      // Parse the response data
      dynamic responseData = jsonDecode(response.body);
      if (responseData is List) {
        for (var item in responseData) {
          if (item is Map<String, dynamic>) {
            companiesConnectionData.add(item);
          }
        }
      } else {
        print('Invalid response format for companies connection data');
      }
    } else {
      print('Failed to retrieve companies connection data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching companies connection data: $e');
  }
  return companiesConnectionData;
}

Future<void> _synchronizeCompaniesConnection(
  List<Map<String, dynamic>> companiesConnectionData,
  Box<CompaniesConnection> companiesConnectionBox,
) async {
  try {
    // Iterate over the retrieved data
    for (var data in companiesConnectionData) {
      var connectionID = data['connectionID'];

      // Check if the item exists in Hive
      var hiveComp = companiesConnectionBox.get('$connectionID');

      // If the item doesn't exist in Hive, add it
      if (hiveComp == null) {
        var newComp = CompaniesConnection(
          connectionID: connectionID,
          connDatabase: data['connDatabase'],
          connServer: data['connServer'],
          connUser: data['connUser'],
          connPassword: data['connPassword'],
          connPort: data['connPort'],
          typeDatabase: data['typeDatabase'],
        );
        await companiesConnectionBox.put('$connectionID', newComp);
      }
      // If the item exists in Hive, update it if needed
      else {
        var updatedComp = CompaniesConnection(
          connectionID: connectionID,
          connDatabase: data['connDatabase'],
          connServer: data['connServer'],
          connUser: data['connUser'],
          connPassword: data['connPassword'],
          connPort: data['connPort'],
          typeDatabase: data['typeDatabase'],
        );
        // Update the item in Hive
        await companiesConnectionBox.put('$connectionID', updatedComp);
      }
    }

    // Check for items in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedConnectionIDs = Set.from(companiesConnectionData.map((data) => data['connectionID']));
    Set<String> hiveConnectionIDs = Set.from(companiesConnectionBox.keys);

    // Identify items in Hive that don't exist in the fetched data
    Set<String> itemsToDelete = hiveConnectionIDs.difference(fetchedConnectionIDs);

    // Delete items in Hive that don't exist in the fetched data
    itemsToDelete.forEach((hiveConnectionID) {
      companiesConnectionBox.delete(hiveConnectionID);
    });
  } catch (e) {
    print('Error synchronizing Companies Connection data from API to Hive: $e');
  }
}



//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<void> synchronizeDataCompaniesUsers() async {
  try {
    // Fetch data from API endpoint
    var apiResponse = await _fetchCompaniesUsersData();

    // Open Hive box
    var companiesUsersBox = await Hive.openBox<CompaniesUsers>('companiesUsersBox');

    // Synchronize data
    await _synchronizeCompaniesUsers(apiResponse, companiesUsersBox);

    // Close Hive box if needed
    // await companiesUsersBox.close();
  } catch (e) {
    print('Error synchronizing data from API to Hive: $e');
  }
}

Future<List<Map<String, dynamic>>> _fetchCompaniesUsersData() async {
  List<Map<String, dynamic>> companiesUsersData = [];
  try {
    // Make API call to fetch companies users data
    var response = await http.get(Uri.parse('${apiurl}getCompaniesUsers'));
    if (response.statusCode == 200) {
      // Parse the response data
      dynamic responseData = jsonDecode(response.body);
      if (responseData is List) {
        for (var item in responseData) {
          if (item is Map<String, dynamic>) {
            companiesUsersData.add(item);
          }
        }
      } else {
        print('Invalid response format for companies users data');
      }
    } else {
      print('Failed to retrieve companies users data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching companies users data: $e');
  }
  return companiesUsersData;
}

Future<void> _synchronizeCompaniesUsers(
  List<Map<String, dynamic>> companiesUsersData,
  Box<CompaniesUsers> companiesUsersBox,
) async {
  try {
    // Iterate over the retrieved data
    for (var data in companiesUsersData) {
      var userCode = data['userCode'];
      var cmpCode = data['cmpCode'];

      // Check if the item exists in Hive
      var hiveComp = companiesUsersBox.get('$userCode$cmpCode');

      // If the item doesn't exist in Hive, add it
      if (hiveComp == null) {
        var newComp = CompaniesUsers(
          userCode: userCode,
          cmpCode: cmpCode,
          defaultcmpCode: data['defaultcmpCode'],
        );
        await companiesUsersBox.put('$userCode$cmpCode', newComp);
      }
      // If the item exists in Hive, update it if needed
      else {
        var updatedComp = CompaniesUsers(
          userCode: userCode,
          cmpCode: cmpCode,
          defaultcmpCode: data['defaultcmpCode'],
        );
        // Update the item in Hive
        await companiesUsersBox.put('$userCode$cmpCode', updatedComp);
      }
    }

    // Check for items in Hive that don't exist in the fetched data and delete them
    Set<String> fetchedCodes = Set.from(companiesUsersData.map((data) => '${data['userCode']}${data['cmpCode']}'));
    Set<String> hiveCodes = Set.from(companiesUsersBox.keys);

    // Identify items in Hive that don't exist in the fetched data
    Set<String> itemsToDelete = hiveCodes.difference(fetchedCodes);

    // Delete items in Hive that don't exist in the fetched data
    itemsToDelete.forEach((hiveCode) {
      companiesUsersBox.delete(hiveCode);
    });
  } catch (e) {
    print('Error synchronizing Companies Users data from API to Hive: $e');
  }
}
}



  // Add similar methods for synchronizing other data if needed

