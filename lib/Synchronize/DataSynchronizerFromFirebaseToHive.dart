import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:project/hive/itembrand_hive.dart';
import 'package:project/hive/itemcateg_hive.dart';
import 'package:project/hive/itemgroup_hive.dart';
import 'package:project/hive/items_hive.dart';
import 'package:project/hive/itemsprices_hive.dart';
import 'package:project/hive/itemattach_hive.dart';
import 'package:project/hive/itemuom_hive.dart';
import 'package:project/hive/menu_hive.dart';
import 'package:project/hive/pricelist_hive.dart';
import 'package:project/hive/translations_hive.dart';
import 'package:project/hive/usergroup_hive.dart';
import 'package:project/hive/userpl_hive.dart';
import 'package:project/hive/hiveuser.dart';
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
        );
        // Update the item in Hive
        await pricelistsBox.put(plCode, updatedPrice);
      }
    }

    // Check for items in Hive that don't exist in Firestore and delete them
    pricelistsBox.keys.toList().forEach((hivePriceCode) {
        if (!firestorePriceLists.any((doc) => doc['plCode'] == hivePriceCode)) {
          // Item exists in Hive but not in Firestore, so delete it from Hive
          pricelistsBox.delete(hivePriceCode);
        }
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
      // Check if the item exists in Hive
      var hivePriceItem = itempriceBox.get(plCode);

      // If the item doesn't exist in Hive, add it
      if (hivePriceItem == null) {
        var newPriceItem= ItemsPrices(
          doc['plCode'],
          doc['itemCode'],
          doc['uom'],
          doc['basePrice'].toDouble(),
          doc['currency'],
          doc['auto'],
          doc['disc'].toDouble(),
          doc['price'].toDouble(),
        );
        await itempriceBox.put(plCode, newPriceItem);
      }
      // If the item exists in Hive, update it if needed
      else {
        var updatedPriceItem = ItemsPrices(
          doc['plCode'],
          doc['itemCode'],
          doc['uom'],
          doc['basePrice'].toDouble(),
          doc['currency'],
          doc['auto'],
          doc['disc'].toDouble(),
          doc['price'].toDouble(),
        );
        // Update the item in Hive
        await itempriceBox.put(plCode, updatedPriceItem);
      }
    }

    // Check for items in Hive that don't exist in Firestore and delete them
    itempriceBox.keys.toList().forEach((hivePriceItemCode) {
        if (!firestoreItemPrice.any((doc) => doc['plCode'] == hivePriceItemCode)) {
          // Item exists in Hive but not in Firestore, so delete it from Hive
          itempriceBox.delete(hivePriceItemCode);
        }
      });

  } catch (e) {
    print('Error synchronizing PricesList from Firebase to Hive: $e');
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
        );
        // Update the item in Hive
        await itemattachBox.put(itemCode, updatedAttachItem);
      }
    }

    // Check for items in Hive that don't exist in Firestore and delete them
    itemattachBox.keys.toList().forEach((hiveAttachItemCode) {
        if (!firestoreItemAttach.any((doc) => doc['itemCode'] == hiveAttachItemCode)) {
          // Item exists in Hive but not in Firestore, so delete it from Hive
          itemattachBox.delete(hiveAttachItemCode);
        }
      });

  } catch (e) {
    print('Error synchronizing PricesList from Firebase to Hive: $e');
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
        
          
        );
        await itemgroupBox.put(groupCode, newGroupItem);
      }
      // If the item exists in Hive, update it if needed
      else {
        var updatedGroupItem = ItemGroup(
         doc['groupCode'],
         doc['groupName'],
          doc['groupFName'],
        );
        // Update the item in Hive
        await itemgroupBox.put(groupCode, updatedGroupItem);
      }
    }

    // Check for items in Hive that don't exist in Firestore and delete them
    itemgroupBox.keys.toList().forEach((hiveGroupItemCode) {
        if (!firestoreItemGroup.any((doc) => doc['groupCode'] == hiveGroupItemCode)) {
          // Item exists in Hive but not in Firestore, so delete it from Hive
          itemgroupBox.delete(hiveGroupItemCode);
        }
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
        
          
        );
        await itemcategBox.put(categCode, newCategItem);
      }
      // If the item exists in Hive, update it if needed
      else {
        var updatedCategItem = ItemCateg(
          doc['categCode'],
          doc['categName'],
          doc['categFName'],
        );
        // Update the item in Hive
        await itemcategBox.put(categCode, updatedCategItem);
      }
    }

    // Check for items in Hive that don't exist in Firestore and delete them
    itemcategBox.keys.toList().forEach((hiveGroupCategCode) {
        if (!firestoreItemCateg.any((doc) => doc['categCode'] == hiveGroupCategCode)) {
          // Item exists in Hive but not in Firestore, so delete it from Hive
          itemcategBox.delete(hiveGroupCategCode);
        }
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
        
          
        );
        await itembrandBox.put(brandCode, newBrandItem);
      }
      // If the item exists in Hive, update it if needed
      else {
        var updatedBrandItem = ItemBrand(
         doc['brandCode'],
          doc['brandName'],
          doc['brandFName'],
        
        );
        // Update the item in Hive
        await itembrandBox.put(brandCode, updatedBrandItem);
      }
    }

    // Check for items in Hive that don't exist in Firestore and delete them
    itembrandBox.keys.toList().forEach((hiveGroupBrandCode) {
        if (!firestoreItemBrand.any((doc) => doc['brandCode'] == hiveGroupBrandCode)) {
          // Item exists in Hive but not in Firestore, so delete it from Hive
          itembrandBox.delete(hiveGroupBrandCode);
        }
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
        );
        // Update the item in Hive
        await itemuomBox.put(itemCode, updatedUOMItem);
      }
    }

    // Check for items in Hive that don't exist in Firestore and delete them
    itemuomBox.keys.toList().forEach((hiveGroupUOMCode) {
        if (!firestoreItemUOM.any((doc) => doc['itemCode'] == hiveGroupUOMCode)) {
          // Item exists in Hive but not in Firestore, so delete it from Hive
          itemuomBox.delete(hiveGroupUOMCode);
        }
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
    userplBox.keys.toList().forEach((hiveGroupUserPL) {
        if (!firestoreUserPL.any((doc) => doc['userCode'] == hiveGroupUserPL)) {
          // Item exists in Hive but not in Firestore, so delete it from Hive
          userplBox.delete(hiveGroupUserPL);
        }
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
    // Iterate over Firestore documents
    for (var doc in firestoreUsers) {
      var email = doc['email'];
      print(email);
      var hiveuser = userBox.get(email);
      print(hiveuser.toString());

      // If the item doesn't exist in Hive, add it
      if (hiveuser == null) {
        print('isnull');
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;

        await userBox.put(email, userData);
      }
      // If the item exists in Hive, update it if needed
      else {
        print('guhhi');
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;

        await userBox.put(email, userData);
      }
    }
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
    // Open other boxes if needed

    print('All data in group database: ${menuBox.values.toList()}');


    // Synchronize data
    await _synchronizeMenu(firestoreItems.docs, menuBox);
    // Synchronize other data if needed

    // Close Hive boxes
    //await userGroupBox.close();
    // Close other boxes if needed
  } catch (e) {
    print('Error synchronizing data from Firebase to Hive: $e');
  }
}

Future<void> _synchronizeMenu(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> firestoreUsersGroup,
  Box<Menu> menuGroup,
) async {
  try {
    // Iterate over Firestore documents
    for (var doc in firestoreUsersGroup) {
      var menucode = doc['menucode'];
      // Check if the item exists in Hive
      var hivemenugroup = menuGroup.get(menucode);

      // If the item doesn't exist in Hive, add it
      if (hivemenugroup == null) {
        var newMenuGroup = Menu(
          menucode: doc['menucode'],
          menuname: doc['menuname'],
        );
        await menuGroup.put(menucode, newMenuGroup);
      }
      // If the item exists in Hive, update it if needed
      else {
        var updatedmenugroup = Menu(
        menucode: doc['menucode'],
          menuname: doc['menuname'],
        );
        // Update the item in Hive
        await menuGroup.put(menucode, updatedmenugroup);
      }
    }
  } catch (e) {
    print('Error synchronizing Users from Firebase to Hive: $e');
  }
}



}



  // Add similar methods for synchronizing other data if needed

