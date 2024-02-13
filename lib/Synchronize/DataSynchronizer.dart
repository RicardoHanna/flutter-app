import 'dart:convert';

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
import 'package:http/http.dart' as http; 


class DataSynchronizer {
String baseUrl='http://5.189.188.139:8080';
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

      var companiesBox = await Hive.openBox<Companies>('companiesBox');
      List<Companies>companies = companiesBox.values.toList();

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
         await _updateFirestoreCompanies(companies);
        // Update or add other data to Firestore if needed

      }
    } catch (e) {
      print('Error synchronizing data: $e');
    }
  }
Future<void> _updateFirestoreUsers(List<String> users) async {
 try {
      // Fetch user data from the API
      var response = await http.get(Uri.parse('http://5.189.188.139:8080/api/users'));
      print(response.body);
      if (response.statusCode == 200) {
        List<dynamic> apiUsers = jsonDecode(response.body);
  
print(apiUsers);
        // Iterate through each user to determine if it should be added, updated, or deleted
        for (String userCode in users) {
          var userData = userBox.get(userCode);
                      var existingUser = apiUsers.firstWhere((user) => user['usercode'] == userCode, orElse: () => null);

          if (userData != null) {
            // Check if user exists in API response

            if (existingUser != null) {
              // User exists, update user data
              final response = await http.put(
                Uri.parse('http://5.189.188.139:8080/api/users/updateUser/${existingUser['usercode']}'),
                body: jsonEncode(userData),
                headers: {'Content-Type': 'application/json'},
              );
              print(response.statusCode);
              print(response.body);
              print('User updated: $userCode');
            } else {
              // User does not exist, add new user
              await http.post(
                Uri.parse('http://5.189.188.139:8080/api/users/insertUser'),
                body: jsonEncode(userData),
                headers: {'Content-Type': 'application/json'},
              );
              print('User added: $userCode');
            }
          } else {
            // User does not exist in local storage, delete user from API
            if (existingUser != null) {
              await http.delete(Uri.parse('http://5.189.188.139:8080/api/users/deleteUser/${existingUser['usercode']}'));
              print('User deleted: $userCode');
            }
          }
        }
      } else {
        print('Failed to fetch users from API');
      }
    } catch (e) {
      print('Error updating API users: $e');
    }
  }





Future<void> _updateFirestoreUserGroup(List<UserGroup> userGroups) async {
  try {
    var userGroupBox = await Hive.openBox<UserGroup>('userGroupBox');

      // Fetch user data from the API
      var response = await http.get(Uri.parse('http://5.189.188.139:8080/api/usergroup'));
      print(response.body);
      if (response.statusCode == 200) {
        List<dynamic> apiUsers = jsonDecode(response.body);
 
print(apiUsers);
        // Iterate through each user to determine if it should be added, updated, or deleted
        for (UserGroup groupCode in userGroups) {
          var userGroupData = userGroupBox.get(groupCode.groupcode);
                      var existingUserGroup = apiUsers.firstWhere((user) => user['groupcode'] == groupCode.groupcode, orElse: () => null);
                     print('jelo');

          if (userGroupData != null) {
            // Check if user exists in API response
            print('fomocs');
print(existingUserGroup);
            if (existingUserGroup != null) {
              // User exists, update user data
              final response = await http.put(
                Uri.parse('http://5.189.188.139:8080/api/usergroup/updateUserGroup/${existingUserGroup['groupcode']}'),
                body: jsonEncode(userGroupData.toJson()),
                headers: {'Content-Type': 'application/json'},
              );
              print(response.statusCode);
              print(response.body);
              print('User Group updated: $userGroupData');
            } else {
              print('riccc');
              // User does not exist, add new user
              await http.post(
                Uri.parse('http://5.189.188.139:8080/api/usergroup/insertUserGroup'),
                body: jsonEncode(userGroupData.toJson()),
                headers: {'Content-Type': 'application/json'},
              );
              print('User added: $groupCode');
            }
          } else {
            // User does not exist in local storage, delete user from API
            if (existingUserGroup != null) {
              await http.delete(Uri.parse('http://5.189.188.139:8080/api/usergroup/deleteUserGroup/${existingUserGroup['groupcode']}'));
              print('User deleted: $groupCode');
            }
          }
        }
      } else {
        print('Failed to fetch users from API');
      }
    } catch (e) {
      print('Error updating API users group: $e');
    }
  }



