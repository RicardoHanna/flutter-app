import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:project/app_notifier.dart';
import 'package:project/classes/numeriqrangeformatters.dart';
import 'package:project/hive/translations_hive.dart';
import 'package:project/screens/admin_users_page.dart';
import 'package:validators/validators.dart';
import 'package:project/classes/validations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:project/classes/Languages.dart';

class EditUserForm extends StatefulWidget {
  final int usercode;
  final String username;
  final String userFname;
  final String email;
  final String password;
  final String warehouse;
  final int usergroup;
  final int font;
  final String languages;
  final bool active;
  final String phonenumber;
  final String imeicode;
  final AppNotifier appNotifier;

  EditUserForm({
    required this.usercode,
    required this.username,
    required this.userFname,
    required this.email,
    required this.password,
    required this.phonenumber,
    required this.imeicode,
    required this.warehouse,
    required this.usergroup,
    required this.font,
    required this.languages,
    required this.active,
    required this.appNotifier
  
  });

  @override
  _EditUserFormState createState() => _EditUserFormState();
}

class _EditUserFormState extends State<EditUserForm> {
    TextEditingController _usernameFController = TextEditingController();
      TextEditingController _usercodeController = TextEditingController();
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
String _selectedLanguage = 'English';
List<String> userGroups = [];
  bool isInitialized = false;
String username='';
      bool _formChanged = false; // Added to track changes

 TextStyle _appTextStyle=TextStyle();
@override
void initState() {
  super.initState();
  // Initialize the controllers with the existing username and email
  _usercodeController.text=widget.usercode.toString();
   _usernameFController.text = widget.userFname;
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
   
}

   @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Access inherited widgets or perform initialization based on inherited widgets here
   fetchUserGroups();
  getUsernameByCode(int.parse(_selectedUserGroup));

   if (!isInitialized) {
      if(AppLocalizations.of(context)!.language=='العربية'){
      
         if(_selectedLanguage=='English'){
          _selectedLanguage='إنجليزي';
        }else if(_selectedLanguage=='Arabic'){
          _selectedLanguage='عربي';
        }
      }
      isInitialized = true;
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
  return username = translation.translations[language] ?? usercode.toString();

    // Close the Hive box
  
  
  } catch (e) {
    print('Error retrieving username: $e');
    return null; // or throw an exception if appropriate
  }
}


  @override
  Widget build(BuildContext context) {
     _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    return WillPopScope(
        onWillPop: () async {
       if (_formChanged) {
          // Show the discard changes dialog only if there are changes
          return await _showDiscardChangesDialog();
        } else {
          // If no changes, allow popping without showing the dialog
          return true;
        }
      },
      child: Scaffold(
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
            keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
            controller: _usercodeController,
             onChanged: (value) {
                    _formChanged = true; 
                  },
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.usercode),
          ),
          TextField(
            style: _appTextStyle,
            controller: _usernameController,
             onChanged: (value) {
                    _formChanged = true; 
                  },
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.username),
          ),
              TextField(
            style: _appTextStyle,
            controller: _usernameFController,
             onChanged: (value) {
                    _formChanged = true; 
                  },
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.userFname),
          ),
          SizedBox(height: 12),
          TextField(
            style: _appTextStyle,
            controller: _emailController,
             onChanged: (value) {
                    _formChanged = true; 
                  },
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.email),
          ),
          SizedBox(height: 12),
          TextField(
            style: _appTextStyle,
            controller: _passwordController,
             onChanged: (value) {
                    _formChanged = true; 
                  },
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
             onChanged: (value) {
                    _formChanged = true; 
                  },
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
             onChanged: (value) {
                    _formChanged = true; 
                  },
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.imeiNumber),
          ),
          SizedBox(height: 12),
          TextField(
            style: _appTextStyle,
            controller: _warehouseController,
             onChanged: (value) {
                    _formChanged = true; 
                  },
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
          child: DropdownButtonFormField<String>(
          value: username,
          onChanged: (String? newValue) {
            setState(() {
          username = newValue!;
          _formChanged=true;
          print(username);
            });
          },
          items: [
                      ...userGroups.map((String userGroup) {
                        return DropdownMenuItem<String>(
                          value: userGroup,
                          child: Text(userGroup, style: _appTextStyle,),
                        );
                      }),
                    ],
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.usergroup),
          hint: Text(
          AppLocalizations.of(context)!.usergroup,
          style: _appTextStyle,
        ),
        ),
        ),
    
          SizedBox(height: 16),
        Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Text(
        AppLocalizations.of(context)!.font,
        style: _appTextStyle,
      ),
      SizedBox(height: 8.0),
      Slider(
        value: _fontController.text.isEmpty ? 1.0 : double.parse(_fontController.text),
        min: 12.0,
        max: 30.0,
        divisions: 29,
        onChanged: (double value) {
          setState(() {
            _fontController.text = value.toInt().toString();
            _formChanged=true;
          });
        },
      ),
      SizedBox(height: 8.0),
     Center(
        child: Text(
          _fontController.text, // Display the selected font size
          style: _appTextStyle,
        ),
     ),
      ],
    ),
    
          SizedBox(height: 16),
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
               child: DropdownButtonFormField<String>(
      value: _selectedLanguage,
      onChanged: (String? newValue) {
      setState(() {
        _selectedLanguage = newValue!;
        _formChanged=true;
      });
      },
      items: Language.languageList().map<DropdownMenuItem<String>>((lang) {
      final String languageName =
          AppLocalizations.of(context)!.language == 'English'
              ? lang.name
              : lang.nameInArabic;
    
      return DropdownMenuItem<String>(
        value: languageName,
        child: Row(
          children: <Widget>[
            Text(languageName, style: _appTextStyle),
          ],
        ),
      );
      }).toList(),
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.languages),
                        hint: Text(
          AppLocalizations.of(context)!.usergroup,
          style: _appTextStyle,
        ),
                      ),
              ),
        Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(AppLocalizations.of(context)!.active,style: _appTextStyle),
          SizedBox(width: 10),
          Switch(
            value: _isActive,
            onChanged: (bool newValue) {
              setState(() {
                _isActive = newValue;
                _formChanged=true;
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
                int.parse(_usercodeController.text),
                _usernameController.text,
                _usernameFController.text,
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
            child: Text(AppLocalizations.of(context)!.update,style: _appTextStyle),
          ),
        ],
      ),
      ),
    ),
    
      ),
    );
  }

  
