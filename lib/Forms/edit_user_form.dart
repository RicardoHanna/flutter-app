import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:project/app_notifier.dart';
import 'package:project/classes/numeriqrangeformatters.dart';
import 'package:project/hive/translations_hive.dart';
import 'package:project/screens/admin_page.dart';
import 'package:validators/validators.dart';
import 'package:project/classes/validations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:project/classes/Languages.dart';

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
  final AppNotifier appNotifier;

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
    required this.appNotifier
  
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
String _selectedLanguage = 'English';
List<String> userGroups = [];
  bool isInitialized = false;
String username='';
 TextStyle _appTextStyle=TextStyle();
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
    return username=translation.translations[language] ?? usercode.toString();
  } catch (e) {
    print('Error retrieving username: $e');
    return null; // or throw an exception if appropriate
  }
}


  @override
  Widget build(BuildContext context) {
     _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
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
        TextField(
           keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
            
             LimitRange(1, 30),
          FilteringTextInputFormatter.digitsOnly
        ],
          style: _appTextStyle,
          controller: _fontController,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.font),
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
          child: Text(AppLocalizations.of(context)!.update,style: _appTextStyle),
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
      user['username'] = newUsername;
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
    builder: (context) => AdminPage(appNotifier: widget.appNotifier),
  ),
);

    
  }
}
