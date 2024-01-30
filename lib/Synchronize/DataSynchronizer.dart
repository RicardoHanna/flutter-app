import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:project/hive/authorization_hive.dart';
import 'package:project/hive/companies_hive.dart';
import 'package:project/hive/companiesconnection_hive.dart';
import 'package:project/hive/companiesusers_hive.dart';
import 'package:project/hive/hiveuser.dart';
import 'package:project/hive/items_hive.dart';
import 'package:project/hive/pricelistauthorization_hive.dart';
import 'package:project/hive/systemadmin_hive.dart';
import 'package:project/hive/translations_hive.dart';
import 'package:project/hive/usergroup_hive.dart'; // Replace with your actual Hive user class

class DataSynchronizer {

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
   late Box userBox;
  Future<void> synchronizeData() async {
    try {
      // Fetch data from Hive
       userBox = await Hive.openBox('userBox');
      List<String> users = userBox.keys.cast<String>().toList();

      var userGroupBox = await Hive.openBox<UserGroup>('userGroupBox');
      List<UserGroup> usersGroup = userGroupBox.values.toList();

      var translationsBox = await Hive.openBox<Translations>('translationsBox');
      List<Translations> translations = translationsBox.values.toList();

    var authorizationBox = await Hive.openBox<Authorization>('authorizationBox');
      List<Authorization> authorization = authorizationBox.values.toList();

          var systemAdminBox = await Hive.openBox<SystemAdmin>('systemAdminBox');
      List<SystemAdmin> systemadmin = systemAdminBox.values.toList();

          var companiesConnectionBox = await Hive.openBox<CompaniesConnection>('companiesConnectionBox');
      List<CompaniesConnection> companyadmin = companiesConnectionBox.values.toList();

      var companiesusersBox = await Hive.openBox<CompaniesUsers>('companiesUsersBox');
      List<CompaniesUsers> companyusers = companiesusersBox.values.toList();


      var pricelistauthoBox = await Hive.openBox<PriceListAuthorization>('pricelistAuthorizationBox');
      List<PriceListAuthorization> pricelistautho = pricelistauthoBox.values.toList();

      // Check for an internet connection
      if (await hasInternetConnection()) {
        // If there's an internet connection, update or add data to Firestore
        await _updateFirestoreUsers(users);
        await _updateFirestoreUserGroup(usersGroup);
        await _updateFirestoreTranslations(translations);
        await _updateFirestoreAuthorization(authorization);
        await _updateFirestoreSystemAdmin(systemadmin);
        await _updateFirestoreCompaniesConnection(companyadmin);
        await _updateFirestoreCompaniesUsers(companyusers);
         await _updateFirestorePriceListAutho(pricelistautho);
        // Update or add other data to Firestore if needed

      }
    } catch (e) {
      print('Error synchronizing data: $e');
    }
  }
Future<void> _updateFirestoreUsers(List<String> users) async {
  try {
    // Fetch documents from Firestore
    QuerySnapshot<Map<String, dynamic>> firestoreUsers =
        await _firestore.collection('Users').get();

    // Get a list of user emails in Firestore
    List<String> firestoreUserEmails =
        firestoreUsers.docs.map((doc) => doc['usercode'] as String).toList();

    // Identify users that need to be added or updated in Firestore
    List<String> usersToAddOrUpdate =
        users.where((userEmail) => !firestoreUserEmails.contains(userEmail)).toList();

    // Identify users in Firestore that need to be deleted
    List<String> usersToDelete =
        firestoreUserEmails.where((userEmail) => !users.contains(userEmail)).toList();

    // Delete users that exist in Firestore but not in Hive
    for (String userCodeToDelete in usersToDelete) {
      QuerySnapshot<Map<String, dynamic>> userToDeleteSnapshot = await _firestore
          .collection('Users')
          .where('usercode', isEqualTo: userCodeToDelete)
          .get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in userToDeleteSnapshot.docs) {
        await _firestore.collection('Users').doc(doc.id).delete();
        print('User deleted: $userCodeToDelete');
      }
    }

    // Loop through each user to update or add to Firestore
    for (String userCodeToAddOrUpdate in usersToAddOrUpdate) {
      var userDataDynamic = userBox.get(userCodeToAddOrUpdate);
      Map<String, dynamic>? userData =
          userDataDynamic is Map ? Map<String, dynamic>.from(userDataDynamic) : null;

      try {
        // Check if the user already exists in Firestore
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
            .collection('Users')
            .where('usercode', isEqualTo: userData?['usercode'])
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Update the existing user in Firestore
          String documentId = querySnapshot.docs[0].id;
          await _firestore.collection('Users').doc(documentId).update(
            {
              'usercode': userData?['usercode'],
              'username': userData?['username'],
              'userFname': userData?['userFname'],
              'email': userData?['email'],
              'password': userData?['password'],
              'phonenumber': userData?['phonenumber'],
              'imeicode': userData?['imeicode'],
              'warehouse': userData?['warehouse'],
              'active': userData?['active'],
              'imageLink': userData?['imageLink'],
              'usergroup': userData?['usergroup'],
              'languages': userData?['languages'],
              'font': userData?['font'],
            },
          );
          print('User updated: ${userData?['email']}');
        } else {
          // Add the user to Firestore if it doesn't exist
          await _firestore.collection('Users').add(
            {
              'usercode': userData?['usercode'],
              'username': userData?['username'],
              'userFname': userData?['userFname'],
              'email': userData?['email'],
              'password': userData?['password'],
              'phonenumber': userData?['phonenumber'],
              'imeicode': userData?['imeicode'],
              'warehouse': userData?['warehouse'],
              'active': userData?['active'],
              'imageLink': userData?['imageLink'],
              'usergroup': userData?['usergroup'],
              'languages': userData?['languages'],
              'font': userData?['font'],
            },
          );
          print('User added: ${userData?['email']}');
        }
      } catch (e) {
        print('Error updating Firestore user: $e');
      }
    }
  } catch (e) {
    print('Error updating/deleting Firestore users: $e');
  }
}


 Future<void> _updateFirestoreUserGroup(List<UserGroup> usersGroup) async {
  try {
    // Loop through each UserGroup object and update or add to Firestore
    for (UserGroup usergroup in usersGroup) {
      try {
        // Check if the usergroup already exists in Firestore
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
            .collection('usergroup')
            .where('groupcode', isEqualTo: usergroup.groupcode)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // UserGroup already exists, check for updates
          String documentId = querySnapshot.docs[0].id;

          // Fetch existing data from Firestore
          Map<String, dynamic> existingUserGroupData = querySnapshot.docs[0].data()!;

          // Compare existing data with data from Hive
          if (!dataEqualsUserGroup(existingUserGroupData, usergroup)) {
            await _firestore.collection('usergroup').doc(documentId).update(
              {
                'groupcode': usergroup.groupcode,
                'groupname': usergroup.groupname,
              },
            );
            print('UserGroup updated: ${usergroup.groupcode}');
          }
        } else {
          // Add the UserGroup to Firestore if it doesn't exist
          await _firestore.collection('usergroup').add(
            {
              'groupcode': usergroup.groupcode,
              'groupname': usergroup.groupname,
            },
          );
          print('UserGroup added: ${usergroup.groupcode}');
        }
      } catch (e) {
        print('Error updating Firestore UserGroup: $e');
      }
    }
  } catch (e) {
    print('Error updating Firestore UserGroup: $e');
  }
}

