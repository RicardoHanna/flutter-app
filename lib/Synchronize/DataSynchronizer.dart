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
import 'package:project/hive/userssalesemployees_hive.dart'; 


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

            var usersSalesEmployeesBox = await Hive.openBox<UserSalesEmployees>('usersSalesEmployeesBox');
      List<UserSalesEmployees>userssalesemployees = usersSalesEmployeesBox.values.toList();

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
         await _updateFirestoreUsersSalesEmployees(userssalesemployees);
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
    print(response.statusCode);
    if (response.statusCode == 200) {
      List<dynamic> apiUsers = jsonDecode(response.body);
      print(apiUsers);
      
      // Iterate through each user to determine if it should be added, updated, or deleted
      for (String userCode in users) {
        var userData = userBox.get(userCode);
        var existingUser;
        if (apiUsers != null) {
          existingUser = apiUsers.firstWhere((user) => user['usercode'] == userCode, orElse: () => null);
        }
       if (existingUser != null) {
          print(existingUser['usercode']);
        } else {
          print('Existing user not found in API');
        }
        print('khata');
        if (userData != null) {
          // Check if user exists in API response
          print('jooo');
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
            print('ricooo');
            // User does not exist, add new user
            await http.post(
              Uri.parse('http://5.189.188.139:8080/api/users/insertUser'),
              body: jsonEncode(userData),
              headers: {'Content-Type': 'application/json'},
            );
            print('User added: $userCode');
          }
        } 
         List<String> hiveUsers = userBox.keys.cast<String>().toList();
for (dynamic apiUser in apiUsers) {
    String apiUserCode = apiUser['usercode'];
    // Check if the user exists in Hive
    if (!hiveUsers.contains(apiUserCode)) {
        // User exists in the API but not in Hive, delete from API
        await http.delete(Uri.parse('http://5.189.188.139:8080/api/users/deleteUser/$apiUserCode'));
        print('User deleted from API: $apiUserCode');
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
           var existingUserGroup;
           if(apiUsers!=null){
                    existingUserGroup = apiUsers.firstWhere((user) => user['groupcode'] == groupCode.groupcode, orElse: () => null);
           }

          if (userGroupData != null) {
            // Check if user exists in API response
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
          } 
          List<int> hiveUsersGroup = userGroupBox.keys.cast<int>().toList();

// Compare the list of users from Hive with the list of users from the API
for (dynamic apiUser in apiUsers) {
    int apiUserCode = apiUser['groupcode'];
    // Check if the user exists in Hive
    if (!hiveUsersGroup.contains(apiUserCode)) {
        // User exists in the API but not in Hive, delete from API
              await http.delete(Uri.parse('http://5.189.188.139:8080/api/usergroup/deleteUserGroup/$apiUserCode'));
        print('User Group deleted from API: $apiUserCode');
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

    // Fetch translations data from the API
    var response = await http.get(Uri.parse('http://5.189.188.139:8080/api/translations'));
    print(response.body);
    if (response.statusCode == 200) {
      List<dynamic> apiTranslations = jsonDecode(response.body);
      print(apiTranslations);
      
      // Iterate through each translation group to determine if it should be added, updated, or deleted
      for (Translations groupCode in translations) {
        var userGroupData = translationsBox.get(groupCode.groupcode);
        var existingTrans;
        if (apiTranslations != null) {
          existingTrans = apiTranslations.firstWhere((trans) => trans['groupcode'] == groupCode.groupcode, orElse: () => null);
        }
        if (userGroupData != null) {
          // Check if translation group exists in API response
          if (existingTrans != null) {
            // Translation group exists, update translation data
            final response = await http.put(
              Uri.parse('http://5.189.188.139:8080/api/translations/updateTranslations/${existingTrans['groupcode']}'),
              body: jsonEncode(userGroupData),
              headers: {'Content-Type': 'application/json'},
            );
            print(response.statusCode);
            print(response.body);
            print('Translation group updated: $userGroupData');
          } else {
            // Translation group does not exist, add new translation group
            print('Adding translation group to API');
            await http.post(
              Uri.parse('http://5.189.188.139:8080/api/translations/insertTranslations'),
              body: jsonEncode(userGroupData),
              headers: {'Content-Type': 'application/json'},
            );
            print('Translation group added: $groupCode');
          }
        } else {
          print('Translation group data not found in local storage');
        }
      }

      // Compare the list of translation groups from Hive with the list of translation groups from the API
      List<int> hiveTrans = translationsBox.keys.cast<int>().toList();
      for (dynamic apiTrans in apiTranslations) {
        int apiTransCode = apiTrans['groupcode'];
        // Check if the translation group exists in Hive
        if (!hiveTrans.contains(apiTransCode)) {
          // Translation group exists in the API but not in Hive, delete from API
          await http.delete(Uri.parse('http://5.189.188.139:8080/api/translations/deleteTranslations/$apiTransCode'));
          print('Translation group deleted from API: $apiTransCode');
        }
      }
    } else {
      print('Failed to fetch translations from API');
    }
  } catch (e) {
    print('Error updating API translation group: $e');
  }
}
Future<void> _updateFirestoreAuthorization(List<Authorization> authorizations) async {
  try {
    var authorizationBox = await Hive.openBox<Authorization>('authorizationBox');

    // Fetch authorization data from the API
    var response = await http.get(Uri.parse('http://5.189.188.139:8080/api/authorization'));
    print(response.body);
    print('hiiiii');
    print(response.statusCode);
    if (response.statusCode == 200) {
      List<dynamic> apiAutho = jsonDecode(response.body);
      print(apiAutho);
      
      // Iterate through each authorization to determine if it should be added, updated, or deleted
      for (Authorization authorization in authorizations) {
        var existingAuthoGroup;
        if (apiAutho != null) {
          existingAuthoGroup = apiAutho.firstWhere((autho) => autho['groupcode'] == authorization.groupcode && autho['menucode'] == authorization.menucode, orElse: () => null);
        }
        print('Processing authorization: $authorization');
        if (existingAuthoGroup != null) {
          // Authorization exists, update authorization data
          final response = await http.put(
            Uri.parse('http://5.189.188.139:8080/api/authorization/updateAuthorization/${authorization.menucode}/${authorization.groupcode}'),
            body: jsonEncode(authorization.toJson()),
            headers: {'Content-Type': 'application/json'},
          );
          print(response.statusCode);
          print(response.body);
          print('Authorization updated: $authorization');
        } else {
          // Authorization does not exist, add new authorization
          print('Adding authorization to API');
          await http.post(
            Uri.parse('http://5.189.188.139:8080/api/authorization/insertAuthorization'),
            body: jsonEncode(authorization.toJson()),
            headers: {'Content-Type': 'application/json'},
          );
          print('Authorization added: $authorization');
        }
      }

   // Convert the keys from authorizationBox to strings for comparison
List<String> hiveAuthoKeys = authorizationBox.keys.map((key) => key.toString()).toList();

// Compare the list of authorizations from Hive with the list of authorizations from the API
for (dynamic apiAuth in apiAutho) {
    int apiGroupCode = apiAuth['groupcode'];
    int apiMenuCode = apiAuth['menucode'];
    // Construct the key in the same format as stored in authorizationBox
    String apiKey = '$apiMenuCode$apiGroupCode';
    print(apiKey);
    // Check if the authorization exists in Hive
    if (!hiveAuthoKeys.contains(apiKey)) {
        // Authorization exists in the API but not in Hive, delete from API
        await http.delete(Uri.parse('http://5.189.188.139:8080/api/authorization/deleteAuthorization/$apiMenuCode/$apiGroupCode'));
        print('Authorization deleted from API: $apiKey');
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
          var systemAdminBox = await Hive.openBox<SystemAdmin>('systemAdminBox');

      // Fetch user data from the API
      var response = await http.get(Uri.parse('http://5.189.188.139:8080/api/systemadmin'));
      print(response.body);
      if (response.statusCode == 200) {
        List<dynamic> apiSys = jsonDecode(response.body);
 
print(apiSys);
        // Iterate through each user to determine if it should be added, updated, or deleted
        for (SystemAdmin groupCode in systemAdmin) {
          var userGroupData = systemAdminBox.get(groupCode.groupcode);
          var existingUserGroup;
          if(apiSys!=null){
              existingUserGroup = apiSys.firstWhere((user) => user['groupcode'] == groupCode.groupcode, orElse: () => null);
          }
                  

          if (userGroupData != null) {
            // Check if user exists in API response

            if (existingUserGroup != null) {
              // User exists, update user data
              final response = await http.put(
                Uri.parse('http://5.189.188.139:8080/api/systemAdmin/updateSystemAdmin/${existingUserGroup['groupcode']}'),
                body: jsonEncode(userGroupData.toJson()),
                headers: {'Content-Type': 'application/json'},
              );
              print(response.statusCode);
              print(response.body);
              print('System Admin Group updated: $userGroupData');
            } else {
              print('riccc');
              // User does not exist, add new user
              await http.post(
                Uri.parse('http://5.189.188.139:8080/api/systemadmin/insertSystemAdmin'),
                body: jsonEncode(userGroupData.toJson()),
                headers: {'Content-Type': 'application/json'},
              );
              print('System Admin added: $groupCode');
            }
          } 
            // User does not exist in local storage, delete user from API
            if (existingUserGroup != null) {
              await http.delete(Uri.parse('http://5.189.188.139:8080/api/systemAdmin/deleteSystemAdmin/${existingUserGroup['groupcode']}'));
              print('System Admin deleted: $groupCode');
            }
          
        }
      } else {
        print('Failed to fetch system admin from API');
      }
    } catch (e) {
      print('Error updating API system admin group: $e');
    }
  }





Future<void> _updateFirestoreCompaniesConnection(List<CompaniesConnection> companiesConnection) async {
  try {
          var companiesConnectionBox = await Hive.openBox<CompaniesConnection>('companiesConnectionBox');


      // Fetch user data from the API
      var response = await http.get(Uri.parse('http://5.189.188.139:8080/api/companiesconnection'));
      print(response.body);
      if (response.statusCode == 200) {
        List<dynamic> apiComp = jsonDecode(response.body);
 
print(apiComp);
        // Iterate through each user to determine if it should be added, updated, or deleted
        for (CompaniesConnection connID in companiesConnection) {
          var userGroupData = companiesConnectionBox.get(connID.connectionID);
          var existingUserGroup;
          if(apiComp!=null){
          existingUserGroup = apiComp.firstWhere((user) => user['connectionID'] == connID.connectionID, orElse: () => null);
          }
                     print('jelo');
print(userGroupData?.connectionID);
          if (userGroupData != null) {
            // Check if user exists in API response
            print('fomocs');
            if (existingUserGroup != null) {
              // User exists, update user data
              final response = await http.put(
                Uri.parse('http://5.189.188.139:8080/api/companiesconnection/updateCompaniesConnection/${existingUserGroup['connectionID']}'),
                body: jsonEncode(userGroupData.toJson()),
                headers: {'Content-Type': 'application/json'},
              );
              print(response.statusCode);
              print(response.body);
              print('Companies Connection Group updated: $userGroupData');
            } else {
              print('riccc');
              // User does not exist, add new user
              await http.post(
                Uri.parse('http://5.189.188.139:8080/api/companiesconnection/insertCompaniesConnection'),
                body: jsonEncode(userGroupData.toJson()),
                headers: {'Content-Type': 'application/json'},
              );
              print('Companies Connection  added: $connID');
            }
          }

               // Compare the list of translation groups from Hive with the list of translation groups from the API
      List<String> hiveTrans = companiesConnectionBox.keys.cast<String>().toList();
      for (dynamic apiComps in apiComp) {
        String apiconnId = apiComps['connectionID'];
        // Check if the translation group exists in Hive
        if (!hiveTrans.contains(apiconnId)) {
          // Translation group exists in the API but not in Hive, delete from API
              await http.delete(Uri.parse('http://5.189.188.139:8080/api/companiesconnection/deleteCompaniesConnection/$apiconnId'));
          print('Companies Conn  deleted from API: $apiconnId');
        }
      }
  
          
        }
      } else {
        print('Failed to fetch companies connection from API');
      }
    } catch (e) {
      print('Error updating API companies connection  group: $e');
    }
  }



Future<void> _updateFirestoreCompaniesUsers(List<CompaniesUsers> companiesusers) async {
   try {
      var companiesusersBox = await Hive.openBox<CompaniesUsers>('companiesUsersBox');

    // Fetch user data from the API
    var response = await http.get(Uri.parse('http://5.189.188.139:8080/api/companiesusers'));
    print(response.body);
    if (response.statusCode == 200) {
      List<dynamic> apiCompUser = jsonDecode(response.body);

      print(apiCompUser);
      // Iterate through each user to determine if it should be added, updated, or deleted
   for (CompaniesUsers compuser in companiesusersBox.values) {
    var existingAuthoGroup;
    if(apiCompUser!=null){
   existingAuthoGroup = apiCompUser.firstWhere((user) => user['userCode'] == compuser.userCode && user['cmpCode'] == compuser.cmpCode, orElse: () => null);
    }
  print('Processing Comp User: $compuser');

  if (existingAuthoGroup != null) {
    // User exists, update user data
    final response = await http.put(
      Uri.parse('http://5.189.188.139:8080/api/companiesusers/updateCompaniesUsers/${compuser.userCode}/${compuser.cmpCode}'),
      body: jsonEncode(compuser.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    print(response.statusCode);
    print(response.body);
    print('Company User updated: $compuser');
  } else {
    // User does not exist, add new user
    await http.post(
      Uri.parse('http://5.189.188.139:8080/api/companiesusers/insertCompaniesUsers'),
      body: jsonEncode(compuser.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    print('Company User added: $compuser');
  }
}

   // Convert the keys from authorizationBox to strings for comparison
List<String> hiveCmpUserKeys = companiesusersBox.keys.map((key) => key.toString()).toList();

// Compare the list of authorizations from Hive with the list of authorizations from the API
for (dynamic apiAuth in apiCompUser) {
    String apiUserCode = apiAuth['userCode'];
    String apiCmpCode = apiAuth['cmpCode'];
    // Construct the key in the same format as stored in authorizationBox
    String apiKey = '$apiUserCode$apiCmpCode';
    print(apiKey);
    // Check if the authorization exists in Hive
    if (!hiveCmpUserKeys.contains(apiKey)) {
        // Authorization exists in the API but not in Hive, delete from API
        await http.delete(Uri.parse('http://5.189.188.139:8080/api/companiesusers/deleteCompaniesUsers/$apiUserCode/$apiCmpCode'));
        print('Comp Users deleted from API: $apiKey');
    }
}

    } else {
      print('Failed to fetch comp user from API');
    }
  } catch (e) {
    print('Error updating API comp user: $e');
  }
}



Future<void> _updateFirestorePriceListAutho(List<PriceListAuthorization> pricelistsautho) async {
 try {
      var pricelistauthoBox = await Hive.openBox<PriceListAuthorization>('pricelistAuthorizationBox');

    // Fetch user data from the API
    var response = await http.get(Uri.parse('http://5.189.188.139:8080/api/pricelistauthorization'));
    print(response.body);
    if (response.statusCode == 200) {
      List<dynamic> apiPrice = jsonDecode(response.body);

      print(apiPrice);
      // Iterate through each user to determine if it should be added, updated, or deleted
   for (PriceListAuthorization pricelistautho in pricelistauthoBox.values) {
    var existingAuthoGroup;
    if(apiPrice!=null){
   existingAuthoGroup = apiPrice.firstWhere((user) => user['userCode'] == pricelistautho.userCode && user['cmpCode'] == pricelistautho.cmpCode  && user['authoGroup'] == pricelistautho.authoGroup, orElse: () => null);
    }
  print('Processing price lsit authi : $pricelistautho');

  if (existingAuthoGroup != null) {
    // User exists, update user data
    final response = await http.put(
      Uri.parse('http://5.189.188.139:8080/api/pricelistauthorization/updatePriceListAuthorization/${pricelistautho.userCode}/${pricelistautho.cmpCode}/${pricelistautho.authoGroup}'),
      body: jsonEncode(pricelistautho.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    print(response.statusCode);
    print(response.body);
    print('Price list  updated: $pricelistautho');
  } else {
    // User does not exist, add new user
    await http.post(
      Uri.parse('http://5.189.188.139:8080/api/pricelistauthorization/insertPriceListAuthorization'),
      body: jsonEncode(pricelistautho.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    print('Price List autho  added: $pricelistautho');
  }
}

 // Convert the keys from authorizationBox to strings for comparison
List<String> hivePriceListKeys = pricelistauthoBox.keys.map((key) => key.toString()).toList();

// Compare the list of authorizations from Hive with the list of authorizations from the API
for (dynamic apiPrices in apiPrice) {
    String apiUserCode = apiPrices['userCode'];
    String apiCmpCode = apiPrices['cmpCode'];
    String authoGroup = apiPrices['authoGroup'];
    // Construct the key in the same format as stored in authorizationBox
    String apiKey = '$apiUserCode$apiCmpCode$authoGroup';
    print(apiKey);
    // Check if the authorization exists in Hive
    if (!hivePriceListKeys.contains(apiKey)) {
        // Authorization exists in the API but not in Hive, delete from API
        await http.delete(Uri.parse('http://5.189.188.139:8080/api/pricelistauthorization/deletePriceListAuthorization/$apiUserCode/$apiCmpCode/$authoGroup'));
        print('Price List Auhto deleted from API: $apiKey');
    }
}


    } else {
      print('Failed to fetch Price List autho from API');
    }
  } catch (e) {
    print('Error updating API Price List autho : $e');
  }
}



Future<void> _updateFirestoreCompanies(List<Companies> companies) async {
 try {
      var companiesBox = await Hive.openBox<Companies>('companiesBox');



      // Fetch user data from the API
      var response = await http.get(Uri.parse('http://5.189.188.139:8080/api/companies'));
      print(response.body);
      if (response.statusCode == 200) {
        List<dynamic> apiComp = jsonDecode(response.body);
 
print(apiComp);
        // Iterate through each user to determine if it should be added, updated, or deleted
        for (Companies cmpCode in companies) {
          var userGroupData = companiesBox.get(cmpCode.cmpCode);
          print('hi');
          print(userGroupData);
          var existingUserGroup;
          if(apiComp!=null){
               existingUserGroup = apiComp.firstWhere((user) => user['cmpCode'] == cmpCode.cmpCode, orElse: () => null);
          }
                     print('jelo');
print(userGroupData?.cmpCode);
          if (userGroupData != null) {
            // Check if user exists in API response
            print('fomocs');
print(existingUserGroup);
            if (existingUserGroup != null) {
              // User exists, update user data
              final response = await http.put(
                Uri.parse('http://5.189.188.139:8080/api/companies/updateCompanies/${existingUserGroup['cmpCode']}'),
                body: jsonEncode(userGroupData.toJson()),
                headers: {'Content-Type': 'application/json'},
              );
              print(response.statusCode);
              print(response.body);
              print('Companies  Group updated: $userGroupData');
            } else {
              print('riccc');
              // User does not exist, add new user
              await http.post(
                Uri.parse('http://5.189.188.139:8080/api/companies/insertCompanies'),
                body: jsonEncode(userGroupData.toJson()),
                headers: {'Content-Type': 'application/json'},
              );
              print('Companies   added: $companies');
            }
          } 

  List<String> hiveCompanies= companiesBox.keys.cast<String>().toList();
print(hiveCompanies);
// Compare the list of users from Hive with the list of users from the API
for (dynamic apiComps in apiComp) {
    String apiCmpCode = apiComps['cmpCode'];
    print(cmpCode);
    // Check if the user exists in Hive
    if (!hiveCompanies.contains(apiCmpCode)) {
        // User exists in the API but not in Hive, delete from API
              await http.delete(Uri.parse('http://5.189.188.139:8080/api/companies/deleteCompanies/$apiCmpCode'));
        print('Companies deleted from API: $apiCmpCode');
    }
}
         
          
        }
      } else {
        print('Failed to fetch companies  from API');
      }
    } catch (e) {
      print('Error updating API companies   group: $e');
    }
  }



Future<void> _updateFirestoreUsersSalesEmployees(List<UserSalesEmployees> usersalesemployees) async {
 try {
  print('mbvcccc');
      var userSalesEmployeesBox = await Hive.openBox<UserSalesEmployees>('userSalesEmployeesBox');



      // Fetch user data from the API
      var response = await http.get(Uri.parse('http://5.189.188.139:8080/api/userssalesemployees'));
      print(response.body);
      if (response.statusCode == 200) {
        List<dynamic> apiUser = jsonDecode(response.body);
 
print(apiUser);
        // Iterate through each user to determine if it should be added, updated, or deleted
        print('?????');
        for (UserSalesEmployees userSales in userSalesEmployeesBox.values) {
          print('####');
          var userGroupData = userSalesEmployeesBox.get('${userSales.userCode}${userSales.cmpCode}${userSales.seCode}');
          print('hi');
          print(userGroupData);
          var existingUserGroup;
          if(apiUser!=null){
               existingUserGroup = apiUser.firstWhere((user) => user['userCode'] == userSales.userCode && user['cmpCode']==userSales.cmpCode && user['seCode']==userSales.seCode, orElse: () => null);
          }
                     print('jelo');
print(userGroupData?.cmpCode);
          if (userGroupData != null) {
            // Check if user exists in API response
            print('fomocs');
print(existingUserGroup);
            if (existingUserGroup != null) {
              // User exists, update user data
              final response = await http.put(
                Uri.parse('http://5.189.188.139:8080/api/userssalesemployees/updateUsersSalesEmployees/${existingUserGroup['userCode']}/${existingUserGroup['cmpCode']}/${existingUserGroup['seCode']}'),
                body: jsonEncode(userGroupData.toJson()),
                headers: {'Content-Type': 'application/json'},
              );
              print(response.statusCode);
              print(response.body);
              print('Companies  Group updated: $userGroupData');
            } else {
              print('riccc');
              // User does not exist, add new user
              await http.post(
                Uri.parse('http://5.189.188.139:8080/api/userssalesemployees/insertUsersSalesEmployees'),
                body: jsonEncode(userGroupData.toJson()),
                headers: {'Content-Type': 'application/json'},
              );
              print('Companies   added: $usersalesemployees');
            }
          } 

  List<String> hivUsersSalesEmployees= userSalesEmployeesBox.keys.cast<String>().toList();
print(hivUsersSalesEmployees);
// Compare the list of users from Hive with the list of users from the API
for (dynamic apiUsers in apiUser) {
    String apiCmpCode = apiUsers['cmpCode'];
    String apiUserCode = apiUsers['userCode'];
    String apiSeCode = apiUsers['seCode'];
String apiKey = '${apiUserCode}${apiCmpCode}${apiSeCode}';
    // Check if the user exists in Hive
    if (!hivUsersSalesEmployees.contains(apiKey)) {
        // User exists in the API but not in Hive, delete from API
              await http.delete(Uri.parse('http://5.189.188.139:8080/api/userssalesemployees/deleteUsersSalesEmployees/$apiUserCode/$apiCmpCode/$apiSeCode'));
        print('Users Sales Employees deleted from API: $apiCmpCode');
    }
}
         
          
        }
      } else {
        print('Failed to fetch Users Sales EMployees  from API');
      }
    } catch (e) {
      print('Error updating API Users Sales Employees   group: $e');
    }
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
