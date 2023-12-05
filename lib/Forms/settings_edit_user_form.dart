import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_launcher_icons/utils.dart';
import 'package:project/app_notifier.dart';
import 'package:validators/validators.dart';
import 'package:project/classes/validations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';



class SettingsEditUserForm extends StatefulWidget {
  final String email;
  final String password;
  final AppNotifier appNotifier;


  SettingsEditUserForm({
    required this.email,
    required this.password, required this.appNotifier,
  });

  @override
  _SettingsEditUserFormState createState() => _SettingsEditUserFormState();
}

class _SettingsEditUserFormState extends State<SettingsEditUserForm> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _warehouseController = TextEditingController();
  TextEditingController _phonenumberController=TextEditingController();
  TextEditingController _imeicodeController=TextEditingController();
  bool _isActive = false; // Assuming default value is false
  List<String> userGroups = [];
 String username = ''; // Set it to a default value that exists in userGroups
  String _selectedUserGroup = '0'; // Initialize to a default value

@override
void initState() {
  super.initState();
_initializeConnectivity();

}

  

 @override
void didChangeDependencies() async {
  super.didChangeDependencies();
  // Access inherited widgets or perform initialization based on inherited widgets here
Future.delayed(Duration.zero, () async {
    await _loadUserPreferences();
    fetchUserGroups();
    await getUsernameByCode(int.parse(_selectedUserGroup));
    print(username);
  });

}