Future<void> _updateFirestoreTranslations(List<Translations> translations) async {
   try {
      var translationsBox = await Hive.openBox<Translations>('translationsBox');

      // Fetch user data from the API
      var response = await http.get(Uri.parse('http://5.189.188.139:8080/api/translations'));
      print(response.body);
      if (response.statusCode == 200) {
        List<dynamic> apiUsers = jsonDecode(response.body);
 
print(apiUsers);
        // Iterate through each user to determine if it should be added, updated, or deleted
        for (Translations groupCode in translations) {
          var userGroupData = translationsBox.get(groupCode.groupcode);
                      var existingTrans = apiUsers.firstWhere((user) => user['groupcode'] == groupCode.groupcode, orElse: () => null);
                     print('jelo');

          if (userGroupData != null) {
            // Check if user exists in API response
            print('fomocs');
print(existingTrans);
            if (existingTrans != null) {
              // User exists, update user data
              final response = await http.put(
                Uri.parse('http://5.189.188.139:8080/api/translations/updateTranslations/${existingTrans['groupcode']}'),
                body: jsonEncode(userGroupData),
                headers: {'Content-Type': 'application/json'},
              );
              print(response.statusCode);
              print(response.body);
              print('Trans updated: $userGroupData');
            } else {
              print('riccc');
              // User does not exist, add new user
              await http.post(
                Uri.parse('http://5.189.188.139:8080/api/translations/insertTranslations'),
                body: jsonEncode(userGroupData),
                headers: {'Content-Type': 'application/json'},
              );
              print('Trans added: $groupCode');
            }
          } else {
            // User does not exist in local storage, delete user from API
            if (existingTrans != null) {
              await http.delete(Uri.parse('http://5.189.188.139:8080/api/translations/deleteTranslations/${existingTrans['groupcode']}'));
              print('Trans deleted: $groupCode');
            }
          }
        }
      } else {
        print('Failed to fetch Trans from API');
      }
    } catch (e) {
      print('Error updating API Transla group: $e');
    }
  }