// Function to compare UserGroup data equality (customize based on your data structure)
bool dataEqualsUserGroup(
    Map<String, dynamic> existingData, UserGroup newUserGroup) {
  // Compare fields and return true if they are equal, otherwise return false
  // Add conditions for each field you want to compare
  return existingData['groupcode'] == newUserGroup.groupcode &&
      existingData['groupname'] == newUserGroup.groupname;
  // Add additional conditions as needed
}


Future<void> _updateFirestoreTranslations(List<Translations> translations) async {
  try {
    // Loop through each Translations object and update or add to Firestore
    for (Translations translation in translations) {
      try {
        // Check if the translation already exists in Firestore
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
            .collection('Translations')
            .where('groupcode', isEqualTo: translation.groupcode)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Translation already exists, check for updates
          String documentId = querySnapshot.docs[0].id;

          // Fetch existing data from Firestore
          Map<String, dynamic> existingTranslationData = querySnapshot.docs[0].data()!;

          // Compare existing data with data from Hive
          if (!dataEqualsTranslations(existingTranslationData, translation)) {
            await _firestore.collection('Translations').doc(documentId).update(
              {
                'groupcode': translation.groupcode,
                'translations': {
                  'en': translation.translations['en'],
                  'ar': translation.translations['ar'],
                },
              },
            );
            print('Translations updated: ${translation.groupcode}');
          }
        } else {
          // Add the Translation to Firestore if it doesn't exist
          await _firestore.collection('Translations').add(
            {
              'groupcode': translation.groupcode,
              'translations': {
                'en': translation.translations['en'],
                'ar': translation.translations['ar'],
              },
            },
          );
          print('Translations added: ${translation.groupcode}');
        }
      } catch (e) {
        print('Error updating Firestore Translations: $e');
      }
    }
  } catch (e) {
    print('Error updating Firestore Translations: $e');
  }
}