void _initializeConnectivity() {
  Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    if (result != ConnectivityResult.none) {
      _syncChangesWithFirestore();
    }
  });
}



  Future<void> _loadUserPreferences() async {
  try {
    var userBox = await Hive.openBox('userBox');
String? userEmail = widget.email;

// Retrieve user data using the email as the key
var user = userBox.get(userEmail) as Map<dynamic, dynamic>?;

// Use the retrieved user data as needed

  String? userName = user?['username'];
  String? password = user?['password'];
 String? phoneNumber = user?['phonenumber'];
  String? imeiCode = user?['imeicode'];
  String? warehouse = user?['warehouse'];
  int? userGroup = user?['usergroup'];
   bool? active = user?['active'];

    if (userName != null && mounted) {
      // Wait for the result of getUsernameByCode
    
      if (mounted) {
        setState(() {
          _usernameController.text = userName;
          _emailController.text = userEmail ?? '';
          _passwordController.text = password ?? '';
          _phonenumberController.text = phoneNumber ?? '';
          _imeicodeController.text = imeiCode ?? '';
          _warehouseController.text = warehouse ?? '';
          _selectedUserGroup = userGroup.toString();
          _isActive = active ?? false;
        });
      }
    } else if (mounted) {
      // If user data is not found in Hive, fetch from Firestore
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: widget.email)
          .where('password', isEqualTo: widget.password)
          .limit(1)
          .get();

          print(widget.email);
          print(widget.password);

      if (querySnapshot.docs.isNotEmpty) {
        var userDocument = querySnapshot.docs.first.data() as Map<String, dynamic>;

        String userName = userDocument['username'] ?? '';
        String userEmail = userDocument['email'] ?? '';
        String password = userDocument['password'] ?? '';
        String phoneNumber = userDocument['phonenumber'] ?? '';
        String imeiCode = userDocument['imeicode'] ?? '';
        String warehouse = userDocument['warehouse'] ?? '';
        int userGroup = userDocument['usergroup'] ?? 0;
        bool active = userDocument['active'] ?? false;

        // Store user data in Hive box
      /*  await userBox.put('username', userName);
        await userBox.put('email', userEmail);
        await userBox.put('password', password);
        await userBox.put('phonenumber', phoneNumber);
        await userBox.put('imeicode', imeiCode);
        await userBox.put('warehouse', warehouse);
        await userBox.put('usergroup', userGroup);
        await userBox.put('active', active);*/

        // Wait for the result of getUsernameByCode
        String? retrievedUsername = await getUsernameByCode(userGroup);
        if (retrievedUsername != null && mounted) {
          setState(() {
            _usernameController.text = userName;
            _emailController.text = userEmail;
            _passwordController.text = password;
            _phonenumberController.text = phoneNumber;
            _imeicodeController.text = imeiCode;
            _warehouseController.text = warehouse;
            _selectedUserGroup = userGroup.toString();
            _isActive = active;
          });
        }
      }
    }
  } catch (e) {
    if (mounted) {
      print('Error loading user preferences: $e');
    }
  }
}



 Future<void> fetchUserGroups() async {
  try {
    // Determine the language based on the selected language in the app
    String language = AppLocalizations.of(context)!.language == 'English' ? 'en' : 'ar';

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Translations').get();

    List<String> fetchedUserGroups = querySnapshot.docs
        .map((doc) {
          Map<String, dynamic> translations = doc['translations'];
          return translations[language] as String;
        })
        .where((translatedGroup) => translatedGroup != null)
        .toList();

    // Update the setState block as follows
    setState(() {
      userGroups = [...fetchedUserGroups];
      print(userGroups);
    });
  } catch (e) {
    print('Error fetching user groups: $e');
  }
}
 Future<String?> getUsernameByCode(int usercode) async {
    String language=AppLocalizations.of(context)!.language=='English'?'en':'ar';
  try {
    // Query the "usergroup" collection for the provided usercode
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Translations')
        .where('usercode', isEqualTo: usercode)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Retrieve the username from the first document in the result
       Map<String, dynamic> translations = querySnapshot.docs.first['translations'];
      
      // Use the specified language to get the translation, or use the original identifier
      return username=translations[language] ?? usercode;
 
   
    } else {
      // Handle the case where no document with the provided usercode is found
      print('No user found with usercode: $usercode');
      return null; // or throw an exception if appropriate
    }
   
  } catch (e) {
    print('Error retrieving username: $e');
    return null; // or throw an exception if appropriate
  }
}


  @override
  Widget build(BuildContext context) {
  TextStyle _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.editUserForm,style: _appTextStyle),
      ),
    body: SingleChildScrollView(
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          style: _appTextStyle,
          controller: _usernameController,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.username),
        ),
        SizedBox(height: 12),
        TextField(
          style: _appTextStyle,
          controller: _emailController,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.email),
        ),
        SizedBox(height: 12),
        TextField(
          style: _appTextStyle,
          controller: _passwordController,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.password),
        ),
        SizedBox(height: 12),
        TextField(
          style: _appTextStyle,
           keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ], 
          controller: _phonenumberController,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.phoneNumber),
        ),
        SizedBox(height: 12),
         TextField(
          style: _appTextStyle,
           keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ], 
          controller: _imeicodeController,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.imeiNumber),
        ),
        SizedBox(height: 12),
        TextField(
          style: _appTextStyle,
          controller: _warehouseController,
          decoration: InputDecoration(labelText:AppLocalizations.of(context)!.warehouse),
        ),
        SizedBox(height: 12),
     Theme(
  data: Theme.of(context).copyWith(
    // Set the text theme for the DropdownButtonFormField
    textTheme: TextTheme(
      subtitle1: TextStyle(
        fontSize: widget.appNotifier.fontSize.toDouble(),
        color: Colors.black,
      ),
    ),
  ),
  child: AbsorbPointer(
    absorbing: true,
    child: DropdownButtonFormField<String>(
      value: username,
      onChanged: (String? newValue) {
        setState(() {
          username = newValue!;
          print(username);
        });
      },
      items: [
        ...userGroups.map((String userGroup) {
          return DropdownMenuItem<String>(
            value: userGroup,
            child: Text(userGroup, style: _appTextStyle),
          );
        }),
      ],
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.usergroup,
      ),
      hint: Text(
        AppLocalizations.of(context)!.usergroup,
        style: _appTextStyle,
      ),
      isExpanded: true,
       onTap: () {}, // Disable onTap
  
    ),
  ),
),
      Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        Text(AppLocalizations.of(context)!.active,style: _appTextStyle,
        ),
        SizedBox(width: 10),
        Switch(
          value: _isActive,
          onChanged: (bool newValue) {
            setState(() {
              _isActive = newValue;
            });
          },
        ),
      ],
    ),
  ),
        ElevatedButton(
          onPressed: () {
            _updateUser(
             widget.email,
              _usernameController.text,
              _emailController.text,
              _passwordController.text,
              _phonenumberController.text,
              _imeicodeController.text,
              _warehouseController.text,
              _isActive,

            );
          },
          child: Text(AppLocalizations.of(context)!.update,style: _appTextStyle),
        ),
      ],
    ),
  ),
),

    );
  }
