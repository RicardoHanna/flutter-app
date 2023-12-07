import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_launcher_icons/utils.dart';
import 'package:project/app_notifier.dart';
import 'package:project/hive/translations_hive.dart';
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
//_initializeConnectivity();

}

  

@override
void didChangeDependencies() async {
  super.didChangeDependencies();

  await Future.delayed(Duration.zero, () async {
    await _loadUserPreferences();
    await fetchUserGroups();

    // Wait for the result of getUsernameByCode
    final result = await getUsernameByCode(int.parse(_selectedUserGroup));
    if (result != null) {
      setState(() {
        username = result;
        _selectedUserGroup = result; // Assuming you want to set it here
        print(username);
      });
    }
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

    var translationsBox = await Hive.openBox<Translations>('translationsBox');

    List<String> fetchedUserGroups = translationsBox.values
        .map((translations) {
          return translations.translations[language] ?? '';
        })
        .where((translatedGroup) => translatedGroup.isNotEmpty)
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
  String language = AppLocalizations.of(context)!.language == 'English' ? 'en' : 'ar';

  try {
    var translationsBox = await Hive.openBox<Translations>('translationsBox');

    // Look for a translation with the specified usercode
    var translation = translationsBox.values.firstWhere(
      (t) => t.usercode == usercode,
      orElse: () => Translations(usercode: 0, translations: {}), // Default translation when not found
    );

    // Retrieve the username from the translation
    return translation.translations[language] ?? usercode.toString();
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

  

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.userUpdated)),
      );
      // Navigate back to the admin page after updating
      Navigator.pop(context);
   
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
