import 'dart:ffi';
import 'package:project/classes/validations.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:project/classes/Languages.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserForm extends StatefulWidget {
  @override
  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController warehouseController = TextEditingController();
  final TextEditingController fontController = TextEditingController();
  final TextEditingController languageController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController imeiCodeController = TextEditingController();
  bool isActive = false;
 String selectedUserGroup = 'Admin'; // Set the default user group
  String selectedLanguage = 'English';
  List<String> userGroups = ['Admin', 'User'];
  bool isInitialized = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.userform),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextField(AppLocalizations.of(context)!.username, Icons.person, usernameController),
            _buildTextField(AppLocalizations.of(context)!.email, Icons.email, emailController),
            _buildTextField(AppLocalizations.of(context)!.password, Icons.lock, passwordController, obscureText: true),
            _buildDigits(AppLocalizations.of(context)!.phoneNumber, Icons.phone, phoneNumberController),
            _buildDigits(AppLocalizations.of(context)!.imeiNumber, Icons.code, imeiCodeController),
            _buildTextField(AppLocalizations.of(context)!.warehouse, Icons.business, warehouseController),
            _buildUserGroupDropdown(),
            _buildDigits(AppLocalizations.of(context)!.font, Icons.font_download, fontController),
            _buildUserGroupDropdownLanguages(),
            _buildUserGroupActive(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _submitForm(context);
              },
              child: Text(AppLocalizations.of(context)!.submit),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  Widget _buildDigits(String label, IconData icon, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ],
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  Widget _buildUserGroupDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedUserGroup,
        items: [
          ...userGroups.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          DropdownMenuItem<String>(
            value: 'Add',
            child: Row(
              children: [
                Icon(Icons.add),
                SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.add),
              ],
            ),
          ),
        ],
        onChanged: (String? newValue) {
          if (newValue == 'Add') {
            _addNewUserGroup(context);
          } else {
            setState(() {
              selectedUserGroup = newValue!;
            });
          }
        },
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.usergroup,
          prefixIcon: Icon(Icons.group),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  Widget _buildUserGroupDropdownLanguages() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField(
        value: selectedLanguage,
        items: Language.languageList().map<DropdownMenuItem<String>>((lang) =>
          DropdownMenuItem(
            value: lang.name,
            child: Row(children: <Widget>[Text(lang.name)]),
          ),
        ).toList(),
        onChanged: (String? value) {
          setState(() {
            selectedLanguage = value!;
          });
        },
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.languages,
          prefixIcon: Icon(Icons.language),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  Widget _buildUserGroupActive() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(AppLocalizations.of(context)!.active),
          SizedBox(width: 10),
          Switch(
            value: isActive,
            onChanged: (bool newValue) {
              setState(() {
                isActive = newValue;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Fetch user groups from the database when the form initializes
   fetchUserGroups();

    // Initialize selectedUserGroup only once
    if (!isInitialized) {
      selectedUserGroup = 'Admin';
      isInitialized = true;
    }
  }

Future<void> fetchUserGroups() async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('usergroup').get();

    List<String> fetchedUserGroups = querySnapshot.docs.map((doc) => doc['username'] as String).toList();

    print('Fetched user groups: $fetchedUserGroups');

    // Update the setState block as follows
    setState(() {
      userGroups = [ ...fetchedUserGroups];
   print(userGroups);
    });
  } catch (e) {
    print('Error fetching user groups: $e');
  }
}

  Future<void> _addNewUserGroup(BuildContext context) async {
    String? newGroup = await showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController newGroupController = TextEditingController();

        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.addUser),
          content: Column(
            children: [
              TextField(
                controller: newGroupController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.usergroup),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                String group = newGroupController.text.trim();
                if (group.isNotEmpty) {
                  Navigator.of(context).pop(group); // Return the new group
                }
              },
              child: Text(AppLocalizations.of(context)!.add),
            ),
          ],
        );
      },
    );

    if (newGroup != null && !userGroups.contains(newGroup)) {
      setState(() {
        userGroups.add(newGroup);
        selectedUserGroup = newGroup;
      });
    }
  }

  Future<int> addUserGroup(String newGroup) async {
    // Query the existing user groups to find the latest user code
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('usergroup').get();
    int latestUserCode = 0;

    if (querySnapshot.docs.isNotEmpty) {
      // Find the maximum user code
      latestUserCode = querySnapshot.docs
          .map<int>((doc) => doc['usercode'] as int)
          .reduce((value, element) => value > element ? value : element);
    }

    // Insert the new user group
    int newUserCode = latestUserCode + 1;
    await FirebaseFirestore.instance.collection('usergroup').add({
      'usercode': newUserCode,
      'username': newGroup,
    });

    return newUserCode;
  }

  Future<void> _submitForm(BuildContext context) async {
    // Retrieve values from controllers
    final String email = emailController.text;
    final String password = passwordController.text;
    final String username = usernameController.text;
    final String warehouse = warehouseController.text;
    final int font = int.parse(fontController.text);
    final String phonenumber = phoneNumberController.text;
    final String imeicode = imeiCodeController.text;

    if (!isValidEmail(email) || !isValidPassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(AppLocalizations.of(context)!.invalidEmail)),
      );
      return;
    }

    if (!isValidPhoneNumber(phonenumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(AppLocalizations.of(context)!.imeiNumber)),
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = userCredential.user!.uid;
      int userSelectGroup = 0;
      if (selectedUserGroup == 'Admin') {
        userSelectGroup = 1;
      } else if (selectedUserGroup == 'User') {
        userSelectGroup = 2;
      } else {
        int newUserGroupCode = await addUserGroup(selectedUserGroup);
        userSelectGroup = newUserGroupCode;
      }

      await FirebaseFirestore.instance.collection('Users').doc(userId).set({
        'username': username,
        'email': email,
        'password': password,
        'phonenumber': phonenumber,
        'imeicode': imeicode,
        'usergroup': userSelectGroup,
        'warehouse': warehouse,
        'font': font,
        'languages': selectedLanguage,
        'active': isActive,
      });

      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(AppLocalizations.of(context)!.userCreated)),
      );
      Navigator.of(context).pop();
    } catch (e) {
      print('Error creating user: $e');
    }
  }

  void _changeLanguage(language) {
    print(language.languageCode);
  }

  @override
  void dispose() {
    // Dispose of the controllers when the widget is disposed
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    warehouseController.dispose();
    super.dispose();
  }
}