// Function to compare Translations data equality (customize based on your data structure)
bool dataEqualsTranslations(
    Map<String, dynamic> existingData, Translations newTranslation) {
  // Compare fields and return true if they are equal, otherwise return false
  // Add conditions for each field you want to compare
  return existingData['groupcode'] == newTranslation.groupcode &&
      existingData['translations']['en'] == newTranslation.translations['en'] &&
      existingData['translations']['ar'] == newTranslation.translations['ar'];
  // Add additional conditions as needed
}


Future<void> _updateFirestoreAuthorization(List<Authorization> authorizations) async {
  try {
    // Fetch existing authorizations from Firestore
    QuerySnapshot<Map<String, dynamic>> allAuthorizationsSnapshot =
        await _firestore.collection('Authorization').get();

    // Extract existing group codes and menu codes from Firestore
    List<int> existingGroupCodes =
        allAuthorizationsSnapshot.docs.map((doc) => doc['groupcode'] as int).toList();
    List<int> existingMenuCodes =
        allAuthorizationsSnapshot.docs.map((doc) => doc['menucode'] as int).toList();

    // Loop through each authorization and update or add to Firestore
    for (Authorization authorization in authorizations) {
      try {
        // Check if the authorization already exists in Firestore
        bool authorizationExists =
            existingGroupCodes.contains(authorization.groupcode) &&
            existingMenuCodes.contains(authorization.menucode);

        if (authorizationExists) {
          // Authorization already exists, check for updates
          QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
              .collection('Authorization')
              .where('groupcode', isEqualTo: authorization.groupcode)
              .where('menucode', isEqualTo: authorization.menucode)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            String documentId = querySnapshot.docs[0].id;

            // Check if there are changes before updating
            Map<String, dynamic> existingAuthorizationData = querySnapshot.docs[0].data()!;

            // Compare existing data with data from Hive
            if (!dataEquals(existingAuthorizationData, authorization)) {
              await _firestore.collection('Authorization').doc(documentId).update(
                {
                  'groupcode': authorization.groupcode,
                  'menucode': authorization.menucode,
                  // Update other fields if needed
                },
              );
              print('Authorization updated: ${authorization.groupcode}, ${authorization.menucode}');
            }
          }
        } else {
          // Add the authorization to Firestore if it doesn't exist
          await _firestore.collection('Authorization').add(
            {
              'groupcode': authorization.groupcode,
              'menucode': authorization.menucode,
              // Add other fields if needed
            },
          );
          print('Authorization added: ${authorization.groupcode}, ${authorization.menucode}');
        }
      } catch (e) {
        print('Error updating Firestore authorization: $e');
      }
    }

    // Delete authorizations in Firestore that don't exist in Hive
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in allAuthorizationsSnapshot.docs) {
      int groupCode = doc['groupcode'] as int;
      int menuCode = doc['menucode'] as int;

      // Check if the authorization exists in the Hive list
      bool authorizationExistsInHive = authorizations
          .any((auth) => auth.groupcode == groupCode && auth.menucode == menuCode);

      if (!authorizationExistsInHive) {
        // Authorization doesn't exist in Hive, delete it from Firestore
        await _firestore.collection('Authorization').doc(doc.id).delete();
        print('Authorization deleted: $groupCode, $menuCode');
      }
    }
  } catch (e) {
    print('Error updating/deleting Firestore authorizations: $e');
  }
}