Future<void> _updateLocalDatabase(
  String newUsername,
  String newEmail,
  String newPassword,
  String newPhoneNumber,
  String newImeiCode,
  String newWarehouse,
  bool newIsActive,
) async {
  try {
    var userBox = await Hive.openBox('userBox');

    // Retrieve user data from Hive box based on email
    String userEmail = widget.email;
    var user = userBox.get(userEmail) as Map<dynamic, dynamic>?;

    // If the user is found, update the fields
    if (user != null) {
      user['username'] = newUsername;
      user['email'] = newEmail;
      user['password'] = newPassword;
      user['phonenumber'] = newPhoneNumber;
      user['imeicode'] = newImeiCode;
      user['warehouse'] = newWarehouse;
      user['active'] = newIsActive;

      // Put the updated user data back into the Hive box
      await userBox.put(userEmail, user);
    }
  } catch (e) {
    print('Error updating local database: $e');
  }
}



  void _updateUser(
  String oldEmail,
  String newUsername,
  String newEmail,
  String newPassword,
  String newPhoneNumber,
  String newImeiCode,
  String newWarehouse,
  bool newIsActive,
) async {
  if (!isValidEmail(newEmail) || !isValidPassword(newPassword)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.invalidEmail)),
    );
    return;
  }
  if (!isValidPhoneNumber(newPhoneNumber)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.invalidNumber)),
    );
    return;
  }

  // Update the local database with the new values
  await _updateLocalDatabase(
    newUsername,
    newEmail,
    newPassword,
    newPhoneNumber,
    newImeiCode,
    newWarehouse,
    newIsActive,
  );

  // Check network connectivity
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Changes will be applied when online.")),
    );
      Navigator.pop(context);
    return;
  }

  try {
    // Query for the document with the old email
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('email', isEqualTo: oldEmail)
        .get();

    // Check if the document exists
    if (querySnapshot.docs.isNotEmpty) {
      // Update the document with the new values
      await querySnapshot.docs.first.reference.update({
        'username': newUsername,
        'email': newEmail,
        'password': newPassword,
        'phonenumber': newPhoneNumber,
        'imeicode': newImeiCode,
        'warehouse': newWarehouse,
        'active': newIsActive,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.userUpdated)),
      );
      // Navigate back to the admin page after updating
      Navigator.pop(context);
    } else {
      print('Document with email $oldEmail not found.');
    }
  } catch (e) {
    print('Error updating user: $e');
  }
}

Future<void> _syncChangesWithFirestore() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult != ConnectivityResult.none) {
    try {
      // Retrieve changes from the local database
      var userBox = await Hive.openBox('userBox');
      String? newUsername = userBox.get('username');
      String? newEmail = userBox.get('email');
      String? newPassword = userBox.get('password');
      String? newPhoneNumber = userBox.get('phonenumber');
      String? newImeiCode = userBox.get('imeicode');
      String? newWarehouse = userBox.get('warehouse');
      bool? newIsActive = userBox.get('active');

      print('Local Changes:');
      print('Username: $newUsername');
      print('Email: $newEmail');
      print('Password: $newPassword');
      print('Phone Number: $newPhoneNumber');
      print('IMEI Code: $newImeiCode');
      print('Warehouse: $newWarehouse');
      print('Is Active: $newIsActive');

      // Update Firestore with the changes based on email and password
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: newEmail)
          .where('password', isEqualTo: newPassword)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String documentId = querySnapshot.docs.first.id;

        // Update Firestore using a batch to ensure atomicity
        WriteBatch batch = FirebaseFirestore.instance.batch();
        batch.update(FirebaseFirestore.instance.collection('Users').doc(documentId), {
          'username': newUsername,
          'email': newEmail,
          'password': newPassword,
          'phonenumber': newPhoneNumber,
          'imeicode': newImeiCode,
          'warehouse': newWarehouse,
          'active': newIsActive,
        });

        // Commit the batch
        await batch.commit();

    

        print('Changes synced with Firestore.');
      } else {
        print('Document not found for email: $newEmail and password: $newPassword');
      }
    } catch (e) {
      print('Error syncing changes with Firestore: $e');
    }
  }
}


}
