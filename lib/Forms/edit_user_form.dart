import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:validators/validators.dart';
import 'package:project/classes/validations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditUserForm extends StatefulWidget {
  final String username;
  final String email;
  final String password;
  final String warehouse;
  final int usergroup;
  final int font;
  final String languages;
  final bool active;
  final String phonenumber;
  final String imeicode;

  EditUserForm({
    required this.username,
    required this.email,
    required this.password,
    required this.phonenumber,
    required this.imeicode,
    required this.warehouse,
    required this.usergroup,
    required this.font,
    required this.languages,
    required this.active,
  
  });

  @override
  _EditUserFormState createState() => _EditUserFormState();
}

class _EditUserFormState extends State<EditUserForm> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _warehouseController = TextEditingController();
  String _selectedUserGroup = '0';
  TextEditingController _fontController = TextEditingController();
  TextEditingController _languageController = TextEditingController();
  bool _isActive = false; // Assuming default value is false
  TextEditingController _phonenumberController=TextEditingController();
    TextEditingController _imeicodeController=TextEditingController();
String _selectedLanguage = '';
List<String> userGroups = [];
String username='';
@override
void initState() {
  super.initState();
  // Initialize the controllers with the existing username and email
  _usernameController.text = widget.username;
  _emailController.text = widget.email;
  _passwordController.text = widget.password;
  _phonenumberController.text = widget.phonenumber;
    _imeicodeController.text = widget.imeicode;
  _warehouseController.text = widget.warehouse;
  _selectedUserGroup = widget.usergroup.toString(); // Set the default value from widget

  // Parse _fontController.text to an integer and assign it to sfont
  _fontController.text=widget.font.toString();

  _languageController.text = widget.languages;
  _isActive = widget.active;
  _selectedLanguage=widget.languages;
  fetchUserGroups();
  getUsernameByCode(int.parse(_selectedUserGroup));
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

        SizedBox(height: 16),
        TextField(
          controller: _fontController,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.font),
        ),
        SizedBox(height: 16),
            DropdownButtonFormField<String>(
          value: _selectedLanguage,
          onChanged: (String? newValue) {
            setState(() {
              _selectedLanguage = newValue!;
            });
          },
          items: ['English', 'Arabic'].map((String userLang) {
            return DropdownMenuItem<String>(
              value: userLang,
              child: Text(userLang),
            );
          }).toList(),
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.languages),
        ),
      Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        Text(AppLocalizations.of(context)!.active),
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
              widget.username,
              _usernameController.text,
              _emailController.text,
              _passwordController.text,
              _phonenumberController.text,
              _imeicodeController.text,
              _warehouseController.text,
              int.parse(_selectedUserGroup),
              int.parse(_fontController.text),
              _selectedLanguage,
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
    String oldUsername,
    String newUsername,
    String newEmail,
    String newPassword,
    String newPhoneNumber,
     String newImeiCode,
    String newWarehouse,
    int newUserGroup,
    int newFont,
    String newLanguages,
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
 int userSelectGroup = 0;
      if (username == 'Admin') {
        userSelectGroup = 1;
      } else if (username == 'User') {
        userSelectGroup = 2;
      } else {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('usergroup')
        .where('username', isEqualTo: username)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Retrieve the username from the first document in the result
       userSelectGroup = querySnapshot.docs.first['usercode'];
      }
      }

    try {
      // Query for the document with the old username
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('username', isEqualTo: oldUsername)
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
          'usergroup': userSelectGroup,
          'font': newFont,
          'languages': newLanguages,
          'active': newisActive,
        });
      } else {
        print('Document with username $oldUsername not found.');
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