// Function to compare data equality (customize based on your data structure)
bool dataEquals(Map<String, dynamic> existingData, Authorization newData) {
  // Compare fields and return true if they are equal, otherwise return false
  // Add conditions for each field you want to compare
  return existingData['groupcode'] == newData.groupcode &&
      existingData['menucode'] == newData.menucode;
  // Add additional conditions as needed
}



Future<void> _updateFirestoreSystemAdmin(List<SystemAdmin> systemAdmin) async {
  try {
    // Loop through each SystemAdmin and update or add to Firestore
    for (SystemAdmin systemadmin in systemAdmin) {
      try {
        // Check if the SystemAdmin already exists in Firestore
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
            .collection('SystemAdmin')
            .where('groupcode', isEqualTo: systemadmin.groupcode)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // SystemAdmin already exists, check for updates
          String documentId = querySnapshot.docs[0].id;

          // Fetch existing data from Firestore
          Map<String, dynamic> existingSystemAdminData = querySnapshot.docs[0].data()!;

          // Compare existing data with data from Hive
          if (!dataEqualsSystemAdmin(existingSystemAdminData, systemadmin)) {
            await _firestore.collection('SystemAdmin').doc(documentId).update(
              {
                'autoExport': systemadmin.autoExport,

                'groupcode': systemadmin.groupcode,
                'importFromErpToMobile': systemadmin.importFromErpToMobile,
                'importFromBackendToMobile': systemadmin.importFromBackendToMobile,
                // Update other fields if needed
              },
            );
            print('SystemAdmin updated: ${systemadmin.groupcode}');
          }
        } else {
          // Add the SystemAdmin to Firestore if it doesn't exist
          await _firestore.collection('SystemAdmin').add(
            {
              'autoExport': systemadmin.autoExport,
              
              'groupcode': systemadmin.groupcode,
              'importFromErpToMobile': systemadmin.importFromErpToMobile,
              'importFromBackendToMobile': systemadmin.importFromBackendToMobile,
              // Add other fields if needed
            },
          );
          print('SystemAdmin added: ${systemadmin.groupcode}');
        }
      } catch (e) {
        print('Error updating Firestore SystemAdmin: $e');
      }
    }
  } catch (e) {
    print('Error updating Firestore SystemAdmins: $e');
  }
}




