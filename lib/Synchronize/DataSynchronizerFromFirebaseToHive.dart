import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:project/classes/PriceItemKey.dart';
import 'package:project/hive/adminsubmenu_hive.dart';
import 'package:project/hive/authorization_hive.dart';
import 'package:project/hive/companies_hive.dart';
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
class DataSynchronizerFromFirebaseToHive {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> synchronizeData() async {
    try {
      // Fetch data from Firestore
      var firestoreItems = await _firestore.collection('Items').get();

      // Open Hive boxes
      var itemsBox = await Hive.openBox<Items>('items');
      // Open other boxes if needed

      // Synchronize data
      await _synchronizeItems(firestoreItems.docs, itemsBox);
      // Synchronize other data if needed

      // Close Hive boxes
     // await itemsBox.close();
      // Close other boxes if needed
    } catch (e) {
      print('Error synchronizing data from Firebase to Hive: $e');
    }
  }
 Future<void> _synchronizeItems(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreItems,
  Box<Items> itemsBox,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreItems) {
      var itemCode = doc['itemCode'];
      // Check if the item exists in Hive
      var hiveItem = itemsBox.get(itemCode);

      // If the item doesn't exist in Hive, add it
      if (hiveItem == null) {
        var newItem = Items(
          doc['itemCode'],
          doc['itemName'],
          doc['itemPrName'],
          doc['itemFName'],
          doc['itemPrFName'],
          doc['groupCode'],
          doc['categCode'],
          doc['brandCode'],
          doc['itemType'],
          doc['barCode'],
          doc['uom'],
          doc['picture'],
          doc['remark'],
          doc['brand'],
          doc['manageBy'],
          doc['vatRate'].toDouble(),
          doc['active'],
          doc['weight'].toDouble(),
          doc['charect1'],
          doc['charact2'],
          doc['cmpCode']
        );
        await itemsBox.put(itemCode, newItem);
      }
      // If the item exists in Hive, update it if needed
      else {
        var updatedItem = Items(
          doc['itemCode'],
          doc['itemName'],
          doc['itemPrName'],
          doc['itemFName'],
          doc['itemPrFName'],
          doc['groupCode'],
          doc['categCode'],
          doc['brandCode'],
          doc['itemType'],
          doc['barCode'],
          doc['uom'],
          doc['picture'],
          doc['remark'],
          doc['brand'],
          doc['manageBy'],
          doc['vatRate'].toDouble(),
          doc['active'],
          doc['weight'].toDouble(),
          doc['charect1'],
          doc['charact2'],
          doc['cmpCode']
        );
        // Update the item in Hive
        await itemsBox.put(itemCode, updatedItem);
      }
    }

    // Check for items in Hive that don't exist in Firestore and delete them
    itemsBox.keys.toList().forEach((hiveItemCode) {
        if (!firestoreItems.any((doc) => doc['itemCode'] == hiveItemCode)) {
          // Item exists in Hive but not in Firestore, so delete it from Hive
          itemsBox.delete(hiveItemCode);
        }
      });

  } catch (e) {
    print('Error synchronizing items from Firebase to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------


Future<void> synchronizeDataPriceLists() async {
    try {
      // Fetch data from Firestore
      var firestoreItems = await _firestore.collection('PriceList').get();

      // Open Hive boxes
      var pricelistsBox = await Hive.openBox<PriceList>('pricelists');
      // Open other boxes if needed

      // Synchronize data
      await _synchronizePriceList(firestoreItems.docs, pricelistsBox);
      // Synchronize other data if needed

      // Close Hive boxes
      //await pricelistsBox.close();
      // Close other boxes if needed
    } catch (e) {
      print('Error synchronizing data from Firebase to Hive: $e');
    }
  }

 Future<void> _synchronizePriceList(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestorePriceLists,
  Box<PriceList> pricelistsBox,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestorePriceLists) {
      var plCode = doc['plCode'];
      // Check if the item exists in Hive
      var hivePrice = pricelistsBox.get(plCode);

      // If the item doesn't exist in Hive, add it
      if (hivePrice == null) {
        var newPrice = PriceList(
          doc['plCode'],
          doc['plName'],
          doc['currency'],
          doc['basePL'].toDouble(),
          doc['factor'].toDouble(),
          doc['incVAT'],
          doc['securityGroup'],
           doc['cmpCode']
        );
        await pricelistsBox.put(plCode, newPrice);
      }
      // If the item exists in Hive, update it if needed
      else {
        var updatedPrice = PriceList(
         doc['plCode'],
          doc['plName'],
          doc['currency'],
          doc['basePL'].toDouble(),
          doc['factor'].toDouble(),
          doc['incVAT'],
          doc['securityGroup'],
          doc['cmpCode']
        );
        // Update the item in Hive
        await pricelistsBox.put(plCode, updatedPrice);
      }
    }

    // Check for items in Hive that don't exist in Firestore and delete them
Set<String> firestorePriceCodes = Set.from(firestorePriceLists.map((doc) => doc['plCode']));
Set<String> hivePriceCodes = Set.from(pricelistsBox.keys);

// Identify items in Hive that don't exist in Firestore
Set<String> itemsToDelete = hivePriceCodes.difference(firestorePriceCodes);

// Delete items in Hive that don't exist in Firestore
itemsToDelete.forEach((hivePriceCode) {
  pricelistsBox.delete(hivePriceCode);
});


  } catch (e) {
    print('Error synchronizing PricesList from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------



Future<void> synchronizeDataItemPrice() async {
    try {
      // Fetch data from Firestore
      var firestoreItems = await _firestore.collection('ItemsPrices').get();

      // Open Hive boxes
var itempriceBox = await Hive.openBox<ItemsPrices>('itemprices');


      // Open other boxes if needed

      // Synchronize data
      await _synchronizeItemPrice(firestoreItems.docs, itempriceBox);
      // Synchronize other data if needed

      // Close Hive boxes
      //await pricelistsBox.close();
      // Close other boxes if needed
    } catch (e) {
      print('Error synchronizing data from Firebase to Hive: $e');
    }
  }

Future<void> _synchronizeItemPrice(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreItemPrice,
  Box<ItemsPrices> itempriceBox,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreItemPrice) {
      var plCode = doc['plCode'];
      var itemCode = doc['itemCode'];

      // Use compound key (plCode, itemCode)
    // Use compound key (plCode_itemCode)
var hivePriceItem = itempriceBox.get('$plCode$itemCode');

// If the item doesn't exist in Hive, add it
if (hivePriceItem == null) {
  var newPriceItem = ItemsPrices(
    plCode,
    itemCode,
    doc['uom'],
    doc['basePrice'].toDouble(),
    doc['currency'],
    doc['auto'],
    doc['disc'].toDouble(),
    doc['price'].toDouble(),
    doc['cmpCode']
  );
  await itempriceBox.put('$plCode$itemCode', newPriceItem);

    }
// If the item exists in Hive, update it if needed
else {
  var updatedPriceItem = ItemsPrices(
    plCode,
    itemCode,
    doc['uom'],
    doc['basePrice'].toDouble(),
    doc['currency'],
    doc['auto'],
    doc['disc'].toDouble(),
    doc['price'].toDouble(),
    doc['cmpCode']
  );
  // Update the item in Hive
  await itempriceBox.put('$plCode$itemCode', updatedPriceItem);
}
 
    }

Set<String> firestorePriceItemKeys =
        Set.from(firestoreItemPrice.map((doc) => '${doc['plCode']}${doc['itemCode']}'));
    Set<String> hivePriceItemKeys = Set.from(itempriceBox.keys);

    // Identify items in Hive that don't exist in Firestore
    Set<String> itemsToDelete = hivePriceItemKeys.difference(firestorePriceItemKeys);

    // Delete items in Hive that don't exist in Firestore
    itemsToDelete.forEach((hivePriceItemKey) {
      itempriceBox.delete(hivePriceItemKey);
    });

  } catch (e) {
    print('Error synchronizing ItemPrices from Firebase to Hive: $e');
  }
}



//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------




Future<void> synchronizeDataItemAttach() async {
    try {
      // Fetch data from Firestore
      var firestoreItems = await _firestore.collection('ItemAttach').get();

      // Open Hive boxes
      var itemattachBox = await Hive.openBox<ItemAttach>('itemattach');
      // Open other boxes if needed

      // Synchronize data
      await _synchronizeItemAttach(firestoreItems.docs, itemattachBox);
      // Synchronize other data if needed

      // Close Hive boxes
      //await pricelistsBox.close();
      // Close other boxes if needed
    } catch (e) {
      print('Error synchronizing data from Firebase to Hive: $e');
    }
  }

 Future<void> _synchronizeItemAttach(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreItemAttach,
  Box<ItemAttach> itemattachBox,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreItemAttach) {
      var itemCode = doc['itemCode'];
      // Check if the item exists in Hive
      var hiveAttachItem = itemattachBox.get(itemCode);

      // If the item doesn't exist in Hive, add it
      if (hiveAttachItem == null) {
        var newAttachItem= ItemAttach(
          doc['itemCode'],
          doc['attachmentType'],
          doc['attachmentPath'],
          doc['note'],
          doc['cmpCode']
          
        );
        await itemattachBox.put(itemCode, newAttachItem);
      }
      // If the item exists in Hive, update it if needed
      else {
        var updatedAttachItem = ItemAttach(
          doc['itemCode'],
          doc['attachmentType'],
          doc['attachmentPath'],
          doc['note'],
          doc['cmpCode']
        );
        // Update the item in Hive
        await itemattachBox.put(itemCode, updatedAttachItem);
      }
    }

    // Check for items in Hive that don't exist in Firestore and delete them
    Set<String> firestoreItemAttachCodes =
        Set.from(firestoreItemAttach.map((doc) => doc['itemCode']));
    Set<String> hiveItemAttachCodes = Set.from(itemattachBox.keys);

    // Identify items in Hive that don't exist in Firestore
    Set<String> itemsToDelete = hiveItemAttachCodes.difference(firestoreItemAttachCodes);

    // Delete items in Hive that don't exist in Firestore
    itemsToDelete.forEach((hiveItemAttachCode) {
      itemattachBox.delete(hiveItemAttachCode);
    });


  } catch (e) {
    print('Error synchronizing ItemAttach from Firebase to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------



Future<void> synchronizeDataItemGroup() async {
    try {
      // Fetch data from Firestore
      var firestoreItems = await _firestore.collection('ItemGroup').get();

      // Open Hive boxes
      var itemgroupBox = await Hive.openBox<ItemGroup>('itemgroup');
      // Open other boxes if needed

      // Synchronize data
      await _synchronizeItemGroup(firestoreItems.docs, itemgroupBox);
      // Synchronize other data if needed

      // Close Hive boxes
      //await pricelistsBox.close();
      // Close other boxes if needed
    } catch (e) {
      print('Error synchronizing data from Firebase to Hive: $e');
    }
  }

 Future<void> _synchronizeItemGroup(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreItemGroup,
  Box<ItemGroup> itemgroupBox,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreItemGroup) {
      var groupCode = doc['groupCode'];
      // Check if the item exists in Hive
      var hiveGroupItem = itemgroupBox.get(groupCode);

      // If the item doesn't exist in Hive, add it
      if (hiveGroupItem == null) {
        var newGroupItem= ItemGroup(
          doc['groupCode'],
          doc['groupName'],
          doc['groupFName'],
          doc['cmpCode']
        
          
        );
        await itemgroupBox.put(groupCode, newGroupItem);
      }
      // If the item exists in Hive, update it if needed
      else {
        var updatedGroupItem = ItemGroup(
         doc['groupCode'],
         doc['groupName'],
          doc['groupFName'],
          doc['cmpCode']
        );
        // Update the item in Hive
        await itemgroupBox.put(groupCode, updatedGroupItem);
      }
    }

// Check for items in Hive that don't exist in Firestore and delete them
    Set<String> firestoreItemGroupCodes =
        Set.from(firestoreItemGroup.map((doc) => doc['groupCode']));
    Set<String> hiveItemGroupCodes = Set.from(itemgroupBox.keys);

    // Identify items in Hive that don't exist in Firestore
    Set<String> itemsToDelete = hiveItemGroupCodes.difference(firestoreItemGroupCodes);

    // Delete items in Hive that don't exist in Firestore
    itemsToDelete.forEach((hiveItemGroupCode) {
      itemgroupBox.delete(hiveItemGroupCode);
    });

  } catch (e) {
    print('Error synchronizing ItemGroup from Firebase to Hive: $e');
  }
}




//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------



