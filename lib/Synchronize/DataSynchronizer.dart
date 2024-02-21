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
                      var existingUserGroup = apiSys.firstWhere((user) => user['groupcode'] == groupCode.groupcode, orElse: () => null);
                     print('jelo');

          if (userGroupData != null) {
            // Check if user exists in API response
            print('fomocs');
print(existingUserGroup);
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
          } else {
            // User does not exist in local storage, delete user from API
            if (existingUserGroup != null) {
              await http.delete(Uri.parse('http://5.189.188.139:8080/api/systemAdmin/deleteSystemAdmin/${existingUserGroup['groupcode']}'));
              print('System Admin deleted: $groupCode');
            }
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
                      var existingUserGroup = apiComp.firstWhere((user) => user['connectionID'] == connID.connectionID, orElse: () => null);
                     print('jelo');
print(userGroupData?.connectionID);
          if (userGroupData != null) {
            // Check if user exists in API response
            print('fomocs');
print(existingUserGroup);
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
          } else {
            // User does not exist in local storage, delete user from API
            if (existingUserGroup != null) {
              await http.delete(Uri.parse('http://5.189.188.139:8080/api/companiesconnection/deleteCompaniesConnection/${existingUserGroup['connectionID']}'));
              print('Companies Connection  deleted: $connID');
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
  var existingAuthoGroup = apiCompUser.firstWhere((user) => user['userCode'] == compuser.userCode && user['cmpCode'] == compuser.cmpCode, orElse: () => null);
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
  var existingAuthoGroup = apiPrice.firstWhere((user) => user['userCode'] == pricelistautho.userCode && user['cmpCode'] == pricelistautho.cmpCode  && user['authoGroup'] == pricelistautho.authoGroup, orElse: () => null);
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
                      var existingUserGroup = apiComp.firstWhere((user) => user['cmpCode'] == cmpCode.cmpCode, orElse: () => null);
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
          } else {
            // User does not exist in local storage, delete user from API
            if (existingUserGroup != null) {
              await http.delete(Uri.parse('http://5.189.188.139:8080/api/companies/deleteCompanies/${existingUserGroup['cmpCode']}'));
              print('Companies   deleted: $companies');
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