Future<void> _updateFirestoreCompaniesConnection(List<CompaniesConnection> companiesConnection) async {
  try {
    // Loop through each SystemAdmin and update or add to Firestore
    for (CompaniesConnection companyConnection in companiesConnection) {
      try {
        // Check if the SystemAdmin already exists in Firestore
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
            .collection('CompaniesConnection')
            .where('connectionID', isEqualTo: companyConnection.connectionID)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // SystemAdmin already exists, check for updates
          String documentId = querySnapshot.docs[0].id;

          // Fetch existing data from Firestore
          Map<String, dynamic> existingSystemAdminData = querySnapshot.docs[0].data()!;

          // Compare existing data with data from Hive
          if (!dataEqualsCompaniesConnection(existingSystemAdminData, companyConnection)) {
            await _firestore.collection('CompaniesConnection').doc(documentId).update(
              {
                'connectionID': companyConnection.connectionID,

                'connDatabase': companyConnection.connDatabase,
                'connServer': companyConnection.connServer,
                 'connUser': companyConnection.connUser,
                 'connPassword':companyConnection.connPassword,
                 'connPort':companyConnection.connPort,
                  'typeDatabase':companyConnection.typeDatabase,
         
                // Update other fields if needed
              },
            );
            print('Companies Connection updated: ${companyConnection.connectionID}');
          }
        } else {
          // Add the SystemAdmin to Firestore if it doesn't exist
          await _firestore.collection('CompaniesConnection').add(
            {
               'connectionID': companyConnection.connectionID,

                'connDatabase': companyConnection.connDatabase,
                'connServer': companyConnection.connServer,
                 'connUser': companyConnection.connUser,
                 'connPassword':companyConnection.connPassword,
                 'connPort':companyConnection.connPort,
                  'typeDatabase':companyConnection.typeDatabase,
              // Add other fields if needed
            },
          );
          print('Companies Connection added: ${companyConnection.connectionID}');
        }
      } catch (e) {
        print('Error updating Firestore Companies Connection: $e');
      }
    }
  } catch (e) {
    print('Error updating Firestore SystemAdmins: $e');
  }
}



Future<void> _updateFirestoreCompaniesUsers(List<CompaniesUsers> companiesusers) async {
  try {
    // Loop through each SystemAdmin and update or add to Firestore
    for (CompaniesUsers companyuser in companiesusers) {
      try {
        // Check if the SystemAdmin already exists in Firestore
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
            .collection('CompaniesUsers')
            .where('cmpCode', isEqualTo: companyuser.cmpCode)
            .where('userCode', isEqualTo: companyuser.userCode)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // SystemAdmin already exists, check for updates
          String documentId = querySnapshot.docs[0].id;

          // Fetch existing data from Firestore
          Map<String, dynamic> existingSystemAdminData = querySnapshot.docs[0].data()!;

          // Compare existing data with data from Hive
          if (!dataEqualsCompaniesUsers(existingSystemAdminData, companyuser)) {
            await _firestore.collection('CompaniesConnection').doc(documentId).update(
              {
                 
                 'userCode':companyuser.userCode,
                'cmpCode':companyuser.cmpCode,
                'defaultcmpCode':companyuser.defaultcmpCode
                
             
         
                // Update other fields if needed
              },
            );
            print('Companies Users updated: ${companyuser.cmpCode}');
          }
        } else {
          // Add the SystemAdmin to Firestore if it doesn't exist
          await _firestore.collection('CompaniesConnection').add(
            {

              'userCode':companyuser.userCode,
              'cmpCode':companyuser.cmpCode,
              'defaultcmpCode':companyuser.defaultcmpCode,
                
              // Add other fields if needed
            },
          );
          print('Companies Users Connection added: ${companyuser.cmpCode}');
        }
      } catch (e) {
        print('Error updating Firestore Companies Users: $e');
      }
    }
  } catch (e) {
    print('Error updating Firestore Companies Users: $e');
  }
}