Future<void> synchronizeDataItemCateg() async {
    try {
      // Fetch data from Firestore
      var firestoreItems = await _firestore.collection('ItemCateg').get();

      // Open Hive boxes
      var itemcategBox = await Hive.openBox<ItemCateg>('itemcateg');
      // Open other boxes if needed

      // Synchronize data
      await _synchronizeItemCateg(firestoreItems.docs, itemcategBox);
      // Synchronize other data if needed

      // Close Hive boxes
      //await pricelistsBox.close();
      // Close other boxes if needed
    } catch (e) {
      print('Error synchronizing data from Firebase to Hive: $e');
    }
  }

 Future<void> _synchronizeItemCateg(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreItemCateg,
  Box<ItemCateg> itemcategBox,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreItemCateg) {
      var categCode = doc['categCode'];
      // Check if the item exists in Hive
      var hiveCategItem = itemcategBox.get(categCode);

      // If the item doesn't exist in Hive, add it
      if (hiveCategItem == null) {
        var newCategItem= ItemCateg(
          doc['categCode'],
          doc['categName'],
          doc['categFName'],
          doc['cmpCode']
        
          
        );
        await itemcategBox.put(categCode, newCategItem);
      }
      // If the item exists in Hive, update it if needed
      else {
        var updatedCategItem = ItemCateg(
          doc['categCode'],
          doc['categName'],
          doc['categFName'],
          doc['cmpCode']
        );
        // Update the item in Hive
        await itemcategBox.put(categCode, updatedCategItem);
      }
    }

    // Check for items in Hive that don't exist in Firestore and delete them
    Set<String> firestoreItemCategCodes =
        Set.from(firestoreItemCateg.map((doc) => doc['categCode']));
    Set<String> hiveItemCategCodes = Set.from(itemcategBox.keys);

    // Identify items in Hive that don't exist in Firestore
    Set<String> itemsToDelete = hiveItemCategCodes.difference(firestoreItemCategCodes);

    // Delete items in Hive that don't exist in Firestore
    itemsToDelete.forEach((hiveItemCategCode) {
      itemcategBox.delete(hiveItemCategCode);
    });

  } catch (e) {
    print('Error synchronizing ItemCateg from Firebase to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------



Future<void> synchronizeDataItemBrand() async {
    try {
      // Fetch data from Firestore
      var firestoreItems = await _firestore.collection('ItemBrand').get();

      // Open Hive boxes
      var itembrandBox = await Hive.openBox<ItemBrand>('itembrand');
      // Open other boxes if needed

      // Synchronize data
      await _synchronizeItemBrand(firestoreItems.docs, itembrandBox);
      // Synchronize other data if needed

      // Close Hive boxes
      //await pricelistsBox.close();
      // Close other boxes if needed
    } catch (e) {
      print('Error synchronizing data from Firebase to Hive: $e');
    }
  }

 Future<void> _synchronizeItemBrand(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreItemBrand,
  Box<ItemBrand> itembrandBox,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreItemBrand) {
      var brandCode = doc['brandCode'];
      // Check if the item exists in Hive
      var hiveBrandItem = itembrandBox.get(brandCode);

      // If the item doesn't exist in Hive, add it
      if (hiveBrandItem == null) {
        var newBrandItem= ItemBrand(
          doc['brandCode'],
          doc['brandName'],
          doc['brandFName'],
          doc['cmpCode']
        
          
        );
        await itembrandBox.put(brandCode, newBrandItem);
      }
      // If the item exists in Hive, update it if needed
      else {
        var updatedBrandItem = ItemBrand(
         doc['brandCode'],
          doc['brandName'],
          doc['brandFName'],
          doc['cmpCode']
        
        );
        // Update the item in Hive
        await itembrandBox.put(brandCode, updatedBrandItem);
      }
    }

    // Check for items in Hive that don't exist in Firestore and delete them
Set<String> firestoreItemBrandCodes =
        Set.from(firestoreItemBrand.map((doc) => doc['brandCode']));
    Set<String> hiveItemBrandCodes = Set.from(itembrandBox.keys);

    // Identify items in Hive that don't exist in Firestore
    Set<String> itemsToDelete = hiveItemBrandCodes.difference(firestoreItemBrandCodes);

    // Delete items in Hive that don't exist in Firestore
    itemsToDelete.forEach((hiveItemBrandCode) {
      itembrandBox.delete(hiveItemBrandCode);
    });


  } catch (e) {
    print('Error synchronizing ItemBrand from Firebase to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------



Future<void> synchronizeDataItemUOM() async {
    try {
      // Fetch data from Firestore
      var firestoreItems = await _firestore.collection('ItemUOM').get();

      // Open Hive boxes
      var itemuomBox = await Hive.openBox<ItemUOM>('itemuom');
      // Open other boxes if needed

      // Synchronize data
      await _synchronizeItemUOM(firestoreItems.docs, itemuomBox);
      // Synchronize other data if needed

      // Close Hive boxes
      //await pricelistsBox.close();
      // Close other boxes if needed
    } catch (e) {
      print('Error synchronizing data from Firebase to Hive: $e');
    }
  }

 Future<void> _synchronizeItemUOM(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreItemUOM,
  Box<ItemUOM> itemuomBox,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreItemUOM) {
      var itemCode = doc['itemCode'];
      // Check if the item exists in Hive
      var hiveuomItem = itemuomBox.get(itemCode);

      // If the item doesn't exist in Hive, add it
      if (hiveuomItem == null) {
        var newUOMItem= ItemUOM(
          doc['itemCode'],
          doc['uom'],
          doc['qtyperUOM'].toDouble(),
         doc['barCode'],
         doc['cmpCode']
        
          
        );
        await itemuomBox.put(itemCode, newUOMItem);
      }
      // If the item exists in Hive, update it if needed
      else {
        var updatedUOMItem = ItemUOM(
        doc['itemCode'],
          doc['uom'],
          doc['qtyperUOM'].toDouble(),
         doc['barCode'],
         doc['cmpCode']
        );
        // Update the item in Hive
        await itemuomBox.put(itemCode, updatedUOMItem);
      }
    }

// Check for items in Hive that don't exist in Firestore and delete them
    Set<String> firestoreItemUOMCodes =
        Set.from(firestoreItemUOM.map((doc) => doc['itemCode']));
    Set<String> hiveItemUOMCodes = Set.from(itemuomBox.keys);

    // Identify items in Hive that don't exist in Firestore
    Set<String> itemsToDelete = hiveItemUOMCodes.difference(firestoreItemUOMCodes);

    // Delete items in Hive that don't exist in Firestore
    itemsToDelete.forEach((hiveItemUOMCode) {
      itemuomBox.delete(hiveItemUOMCode);
    });


  } catch (e) {
    print('Error synchronizing UOM from Firebase to Hive: $e');
  }
}




//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------


Future<void> synchronizeDataUserPL() async {
    try {
      // Fetch data from Firestore
      var firestoreItems = await _firestore.collection('UserPL').get();

      // Open Hive boxes
      var userplBox = await Hive.openBox<UserPL>('userpl');
      // Open other boxes if needed

      // Synchronize data
      await _synchronizeUserPL(firestoreItems.docs, userplBox);
      // Synchronize other data if needed

      // Close Hive boxes
      //await pricelistsBox.close();
      // Close other boxes if needed
    } catch (e) {
      print('Error synchronizing data from Firebase to Hive: $e');
    }
  }

 Future<void> _synchronizeUserPL(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreUserPL,
  Box<UserPL> userplBox,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreUserPL) {
      var userCode = doc['userCode'];
      // Check if the item exists in Hive
      var hiveuserPL = userplBox.get(userCode);

      // If the item doesn't exist in Hive, add it
      if (hiveuserPL == null) {
        var newUserPL= UserPL(
          doc['userCode'],
          doc['plSecGroup'],  
        );
        await userplBox.put(userCode, newUserPL);
      }
      // If the item exists in Hive, update it if needed
      else {
        var updateduserPL = UserPL(
            doc['userCode'],
          doc['plSecGroup'], 
        );
        // Update the item in Hive
        await userplBox.put(userCode, updateduserPL);
      }
    }

    // Check for items in Hive that don't exist in Firestore and delete them
  Set<String> firestoreUserPLCodes =
        Set.from(firestoreUserPL.map((doc) => doc['userCode']));
    Set<String> hiveUserPLCodes = Set.from(userplBox.keys);

    // Identify items in Hive that don't exist in Firestore
    Set<String> itemsToDelete = hiveUserPLCodes.difference(firestoreUserPLCodes);

    // Delete items in Hive that don't exist in Firestore
    itemsToDelete.forEach((hiveUserPLCode) {
      userplBox.delete(hiveUserPLCode);
    });


  } catch (e) {
    print('Error synchronizing USERPL from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------



Future<void> synchronizeDataUser() async {
    try {
      // Fetch data from Firestore
      var firestoreItems = await _firestore.collection('Users').get();

      // Open Hive boxes

      // Open other boxes if needed


      // Synchronize data
      await _synchronizeUsers(firestoreItems.docs);
      // Synchronize other data if needed

      // Close Hive boxes
      //await pricelistsBox.close();
      // Close other boxes if needed
    } catch (e) {
      print('Error synchronizing data from Firebase to Hive: $e');
    }
  }
Future<void> _synchronizeUsers(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreUsers,
) async {
  try {
    var userBox = await Hive.openBox('userBox');
    
    // Get the list of emails from Firestore users
    Set<String> firestoreUserEmails = Set.from(firestoreUsers.map((doc) => doc['email']));

    // Get the list of emails in the Hive box
    Set<String> hiveUserEmails = Set.from(userBox.keys);

    // Identify emails in Hive that don't exist in Firestore
    Set<String> emailsToDelete = hiveUserEmails.difference(firestoreUserEmails);

    // Iterate over Firestore documents
    for (var doc in firestoreUsers) {
      var email = doc['email'];
      var userData = doc.data() as Map<String, dynamic>;

      // If the item doesn't exist in Hive, add it
      if (!hiveUserEmails.contains(email)) {
        await userBox.put(email, userData);
      }
      // If the item exists in Hive, update it if needed
      else {
        await userBox.put(email, userData);
      }
    }

    // Delete users in Hive that don't exist in Firestore
    emailsToDelete.forEach((emailToDelete) {
      userBox.delete(emailToDelete);
    });
  } catch (e) {
    print('Error synchronizing Users from Firebase to Hive: $e');
  }
}




//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------


Future<void> synchronizeDataUserGroup() async {
  try {
    // Fetch data from Firestore
    var firestoreItems = await _firestore.collection('usergroup').get();

    // Open Hive boxes
    var userGroupBox = await Hive.openBox<UserGroup>('userGroupBox');
    // Open other boxes if needed

    print('All data in group database: ${userGroupBox.values.toList()}');


    // Synchronize data
    await _synchronizeUsersGroup(firestoreItems.docs, userGroupBox);
    // Synchronize other data if needed

    // Close Hive boxes
    //await userGroupBox.close();
    // Close other boxes if needed
  } catch (e) {
    print('Error synchronizing data from Firebase to Hive: $e');
  }
}

Future<void> _synchronizeUsersGroup(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreUsersGroup,
  Box<UserGroup> usersGroup,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreUsersGroup) {
      var usercode = doc['usercode'];
      // Check if the item exists in Hive
      var hiveusergroup = usersGroup.get(usercode);

      // If the item doesn't exist in Hive, add it
      if (hiveusergroup == null) {
        var newUserGroup = UserGroup(
          usercode: doc['usercode'],
          username: doc['username'],
        );
        await usersGroup.put(usercode, newUserGroup);
      }
      // If the item exists in Hive, update it if needed
      else {
        var updatedusergroup = UserGroup(
          usercode: doc['usercode'],
          username: doc['username'],
        );
        // Update the item in Hive
        await usersGroup.put(usercode, updatedusergroup);
      }
    }
    // Check for items in Hive that don't exist in Firestore and delete them
    Set<String> firestoreUserGroupCodes =
        Set.from(firestoreUsersGroup.map((doc) => doc['usercode']));
    Set<String> hiveUserGroupCodes = Set.from(usersGroup.keys);

    // Identify items in Hive that don't exist in Firestore
    Set<String> itemsToDelete = hiveUserGroupCodes.difference(firestoreUserGroupCodes);

    // Delete items in Hive that don't exist in Firestore
    itemsToDelete.forEach((hiveUserGroupCode) {
      usersGroup.delete(hiveUserGroupCode);
    });

  } catch (e) {
    print('Error synchronizing Users from Firebase to Hive: $e');
  }
}




//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------



Future<void> synchronizeDataUserGroupTranslations() async {
    try {
      // Fetch data from Firestore
      var firestoreItems = await _firestore.collection('Translations').get();

      // Open Hive boxes
      var translationBox = await Hive.openBox<Translations>('translationsBox');
      // Open other boxes if needed


      // Synchronize data
      await _synchronizeUsersTranslations(firestoreItems.docs, translationBox);
      // Synchronize other data if needed

      // Close Hive boxes
      //await pricelistsBox.close();
      // Close other boxes if needed
    } catch (e) {
      print('Error synchronizing data from Firebase to Hive: $e');
    }
  }

Future<void> _synchronizeUsersTranslations(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreUsersTranslations,
  Box<Translations>translationBox,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreUsersTranslations) {
      
      var usercode = doc['usercode'];
      // Check if the item exists in Hive
      var hiveusertrans = translationBox.get(usercode);

      // If the item doesn't exist in Hive, add it
      if (hiveusertrans == null) {
      
      var newtrans = Translations(
  usercode: doc['usercode'],
  translations: {'en': doc['translations.en'], 'ar': doc['translations.ar']},

        );
      
        await translationBox.put(usercode, newtrans);
      }
      // If the item exists in Hive, update it if needed
      else {
    var updatetrans = Translations(
  usercode: doc['usercode'],
  translations: {'en': doc['translations.en'], 'ar': doc['translations.ar']},

        );
      
        await translationBox.put(usercode, updatetrans);
      }
    }
// Delete items in Hive that don't exist in Firestore
    Set<String> firestoreUserTransCodes =
        Set.from(firestoreUsersTranslations.map((doc) => doc['usercode']));
    Set<String> hiveUserTransCodes = Set.from(translationBox.keys);

    // Identify items in Hive that don't exist in Firestore
    Set<String> itemsToDelete = hiveUserTransCodes.difference(firestoreUserTransCodes);

    // Delete items in Hive that don't exist in Firestore
    itemsToDelete.forEach((hiveUserTransCode) {
      translationBox.delete(hiveUserTransCode);
    });

   
  } catch (e) {
    print('Error synchronizing Translations from Firebase to Hive: $e');
  }


}




//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<void> synchronizeDataMenu() async {
  try {
    // Fetch data from Firestore
    var firestoreItems = await _firestore.collection('Menu').get();

    // Open Hive boxes
    var menuBox = await Hive.openBox<Menu>('menuBox');
    var userGroupBox = await Hive.openBox<AdminSubMenu>('adminSubMenuBox');
  var syncGroupBox = await Hive.openBox<SynchronizeSubMenu>('synchronizeSubMenu');
    print('All data in group database: ${menuBox.values.toList()}');

    // Synchronize data
    await _synchronizeMenu(firestoreItems.docs, menuBox, userGroupBox,syncGroupBox);
  } catch (e) {
    print('Error synchronizing data from Firebase to Hive: $e');
  }
}

Future<void> _synchronizeMenu(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreMenus,
  Box<Menu> menuBox,
  Box<AdminSubMenu> userGroupBox,
  Box<SynchronizeSubMenu>syncGroupBox
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreMenus) {
      var menucode = doc['menucode'];

      // Check if the menu item exists in Hive
      var hiveMenu = menuBox.get(menucode);

      // If the menu item doesn't exist in Hive, add it
      if (hiveMenu == null) {
        var newMenu = Menu(
          menucode: doc['menucode'],
          menuname: doc['menuname'],
          menuarname: doc['menuarname']
        );
        await menuBox.put(menucode, newMenu);
      } else {
        // If the menu item exists in Hive, update it if needed
        var updatedMenu = Menu(
          menucode: doc['menucode'],
          menuname: doc['menuname'],
          menuarname: doc['menuarname'],
        );
        // Update the item in Hive
        await menuBox.put(menucode, updatedMenu);
      }

      // Synchronize the usergroups subcollection
      await _synchronizeSubMenu(menucode, doc.reference.collection('usergroups'), userGroupBox);
      await synchronizeIESubMenu(menucode,doc.reference.collection('syncronizesubmenu'),syncGroupBox);
    }

    // Delete menu items from Hive that don't exist in Firestore
    menuBox.keys.toList().forEach((hiveMenuCode) {
      if (!firestoreMenus.any((doc) => doc['menucode'] == hiveMenuCode)) {
        // Menu item exists in Hive but not in Firestore, so delete it from Hive
        menuBox.delete(hiveMenuCode);
      }
    });
  } catch (e) {
    print('Error synchronizing Menus from Firestore to Hive: $e');
  }
}

Future<void> _synchronizeSubMenu(int menucode, CollectionReference usergroupsCollection, Box<AdminSubMenu> userGroupBox) async {
  try {
    var firestoreUserGroups = await usergroupsCollection.get();

    for (var userGroupDoc in firestoreUserGroups.docs) {
      var groupcode = userGroupDoc['groupcode'];

      // Check if the usergroup exists in Hive
      var hiveUserGroup = userGroupBox.get(groupcode);

      // If the usergroup doesn't exist in Hive, add it
      if (hiveUserGroup == null) {
        print('admin is null');
        var newUserGroup = AdminSubMenu(
          groupcode: userGroupDoc['groupcode'],
          groupname: userGroupDoc['groupname'],
          grouparname: userGroupDoc['grouparname'],
         
        );
        await userGroupBox.put(groupcode, newUserGroup);
      } else {
        print('updated admin');
        // If the usergroup exists in Hive, update it if needed
        var updatedUserGroup = AdminSubMenu(
          groupcode: userGroupDoc['groupcode'],
          groupname: userGroupDoc['groupname'],
          grouparname: userGroupDoc['grouparname'],
        );
        // Update the item in Hive
        await userGroupBox.put(groupcode, updatedUserGroup);
      }
    }
    print('Admin Sub Menu');

// Create sets of usergroup codes from Firestore and Hive
Set<String> firestoreUserGroupCodes = Set.from(firestoreUserGroups.docs.map((doc) => doc['groupcode']));
Set<String> hiveUserGroupCodes = Set.from(userGroupBox.keys);

// Identify items in Hive that don't exist in Firestore
Set<String> itemsToDelete = hiveUserGroupCodes.difference(firestoreUserGroupCodes);

// Delete items in Hive that don't exist in Firestore
itemsToDelete.forEach((hiveUserGroupCode) {
  userGroupBox.delete(hiveUserGroupCode);
});

  
    print('All data in adminSubMenuBox: ${userGroupBox.values.toList()}');

  } catch (e) {
    print('Error synchronizing AdminSubMenu from Firestore to Hive: $e');
  }
}
//-----