Future<void> _updateFirestoreAuthorization(List<Authorization> authorizations) async {
  try {
    var authorizationBox = await Hive.openBox<Authorization>('authorizationBox');

    // Fetch user data from the API
    var response = await http.get(Uri.parse('http://5.189.188.139:8080/api/authorization'));
    print(response.body);
    if (response.statusCode == 200) {
      List<dynamic> apiAutho = jsonDecode(response.body);

      print(apiAutho);
      // Iterate through each user to determine if it should be added, updated, or deleted
   for (Authorization authorization in authorizationBox.values) {
  var existingAuthoGroup = apiAutho.firstWhere((user) => user['groupcode'] == authorization.groupcode && user['menucode'] == authorization.menucode, orElse: () => null);
  print('Processing authorization: $authorization');

  if (existingAuthoGroup != null) {
    // User exists, update user data
    final response = await http.put(
      Uri.parse('http://5.189.188.139:8080/api/authorization/updateAuthorization/${authorization.menucode}/${authorization.groupcode}'),
      body: jsonEncode(authorization.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    print(response.statusCode);
    print(response.body);
    print('Authorization updated: $authorization');
  } else {
    // User does not exist, add new user
    await http.post(
      Uri.parse('http://5.189.188.139:8080/api/authorization/insertAuthorization'),
      body: jsonEncode(authorization.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    print('Authorization added: $authorization');
  }
}


    } else {
      print('Failed to fetch authorizations from API');
    }
  } catch (e) {
    print('Error updating API authorizations: $e');
  }
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
    // Get all CompaniesUsers documents from Firestore
    QuerySnapshot<Map<String, dynamic>> allDocsSnapshot =
        await _firestore.collection('CompaniesUsers').get();

    // Create a list to keep track of documents to delete
    List<DocumentReference> docsToDelete = [];

    // Loop through each CompaniesUsers and update or add to Firestore
    for (CompaniesUsers companyuser in companiesusers) {
      try {
        // Check if the CompaniesUsers already exists in Firestore
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
            .collection('CompaniesUsers')
            .where('cmpCode', isEqualTo: companyuser.cmpCode)
            .where('userCode', isEqualTo: companyuser.userCode)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // CompaniesUsers already exists
          String documentId = querySnapshot.docs[0].id;
          Map<String, dynamic> existingData = querySnapshot.docs[0].data()!;

          if (!dataEqualsCompaniesUsers(existingData, companyuser)) {
            // Update existing data in Firestore
            await _firestore.collection('CompaniesUsers').doc(documentId).update(
              {
                'userCode': companyuser.userCode,
                'cmpCode': companyuser.cmpCode,
                'defaultcmpCode': companyuser.defaultcmpCode
                // Update other fields if needed
              },
            );
            print('Companies Users updated: ${companyuser.cmpCode}');
          }
        } else {
          // CompaniesUsers doesn't exist, add it to Firestore
          await _firestore.collection('CompaniesUsers').add(
            {
              'userCode': companyuser.userCode,
              'cmpCode': companyuser.cmpCode,
              'defaultcmpCode': companyuser.defaultcmpCode
              // Add other fields if needed
            },
          );
          print('Companies Users added: ${companyuser.cmpCode}');
        }
      } catch (e) {
        print('Error updating Firestore Companies Users: $e');
      }
    }

    // Check for deletions
    for (DocumentSnapshot<Map<String, dynamic>> docSnapshot in allDocsSnapshot.docs) {
      // Extract data from the document
      Map<String, dynamic> firestoreData = docSnapshot.data()!;
      String cmpCode = firestoreData['cmpCode'];
      String userCode = firestoreData['userCode'];

      // Check if the document exists in the local list of CompaniesUsers objects
      bool existsLocally = companiesusers.any((localCompanyUser) =>
          localCompanyUser.cmpCode == cmpCode && localCompanyUser.userCode == userCode);

      // If the document doesn't exist locally, add it to the list of documents to delete
      if (!existsLocally) {
        docsToDelete.add(docSnapshot.reference);
        print('Companies Users to delete: $cmpCode');
      }
    }

    // Delete documents
    for (DocumentReference docRef in docsToDelete) {
      await docRef.delete();
      print('Companies Users deleted');
    }
  } catch (e) {
    print('Error updating Firestore Companies Users: $e');
  }
}

Future<void> _updateFirestorePriceListAutho(List<PriceListAuthorization> pricelistsautho) async {
  try {
    // Get all PriceListAuthorization documents from Firestore
    QuerySnapshot<Map<String, dynamic>> allDocsSnapshot =
        await _firestore.collection('PriceListAuthorization').get();

    // Create a list to keep track of documents to delete
    List<DocumentReference> docsToDelete = [];

    // Loop through each PriceListAuthorization and update or add to Firestore
    for (PriceListAuthorization pricelistautho in pricelistsautho) {
      try {
        // Check if the PriceListAuthorization already exists in Firestore
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
            .collection('PriceListAuthorization')
            .where('cmpCode', isEqualTo: pricelistautho.cmpCode)
            .where('userCode', isEqualTo: pricelistautho.userCode)
            .where('authoGroup', isEqualTo: pricelistautho.authoGroup)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // PriceListAuthorization already exists
          String documentId = querySnapshot.docs[0].id;
          Map<String, dynamic> existingData = querySnapshot.docs[0].data()!;

          if (!dataEqualsPriceListAutho(existingData, pricelistautho)) {
            // Update existing data in Firestore
            await _firestore.collection('PriceListAuthorization').doc(documentId).update(
              {
                'userCode': pricelistautho.userCode,
                'cmpCode': pricelistautho.cmpCode,
                'authoGroup': pricelistautho.authoGroup
                // Update other fields if needed
              },
            );
            print('Price List Users updated: ${pricelistautho.authoGroup}');
          }
        } else {
          // PriceListAuthorization doesn't exist, add it to Firestore
          await _firestore.collection('PriceListAuthorization').add(
            {
              'userCode': pricelistautho.userCode,
              'cmpCode': pricelistautho.cmpCode,
              'authoGroup': pricelistautho.authoGroup
              // Add other fields if needed
            },
          );
          print('Price List Users added: ${pricelistautho.authoGroup}');
        }
      } catch (e) {
        print('Error updating Firestore Price List Users: $e');
      }
    }

    // Check for deletions
    for (DocumentSnapshot<Map<String, dynamic>> docSnapshot in allDocsSnapshot.docs) {
      // Extract data from the document
      Map<String, dynamic> firestoreData = docSnapshot.data()!;
      String cmpCode = firestoreData['cmpCode'];
      String userCode = firestoreData['userCode'];
      String authoGroup = firestoreData['authoGroup'];

      // Check if the document exists in the local list of PriceListAuthorization objects
      bool existsLocally = pricelistsautho.any((localPriceListAutho) =>
          localPriceListAutho.cmpCode == cmpCode &&
          localPriceListAutho.userCode == userCode &&
          localPriceListAutho.authoGroup == authoGroup);

      // If the document doesn't exist locally, add it to the list of documents to delete
      if (!existsLocally) {
        docsToDelete.add(docSnapshot.reference);
        print('Price List Users to delete: $authoGroup');
      }
    }

    // Delete documents
    for (DocumentReference docRef in docsToDelete) {
      await docRef.delete();
      print('Price List Users deleted');
    }
  } catch (e) {
    print('Error updating Firestore Price List Users: $e');
  }
}


Future<void> _updateFirestoreCompanies(List<Companies> companies) async {
  try {
    // Get all PriceListAuthorization documents from Firestore
    QuerySnapshot<Map<String, dynamic>> allDocsSnapshot =
        await _firestore.collection('Companies').get();

    // Create a list to keep track of documents to delete
    List<DocumentReference> docsToDelete = [];

    // Loop through each PriceListAuthorization and update or add to Firestore
    for (Companies company in companies) {
      try {
        // Check if the PriceListAuthorization already exists in Firestore
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
            .collection('Companies')
            .where('cmpCode', isEqualTo: company.cmpCode)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // PriceListAuthorization already exists
          String documentId = querySnapshot.docs[0].id;
          Map<String, dynamic> existingData = querySnapshot.docs[0].data()!;

          if (!dataEqualsCompany(existingData, company)) {
            // Update existing data in Firestore
            await _firestore.collection('Companies').doc(documentId).update(
              {
          'cmpCode': company.cmpCode,
          'cmpName': company.cmpName,
          'cmpFName': company.cmpFName,
          'tel': company.tel,
          'mobile': company.mobile,
          'address': company.address,
          'fAddress':company.address,
          'prHeader': company.prHeader,
          'prFHeader': company.prFHeader,
          'prFooter': company.prFFooter,
          'prFFooter': company.prFFooter,
          'mainCurCode': company.mainCurCode,
          'secCurCode': company.secCurCode,
          'rateType': company.rateType,
          'issueBatchMethod': company.issueBatchMethod,
          'systemAdminID': company.systemAdminID ,
          'notes': company.notes,
              },
            );
            print('Company updated: ${company.cmpCode}');
          }
        } else {
          // PriceListAuthorization doesn't exist, add it to Firestore
          await _firestore.collection('Companies').add(
            {
                'cmpCode': company.cmpCode,
          'cmpName': company.cmpName,
          'cmpFName': company.cmpFName,
          'tel': company.tel,
          'mobile': company.mobile,
          'address': company.address,
          'fAddress':company.address,
          'prHeader': company.prHeader,
          'prFHeader': company.prFHeader,
          'prFooter': company.prFFooter,
          'prFFooter': company.prFFooter,
          'mainCurCode': company.mainCurCode,
          'secCurCode': company.secCurCode,
          'rateType': company.rateType,
          'issueBatchMethod': company.issueBatchMethod,
          'systemAdminID': company.systemAdminID ,
          'notes': company.notes,
            },
          );
          print('Company added: ${company.cmpCode}');
        }
      } catch (e) {
        print('Error updating Firestore Company : $e');
      }
    }

    // Check for deletions
    for (DocumentSnapshot<Map<String, dynamic>> docSnapshot in allDocsSnapshot.docs) {
      // Extract data from the document
      Map<String, dynamic> firestoreData = docSnapshot.data()!;
      String cmpCode = firestoreData['cmpCode'];


      // Check if the document exists in the local list of PriceListAuthorization objects
      bool existsLocally = companies.any((localCompany) =>
          localCompany.cmpCode == cmpCode 
         );

      // If the document doesn't exist locally, add it to the list of documents to delete
      if (!existsLocally) {
        docsToDelete.add(docSnapshot.reference);
        print('Company to delete: $cmpCode');
      }
    }

    // Delete documents
    for (DocumentReference docRef in docsToDelete) {
      await docRef.delete();
      print('Company deleted');
    }
  } catch (e) {
    print('Error updating Firestore Company: $e');
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
      existingData['typeDatabase'] == newCompanyConnection.typeDatabase &&
        existingData['connServer'] == newCompanyConnection.connServer;

  // Add additional conditions as needed
}

bool dataEqualsCompaniesUsers(
    Map<String, dynamic> existingData, CompaniesUsers newCompanyUser) {
  // Compare fields and return true if they are equal, otherwise return false
  // Add conditions for each field you want to compare
  return existingData['cmpCode'] == newCompanyUser.cmpCode &&
      existingData['userCode'] == newCompanyUser.userCode &&
        existingData['defaultcmpCode'] == newCompanyUser.defaultcmpCode ;
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


// Function to compare SystemAdmin data equality (customize based on your data structure)
bool dataEqualsCompany(
    Map<String, dynamic> existingData, Companies newCompanies) {
  // Compare fields and return true if they are equal, otherwise return false
  // Add conditions for each field you want to compare
  return existingData['cmpCode'] == newCompanies.cmpCode;
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