Future<bool> _showDiscardChangesDialog() async {
  bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Discard Changes'),
        content: Text('Are you sure you want to discard the changes?'),
        actions: <Widget>[
          TextButton(
            child: Text('No'),
            onPressed: () {
              Navigator.of(context).pop(false); // Return false
            },
          ),
          TextButton(
            child: Text('Yes'),
            onPressed: () {
              Navigator.of(context).pop(true); // Return true
              Navigator.of(context).pop(); // Close the current page
            },
          ),
        ],
      );
    },
  );

  // If the dialog is dismissed, return false as a default value
  return result ?? false;
}


  void _updateUser(
    String oldUsername,
    int newUsercode,
    String newUsername,
    String newFUsername,
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
 String language = AppLocalizations.of(context)!.language == 'English' ? 'en' : 'ar';
 
var translationsBox = await Hive.openBox<Translations>('translationsBox');

// Perform a Hive query to find the translation by username
var translation = translationsBox.values.firstWhere(
  (t) => t.translations[language] == username,
  orElse: () => Translations(usercode: 1, translations: {}), // Provide a default value
);

// Now, you can safely use the translation
userSelectGroup = translation.usercode;

print(userSelectGroup);

      }

      if(newLanguages=='إنجليزي') newLanguages='English'; else newLanguages='Arabic';

    try {
    var userBox = await Hive.openBox('userBox');

    // Retrieve user data from Hive box based on email
    String userEmail = widget.email;
    var user = userBox.get(userEmail) as Map<dynamic, dynamic>?;

    // If the user is found, update the fields
    if (user != null) {
     user['usercode']=newUsercode;
      user['username'] = newUsername;
      user['userFname'] = newFUsername;
      user['email'] = newEmail;
      user['password'] = newPassword;
      user['phonenumber'] = newPhoneNumber;
      user['imeicode'] = newImeiCode;
      user['warehouse'] = newWarehouse;
      user['usergroup'] = userSelectGroup;
      user['font'] = newFont;
      user['languages'] = newLanguages;
      user['active'] = newisActive;

      // Put the updated user data back into the Hive box
      await userBox.put(userEmail, user);
      
    }

  } catch (e) {
    print('Error updating local database: $e');
  }
 ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(AppLocalizations.of(context)!.userUpdated,style: _appTextStyle)),
             );
      // Navigate back to the admin page after updating
    Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => AdminUsersPage(appNotifier: widget.appNotifier),
  ),
);

    
  }
}