Future<void> _updateFirestorePriceListAutho(List<PriceListAuthorization> pricelistsautho) async {
  try {
    // Loop through each SystemAdmin and update or add to Firestore
    for (PriceListAuthorization pricelistautho in pricelistsautho) {
      try {
        // Check if the SystemAdmin already exists in Firestore
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
            .collection('PriceListAuthorization')
            .where('cmpCode', isEqualTo: pricelistautho.cmpCode)
            .where('userCode', isEqualTo: pricelistautho.userCode)
            .where('authoGroup', isEqualTo: pricelistautho.authoGroup)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // SystemAdmin already exists, check for updates
          String documentId = querySnapshot.docs[0].id;

          // Fetch existing data from Firestore
          Map<String, dynamic> existingSystemAdminData = querySnapshot.docs[0].data()!;

          // Compare existing data with data from Hive
          if (!dataEqualsPriceListAutho(existingSystemAdminData, pricelistautho)) {
            await _firestore.collection('PriceListAuthorization').doc(documentId).update(
              {
                 
                 'userCode':pricelistautho.userCode,
                'cmpCode':pricelistautho.cmpCode,
                'authoGroup':pricelistautho.authoGroup
                
             
         
                // Update other fields if needed
              },
            );
            print('Price List Users updated: ${pricelistautho.authoGroup}');
          }
        } else {
          // Add the SystemAdmin to Firestore if it doesn't exist
          await _firestore.collection('PriceListAuthorization').add(
            {

             'userCode':pricelistautho.userCode,
                'cmpCode':pricelistautho.cmpCode,
                'authoGroup':pricelistautho.authoGroup
                
             
                
              // Add other fields if needed
            },
          );
          print('Price List Users  added: ${pricelistautho.authoGroup}');
        }
      } catch (e) {
        print('Error updating Firestore Price List Users: $e');
      }
    }
  } catch (e) {
    print('Error updating Firestore Price List Users: $e');
  }
}


// Function to compare SystemAdmin data equality (customize based on your data structure)
bool dataEqualsSystemAdmin(
    Map<String, dynamic> existingData, SystemAdmin newSystemAdmin) {
  // Compare fields and return true if they are equal, otherwise return false
  // Add conditions for each field you want to compare
  return existingData['autoExport'] == newSystemAdmin.autoExport &&
      existingData['groupcode'] == newSystemAdmin.groupcode &&
      existingData['importFromErpToMobile'] == newSystemAdmin.importFromErpToMobile &&
      existingData['importFromBackendToMobile'] == newSystemAdmin.importFromBackendToMobile;
  // Add additional conditions as needed
}

bool dataEqualsCompaniesConnection(
    Map<String, dynamic> existingData, CompaniesConnection newCompanyConnection) {
  // Compare fields and return true if they are equal, otherwise return false
  // Add conditions for each field you want to compare
  return existingData['connectionID'] == newCompanyConnection.connectionID &&
      existingData['connDatabase'] == newCompanyConnection.connDatabase &&
      existingData['connUser'] == newCompanyConnection.connUser &&
       existingData['connPassword'] == newCompanyConnection.connPassword &&
        existingData['connPort'] == newCompanyConnection.connPort &&
      existingData['typeDatabase'] == newCompanyConnection.typeDatabase;
  // Add additional conditions as needed
}

bool dataEqualsCompaniesUsers(
    Map<String, dynamic> existingData, CompaniesUsers newCompanyUser) {
  // Compare fields and return true if they are equal, otherwise return false
  // Add conditions for each field you want to compare
  return existingData['cmpCode'] == newCompanyUser.cmpCode &&
      existingData['userCode'] == newCompanyUser.userCode;
  // Add additional conditions as needed
}

bool dataEqualsPriceListAutho(
    Map<String, dynamic> existingData, PriceListAuthorization newPriceList) {
  // Compare fields and return true if they are equal, otherwise return false
  // Add conditions for each field you want to compare
  return existingData['cmpCode'] == newPriceList.cmpCode &&
      existingData['userCode'] == newPriceList.userCode &&
      existingData['authoGroup']== newPriceList.authoGroup;
  // Add additional conditions as needed
}


  Future<bool> hasInternetConnection() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      print('Error checking internet connection: $e');
      return false;
    }
  }
}
