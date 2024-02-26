import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:project/classes/PriceItemKey.dart';
import 'package:project/hive/addressformat_hive.dart';
import 'package:project/hive/adminsubmenu_hive.dart';
import 'package:project/hive/authorization_hive.dart';
import 'package:project/hive/companies_hive.dart';
import 'package:project/hive/companiesconnection_hive.dart';
import 'package:project/hive/companiesusers_hive.dart';
import 'package:project/hive/countries_hive.dart';
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
import 'package:project/hive/itembarcode_hive.dart';
import 'package:project/hive/itembrand_hive.dart';
import 'package:project/hive/itemcateg_hive.dart';
import 'package:project/hive/itemgroup_hive.dart';
import 'package:project/hive/itemmanufacturers_hive.dart';
import 'package:project/hive/itemprop_hive.dart';
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
String apiurl='http://5.189.188.139:8080/api/';
   TimeOfDay noTime = TimeOfDay(hour: 0, minute: 0);

Future<List<String>> retrieveSeCodes(String usercode) async {
  List<String> seCodes = [];
  try {
    // Send HTTP GET request to fetch seCodes from the server
    final response = await http.get(Uri.parse('${apiurl}getSeCodes?usercode=$usercode'));
    if (response.statusCode == 200) {
      // Parse response body and extract seCodes
      // Adjust this part based on your server's response format
      List<dynamic> responseBody = jsonDecode(response.body);
      for (var item in responseBody) {
        if (item['seCode'] != null) {
          String seCode = item['seCode'];
          seCodes.add(seCode); // Add seCode to the list
        }
      }
    } else {
      print('Failed to retrieve seCodes: ${response.statusCode}');
    }
  } catch (e) {
    print('Error retrieving seCodes: $e');
  }
  return seCodes;
}


  
Future<List<String>> retrieveItemCodes(List<String> seCodes,String cmpCode) async {
  List<String> itemCodes = [];
  try {
    for (String seCode in seCodes) {
      // Send HTTP GET request to fetch item codes from the server
      String url = '${apiurl}getSalesEmployeesItems?seCode=$seCode&cmpCode=$cmpCode';
      print('Request URL: $url'); // Print the URL for debugging
      final response = await http.get(Uri.parse('${apiurl}getSalesEmployeesItems?seCode=$seCode&cmpCode=$cmpCode'));
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

  Future<List<Map<String, dynamic>>> _fetchItemsData(
      List<String> itemCodes) async {
    List<Map<String, dynamic>> itemsData = [];
    try {
      for (String itemCode in itemCodes) {
        final response =await http.get(Uri.parse('${apiurl}getItems'));
            //await http.get(Uri.parse('${apiurl}getItems?itemCode=$itemCode'));
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
          print(
              'Failed to retrieve item details for item code $itemCode: ${response.statusCode}');
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
      List<dynamic> itemsData = await _fetchItemsData(itemCodes);

      // Synchronize data
      await _synchronizeItems(itemsData, itemsBox);
      // Synchronize other data if needed

      // Close other boxes if needed
    } catch (e) {
      print('Error synchronizing data from API to Hive: $e');
    }
  }
Future<void> _synchronizeItems(
    List<dynamic> itemsData, Box<Items> itemsBox) async {
  try {
    List<Items> itemsToUpdate = [];
    List<String> itemsToDelete = [];

    // Prepare items to update and delete
    for (var data in itemsData) {
      var itemCode = data['itemCode'] ?? '';
      var updatedItem = Items(
       data['itemCode']??'',
            data['itemName']??'',
            data['itemPrName']??'',
            data['itemFName']??'',
            data['itemPrFName']??'',
            data['groupCode']??'',
            data['categCode']??'',
            data['brandCode']??'',
            data['itemType']??'',
            data['barCode']??'',
            data['uom']??'',
            data['picture']??'',
            data['remark']??'',
            data['manageBy']??'',
            data['vatCode']??'',
            data['weight']??0,
            data['cmpCode']??'',
            data['wUOMCode']??'',
            data['salesItem']??'',
            data['purchItem']??'',
            data['invntItem']??'',
        // Populate other fields similarly
      );

      itemsToUpdate.add(updatedItem);
    }

    // Batch update items
    await itemsBox.putAll(Map.fromIterable(itemsToUpdate, key: (item) => item.itemCode));

    // Delete items not present in the updated data
    Set<String> updatedItemCodes = itemsToUpdate.map((item) => item.itemCode).toSet();
    itemsBox.keys.where((itemCode) => !updatedItemCodes.contains(itemCode)).forEach((itemCode) {
      itemsToDelete.add(itemCode);
    });
    await itemsBox.deleteAll(itemsToDelete);
  } catch (e) {
    print('Error synchronizing items from API to Hive: $e');
  }
}




//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

  Future<List<String>> retrievePriceList(List<String> itemCodes,String cmpCode) async {
    List<String> priceLists = [];
    try {
      for (String itemCode in itemCodes) {
        final response = await http
            .get(Uri.parse('${apiurl}getItemPrice?itemCode=$itemCode&cmpCode=$cmpCode'));
        if (response.statusCode == 200) {
          List<dynamic> responseData = jsonDecode(response.body);
          for (var data in responseData) {
            priceLists.add(data['plCode']);
          }
        } else {
          print(
              'Failed to retrieve price list Codes for item code $itemCode: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error retrieving price list Codes: $e');
    }
    return priceLists;
  }

  Future<List<Map<String, dynamic>>> _fetchPriceListData(
      List<String> priceLists) async {
    List<Map<String, dynamic>> priceListData = [];
    try {
      for (String plCode in priceLists) {
        final response = await http.get(Uri.parse('${apiurl}getPriceList'));
         //   await http.get(Uri.parse('${apiurl}getPriceList?plCode=$plCode'));
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
          print(
              'Failed to retrieve price list data for plCode $plCode: ${response.statusCode}');
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
      List<Map<String, dynamic>> priceListData =
          await _fetchPriceListData(priceLists);

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
    List<PriceList> priceListsToUpdate = [];
    List<String> priceListsToDelete = [];

    // Prepare price lists to update and delete
    for (var data in priceListData) {
      var plCode = data['plCode'] ?? '';
      var updatedPriceList = PriceList(
         data['plCode']??'',
          data['plName']??'',
          data['currency']??'',
          data['basePL']??'',
          data['factor']??0,
          data['incVAT']== 1 ? true : false, // Convert Tinyint to Boolean
          data['cmpCode']??'',
          data['authoGroup']??'',
          data['plFName']??'',
          data['notes']??''
        // Populate other fields similarly
      );

      priceListsToUpdate.add(updatedPriceList);
    }

    // Batch update price lists
    await pricelistsBox.putAll(Map.fromIterable(priceListsToUpdate, key: (priceList) => priceList.plCode));

    // Delete price lists not present in the updated data
    Set<String> updatedPriceListCodes = priceListsToUpdate.map((priceList) => priceList.plCode).toSet();
    pricelistsBox.keys.where((plCode) => !updatedPriceListCodes.contains(plCode)).forEach((plCode) {
      priceListsToDelete.add(plCode);
    });
    await pricelistsBox.deleteAll(priceListsToDelete);
  } catch (e) {
    print('Error synchronizing PriceLists from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> _fetchItemPricesData(
      List<String> itemCodes) async {
    List<Map<String, dynamic>> itemPricesData = [];
    try {
      for (String itemCode in itemCodes) {
        final response = await http
            .get(Uri.parse('${apiurl}getItemPrice?itemCode=$itemCode'));
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
          print(
              'Failed to retrieve item prices for item code $itemCode: ${response.statusCode}');
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
      List<Map<String, dynamic>> itemPricesData =
          await _fetchItemPricesData(itemCodes);

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
    List<ItemsPrices> itemPricesToUpdate = [];
    List<String> itemPricesToDelete = [];

    // Prepare item prices to update and delete
    for (var data in itemPricesData) {
      var plCode = data['plCode'] ?? '';
      var itemCode = data['itemCode'] ?? '';

      var updatedItemPrice = ItemsPrices(
        plCode,
        itemCode,
        data['uom'] ?? '',
        data['basePrice'] ?? 0,
        data['currency'] ?? '',
        data['auto'] == 1 ? true : false,
        data['disc'] ?? 0,
        data['price'] ?? 0,
        data['cmpCode'] ?? '',
      );

      itemPricesToUpdate.add(updatedItemPrice);
    }

    // Batch update item prices
    await itempriceBox.putAll(Map.fromIterable(itemPricesToUpdate, key: (itemPrice) => '${itemPrice.plCode}${itemPrice.itemCode}'));

    // Delete item prices not present in the updated data
    Set<String> updatedItemPriceKeys = itemPricesToUpdate.map((itemPrice) => '${itemPrice.plCode}${itemPrice.itemCode}').toSet();
    itempriceBox.keys.where((itemPriceKey) => !updatedItemPriceKeys.contains(itemPriceKey)).forEach((itemPriceKey) {
      itemPricesToDelete.add(itemPriceKey);
    });
    await itempriceBox.deleteAll(itemPricesToDelete);
  } catch (e) {
    print('Error synchronizing ItemPrices from API to Hive: $e');
  }
}


//---------------------------------------

  Future<List<Map<String, dynamic>>> _fetchItemAttachData(
      List<String> itemCodes) async {
    List<Map<String, dynamic>> itemAttachData = [];
    try {
      for (String itemCode in itemCodes) {
        final response = await http
            .get(Uri.parse('${apiurl}getItemAttach?itemCode=$itemCode'));
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
          print(
              'Failed to retrieve item attach for item code $itemCode: ${response.statusCode}');
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
      List<Map<String, dynamic>> apiResponse =
          await _fetchItemAttachData(itemCodes);

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
    List<ItemAttach> itemAttachsToUpdate = [];
    List<String> itemAttachsToDelete = [];

    // Prepare item attachments to update and delete
    for (var data in itemAttachData) {
      var itemCode = data['itemCode'] ?? '';

      var updatedItemAttach = ItemAttach(
        data['itemCode'] ?? '',
        data['attachmentType'] ?? '',
        data['attachmentPath'] ?? '',
        data['note'] ?? '',
        data['cmpCode'] ?? '',
      );

      itemAttachsToUpdate.add(updatedItemAttach);
    }

    // Batch update item attachments
    await itemattachBox.putAll(Map.fromIterable(itemAttachsToUpdate, key: (itemAttach) => itemAttach.itemCode));

    // Delete item attachments not present in the updated data
    Set<String> updatedItemAttachCodes = itemAttachsToUpdate.map((itemAttach) => itemAttach.itemCode).toSet();
    itemattachBox.keys.where((itemAttachCode) => !updatedItemAttachCodes.contains(itemAttachCode)).forEach((itemAttachCode) {
      itemAttachsToDelete.add(itemAttachCode);
    });
    await itemattachBox.deleteAll(itemAttachsToDelete);
  } catch (e) {
    print('Error synchronizing ItemAttach from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

  Future<List<String>> retrieveItemGroupCodes(List<String> seCodes,String cmpCode) async {
    List<String> itemGroupCodes = [];
    try {
      for (String seCode in seCodes) {
        // Make API call to retrieve item group codes for the given sales employee code
        var response = await http.get(
            Uri.parse('${apiurl}getSalesEmployeesItemsGroups?seCode=$seCode&cmpCode=$cmpCode'));
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

  Future<List<Map<String, dynamic>>> _fetchItemGroupData(
      List<String> itemGroupCodes) async {
    List<Map<String, dynamic>> itemGroupData = [];
    try {
      for (String groupCode in itemGroupCodes) {
        final response = await http.get(Uri.parse('${apiurl}getItemGroup'));
      //     await http.get(Uri.parse('${apiurl}getItemGroup?groupCode=$groupCode'));
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
          print(
              'Failed to retrieve item group for group code $groupCode: ${response.statusCode}');
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
      List<Map<String, dynamic>> apiResponse =
          await _fetchItemGroupData(itemGroupCodes);

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
    List<ItemGroup> itemGroupsToUpdate = [];
    List<String> itemGroupsToDelete = [];

    // Prepare item groups to update and delete
    for (var data in itemGroupData) {
      var groupCode = data['groupCode'] ?? '';
      var cmpCode = data['cmpCode'] ?? '';

      var updatedItemGroup = ItemGroup(
        data['groupCode'] ?? '',
        data['groupName'] ?? '',
        data['groupFName'] ?? '',
        data['cmpCode'] ?? '',
      );

      itemGroupsToUpdate.add(updatedItemGroup);
    }

    // Batch update item groups
    await itemgroupBox.putAll(Map.fromIterable(itemGroupsToUpdate, key: (itemGroup) => '${itemGroup.groupCode}${itemGroup.cmpCode}'));

    // Delete item groups not present in the updated data
    Set<String> updatedItemGroupCodes = itemGroupsToUpdate.map((itemGroup) => '${itemGroup.groupCode}${itemGroup.cmpCode}').toSet();
    itemgroupBox.keys.where((itemGroupCode) => !updatedItemGroupCodes.contains(itemGroupCode)).forEach((itemGroupCode) {
      itemGroupsToDelete.add(itemGroupCode);
    });
    await itemgroupBox.deleteAll(itemGroupsToDelete);
  } catch (e) {
    print('Error synchronizing ItemGroup from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

  Future<List<String>> retrieveItemCateg(List<String> seCodes,String cmpCode) async {
    List<String> itemCategCodes = [];
    try {
      for (String seCode in seCodes) {
        // Make API call to retrieve item category codes for the given sales employee code
        var response = await http.get(Uri.parse(
            '${apiurl}getSalesEmployeesItemsCategories?seCode=$seCode&cmpCode=$cmpCode'));
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
          print(
              'Failed to retrieve item category codes: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error retrieving item category codes: $e');
    }
    return itemCategCodes;
  }

  Future<List<Map<String, dynamic>>> _fetchItemCategData(
      List<String> itemCateg) async {
    List<Map<String, dynamic>> itemCategData = [];
    try {
      for (String categCode in itemCateg) {
        final response =await http.get(Uri.parse('${apiurl}getItemCateg'));
           // await http.get(Uri.parse('${apiurl}getItemCateg?categCode=$categCode'));
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
          print(
              'Failed to retrieve item category for category code $categCode: ${response.statusCode}');
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
      List<Map<String, dynamic>> apiResponse =
          await _fetchItemCategData(itemCateg);

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
    List<ItemCateg> itemCategsToUpdate = [];
    List<String> itemCategsToDelete = [];

    // Prepare item categories to update and delete
    for (var data in itemCategData) {
      var categCode = data['categCode'] ?? '';
      var cmpCode = data['cmpCode'] ?? '';

      var updatedItemCateg = ItemCateg(
        data['categCode'] ?? '',
        data['categName'] ?? '',
        data['categFName'] ?? '',
        data['cmpCode'] ?? '',
      );

      itemCategsToUpdate.add(updatedItemCateg);
    }

    // Batch update item categories
    await itemcategBox.putAll(Map.fromIterable(itemCategsToUpdate, key: (itemCateg) => '${itemCateg.categCode}${itemCateg.cmpCode}'));

    // Delete item categories not present in the updated data
    Set<String> updatedItemCategCodes = itemCategsToUpdate.map((itemCateg) => '${itemCateg.categCode}${itemCateg.cmpCode}').toSet();
    itemcategBox.keys.where((itemCategCode) => !updatedItemCategCodes.contains(itemCategCode)).forEach((itemCategCode) {
      itemCategsToDelete.add(itemCategCode);
    });
    await itemcategBox.deleteAll(itemCategsToDelete);
  } catch (e) {
    print('Error synchronizing ItemCateg from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

  Future<List<String>> retrieveItemBrand(List<String> seCodes,String cmpCode) async {
    List<String> itemBrandCodes = [];
    try {
      for (String seCode in seCodes) {
        // Make API call to retrieve item brand codes for the given sales employee code
        var response = await http.get(
            Uri.parse('${apiurl}getSalesEmployeesItemsBrands?seCode=$seCode&cmpCode=$cmpCode'));
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

  Future<List<Map<String, dynamic>>> _fetchItemBrandData(
      List<String> itemBrand) async {
    List<Map<String, dynamic>> itemBrandData = [];
    try {
      for (String brandCode in itemBrand) {
        final response = await http .get(Uri.parse('${apiurl}getItemBrand'));
           //= await http .get(Uri.parse('${apiurl}getItemBrand?brandCode=$brandCode'));
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
          print(
              'Failed to retrieve item brand for brand code $brandCode: ${response.statusCode}');
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
      List<Map<String, dynamic>> apiResponse =
          await _fetchItemBrandData(itemBrand);

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
    List<ItemBrand> itemBrandsToUpdate = [];
    List<String> itemBrandsToDelete = [];

    // Prepare item brands to update and delete
    for (var data in itemBrandData) {
      var brandCode = data['brandCode'] ?? '';
      var cmpCode = data['cmpCode'] ?? '';

      var updatedItemBrand = ItemBrand(
        data['brandCode'] ?? '',
        data['brandName'] ?? '',
        data['brandFName'] ?? '',
        data['cmpCode'] ?? '',
      );

      itemBrandsToUpdate.add(updatedItemBrand);
    }

    // Batch update item brands
    await itembrandBox.putAll(Map.fromIterable(itemBrandsToUpdate, key: (itemBrand) => '${itemBrand.brandCode}${itemBrand.cmpCode}'));

    // Delete item brands not present in the updated data
    Set<String> updatedItemBrandCodes = itemBrandsToUpdate.map((itemBrand) => '${itemBrand.brandCode}${itemBrand.cmpCode}').toSet();
    itembrandBox.keys.where((itemBrandCode) => !updatedItemBrandCodes.contains(itemBrandCode)).forEach((itemBrandCode) {
      itemBrandsToDelete.add(itemBrandCode);
    });
    await itembrandBox.deleteAll(itemBrandsToDelete);
  } catch (e) {
    print('Error synchronizing ItemBrand from API to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> _fetchItemUOMData(
      List<String> itemCodes) async {
    List<Map<String, dynamic>> itemUOMData = [];
    try {
      for (String itemCode in itemCodes) {
        final response =await http.get(Uri.parse('${apiurl}getItemUOM'));
           // await http.get(Uri.parse('${apiurl}getItemUOM?itemCode=$itemCode'));
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
          print(
              'Failed to retrieve item UOM for item code $itemCode: ${response.statusCode}');
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
      List<Map<String, dynamic>> apiResponse =
          await _fetchItemUOMData(itemCodes);

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
    List<ItemUOM> itemUOMsToUpdate = [];
    List<String> itemUOMsToDelete = [];

    // Prepare item UOMs to update and delete
    for (var data in itemUOMData) {
      var uom = data['uom'] ?? '';
      var itemCode = data['itemCode'] ?? '';
      var cmpCode = data['cmpCode'] ?? '';

      var updatedItemUOM = ItemUOM(
        data['itemCode'] ?? '',
        data['uom'] ?? '',
        data['qtyperUOM'] ?? 0,
        data['barCode'] ?? '',
        data['cmpCode'] ?? '',
      );

      itemUOMsToUpdate.add(updatedItemUOM);
    }

    // Batch update item UOMs
    await itemuomBox.putAll(Map.fromIterable(itemUOMsToUpdate, key: (itemUOM) => '${itemUOM.uom}${itemUOM.itemCode}${itemUOM.cmpCode}'));

    // Delete item UOMs not present in the updated data
    Set<String> updatedItemUOMCodes = itemUOMsToUpdate.map((itemUOM) => '${itemUOM.uom}${itemUOM.itemCode}${itemUOM.cmpCode}').toSet();
    itemuomBox.keys.where((itemUOMCode) => !updatedItemUOMCodes.contains(itemUOMCode)).forEach((itemUOMCode) {
      itemUOMsToDelete.add(itemUOMCode);
    });
    await itemuomBox.deleteAll(itemUOMsToDelete);
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
    List<UserPL> userPLsToUpdate = [];
    List<String> userPLsToDelete = [];

    // Prepare user PLs to update and delete
    for (var data in userPLData) {
      var userCode = data['userCode'] ?? '';

      var updatedUserPL = UserPL(
        data['userCode'] ?? '',
        data['plSecGroup'] ?? '',
      );

      userPLsToUpdate.add(updatedUserPL);
    }

    // Batch update user PLs
    await userplBox.putAll(Map.fromIterable(userPLsToUpdate, key: (userPL) => userPL.userCode));

    // Delete user PLs not present in the updated data
    Set<String> updatedUserPLCodes = userPLsToUpdate.map((userPL) => userPL.userCode).toSet();
    userplBox.keys.where((userPLCode) => !updatedUserPLCodes.contains(userPLCode)).forEach((userPLCode) {
      userPLsToDelete.add(userPLCode);
    });
    await userplBox.deleteAll(userPLsToDelete);
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
      Set<dynamic> apiUserCodes =
          Set.from(userData.map((data) => data['usercode']));

      // Get the list of user codes in the Hive box
      Set<dynamic> hiveUserCodes = Set.from(userBox.keys);

      // Identify user codes in Hive that don't exist in the API response
      Set<dynamic> userCodesToDelete = hiveUserCodes.difference(apiUserCodes);

    // Iterate over API response
    for (var data in userData) {
      var usercode = data['usercode'];

      // Convert the active field to a boolean
      bool active = data['active'] == 1 ? true : false;

      // Update the data with the converted active field
      data['active'] = active;

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
      var groupcode = data['groupcode']??'';

      // If the item doesn't exist in Hive, add it
      if (!usersGroup.containsKey(groupcode)) {
        var newUserGroup = UserGroup(
          groupcode: data['groupcode']??'',
          groupname: data['groupname']??'',
        );
        await usersGroup.put(groupcode, newUserGroup);
      }
      // If the item exists in Hive, update it if needed
      else {
        var updatedUserGroup = UserGroup(
          groupcode: data['groupcode']??'',
          groupname: data['groupname']??'',
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
      Set<dynamic> itemsToDelete =
          hiveUserGroupCodes.difference(fetchedUserGroupCodes);

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
        List<Map<String, dynamic>> data =
            List<Map<String, dynamic>>.from(jsonData);

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
      List<Map<String, dynamic>> mysqlData =
          await _fetchUserGroupTranslationsData();

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
      var groupcode = data['groupcode']??'';

      // If the item doesn't exist in Hive, add it
      if (!translationBox.containsKey(groupcode)) {
        var newTranslations = Translations(
          groupcode: groupcode,
          translations: {'en': data['en']??'', 'ar': data['ar']??''},
        );
        await translationBox.put(groupcode, newTranslations);
      }
      // If the item exists in Hive, update it if needed
      else {
        var updatedTranslations = Translations(
          groupcode: groupcode,
          translations: {'en': data['en']??'', 'ar': data['ar']??''},
        );
        // Update the item in Hive
        await translationBox.put(groupcode, updatedTranslations);
      }
    }

      // Delete items in Hive that don't exist in MySQL data
      Set<dynamic> mysqlGroupCodes =
          Set.from(mysqlData.map((data) => data['groupcode']));
      Set<dynamic> hiveGroupCodes = Set.from(translationBox.keys);

      // Identify items in Hive that don't exist in MySQL data
      Set<dynamic> itemsToDelete = hiveGroupCodes.difference(mysqlGroupCodes);

      // Delete items in Hive that don't exist in MySQL data
      itemsToDelete.forEach((groupcode) {
        translationBox.delete(groupcode);
      });
    } catch (e) {
      print(
          'Error synchronizing User Group Translations from MySQL to Hive: $e');
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
      var syncGroupBox =
          await Hive.openBox<SynchronizeSubMenu>('synchronizeSubMenu');

      // Synchronize data
      await _synchronizeMenu(apiResponse, apiSubAdminResponse,
          apiSubSyncResponse, menuBox, userGroupBox, syncGroupBox);

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
        List<Map<String, dynamic>> data =
            List<Map<String, dynamic>>.from(jsonData);

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
        List<Map<String, dynamic>> data =
            List<Map<String, dynamic>>.from(jsonData);

        return data;
      } else {
        // If the request was not successful, print error message
        print(
            'Failed to fetch Admin sub menu data. Status code: ${response.statusCode}');
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
        List<Map<String, dynamic>> data =
            List<Map<String, dynamic>>.from(jsonData);

        return data;
      } else {
        // If the request was not successful, print error message
        print(
            'Failed to fetch Admin sub menu data. Status code: ${response.statusCode}');
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
      var menucode = data['menucode']??'';

        // Check if the menu item exists in Hive
        var hiveMenu = menuBox.get(menucode);

      // If the menu item doesn't exist in Hive, add it
      if (hiveMenu == null) {
        var newMenu = Menu(
          menucode: data['menucode']??'',
          menuname: data['menuname']??'',
          menuarname: data['menuarname']??'',
        );
        await menuBox.put(menucode, newMenu);
      } else {
        // If the menu item exists in Hive, update it if needed
        var updatedMenu = Menu(
          menucode: data['menucode']??'',
          menuname: data['menuname']??'',
          menuarname: data['menuarname']??'',
        );
        // Update the item in Hive
        await menuBox.put(menucode, updatedMenu);
      }

        // Synchronize the usergroups and syncgroups subcollections
        await _synchronizeSubMenu(menucode, apiSubAdminResponse, adminGroupBox);
        await synchronizeIESubMenu(
            menucode, apiSubSynchronizeResponse, syncGroupBox);
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
      var groupcode = subMenu['groupcode']??'';

        // Check if the usergroup/syncgroup exists in Hive
        var hiveGroup = groupBox.get(groupcode);

      // If the usergroup/syncgroup doesn't exist in Hive, add it
      if (hiveGroup == null) {
        var newGroup = AdminSubMenu(
          groupcode: subMenu['groupcode']??'',
          groupname: subMenu['groupname']??'',
          grouparname: subMenu['grouparname']??'',
          
        );
        await groupBox.put(groupcode, newGroup);
      } else {
        // If the usergroup/syncgroup exists in Hive, update it if needed
        var updatedGroup = AdminSubMenu(
          groupcode: subMenu['groupcode']??'',
          groupname: subMenu['groupname']??'',
          grouparname: subMenu['grouparname']??'',
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
      var syncronizecode = subMenu['syncronizecode']??'';

        // Check if the usergroup/syncgroup exists in Hive
        var hiveGroup = syncGroupBox.get(syncronizecode);

      // If the usergroup/syncgroup doesn't exist in Hive, add it
      if (hiveGroup == null) {
        var newGroup = SynchronizeSubMenu(
          syncronizecode: subMenu['syncronizecode']??'',
          syncronizename: subMenu['syncronizename']??'',
          syncronizearname: subMenu['syncronizearname']??'',
          
        );
        await syncGroupBox.put(syncronizecode, newGroup);
      } else {
        // If the usergroup/syncgroup exists in Hive, update it if needed
        var updatedGroup = SynchronizeSubMenu(
             syncronizecode: subMenu['syncronizecode']??'',
          syncronizename: subMenu['syncronizename']??'',
          syncronizearname: subMenu['syncronizearname']??'',
        );
        // Update the item in Hive
        await syncGroupBox.put(syncronizecode, updatedGroup);
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
      print(responseData);
      if (responseData is List) {
        print('hi');
        // If the response is a list, append each authorization data to the authorizationData list
        for (var authData in responseData) {
          print('Type of authData: ${authData.runtimeType}');
          print('Keys of authData: ${authData.keys}');
          if (authData is Map<String, dynamic>) {
            print('helo');
            print(authData);
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
print(apiResponse);
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
      var menucode = data['menucode']??'';
      var groupcode = data['groupcode']??'';

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
      var groupcode = data['groupcode']??'';

        // Check if the item exists in Hive
        var hiveSystem = systemAdminBox.get(groupcode);

      // If the item doesn't exist in Hive, add it
      if (hiveSystem == null) {
        var newSystem = SystemAdmin(
          autoExport: data['autoExport']== 1 ? true : false,
          groupcode: data['groupcode']??'',
          importFromErpToMobile: data['importFromErpToMobile']== 1 ? true : false,
          importFromBackendToMobile: data['importFromBackendToMobile']== 1 ? true : false,
        );
        await systemAdminBox.put(groupcode, newSystem);
      }
      // If the item exists in Hive, update it if needed
      else {
        var updatedSystem = SystemAdmin(
          autoExport: data['autoExport']== 1 ? true : false,
          groupcode: data['groupcode']??'',
          importFromErpToMobile: data['importFromErpToMobile']== 1 ? true : false,
          importFromBackendToMobile: data['importFromBackendToMobile']== 1 ? true : false,
        );
        // Update the item in Hive
        await systemAdminBox.put(groupcode, updatedSystem);
      }
    }

    // Check for items in Hive that don't exist in the fetched data and delete them
    Set<int> fetchedSystemCodes =
        Set.from(generalSettingsData.map((data) => data['groupcode']));
    Set<int> hiveSystemCodes = Set.from(systemAdminBox.keys);

    // Identify items in Hive that don't exist in the fetched data
    Set<int> itemsToDelete = hiveSystemCodes.difference(fetchedSystemCodes);

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
TimeOfDay parseTime(String timeString) {
  List<String> parts = timeString.split(':');
  int hour = int.parse(parts[0]);
  int minute = int.parse(parts[1]);
  return TimeOfDay(hour: hour, minute: minute);
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
          cmpCode: data['cmpCode']??'',
          cmpName: data['cmpName']??'',
          cmpFName: data['cmpFName']??'',
          tel: data['tel']??'',
          mobile: data['mobile']??'',
          address: data['address']??'',
          fAddress: data['fAddress']??'',
          prHeader: data['prHeader']??'',
          prFHeader: data['prFHeader']??'',
          prFooter: data['prFooter']??'',
          prFFooter: data['prFFooter']??'',
          mainCurCode: data['mainCurCode']??'',
          secCurCode: data['secCurCode']??'',
          rateType: data['rateType']??'',
          issueBatchMethod: data['issueBatchMethod']??'',
          systemAdminID: data['systemAdminID']??'',
          notes: data['notes']??'',
          priceDec: data['priceDec']??0,
          amntDec: data['amntDec']??0, 
          qtyDec: data['qtyDec']??0,
          roundMethod: data['roundMethod']??'',
          importMethod: data['importMethod']??'',
time: data['time'] != null ? parseTime(data['time']) : noTime,
        );
        await companiesBox.put(cmpCode, newCompany);
      } else {
        var updatedCompany = Companies(
         cmpCode: data['cmpCode']??'',
          cmpName: data['cmpName']??'',
          cmpFName: data['cmpFName']??'',
          tel: data['tel']??'',
          mobile: data['mobile']??'',
          address: data['address']??'',
          fAddress: data['fAddress']??'',
          prHeader: data['prHeader']??'',
          prFHeader: data['prFHeader']??'',
          prFooter: data['prFooter']??'',
          prFFooter: data['prFFooter']??'',
          mainCurCode: data['mainCurCode']??'',
          secCurCode: data['secCurCode']??'',
          rateType: data['rateType']??'',
          issueBatchMethod: data['issueBatchMethod']??'',
          systemAdminID: data['systemAdminID']??'',
          notes: data['notes']??'',
          priceDec: data['priceDec']??0,
          amntDec: data['amntDec']??0, 
          qtyDec: data['qtyDec']??0,
          roundMethod: data['roundMethod']??'',
          importMethod: data['importMethod']??'',
        time: data['time'] != null ? parseTime(data['time']) : noTime,
        );
        await companiesBox.put(cmpCode, updatedCompany);
      }
    }

      // Check for companies in Hive that don't exist in the fetched data and delete them
      Set<String> fetchedCompanyCodes =
          Set.from(companiesData.map((data) => data['cmpCode']));
      Set<String> hiveCompanyCodes = Set.from(companiesBox.keys);

      // Identify companies in Hive that don't exist in the fetched data
      Set<String> companiesToDelete =
          hiveCompanyCodes.difference(fetchedCompanyCodes);

      // Delete companies in Hive that don't exist in the fetched data
      companiesToDelete.forEach((hiveCompanyCode) {
        companiesBox.delete(hiveCompanyCode);
      });
    } catch (e) {
      print('Error synchronizing Companies from API to Hive: $e');
    }
  }
//----
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
    List<Departements> departmentsToUpdate = [];
    List<String> departmentsToDelete = [];

    // Prepare departments to update and delete
    for (var data in departmentsData) {
      var cmpCode = data['cmpCode'] ?? '';
      var depCode = data['depCode'] ?? '';

      var updatedDepartment = Departements(
        cmpCode: cmpCode,
        depCode: depCode,
        depName: data['depName'] ?? '',
        depFName: data['depFName'] ?? '',
        notes: data['notes'] ?? '',
      );

      departmentsToUpdate.add(updatedDepartment);
    }

    // Batch update departments
    await departmentsBox.putAll(Map.fromIterable(departmentsToUpdate, key: (department) => '${department.cmpCode}${department.depCode}'));

    // Delete departments not present in the updated data
    Set<String> updatedDepartmentKeys = departmentsToUpdate.map((department) => '${department.cmpCode}${department.depCode}').toSet();
    departmentsBox.keys.where((departmentKey) => !updatedDepartmentKeys.contains(departmentKey)).forEach((departmentKey) {
      departmentsToDelete.add(departmentKey);
    });
    await departmentsBox.deleteAll(departmentsToDelete);
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
    List<ExchangeRate> exchangeRatesToUpdate = [];
    List<String> exchangeRatesToDelete = [];

    // Prepare exchange rates to update and delete
    for (var data in exchangeRatesData) {
      var cmpCode = data['cmpCode'] ?? '';
      var curCode = data['curCode'] ?? '';

      var updatedExchangeRate = ExchangeRate(
        cmpCode: cmpCode,
        curCode: curCode,
        fDate: DateTime.parse(data['fDate']),
        tDate: DateTime.parse(data['tDate']),
        rate: data['rate'] ?? '',
      );

      exchangeRatesToUpdate.add(updatedExchangeRate);
    }

    // Batch update exchange rates
    await exchangeRatesBox.putAll(Map.fromIterable(exchangeRatesToUpdate, key: (exchangeRate) => '${exchangeRate.cmpCode}${exchangeRate.curCode}'));

    // Delete exchange rates not present in the updated data
    Set<String> updatedExchangeRateKeys = exchangeRatesToUpdate.map((exchangeRate) => '${exchangeRate.cmpCode}${exchangeRate.curCode}').toSet();
    exchangeRatesBox.keys.where((exchangeRateKey) => !updatedExchangeRateKeys.contains(exchangeRateKey)).forEach((exchangeRateKey) {
      exchangeRatesToDelete.add(exchangeRateKey);
    });
    await exchangeRatesBox.deleteAll(exchangeRatesToDelete);
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
    List<Currencies> currenciesToUpdate = [];
    List<String> currenciesToDelete = [];

    // Prepare currencies to update and delete
    for (var data in currenciesData) {
      var cmpCode = data['cmpCode'] ?? '';
      var curCode = data['curCode'] ?? '';

      var updatedCurrency = Currencies(
        cmpCode: cmpCode,
        curCode: curCode,
        curName: data['curName'] ?? '',
        curFName: data['curFName'] ?? '',
        notes: data['notes'] ?? '',
        amntDec: data['amntDec'] ?? 0,
        rounding: data['rounding'] ?? 0,
      );

      currenciesToUpdate.add(updatedCurrency);
    }

    // Batch update currencies
    await currenciesBox.putAll(Map.fromIterable(currenciesToUpdate, key: (currency) => '${currency.cmpCode}${currency.curCode}'));

    // Delete currencies not present in the updated data
    Set<String> updatedCurrencyKeys = currenciesToUpdate.map((currency) => '${currency.cmpCode}${currency.curCode}').toSet();
    currenciesBox.keys.where((currencyKey) => !updatedCurrencyKeys.contains(currencyKey)).forEach((currencyKey) {
      currenciesToDelete.add(currencyKey);
    });
    await currenciesBox.deleteAll(currenciesToDelete);
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
    List<VATGroups> vatGroupsToUpdate = [];
    List<String> vatGroupsToDelete = [];

    // Prepare VAT groups to update and delete
    for (var data in vatGroupsData) {
      var cmpCode = data['cmpCode'] ?? '';
      var vatCode = data['vatCode'] ?? '';

      var updatedVATGroup = VATGroups(
        cmpCode: cmpCode,
        vatCode: vatCode,
        vatName: data['vatName'] ?? '',
        vatRate: data['vatRate'] ?? '',
        baseCurCode: data['baseCurCode'] ?? '',
        notes: data['notes'] ?? '',
      );

      vatGroupsToUpdate.add(updatedVATGroup);
    }

    // Batch update VAT groups
    await vatGroupsBox.putAll(Map.fromIterable(vatGroupsToUpdate, key: (vatGroup) => '${vatGroup.cmpCode}${vatGroup.vatCode}'));

    // Delete VAT groups not present in the updated data
    Set<String> updatedVATGroupKeys = vatGroupsToUpdate.map((vatGroup) => '${vatGroup.cmpCode}${vatGroup.vatCode}').toSet();
    vatGroupsBox.keys.where((vatGroupKey) => !updatedVATGroupKeys.contains(vatGroupKey)).forEach((vatGroupKey) {
      vatGroupsToDelete.add(vatGroupKey);
    });
    await vatGroupsBox.deleteAll(vatGroupsToDelete);
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
        print(
            'Failed to retrieve customer groups data: ${response.statusCode}');
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
    List<CustGroups> custGroupsToUpdate = [];
    List<String> custGroupsToDelete = [];

    // Prepare customer groups to update and delete
    for (var data in custGroupsData) {
      var cmpCode = data['cmpCode'] ?? '';
      var grpCode = data['grpCode'] ?? '';

      var updatedCustGroup = CustGroups(
        cmpCode: cmpCode,
        grpCode: grpCode,
        grpName: data['grpName'] ?? '',
        grpFName: data['grpFName'] ?? '',
        notes: data['notes'] ?? '',
      );

      custGroupsToUpdate.add(updatedCustGroup);
    }

    // Batch update customer groups
    await custGroupsBox.putAll(Map.fromIterable(custGroupsToUpdate, key: (custGroup) => '${custGroup.cmpCode}${custGroup.grpCode}'));

    // Delete customer groups not present in the updated data
    Set<String> updatedCustGroupKeys = custGroupsToUpdate.map((custGroup) => '${custGroup.cmpCode}${custGroup.grpCode}').toSet();
    custGroupsBox.keys.where((custGroupKey) => !updatedCustGroupKeys.contains(custGroupKey)).forEach((custGroupKey) {
      custGroupsToDelete.add(custGroupKey);
    });
    await custGroupsBox.deleteAll(custGroupsToDelete);
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
        print(
            'Failed to retrieve customer properties data: ${response.statusCode}');
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
      var custPropertiesBox =
          await Hive.openBox<CustProperties>('custPropertiesBox');

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
    List<CustProperties> custPropertiesToUpdate = [];
    List<String> custPropertiesToDelete = [];

    // Prepare customer properties to update and delete
    for (var data in custPropertiesData) {
      var cmpCode = data['cmpCode'] ?? '';
      var propCode = data['propCode'] ?? '';

      var updatedCustProperty = CustProperties(
        cmpCode: cmpCode,
        propCode: propCode,
        propName: data['propName'] ?? '',
        propFName: data['propFName'] ?? '',
        notes: data['notes'] ?? '',
      );

      custPropertiesToUpdate.add(updatedCustProperty);
    }

    // Batch update customer properties
    await custPropertiesBox.putAll(Map.fromIterable(custPropertiesToUpdate, key: (custProperty) => '${custProperty.cmpCode}${custProperty.propCode}'));

    // Delete customer properties not present in the updated data
    Set<String> updatedCustPropertyKeys = custPropertiesToUpdate.map((custProperty) => '${custProperty.cmpCode}${custProperty.propCode}').toSet();
    custPropertiesBox.keys.where((custPropertyKey) => !updatedCustPropertyKeys.contains(custPropertyKey)).forEach((custPropertyKey) {
      custPropertiesToDelete.add(custPropertyKey);
    });
    await custPropertiesBox.deleteAll(custPropertiesToDelete);
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
    List<Regions> regionsToUpdate = [];
    List<String> regionsToDelete = [];

    // Prepare regions to update and delete
    for (var data in regionsData) {
      var cmpCode = data['cmpCode'] ?? '';
      var regCode = data['regCode'] ?? '';

      var updatedRegion = Regions(
        cmpCode: cmpCode,
        regCode: regCode,
        regName: data['regName'] ?? '',
        regFName: data['regFName'] ?? '',
        notes: data['notes'] ?? '',
      );

      regionsToUpdate.add(updatedRegion);
    }

    // Batch update regions
    await regionsBox.putAll(Map.fromIterable(regionsToUpdate, key: (region) => '${region.cmpCode}${region.regCode}'));

    // Delete regions not present in the updated data
    Set<String> updatedRegionKeys = regionsToUpdate.map((region) => '${region.cmpCode}${region.regCode}').toSet();
    regionsBox.keys.where((regionKey) => !updatedRegionKeys.contains(regionKey)).forEach((regionKey) {
      regionsToDelete.add(regionKey);
    });
    await regionsBox.deleteAll(regionsToDelete);
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
    List<Warehouses> warehousesToUpdate = [];
    List<String> warehousesToDelete = [];

    // Prepare warehouses to update and delete
    for (var data in warehousesData) {
      var cmpCode = data['cmpCode'] ?? '';
      var whsCode = data['whsCode'] ?? '';

      var updatedWarehouse = Warehouses(
        cmpCode: cmpCode,
        whsCode: whsCode,
        whsName: data['whsName'] ?? '',
        whsFName: data['whsFName'] ?? '',
        notes: data['notes'] ?? '',
        binActivate: data['binActivate'] == 1 ? true : false, // Convert Tinyint to Boolean
      );

      warehousesToUpdate.add(updatedWarehouse);
    }

    // Batch update warehouses
    await warehousesBox.putAll(Map.fromIterable(warehousesToUpdate, key: (warehouse) => '${warehouse.cmpCode}${warehouse.whsCode}'));

    // Delete warehouses not present in the updated data
    Set<String> updatedWarehouseKeys = warehousesToUpdate.map((warehouse) => '${warehouse.cmpCode}${warehouse.whsCode}').toSet();
    warehousesBox.keys.where((warehouseKey) => !updatedWarehouseKeys.contains(warehouseKey)).forEach((warehouseKey) {
      warehousesToDelete.add(warehouseKey);
    });
    await warehousesBox.deleteAll(warehousesToDelete);
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
    List<PaymentTerms> paymentTermsToUpdate = [];
    List<String> paymentTermsToDelete = [];

    // Prepare payment terms to update and delete
    for (var data in paymentTermsData) {
      var cmpCode = data['cmpCode'] ?? '';
      var ptCode = data['ptCode'] ?? '';

      var updatedPaymentTerm = PaymentTerms(
        cmpCode: cmpCode,
        ptCode: ptCode,
        ptName: data['ptName'] ?? '',
        ptFName: data['ptFName'] ?? '',
        startFrom: data['startFrom'] ?? '',
        nbrofDays: data['nbrofDays'] ?? '',
        notes: data['notes'] ?? '',
        nbrofMonths: data['nbrofMonths'] ?? 0,
      );

      paymentTermsToUpdate.add(updatedPaymentTerm);
    }

    // Batch update payment terms
    await paymentTermsBox.putAll(Map.fromIterable(paymentTermsToUpdate, key: (paymentTerm) => '${paymentTerm.cmpCode}${paymentTerm.ptCode}'));

    // Delete payment terms not present in the updated data
    Set<String> updatedPaymentTermKeys = paymentTermsToUpdate.map((paymentTerm) => '${paymentTerm.cmpCode}${paymentTerm.ptCode}').toSet();
    paymentTermsBox.keys.where((paymentTermKey) => !updatedPaymentTermKeys.contains(paymentTermKey)).forEach((paymentTermKey) {
      paymentTermsToDelete.add(paymentTermKey);
    });
    await paymentTermsBox.deleteAll(paymentTermsToDelete);
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
      List<Map<String, dynamic>> apiResponse =
          await _fetchSalesEmployeesData(seCodes);

      // Open Hive box
      var salesEmployeesBox =
          await Hive.openBox<SalesEmployees>('salesEmployeesBox');

      // Synchronize data
      await _synchronizeSalesEmployees(apiResponse, salesEmployeesBox);
    } catch (e) {
      print('Error synchronizing data from API to Hive for SalesEmployees: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchSalesEmployeesData(
      List<String> seCodes) async {
    List<Map<String, dynamic>> salesEmployeesData = [];
    try {
      // Iterate over each seCode and fetch data for each one
      for (String seCode in seCodes) {
        final response = await http
            .get(Uri.parse('${apiurl}getSalesEmployees?seCode=$seCode'));
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
          print(
              'Failed to retrieve sales employees data for seCode $seCode: ${response.statusCode}');
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
    List<SalesEmployees> salesEmployeesToUpdate = [];
    List<String> salesEmployeesToDelete = [];

    // Prepare sales employees to update and delete
    for (var data in salesEmployeesData) {
      var cmpCode = data['cmpCode'] ?? '';
      var seCode = data['seCode'] ?? '';

      var updatedSalesEmployee = SalesEmployees(
        cmpCode: cmpCode,
        seCode: seCode,
        seName: data['seName'] ?? '',
        seFName: data['seFName'] ?? '',
        mobile: data['mobile'] ?? '',
        email: data['email'] ?? '',
        whsCode: data['whsCode'] ?? '',
        reqFromWhsCode: data['reqFromWhsCode'] ?? '',
        notes: data['notes'] ?? '',
      );

      salesEmployeesToUpdate.add(updatedSalesEmployee);
    }

    // Batch update sales employees
    await salesEmployeesBox.putAll(Map.fromIterable(salesEmployeesToUpdate, key: (salesEmployee) => '${salesEmployee.cmpCode}${salesEmployee.seCode}'));

    // Delete sales employees not present in the updated data
    Set<String> updatedSalesEmployeeKeys = salesEmployeesToUpdate.map((salesEmployee) => '${salesEmployee.cmpCode}${salesEmployee.seCode}').toSet();
    salesEmployeesBox.keys.where((salesEmployeeKey) => !updatedSalesEmployeeKeys.contains(salesEmployeeKey)).forEach((salesEmployeeKey) {
      salesEmployeesToDelete.add(salesEmployeeKey);
    });
    await salesEmployeesBox.deleteAll(salesEmployeesToDelete);
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
      List<Map<String, dynamic>> apiResponse =
          await _fetchSalesEmployeesCustomersData(seCodes);

      // Open Hive box
      var salesEmployeesCustomersBox =
          await Hive.openBox<SalesEmployeesCustomers>(
              'salesEmployeesCustomersBox');

      // Synchronize data
      await _synchronizeSalesEmployeesCustomers(
          apiResponse, salesEmployeesCustomersBox);
    } catch (e) {
      print(
          'Error synchronizing data from API to Hive for SalesEmployeesCustomers: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchSalesEmployeesCustomersData(
      List<String> seCodes) async {
    List<Map<String, dynamic>> salesEmployeesCustomersData = [];
    try {
      // Iterate over each seCode and fetch data for each one
      for (String seCode in seCodes) {
        final response = await http.get(
            Uri.parse('${apiurl}getSalesEmployeesCustomers?seCode=$seCode'));
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
          print(
              'Failed to retrieve sales employees customers data for seCode $seCode: ${response.statusCode}');
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
    List<SalesEmployeesCustomers> salesEmployeesCustomersToUpdate = [];
    List<String> salesEmployeesCustomersToDelete = [];

    // Prepare sales employee customer relationships to update and delete
    for (var data in salesEmployeesCustomersData) {
      var cmpCode = data['cmpCode'] ?? '';
      var seCode = data['seCode'] ?? '';
      var custCode = data['custCode'] ?? '';

      var updatedSalesEmployeesCustomers = SalesEmployeesCustomers(
        cmpCode: cmpCode,
        seCode: seCode,
        custCode: custCode,
        notes: data['notes'] ?? '',
      );

      salesEmployeesCustomersToUpdate.add(updatedSalesEmployeesCustomers);
    }

    // Batch update sales employee customer relationships
    await salesEmployeesCustomersBox.putAll(Map.fromIterable(salesEmployeesCustomersToUpdate, key: (salesEmployeeCustomer) => '${salesEmployeeCustomer.cmpCode}${salesEmployeeCustomer.seCode}${salesEmployeeCustomer.custCode}'));

    // Delete sales employee customer relationships not present in the updated data
    Set<String> updatedSalesEmployeesCustomersKeys = salesEmployeesCustomersToUpdate.map((salesEmployeeCustomer) => '${salesEmployeeCustomer.cmpCode}${salesEmployeeCustomer.seCode}${salesEmployeeCustomer.custCode}').toSet();
    salesEmployeesCustomersBox.keys.where((salesEmployeeCustomerKey) => !updatedSalesEmployeesCustomersKeys.contains(salesEmployeeCustomerKey)).forEach((salesEmployeeCustomerKey) {
      salesEmployeesCustomersToDelete.add(salesEmployeeCustomerKey);
    });
    await salesEmployeesCustomersBox.deleteAll(salesEmployeesCustomersToDelete);
  } catch (e) {
    print('Error synchronizing SalesEmployeesCustomers from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

  Future<void> synchronizeSalesEmployeesDepartments(
      List<String> seCodes) async {
    try {
      // Fetch data from API endpoint using seCodes
      List<Map<String, dynamic>> apiResponse =
          await _fetchSalesEmployeesDepartmentsData(seCodes);

      // Open Hive box
      var salesEmployeesDepartmentsBox =
          await Hive.openBox<SalesEmployeesDepartements>(
              'salesEmployeesDepartmentsBox');

      // Synchronize data
      await _synchronizeSalesEmployeesDepartments(
          apiResponse, salesEmployeesDepartmentsBox);
    } catch (e) {
      print(
          'Error synchronizing data from API to Hive for SalesEmployeesDepartments: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchSalesEmployeesDepartmentsData(
      List<String> seCodes) async {
    List<Map<String, dynamic>> salesEmployeesDepartmentsData = [];
    try {
      // Iterate over each seCode and fetch data for each one
      for (String seCode in seCodes) {
        final response = await http.get(
            Uri.parse('${apiurl}getSalesEmployeesDepartments?seCode=$seCode'));
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
            print(
                'Invalid response format for sales employees departments data');
          }
        } else {
          print(
              'Failed to retrieve sales employees departments data for seCode $seCode: ${response.statusCode}');
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
    List<SalesEmployeesDepartements> salesEmployeesDepartmentsToUpdate = [];
    List<String> salesEmployeesDepartmentsToDelete = [];

    // Prepare sales employee department relationships to update and delete
    for (var data in salesEmployeesDepartmentsData) {
      var cmpCode = data['cmpCode'] ?? '';
      var seCode = data['seCode'] ?? '';
      var deptCode = data['deptCode'] ?? '';

      var updatedSalesEmployeesDepartments = SalesEmployeesDepartements(
        cmpCode: cmpCode,
        seCode: seCode,
        deptCode: deptCode,
        reqFromWhsCode: data['reqFromWhsCode'] ?? '',
        notes: data['notes'] ?? '',
      );

      salesEmployeesDepartmentsToUpdate.add(updatedSalesEmployeesDepartments);
    }

    // Batch update sales employee department relationships
    await salesEmployeesDepartmentsBox.putAll(Map.fromIterable(salesEmployeesDepartmentsToUpdate, key: (salesEmployeeDepartment) => '${salesEmployeeDepartment.cmpCode}${salesEmployeeDepartment.seCode}${salesEmployeeDepartment.deptCode}'));

    // Delete sales employee department relationships not present in the updated data
    Set<String> updatedSalesEmployeesDepartmentsKeys = salesEmployeesDepartmentsToUpdate.map((salesEmployeeDepartment) => '${salesEmployeeDepartment.cmpCode}${salesEmployeeDepartment.seCode}${salesEmployeeDepartment.deptCode}').toSet();
    salesEmployeesDepartmentsBox.keys.where((salesEmployeeDepartmentKey) => !updatedSalesEmployeesDepartmentsKeys.contains(salesEmployeeDepartmentKey)).forEach((salesEmployeeDepartmentKey) {
      salesEmployeesDepartmentsToDelete.add(salesEmployeeDepartmentKey);
    });
    await salesEmployeesDepartmentsBox.deleteAll(salesEmployeesDepartmentsToDelete);
  } catch (e) {
    print('Error synchronizing SalesEmployeesDepartments from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
  Future<void> synchronizeSalesEmployeesItemsBrands(
      List<String> seCodes) async {
    try {
      // Fetch data from API endpoint using seCodes
      List<Map<String, dynamic>> apiResponse =
          await _fetchSalesEmployeesItemsBrandsData(seCodes);

      // Open Hive box
      var salesEmployeesItemsBrandsBox =
          await Hive.openBox<SalesEmployeesItemsBrands>(
              'salesEmployeesItemsBrandsBox');

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
    List<SalesEmployeesItemsBrands> salesEmployeesItemsBrandsToUpdate = [];
    List<String> salesEmployeesItemsBrandsToDelete = [];

    // Prepare sales employee items brands relationships to update and delete
    for (var data in salesEmployeesItemsBrandsData) {
      var cmpCode = data['cmpCode'] ?? '';
      var seCode = data['seCode'] ?? '';
      var brandCode = data['brandCode'] ?? '';

      var updatedSalesEmployeesItemsBrands = SalesEmployeesItemsBrands(
        cmpCode: cmpCode,
        seCode: seCode,
        brandCode: brandCode,
        reqFromWhsCode: data['reqFromWhsCode'] ?? '',
        notes: data['notes'] ?? '',
      );

      salesEmployeesItemsBrandsToUpdate.add(updatedSalesEmployeesItemsBrands);
    }

    // Batch update sales employee items brands relationships
    await salesEmployeesItemsBrandsBox.putAll(Map.fromIterable(salesEmployeesItemsBrandsToUpdate, key: (salesEmployeeItemsBrand) => '${salesEmployeeItemsBrand.cmpCode}${salesEmployeeItemsBrand.seCode}${salesEmployeeItemsBrand.brandCode}'));

    // Delete sales employee items brands relationships not present in the updated data
    Set<String> updatedSalesEmployeesItemsBrandsKeys = salesEmployeesItemsBrandsToUpdate.map((salesEmployeeItemsBrand) => '${salesEmployeeItemsBrand.cmpCode}${salesEmployeeItemsBrand.seCode}${salesEmployeeItemsBrand.brandCode}').toSet();
    salesEmployeesItemsBrandsBox.keys.where((salesEmployeeItemsBrandKey) => !updatedSalesEmployeesItemsBrandsKeys.contains(salesEmployeeItemsBrandKey)).forEach((salesEmployeeItemsBrandKey) {
      salesEmployeesItemsBrandsToDelete.add(salesEmployeeItemsBrandKey);
    });
    await salesEmployeesItemsBrandsBox.deleteAll(salesEmployeesItemsBrandsToDelete);
  } catch (e) {
    print('Error synchronizing SalesEmployeesItemsBrands from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

  Future<void> synchronizeSalesEmployeesItemsCategories(
      List<String> seCodes) async {
    try {
      // Fetch data from API endpoint using seCodes
      List<Map<String, dynamic>> apiResponse =
          await _fetchSalesEmployeesItemsCategoriesData(seCodes);

      // Open Hive box
      var salesEmployeesItemsCategoriesBox =
          await Hive.openBox<SalesEmployeesItemsCategories>(
              'salesEmployeesItemsCategoriesBox');

      // Synchronize data
      await _synchronizeSalesEmployeesItemsCategories(
          apiResponse, salesEmployeesItemsCategoriesBox);
    } catch (e) {
      print(
          'Error synchronizing data from API to Hive for SalesEmployeesItemsCategories: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchSalesEmployeesItemsCategoriesData(
      List<String> seCodes) async {
    List<Map<String, dynamic>> salesEmployeesItemsCategoriesData = [];
    try {
      // Iterate over each seCode and fetch data for each one
      for (String seCode in seCodes) {
        final response = await http.get(Uri.parse(
            '${apiurl}getSalesEmployeesItemsCategories?seCode=$seCode'));
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
            print(
                'Invalid response format for sales employees items categories data');
          }
        } else {
          print(
              'Failed to retrieve sales employees items categories data for seCode $seCode: ${response.statusCode}');
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
    List<SalesEmployeesItemsCategories> salesEmployeesItemsCategoriesToUpdate = [];
    List<String> salesEmployeesItemsCategoriesToDelete = [];

    // Prepare sales employee items categories relationships to update and delete
    for (var data in salesEmployeesItemsCategoriesData) {
      var cmpCode = data['cmpCode'] ?? '';
      var seCode = data['seCode'] ?? '';
      var categCode = data['categCode'] ?? '';

      var updatedSalesEmployeesItemsCategories = SalesEmployeesItemsCategories(
        cmpCode: cmpCode,
        seCode: seCode,
        categCode: categCode,
        reqFromWhsCode: data['reqFromWhsCode'] ?? '',
        notes: data['notes'] ?? '',
      );

      salesEmployeesItemsCategoriesToUpdate.add(updatedSalesEmployeesItemsCategories);
    }

    // Batch update sales employee items categories relationships
    await salesEmployeesItemsCategoriesBox.putAll(Map.fromIterable(salesEmployeesItemsCategoriesToUpdate, key: (salesEmployeeItemsCategory) => '${salesEmployeeItemsCategory.cmpCode}${salesEmployeeItemsCategory.seCode}${salesEmployeeItemsCategory.categCode}'));

    // Delete sales employee items categories relationships not present in the updated data
    Set<String> updatedSalesEmployeesItemsCategoriesKeys = salesEmployeesItemsCategoriesToUpdate.map((salesEmployeeItemsCategory) => '${salesEmployeeItemsCategory.cmpCode}${salesEmployeeItemsCategory.seCode}${salesEmployeeItemsCategory.categCode}').toSet();
    salesEmployeesItemsCategoriesBox.keys.where((salesEmployeeItemsCategoryKey) => !updatedSalesEmployeesItemsCategoriesKeys.contains(salesEmployeeItemsCategoryKey)).forEach((salesEmployeeItemsCategoryKey) {
      salesEmployeesItemsCategoriesToDelete.add(salesEmployeeItemsCategoryKey);
    });
    await salesEmployeesItemsCategoriesBox.deleteAll(salesEmployeesItemsCategoriesToDelete);
  } catch (e) {
    print('Error synchronizing SalesEmployeesItemsCategories from API to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
  Future<void> synchronizeSalesEmployeesItemsGroups(
      List<String> seCodes) async {
    try {
      // Fetch data from API endpoint using seCodes
      List<Map<String, dynamic>> apiResponse =
          await _fetchSalesEmployeesItemsGroupsData(seCodes);

      // Open Hive box
      var salesEmployeesItemsGroupsBox =
          await Hive.openBox<SalesEmployeesItemsGroups>(
              'salesEmployeesItemsGroupsBox');

      // Synchronize data
      await _synchronizeSalesEmployeesItemsGroups(
          apiResponse, salesEmployeesItemsGroupsBox);
    } catch (e) {
      print(
          'Error synchronizing data from API to Hive for SalesEmployeesItemsGroups: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchSalesEmployeesItemsGroupsData(
      List<String> seCodes) async {
    List<Map<String, dynamic>> salesEmployeesItemsGroupsData = [];
    try {
      // Iterate over each seCode and fetch data for each one
      for (String seCode in seCodes) {
        final response = await http.get(
            Uri.parse('${apiurl}getSalesEmployeesItemsGroups?seCode=$seCode'));
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
            print(
                'Invalid response format for sales employees items groups data');
          }
        } else {
          print(
              'Failed to retrieve sales employees items groups data for seCode $seCode: ${response.statusCode}');
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
    List<SalesEmployeesItemsGroups> salesEmployeesItemsGroupsToUpdate = [];
    List<String> salesEmployeesItemsGroupsToDelete = [];

    // Prepare sales employee items groups relationships to update and delete
    for (var data in salesEmployeesItemsGroupsData) {
      var cmpCode = data['cmpCode'] ?? '';
      var seCode = data['seCode'] ?? '';
      var groupCode = data['groupCode'] ?? '';

      var updatedSalesEmployeesItemsGroups = SalesEmployeesItemsGroups(
        cmpCode: cmpCode,
        seCode: seCode,
        groupCode: groupCode,
        reqFromWhsCode: data['reqFromWhsCode'] ?? '',
        notes: data['notes'] ?? '',
      );

      salesEmployeesItemsGroupsToUpdate.add(updatedSalesEmployeesItemsGroups);
    }

    // Batch update sales employee items groups relationships
    await salesEmployeesItemsGroupsBox.putAll(Map.fromIterable(salesEmployeesItemsGroupsToUpdate, key: (salesEmployeeItemsGroup) => '${salesEmployeeItemsGroup.cmpCode}${salesEmployeeItemsGroup.seCode}${salesEmployeeItemsGroup.groupCode}'));

    // Delete sales employee items groups relationships not present in the updated data
    Set<String> updatedSalesEmployeesItemsGroupsKeys = salesEmployeesItemsGroupsToUpdate.map((salesEmployeeItemsGroup) => '${salesEmployeeItemsGroup.cmpCode}${salesEmployeeItemsGroup.seCode}${salesEmployeeItemsGroup.groupCode}').toSet();
    salesEmployeesItemsGroupsBox.keys.where((salesEmployeeItemsGroupKey) => !updatedSalesEmployeesItemsGroupsKeys.contains(salesEmployeeItemsGroupKey)).forEach((salesEmployeeItemsGroupKey) {
      salesEmployeesItemsGroupsToDelete.add(salesEmployeeItemsGroupKey);
    });
    await salesEmployeesItemsGroupsBox.deleteAll(salesEmployeesItemsGroupsToDelete);
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
      List<Map<String, dynamic>> apiResponse =
          await _fetchSalesEmployeesItemsData(seCodes);

      // Open Hive box
      var salesEmployeesItemsBox =
          await Hive.openBox<SalesEmployeesItems>('salesEmployeesItemsBox');

      // Synchronize data
      await _synchronizeSalesEmployeesItems(
          apiResponse, salesEmployeesItemsBox);
    } catch (e) {
      print(
          'Error synchronizing data from API to Hive for SalesEmployeesItems: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchSalesEmployeesItemsData(
      List<String> seCodes) async {
    List<Map<String, dynamic>> salesEmployeesItemsData = [];
    try {
      // Iterate over each seCode and fetch data for each one
      for (String seCode in seCodes) {
        final response = await http
            .get(Uri.parse('${apiurl}getSalesEmployeesItems?seCode=$seCode'));
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
          print(
              'Failed to retrieve sales employees items data for seCode $seCode: ${response.statusCode}');
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
    List<SalesEmployeesItems> salesEmployeesItemsToUpdate = [];
    List<String> salesEmployeesItemsToDelete = [];

    // Prepare sales employee items relationships to update
    for (var data in salesEmployeesItemsData) {
      var cmpCode = data['cmpCode'] ?? '';
      var seCode = data['seCode'] ?? '';
      var itemCode = data['itemCode'] ?? '';

      var updatedSalesEmployeesItems = SalesEmployeesItems(
        cmpCode: cmpCode,
        seCode: seCode,
        itemCode: itemCode,
        reqFromWhsCode: data['reqFromWhsCode'] ?? '',
        notes: data['notes'] ?? '',
      );

      salesEmployeesItemsToUpdate.add(updatedSalesEmployeesItems);
    }

    // Batch update sales employee items relationships
    await salesEmployeesItemsBox.putAll(Map.fromIterable(salesEmployeesItemsToUpdate, key: (salesEmployeeItem) => '${salesEmployeeItem.cmpCode}${salesEmployeeItem.seCode}${salesEmployeeItem.itemCode}'));

    // Delete sales employee items relationships not present in the updated data
    Set<String> updatedSalesEmployeesItemsKeys = salesEmployeesItemsToUpdate.map((salesEmployeeItem) => '${salesEmployeeItem.cmpCode}${salesEmployeeItem.seCode}${salesEmployeeItem.itemCode}').toSet();
    salesEmployeesItemsBox.keys.where((salesEmployeeItemKey) => !updatedSalesEmployeesItemsKeys.contains(salesEmployeeItemKey)).forEach((salesEmployeeItemKey) {
      salesEmployeesItemsToDelete.add(salesEmployeeItemKey);
    });
    await salesEmployeesItemsBox.deleteAll(salesEmployeesItemsToDelete);
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
      List<Map<String, dynamic>> apiResponse =
          await _fetchUserSalesEmployeesData();

      // Open Hive box
      var userSalesEmployeesBox =
          await Hive.openBox<UserSalesEmployees>('userSalesEmployeesBox');

      // Synchronize data
      await _synchronizeUserSalesEmployees(apiResponse, userSalesEmployeesBox);
    } catch (e) {
      print(
          'Error synchronizing data from API to Hive for UserSalesEmployees: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUserSalesEmployeesData() async {
    List<Map<String, dynamic>> userSalesEmployeesData = [];
    try {
      // Perform HTTP GET request to fetch user sales employees data from the API endpoint
      final response =
          await http.get(Uri.parse('${apiurl}getUserSalesEmployees'));
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
        print(
            'Failed to retrieve user sales employees data: ${response.statusCode}');
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
    List<UserSalesEmployees> userSalesEmployeesToUpdate = [];
    List<String> userSalesEmployeesToDelete = [];

    // Prepare user sales employees relationships to update
    for (var data in userSalesEmployeesData) {
      var userCode = data['userCode'] ?? '';
      var cmpCode = data['cmpCode'] ?? '';
      var seCode = data['seCode'] ?? '';

      var updatedUserSalesEmployees = UserSalesEmployees(
        cmpCode: cmpCode,
        userCode: userCode,
        seCode: seCode,
        notes: data['notes'] ?? '',
      );

      userSalesEmployeesToUpdate.add(updatedUserSalesEmployees);
    }

    // Batch update user sales employees relationships
    await userSalesEmployeesBox.putAll(Map.fromIterable(userSalesEmployeesToUpdate, key: (userSalesEmployee) => '${userSalesEmployee.userCode}${userSalesEmployee.cmpCode}${userSalesEmployee.seCode}'));

    // Delete user sales employees relationships not present in the updated data
    Set<String> updatedUserSalesEmployeesKeys = userSalesEmployeesToUpdate.map((userSalesEmployee) => '${userSalesEmployee.userCode}${userSalesEmployee.cmpCode}${userSalesEmployee.seCode}').toSet();
    userSalesEmployeesBox.keys.where((userSalesEmployeeKey) => !updatedUserSalesEmployeesKeys.contains(userSalesEmployeeKey)).forEach((userSalesEmployeeKey) {
      userSalesEmployeesToDelete.add(userSalesEmployeeKey);
    });
    await userSalesEmployeesBox.deleteAll(userSalesEmployeesToDelete);
  } catch (e) {
    print('Error synchronizing UserSalesEmployees from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
Future<List<String>> retrieveCustCodes(List<String> seCodes,String cmpCode) async {
 print('ksdpds'); print(seCodes);print('ksdps');
  List<String> custCodes = [];
  try {
    for (String seCode in seCodes) {
      final response = await http.get(Uri.parse('${apiurl}getSalesEmployeesCustomers?seCode=$seCode&cmpCode=$cmpCode'));
      print(response.body);
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
    //List<Map<String, dynamic>> apiResponse = await _fetchCustomersData(custCodes);
List<Map<String, dynamic>> apiResponse = await _fetchCustomersData(custCodes);
    // Open Hive box
    var customersBox = await Hive.openBox<Customers>('customersBox');

      // Synchronize data
      await _synchronizeCustomers(apiResponse, customersBox);
    } catch (e) {
      print('Error synchronizing data from API to Hive for Customers: $e');
    }
  }



Future<List<Map<String, dynamic>>> _fetchCustomersData(List<String>custCodes) async {
  List<Map<String, dynamic>> customersData = [];
  try {
    for (String custCode in custCodes) {
      final response = await http.get(Uri.parse('${apiurl}getCustomers?custCode=$custCode'));
      if (response.statusCode == 200) {
                dynamic responseData = jsonDecode(response.body);

      if (responseData is List) {
          // If the response is a list, append each item to the itemsData list
          for (var item in responseData) {
            if (item is Map<String, dynamic>) {
              customersData.add(item);
            }
          }
        } else if (responseData is Map<String, dynamic>) {
          // If the response is a map, directly append it to the itemsData list
          customersData.add(responseData);
        }
      } else {
        print('Failed to retrieve customer data for custCode : ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error fetching customer data: $e');
  }
  return customersData;
}
Future<void> _synchronizeCustomers(
  List<Map<String, dynamic>> customersData,
  Box<Customers> customersBox,
) async {
  try {
    List<Customers> customersToUpdate = [];
    List<String> customersToDelete = [];

    // Prepare customers to update
    for (var data in customersData) {
      var cmpCode = data['cmpCode'] ?? '';
      var custCode = data['custCode'] ?? '';

      var updatedCustomer = Customers(
        cmpCode: cmpCode,
        custCode: custCode,
        custName: data['custName'] ?? '',
        custFName: data['custFName'] ?? '',
        groupCode: data['groupCode'] ?? '',
        mofNum: data['mofNum'] ?? '',
        barcode: data['barcode'] ?? '',
        phone: data['phone'] ?? '',
        mobile: data['mobile'] ?? '',
        fax: data['fax'] ?? '',
        website: data['website'] ?? '',
        email: data['email'] ?? '',
        active: data['active'] == 1 ? true : false,
        printLayout: data['printLayout'] ?? '',
        dfltAddressID: data['dfltAddressID'] ?? '',
        dfltContactID: data['dfltContactID'] ?? '',
        curCode: data['curCode'] ?? '',
        cashClient: data['cashClient'] ?? '',
        discType: data['discType'] ?? '',
        vatCode: data['vatCode'] ?? '',
        prListCode: data['prListCode'] ?? '',
        payTermsCode: data['payTermsCode'] ?? '',
        discount: data['discount'] ?? '',
        creditLimit: data['creditLimit'] ?? '',
        balance: data['balance'] ?? '',
        balanceDue: data['balanceDue'] ?? '',
        notes: data['notes'] ?? '',
      );

      customersToUpdate.add(updatedCustomer);
    }

    // Batch update customers
    await customersBox.putAll(Map.fromIterable(customersToUpdate, key: (customer) => '${customer.cmpCode}${customer.custCode}'));

    // Delete customers not present in the updated data
    Set<String> updatedCustomersKeys = customersToUpdate.map((customer) => '${customer.cmpCode}${customer.custCode}').toSet();
    customersBox.keys.where((customerKey) => !updatedCustomersKeys.contains(customerKey)).forEach((customerKey) {
      customersToDelete.add(customerKey);
    });
    await customersBox.deleteAll(customersToDelete);
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
      List<Map<String, dynamic>> apiResponse =
          await _fetchCustomerAddressesData(custCodes);

      // Open Hive box
      var addressesBox =
          await Hive.openBox<CustomerAddresses>('customerAddressesBox');

      // Synchronize data
      await _synchronizeCustomerAddresses(apiResponse, addressesBox);
    } catch (e) {
      print(
          'Error synchronizing data from API to Hive for CustomerAddresses: $e');
    }
  }

Future<List<Map<String, dynamic>>> _fetchCustomerAddressesData(List<String> custCodes) async {
  List<Map<String, dynamic>> addressesData = [];
  try {
    for (String custCode in custCodes) {
      final response = await http.get(Uri.parse('${apiurl}getCustomerAddresses?custCode=$custCode'));
      if (response.statusCode == 200) {
     dynamic responseData = jsonDecode(response.body);
        if (responseData is List) {
          // If the response is a list, append each item to the itemsData list
          for (var item in responseData) {
            if (item is Map<String, dynamic>) {
              addressesData.add(item);
            }
          }
        } else if (responseData is Map<String, dynamic>) {
          // If the response is a map, directly append it to the itemsData list
          addressesData.add(responseData);
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
  Box<CustomerAddresses> addressesBox,
) async {
  try {
    List<CustomerAddresses> addressesToUpdate = [];
    List<String> addressesToDelete = [];

    // Prepare addresses to update
    for (var data in addressesData) {
      var cmpCode = data['cmpCode'] ?? '';
      var addressID = data['addressID'] ?? '';
      var custCode = data['custCode'] ?? '';
      var addressType = data['addressType'] ?? '';

      var updatedAddress = CustomerAddresses(
        cmpCode: cmpCode,
        custCode: custCode,
        addressID: addressID,
        address: data['address'] ?? '',
        fAddress: data['fAddress'] ?? '',
        regCode: data['regCode'] ?? '',
        gpslat: data['gpslat'] ?? '',
        gpslong: data['gpslong'] ?? '',
        notes: data['notes'] ?? '',
        addressType: addressType,
        countryCode: data['countryCode'] ?? '',
        city: data['city'] ?? '',
        block: data['block'] ?? '',
        street: data['street'] ?? '',
        zipCode: data['zipCode'] ?? '',
        building: data['building'] ?? '',
      );

      addressesToUpdate.add(updatedAddress);
    }

    // Batch update addresses
    await addressesBox.putAll(Map.fromIterable(addressesToUpdate, key: (address) => '${address.cmpCode}${address.addressID}${address.custCode}${address.addressType}'));

    // Delete addresses not present in the updated data
    Set<String> updatedAddressesKeys = addressesToUpdate.map((address) => '${address.cmpCode}${address.addressID}${address.custCode}${address.addressType}').toSet();
    addressesBox.keys.where((addressKey) => !updatedAddressesKeys.contains(addressKey)).forEach((addressKey) {
      addressesToDelete.add(addressKey);
    });
    await addressesBox.deleteAll(addressesToDelete);
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
      List<Map<String, dynamic>> apiResponse =
          await _fetchCustomerContactsData(custCodes);

      // Open Hive box
      var contactsBox =
          await Hive.openBox<CustomerContacts>('customerContactsBox');

      // Synchronize data
      await _synchronizeCustomerContacts(apiResponse, contactsBox);
    } catch (e) {
      print(
          'Error synchronizing data from API to Hive for CustomerContacts: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCustomerContactsData(
      List<String> custCodes) async {
    List<Map<String, dynamic>> contactsData = [];
    try {
      for (String custCode in custCodes) {
        final response = await http
            .get(Uri.parse('${apiurl}getCustomerContacts?custCode=$custCode'));
        if (response.statusCode == 200) {
          dynamic responseData = jsonDecode(response.body);
          if (responseData is List) {
            contactsData.addAll(responseData.cast<Map<String, dynamic>>());
          } else {
            print('Invalid response format for customer contacts data');
          }
        } else {
          print(
              'Failed to retrieve customer contacts data for custCode $custCode: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error fetching customer contacts data: $e');
    }
    return contactsData;
  }
Future<void> _synchronizeCustomerContacts(
  List<Map<String, dynamic>> contactsData,
  Box<CustomerContacts> contactsBox,
) async {
  try {
    List<CustomerContacts> contactsToUpdate = [];
    List<String> contactsToDelete = [];

    // Prepare contacts to update
    for (var data in contactsData) {
      var cmpCode = data['cmpCode'] ?? '';
      var contactID = data['contactID'] ?? '';
      var custCode = data['custCode'] ?? '';

      var updatedContact = CustomerContacts(
        cmpCode: cmpCode,
        custCode: custCode,
        contactID: contactID,
        contactName: data['contactName'] ?? '',
        contactFName: data['contactFName'] ?? '',
        phone: data['phone'] ?? '',
        mobile: data['mobile'] ?? '',
        email: data['email'] ?? '',
        position: data['position'] ?? '',
        notes: data['notes'] ?? '',
      );

      contactsToUpdate.add(updatedContact);
    }

    // Batch update contacts
    await contactsBox.putAll(Map.fromIterable(contactsToUpdate, key: (contact) => '${contact.cmpCode}${contact.contactID}${contact.custCode}'));

    // Delete contacts not present in the updated data
    Set<String> updatedContactsKeys = contactsToUpdate.map((contact) => '${contact.cmpCode}${contact.contactID}${contact.custCode}').toSet();
    contactsBox.keys.where((contactKey) => !updatedContactsKeys.contains(contactKey)).forEach((contactKey) {
      contactsToDelete.add(contactKey);
    });
    await contactsBox.deleteAll(contactsToDelete);
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
      List<Map<String, dynamic>> apiResponse =
          await _fetchCustomerPropertiesData(custCodes);

      // Open Hive box
      var propertiesBox =
          await Hive.openBox<CustomerProperties>('customerPropertiesBox');

      // Synchronize data
      await _synchronizeCustomerProperties(apiResponse, propertiesBox);
    } catch (e) {
      print(
          'Error synchronizing data from API to Hive for CustomerProperties: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCustomerPropertiesData(
      List<String> custCodes) async {
    List<Map<String, dynamic>> customerPropertiesData = [];
    try {
      // Iterate over each custCode and fetch data for each one
      for (String custCode in custCodes) {
        // Make API call to fetch customer properties data
        var response = await http.get(
            Uri.parse('${apiurl}getCustomerProperties?custCode=$custCode'));
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
          print(
              'Failed to retrieve customer properties data for custCode $custCode: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error fetching customer properties data: $e');
    }
    return customerPropertiesData;
  }
Future<void> _synchronizeCustomerProperties(
  List<Map<String, dynamic>> customerPropertiesData,
  Box<CustomerProperties> propertiesBox,
) async {
  try {
    List<CustomerProperties> propertiesToUpdate = [];
    List<String> propertiesToDelete = [];

    // Prepare properties to update
    for (var data in customerPropertiesData) {
      var cmpCode = data['cmpCode'] ?? '';
      var custCode = data['custCode'] ?? '';
      var propCode = data['propCode'] ?? '';

      var updatedProperty = CustomerProperties(
        cmpCode: cmpCode,
        custCode: custCode,
        propCode: propCode,
        notes: data['notes'] ?? '',
      );

      propertiesToUpdate.add(updatedProperty);
    }

    // Batch update properties
    await propertiesBox.putAll(Map.fromIterable(propertiesToUpdate, key: (property) => '${property.cmpCode}${property.propCode}${property.custCode}'));

    // Delete properties not present in the updated data
    Set<String> updatedPropertiesKeys = propertiesToUpdate.map((property) => '${property.cmpCode}${property.propCode}${property.custCode}').toSet();
    propertiesBox.keys.where((propertyKey) => !updatedPropertiesKeys.contains(propertyKey)).forEach((propertyKey) {
      propertiesToDelete.add(propertyKey);
    });
    await propertiesBox.deleteAll(propertiesToDelete);
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
      List<Map<String, dynamic>> apiResponse =
          await _fetchCustomerAttachmentsData(custCodes);

      // Open Hive box
      var attachmentsBox =
          await Hive.openBox<CustomerAttachments>('customerAttachmentsBox');

      // Synchronize data
      await _synchronizeCustomerAttachments(apiResponse, attachmentsBox);
    } catch (e) {
      print(
          'Error synchronizing data from API to Hive for CustomerAttachments: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCustomerAttachmentsData(
      List<String> custCodes) async {
    List<Map<String, dynamic>> customerAttachmentsData = [];
    try {
      // Iterate over each custCode and fetch data for each one
      for (String custCode in custCodes) {
        // Make API call to fetch customer attachments data
        var response = await http.get(
            Uri.parse('${apiurl}getCustomerAttachments?custCode=$custCode'));
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
          print(
              'Failed to retrieve customer attachments data for custCode $custCode: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error fetching customer attachments data: $e');
    }
    return customerAttachmentsData;
  }
Future<void> _synchronizeCustomerAttachments(
  List<Map<String, dynamic>> customerAttachmentsData,
  Box<CustomerAttachments> attachmentsBox,
) async {
  try {
    List<CustomerAttachments> attachmentsToUpdate = [];
    List<String> attachmentsToDelete = [];

    // Prepare attachments to update
    for (var data in customerAttachmentsData) {
      var cmpCode = data['cmpCode'] ?? '';
      var custCode = data['custCode'] ?? '';

      var updatedAttachment = CustomerAttachments(
        cmpCode: cmpCode,
        custCode: custCode,
        attach: data['attach'] ?? '',
        attachType: data['attachType'] ?? '',
        notes: data['notes'] ?? '',
        lineID: data['lineID'] ?? '',
        attachPath: data['attachPath'] ?? '',
        attachFile: data['attachFile'] ?? '',
      );

      attachmentsToUpdate.add(updatedAttachment);
    }

    // Batch update attachments
    await attachmentsBox.putAll(Map.fromIterable(attachmentsToUpdate, key: (attachment) => '${attachment.cmpCode}${attachment.custCode}'));

    // Delete attachments not present in the updated data
    Set<String> updatedAttachmentsKeys = attachmentsToUpdate.map((attachment) => '${attachment.cmpCode}${attachment.custCode}').toSet();
    attachmentsBox.keys.where((attachmentKey) => !updatedAttachmentsKeys.contains(attachmentKey)).forEach((attachmentKey) {
      attachmentsToDelete.add(attachmentKey);
    });
    await attachmentsBox.deleteAll(attachmentsToDelete);
  } catch (e) {
    print('Error synchronizing CustomerAttachments from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
  Future<void> synchronizeCustomerItemsSpecialPrice(
      List<String> custCodes, List<String> itemCodes) async {
    try {
      // Fetch data from API endpoint without filtering by itemCodes in the query
      var apiResponse = await _fetchCustomerItemsSpecialPriceData(custCodes);

      // Filter the results based on itemCodes in Dart code
      var filteredApiResponse = apiResponse
          .where((data) => itemCodes.contains(data['itemCode']))
          .toList();

      // Open Hive box
      var specialPriceBox = await Hive.openBox<CustomerItemsSpecialPrice>(
          'customerItemsSpecialPriceBox');

      // Synchronize data
      await _synchronizeCustomerItemsSpecialPrice(
          filteredApiResponse, specialPriceBox);
    } catch (e) {
      print(
          'Error synchronizing data from API to Hive for CustomerItemsSpecialPrice: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCustomerItemsSpecialPriceData(
      List<String> custCodes) async {
    List<Map<String, dynamic>> customerItemsSpecialPriceData = [];
    try {
      // Iterate over each custCode and fetch data for each one
      for (String custCode in custCodes) {
        // Make API call to fetch customer items special price data
        var response = await http.get(Uri.parse(
            '${apiurl}getCustomerItemsSpecialPrice?custCode=$custCode'));
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
            print(
                'Invalid response format for customer items special price data');
          }
        } else {
          print(
              'Failed to retrieve customer items special price data for custCode $custCode: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error fetching customer items special price data: $e');
    }
    return customerItemsSpecialPriceData;
  }

Future<void> _synchronizeCustomerItemsSpecialPrice(
  List<Map<String, dynamic>> customerItemsSpecialPriceData,
  Box<CustomerItemsSpecialPrice> specialPriceBox,
) async {
  try {
    List<CustomerItemsSpecialPrice> specialPricesToUpdate = [];
    List<String> specialPricesToDelete = [];

    // Prepare special prices to update
    for (var data in customerItemsSpecialPriceData) {
      var cmpCode = data['cmpCode'] ?? '';
      var custCode = data['custCode'] ?? '';
      var itemCode = data['itemCode'] ?? '';
      var uom = data['uom'] ?? '';

      var updatedSpecialPrice = CustomerItemsSpecialPrice(
        cmpCode: cmpCode,
        custCode: custCode,
        itemCode: itemCode,
        uom: uom,
        basePrice: data['basePrice'] ?? '',
        currency: data['currency'] ?? '',
        auto: data['auto'] ?? '',
        disc: data['disc'] ?? '',
        price: data['price'] ?? '',
        notes: data['notes'] ?? '',
      );

      specialPricesToUpdate.add(updatedSpecialPrice);
    }

    // Batch update special prices
    await specialPriceBox.putAll(Map.fromIterable(specialPricesToUpdate, key: (specialPrice) => '${specialPrice.cmpCode}${specialPrice.itemCode}${specialPrice.custCode}${specialPrice.uom}'));

    // Delete special prices not present in the updated data
    Set<String> updatedSpecialPriceKeys = specialPricesToUpdate.map((specialPrice) => '${specialPrice.cmpCode}${specialPrice.itemCode}${specialPrice.custCode}${specialPrice.uom}').toSet();
    specialPriceBox.keys.where((specialPriceKey) => !updatedSpecialPriceKeys.contains(specialPriceKey)).forEach((specialPriceKey) {
      specialPricesToDelete.add(specialPriceKey);
    });
    await specialPriceBox.deleteAll(specialPricesToDelete);
  } catch (e) {
    print('Error synchronizing CustomerItemsSpecialPrice from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
  Future<void> synchronizeCustomerBrandsSpecialPrice(
      List<String> custCodes, List<String> brandCodes) async {
    try {
      // Fetch data from API endpoint without filtering by brandCodes in the query
      var apiResponse = await _fetchCustomerBrandsSpecialPriceData(custCodes);

      // Filter the results based on brandCodes in Dart code
      var filteredApiResponse = apiResponse
          .where((data) => brandCodes.contains(data['brandCode']))
          .toList();

      // Open Hive box
      var brandsSpecialPriceBox =
          await Hive.openBox<CustomerBrandsSpecialPrice>(
              'customerBrandsSpecialPriceBox');

      // Synchronize data
      await _synchronizeCustomerBrandsSpecialPrice(
          filteredApiResponse, brandsSpecialPriceBox);
    } catch (e) {
      print(
          'Error synchronizing data from API to Hive for CustomerBrandsSpecialPrice: $e');
    }
  }

Future<List<Map<String, dynamic>>> _fetchCustomerBrandsSpecialPriceData(List<String> custCodes) async {
  List<Map<String, dynamic>> customerBrandsSpecialPriceData = [];
  try {
    // Iterate over each custCode and fetch data for each one
    for (String custCode in custCodes) {
      // Make API call to fetch customer brands special price data
      var response = await http.get(Uri.parse('${apiurl}getCustomerBrandSpecialPrice?custCode=$custCode'));
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
  Box<CustomerBrandsSpecialPrice> brandsSpecialPriceBox,
) async {
  try {
    // Prepare lists for batch operations
    List<CustomerBrandsSpecialPrice> brandsSpecialPriceToUpdate = [];
    List<String> brandsSpecialPriceToDelete = [];

    // Iterate over the retrieved data
    for (var data in customerBrandsSpecialPriceData) {
      var cmpCode = data['cmpCode'] ?? '';
      var custCode = data['custCode'] ?? '';
      var brandCode = data['brandCode'] ?? '';

      var updatedBrandSpecialPrice = CustomerBrandsSpecialPrice(
        cmpCode: cmpCode,
        custCode: custCode,
        brandCode: brandCode,
        disc: data['disc'] ?? '',
        notes: data['notes'] ?? '',
      );

      brandsSpecialPriceToUpdate.add(updatedBrandSpecialPrice);
    }

    // Batch update brand special prices
    await brandsSpecialPriceBox.putAll(Map.fromIterable(
      brandsSpecialPriceToUpdate,
      key: (brandSpecialPrice) =>
          '${brandSpecialPrice.cmpCode}${brandSpecialPrice.custCode}${brandSpecialPrice.brandCode}',
    ));

    // Delete brand special prices not present in the updated data
    Set<String> updatedBrandSpecialPriceKeys = brandsSpecialPriceToUpdate
        .map((brandSpecialPrice) =>
            '${brandSpecialPrice.cmpCode}${brandSpecialPrice.custCode}${brandSpecialPrice.brandCode}')
        .toSet();
    brandsSpecialPriceBox.keys
        .where((brandSpecialPriceKey) =>
            !updatedBrandSpecialPriceKeys.contains(brandSpecialPriceKey))
        .forEach((brandSpecialPriceKey) {
      brandsSpecialPriceToDelete.add(brandSpecialPriceKey);
    });
    await brandsSpecialPriceBox.deleteAll(brandsSpecialPriceToDelete);
  } catch (e) {
    print('Error synchronizing CustomerBrandsSpecialPrice from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
  Future<void> synchronizeCustomerGroupsSpecialPrice(
      List<String> custCodes, List<String> itemGroupCodes) async {
    try {
      // Fetch data from API endpoint without filtering by itemGroupCodes in the query
      var apiResponse = await _fetchCustomerGroupsSpecialPriceData(custCodes);

      // Filter the results based on itemGroupCodes in Dart code
      var filteredApiResponse = apiResponse
          .where((data) => itemGroupCodes.contains(data['groupCode']))
          .toList();

      // Open Hive box
      var groupsSpecialPriceBox =
          await Hive.openBox<CustomerGroupsSpecialPrice>(
              'customerGroupsSpecialPriceBox');

      // Synchronize data
      await _synchronizeCustomerGroupsSpecialPrice(
          filteredApiResponse, groupsSpecialPriceBox);
    } catch (e) {
      print(
          'Error synchronizing data from API to Hive for CustomerGroupsSpecialPrice: $e');
    }
  }

Future<List<Map<String, dynamic>>> _fetchCustomerGroupsSpecialPriceData(List<String> custCodes) async {
  List<Map<String, dynamic>> customerGroupsSpecialPriceData = [];
  try {
    // Iterate over each custCode and fetch data for each one
    for (String custCode in custCodes) {
      // Make API call to fetch customer groups special price data
      var response = await http.get(Uri.parse('${apiurl}getCustomerGroupSpecialPrice?custCode=$custCode'));
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
  Box<CustomerGroupsSpecialPrice> groupsSpecialPriceBox,
) async {
  try {
    // Prepare lists for batch operations
    List<CustomerGroupsSpecialPrice> groupsSpecialPriceToUpdate = [];
    List<String> groupsSpecialPriceToDelete = [];

    // Iterate over the retrieved data
    for (var data in customerGroupsSpecialPriceData) {
      var cmpCode = data['cmpCode'] ?? '';
      var custCode = data['custCode'] ?? '';
      var groupCode = data['groupCode'] ?? '';

      var updatedGroupSpecialPrice = CustomerGroupsSpecialPrice(
        cmpCode: cmpCode,
        custCode: custCode,
        groupCode: groupCode,
        disc: data['disc'] ?? '',
        notes: data['notes'] ?? '',
      );

      groupsSpecialPriceToUpdate.add(updatedGroupSpecialPrice);
    }

    // Batch update group special prices
    await groupsSpecialPriceBox.putAll(Map.fromIterable(
      groupsSpecialPriceToUpdate,
      key: (groupSpecialPrice) =>
          '${groupSpecialPrice.cmpCode}${groupSpecialPrice.custCode}${groupSpecialPrice.groupCode}',
    ));

    // Delete group special prices not present in the updated data
    Set<String> updatedGroupSpecialPriceKeys = groupsSpecialPriceToUpdate
        .map((groupSpecialPrice) =>
            '${groupSpecialPrice.cmpCode}${groupSpecialPrice.custCode}${groupSpecialPrice.groupCode}')
        .toSet();
    groupsSpecialPriceBox.keys
        .where((groupSpecialPriceKey) =>
            !updatedGroupSpecialPriceKeys.contains(groupSpecialPriceKey))
        .forEach((groupSpecialPriceKey) {
      groupsSpecialPriceToDelete.add(groupSpecialPriceKey);
    });
    await groupsSpecialPriceBox.deleteAll(groupsSpecialPriceToDelete);
  } catch (e) {
    print('Error synchronizing CustomerGroupsSpecialPrice from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
  Future<void> synchronizeCustomerCategSpecialPrice(
      List<String> custCodes, List<String> categCodes) async {
    try {
      // Fetch data from API endpoint without filtering by categCodes in the query
      var apiResponse = await _fetchCustomerCategSpecialPriceData(custCodes);

      // Filter the results based on categCodes in Dart code
      var filteredApiResponse = apiResponse
          .where((data) => categCodes.contains(data['categCode']))
          .toList();

      // Open Hive box
      var categSpecialPriceBox = await Hive.openBox<CustomerCategSpecialPrice>(
          'customerCategSpecialPriceBox');

      // Synchronize data
      await _synchronizeCustomerCategSpecialPrice(
          filteredApiResponse, categSpecialPriceBox);
    } catch (e) {
      print(
          'Error synchronizing data from API to Hive for CustomerCategSpecialPrice: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCustomerCategSpecialPriceData(
      List<String> custCodes) async {
    List<Map<String, dynamic>> customerCategSpecialPriceData = [];
    try {
      // Iterate over each custCode and fetch data for each one
      for (String custCode in custCodes) {
        // Make API call to fetch customer category special price data
        var response = await http.get(Uri.parse(
            '${apiurl}getCustomerCategSpecialPrice?custCode=$custCode'));
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
            print(
                'Invalid response format for customer category special price data');
          }
        } else {
          print(
              'Failed to retrieve customer category special price data for custCode $custCode: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error fetching customer category special price data: $e');
    }
    return customerCategSpecialPriceData;
  }
Future<void> _synchronizeCustomerCategSpecialPrice(
  List<Map<String, dynamic>> customerCategSpecialPriceData,
  Box<CustomerCategSpecialPrice> categSpecialPriceBox,
) async {
  try {
    // Prepare lists for batch operations
    List<CustomerCategSpecialPrice> categSpecialPriceToUpdate = [];
    List<String> categSpecialPriceToDelete = [];

    // Iterate over the retrieved data
    for (var data in customerCategSpecialPriceData) {
      var cmpCode = data['cmpCode'] ?? '';
      var custCode = data['custCode'] ?? '';
      var categCode = data['categCode'] ?? '';

      var updatedCategSpecialPrice = CustomerCategSpecialPrice(
        cmpCode: cmpCode,
        custCode: custCode,
        categCode: categCode,
        disc: data['disc'] ?? '',
        notes: data['notes'] ?? '',
      );

      categSpecialPriceToUpdate.add(updatedCategSpecialPrice);
    }

    // Batch update category special prices
    await categSpecialPriceBox.putAll(Map.fromIterable(
      categSpecialPriceToUpdate,
      key: (categSpecialPrice) =>
          '${categSpecialPrice.cmpCode}${categSpecialPrice.custCode}${categSpecialPrice.categCode}',
    ));

    // Delete category special prices not present in the updated data
    Set<String> updatedCategSpecialPriceKeys = categSpecialPriceToUpdate
        .map((categSpecialPrice) =>
            '${categSpecialPrice.cmpCode}${categSpecialPrice.custCode}${categSpecialPrice.categCode}')
        .toSet();
    categSpecialPriceBox.keys
        .where((categSpecialPriceKey) =>
            !updatedCategSpecialPriceKeys.contains(categSpecialPriceKey))
        .forEach((categSpecialPriceKey) {
      categSpecialPriceToDelete.add(categSpecialPriceKey);
    });
    await categSpecialPriceBox.deleteAll(categSpecialPriceToDelete);
  } catch (e) {
    print(
        'Error synchronizing CustomerCategSpecialPrice from API to Hive: $e');
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
        var response = await http
            .get(Uri.parse('${apiurl}getCustomers?custCode=$custCode'));
        if (response.statusCode == 200) {
          // Parse the response data
          dynamic responseData = jsonDecode(response.body);
          if (responseData is List && responseData.isNotEmpty) {
            // Assuming the API response contains the groupCode
            custGroupCodes.add(responseData[0]['groupCode']);
          }
        } else {
          print(
              'Failed to retrieve custGroupCode for custCode $custCode: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error retrieving custGroupCodes: $e');
    }
    return custGroupCodes;
  }

  Future<void> synchronizeCustomerGroupItemsSpecialPrice(
      List<String> itemCodes, List<String> custGroupCodes) async {
    try {
      // Fetch data from API endpoint
      var apiResponse = await _fetchCustomerGroupItemsSpecialPriceData(
          itemCodes, custGroupCodes);

      // Open Hive box
      var groupItemsSpecialPriceBox =
          await Hive.openBox<CustomerGroupItemsSpecialPrice>(
              'customerGroupItemsSpecialPriceBox');

      // Synchronize data
      await _synchronizeCustomerGroupItemsSpecialPrice(
          apiResponse, groupItemsSpecialPriceBox);
    } catch (e) {
      print(
          'Error synchronizing data from API to Hive for CustomerGroupItemsSpecialPrice: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCustomerGroupItemsSpecialPriceData(
      List<String> itemCodes, List<String> custGroupCodes) async {
    List<Map<String, dynamic>> customerGroupItemsSpecialPriceData = [];
    try {
      for (String itemCode in itemCodes) {
        for (String custGroupCode in custGroupCodes) {
          // Make API call to fetch customer group items special price data
          var response = await http.get(Uri.parse(
              '${apiurl}getCustomerGroupItemsSpecialPrice?itemCode=$itemCode&custGroupCode=$custGroupCode'));
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
              print(
                  'Invalid response format for customer group items special price data');
            }
          } else {
            print(
                'Failed to retrieve customer group items special price data for itemCode $itemCode and custGroupCode $custGroupCode: ${response.statusCode}');
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
  Box<CustomerGroupItemsSpecialPrice> groupItemsSpecialPriceBox,
) async {
  try {
    // Prepare lists for batch operations
    List<CustomerGroupItemsSpecialPrice> groupItemsSpecialPriceToUpdate = [];
    List<String> groupItemsSpecialPriceToDelete = [];

    // Iterate over the retrieved data
    for (var data in customerGroupItemsSpecialPriceData) {
      var cmpCode = data['cmpCode'] ?? '';
      var custGroupCode = data['custGroupCode'] ?? '';
      var itemCode = data['itemCode'] ?? '';
      var uom = data['uom'] ?? '';

      var updatedGroupItemSpecialPrice = CustomerGroupItemsSpecialPrice(
        cmpCode: cmpCode,
        custGroupCode: custGroupCode,
        itemCode: itemCode,
        uom: uom,
        basePrice: data['basePrice'] ?? '',
        currency: data['currency'] ?? '',
        auto: data['auto'] ?? '',
        disc: data['disc'] ?? '',
        price: data['price'] ?? '',
        notes: data['notes'] ?? '',
      );

      groupItemsSpecialPriceToUpdate.add(updatedGroupItemSpecialPrice);
    }

    // Batch update group item special prices
    await groupItemsSpecialPriceBox.putAll(Map.fromIterable(
      groupItemsSpecialPriceToUpdate,
      key: (groupItemSpecialPrice) =>
          '${groupItemSpecialPrice.cmpCode}${groupItemSpecialPrice.custGroupCode}${groupItemSpecialPrice.itemCode}${groupItemSpecialPrice.uom}',
    ));

    // Delete group item special prices not present in the updated data
    Set<String> updatedGroupItemsSpecialPriceKeys =
        groupItemsSpecialPriceToUpdate
            .map((groupItemSpecialPrice) =>
                '${groupItemSpecialPrice.cmpCode}${groupItemSpecialPrice.custGroupCode}${groupItemSpecialPrice.itemCode}${groupItemSpecialPrice.uom}')
            .toSet();
    groupItemsSpecialPriceBox.keys
        .where((groupItemSpecialPriceKey) =>
            !updatedGroupItemsSpecialPriceKeys
                .contains(groupItemSpecialPriceKey))
        .forEach((groupItemSpecialPriceKey) {
      groupItemsSpecialPriceToDelete.add(groupItemSpecialPriceKey);
    });
    await groupItemsSpecialPriceBox.deleteAll(groupItemsSpecialPriceToDelete);
  } catch (e) {
    print(
        'Error synchronizing CustomerGroupItemsSpecialPrice from API to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
  Future<void> synchronizeCustomerGroupBrandSpecialPrice(
      List<String> brandCodes, List<String> custGroupCodes) async {
    try {
      // Fetch data from API endpoint
      var apiResponse = await _fetchCustomerGroupBrandSpecialPriceData(
          brandCodes, custGroupCodes);

      // Open Hive box
      var groupBrandSpecialPriceBox =
          await Hive.openBox<CustomerGroupBrandSpecialPrice>(
              'customerGroupBrandSpecialPriceBox');

      // Synchronize data
      await _synchronizeCustomerGroupBrandSpecialPrice(
          apiResponse, groupBrandSpecialPriceBox);
    } catch (e) {
      print(
          'Error synchronizing data from API to Hive for CustomerGroupBrandSpecialPrice: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCustomerGroupBrandSpecialPriceData(
      List<String> brandCodes, List<String> custGroupCodes) async {
    List<Map<String, dynamic>> customerGroupBrandSpecialPriceData = [];
    try {
      for (String brandCode in brandCodes) {
        for (String custGroupCode in custGroupCodes) {
          // Make API call to fetch customer group brand special price data
          var response = await http.get(Uri.parse(
              '${apiurl}getCustomerGroupBrandSpecialPrice?brandCode=$brandCode&custGroupCode=$custGroupCode'));
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
              print(
                  'Invalid response format for customer group brand special price data');
            }
          } else {
            print(
                'Failed to retrieve customer group brand special price data for brandCode $brandCode and custGroupCode $custGroupCode: ${response.statusCode}');
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
  Box<CustomerGroupBrandSpecialPrice> groupBrandSpecialPriceBox,
) async {
  try {
    // Prepare lists for batch operations
    List<CustomerGroupBrandSpecialPrice> groupBrandSpecialPriceToUpdate = [];
    List<String> groupBrandSpecialPriceToDelete = [];

    // Iterate over the retrieved data
    for (var data in customerGroupBrandSpecialPriceData) {
      var cmpCode = data['cmpCode'] ?? '';
      var custGroupCode = data['custGroupCode'] ?? '';
      var brandCode = data['brandCode'] ?? '';

      var updatedGroupBrandSpecialPrice = CustomerGroupBrandSpecialPrice(
        cmpCode: cmpCode,
        custGroupCode: custGroupCode,
        brandCode: brandCode,
        disc: data['disc'] ?? '',
        notes: data['notes'] ?? '',
      );

      groupBrandSpecialPriceToUpdate.add(updatedGroupBrandSpecialPrice);
    }

    // Batch update group brand special prices
    await groupBrandSpecialPriceBox.putAll(Map.fromIterable(
      groupBrandSpecialPriceToUpdate,
      key: (groupBrandSpecialPrice) =>
          '${groupBrandSpecialPrice.cmpCode}${groupBrandSpecialPrice.custGroupCode}${groupBrandSpecialPrice.brandCode}',
    ));

    // Delete group brand special prices not present in the updated data
    Set<String> updatedGroupBrandSpecialPriceKeys =
        groupBrandSpecialPriceToUpdate
            .map((groupBrandSpecialPrice) =>
                '${groupBrandSpecialPrice.cmpCode}${groupBrandSpecialPrice.custGroupCode}${groupBrandSpecialPrice.brandCode}')
            .toSet();
    groupBrandSpecialPriceBox.keys
        .where((groupBrandSpecialPriceKey) =>
            !updatedGroupBrandSpecialPriceKeys
                .contains(groupBrandSpecialPriceKey))
        .forEach((groupBrandSpecialPriceKey) {
      groupBrandSpecialPriceToDelete.add(groupBrandSpecialPriceKey);
    });
    await groupBrandSpecialPriceBox.deleteAll(groupBrandSpecialPriceToDelete);
  } catch (e) {
    print(
        'Error synchronizing CustomerGroupBrandSpecialPrice from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
  Future<void> synchronizeCustomerGroupGroupSpecialPrice(
      List<String> groupCodes, List<String> custGroupCodes) async {
    try {
      // Fetch data from API endpoint
      var apiResponse = await _fetchCustomerGroupGroupSpecialPriceData(
          groupCodes, custGroupCodes);

      // Open Hive box
      var groupGroupSpecialPriceBox =
          await Hive.openBox<CustomerGroupGroupSpecialPrice>(
              'customerGroupGroupSpecialPriceBox');

      // Synchronize data
      await _synchronizeCustomerGroupGroupSpecialPrice(
          apiResponse, groupGroupSpecialPriceBox);
    } catch (e) {
      print(
          'Error synchronizing data from API to Hive for CustomerGroupGroupSpecialPrice: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCustomerGroupGroupSpecialPriceData(
      List<String> groupCodes, List<String> custGroupCodes) async {
    List<Map<String, dynamic>> customerGroupGroupSpecialPriceData = [];
    try {
      for (String groupCode in groupCodes) {
        for (String custGroupCode in custGroupCodes) {
          // Make API call to fetch customer group group special price data
          var response = await http.get(Uri.parse(
              '${apiurl}getCustomerGroupGroupSpecialPrice?groupCode=$groupCode&custGroupCode=$custGroupCode'));
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
              print(
                  'Invalid response format for customer group group special price data');
            }
          } else {
            print(
                'Failed to retrieve customer group group special price data for groupCode $groupCode and custGroupCode $custGroupCode: ${response.statusCode}');
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
  Box<CustomerGroupGroupSpecialPrice> groupGroupSpecialPriceBox,
) async {
  try {
    // Prepare lists for batch operations
    List<CustomerGroupGroupSpecialPrice> groupGroupSpecialPriceToUpdate = [];
    List<String> groupGroupSpecialPriceToDelete = [];

    // Iterate over the retrieved data
    for (var data in customerGroupGroupSpecialPriceData) {
      var cmpCode = data['cmpCode'] ?? '';
      var custGroupCode = data['custGroupCode'] ?? '';
      var groupCode = data['groupCode'] ?? '';

      var updatedGroupGroupSpecialPrice = CustomerGroupGroupSpecialPrice(
        cmpCode: cmpCode,
        custGroupCode: custGroupCode,
        groupCode: groupCode,
        disc: data['disc'] ?? '',
        notes: data['notes'] ?? '',
      );

      groupGroupSpecialPriceToUpdate.add(updatedGroupGroupSpecialPrice);
    }

    // Batch update group group special prices
    await groupGroupSpecialPriceBox.putAll(Map.fromIterable(
      groupGroupSpecialPriceToUpdate,
      key: (groupGroupSpecialPrice) =>
          '${groupGroupSpecialPrice.cmpCode}${groupGroupSpecialPrice.custGroupCode}${groupGroupSpecialPrice.groupCode}',
    ));

    // Delete group group special prices not present in the updated data
    Set<String> updatedGroupGroupSpecialPriceKeys =
        groupGroupSpecialPriceToUpdate
            .map((groupGroupSpecialPrice) =>
                '${groupGroupSpecialPrice.cmpCode}${groupGroupSpecialPrice.custGroupCode}${groupGroupSpecialPrice.groupCode}')
            .toSet();
    groupGroupSpecialPriceBox.keys
        .where((groupGroupSpecialPriceKey) =>
            !updatedGroupGroupSpecialPriceKeys
                .contains(groupGroupSpecialPriceKey))
        .forEach((groupGroupSpecialPriceKey) {
      groupGroupSpecialPriceToDelete.add(groupGroupSpecialPriceKey);
    });
    await groupGroupSpecialPriceBox.deleteAll(groupGroupSpecialPriceToDelete);
  } catch (e) {
    print(
        'Error synchronizing CustomerGroupGroupSpecialPrice from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

  Future<void> synchronizeCustomerGroupCategSpecialPrice(
      List<String> categCodes, List<String> custGroupCodes) async {
    try {
      // Fetch data from API endpoint
      var apiResponse = await _fetchCustomerGroupCategSpecialPriceData(
          categCodes, custGroupCodes);

      // Open Hive box
      var groupCategSpecialPriceBox =
          await Hive.openBox<CustomerGroupCategSpecialPrice>(
              'customerGroupCategSpecialPriceBox');

      // Synchronize data
      await _synchronizeCustomerGroupCategSpecialPrice(
          apiResponse, groupCategSpecialPriceBox);
    } catch (e) {
      print(
          'Error synchronizing data from API to Hive for CustomerGroupCategSpecialPrice: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCustomerGroupCategSpecialPriceData(
      List<String> categCodes, List<String> custGroupCodes) async {
    List<Map<String, dynamic>> customerGroupCategSpecialPriceData = [];
    try {
      for (String categCode in categCodes) {
        for (String custGroupCode in custGroupCodes) {
          // Make API call to fetch customer group categ special price data
          var response = await http.get(Uri.parse(
              '${apiurl}getCustomerGroupCategSpecialPrice?categCode=$categCode&custGroupCode=$custGroupCode'));
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
              print(
                  'Invalid response format for customer group categ special price data');
            }
          } else {
            print(
                'Failed to retrieve customer group categ special price data for categCode $categCode and custGroupCode $custGroupCode: ${response.statusCode}');
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
  Box<CustomerGroupCategSpecialPrice> groupCategSpecialPriceBox,
) async {
  try {
    // Prepare lists for batch operations
    List<CustomerGroupCategSpecialPrice> groupCategSpecialPriceToUpdate = [];
    List<String> groupCategSpecialPriceToDelete = [];

    // Iterate over the retrieved data
    for (var data in customerGroupCategSpecialPriceData) {
      var cmpCode = data['cmpCode'] ?? '';
      var custGroupCode = data['custGroupCode'] ?? '';
      var categCode = data['categCode'] ?? '';

      var updatedGroupCategSpecialPrice = CustomerGroupCategSpecialPrice(
        cmpCode: cmpCode,
        custGroupCode: custGroupCode,
        categCode: categCode,
        disc: data['disc'] ?? '',
        notes: data['notes'] ?? '',
      );

      groupCategSpecialPriceToUpdate.add(updatedGroupCategSpecialPrice);
    }

    // Batch update group categ special prices
    await groupCategSpecialPriceBox.putAll(Map.fromIterable(
      groupCategSpecialPriceToUpdate,
      key: (groupCategSpecialPrice) =>
          '${groupCategSpecialPrice.cmpCode}${groupCategSpecialPrice.custGroupCode}${groupCategSpecialPrice.categCode}',
    ));

    // Delete group categ special prices not present in the updated data
    Set<String> updatedGroupCategSpecialPriceKeys =
        groupCategSpecialPriceToUpdate
            .map((groupCategSpecialPrice) =>
                '${groupCategSpecialPrice.cmpCode}${groupCategSpecialPrice.custGroupCode}${groupCategSpecialPrice.categCode}')
            .toSet();
    groupCategSpecialPriceBox.keys
        .where((groupCategSpecialPriceKey) =>
            !updatedGroupCategSpecialPriceKeys
                .contains(groupCategSpecialPriceKey))
        .forEach((groupCategSpecialPriceKey) {
      groupCategSpecialPriceToDelete.add(groupCategSpecialPriceKey);
    });
    await groupCategSpecialPriceBox.deleteAll(groupCategSpecialPriceToDelete);
  } catch (e) {
    print(
        'Error synchronizing CustomerGroupCategSpecialPrice from API to Hive: $e');
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
        var response = await http.get(
            Uri.parse('${apiurl}getCustomerProperties?custCode=$custCode'));
        if (response.statusCode == 200) {
          // Parse the response data
          dynamic responseData = jsonDecode(response.body);
          if (responseData is List) {
            for (var item in responseData) {
              if (item is Map<String, dynamic> &&
                  item.containsKey('propCode')) {
                propCodes.add(item['propCode']);
              }
            }
          } else {
            print('Invalid response format for customer properties data');
          }
        } else {
          print(
              'Failed to retrieve customer properties data for custCode $custCode: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error retrieving propCodes: $e');
    }
    return propCodes;
  }

  Future<void> synchronizeCustomerPropItemsSpecialPrice(
      List<String> itemCodes, List<String> custCodes) async {
    List<String> propCodes = await retrievePropCodes(custCodes);

    try {
      // Fetch data from API endpoint
      var apiResponse =
          await _fetchCustomerPropItemsSpecialPriceData(itemCodes, propCodes);

      // Open Hive box
      var propItemsSpecialPriceBox =
          await Hive.openBox<CustomerPropItemsSpecialPrice>(
              'customerPropItemsSpecialPriceBox');

      // Synchronize data
      await _synchronizeCustomerPropItemsSpecialPrice(
          apiResponse, propItemsSpecialPriceBox);

      // Close Hive box if needed
      // await propItemsSpecialPriceBox.close();
    } catch (e) {
      print(
          'Error synchronizing data from API to Hive for CustomerPropItemsSpecialPrice: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCustomerPropItemsSpecialPriceData(
      List<String> itemCodes, List<String> propCodes) async {
    List<Map<String, dynamic>> customerPropItemsSpecialPriceData = [];
    try {
      for (String itemCode in itemCodes) {
        for (String propCode in propCodes) {
          // Make API call to fetch customer prop items special price data
          var response = await http.get(Uri.parse(
              '${apiurl}getCustomerPropItemsSpecialPrice?itemCode=$itemCode&propCode=$propCode'));
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
              print(
                  'Invalid response format for customer prop items special price data');
            }
          } else {
            print(
                'Failed to retrieve customer prop items special price data for itemCode $itemCode and propCode $propCode: ${response.statusCode}');
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
  Box<CustomerPropItemsSpecialPrice> propItemsSpecialPriceBox,
) async {
  try {
    // Prepare lists for batch operations
    List<CustomerPropItemsSpecialPrice> propItemsSpecialPriceToUpdate = [];
    List<String> propItemsSpecialPriceToDelete = [];

    // Iterate over the retrieved data
    for (var data in customerPropItemsSpecialPriceData) {
      var cmpCode = data['cmpCode'] ?? '';
      var custPropCode = data['custPropCode'] ?? '';
      var itemCode = data['itemCode'] ?? '';
      var uom = data['uom'] ?? '';

      var updatedPropItemsSpecialPrice = CustomerPropItemsSpecialPrice(
        cmpCode: cmpCode,
        custPropCode: custPropCode,
        itemCode: itemCode,
        uom: uom,
        basePrice: data['basePrice'] ?? '',
        currency: data['currency'] ?? '',
        auto: data['auto'] ?? '',
        disc: data['disc'] ?? '',
        price: data['price'] ?? '',
        notes: data['notes'] ?? '',
      );

      propItemsSpecialPriceToUpdate.add(updatedPropItemsSpecialPrice);
    }

    // Batch update prop items special prices
    await propItemsSpecialPriceBox.putAll(Map.fromIterable(
      propItemsSpecialPriceToUpdate,
      key: (propItemsSpecialPrice) =>
          '${propItemsSpecialPrice.cmpCode}${propItemsSpecialPrice.custPropCode}${propItemsSpecialPrice.itemCode}${propItemsSpecialPrice.uom}',
    ));

    // Delete prop items special prices not present in the updated data
    Set<String> updatedPropItemsSpecialPriceKeys =
        propItemsSpecialPriceToUpdate
            .map((propItemsSpecialPrice) =>
                '${propItemsSpecialPrice.cmpCode}${propItemsSpecialPrice.custPropCode}${propItemsSpecialPrice.itemCode}${propItemsSpecialPrice.uom}')
            .toSet();
    propItemsSpecialPriceBox.keys
        .where((propItemsSpecialPriceKey) =>
            !updatedPropItemsSpecialPriceKeys
                .contains(propItemsSpecialPriceKey))
        .forEach((propItemsSpecialPriceKey) {
      propItemsSpecialPriceToDelete.add(propItemsSpecialPriceKey);
    });
    await propItemsSpecialPriceBox.deleteAll(propItemsSpecialPriceToDelete);
  } catch (e) {
    print(
        'Error synchronizing CustomerPropItemsSpecialPrice from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
  Future<void> synchronizeCustomerPropBrandSpecialPrice(
      List<String> brandCodes, List<String> custCodes) async {
    List<String> propCodes = await retrievePropCodes(custCodes);

    try {
      // Fetch data from API endpoint
      var apiResponse =
          await _fetchCustomerPropBrandSpecialPriceData(brandCodes, propCodes);

      // Open Hive box
      var propBrandSpecialPriceBox =
          await Hive.openBox<CustomerPropBrandSpecialPrice>(
              'customerPropBrandSpecialPriceBox');

      // Synchronize data
      await _synchronizeCustomerPropBrandSpecialPrice(
          apiResponse, propBrandSpecialPriceBox);

      // Close Hive box if needed
      // await propBrandSpecialPriceBox.close();
    } catch (e) {
      print(
          'Error synchronizing data from API to Hive for CustomerPropBrandSpecialPrice: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCustomerPropBrandSpecialPriceData(
      List<String> brandCodes, List<String> propCodes) async {
    List<Map<String, dynamic>> customerPropBrandSpecialPriceData = [];
    try {
      for (String brandCode in brandCodes) {
        for (String propCode in propCodes) {
          // Make API call to fetch customer prop brand special price data
          var response = await http.get(Uri.parse(
              '${apiurl}getCustomerPropBrandSpecialPrice?brandCode=$brandCode&propCode=$propCode'));
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
              print(
                  'Invalid response format for customer prop brand special price data');
            }
          } else {
            print(
                'Failed to retrieve customer prop brand special price data for brandCode $brandCode and propCode $propCode: ${response.statusCode}');
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
  Box<CustomerPropBrandSpecialPrice> propBrandSpecialPriceBox,
) async {
  try {
    // Prepare lists for batch operations
    List<CustomerPropBrandSpecialPrice> propBrandSpecialPriceToUpdate = [];
    List<String> propBrandSpecialPriceToDelete = [];

    // Iterate over the retrieved data
    for (var data in customerPropBrandSpecialPriceData) {
      var cmpCode = data['cmpCode'] ?? '';
      var custPropCode = data['custPropCode'] ?? '';
      var brandCode = data['brandCode'] ?? '';

      var updatedPropBrandSpecialPrice = CustomerPropBrandSpecialPrice(
        cmpCode: cmpCode,
        custPropCode: custPropCode,
        brandCode: brandCode,
        disc: data['disc'] ?? '',
        notes: data['notes'] ?? '',
      );

      propBrandSpecialPriceToUpdate.add(updatedPropBrandSpecialPrice);
    }

    // Batch update prop brand special prices
    await propBrandSpecialPriceBox.putAll(Map.fromIterable(
      propBrandSpecialPriceToUpdate,
      key: (propBrandSpecialPrice) =>
          '${propBrandSpecialPrice.cmpCode}${propBrandSpecialPrice.custPropCode}${propBrandSpecialPrice.brandCode}',
    ));

    // Delete prop brand special prices not present in the updated data
    Set<String> updatedPropBrandSpecialPriceKeys =
        propBrandSpecialPriceToUpdate
            .map((propBrandSpecialPrice) =>
                '${propBrandSpecialPrice.cmpCode}${propBrandSpecialPrice.custPropCode}${propBrandSpecialPrice.brandCode}')
            .toSet();
    propBrandSpecialPriceBox.keys
        .where((propBrandSpecialPriceKey) =>
            !updatedPropBrandSpecialPriceKeys
                .contains(propBrandSpecialPriceKey))
        .forEach((propBrandSpecialPriceKey) {
      propBrandSpecialPriceToDelete.add(propBrandSpecialPriceKey);
    });
    await propBrandSpecialPriceBox.deleteAll(propBrandSpecialPriceToDelete);
  } catch (e) {
    print(
        'Error synchronizing CustomerPropBrandSpecialPrice from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

  Future<void> synchronizeCustomerPropGroupSpecialPrice(
      List<String> custGroupCodes, List<String> custCodes) async {
    List<String> propCodes = await retrievePropCodes(custCodes);

    try {
      // Fetch data from API endpoint
      var apiResponse = await _fetchCustomerPropGroupSpecialPriceData(
          propCodes, custGroupCodes);

      // Open Hive box
      var propGroupSpecialPriceBox =
          await Hive.openBox<CustomerPropGroupSpecialPrice>(
              'customerPropGroupSpecialPriceBox');

      // Synchronize data
      await _synchronizeCustomerPropGroupSpecialPrice(
          apiResponse, propGroupSpecialPriceBox);

      // Close Hive box if needed
      // await propGroupSpecialPriceBox.close();
    } catch (e) {
      print(
          'Error synchronizing data from API to Hive for CustomerPropGroupSpecialPrice: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCustomerPropGroupSpecialPriceData(
      List<String> propCodes, List<String> custGroupCodes) async {
    List<Map<String, dynamic>> customerPropGroupSpecialPriceData = [];
    try {
      for (String propCode in propCodes) {
        for (String custGroupCode in custGroupCodes) {
          // Make API call to fetch customer prop group special price data
          var response = await http.get(Uri.parse(
              '${apiurl}getCustomerPropGroupSpecialPrice?propCode=$propCode&custGroupCode=$custGroupCode'));
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
              print(
                  'Invalid response format for customer prop group special price data');
            }
          } else {
            print(
                'Failed to retrieve customer prop group special price data for propCode $propCode and custGroupCode $custGroupCode: ${response.statusCode}');
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
  Box<CustomerPropGroupSpecialPrice> propGroupSpecialPriceBox,
) async {
  try {
    // Prepare lists for batch operations
    List<CustomerPropGroupSpecialPrice> propGroupSpecialPriceToUpdate = [];
    List<String> propGroupSpecialPriceToDelete = [];

    // Iterate over the retrieved data
    for (var data in customerPropGroupSpecialPriceData) {
      var cmpCode = data['cmpCode'] ?? '';
      var custGroupCode = data['custGroupCode'] ?? '';
      var propCode = data['propCode'] ?? '';

      var updatedPropGroupSpecialPrice = CustomerPropGroupSpecialPrice(
        cmpCode: cmpCode,
        custGroupCode: custGroupCode,
        propCode: propCode,
        disc: data['disc'] ?? '',
        notes: data['notes'] ?? '',
      );

      propGroupSpecialPriceToUpdate.add(updatedPropGroupSpecialPrice);
    }

    // Batch update prop group special prices
    await propGroupSpecialPriceBox.putAll(Map.fromIterable(
      propGroupSpecialPriceToUpdate,
      key: (propGroupSpecialPrice) =>
          '${propGroupSpecialPrice.cmpCode}${propGroupSpecialPrice.custGroupCode}${propGroupSpecialPrice.propCode}',
    ));

    // Delete prop group special prices not present in the updated data
    Set<String> updatedPropGroupSpecialPriceKeys =
        propGroupSpecialPriceToUpdate
            .map((propGroupSpecialPrice) =>
                '${propGroupSpecialPrice.cmpCode}${propGroupSpecialPrice.custGroupCode}${propGroupSpecialPrice.propCode}')
            .toSet();
    propGroupSpecialPriceBox.keys
        .where((propGroupSpecialPriceKey) =>
            !updatedPropGroupSpecialPriceKeys
                .contains(propGroupSpecialPriceKey))
        .forEach((propGroupSpecialPriceKey) {
      propGroupSpecialPriceToDelete.add(propGroupSpecialPriceKey);
    });
    await propGroupSpecialPriceBox.deleteAll(propGroupSpecialPriceToDelete);
  } catch (e) {
    print(
        'Error synchronizing CustomerPropGroupSpecialPrice from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
  Future<void> synchronizeCustomerPropCategSpecialPrice(
      List<String> categCodes, List<String> custCodes) async {
    List<String> propCodes = await retrievePropCodes(custCodes);

    try {
      // Fetch data from API endpoint
      var apiResponse =
          await _fetchCustomerPropCategSpecialPriceData(propCodes, categCodes);

      // Open Hive box
      var propCategSpecialPriceBox =
          await Hive.openBox<CustomerPropCategSpecialPrice>(
              'customerPropCategSpecialPriceBox');

      // Synchronize data
      await _synchronizeCustomerPropCategSpecialPrice(
          apiResponse, propCategSpecialPriceBox);

      // Close Hive box if needed
      // await propCategSpecialPriceBox.close();
    } catch (e) {
      print(
          'Error synchronizing data from API to Hive for CustomerPropCategSpecialPrice: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCustomerPropCategSpecialPriceData(
      List<String> propCodes, List<String> categCodes) async {
    List<Map<String, dynamic>> customerPropCategSpecialPriceData = [];
    try {
      for (String propCode in propCodes) {
        for (String categCode in categCodes) {
          // Make API call to fetch customer prop categ special price data
          var response = await http.get(Uri.parse(
              '${apiurl}getCustomerPropCategSpecialPrice?propCode=$propCode&categCode=$categCode'));
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
              print(
                  'Invalid response format for customer prop categ special price data');
            }
          } else {
            print(
                'Failed to retrieve customer prop categ special price data for propCode $propCode and categCode $categCode: ${response.statusCode}');
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
  Box<CustomerPropCategSpecialPrice> propCategSpecialPriceBox,
) async {
  try {
    // Prepare lists for batch operations
    List<CustomerPropCategSpecialPrice> propCategSpecialPriceToUpdate = [];
    List<String> propCategSpecialPriceToDelete = [];

    // Iterate over the retrieved data
    for (var data in customerPropCategSpecialPriceData) {
      var cmpCode = data['cmpCode'] ?? '';
      var custPropCode = data['custPropCode'] ?? '';
      var categCode = data['categCode'] ?? '';

      var updatedPropCategSpecialPrice = CustomerPropCategSpecialPrice(
        cmpCode: cmpCode,
        custPropCode: custPropCode,
        categCode: categCode,
        disc: data['disc'] ?? '',
        notes: data['notes'] ?? '',
      );

      propCategSpecialPriceToUpdate.add(updatedPropCategSpecialPrice);
    }

    // Batch update prop categ special prices
    await propCategSpecialPriceBox.putAll(Map.fromIterable(
      propCategSpecialPriceToUpdate,
      key: (propCategSpecialPrice) =>
          '${propCategSpecialPrice.cmpCode}${propCategSpecialPrice.custPropCode}${propCategSpecialPrice.categCode}',
    ));

    // Delete prop categ special prices not present in the updated data
    Set<String> updatedPropCategSpecialPriceKeys =
        propCategSpecialPriceToUpdate
            .map((propCategSpecialPrice) =>
                '${propCategSpecialPrice.cmpCode}${propCategSpecialPrice.custPropCode}${propCategSpecialPrice.categCode}')
            .toSet();
    propCategSpecialPriceBox.keys
        .where((propCategSpecialPriceKey) =>
            !updatedPropCategSpecialPriceKeys
                .contains(propCategSpecialPriceKey))
        .forEach((propCategSpecialPriceKey) {
      propCategSpecialPriceToDelete.add(propCategSpecialPriceKey);
    });
    await propCategSpecialPriceBox.deleteAll(propCategSpecialPriceToDelete);
  } catch (e) {
    print(
        'Error synchronizing CustomerPropCategSpecialPrice from API to Hive: $e');
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
        print(
            'Failed to retrieve price list authorization data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching price list authorization data: $e');
    }
    return priceListAuthoData;
  }

  Future<void> synchronizeDataPriceListsAutho() async {
    try {
      // Fetch data from the API endpoint
      List<Map<String, dynamic>> priceListAuthoData =
          await _fetchPriceListAuthoData();

      // Open Hive box
      var pricelistsauthoBox = await Hive.openBox<PriceListAuthorization>(
          'pricelistAuthorizationBox');

      // Synchronize data
      await _synchronizePriceListAutho(priceListAuthoData, pricelistsauthoBox);

    // Close Hive box
    //await pricelistsauthoBox.close();
  } catch (e) {
    print('Error synchronizing data from API to Hive for price list authorizations: $e');
  }
}
Future<void> _synchronizePriceListAutho(
  List<Map<String, dynamic>> priceListAuthoData,
  Box<PriceListAuthorization> priceListAuthoBox,
) async {
  try {
    // Prepare lists for batch operations
    List<PriceListAuthorization> priceListAuthoToUpdate = [];
    List<String> priceListAuthoToDelete = [];

    // Iterate over the retrieved data
    for (var data in priceListAuthoData) {
      var userCode = data['userCode'] as String ?? '';
      var cmpCode = data['cmpCode'] as String ?? '';
      var authoGroup = data['authoGroup'] as String ?? '';

      // Check if any of the required keys are missing or null
      if (userCode.isNotEmpty && cmpCode.isNotEmpty && authoGroup.isNotEmpty) {
        var key = '$userCode$cmpCode$authoGroup';
        
        var updatedPriceListAutho = PriceListAuthorization(
          userCode: userCode,
          cmpCode: cmpCode,
          authoGroup: authoGroup,
        );

        priceListAuthoToUpdate.add(updatedPriceListAutho);
      } else {
        // Print a message if any of the required keys are missing or null
        print(
          'One or more required keys (userCode, cmpCode, authoGroup) are missing or empty in the data map: $data',
        );
      }
    }

    // Batch update price list authorizations
    await priceListAuthoBox.putAll(Map.fromIterable(
      priceListAuthoToUpdate,
      key: (priceListAutho) =>
          '${priceListAutho.userCode}${priceListAutho.cmpCode}${priceListAutho.authoGroup}',
    ));

    // Delete price list authorizations not present in the updated data
    Set<String> updatedPriceListAuthoKeys = priceListAuthoToUpdate
        .map((priceListAutho) =>
            '${priceListAutho.userCode}${priceListAutho.cmpCode}${priceListAutho.authoGroup}')
        .toSet();
    priceListAuthoBox.keys
        .where((priceListAuthoKey) =>
            !updatedPriceListAuthoKeys.contains(priceListAuthoKey))
        .forEach((priceListAuthoKey) {
      priceListAuthoToDelete.add(priceListAuthoKey);
    });
    await priceListAuthoBox.deleteAll(priceListAuthoToDelete);
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
      var companiesConnectionBox =
          await Hive.openBox<CompaniesConnection>('companiesConnectionBox');

      // Synchronize data
      await _synchronizeCompaniesConnection(
          apiResponse, companiesConnectionBox);

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
      var response =
          await http.get(Uri.parse('${apiurl}getCompaniesConnections'));
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
        print(
            'Failed to retrieve companies connection data: ${response.statusCode}');
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
    // Prepare lists for batch operations
    List<CompaniesConnection> companiesConnectionToUpdate = [];
    List<String> companiesConnectionToDelete = [];

    // Iterate over the retrieved data
    for (var data in companiesConnectionData) {
      var connectionID = data['connectionID'] ?? '';
      var updatedCompaniesConnection = CompaniesConnection(
        connectionID: connectionID,
        connDatabase: data['connDatabase'] ?? '',
        connServer: data['connServer'] ?? '',
        connUser: data['connUser'] ?? '',
        connPassword: data['connPassword'] ?? '',
        connPort: data['connPort'] ?? '',
        typeDatabase: data['typeDatabase'] ?? '',
      );

      companiesConnectionToUpdate.add(updatedCompaniesConnection);
    }

    // Batch update companies connections
    await companiesConnectionBox.putAll(Map.fromIterable(
      companiesConnectionToUpdate,
      key: (companiesConnection) => companiesConnection.connectionID,
    ));

    // Delete companies connections not present in the updated data
    Set<String> updatedCompaniesConnectionsKeys = companiesConnectionToUpdate
        .map((companiesConnection) => companiesConnection.connectionID)
        .toSet();
    companiesConnectionBox.keys
        .where((companiesConnectionKey) =>
            !updatedCompaniesConnectionsKeys.contains(companiesConnectionKey))
        .forEach((companiesConnectionKey) {
      companiesConnectionToDelete.add(companiesConnectionKey);
    });
    await companiesConnectionBox.deleteAll(companiesConnectionToDelete);
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
      var companiesUsersBox =
          await Hive.openBox<CompaniesUsers>('companiesUsersBox');

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
        print(
            'Failed to retrieve companies users data: ${response.statusCode}');
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
    // Prepare lists for batch operations
    List<CompaniesUsers> companiesUsersToUpdate = [];
    List<String> companiesUsersToDelete = [];

    // Iterate over the retrieved data
    for (var data in companiesUsersData) {
      var userCode = data['userCode'] ?? '';
      var cmpCode = data['cmpCode'] ?? '';
      var defaultcmpCode = data['defaultcmpCode'] ?? '';

      var updatedCompaniesUser = CompaniesUsers(
        userCode: userCode,
        cmpCode: cmpCode,
        defaultcmpCode: defaultcmpCode,
      );

      companiesUsersToUpdate.add(updatedCompaniesUser);
    }

    // Batch update companies users
    await companiesUsersBox.putAll(Map.fromIterable(
      companiesUsersToUpdate,
      key: (companiesUser) => '${companiesUser.userCode}${companiesUser.cmpCode}',
    ));

    // Delete companies users not present in the updated data
    Set<String> updatedCompaniesUsersKeys = companiesUsersToUpdate
        .map((companiesUser) => '${companiesUser.userCode}${companiesUser.cmpCode}')
        .toSet();
    companiesUsersBox.keys
        .where((companiesUserKey) => !updatedCompaniesUsersKeys.contains(companiesUserKey))
        .forEach((companiesUserKey) {
      companiesUsersToDelete.add(companiesUserKey);
    });
    await companiesUsersBox.deleteAll(companiesUsersToDelete);
  } catch (e) {
    print('Error synchronizing Companies Users data from API to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------


Future<List<Map<String, dynamic>>> _fetchCountriesData() async {
  List<Map<String, dynamic>> countriesData = [];
  try {
    // Perform HTTP GET request to fetch departments data from the API endpoint
    final response = await http.get(Uri.parse('${apiurl}getCountries'));
    if (response.statusCode == 200) {
      dynamic responseData = jsonDecode(response.body);
      if (responseData is List) {
        // If the response is a list, append each department data to the departmentsData list
        for (var countryData in responseData) {
          if (countryData is Map<String, dynamic>) {
            countriesData.add(countryData);
          }
        }
      } else {
        print('Invalid response format for countries data');
      }
    } else {
      print('Failed to retrieve countries data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching countries data: $e');
  }
  return countriesData;
}

Future<void> synchronizeCountries() async {
  try {
    // Fetch data from API endpoint
    List<Map<String, dynamic>> apiResponse = await _fetchCountriesData();

    // Open Hive box
    var countriesBox = await Hive.openBox<Countries>('countriesBox');

    // Synchronize data
    await _synchronizeCountries(apiResponse, countriesBox);

    // Close Hive box
    // await departmentsBox.close();
  } catch (e) {
    print('Error synchronizing data from API to Hive for Countries: $e');
  }
}

Future<void> _synchronizeCountries(
  List<Map<String, dynamic>> countriesData,
  Box<Countries> countriesBox,
) async {
  try {
    // Prepare lists for batch operations
    List<Countries> countriesToUpdate = [];
    List<String> countriesToDelete = [];

    // Iterate over the retrieved data
    for (var data in countriesData) {
      var cmpCode = data['cmpCode'] ?? '';
      var countryCode = data['countryCode'] ?? '';
      var countryName = data['countryName'] ?? '';
      var countryFName = data['countryFName'] ?? '';
      var addrFormatID = data['addrFormatID'] ?? '';
      var notes = data['notes'] ?? '';

      var updatedCountry = Countries(
        cmpCode: cmpCode,
        countryCode: countryCode,
        countryName: countryName,
        countryFName: countryFName,
        addrFormatID: addrFormatID,
        notes: notes,
      );

      countriesToUpdate.add(updatedCountry);
    }

    // Batch update countries
    await countriesBox.putAll(Map.fromIterable(
      countriesToUpdate,
      key: (country) => '${country.cmpCode}${country.countryCode}',
    ));

    // Delete countries not present in the updated data
    Set<String> updatedCountryKeys = countriesToUpdate
        .map((country) => '${country.cmpCode}${country.countryCode}')
        .toSet();
    countriesBox.keys
        .where((countryKey) => !updatedCountryKeys.contains(countryKey))
        .forEach((countryKey) {
      countriesToDelete.add(countryKey);
    });
    await countriesBox.deleteAll(countriesToDelete);
  } catch (e) {
    print('Error synchronizing countries from API to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------


Future<List<Map<String, dynamic>>> _fetchItemManufacturers() async {
  List<Map<String, dynamic>> itemmanuData = [];
  try {
    // Perform HTTP GET request to fetch departments data from the API endpoint
    final response = await http.get(Uri.parse('${apiurl}getItemManufacturers'));
    if (response.statusCode == 200) {
      dynamic responseData = jsonDecode(response.body);
      if (responseData is List) {
        // If the response is a list, append each department data to the departmentsData list
        for (var manuData in responseData) {
          if (manuData is Map<String, dynamic>) {
            itemmanuData.add(manuData);
          }
        }
      } else {
        print('Invalid response format for item manu data');
      }
    } else {
      print('Failed to retrieve item manu data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching item manu data: $e');
  }
  return itemmanuData;
}

Future<void> synchronizeItemManu() async {
  try {
    // Fetch data from API endpoint
    List<Map<String, dynamic>> apiResponse = await _fetchItemManufacturers();

    // Open Hive box
    var itemManuBox = await Hive.openBox<ItemManufacturers>('itemManufacturersBox');

    // Synchronize data
    await _synchronizeItemManu(apiResponse, itemManuBox);

    // Close Hive box
    // await departmentsBox.close();
  } catch (e) {
    print('Error synchronizing data from API to Hive for Item Manu: $e');
  }
}

Future<void> _synchronizeItemManu(
  List<Map<String, dynamic>> itemManuData,
  Box<ItemManufacturers> itemmanuBox,
) async {
  try {
    // Prepare lists for batch operations
    List<ItemManufacturers> itemManufacturersToUpdate = [];
    List<String> itemManufacturersToDelete = [];

    // Iterate over the retrieved data
    for (var data in itemManuData) {
      var cmpCode = data['cmpCode'] ?? '';
      var manufCode = data['manufCode'] ?? '';
      var manufName = data['manufName'] ?? '';
      var manufFName = data['manufFname'] ?? '';
      var notes = data['notes'] ?? '';

      var updatedItemManu = ItemManufacturers(
        cmpCode: cmpCode,
        manufCode: manufCode,
        manufName: manufName,
        manufFName: manufFName,
        notes: notes,
      );

      itemManufacturersToUpdate.add(updatedItemManu);
    }

    // Batch update item manufacturers
    await itemmanuBox.putAll(Map.fromIterable(
      itemManufacturersToUpdate,
      key: (itemManu) => '${itemManu.cmpCode}${itemManu.manufCode}',
    ));

    // Delete item manufacturers not present in the updated data
    Set<String> updatedItemManuKeys = itemManufacturersToUpdate
        .map((itemManu) => '${itemManu.cmpCode}${itemManu.manufCode}')
        .toSet();
    itemmanuBox.keys
        .where((itemManuKey) => !updatedItemManuKeys.contains(itemManuKey))
        .forEach((itemManuKey) {
      itemManufacturersToDelete.add(itemManuKey);
    });
    await itemmanuBox.deleteAll(itemManufacturersToDelete);
  } catch (e) {
    print('Error synchronizing item manu from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------


Future<List<Map<String, dynamic>>> _fetchItemBarcode(List<String> itemCodes) async {
  List<Map<String, dynamic>> itembarcodeData = [];
  try {
    // Perform HTTP GET request to fetch departments data from the API endpoint
        for (String itemCode in itemCodes) {
    final response = await http.get(Uri.parse('${apiurl}getItemBarCode?itemCode=$itemCode'));
    if (response.statusCode == 200) {
      dynamic responseData = jsonDecode(response.body);
      if (responseData is List) {
        // If the response is a list, append each department data to the departmentsData list
        for (var barcodeData in responseData) {
          if (barcodeData is Map<String, dynamic>) {
            itembarcodeData.add(barcodeData);
          }
        }
      }
      else if (responseData is Map<String, dynamic>) {
          // If the response is a map, directly append it to the itemUOMData list
          itembarcodeData.add(responseData);
        } else {
          print('Invalid response format for item barcode $itemCode');
        }
      } else {
        print('Failed to retrieve item UOM for item barcode $itemCode: ${response.statusCode}');
      }
        }
  } catch (e) {
    print('Error fetching item barcode  data: $e');
  }
  return itembarcodeData;
}

Future<void> synchronizeItemBarcode(List<String> itemCodes) async {
  try {
    // Fetch data from API endpoint
    List<Map<String, dynamic>> apiResponse = await _fetchItemBarcode(itemCodes);

    // Open Hive box
    var itemBarcodeBox = await Hive.openBox<ItemBarcode>('itemBarcodeBox');

    // Synchronize data
    await _synchronizeItemBarcode(apiResponse, itemBarcodeBox);

    // Close Hive box
    // await departmentsBox.close();
  } catch (e) {
    print('Error synchronizing data from API to Hive for Item Manu: $e');
  }
}

Future<void> _synchronizeItemBarcode(
  List<Map<String, dynamic>> itemBarcodeData,
  Box<ItemBarcode> itembarcodeBox,
) async {
  try {
    // Prepare lists for batch operations
    List<ItemBarcode> itemBarcodesToUpdate = [];
    List<String> itemBarcodesToDelete = [];

    // Iterate over the retrieved data
    for (var data in itemBarcodeData) {
      var cmpCode = data['cmpCode'] ?? '';
      var itemCode = data['itemCode'] ?? '';
      var uomCode = data['uomCode'] ?? '';
      var barcode = data['barcode'] ?? '';
      var notes = data['notes'] ?? '';

      var updatedItemBarcode = ItemBarcode(
        cmpCode: cmpCode,
        itemCode: itemCode,
        uomCode: uomCode,
        barcode: barcode,
        notes: notes,
      );

      itemBarcodesToUpdate.add(updatedItemBarcode);
    }

    // Batch update item barcodes
    await itembarcodeBox.putAll(Map.fromIterable(
      itemBarcodesToUpdate,
      key: (itemBarcode) =>
          '${itemBarcode.cmpCode}${itemBarcode.itemCode}${itemBarcode.uomCode}',
    ));

    // Delete item barcodes not present in the updated data
    Set<String> updatedItemBarcodeKeys = itemBarcodesToUpdate
        .map((itemBarcode) =>
            '${itemBarcode.cmpCode}${itemBarcode.itemCode}${itemBarcode.uomCode}')
        .toSet();
    itembarcodeBox.keys
        .where((itemBarcodeKey) => !updatedItemBarcodeKeys.contains(itemBarcodeKey))
        .forEach((itemBarcodeKey) {
      itemBarcodesToDelete.add(itemBarcodeKey);
    });
    await itembarcodeBox.deleteAll(itemBarcodesToDelete);
  } catch (e) {
    print('Error synchronizing item barcode from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<List<Map<String, dynamic>>> _fetchItemProps(List<String>itemCodes, List<String>propCodes) async {
  List<Map<String, dynamic>> itemPropsData = [];
  try {
    // Perform HTTP GET request to fetch item properties data from the API endpoint
        for (String itemCode in itemCodes) {
      for (String propCode in propCodes) {
    final response = await http.get(Uri.parse('${apiurl}getItemProps?itemCode=$itemCode&propCode=$propCode'));
    if (response.statusCode == 200) {
      dynamic responseData = jsonDecode(response.body);
      if (responseData is List) {
        // If the response is a list, append each item property data to the itemPropsData list
        for (var propData in responseData) {
          if (propData is Map<String, dynamic>) {
            itemPropsData.add(propData);
          }
        }
      } else {
        print('Invalid response format for item prop data');
      }
    } else {
      print('Failed to retrieve item prop data: ${response.statusCode}');
    }
      }}
  } catch (e) {
    print('Error fetching item prop data: $e');
  }
  return itemPropsData;
}

Future<void> synchronizeItemProps(List<String> itemCodes,List<String>propCodes) async {
  try {
    // Fetch data from API endpoint
    List<Map<String, dynamic>> apiResponse = await _fetchItemProps(itemCodes,propCodes);

    // Open Hive box
    var itemPropsBox = await Hive.openBox<ItemProp>('itemPropBox');

    // Synchronize data
    await _synchronizeItemProps(apiResponse, itemPropsBox);

    // Close Hive box
    // await itemPropsBox.close();
  } catch (e) {
    print('Error synchronizing data from API to Hive for Item Props: $e');
  }
}

Future<void> _synchronizeItemProps(
  List<Map<String, dynamic>> itemPropsData,
  Box<ItemProp> itemPropsBox,
) async {
  try {
    // Prepare lists for batch operations
    List<ItemProp> itemPropsToUpdate = [];
    List<String> itemPropsToDelete = [];

    // Iterate over the retrieved data
    for (var data in itemPropsData) {
      var cmpCode = data['cmpCode'] ?? '';
      var itemCode = data['itemCode'] ?? '';
      var propCode = data['propCode'] ?? '';
      var notes = data['notes'] ?? '';

      var updatedItemProp = ItemProp(
        cmpCode: cmpCode,
        itemCode: itemCode,
        propCode: propCode,
        notes: notes,
      );

      itemPropsToUpdate.add(updatedItemProp);
    }

    // Batch update item properties
    await itemPropsBox.putAll(Map.fromIterable(
      itemPropsToUpdate,
      key: (itemProp) =>
          '${itemProp.cmpCode}${itemProp.itemCode}${itemProp.propCode}',
    ));

    // Delete item properties not present in the updated data
    Set<String> updatedItemPropKeys = itemPropsToUpdate
        .map((itemProp) =>
            '${itemProp.cmpCode}${itemProp.itemCode}${itemProp.propCode}')
        .toSet();
    itemPropsBox.keys
        .where((itemPropKey) => !updatedItemPropKeys.contains(itemPropKey))
        .forEach((itemPropKey) {
      itemPropsToDelete.add(itemPropKey);
    });
    await itemPropsBox.deleteAll(itemPropsToDelete);
  } catch (e) {
    print('Error synchronizing item properties from API to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<List<Map<String, dynamic>>> _fetchAddressFormats() async {
  List<Map<String, dynamic>> addressFormatsData = [];
  try {
    // Perform HTTP GET request to fetch address formats data from the API endpoint
    final response = await http.get(Uri.parse('${apiurl}getAddressFormats'));
    if (response.statusCode == 200) {
      dynamic responseData = jsonDecode(response.body);
      if (responseData is List) {
        // If the response is a list, append each address format data to the addressFormatsData list
        for (var formatData in responseData) {
          if (formatData is Map<String, dynamic>) {
            addressFormatsData.add(formatData);
          }
        }
      } else {
        print('Invalid response format for address formats data');
      }
    } else {
      print('Failed to retrieve address formats data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching address formats data: $e');
  }
  return addressFormatsData;
}

Future<void> synchronizeAddressFormats() async {
  try {
    // Fetch data from API endpoint
    List<Map<String, dynamic>> apiResponse = await _fetchAddressFormats();

    // Open Hive box
    var addressFormatsBox = await Hive.openBox<AddressFormat>('addressFormatBox');

    // Synchronize data
    await _synchronizeAddressFormats(apiResponse, addressFormatsBox);

    // Close Hive box
    // await addressFormatsBox.close();
  } catch (e) {
    print('Error synchronizing data from API to Hive for Address Formats: $e');
  }
}
Future<void> _synchronizeAddressFormats(
  List<Map<String, dynamic>> addressFormatsData,
  Box<AddressFormat> addressFormatsBox,
) async {
  try {
    // Prepare lists for batch operations
    List<AddressFormat> addressFormatsToUpdate = [];
    List<String> addressFormatsToDelete = [];

    // Iterate over the retrieved data
    for (var data in addressFormatsData) {
      var cmpCode = data['cmpCode'] ?? '';
      var addrFormatID = data['addrFormatID'] ?? '';

      var updatedAddressFormat = AddressFormat(
        cmpCode: cmpCode,
        addrFormatID: addrFormatID,
      );

      addressFormatsToUpdate.add(updatedAddressFormat);
    }

    // Batch update address formats
    await addressFormatsBox.putAll(Map.fromIterable(
      addressFormatsToUpdate,
      key: (addressFormat) =>
          '${addressFormat.cmpCode}${addressFormat.addrFormatID}',
    ));

    // Delete address formats not present in the updated data
    Set<String> updatedAddressFormatKeys = addressFormatsToUpdate
        .map((addressFormat) =>
            '${addressFormat.cmpCode}${addressFormat.addrFormatID}')
        .toSet();
    addressFormatsBox.keys
        .where((addressFormatKey) =>
            !updatedAddressFormatKeys.contains(addressFormatKey))
        .forEach((addressFormatKey) {
      addressFormatsToDelete.add(addressFormatKey);
    });
    await addressFormatsBox.deleteAll(addressFormatsToDelete);
  } catch (e) {
    print('Error synchronizing address formats from API to Hive: $e');
  }
}





}

  // Add similar methods for synchronizing other data if needed








// Add similar methods for synchronizing other data if needed