Future<void> synchronizeIESubMenu(int menucode, CollectionReference syncgroupsCollection, Box<SynchronizeSubMenu> syncGroupBox) async {
  try {
    var firestoreUserGroups = await syncgroupsCollection.get();

    for (var syncGroupDoc in firestoreUserGroups.docs) {
      var groupcode = syncGroupDoc['syncronizecode'];

      // Check if the usergroup exists in Hive
      var hiveSyncGroup = syncGroupBox.get(groupcode);

      // If the usergroup doesn't exist in Hive, add it
      if (hiveSyncGroup == null) {
        print('sync is null');
        var newSyncGroup = SynchronizeSubMenu(
          syncronizecode: syncGroupDoc['syncronizecode'],
          syncronizename: syncGroupDoc['syncronizename'],
          syncronizearname: syncGroupDoc['syncronizearname'],
         
        );
        await syncGroupBox.put(groupcode, newSyncGroup);
      } else {
        print('updated Sync');
        // If the usergroup exists in Hive, update it if needed
        var updatedSyncGroup = SynchronizeSubMenu(
          syncronizecode: syncGroupDoc['syncronizecode'],
          syncronizename: syncGroupDoc['syncronizename'],
          syncronizearname: syncGroupDoc['syncronizearname'],
        );
        // Update the item in Hive
        await syncGroupBox.put(groupcode, updatedSyncGroup);
      }
    }
    print('Sync Sub Menu');

    // Delete usergroups from Hive that don't exist in Firestore
    // Create sets of syncgroup codes from Firestore and Hive
Set<String> firestoreSyncGroupCodes = Set.from(firestoreUserGroups.docs.map((doc) => doc['syncronizecode']));
Set<String> hiveSyncGroupCodes = Set.from(syncGroupBox.keys);

// Identify items in Hive that don't exist in Firestore
Set<String> itemsToDelete = hiveSyncGroupCodes.difference(firestoreSyncGroupCodes);

// Delete items in Hive that don't exist in Firestore
itemsToDelete.forEach((hiveSyncGroupCode) {
  syncGroupBox.delete(hiveSyncGroupCode);
});

  
    print('All data in SyncSubMenuBox: ${syncGroupBox.values.toList()}');

  } catch (e) {
    print('Error synchronizing SyncSubMENY from Firestore to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------


Future<void> synchronizeDataAuthorization() async {
  try {
    // Fetch data from Firestore
    var firestoreItems = await _firestore.collection('Authorization').get();

    // Open Hive boxes
    var authoBox = await Hive.openBox<Authorization>('authorizationBox');
    // Open other boxes if needed

    print('All data in group database: ${authoBox.values.toList()}');


    // Synchronize data
    await _synchronizeAutho(firestoreItems.docs, authoBox);
    // Synchronize other data if needed

    // Close Hive boxes
    //await userGroupBox.close();
    // Close other boxes if needed
  } catch (e) {
    print('Error synchronizing data from Firebase to Hive: $e');
  }
}

Future<void> _synchronizeAutho(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreAutho,
  Box<Authorization> autho,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreAutho) {
            var menucode=doc['menucode'];
      var groupcode = doc['groupcode'];

      // Check if the item exists in Hive
      var hiveusergroup = autho.get('$menucode$groupcode');

      // If the item doesn't exist in Hive, add it
      if (hiveusergroup == null) {
        var newUserGroup = Authorization(
           menucode: doc['menucode'],
          groupcode: doc['groupcode'],
         
        );
        await autho.put(int.parse('$menucode$groupcode'), newUserGroup);
      }
      // If the item exists in Hive, update it if needed
      else {
        var updatedusergroup = Authorization(
            menucode: doc['menucode'],
          groupcode: doc['groupcode'],
        
        );
        // Update the item in Hive
        await autho.put(int.parse('$menucode$groupcode'), updatedusergroup);
      }
    }
    
  } catch (e) {
    print('Error synchronizing Autho from Firebase to Hive: $e');
  }
}




//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------



Future<void> synchronizeDataGeneralSettings() async {
  try {
    // Fetch data from Firestore
    var firestoreItems = await _firestore.collection('SystemAdmin').get();

    // Open Hive boxes
    var systemAdminBox= await Hive.openBox<SystemAdmin>('systemAdminBox');
    // Open other boxes if needed

    print('All data in group database: ${systemAdminBox.values.toList()}');


    // Synchronize data
    await _synchronizeSystem(firestoreItems.docs, systemAdminBox);
    // Synchronize other data if needed

    // Close Hive boxes
    //await userGroupBox.close();
    // Close other boxes if needed
  } catch (e) {
    print('Error synchronizing data from Firebase to Hive: $e');
  }
}

Future<void> _synchronizeSystem(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreAutho,
  Box<SystemAdmin> system,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreAutho) {
        
      var groupcode = doc['groupcode'];

      // Check if the item exists in Hive
      var hivesystem= system.get(groupcode);

      // If the item doesn't exist in Hive, add it
      if (hivesystem == null) {
        var newSystem = SystemAdmin(
        
             autoExport:doc['autoExport'],
             connDatabase: doc['connDatabase'],
              connServer: doc['connServer'],
              connUser: doc['connUser'],
              connPassword:doc['connPassword'],
              connPort: doc['connPort'],
              typeDatabase: doc['typeDatabase'],
              groupcode:doc['groupcode'],
              importFromErpToMobile: doc['importFromErpToMobile'],
              importFromBackendToMobile: doc['importFromBackendToMobile'],
        );
        await system.put(groupcode, newSystem);
      }
      // If the item exists in Hive, update it if needed
      else {
        var updatedsystem = SystemAdmin(
             autoExport:doc['autoExport'],
             connDatabase: doc['connDatabase'],
              connServer: doc['connServer'],
                connUser: doc['connUser'],
              connPassword:doc['connPassword'],
              connPort: doc['connPort'],
              typeDatabase: doc['typeDatabase'],
              groupcode:doc['groupcode'],
              importFromErpToMobile: doc['importFromErpToMobile'],
              importFromBackendToMobile: doc['importFromBackendToMobile'],
        
        );
        // Update the item in Hive
        await system.put(groupcode, updatedsystem);
      }
    }
    // Create sets of group codes from Firestore and Hive
Set<String> firestoreSystemCodes = Set.from(firestoreAutho.map((doc) => doc['groupcode']));
Set<String> hiveSystemCodes = Set.from(system.keys);

// Identify items in Hive that don't exist in Firestore
Set<String> itemsToDelete = hiveSystemCodes.difference(firestoreSystemCodes);

// Delete items in Hive that don't exist in Firestore
itemsToDelete.forEach((hiveSystemCode) {
  system.delete(hiveSystemCode);
});

  } catch (e) {
    print('Error synchronizing System General Settings from Firebase to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<void> synchronizeCompanies() async {
  try {
    // Fetch data from Firestore
    var firestoreCompanies = await FirebaseFirestore.instance.collection('Companies').get();

    // Open Hive box
    var companiesBox = await Hive.openBox<Companies>('companiesBox');

    // Synchronize data
    await _synchronizeCompanies(firestoreCompanies.docs, companiesBox);



  } catch (e) {
    print('Error synchronizing data from Firebase to Hive for Companies: $e');
  }
}

Future<void> _synchronizeCompanies(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreCompanies,
  Box<Companies> companies,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreCompanies) {
      var cmpCode = doc['cmpCode'];

      // Check if the company exists in Hive
      var hiveCompany = companies.get(cmpCode);

      // If the company doesn't exist in Hive, add it
      if (hiveCompany == null) {
        var newCompany = Companies(
          cmpCode: doc['cmpCode'],
          cmpName: doc['cmpName'],
          cmpFName: doc['cmpFName'],
          tel: doc['tel'],
          mobile: doc['mobile'],
          address: doc['address'],
          fAddress: doc['fAddress'],
          prHeader: doc['prHeader'],
          prFHeader: doc['prFHeader'],
          prFooter: doc['prFooter'],
          prFFooter: doc['prFFooter'],
          mainCurCode: doc['mainCurCode'],
          secCurCode: doc['secCurCode'],
          rateType: doc['rateType'],
          issueBatchMethod: doc['issueBatchMethod'],
          systemAdminID: doc['systemAdminID'],
          notes: doc['notes'],
        );
        await companies.put(cmpCode, newCompany);
      }
      // If the company exists in Hive, update it if needed
      else {
        var updatedCompany = Companies(
          cmpCode: doc['cmpCode'],
          cmpName: doc['cmpName'],
          cmpFName: doc['cmpFName'],
          tel: doc['tel'],
          mobile: doc['mobile'],
          address: doc['address'],
          fAddress: doc['fAddress'],
          prHeader: doc['prHeader'],
          prFHeader: doc['prFHeader'],
          prFooter: doc['prFooter'],
          prFFooter: doc['prFFooter'],
          mainCurCode: doc['mainCurCode'],
          secCurCode: doc['secCurCode'],
          rateType: doc['rateType'],
          issueBatchMethod: doc['issueBatchMethod'],
          systemAdminID: doc['systemAdminID'],
          notes: doc['notes'],
        );
        // Update the company in Hive
        await companies.put(cmpCode, updatedCompany);
      }
    }
    // Create sets of company codes from Firestore and Hive
Set<String> firestoreCompanyCodes = Set.from(firestoreCompanies.map((doc) => doc['cmpCode']));
Set<String> hiveCompanyCodes = Set.from(companies.keys);

// Identify companies in Hive that don't exist in Firestore
Set<String> companiesToDelete = hiveCompanyCodes.difference(firestoreCompanyCodes);

// Delete companies in Hive that don't exist in Firestore
companiesToDelete.forEach((hiveCompanyCode) {
  companies.delete(hiveCompanyCode);
});

  } catch (e) {
    print('Error synchronizing Companies from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<void> synchronizeDepartements() async {
  try {
    // Fetch data from Firestore
    var firestoreDepartements = await FirebaseFirestore.instance.collection('Departments').get();

    // Open Hive box
    var departementsBox = await Hive.openBox<Departements>('departmentsBox');

    // Synchronize data
    await _synchronizeDepartements(firestoreDepartements.docs, departementsBox);

    // Close Hive box

  } catch (e) {
    print('Error synchronizing data from Firebase to Hive for Departements: $e');
  }
}

Future<void> _synchronizeDepartements(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreDepartements,
  Box<Departements> departements,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreDepartements) {
      var cmpCode = doc['cmpCode'];
      var depCode = doc['depCode'];

      // Check if the departement exists in Hive
      var hiveDepartement = departements.get('$cmpCode$depCode');

      // If the departement doesn't exist in Hive, add it
      if (hiveDepartement == null) {
        var newDepartement = Departements(
          cmpCode: cmpCode,
          depCode: depCode,
          depName: doc['depName'],
          depFName: doc['depFName'],
          notes: doc['notes'],
        );
        await departements.put('$cmpCode$depCode', newDepartement);
      }
      // If the departement exists in Hive, update it if needed
      else {
        var updatedDepartement = Departements(
          cmpCode: cmpCode,
          depCode: depCode,
          depName: doc['depName'],
          depFName: doc['depFName'],
          notes: doc['notes'],
        );
        // Update the departement in Hive
        await departements.put('$cmpCode$depCode', updatedDepartement);
      }
    }
    // Create sets of department keys from Firestore and Hive
Set<String> firestoreDepartementKeys = Set.from(firestoreDepartements.map((doc) => '${doc['cmpCode']}${doc['depCode']}'));
Set<String> hiveDepartementKeys = Set.from(departements.keys);

// Identify departments in Hive that don't exist in Firestore
Set<String> departementsToDelete = hiveDepartementKeys.difference(firestoreDepartementKeys);

// Delete departments in Hive that don't exist in Firestore
departementsToDelete.forEach((hiveDepartementKey) {
  departements.delete(hiveDepartementKey);
});

  } catch (e) {
    print('Error synchronizing Departements from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------


Future<void> synchronizeExchangeRates() async {
  try {
    // Fetch data from Firestore
    var firestoreExchangeRates = await FirebaseFirestore.instance.collection('ExchangeRate').get();

    // Open Hive box
    var exchangeRateBox = await Hive.openBox<ExchangeRate>('exchangeRateBox');

    // Synchronize data
    await _synchronizeExchangeRates(firestoreExchangeRates.docs, exchangeRateBox);


  } catch (e) {
    print('Error synchronizing data from Firebase to Hive for ExchangeRate: $e');
  }
}

Future<void> _synchronizeExchangeRates(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreExchangeRates,
  Box<ExchangeRate> exchangeRates,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreExchangeRates) {
      var cmpCode = doc['cmpCode']; // Replace 'yourKey' with the actual key for the exchange rate
     var curCode=doc['curCode'];
      // Check if the exchange rate exists in Hive
      var hiveExchangeRate = exchangeRates.get('$cmpCode$curCode');

      // If the exchange rate doesn't exist in Hive, add it
      if (hiveExchangeRate == null) {
        var newExchangeRate = ExchangeRate(
          cmpCode: doc['cmpCode'],
          curCode: doc['curCode'],
          fDate: (doc['fDate'] as Timestamp).toDate(),
          tDate: (doc['tDate'] as Timestamp).toDate(),
          rate: doc['rate'],
        );
        await exchangeRates.put('$cmpCode$curCode', newExchangeRate);
      }
      // If the exchange rate exists in Hive, update it if needed
      else {
        var updatedExchangeRate = ExchangeRate(
          cmpCode: doc['cmpCode'],
          curCode: doc['curCode'],
          fDate: (doc['fDate'] as Timestamp).toDate(),
          tDate: (doc['tDate'] as Timestamp).toDate(),
          rate: doc['rate'],
        );
        // Update the exchange rate in Hive
        await exchangeRates.put('$cmpCode$curCode', updatedExchangeRate);
      }
    }
    // Create sets of exchange rate keys from Firestore and Hive
Set<String> firestoreExchangeRateKeys = Set.from(firestoreExchangeRates.map((doc) => '${doc['cmpCode']}${doc['curCode']}'));
Set<String> hiveExchangeRateKeys = Set.from(exchangeRates.keys);

// Identify exchange rates in Hive that don't exist in Firestore
Set<String> exchangeRatesToDelete = hiveExchangeRateKeys.difference(firestoreExchangeRateKeys);

// Delete exchange rates in Hive that don't exist in Firestore
exchangeRatesToDelete.forEach((hiveExchangeRateKey) {
  exchangeRates.delete(hiveExchangeRateKey);
});

  } catch (e) {
    print('Error synchronizing ExchangeRates from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------


Future<void> synchronizeCurrencies() async {
  try {
    // Fetch data from Firestore
    var firestoreCurrencies = await FirebaseFirestore.instance.collection('Currencies').get();

    // Open Hive box
    var currenciesBox = await Hive.openBox<Currencies>('currenciesBox');

    // Synchronize data
    await _synchronizeCurrencies(firestoreCurrencies.docs, currenciesBox);

    // Close Hive box

  } catch (e) {
    print('Error synchronizing data from Firebase to Hive for Currencies: $e');
  }
}

Future<void> _synchronizeCurrencies(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreCurrencies,
  Box<Currencies> currencies,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreCurrencies) {
      var curCode = doc['curCode'];
      var cmpCode = doc['cmpCode'];

      // Check if the currency exists in Hive
      var hiveCurrency = currencies.get('$cmpCode$curCode');

      // If the currency doesn't exist in Hive, add it
      if (hiveCurrency == null) {
        var newCurrency = Currencies(
          cmpCode: doc['cmpCode'],
          curCode: doc['curCode'],
          curName: doc['curName'],
          curFName: doc['curFName'],
          notes: doc['notes'],
        );
        await currencies.put('$cmpCode$curCode', newCurrency);
      }
      // If the currency exists in Hive, update it if needed
      else {
        var updatedCurrency = Currencies(
          cmpCode: doc['cmpCode'],
          curCode: doc['curCode'],
          curName: doc['curName'],
          curFName: doc['curFName'],
          notes: doc['notes'],
        );
        // Update the currency in Hive
        await currencies.put('$cmpCode$curCode', updatedCurrency);
      }
    }

    // Create sets of currency keys from Firestore and Hive
Set<String> firestoreCurrencyKeys = Set.from(firestoreCurrencies.map((doc) => '${doc['cmpCode']}${doc['curCode']}'));
Set<String> hiveCurrencyKeys = Set.from(currencies.keys);

// Identify currencies in Hive that don't exist in Firestore
Set<String> currenciesToDelete = hiveCurrencyKeys.difference(firestoreCurrencyKeys);

// Delete currencies in Hive that don't exist in Firestore
currenciesToDelete.forEach((hiveCurrencyKey) {
  currencies.delete(hiveCurrencyKey);
});


  } catch (e) {
    print('Error synchronizing Currencies from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<void> synchronizeVATGroups() async {
  try {
    // Fetch data from Firestore
    var firestoreVATGroups = await FirebaseFirestore.instance.collection('VATGroups').get();

    // Open Hive box
    var vatGroupsBox = await Hive.openBox<VATGroups>('vatGroupsBox');

    // Synchronize data
    await _synchronizeVATGroups(firestoreVATGroups.docs, vatGroupsBox);

    // Close Hive box

  } catch (e) {
    print('Error synchronizing data from Firebase to Hive for VATGroups: $e');
  }
}

Future<void> _synchronizeVATGroups(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreVATGroups,
  Box<VATGroups> vatGroups,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreVATGroups) {
      var vatCode = doc['vatCode'];
      var cmpCode = doc['vatCode'];

      // Check if the VAT group exists in Hive
      var hiveVATGroup = vatGroups.get('$cmpCode$vatCode');

      // If the VAT group doesn't exist in Hive, add it
      if (hiveVATGroup == null) {
        var newVATGroup = VATGroups(
          cmpCode: doc['cmpCode'],
          vatCode: doc['vatCode'],
          vatName: doc['vatName'],
          vatRate: doc['vatRate'],
          baseCurCode: doc['baseCurCode'],
          notes: doc['notes'],
        );
        await vatGroups.put('$cmpCode$vatCode', newVATGroup);
      }
      // If the VAT group exists in Hive, update it if needed
      else {
        var updatedVATGroup = VATGroups(
          cmpCode: doc['cmpCode'],
          vatCode: doc['vatCode'],
          vatName: doc['vatName'],
          vatRate: doc['vatRate'],
          baseCurCode: doc['baseCurCode'],
          notes: doc['notes'],
        );
        // Update the VAT group in Hive
        await vatGroups.put('$cmpCode$vatCode', updatedVATGroup);
      }
    }
    // Create sets of VAT group keys from Firestore and Hive
Set<String> firestoreVATGroupKeys = Set.from(firestoreVATGroups.map((doc) => '${doc['cmpCode']}${doc['vatCode']}'));
Set<String> hiveVATGroupKeys = Set.from(vatGroups.keys);

// Identify VAT groups in Hive that don't exist in Firestore
Set<String> vatGroupsToDelete = hiveVATGroupKeys.difference(firestoreVATGroupKeys);

// Delete VAT groups in Hive that don't exist in Firestore
vatGroupsToDelete.forEach((hiveVATGroupKey) {
  vatGroups.delete(hiveVATGroupKey);
});

  } catch (e) {
    print('Error synchronizing VATGroups from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<void> synchronizeCustGroups() async {
  try {
    // Fetch data from Firestore
    var firestoreCustGroups = await FirebaseFirestore.instance.collection('CustGroups').get();

    // Open Hive box
    var custGroupsBox = await Hive.openBox<CustGroups>('custGroupsBox');

    // Synchronize data
    await _synchronizeCustGroups(firestoreCustGroups.docs, custGroupsBox);

    // Close Hive box

  } catch (e) {
    print('Error synchronizing data from Firebase to Hive for CustGroups: $e');
  }
}

Future<void> _synchronizeCustGroups(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreCustGroups,
  Box<CustGroups> custGroups,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreCustGroups) {
      var grpCode = doc['grpCode'];
      var cmpCode = doc['cmpCode'];

      // Check if the customer group exists in Hive
      var hiveCustGroup = custGroups.get('$cmpCode$grpCode');

      // If the customer group doesn't exist in Hive, add it
      if (hiveCustGroup == null) {
        var newCustGroup = CustGroups(
          cmpCode: doc['cmpCode'],
          grpCode: doc['grpCode'],
          grpName: doc['grpName'],
          grpFName: doc['grpFName'],
          notes: doc['notes'],
        );
        await custGroups.put('$cmpCode$grpCode', newCustGroup);
      }
      // If the customer group exists in Hive, update it if needed
      else {
        var updatedCustGroup = CustGroups(
          cmpCode: doc['cmpCode'],
          grpCode: doc['grpCode'],
          grpName: doc['grpName'],
          grpFName: doc['grpFName'],
          notes: doc['notes'],
        );
        // Update the customer group in Hive
        await custGroups.put('$cmpCode$grpCode', updatedCustGroup);
      }
    }
    // Create sets of customer group keys from Firestore and Hive
Set<String> firestoreCustGroupKeys = Set.from(firestoreCustGroups.map((doc) => '${doc['cmpCode']}${doc['grpCode']}'));
Set<String> hiveCustGroupKeys = Set.from(custGroups.keys);

// Identify customer groups in Hive that don't exist in Firestore
Set<String> custGroupsToDelete = hiveCustGroupKeys.difference(firestoreCustGroupKeys);

// Delete customer groups in Hive that don't exist in Firestore
custGroupsToDelete.forEach((hiveCustGroupKey) {
  custGroups.delete(hiveCustGroupKey);
});

  } catch (e) {
    print('Error synchronizing CustGroups from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<void> synchronizeCustProperties() async {
  try {
    // Fetch data from Firestore
    var firestoreCustProperties = await FirebaseFirestore.instance.collection('CustProperties').get();

    // Open Hive box
    var custPropertiesBox = await Hive.openBox<CustProperties>('custPropertiesBox');

    // Synchronize data
    await _synchronizeCustProperties(firestoreCustProperties.docs, custPropertiesBox);

    // Close Hive box
  
  } catch (e) {
    print('Error synchronizing data from Firebase to Hive for CustProperties: $e');
  }
}

Future<void> _synchronizeCustProperties(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreCustProperties,
  Box<CustProperties> custProperties,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreCustProperties) {
      var propCode = doc['propCode'];
      var cmpCode = doc['cmpCode'];

      // Check if the customer property exists in Hive
      var hiveCustProperty = custProperties.get('$cmpCode$propCode');

      // If the customer property doesn't exist in Hive, add it
      if (hiveCustProperty == null) {
        var newCustProperty = CustProperties(
          cmpCode: doc['cmpCode'],
          propCode: doc['propCode'],
          propName: doc['propName'],
          propFName: doc['propFName'],
          notes: doc['notes'],
        );
        await custProperties.put('$cmpCode$propCode', newCustProperty);
      }
      // If the customer property exists in Hive, update it if needed
      else {
        var updatedCustProperty = CustProperties(
          cmpCode: doc['cmpCode'],
          propCode: doc['propCode'],
          propName: doc['propName'],
          propFName: doc['propFName'],
          notes: doc['notes'],
        );
        // Update the customer property in Hive
        await custProperties.put('$cmpCode$propCode', updatedCustProperty);
      }
    }
    // Create sets of customer property keys from Firestore and Hive
Set<String> firestoreCustPropertyKeys = Set.from(firestoreCustProperties.map((doc) => '${doc['cmpCode']}${doc['propCode']}'));
Set<String> hiveCustPropertyKeys = Set.from(custProperties.keys);

// Identify customer properties in Hive that don't exist in Firestore
Set<String> custPropertiesToDelete = hiveCustPropertyKeys.difference(firestoreCustPropertyKeys);

// Delete customer properties in Hive that don't exist in Firestore
custPropertiesToDelete.forEach((hiveCustPropertyKey) {
  custProperties.delete(hiveCustPropertyKey);
});

  } catch (e) {
    print('Error synchronizing CustProperties from Firebase to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------


Future<void> synchronizeRegions() async {
  try {
    // Fetch data from Firestore
    var firestoreRegions = await FirebaseFirestore.instance.collection('Regions').get();

    // Open Hive box
    var regionsBox = await Hive.openBox<Regions>('regionsBox');

    // Synchronize data
    await _synchronizeRegions(firestoreRegions.docs, regionsBox);

  } catch (e) {
    print('Error synchronizing data from Firebase to Hive for Regions: $e');
  }
}

Future<void> _synchronizeRegions(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreRegions,
  Box<Regions> regions,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreRegions) {
      var regCode = doc['regCode'];
      var cmpCode = doc['cmpCode'];

      // Check if the region exists in Hive
      var hiveRegion = regions.get('$cmpCode$regCode');

      // If the region doesn't exist in Hive, add it
      if (hiveRegion == null) {
        var newRegion = Regions(
          cmpCode: doc['cmpCode'],
          regCode: doc['regCode'],
          regName: doc['regName'],
          regFName: doc['regFName'],
          notes: doc['notes'],
        );
        await regions.put('$cmpCode$regCode', newRegion);
      }
      // If the region exists in Hive, update it if needed
      else {
        var updatedRegion = Regions(
          cmpCode: doc['cmpCode'],
          regCode: doc['regCode'],
          regName: doc['regName'],
          regFName: doc['regFName'],
          notes: doc['notes'],
        );
        // Update the region in Hive
        await regions.put('$cmpCode$regCode', updatedRegion);
      }
    }
    // Create sets of region keys from Firestore and Hive
Set<String> firestoreRegionKeys = Set.from(firestoreRegions.map((doc) => '${doc['cmpCode']}${doc['regCode']}'));
Set<String> hiveRegionKeys = Set.from(regions.keys);

// Identify regions in Hive that don't exist in Firestore
Set<String> regionsToDelete = hiveRegionKeys.difference(firestoreRegionKeys);

// Delete regions in Hive that don't exist in Firestore
regionsToDelete.forEach((hiveRegionKey) {
  regions.delete(hiveRegionKey);
});

  } catch (e) {
    print('Error synchronizing Regions from Firebase to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<void> synchronizeWarehouses() async {
  try {
    // Fetch data from Firestore
    var firestoreWarehouses = await FirebaseFirestore.instance.collection('Warehouses').get();

    // Open Hive box
    var warehousesBox = await Hive.openBox<Warehouses>('warehousesBox');

    // Synchronize data
    await _synchronizeWarehouses(firestoreWarehouses.docs, warehousesBox);

    // Close Hive box

  } catch (e) {
    print('Error synchronizing data from Firebase to Hive for Warehouses: $e');
  }
}

Future<void> _synchronizeWarehouses(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreWarehouses,
  Box<Warehouses> warehouses,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreWarehouses) {
      var whsCode = doc['whsCode'];
      var cmpCode = doc['cmpCode'];

      // Check if the warehouse exists in Hive
      var hiveWarehouse = warehouses.get('$cmpCode$whsCode');

      // If the warehouse doesn't exist in Hive, add it
      if (hiveWarehouse == null) {
        var newWarehouse = Warehouses(
          cmpCode: doc['cmpCode'],
          whsCode: doc['whsCode'],
          whsName: doc['whsName'],
          whsFName: doc['whsFName'],
          notes: doc['notes'],
        );
        await warehouses.put('$cmpCode$whsCode', newWarehouse);
      }
      // If the warehouse exists in Hive, update it if needed
      else {
        var updatedWarehouse = Warehouses(
          cmpCode: doc['cmpCode'],
          whsCode: doc['whsCode'],
          whsName: doc['whsName'],
          whsFName: doc['whsFName'],
          notes: doc['notes'],
        );
        // Update the warehouse in Hive
        await warehouses.put('$cmpCode$whsCode', updatedWarehouse);
      }
    }
    // Create sets of warehouse keys from Firestore and Hive
Set<String> firestoreWarehouseKeys = Set.from(firestoreWarehouses.map((doc) => '${doc['cmpCode']}${doc['whsCode']}'));
Set<String> hiveWarehouseKeys = Set.from(warehouses.keys);

// Identify warehouses in Hive that don't exist in Firestore
Set<String> warehousesToDelete = hiveWarehouseKeys.difference(firestoreWarehouseKeys);

// Delete warehouses in Hive that don't exist in Firestore
warehousesToDelete.forEach((hiveWarehouseKey) {
  warehouses.delete(hiveWarehouseKey);
});

  } catch (e) {
    print('Error synchronizing Warehouses from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------


Future<void> synchronizePaymentTerms() async {
  try {
    // Fetch data from Firestore
    var firestorePaymentTerms = await FirebaseFirestore.instance.collection('PaymentTerms').get();

    // Open Hive box
    var paymentTermsBox = await Hive.openBox<PaymentTerms>('paymentTermsBox');

    // Synchronize data
    await _synchronizePaymentTerms(firestorePaymentTerms.docs, paymentTermsBox);


  } catch (e) {
    print('Error synchronizing data from Firebase to Hive for PaymentTerms: $e');
  }
}

Future<void> _synchronizePaymentTerms(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestorePaymentTerms,
  Box<PaymentTerms> paymentTerms,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestorePaymentTerms) {
      var ptCode = doc['ptCode'];
      var cmpCode = doc['cmpCode'];

      // Check if the payment term exists in Hive
      var hivePaymentTerm = paymentTerms.get('$cmpCode$ptCode');

      // If the payment term doesn't exist in Hive, add it
      if (hivePaymentTerm == null) {
        var newPaymentTerm = PaymentTerms(
          cmpCode: doc['cmpCode'],
          ptCode: doc['ptCode'],
          ptName: doc['ptName'],
          ptFName: doc['ptFName'],
          startFrom: doc['startFrom'],
          nbrofDays: doc['nbrofDays'],
          notes: doc['notes'],
        );
        await paymentTerms.put('$cmpCode$ptCode', newPaymentTerm);
      }
      // If the payment term exists in Hive, update it if needed
      else {
        var updatedPaymentTerm = PaymentTerms(
          cmpCode: doc['cmpCode'],
          ptCode: doc['ptCode'],
          ptName: doc['ptName'],
          ptFName: doc['ptFName'],
          startFrom: doc['startFrom'],
          nbrofDays: doc['nbrofDays'],
          notes: doc['notes'],
        );
        // Update the payment term in Hive
        await paymentTerms.put('$cmpCode$ptCode', updatedPaymentTerm);
      }
    }
    // Create sets of payment term keys from Firestore and Hive
Set<String> firestorePaymentTermKeys = Set.from(firestorePaymentTerms.map((doc) => '${doc['cmpCode']}${doc['ptCode']}'));
Set<String> hivePaymentTermKeys = Set.from(paymentTerms.keys);

// Identify payment terms in Hive that don't exist in Firestore
Set<String> paymentTermsToDelete = hivePaymentTermKeys.difference(firestorePaymentTermKeys);

// Delete payment terms in Hive that don't exist in Firestore
paymentTermsToDelete.forEach((hivePaymentTermKey) {
  paymentTerms.delete(hivePaymentTermKey);
});

  } catch (e) {
    print('Error synchronizing PaymentTerms from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<void> synchronizeSalesEmployees() async {
  try {
    // Fetch data from Firestore
    var firestoreSalesEmployees = await FirebaseFirestore.instance.collection('SalesEmployees').get();

    // Open Hive box
    var salesEmployeesBox = await Hive.openBox<SalesEmployees>('salesEmployeesBox');

    // Synchronize data
    await _synchronizeSalesEmployees(firestoreSalesEmployees.docs, salesEmployeesBox);


  } catch (e) {
    print('Error synchronizing data from Firebase to Hive for SalesEmployees: $e');
  }
}

Future<void> _synchronizeSalesEmployees(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreSalesEmployees,
  Box<SalesEmployees> salesEmployees,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreSalesEmployees) {
      var seCode = doc['seCode'];
      var cmpCode = doc['cmpCode'];

      // Check if the sales employee exists in Hive
      var hiveSalesEmployee = salesEmployees.get('$cmpCode$seCode');

      // If the sales employee doesn't exist in Hive, add it
      if (hiveSalesEmployee == null) {
        var newSalesEmployee = SalesEmployees(
          cmpCode: doc['cmpCode'],
          seCode: doc['seCode'],
          seName: doc['seName'],
          seFName: doc['seFName'],
          mobile: doc['mobile'],
          email: doc['email'],
          whsCode: doc['whsCode'],
          reqFromWhsCode: doc['reqFromWhsCode'],
          notes: doc['notes'],
        );
        await salesEmployees.put('$cmpCode$seCode', newSalesEmployee);
      }
      // If the sales employee exists in Hive, update it if needed
      else {
        var updatedSalesEmployee = SalesEmployees(
          cmpCode: doc['cmpCode'],
          seCode: doc['seCode'],
          seName: doc['seName'],
          seFName: doc['seFName'],
          mobile: doc['mobile'],
          email: doc['email'],
          whsCode: doc['whsCode'],
          reqFromWhsCode: doc['reqFromWhsCode'],
          notes: doc['notes'],
        );
        // Update the sales employee in Hive
        await salesEmployees.put('$cmpCode$seCode', updatedSalesEmployee);
      }
    }
    // Create sets of sales employee keys from Firestore and Hive
Set<String> firestoreSalesEmployeeKeys = Set.from(firestoreSalesEmployees.map((doc) => '${doc['cmpCode']}${doc['seCode']}'));
Set<String> hiveSalesEmployeeKeys = Set.from(salesEmployees.keys);

// Identify sales employees in Hive that don't exist in Firestore
Set<String> salesEmployeesToDelete = hiveSalesEmployeeKeys.difference(firestoreSalesEmployeeKeys);

// Delete sales employees in Hive that don't exist in Firestore
salesEmployeesToDelete.forEach((hiveSalesEmployeeKey) {
  salesEmployees.delete(hiveSalesEmployeeKey);
});

  } catch (e) {
    print('Error synchronizing SalesEmployees from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<void> synchronizeSalesEmployeesCustomers() async {
  try {
    // Fetch data from Firestore
    var firestoreSalesEmployeesCustomers =
        await FirebaseFirestore.instance.collection('SalesEmployeesCustomers').get();

    // Open Hive box
    var salesEmployeesCustomersBox =
        await Hive.openBox<SalesEmployeesCustomers>('salesEmployeesCustomersBox');

    // Synchronize data
    await _synchronizeSalesEmployeesCustomers(
        firestoreSalesEmployeesCustomers.docs, salesEmployeesCustomersBox);

 
  } catch (e) {
    print('Error synchronizing data from Firebase to Hive for SalesEmployeesCustomers: $e');
  }
}

Future<void> _synchronizeSalesEmployeesCustomers(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreSalesEmployeesCustomers,
  Box<SalesEmployeesCustomers> salesEmployeesCustomers,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreSalesEmployeesCustomers) {
      var seCode = doc['seCode'];
      var custCode = doc['custCode'];
      var cmpCode = doc['cmpCode'];

      // Check if the sales employee customer relationship exists in Hive
      var hiveSalesEmployeesCustomers = salesEmployeesCustomers.get('$cmpCode$seCode$custCode');

      // If the relationship doesn't exist in Hive, add it
      if (hiveSalesEmployeesCustomers == null) {
        var newSalesEmployeesCustomers = SalesEmployeesCustomers(
          cmpCode: doc['cmpCode'],
          seCode: doc['seCode'],
          custCode: doc['custCode'],
          notes: doc['notes'],
        );
        await salesEmployeesCustomers.put('$cmpCode$seCode$custCode', newSalesEmployeesCustomers);
      }
      // If the relationship exists in Hive, update it if needed
      else {
        var updatedSalesEmployeesCustomers = SalesEmployeesCustomers(
          cmpCode: doc['cmpCode'],
          seCode: doc['seCode'],
          custCode: doc['custCode'],
          notes: doc['notes'],
        );
        // Update the relationship in Hive
        await salesEmployeesCustomers.put('$cmpCode$seCode$custCode', updatedSalesEmployeesCustomers);
      }
    }
    // Create sets of sales employee customers keys from Firestore and Hive
Set<String> firestoreSalesEmployeesCustomersKeys = Set.from(firestoreSalesEmployeesCustomers.map((doc) => '${doc['cmpCode']}${doc['seCode']}${doc['custCode']}'));
Set<String> hiveSalesEmployeesCustomersKeys = Set.from(salesEmployeesCustomers.keys);

// Identify sales employee customers relationships in Hive that don't exist in Firestore
Set<String> salesEmployeesCustomersToDelete = hiveSalesEmployeesCustomersKeys.difference(firestoreSalesEmployeesCustomersKeys);

// Delete sales employee customers relationships in Hive that don't exist in Firestore
salesEmployeesCustomersToDelete.forEach((hiveSalesEmployeesCustomersKey) {
  salesEmployeesCustomers.delete(hiveSalesEmployeesCustomersKey);
});

  } catch (e) {
    print('Error synchronizing SalesEmployeesCustomers from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------


Future<void> synchronizeSalesEmployeesDepartements() async {
  try {
    // Fetch data from Firestore
    var firestoreSalesEmployeesDepartements =
        await FirebaseFirestore.instance.collection('SalesEmployeesDepartments').get();

    // Open Hive box
    var salesEmployeesDepartementsBox =
        await Hive.openBox<SalesEmployeesDepartements>('salesEmployeesDepartmentsBox');

    // Synchronize data
    await _synchronizeSalesEmployeesDepartements(
        firestoreSalesEmployeesDepartements.docs, salesEmployeesDepartementsBox);


  } catch (e) {
    print('Error synchronizing data from Firebase to Hive for SalesEmployeesDepartements: $e');
  }
}

Future<void> _synchronizeSalesEmployeesDepartements(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreSalesEmployeesDepartements,
  Box<SalesEmployeesDepartements> salesEmployeesDepartements,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreSalesEmployeesDepartements) {
      var seCode = doc['seCode'];
      var deptCode = doc['deptCode'];
      var cmpCode = doc['cmpCode'];

      // Check if the sales employee department relationship exists in Hive
      var hiveSalesEmployeesDepartements = salesEmployeesDepartements.get('$cmpCode$seCode$deptCode');

      // If the relationship doesn't exist in Hive, add it
      if (hiveSalesEmployeesDepartements == null) {
        var newSalesEmployeesDepartements = SalesEmployeesDepartements(
          cmpCode: doc['cmpCode'],
          seCode: doc['seCode'],
          deptCode: doc['deptCode'],
          reqFromWhsCode: doc['reqFromWhsCode'],
          notes: doc['notes'],
        );
        await salesEmployeesDepartements.put('$cmpCode$seCode$deptCode', newSalesEmployeesDepartements);
      }
      // If the relationship exists in Hive, update it if needed
      else {
        var updatedSalesEmployeesDepartements = SalesEmployeesDepartements(
          cmpCode: doc['cmpCode'],
          seCode: doc['seCode'],
          deptCode: doc['deptCode'],
          reqFromWhsCode: doc['reqFromWhsCode'],
          notes: doc['notes'],
        );
        // Update the relationship in Hive
        await salesEmployeesDepartements.put('$cmpCode$seCode$deptCode', updatedSalesEmployeesDepartements);
      }
    }
    // Create sets of sales employee departments keys from Firestore and Hive
Set<String> firestoreSalesEmployeesDepartmentsKeys = Set.from(firestoreSalesEmployeesDepartements.map((doc) => '${doc['cmpCode']}${doc['seCode']}${doc['deptCode']}'));
Set<String> hiveSalesEmployeesDepartmentsKeys = Set.from(salesEmployeesDepartements.keys);

// Identify sales employee departments relationships in Hive that don't exist in Firestore
Set<String> salesEmployeesDepartmentsToDelete = hiveSalesEmployeesDepartmentsKeys.difference(firestoreSalesEmployeesDepartmentsKeys);

// Delete sales employee departments relationships in Hive that don't exist in Firestore
salesEmployeesDepartmentsToDelete.forEach((hiveSalesEmployeesDepartmentsKey) {
  salesEmployeesDepartements.delete(hiveSalesEmployeesDepartmentsKey);
});

  } catch (e) {
    print('Error synchronizing SalesEmployeesDepartements from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<void> synchronizeSalesEmployeesItemsBrands() async {
  try {
    // Fetch data from Firestore
    var firestoreSalesEmployeesItemsBrands =
        await FirebaseFirestore.instance.collection('SalesEmployeesItemsBrands').get();

    // Open Hive box
    var salesEmployeesItemsBrandsBox =
        await Hive.openBox<SalesEmployeesItemsBrands>('salesEmployeesItemsBrandsBox');

    // Synchronize data
    await _synchronizeSalesEmployeesItemsBrands(
        firestoreSalesEmployeesItemsBrands.docs, salesEmployeesItemsBrandsBox);


  } catch (e) {
    print('Error synchronizing data from Firebase to Hive for SalesEmployeesItemsBrands: $e');
  }
}

Future<void> _synchronizeSalesEmployeesItemsBrands(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreSalesEmployeesItemsBrands,
  Box<SalesEmployeesItemsBrands> salesEmployeesItemsBrands,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreSalesEmployeesItemsBrands) {
      var seCode = doc['seCode'];
      var brandCode = doc['brandCode'];
      var cmpCode = doc['cmpCode'];

      // Check if the sales employee items brands relationship exists in Hive
      var hiveSalesEmployeesItemsBrands = salesEmployeesItemsBrands.get('$cmpCode$seCode$brandCode');

      // If the relationship doesn't exist in Hive, add it
      if (hiveSalesEmployeesItemsBrands == null) {
        var newSalesEmployeesItemsBrands = SalesEmployeesItemsBrands(
          cmpCode: doc['cmpCode'],
          seCode: doc['seCode'],
          brandCode: doc['brandCode'],
          reqFromWhsCode: doc['reqFromWhsCode'],
          notes: doc['notes'],
        );
        await salesEmployeesItemsBrands.put('$cmpCode$seCode$brandCode', newSalesEmployeesItemsBrands);
      }
      // If the relationship exists in Hive, update it if needed
      else {
        var updatedSalesEmployeesItemsBrands = SalesEmployeesItemsBrands(
          cmpCode: doc['cmpCode'],
          seCode: doc['seCode'],
          brandCode: doc['brandCode'],
          reqFromWhsCode: doc['reqFromWhsCode'],
          notes: doc['notes'],
        );
        // Update the relationship in Hive
        await salesEmployeesItemsBrands.put('$cmpCode$seCode$brandCode', updatedSalesEmployeesItemsBrands);
      }
    }
    // Create sets of sales employee items brands keys from Firestore and Hive
Set<String> firestoreSalesEmployeesItemsBrandsKeys = Set.from(firestoreSalesEmployeesItemsBrands.map((doc) => '${doc['cmpCode']}${doc['seCode']}${doc['brandCode']}'));
Set<String> hiveSalesEmployeesItemsBrandsKeys = Set.from(salesEmployeesItemsBrands.keys);

// Identify sales employee items brands relationships in Hive that don't exist in Firestore
Set<String> salesEmployeesItemsBrandsToDelete = hiveSalesEmployeesItemsBrandsKeys.difference(firestoreSalesEmployeesItemsBrandsKeys);

// Delete sales employee items brands relationships in Hive that don't exist in Firestore
salesEmployeesItemsBrandsToDelete.forEach((hiveSalesEmployeesItemsBrandsKey) {
  salesEmployeesItemsBrands.delete(hiveSalesEmployeesItemsBrandsKey);
});

  } catch (e) {
    print('Error synchronizing SalesEmployeesItemsBrands from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------


Future<void> synchronizeSalesEmployeesItemsCategories() async {
  try {
    // Fetch data from Firestore
    var firestoreSalesEmployeesItemsCategories =
        await FirebaseFirestore.instance.collection('SalesEmployeesItemsCategories').get();

    // Open Hive box
    var salesEmployeesItemsCategoriesBox =
        await Hive.openBox<SalesEmployeesItemsCategories>('salesEmployeesItemsCategoriesBox');

    // Synchronize data
    await _synchronizeSalesEmployeesItemsCategories(
        firestoreSalesEmployeesItemsCategories.docs, salesEmployeesItemsCategoriesBox);


  } catch (e) {
    print('Error synchronizing data from Firebase to Hive for SalesEmployeesItemsCategories: $e');
  }
}

Future<void> _synchronizeSalesEmployeesItemsCategories(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreSalesEmployeesItemsCategories,
  Box<SalesEmployeesItemsCategories> salesEmployeesItemsCategories,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreSalesEmployeesItemsCategories) {
      var seCode = doc['seCode'];
      var cmpCode = doc['cmpCode'];
      var categCode = doc['categCode'];

      // Check if the sales employee items categories relationship exists in Hive
      var hiveSalesEmployeesItemsCategories =
          salesEmployeesItemsCategories.get('$cmpCode$seCode$categCode');

      // If the relationship doesn't exist in Hive, add it
      if (hiveSalesEmployeesItemsCategories == null) {
        var newSalesEmployeesItemsCategories = SalesEmployeesItemsCategories(
          cmpCode: doc['cmpCode'],
          seCode: doc['seCode'],
          categCode: doc['categCode'],
          reqFromWhsCode: doc['reqFromWhsCode'],
          notes: doc['notes'],
        );
        await salesEmployeesItemsCategories.put('$cmpCode$seCode$categCode', newSalesEmployeesItemsCategories);
      }
      // If the relationship exists in Hive, update it if needed
      else {
        var updatedSalesEmployeesItemsCategories = SalesEmployeesItemsCategories(
          cmpCode: doc['cmpCode'],
          seCode: doc['seCode'],
          categCode: doc['categCode'],
          reqFromWhsCode: doc['reqFromWhsCode'],
          notes: doc['notes'],
        );
        // Update the relationship in Hive
        await salesEmployeesItemsCategories.put('$cmpCode$seCode$categCode', updatedSalesEmployeesItemsCategories);
      }
    }
    // Create sets of sales employee items categories keys from Firestore and Hive
Set<String> firestoreSalesEmployeesItemsCategoriesKeys = Set.from(firestoreSalesEmployeesItemsCategories.map((doc) => '${doc['cmpCode']}${doc['seCode']}${doc['categCode']}'));
Set<String> hiveSalesEmployeesItemsCategoriesKeys = Set.from(salesEmployeesItemsCategories.keys);

// Identify sales employee items categories relationships in Hive that don't exist in Firestore
Set<String> salesEmployeesItemsCategoriesToDelete = hiveSalesEmployeesItemsCategoriesKeys.difference(firestoreSalesEmployeesItemsCategoriesKeys);

// Delete sales employee items categories relationships in Hive that don't exist in Firestore
salesEmployeesItemsCategoriesToDelete.forEach((hiveSalesEmployeesItemsCategoriesKey) {
  salesEmployeesItemsCategories.delete(hiveSalesEmployeesItemsCategoriesKey);
});

  } catch (e) {
    print('Error synchronizing SalesEmployeesItemsCategories from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<void> synchronizeSalesEmployeesItemsGroups() async {
  try {
    // Fetch data from Firestore
    var firestoreSalesEmployeesItemsGroups =
        await FirebaseFirestore.instance.collection('SalesEmployeesItemsGroups').get();

    // Open Hive box
    var salesEmployeesItemsGroupsBox =
        await Hive.openBox<SalesEmployeesItemsGroups>('salesEmployeesItemsGroupsBox');

    // Synchronize data
    await _synchronizeSalesEmployeesItemsGroups(
        firestoreSalesEmployeesItemsGroups.docs, salesEmployeesItemsGroupsBox);

  } catch (e) {
    print('Error synchronizing data from Firebase to Hive for SalesEmployeesItemsGroups: $e');
  }
}

Future<void> _synchronizeSalesEmployeesItemsGroups(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreSalesEmployeesItemsGroups,
  Box<SalesEmployeesItemsGroups> salesEmployeesItemsGroups,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreSalesEmployeesItemsGroups) {
      var seCode = doc['seCode'];
      var groupCode = doc['groupCode'];
      var cmpCode = doc['cmpCode'];

      // Check if the sales employee items groups relationship exists in Hive
      var hiveSalesEmployeesItemsGroups =
          salesEmployeesItemsGroups.get('$cmpCode$seCode$groupCode');

      // If the relationship doesn't exist in Hive, add it
      if (hiveSalesEmployeesItemsGroups == null) {
        var newSalesEmployeesItemsGroups = SalesEmployeesItemsGroups(
          cmpCode: doc['cmpCode'],
          seCode: doc['seCode'],
          groupCode: doc['groupCode'],
          reqFromWhsCode: doc['reqFromWhsCode'],
          notes: doc['notes'],
        );
        await salesEmployeesItemsGroups.put('$cmpCode$seCode$groupCode', newSalesEmployeesItemsGroups);
      }
      // If the relationship exists in Hive, update it if needed
      else {
        var updatedSalesEmployeesItemsGroups = SalesEmployeesItemsGroups(
          cmpCode: doc['cmpCode'],
          seCode: doc['seCode'],
          groupCode: doc['groupCode'],
          reqFromWhsCode: doc['reqFromWhsCode'],
          notes: doc['notes'],
        );
        // Update the relationship in Hive
        await salesEmployeesItemsGroups.put('$cmpCode$seCode$groupCode', updatedSalesEmployeesItemsGroups);
      }
    }
    // Create sets of sales employee items groups keys from Firestore and Hive
Set<String> firestoreSalesEmployeesItemsGroupsKeys = Set.from(firestoreSalesEmployeesItemsGroups.map((doc) => '${doc['cmpCode']}${doc['seCode']}${doc['groupCode']}'));
Set<String> hiveSalesEmployeesItemsGroupsKeys = Set.from(salesEmployeesItemsGroups.keys);

// Identify sales employee items groups relationships in Hive that don't exist in Firestore
Set<String> salesEmployeesItemsGroupsToDelete = hiveSalesEmployeesItemsGroupsKeys.difference(firestoreSalesEmployeesItemsGroupsKeys);

// Delete sales employee items groups relationships in Hive that don't exist in Firestore
salesEmployeesItemsGroupsToDelete.forEach((hiveSalesEmployeesItemsGroupsKey) {
  salesEmployeesItemsGroups.delete(hiveSalesEmployeesItemsGroupsKey);
});

  } catch (e) {
    print('Error synchronizing SalesEmployeesItemsGroups from Firebase to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------


Future<void> synchronizeSalesEmployeesItems() async {
  try {
    // Fetch data from Firestore
    var firestoreSalesEmployeesItems =
        await FirebaseFirestore.instance.collection('SalesEmployeesItems').get();

    // Open Hive box
    var salesEmployeesItemsBox =
        await Hive.openBox<SalesEmployeesItems>('salesEmployeesItemsBox');

    // Synchronize data
    await _synchronizeSalesEmployeesItems(
        firestoreSalesEmployeesItems.docs, salesEmployeesItemsBox);


  } catch (e) {
    print('Error synchronizing data from Firebase to Hive for SalesEmployeesItems: $e');
  }
}

Future<void> _synchronizeSalesEmployeesItems(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreSalesEmployeesItems,
  Box<SalesEmployeesItems> salesEmployeesItems,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreSalesEmployeesItems) {
      var seCode = doc['seCode'];
      var itemCode = doc['itemCode'];
      var cmpCode = doc['cmpCode'];

      // Check if the sales employee items relationship exists in Hive
      var hiveSalesEmployeesItems = salesEmployeesItems.get('$cmpCode$seCode$itemCode');

      // If the relationship doesn't exist in Hive, add it
      if (hiveSalesEmployeesItems == null) {
        var newSalesEmployeesItems = SalesEmployeesItems(
          cmpCode: doc['cmpCode'],
          seCode: doc['seCode'],
          itemCode: doc['itemCode'],
          reqFromWhsCode: doc['reqFromWhsCode'],
          notes: doc['notes'],
        );
        await salesEmployeesItems.put('$cmpCode$seCode$itemCode', newSalesEmployeesItems);
      }
      // If the relationship exists in Hive, update it if needed
      else {
        var updatedSalesEmployeesItems = SalesEmployeesItems(
          cmpCode: doc['cmpCode'],
          seCode: doc['seCode'],
          itemCode: doc['itemCode'],
          reqFromWhsCode: doc['reqFromWhsCode'],
          notes: doc['notes'],
        );
        // Update the relationship in Hive
        await salesEmployeesItems.put('$cmpCode$seCode$itemCode', updatedSalesEmployeesItems);
      }
    }
    // Create sets of sales employee items keys from Firestore and Hive
Set<String> firestoreSalesEmployeesItemsKeys = Set.from(firestoreSalesEmployeesItems.map((doc) => '${doc['cmpCode']}${doc['seCode']}${doc['itemCode']}'));
Set<String> hiveSalesEmployeesItemsKeys = Set.from(salesEmployeesItems.keys);

// Identify sales employee items relationships in Hive that don't exist in Firestore
Set<String> salesEmployeesItemsToDelete = hiveSalesEmployeesItemsKeys.difference(firestoreSalesEmployeesItemsKeys);

// Delete sales employee items relationships in Hive that don't exist in Firestore
salesEmployeesItemsToDelete.forEach((hiveSalesEmployeesItemsKey) {
  salesEmployeesItems.delete(hiveSalesEmployeesItemsKey);
});

  } catch (e) {
    print('Error synchronizing SalesEmployeesItems from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<void> synchronizeUserSalesEmployees() async {
  try {
    // Fetch data from Firestore
    var firestoreUserSalesEmployees =
        await FirebaseFirestore.instance.collection('UsersSalesEmployees').get();

    // Open Hive box
    var userSalesEmployeesBox =
        await Hive.openBox<UserSalesEmployees>('userSalesEmployeesBox');

    // Synchronize data
    await _synchronizeUserSalesEmployees(
        firestoreUserSalesEmployees.docs, userSalesEmployeesBox);


  } catch (e) {
    print('Error synchronizing data from Firebase to Hive for UserSalesEmployees: $e');
  }
}

Future<void> _synchronizeUserSalesEmployees(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreUserSalesEmployees,
  Box<UserSalesEmployees> userSalesEmployees,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreUserSalesEmployees) {
      var userCode = doc['userCode'];
      var seCode = doc['seCode'];
      var cmpCode = doc['cmpCode'];

      // Check if the user sales employees relationship exists in Hive
      var hiveUserSalesEmployees = userSalesEmployees.get('$cmpCode$userCode$seCode');

      // If the relationship doesn't exist in Hive, add it
      if (hiveUserSalesEmployees == null) {
        var newUserSalesEmployees = UserSalesEmployees(
          cmpCode: doc['cmpCode'],
          userCode: doc['userCode'],
          seCode: doc['seCode'],
          notes: doc['notes'],
        );
        await userSalesEmployees.put('$cmpCode$userCode$seCode', newUserSalesEmployees);
      }
      // If the relationship exists in Hive, update it if needed
      else {
        var updatedUserSalesEmployees = UserSalesEmployees(
          cmpCode: doc['cmpCode'],
          userCode: doc['userCode'],
          seCode: doc['seCode'],
          notes: doc['notes'],
        );
        // Update the relationship in Hive
        await userSalesEmployees.put('$cmpCode$userCode$seCode', updatedUserSalesEmployees);
      }
    }
    Set<String> firestoreUserSalesEmployeesKeys = Set.from(firestoreUserSalesEmployees.map((doc) => '${doc['cmpCode']}${doc['userCode']}${doc['seCode']}'));
    Set<String> hiveUserSalesEmployeesKeys = Set.from(userSalesEmployees.keys);

    // Identify user sales employees relationships in Hive that don't exist in Firestore
    Set<String> userSalesEmployeesToDelete = hiveUserSalesEmployeesKeys.difference(firestoreUserSalesEmployeesKeys);

    // Delete user sales employees relationships in Hive that don't exist in Firestore
    userSalesEmployeesToDelete.forEach((hiveUserSalesEmployeesKey) {
      userSalesEmployees.delete(hiveUserSalesEmployeesKey);
    });

  } catch (e) {
    print('Error synchronizing UserSalesEmployees from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<void> synchronizeCustomers() async {
  try {
    // Fetch data from Firestore
    var firestoreCustomers = await FirebaseFirestore.instance.collection('Customers').get();

    // Open Hive box
    var customersBox = await Hive.openBox<Customers>('customersBox');

    // Synchronize data
    await _synchronizeCustomers(firestoreCustomers.docs, customersBox);

   
  } catch (e) {
    print('Error synchronizing data from Firebase to Hive for Customers: $e');
  }
}

Future<void> _synchronizeCustomers(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreCustomers,
  Box<Customers> customers,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreCustomers) {
      var custCode = doc['custCode'];
      var cmpCode = doc['cmpCode'];

      // Check if the customer exists in Hive
      var hiveCustomer = customers.get('$cmpCode$custCode');

      // If the customer doesn't exist in Hive, add it
      if (hiveCustomer == null) {
        var newCustomer = Customers(
          cmpCode: doc['cmpCode'],
          custCode: doc['custCode'],
          custName: doc['custName'],
          custFName: doc['custFName'],
          groupCode: doc['groupCode'],
          mofNum: doc['mofNum'],
          barcode: doc['barcode'],
          phone: doc['phone'],
          mobile: doc['mobile'],
          fax: doc['fax'],
          website: doc['website'],
          email: doc['email'],
          active: doc['active'],
          printLayout: doc['printLayout'],
          dfltAddressID: doc['dfltAddressID'],
          dfltContactID: doc['dfltContactID'],
          curCode: doc['curCode'],
          cashClient: doc['cashClient'],
          discType: doc['discType'],
          vatCode: doc['vatCode'],
          prListCode: doc['prListCode'],
          payTermsCode: doc['payTermsCode'],
          discount: doc['discount'],
          creditLimit: doc['creditLimit'],
          balance: doc['balance'],
          balanceDue: doc['balanceDue'],
          notes: doc['notes'],
        );
        await customers.put('$cmpCode$custCode', newCustomer);
      }
      // If the customer exists in Hive, update it if needed
      else {
        var updatedCustomer = Customers(
          cmpCode: doc['cmpCode'],
          custCode: doc['custCode'],
          custName: doc['custName'],
          custFName: doc['custFName'],
          groupCode: doc['groupCode'],
          mofNum: doc['mofNum'],
          barcode: doc['barcode'],
          phone: doc['phone'],
          mobile: doc['mobile'],
          fax: doc['fax'],
          website: doc['website'],
          email: doc['email'],
          active: doc['active'],
          printLayout: doc['printLayout'],
          dfltAddressID: doc['dfltAddressID'],
          dfltContactID: doc['dfltContactID'],
          curCode: doc['curCode'],
          cashClient: doc['cashClient'],
          discType: doc['discType'],
          vatCode: doc['vatCode'],
          prListCode: doc['prListCode'],
          payTermsCode: doc['payTermsCode'],
          discount: doc['discount'],
          creditLimit: doc['creditLimit'],
          balance: doc['balance'],
          balanceDue: doc['balanceDue'],
          notes: doc['notes'],
        );
        // Update the customer in Hive
        await customers.put('$cmpCode$custCode', updatedCustomer);
      }
    }
    Set<String> firestoreCustomersKeys = Set.from(firestoreCustomers.map((doc) => '${doc['cmpCode']}${doc['custCode']}'));
    Set<String> hiveCustomersKeys = Set.from(customers.keys);

    // Identify customers in Hive that don't exist in Firestore
    Set<String> customersToDelete = hiveCustomersKeys.difference(firestoreCustomersKeys);

    // Delete customers in Hive that don't exist in Firestore
    customersToDelete.forEach((hiveCustomerKey) {
      customers.delete(hiveCustomerKey);
    });
  } catch (e) {
    print('Error synchronizing Customers from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<void> synchronizeCustomerAddresses() async {
  try {
    // Fetch data from Firestore
    var firestoreAddresses = await FirebaseFirestore.instance.collection('CustomerAddresses').get();

    // Open Hive box
    var addressesBox = await Hive.openBox<CustomerAddresses>('customerAddressesBox');

    // Synchronize data
    await _synchronizeCustomerAddresses(firestoreAddresses.docs, addressesBox);


  } catch (e) {
    print('Error synchronizing data from Firebase to Hive for CustomerAddresses: $e');
  }
}

Future<void> _synchronizeCustomerAddresses(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreAddresses,
  Box<CustomerAddresses> addresses,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreAddresses) {

     
      var addressID = doc['addressID'];
      // Check if the address exists in Hive
      var hiveAddress = addresses.get('$addressID');

      // If the address doesn't exist in Hive, add it
      if (hiveAddress == null) {
        var newAddress = CustomerAddresses(
          cmpCode: doc['cmpCode'],
          custCode: doc['custCode'],
          addressID: doc['addressID'],
          address: doc['address'],
          fAddress: doc['fAddress'],
          regCode: doc['regCode'],
          gpslat: doc['gpslat'],
          gpslong: doc['gpslong'],
          notes: doc['notes'],
        );
        await addresses.put('$addressID', newAddress);
      }
      // If the address exists in Hive, update it if needed
      else {
        var updatedAddress = CustomerAddresses(
          cmpCode: doc['cmpCode'],
          custCode: doc['custCode'],
          addressID: doc['addressID'],
          address: doc['address'],
          fAddress: doc['fAddress'],
          regCode: doc['regCode'],
          gpslat: doc['gpslat'],
          gpslong: doc['gpslong'],
          notes: doc['notes'],
        );
        // Update the address in Hive
        await addresses.put('$addressID', updatedAddress);
      }
    }
    Set<String> firestoreAddressesKeys = Set.from(firestoreAddresses.map((doc) => '${doc['addressID']}'));
    Set<String> hiveAddressesKeys = Set.from(addresses.keys);

    // Identify addresses in Hive that don't exist in Firestore
    Set<String> addressesToDelete = hiveAddressesKeys.difference(firestoreAddressesKeys);

    // Delete addresses in Hive that don't exist in Firestore
    addressesToDelete.forEach((hiveAddressKey) {
      addresses.delete(hiveAddressKey);
    });

  } catch (e) {
    print('Error synchronizing CustomerAddresses from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<void> synchronizeCustomerContacts() async {
  try {
    // Fetch data from Firestore
    var firestoreContacts = await FirebaseFirestore.instance.collection('CustomerContacts').get();

    // Open Hive box
    var contactsBox = await Hive.openBox<CustomerContacts>('customerContactsBox');

    // Synchronize data
    await _synchronizeCustomerContacts(firestoreContacts.docs, contactsBox);


  } catch (e) {
    print('Error synchronizing data from Firebase to Hive for CustomerContacts: $e');
  }
}

Future<void> _synchronizeCustomerContacts(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreContacts,
  Box<CustomerContacts> contacts,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreContacts) {

   var contactID = doc['contactID'];
 print(doc.data());
      // Check if the contact exists in Hive
      var hiveContact = contacts.get('$contactID');

      // If the contact doesn't exist in Hive, add it
      if (hiveContact == null) {
        var newContact = CustomerContacts(
          cmpCode: doc['cmpCode'],
          custCode: doc['custCode'],
          contactID: doc['contactID'],
          contactName: doc['contactName'],
          contactFName: doc['contactFName'],
          phone: doc['phone'],
          mobile: doc['mobile'],
          email: doc['email'],
          position: doc['position'],
          notes: doc['notes'],
        );
        await contacts.put('$contactID', newContact);
      }
      // If the contact exists in Hive, update it if needed
      else {
        var updatedContact = CustomerContacts(
          cmpCode: doc['cmpCode'],
          custCode: doc['custCode'],
          contactID: doc['contactID'],
          contactName: doc['contactName'],
          contactFName: doc['contactFName'],
          phone: doc['phone'],
          mobile: doc['mobile'],
          email: doc['email'],
          position: doc['position'],
          notes: doc['notes'],
        );
        // Update the contact in Hive
        await contacts.put('$contactID', updatedContact);
      }
    }
    Set<String> firestoreContactsKeys = Set.from(firestoreContacts.map((doc) => '${doc['contactID']}'));
    Set<String> hiveContactsKeys = Set.from(contacts.keys);

    // Identify contacts in Hive that don't exist in Firestore
    Set<String> contactsToDelete = hiveContactsKeys.difference(firestoreContactsKeys);

    // Delete contacts in Hive that don't exist in Firestore
    contactsToDelete.forEach((hiveContactKey) {
      contacts.delete(hiveContactKey);
    });

  } catch (e) {
    print('Error synchronizing CustomerContacts from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<void> synchronizeCustomerProperties() async {
  try {
    // Fetch data from Firestore
    var firestoreProperties = await FirebaseFirestore.instance.collection('CustomerProperties').get();

    // Open Hive box
    var propertiesBox = await Hive.openBox<CustomerProperties>('customerPropertiesBox');

    // Synchronize data
    await _synchronizeCustomerProperties(firestoreProperties.docs, propertiesBox);

  
  } catch (e) {
    print('Error synchronizing data from Firebase to Hive for CustomerProperties: $e');
  }
}

Future<void> _synchronizeCustomerProperties(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreProperties,
  Box<CustomerProperties> properties,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreProperties) {
 
     var propCode = doc['propCode'];

      // Check if the property exists in Hive
      var hiveProperty = properties.get('$propCode');

      // If the property doesn't exist in Hive, add it
      if (hiveProperty == null) {
        var newProperty = CustomerProperties(
          cmpCode: doc['cmpCode'],
          custCode: doc['custCode'],
          propCode: doc['propCode'],
          notes: doc['notes'],
        );
        await properties.put('$propCode', newProperty);
      }
      // If the property exists in Hive, update it if needed
      else {
        var updatedProperty = CustomerProperties(
          cmpCode: doc['cmpCode'],
          custCode: doc['custCode'],
          propCode: doc['propCode'],
          notes: doc['notes'],
        );
        // Update the property in Hive
        await properties.put('$propCode', updatedProperty);
      }
    }
    Set<String> firestorePropertiesKeys = Set.from(firestoreProperties.map((doc) => '${doc['propCode']}'));
    Set<String> hivePropertiesKeys = Set.from(properties.keys);

    // Identify properties in Hive that don't exist in Firestore
    Set<String> propertiesToDelete = hivePropertiesKeys.difference(firestorePropertiesKeys);

    // Delete properties in Hive that don't exist in Firestore
    propertiesToDelete.forEach((hivePropertyKey) {
      properties.delete(hivePropertyKey);
    });

  } catch (e) {
    print('Error synchronizing CustomerProperties from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<void> synchronizeCustomerAttachments() async {
  try {
    // Fetch data from Firestore
    var firestoreAttachments =
        await FirebaseFirestore.instance.collection('CustomerAttachments').get();

    // Open Hive box
    var attachmentsBox = await Hive.openBox<CustomerAttachments>('customerAttachmentsBox');

    // Synchronize data
    await _synchronizeCustomerAttachments(firestoreAttachments.docs, attachmentsBox);


  } catch (e) {
    print('Error synchronizing data from Firebase to Hive for CustomerAttachments: $e');
  }
}

Future<void> _synchronizeCustomerAttachments(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreAttachments,
  Box<CustomerAttachments> attachments,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreAttachments) {
      var cmpCode = doc['cmpCode'];
      var custCode = doc['custCode'];
      // Check if the attachment exists in Hive
      var hiveAttachment = attachments.get('$cmpCode$custCode');

      // If the attachment doesn't exist in Hive, add it
      if (hiveAttachment == null) {
        var newAttachment = CustomerAttachments(
          cmpCode: doc['cmpCode'],
          custCode: doc['custCode'],
          attach: doc['attach'],
          attachType: doc['attachType'],
          notes: doc['notes'],
        );
        await attachments.put('$cmpCode$custCode', newAttachment);
      }
      // If the attachment exists in Hive, update it if needed
      else {
        var updatedAttachment = CustomerAttachments(
          cmpCode: doc['cmpCode'],
          custCode: doc['custCode'],
          attach: doc['attach'],
          attachType: doc['attachType'],
          notes: doc['notes'],
        );
        // Update the attachment in Hive
        await attachments.put('$cmpCode$custCode', updatedAttachment);
      }
    }
    Set<String> firestoreAttachmentsKeys = Set.from(firestoreAttachments.map((doc) => '${doc['cmpCode']}${doc['custCode']}'));
    Set<String> hiveAttachmentsKeys = Set.from(attachments.keys);

    // Identify attachments in Hive that don't exist in Firestore
    Set<String> attachmentsToDelete = hiveAttachmentsKeys.difference(firestoreAttachmentsKeys);

    // Delete attachments in Hive that don't exist in Firestore
    attachmentsToDelete.forEach((hiveAttachmentKey) {
      attachments.delete(hiveAttachmentKey);
    });

  } catch (e) {
    print('Error synchronizing CustomerAttachments from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<void> synchronizeCustomerItemsSpecialPrice() async {
  try {
    // Fetch data from Firestore
    var firestoreSpecialPrice =
        await FirebaseFirestore.instance.collection('CustomerItemsSpecialPrice').get();

    // Open Hive box
    var specialPriceBox =
        await Hive.openBox<CustomerItemsSpecialPrice>('customerItemsSpecialPriceBox');

    // Synchronize data
    await _synchronizeCustomerItemsSpecialPrice(
        firestoreSpecialPrice.docs, specialPriceBox);


  } catch (e) {
    print('Error synchronizing data from Firebase to Hive for CustomerItemsSpecialPrice: $e');
  }
}

Future<void> _synchronizeCustomerItemsSpecialPrice(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreSpecialPrice,
  Box<CustomerItemsSpecialPrice> specialPrice,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreSpecialPrice) {
      var itemCode = doc['itemCode'];
      var cmpCode = doc['cmpCode'];
      var custCode = doc['custCode'];
      var uom = doc['uom'];


      // Check if the special price exists in Hive
      var hiveSpecialPrice = specialPrice.get('$cmpCode$itemCode$custCode$uom');

      // If the special price doesn't exist in Hive, add it
      if (hiveSpecialPrice == null) {
        var newSpecialPrice = CustomerItemsSpecialPrice(
          cmpCode: doc['cmpCode'],
          custCode: doc['custCode'],
          itemCode: doc['itemCode'],
          uom: doc['uom'],
          basePrice: doc['basePrice'],
          currency: doc['currency'],
          auto: doc['auto'],
          disc: doc['disc'],
          price: doc['price'],
          notes: doc['notes'],
        );
        await specialPrice.put('$cmpCode$itemCode$custCode$uom', newSpecialPrice);
      }
      // If the special price exists in Hive, update it if needed
      else {
        var updatedSpecialPrice = CustomerItemsSpecialPrice(
          cmpCode: doc['cmpCode'],
          custCode: doc['custCode'],
          itemCode: doc['itemCode'],
          uom: doc['uom'],
          basePrice: doc['basePrice'],
          currency: doc['currency'],
          auto: doc['auto'],
          disc: doc['disc'],
          price: doc['price'],
          notes: doc['notes'],
        );
        // Update the special price in Hive
        await specialPrice.put('$cmpCode$itemCode$custCode$uom', updatedSpecialPrice);
      }
    }
    Set<String> firestoreSpecialPriceKeys = Set.from(firestoreSpecialPrice.map((doc) => '${doc['cmpCode']}${doc['itemCode']}${doc['custCode']}${doc['uom']}'));
    Set<String> hiveSpecialPriceKeys = Set.from(specialPrice.keys);

    // Identify special prices in Hive that don't exist in Firestore
    Set<String> specialPricesToDelete = hiveSpecialPriceKeys.difference(firestoreSpecialPriceKeys);

    // Delete special prices in Hive that don't exist in Firestore
    specialPricesToDelete.forEach((hiveSpecialPriceKey) {
      specialPrice.delete(hiveSpecialPriceKey);
    });

  } catch (e) {
    print('Error synchronizing CustomerItemsSpecialPrice from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<void> synchronizeCustomerBrandsSpecialPrice() async {
  try {
    print('hiiiiii');
    // Fetch data from Firestore
    var firestoreBrandsSpecialPrice =
        await FirebaseFirestore.instance.collection('CustomerBrandsSpecialPrice').get();

    // Open Hive box
    var brandsSpecialPriceBox =
        await Hive.openBox<CustomerBrandsSpecialPrice>('customerBrandsSpecialPriceBox');

    // Synchronize data
    await _synchronizeCustomerBrandsSpecialPrice(
        firestoreBrandsSpecialPrice.docs, brandsSpecialPriceBox);


  } catch (e) {
    print('Error synchronizing data from Firebase to Hive for CustomerBrandsSpecialPrice: $e');
  }
}

Future<void> _synchronizeCustomerBrandsSpecialPrice(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreBrandsSpecialPrice,
  Box<CustomerBrandsSpecialPrice> brandsSpecialPrice,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreBrandsSpecialPrice) {
      var brandCode = doc['brandCode'];
      var cmpCode = doc['cmpCode'];
      var custCode = doc['custCode'];

print(doc.data());
      // Check if the brand special price exists in Hive
      var hiveBrandSpecialPrice = brandsSpecialPrice.get('$cmpCode$custCode$brandCode');

      // If the brand special price doesn't exist in Hive, add it
      if (hiveBrandSpecialPrice == null) {
        var newBrandSpecialPrice = CustomerBrandsSpecialPrice(
          cmpCode: doc['cmpCode'],
          custCode: doc['custCode'],
          brandCode: doc['brandCode'],
          disc: doc['disc'],
          notes: doc['notes'],
        );
        await brandsSpecialPrice.put('$cmpCode$custCode$brandCode', newBrandSpecialPrice);
      }
      // If the brand special price exists in Hive, update it if needed
      else {
        var updatedBrandSpecialPrice = CustomerBrandsSpecialPrice(
          cmpCode: doc['cmpCode'],
          custCode: doc['custCode'],
          brandCode: doc['brandCode'],
          disc: doc['disc'],
          notes: doc['notes'],
        );
        // Update the brand special price in Hive
        await brandsSpecialPrice.put('$cmpCode$custCode$brandCode', updatedBrandSpecialPrice);
      }
    }
    Set<String> firestoreBrandsSpecialPriceKeys = Set.from(firestoreBrandsSpecialPrice.map((doc) => '${doc['cmpCode']}${doc['custCode']}${doc['brandCode']}'));
    Set<String> hiveBrandsSpecialPriceKeys = Set.from(brandsSpecialPrice.keys);

    // Identify brand special prices in Hive that don't exist in Firestore
    Set<String> brandsSpecialPricesToDelete = hiveBrandsSpecialPriceKeys.difference(firestoreBrandsSpecialPriceKeys);

    // Delete brand special prices in Hive that don't exist in Firestore
    brandsSpecialPricesToDelete.forEach((hiveBrandSpecialPriceKey) {
      brandsSpecialPrice.delete(hiveBrandSpecialPriceKey);
    });

  } catch (e) {
    print('Error synchronizing CustomerBrandsSpecialPrice from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------


Future<void> synchronizeCustomerGroupsSpecialPrice() async {
  try {
    // Fetch data from Firestore
    var firestoreGroupsSpecialPrice =
        await FirebaseFirestore.instance.collection('CustomerGroupsSpecialPrice').get();

    // Open Hive box
    var groupsSpecialPriceBox =
        await Hive.openBox<CustomerGroupsSpecialPrice>('customerGroupsSpecialPriceBox');

    // Synchronize data
    await _synchronizeCustomerGroupsSpecialPrice(
        firestoreGroupsSpecialPrice.docs, groupsSpecialPriceBox);

  } catch (e) {
    print('Error synchronizing data from Firebase to Hive for CustomerGroupsSpecialPrice: $e');
  }
}

Future<void> _synchronizeCustomerGroupsSpecialPrice(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreGroupsSpecialPrice,
  Box<CustomerGroupsSpecialPrice> groupsSpecialPrice,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreGroupsSpecialPrice) {
      var groupCode = doc['groupCode'];
      var cmpCode = doc['cmpCode'];
      var custCode = doc['custCode'];

      // Check if the group special price exists in Hive
      var hiveGroupSpecialPrice = groupsSpecialPrice.get('$cmpCode$custCode$groupCode');

      // If the group special price doesn't exist in Hive, add it
      if (hiveGroupSpecialPrice == null) {
        var newGroupSpecialPrice = CustomerGroupsSpecialPrice(
          cmpCode: doc['cmpCode'],
          custCode: doc['custCode'],
          groupCode: doc['groupCode'],
          disc: doc['disc'],
          notes: doc['notes'],
        );
        await groupsSpecialPrice.put('$cmpCode$custCode$groupCode', newGroupSpecialPrice);
      }
      // If the group special price exists in Hive, update it if needed
      else {
        var updatedGroupSpecialPrice = CustomerGroupsSpecialPrice(
          cmpCode: doc['cmpCode'],
          custCode: doc['custCode'],
          groupCode: doc['groupCode'],
          disc: doc['disc'],
          notes: doc['notes'],
        );
        // Update the group special price in Hive
        await groupsSpecialPrice.put('$cmpCode$custCode$groupCode', updatedGroupSpecialPrice);
      }
    }
     Set<String> firestoreGroupsSpecialPriceKeys = Set.from(firestoreGroupsSpecialPrice.map((doc) => '${doc['cmpCode']}${doc['custCode']}${doc['groupCode']}'));
    Set<String> hiveGroupsSpecialPriceKeys = Set.from(groupsSpecialPrice.keys);

    // Identify group special prices in Hive that don't exist in Firestore
    Set<String> groupsSpecialPricesToDelete = hiveGroupsSpecialPriceKeys.difference(firestoreGroupsSpecialPriceKeys);

    // Delete group special prices in Hive that don't exist in Firestore
    groupsSpecialPricesToDelete.forEach((hiveGroupSpecialPriceKey) {
      groupsSpecialPrice.delete(hiveGroupSpecialPriceKey);
    });
  } catch (e) {
    print('Error synchronizing CustomerGroupsSpecialPrice from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------


Future<void> synchronizeCustomerCategSpecialPrice() async {
  try {
    // Fetch data from Firestore
    var firestoreCategSpecialPrice =
        await FirebaseFirestore.instance.collection('CustomerCategSpecialPrice').get();

    // Open Hive box
    var categSpecialPriceBox =
        await Hive.openBox<CustomerCategSpecialPrice>('customerCategSpecialPriceBox');

    // Synchronize data
    await _synchronizeCustomerCategSpecialPrice(
        firestoreCategSpecialPrice.docs, categSpecialPriceBox);

  } catch (e) {
    print('Error synchronizing data from Firebase to Hive for CustomerCategSpecialPrice: $e');
  }
}

Future<void> _synchronizeCustomerCategSpecialPrice(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreCategSpecialPrice,
  Box<CustomerCategSpecialPrice> categSpecialPrice,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreCategSpecialPrice) {
      var categCode = doc['categCode'];
   var cmpCode = doc['cmpCode'];
      var custCode = doc['custCode'];
      // Check if the categ special price exists in Hive
      var hiveCategSpecialPrice = categSpecialPrice.get('$cmpCode$custCode$categCode');

      // If the categ special price doesn't exist in Hive, add it
      if (hiveCategSpecialPrice == null) {
        var newCategSpecialPrice = CustomerCategSpecialPrice(
          cmpCode: doc['cmpCode'],
          custCode: doc['custCode'],
          categCode: doc['categCode'],
          disc: doc['disc'],
          notes: doc['notes'],
        );
        await categSpecialPrice.put('$cmpCode$custCode$categCode', newCategSpecialPrice);
      }
      // If the categ special price exists in Hive, update it if needed
      else {
        var updatedCategSpecialPrice = CustomerCategSpecialPrice(
          cmpCode: doc['cmpCode'],
          custCode: doc['custCode'],
          categCode: doc['categCode'],
          disc: doc['disc'],
          notes: doc['notes'],
        );
        // Update the categ special price in Hive
        await categSpecialPrice.put('$cmpCode$custCode$categCode', updatedCategSpecialPrice);
      }
    }
        Set<String> firestoreCategSpecialPriceKeys = Set.from(firestoreCategSpecialPrice.map((doc) => '${doc['cmpCode']}${doc['custCode']}${doc['categCode']}'));
    Set<String> hiveCategSpecialPriceKeys = Set.from(categSpecialPrice.keys);

    // Identify categ special prices in Hive that don't exist in Firestore
    Set<String> categSpecialPricesToDelete = hiveCategSpecialPriceKeys.difference(firestoreCategSpecialPriceKeys);

    // Delete categ special prices in Hive that don't exist in Firestore
    categSpecialPricesToDelete.forEach((hiveCategSpecialPriceKey) {
      categSpecialPrice.delete(hiveCategSpecialPriceKey);
    });

  } catch (e) {
    print('Error synchronizing CustomerCategSpecialPrice from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------


Future<void> synchronizeCustomerGroupItemsSpecialPrice() async {
  try {
    // Fetch data from Firestore
    var firestoreGroupItemsSpecialPrice =
        await FirebaseFirestore.instance.collection('CustomerGroupItemsSpecialPrice').get();

    // Open Hive box
    var groupItemsSpecialPriceBox =
        await Hive.openBox<CustomerGroupItemsSpecialPrice>('customerGroupItemsSpecialPriceBox');

    // Synchronize data
    await _synchronizeCustomerGroupItemsSpecialPrice(
        firestoreGroupItemsSpecialPrice.docs, groupItemsSpecialPriceBox);

    
  } catch (e) {
    print('Error synchronizing data from Firebase to Hive for CustomerGroupItemsSpecialPrice: $e');
  }
}

Future<void> _synchronizeCustomerGroupItemsSpecialPrice(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreGroupItemsSpecialPrice,
  Box<CustomerGroupItemsSpecialPrice> groupItemsSpecialPrice,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreGroupItemsSpecialPrice) {
      var itemCode = doc['itemCode'];
      var cmpCode = doc['cmpCode'];
      var custGroupCode = doc['custGroupCode'];
      var uom = doc['uom'];
print(doc.data());
      // Check if the group item special price exists in Hive
      var hiveGroupItemSpecialPrice = groupItemsSpecialPrice.get('$cmpCode$custGroupCode$itemCode$uom');

      // If the group item special price doesn't exist in Hive, add it
      if (hiveGroupItemSpecialPrice == null) {
        var newGroupItemSpecialPrice = CustomerGroupItemsSpecialPrice(
          cmpCode: doc['cmpCode'],
          custGroupCode: doc['custGroupCode'],
          itemCode: doc['itemCode'],
          uom: doc['uom'],
          basePrice: doc['basePrice'],
          currency: doc['currency'],
          auto: doc['auto'],
          disc: doc['disc'],
          price: doc['price'],
          notes: doc['notes'],
        );
        await groupItemsSpecialPrice.put('$cmpCode$custGroupCode$itemCode$uom', newGroupItemSpecialPrice);
      }
      // If the group item special price exists in Hive, update it if needed
      else {
        var updatedGroupItemSpecialPrice = CustomerGroupItemsSpecialPrice(
          cmpCode: doc['cmpCode'],
          custGroupCode: doc['custGroupCode'],
          itemCode: doc['itemCode'],
          uom: doc['uom'],
          basePrice: doc['basePrice'],
          currency: doc['currency'],
          auto: doc['auto'],
          disc: doc['disc'],
          price: doc['price'],
          notes: doc['notes'],
        );
        // Update the group item special price in Hive
        await groupItemsSpecialPrice.put('$cmpCode$custGroupCode$itemCode$uom', updatedGroupItemSpecialPrice);
      }
    }
    Set<String> firestoreGroupItemsSpecialPriceKeys = Set.from(firestoreGroupItemsSpecialPrice.map((doc) => '${doc['cmpCode']}${doc['custGroupCode']}${doc['itemCode']}${doc['uom']}'));
    Set<String> hiveGroupItemsSpecialPriceKeys = Set.from(groupItemsSpecialPrice.keys);

    // Identify group item special prices in Hive that don't exist in Firestore
    Set<String> groupItemsSpecialPricesToDelete = hiveGroupItemsSpecialPriceKeys.difference(firestoreGroupItemsSpecialPriceKeys);

    // Delete group item special prices in Hive that don't exist in Firestore
    groupItemsSpecialPricesToDelete.forEach((hiveGroupItemSpecialPriceKey) {
      groupItemsSpecialPrice.delete(hiveGroupItemSpecialPriceKey);
    });
  } catch (e) {
    print('Error synchronizing CustomerGroupItemsSpecialPrice from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<void> synchronizeCustomerGroupBrandSpecialPrice() async {
  try {
    // Fetch data from Firestore
    var firestoreGroupBrandSpecialPrice =
        await FirebaseFirestore.instance.collection('CustomerGroupBrandSpecialPrice').get();

    // Open Hive box
    var groupBrandSpecialPriceBox =
        await Hive.openBox<CustomerGroupBrandSpecialPrice>('customerGroupBrandSpecialPriceBox');

    // Synchronize data
    await _synchronizeCustomerGroupBrandSpecialPrice(
        firestoreGroupBrandSpecialPrice.docs, groupBrandSpecialPriceBox);


  } catch (e) {
    print('Error synchronizing data from Firebase to Hive for CustomerGroupBrandSpecialPrice: $e');
  }
}

Future<void> _synchronizeCustomerGroupBrandSpecialPrice(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreGroupBrandSpecialPrice,
  Box<CustomerGroupBrandSpecialPrice> groupBrandSpecialPrice,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreGroupBrandSpecialPrice) {
      var brandCode = doc['brandCode'];
   var cmpCode = doc['cmpCode'];
      var custGroupCode = doc['custGroupCode'];

      // Check if the group brand special price exists in Hive
      var hiveGroupBrandSpecialPrice = groupBrandSpecialPrice.get('$cmpCode$custGroupCode$brandCode');

      // If the group brand special price doesn't exist in Hive, add it
      if (hiveGroupBrandSpecialPrice == null) {
        var newGroupBrandSpecialPrice = CustomerGroupBrandSpecialPrice(
          cmpCode: doc['cmpCode'],
          custGroupCode: doc['custGroupCode'],
          brandCode: doc['brandCode'],
          disc: doc['disc'],
          notes: doc['notes'],
        );
        await groupBrandSpecialPrice.put('$cmpCode$custGroupCode$brandCode', newGroupBrandSpecialPrice);
      }
      // If the group brand special price exists in Hive, update it if needed
      else {
        var updatedGroupBrandSpecialPrice = CustomerGroupBrandSpecialPrice(
          cmpCode: doc['cmpCode'],
          custGroupCode: doc['custGroupCode'],
          brandCode: doc['brandCode'],
          disc: doc['disc'],
          notes: doc['notes'],
        );
        // Update the group brand special price in Hive
        await groupBrandSpecialPrice.put('$cmpCode$custGroupCode$brandCode', updatedGroupBrandSpecialPrice);
      }
    }
    Set<String> firestoreGroupBrandSpecialPriceKeys = Set.from(firestoreGroupBrandSpecialPrice.map((doc) => '${doc['cmpCode']}${doc['custGroupCode']}${doc['brandCode']}'));
    Set<String> hiveGroupBrandSpecialPriceKeys = Set.from(groupBrandSpecialPrice.keys);

    // Identify group brand special prices in Hive that don't exist in Firestore
    Set<String> groupBrandSpecialPricesToDelete = hiveGroupBrandSpecialPriceKeys.difference(firestoreGroupBrandSpecialPriceKeys);

    // Delete group brand special prices in Hive that don't exist in Firestore
    groupBrandSpecialPricesToDelete.forEach((hiveGroupBrandSpecialPriceKey) {
      groupBrandSpecialPrice.delete(hiveGroupBrandSpecialPriceKey);
    });
  } catch (e) {
    print('Error synchronizing CustomerGroupBrandSpecialPrice from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------


Future<void> synchronizeCustomerGroupGroupSpecialPrice() async {
  try {
    // Fetch data from Firestore
    var firestoreGroupGroupSpecialPrice =
        await FirebaseFirestore.instance.collection('CustomerGroupGroupSpecialPrice').get();

    // Open Hive box
    var groupGroupSpecialPriceBox =
        await Hive.openBox<CustomerGroupGroupSpecialPrice>('customerGroupGroupSpecialPriceBox');

    // Synchronize data
    await _synchronizeCustomerGroupGroupSpecialPrice(
        firestoreGroupGroupSpecialPrice.docs, groupGroupSpecialPriceBox);

  } catch (e) {
    print(
        'Error synchronizing data from Firebase to Hive for CustomerGroupGroupSpecialPrice: $e');
  }
}

Future<void> _synchronizeCustomerGroupGroupSpecialPrice(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreGroupGroupSpecialPrice,
  Box<CustomerGroupGroupSpecialPrice> groupGroupSpecialPrice,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreGroupGroupSpecialPrice) {
      var groupCode = doc['groupCode'];
      var cmpCode = doc['cmpCode'];
      var custGroupCode = doc['custGroupCode'];
      // Check if the group group special price exists in Hive
      var hiveGroupGroupSpecialPrice = groupGroupSpecialPrice.get('$cmpCode$custGroupCode$groupCode');

      // If the group group special price doesn't exist in Hive, add it
      if (hiveGroupGroupSpecialPrice == null) {
        var newGroupGroupSpecialPrice = CustomerGroupGroupSpecialPrice(
          cmpCode: doc['cmpCode'],
          custGroupCode: doc['custGroupCode'],
          groupCode: doc['groupCode'],
          disc: doc['disc'],
          notes: doc['notes'],
        );
        await groupGroupSpecialPrice.put('$cmpCode$custGroupCode$groupCode', newGroupGroupSpecialPrice);
      }
      // If the group group special price exists in Hive, update it if needed
      else {
        var updatedGroupGroupSpecialPrice = CustomerGroupGroupSpecialPrice(
          cmpCode: doc['cmpCode'],
          custGroupCode: doc['custGroupCode'],
          groupCode: doc['groupCode'],
          disc: doc['disc'],
          notes: doc['notes'],
        );
        // Update the group group special price in Hive
        await groupGroupSpecialPrice.put('$cmpCode$custGroupCode$groupCode', updatedGroupGroupSpecialPrice);
      }
    }
    Set<String> firestoreGroupGroupSpecialPriceKeys = Set.from(firestoreGroupGroupSpecialPrice.map((doc) => '${doc['cmpCode']}${doc['custGroupCode']}${doc['groupCode']}'));
    Set<String> hiveGroupGroupSpecialPriceKeys = Set.from(groupGroupSpecialPrice.keys);

    // Identify group group special prices in Hive that don't exist in Firestore
    Set<String> groupGroupSpecialPricesToDelete = hiveGroupGroupSpecialPriceKeys.difference(firestoreGroupGroupSpecialPriceKeys);

    // Delete group group special prices in Hive that don't exist in Firestore
    groupGroupSpecialPricesToDelete.forEach((hiveGroupGroupSpecialPriceKey) {
      groupGroupSpecialPrice.delete(hiveGroupGroupSpecialPriceKey);
    });
  } catch (e) {
    print('Error synchronizing CustomerGroupGroupSpecialPrice from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

Future<void> synchronizeCustomerGroupCategSpecialPrice() async {
  try {
    // Fetch data from Firestore
    var firestoreGroupCategSpecialPrice =
        await FirebaseFirestore.instance.collection('CustomerGroupCategSpecialPrice').get();

    // Open Hive box
    var groupCategSpecialPriceBox =
        await Hive.openBox<CustomerGroupCategSpecialPrice>('customerGroupCategSpecialPriceBox');

    // Synchronize data
    await _synchronizeCustomerGroupCategSpecialPrice(
        firestoreGroupCategSpecialPrice.docs, groupCategSpecialPriceBox);


  } catch (e) {
    print(
        'Error synchronizing data from Firebase to Hive for CustomerGroupCategSpecialPrice: $e');
  }
}

Future<void> _synchronizeCustomerGroupCategSpecialPrice(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreGroupCategSpecialPrice,
  Box<CustomerGroupCategSpecialPrice> groupCategSpecialPrice,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreGroupCategSpecialPrice) {
      var categCode = doc['categCode'];
     var cmpCode = doc['cmpCode'];
      var custGroupCode = doc['custGroupCode'];

      // Check if the group categ special price exists in Hive
      var hiveGroupCategSpecialPrice = groupCategSpecialPrice.get('$cmpCode$custGroupCode$categCode');

      // If the group categ special price doesn't exist in Hive, add it
      if (hiveGroupCategSpecialPrice == null) {
        var newGroupCategSpecialPrice = CustomerGroupCategSpecialPrice(
          cmpCode: doc['cmpCode'],
          custGroupCode: doc['custGroupCode'],
          categCode: doc['categCode'],
          disc: doc['disc'],
          notes: doc['notes'],
        );
        await groupCategSpecialPrice.put('$cmpCode$custGroupCode$categCode', newGroupCategSpecialPrice);
      }
      // If the group categ special price exists in Hive, update it if needed
      else {
        var updatedGroupCategSpecialPrice = CustomerGroupCategSpecialPrice(
          cmpCode: doc['cmpCode'],
          custGroupCode: doc['custGroupCode'],
          categCode: doc['categCode'],
          disc: doc['disc'],
          notes: doc['notes'],
        );
        // Update the group categ special price in Hive
        await groupCategSpecialPrice.put('$cmpCode$custGroupCode$categCode', updatedGroupCategSpecialPrice);
      }
    }
   Set<String> firestoreGroupCategSpecialPriceKeys = Set.from(firestoreGroupCategSpecialPrice.map((doc) => '${doc['cmpCode']}${doc['custGroupCode']}${doc['categCode']}'));
    Set<String> hiveGroupCategSpecialPriceKeys = Set.from(groupCategSpecialPrice.keys);

    // Identify group categ special prices in Hive that don't exist in Firestore
    Set<String> groupCategSpecialPricesToDelete = hiveGroupCategSpecialPriceKeys.difference(firestoreGroupCategSpecialPriceKeys);

    // Delete group categ special prices in Hive that don't exist in Firestore
    groupCategSpecialPricesToDelete.forEach((hiveGroupCategSpecialPriceKey) {
      groupCategSpecialPrice.delete(hiveGroupCategSpecialPriceKey);
    });

  } catch (e) {
    print('Error synchronizing CustomerGroupCategSpecialPrice from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------


Future<void> synchronizeCustomerPropItemsSpecialPrice() async {
  try {
    // Fetch data from Firestore
    var firestorePropItemsSpecialPrice =
        await FirebaseFirestore.instance.collection('CustomerPropItemsSpecialPrice').get();

    // Open Hive box
    var propItemsSpecialPriceBox =
        await Hive.openBox<CustomerPropItemsSpecialPrice>('customerPropItemsSpecialPriceBox');

    // Synchronize data
    await _synchronizeCustomerPropItemsSpecialPrice(
        firestorePropItemsSpecialPrice.docs, propItemsSpecialPriceBox);


  } catch (e) {
    print(
        'Error synchronizing data from Firebase to Hive for CustomerPropItemsSpecialPrice: $e');
  }
}

Future<void> _synchronizeCustomerPropItemsSpecialPrice(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestorePropItemsSpecialPrice,
  Box<CustomerPropItemsSpecialPrice> propItemsSpecialPrice,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestorePropItemsSpecialPrice) {
      var itemCode = doc['itemCode'];
        var cmpCode = doc['cmpCode'];
      var custPropCode = doc['custPropCode'];
      var uom = doc['uom'];

      // Check if the prop items special price exists in Hive
      var hivePropItemsSpecialPrice = propItemsSpecialPrice.get('$cmpCode$custPropCode$itemCode$uom');

      // If the prop items special price doesn't exist in Hive, add it
      if (hivePropItemsSpecialPrice == null) {
        var newPropItemsSpecialPrice = CustomerPropItemsSpecialPrice(
          cmpCode: doc['cmpCode'],
          custPropCode: doc['custPropCode'],
          itemCode: doc['itemCode'],
          uom: doc['uom'],
          basePrice: doc['basePrice'],
          currency: doc['currency'],
          auto: doc['auto'],
          disc: doc['disc'],
          price: doc['price'],
          notes: doc['notes'],
        );
        await propItemsSpecialPrice.put('$cmpCode$custPropCode$itemCode$uom', newPropItemsSpecialPrice);
      }
      // If the prop items special price exists in Hive, update it if needed
      else {
        var updatedPropItemsSpecialPrice = CustomerPropItemsSpecialPrice(
          cmpCode: doc['cmpCode'],
          custPropCode: doc['custPropCode'],
          itemCode: doc['itemCode'],
          uom: doc['uom'],
          basePrice: doc['basePrice'],
          currency: doc['currency'],
          auto: doc['auto'],
          disc: doc['disc'],
          price: doc['price'],
          notes: doc['notes'],
        );
        // Update the prop items special price in Hive
        await propItemsSpecialPrice.put('$cmpCode$custPropCode$itemCode$uom', updatedPropItemsSpecialPrice);
      }
    }
    Set<String> firestorePropItemsSpecialPriceKeys = Set.from(firestorePropItemsSpecialPrice.map((doc) => '${doc['cmpCode']}${doc['custPropCode']}${doc['itemCode']}${doc['uom']}'));
    Set<String> hivePropItemsSpecialPriceKeys = Set.from(propItemsSpecialPrice.keys);

    // Identify prop items special prices in Hive that don't exist in Firestore
    Set<String> propItemsSpecialPricesToDelete = hivePropItemsSpecialPriceKeys.difference(firestorePropItemsSpecialPriceKeys);

    // Delete prop items special prices in Hive that don't exist in Firestore
    propItemsSpecialPricesToDelete.forEach((hivePropItemsSpecialPriceKey) {
      propItemsSpecialPrice.delete(hivePropItemsSpecialPriceKey);
    });

  } catch (e) {
    print('Error synchronizing CustomerPropItemsSpecialPrice from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------


Future<void> synchronizeCustomerPropBrandSpecialPrice() async {
  try {
    // Fetch data from Firestore
    var firestorePropBrandSpecialPrice =
        await FirebaseFirestore.instance.collection('CustomerPropBrandSpecialPrice').get();

    // Open Hive box
    var propBrandSpecialPriceBox =
        await Hive.openBox<CustomerPropBrandSpecialPrice>('customerPropBrandSpecialPriceBox');

    // Synchronize data
    await _synchronizeCustomerPropBrandSpecialPrice(
        firestorePropBrandSpecialPrice.docs, propBrandSpecialPriceBox);


  } catch (e) {
    print(
        'Error synchronizing data from Firebase to Hive for CustomerPropBrandSpecialPrice: $e');
  }
}

Future<void> _synchronizeCustomerPropBrandSpecialPrice(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestorePropBrandSpecialPrice,
  Box<CustomerPropBrandSpecialPrice> propBrandSpecialPrice,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestorePropBrandSpecialPrice) {
      var brandCode = doc['brandCode'];
      var cmpCode = doc['cmpCode'];
      var custPropCode= doc['custPropCode'];

      // Check if the prop brand special price exists in Hive
      var hivePropBrandSpecialPrice = propBrandSpecialPrice.get('$cmpCode$custPropCode$brandCode');

      // If the prop brand special price doesn't exist in Hive, add it
      if (hivePropBrandSpecialPrice == null) {
        var newPropBrandSpecialPrice = CustomerPropBrandSpecialPrice(
          cmpCode: doc['cmpCode'],
          custPropCode: doc['custPropCode'],
          brandCode: doc['brandCode'],
          disc: doc['disc'],
          notes: doc['notes'],
        );
        await propBrandSpecialPrice.put('$cmpCode$custPropCode$brandCode', newPropBrandSpecialPrice);
      }
      // If the prop brand special price exists in Hive, update it if needed
      else {
        var updatedPropBrandSpecialPrice = CustomerPropBrandSpecialPrice(
          cmpCode: doc['cmpCode'],
          custPropCode: doc['custPropCode'],
          brandCode: doc['brandCode'],
          disc: doc['disc'],
          notes: doc['notes'],
        );
        // Update the prop brand special price in Hive
        await propBrandSpecialPrice.put('$cmpCode$custPropCode$brandCode', updatedPropBrandSpecialPrice);
      }
    }
        Set<String> firestorePropBrandSpecialPriceKeys = Set.from(firestorePropBrandSpecialPrice.map((doc) => '${doc['cmpCode']}${doc['custPropCode']}${doc['brandCode']}'));
    Set<String> hivePropBrandSpecialPriceKeys = Set.from(propBrandSpecialPrice.keys);

    // Identify prop brand special prices in Hive that don't exist in Firestore
    Set<String> propBrandSpecialPricesToDelete = hivePropBrandSpecialPriceKeys.difference(firestorePropBrandSpecialPriceKeys);

    // Delete prop brand special prices in Hive that don't exist in Firestore
    propBrandSpecialPricesToDelete.forEach((hivePropBrandSpecialPriceKey) {
      propBrandSpecialPrice.delete(hivePropBrandSpecialPriceKey);
    });

  } catch (e) {
    print('Error synchronizing CustomerPropBrandSpecialPrice from Firebase to Hive: $e');
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------


Future<void> synchronizeCustomerPropGroupSpecialPrice() async {
  try {
    // Fetch data from Firestore
    var firestorePropGroupSpecialPrice =
        await FirebaseFirestore.instance.collection('CustomerPropGroupSpecialPrice').get();

    // Open Hive box
    var propGroupSpecialPriceBox =
        await Hive.openBox<CustomerPropGroupSpecialPrice>('customerPropGroupSpecialPriceBox');

    // Synchronize data
    await _synchronizeCustomerPropGroupSpecialPrice(
        firestorePropGroupSpecialPrice.docs, propGroupSpecialPriceBox);


  } catch (e) {
    print(
        'Error synchronizing data from Firebase to Hive for CustomerPropGroupSpecialPrice: $e');
  }
}

Future<void> _synchronizeCustomerPropGroupSpecialPrice(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestorePropGroupSpecialPrice,
  Box<CustomerPropGroupSpecialPrice> propGroupSpecialPrice,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestorePropGroupSpecialPrice) {
      var propCode = doc['propCode'];
      var cmpCode = doc['cmpCode'];
      var custGroupCode= doc['custGroupCode'];

      // Check if the prop group special price exists in Hive
      var hivePropGroupSpecialPrice = propGroupSpecialPrice.get('$cmpCode$custGroupCode$propCode');

      // If the prop group special price doesn't exist in Hive, add it
      if (hivePropGroupSpecialPrice == null) {
        var newPropGroupSpecialPrice = CustomerPropGroupSpecialPrice(
          cmpCode: doc['cmpCode'],
          custGroupCode: doc['custGroupCode'],
          propCode: doc['propCode'],
          disc: doc['disc'],
          notes: doc['notes'],
        );
        await propGroupSpecialPrice.put('$cmpCode$custGroupCode$propCode', newPropGroupSpecialPrice);
      }
      // If the prop group special price exists in Hive, update it if needed
      else {
        var updatedPropGroupSpecialPrice = CustomerPropGroupSpecialPrice(
          cmpCode: doc['cmpCode'],
          custGroupCode: doc['custGroupCode'],
          propCode: doc['propCode'],
          disc: doc['disc'],
          notes: doc['notes'],
        );
        // Update the prop group special price in Hive
        await propGroupSpecialPrice.put('$cmpCode$custGroupCode$propCode', updatedPropGroupSpecialPrice);
      }
    }
    Set<String> firestorePropGroupSpecialPriceKeys = Set.from(firestorePropGroupSpecialPrice.map((doc) => '${doc['cmpCode']}${doc['custGroupCode']}${doc['propCode']}'));
    Set<String> hivePropGroupSpecialPriceKeys = Set.from(propGroupSpecialPrice.keys);

    // Identify prop group special prices in Hive that don't exist in Firestore
    Set<String> propGroupSpecialPricesToDelete = hivePropGroupSpecialPriceKeys.difference(firestorePropGroupSpecialPriceKeys);

    // Delete prop group special prices in Hive that don't exist in Firestore
    propGroupSpecialPricesToDelete.forEach((hivePropGroupSpecialPriceKey) {
      propGroupSpecialPrice.delete(hivePropGroupSpecialPriceKey);
    });

  } catch (e) {
    print('Error synchronizing CustomerPropGroupSpecialPrice from Firebase to Hive: $e');
  }
}


//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------


Future<void> synchronizeCustomerPropCategSpecialPrice() async {
  try {
    // Fetch data from Firestore
    var firestorePropCategSpecialPrice =
        await FirebaseFirestore.instance.collection('CustomerPropCategSpecialPrice').get();

    // Open Hive box
    var propCategSpecialPriceBox =
        await Hive.openBox<CustomerPropCategSpecialPrice>('customerPropCategSpecialPriceBox');

    // Synchronize data
    await _synchronizeCustomerPropCategSpecialPrice(
        firestorePropCategSpecialPrice.docs, propCategSpecialPriceBox);

   
  } catch (e) {
    print(
        'Error synchronizing data from Firebase to Hive for CustomerPropCategSpecialPrice: $e');
  }
}

Future<void> _synchronizeCustomerPropCategSpecialPrice(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestorePropCategSpecialPrice,
  Box<CustomerPropCategSpecialPrice> propCategSpecialPrice,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestorePropCategSpecialPrice) {
      var categCode = doc['categCode'];
      var cmpCode = doc['cmpCode'];
      var custPropCode = doc['custPropCode'];

      // Check if the prop categ special price exists in Hive
      var hivePropCategSpecialPrice = propCategSpecialPrice.get('$cmpCode$custPropCode$categCode');

      // If the prop categ special price doesn't exist in Hive, add it
      if (hivePropCategSpecialPrice == null) {
        var newPropCategSpecialPrice = CustomerPropCategSpecialPrice(
          cmpCode: doc['cmpCode'],
          custPropCode: doc['custPropCode'],
          categCode: doc['categCode'],
          disc: doc['disc'],
          notes: doc['notes'],
        );
        await propCategSpecialPrice.put('$cmpCode$custPropCode$categCode', newPropCategSpecialPrice);
      }
      // If the prop categ special price exists in Hive, update it if needed
      else {
        var updatedPropCategSpecialPrice = CustomerPropCategSpecialPrice(
          cmpCode: doc['cmpCode'],
          custPropCode: doc['custPropCode'],
          categCode: doc['categCode'],
          disc: doc['disc'],
          notes: doc['notes'],
        );
        // Update the prop categ special price in Hive
        await propCategSpecialPrice.put('$cmpCode$custPropCode$categCode', updatedPropCategSpecialPrice);
      }
    }
  Set<String>  firestorePropCategSpecialPriceKeys = Set.from(firestorePropCategSpecialPrice.map((doc) => '${doc['cmpCode']}${doc['custPropCode']}${doc['categCode']}'));
    Set<String> hivePropCategSpecialPriceKeys = Set.from(propCategSpecialPrice.keys);

    // Identify prop categ special prices in Hive that don't exist in Firestore
    Set<String> propCategSpecialPricesToDelete = hivePropCategSpecialPriceKeys.difference(firestorePropCategSpecialPriceKeys);

    // Delete prop categ special prices in Hive that don't exist in Firestore
    propCategSpecialPricesToDelete.forEach((hivePropCategSpecialPriceKey) {
      propCategSpecialPrice.delete(hivePropCategSpecialPriceKey);
    });

  } catch (e) {
    print('Error synchronizing CustomerPropCategSpecialPrice from Firebase to Hive: $e');
  }
}

}



  // Add similar methods for synchronizing other data if needed

