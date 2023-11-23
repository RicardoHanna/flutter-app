import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:validators/validators.dart';
import 'package:project/classes/validations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsEditUserForm extends StatefulWidget {
  final String email;
  final String password;


  SettingsEditUserForm({
    required this.email,
    required this.password,
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
 String username = 'Admin'; // Set it to a default value that exists in userGroups
  String _selectedUserGroup = '0'; // Initialize to a default value

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
    fetchUserGroups();
    //getUsernameByCode(_selectedUserGroup);
  }

  void _loadUserPreferences() async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('email', isEqualTo: widget.email)
        .where('password', isEqualTo: widget.password)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var userDocument = querySnapshot.docs.first.data() as Map<String, dynamic>;

      String userName = userDocument['username'] ?? _usernameController;
      String userEmail = userDocument['email'] ?? _emailController;
      String password = userDocument['password'] ?? _passwordController;
      String phoneNumber = userDocument['phonenumber'] ?? _phonenumberController;
      String imeiCode = userDocument['imeicode'] ?? _imeicodeController;
      String warehouse = userDocument['warehouse'] ?? _warehouseController;
      int userGroup = userDocument['usergroup'] ?? _selectedUserGroup;
      bool active = userDocument['active'] ?? _isActive;

      // Wait for the result of getUsernameByCode
      String? retrievedUsername = await getUsernameByCode(userGroup);
      if (retrievedUsername != null) {
        setState(() {
          _usernameController.text = userName;
          _emailController.text = userEmail;
          _passwordController.text = password;
          _phonenumberController.text = phoneNumber;
          _imeicodeController.text = imeiCode;
          _warehouseController.text=warehouse;
          _selectedUserGroup = userGroup.toString();
          _isActive = active;
        });
      }
    }
  } catch (e) {
    print('Error loading user preferences: $e');
  }
}


 Future<void> fetchUserGroups() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('usergroup').get();

      List<String> fetchedUserGroups =
          querySnapshot.docs.map((doc) => doc['username'] as String).toList();

      print('Fetched user groups: $fetchedUserGroups');

      // Update the userGroups list
      setState(() {
        userGroups = [...fetchedUserGroups];
      });
      
    } catch (e) {
      print('Error fetching user groups: $e');
    }
  }
  Future<String?> getUsernameByCode(int usercode) async {
    print(usercode);
  try {
    // Query the "usergroup" collection for the provided usercode
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('usergroup')
        .where('usercode', isEqualTo: usercode)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Retrieve the username from the first document in the result
       username = querySnapshot.docs.first['username'];

      return username;
     
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
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.editUserForm),
      ),
    body: SingleChildScrollView(
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _usernameController,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.username),
        ),
        SizedBox(height: 12),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.email),
        ),
        SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.password),
        ),
        SizedBox(height: 12),
        TextField(
           keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ], 
          controller: _phonenumberController,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.phoneNumber),
        ),
        SizedBox(height: 12),
         TextField(
           keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ], 
          controller: _imeicodeController,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.imeiNumber),
        ),
        SizedBox(height: 12),
        TextField(
          controller: _warehouseController,
          decoration: InputDecoration(labelText:AppLocalizations.of(context)!.warehouse),
        ),
        SizedBox(height: 12),
      DropdownButtonFormField<String>(
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
                      child: Text(userGroup),
                    );
                  }),
                ],
  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.usergroup),
),

  
      Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        Text(AppLocalizations.of(context)!.active,
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
          child: Text(AppLocalizations.of(context)!.update),
        ),
      ],
    ),
  ),
),

    );
  }

  void _updateUser(
    String oldEmail,
    String newUsername,
    String newEmail,
    String newPassword,
    String newPhoneNumber,
     String newImeiCode,
    String newWarehouse,
     bool newisActive,


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
      // Query for the document with the old username
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
          'phonenumber':newPhoneNumber,
           'imeicode':newImeiCode,
          'warehouse': newWarehouse,
          'active': newisActive,
        });
      } else {
        print('Document with email $oldEmail not found.');
      }
 ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(AppLocalizations.of(context)!.userUpdated)),
             );
      // Navigate back to the admin page after updating
      Navigator.pop(context);
    } catch (e) {
      print('Error updating user: $e');
    }
  }
}
