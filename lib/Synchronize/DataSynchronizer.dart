import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:project/hive/authorization_hive.dart';
import 'package:project/hive/hiveuser.dart';
import 'package:project/hive/items_hive.dart';
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

      // Check for an internet connection
      if (await hasInternetConnection()) {
        // If there's an internet connection, update or add data to Firestore
        await _updateFirestoreUsers(users);
        await _updateFirestoreUserGroup(usersGroup);
        await _updateFirestoreTranslations(translations);
        await _updateFirestoreAuthorization(authorization);
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

    // Delete users that exist in Firestore but not in Hive
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in firestoreUsers.docs) {
      String userEmail = doc['email'];

      if (!users.contains(userEmail)) {
        // User exists in Firestore but not in Hive, delete it
      //  await _firestore.collection('Users').doc(doc.id).delete();
      }
    }

    // Loop through each user and update or add to Firestore
    for (String user in users) {
      dynamic userDataDynamic = userBox.get(user);
      // Fetch other data from Hive if needed
      Map<String, dynamic>? userData =
          userDataDynamic is Map ? Map<String, dynamic>.from(userDataDynamic) : null;

      try {
        // Check if the user already exists in Firestore
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
            .collection('Users')
            .where('email', isEqualTo: userData?['email'])
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
              //'imageLink': userData?['imageLink'],
              'usergroup': userData?['usergroup'],
              'languages': userData?['languages'],
              'font': userData?['font'],
            },
          );
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
    // Loop through each user and update or add to Firestore
    for (UserGroup usergroup in usersGroup) {
   
      try {
        // Check if the user already exists in Firestore
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
            .collection('usergroup')
            .where('usercode', isEqualTo: usergroup.usercode)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Update the existing user in Firestore
          String documentId = querySnapshot.docs[0].id;
          await _firestore.collection('usergroup').doc(documentId).update(
            {
              'usercode': usergroup.usercode,
              'username': usergroup.username
            
            },
          );
        } else {
          // Add the user to Firestore if it doesn't exist
          await _firestore.collection('usergroup').add(
            {
              'usercode': usergroup.usercode,
              'username': usergroup.username
            },
          );
        }
      } catch (e) {
        print('Error updating Firestore user: $e');
      }
    }
  }

   Future<void> _updateFirestoreTranslations(List<Translations> translations) async {
    // Loop through each user and update or add to Firestore
    for (Translations translation in translations) {
   
      try {
        // Check if the user already exists in Firestore
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
            .collection('Translations')
            .where('usercode', isEqualTo: translation.usercode)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Update the existing user in Firestore
          String documentId = querySnapshot.docs[0].id;
          await _firestore.collection('Translations').doc(documentId).update(
            {
              'usercode': translation.usercode,
             'translations': {
              'en': translation.translations['en'],
              'ar': translation.translations['ar'],
            },
            
            },
          );
        } else {
          // Add the user to Firestore if it doesn't exist
          await _firestore.collection('Translations').add(
            {
              'usercode': translation.usercode,
              'translations': {
              'en': translation.translations['en'],
              'ar': translation.translations['ar'],
            },
            },
          );
        }
      } catch (e) {
        print('Error updating Firestore user: $e');
      }
    }
  }

Future<void> _updateFirestoreAuthorization(List<Authorization> authorizations) async {
  // Get all existing authorizations from Firestore
  QuerySnapshot<Map<String, dynamic>> allAuthorizationsSnapshot =
      await _firestore.collection('Authorization').get();

  // Get a list of existing group codes and menu codes in Firestore
  List<int> existingGroupCodes =
      allAuthorizationsSnapshot.docs.map((doc) => doc['groupcode'] as int).toList();
  List<int> existingMenuCodes =
      allAuthorizationsSnapshot.docs.map((doc) => doc['menucode'] as int).toList();

  // Loop through each user and update or add to Firestore
  for (Authorization authorization in authorizations) {
    try {
      // Check if the authorization already exists in Firestore
      bool authorizationExists = existingGroupCodes.contains(authorization.groupcode) &&
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
      
            await _firestore.collection('Authorization').doc(documentId).update(
              {
                'groupcode': authorization.groupcode,
                'menucode': authorization.menucode,
              },
            );
            print('Authorization updated: ${authorization.groupcode}, ${authorization.menucode}');
          
        }
      } else {
        // Add the user to Firestore if it doesn't exist
        await _firestore.collection('Authorization').add(
          {
            'groupcode': authorization.groupcode,
            'menucode': authorization.menucode,
          },
        );
        print('Authorization added: ${authorization.groupcode}, ${authorization.menucode}');
      }
    } catch (e) {
      print('Error updating Firestore authorization: $e');
    }
  }

  // Delete authorizations in Firestore that don't exist in Hive
  /*for (QueryDocumentSnapshot<Map<String, dynamic>> doc in allAuthorizationsSnapshot.docs) {
    int groupCode = doc['groupcode'] as int;
    int menuCode = doc['menucode'] as int;

    // Check if the authorization exists in the Hive list
    bool authorizationExistsInHive =
        authorizations.any((auth) => auth.groupcode == groupCode && auth.menucode == menuCode);

    if (!authorizationExistsInHive) {
      // Authorization doesn't exist in Hive, delete it from Firestore
      await _firestore.collection('Authorization').doc(doc.id).delete();
      print('Authorization deleted: $groupCode, $menuCode');
    }
  }*/
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
