import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_launcher_icons/utils.dart';
import 'package:project/app_notifier.dart';
import 'package:project/hive/translations_hive.dart';
import 'package:provider/provider.dart';
import 'package:validators/validators.dart';
import 'package:project/classes/validations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';



class SettingsEditUserForm extends StatefulWidget {
  final String usercode;
  final String password;
  final AppNotifier appNotifier;


  SettingsEditUserForm({
    required this.usercode,
    required this.password, required this.appNotifier,
  });

  @override
  _SettingsEditUserFormState createState() => _SettingsEditUserFormState();
}

class _SettingsEditUserFormState extends State<SettingsEditUserForm> {
    TextEditingController _usercodeController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
   TextEditingController _userFnameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  TextEditingController _phonenumberController=TextEditingController();
  TextEditingController _imeicodeController=TextEditingController();
  bool _isActive = false; // Assuming default value is false
  List<String> userGroups = [];
 String username = ''; // Set it to a default value that exists in userGroups
  String _selectedUserGroup = '0'; // Initialize to a default value
 String _selectedLanguage = 'English';
  int _selectedFont = 16;
    late TextStyle _appTextStyle;
      bool _formChanged = false; // Added to track changes

@override
void initState() {
  super.initState();
      _appTextStyle = TextStyle(fontSize: _selectedFont.toDouble());

}

  

@override
void didChangeDependencies() async {
  super.didChangeDependencies();
 if(_selectedLanguage=='Arabic') _selectedLanguage='عربي';
  await Future.delayed(Duration.zero, () async {
    await _loadUserPreferences();
    await fetchUserGroups();
       _appTextStyle = TextStyle(fontSize: _selectedFont.toDouble());
await _loadUserLangFontPreferences();
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
String? userCode = widget.usercode;

// Retrieve user data using the email as the key
var user = userBox.get(userCode) as Map<dynamic, dynamic>?;

// Use the retrieved user data as needed
  String? usercode = user?['usercode'];
  String? userFname = user?['userFname'];
  String? userName = user?['username'];
  String? password = user?['password'];
 String? phoneNumber = user?['phonenumber'];
  String? imeiCode = user?['imeicode'];
  int? userGroup = user?['usergroup'];
   bool? active = user?['active'];
   String? email =user?['email'];

    if (userName != null && mounted) {
      // Wait for the result of getUsernameByCode
    
      if (mounted) {
        setState(() {
          _usercodeController.text=usercode ?? '' ;
          _userFnameController.text = userFname??'';
          _usernameController.text = userName;
          _emailController.text = email ?? '';
          _passwordController.text = password ?? '';
          _phonenumberController.text = phoneNumber ?? '';
          _imeicodeController.text = imeiCode ?? '';
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


  Future <void> _loadUserLangFontPreferences() async {
String userLanguage='';
 int userFont=0 ;

var userBox = await Hive.openBox('userBox');
       dynamic userDataDynamic = userBox.get(widget.usercode);
       if (userDataDynamic != null) {
      // Update the font size locally
   userLanguage  =  userDataDynamic['languages'] ?? _selectedLanguage;
  userFont=  userDataDynamic['font']?? _selectedFont;

       }


    try {
    
if(userLanguage=='Arabic') userLanguage='عربي';

        // Update the state with the user's preferences
        setState(() {
          _selectedFont = userFont;
          _selectedLanguage = userLanguage;
         
        });
        print(_selectedLanguage);
   
    } catch (e) {
      print('Error loading user preferences: $e');
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
Future<String?> getUsernameByCode(int groupcode) async {
  String language = AppLocalizations.of(context)!.language == 'English' ? 'en' : 'ar';

  try {
    var translationsBox = await Hive.openBox<Translations>('translationsBox');

    // Look for a translation with the specified usercode
    var translation = translationsBox.values.firstWhere(
      (t) => t.groupcode == groupcode,
      orElse: () => Translations(groupcode: 0, translations: {}), // Default translation when not found
    );

    // Close the Hive box
 

    // Retrieve the username from the translation
    return translation.translations[language] ?? groupcode.toString();
  } catch (e) {
    print('Error retrieving username: $e');
    return null; // or throw an exception if appropriate
  }
}



  @override
  Widget build(BuildContext context) {
  TextStyle _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
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
          AbsorbPointer(
          absorbing: true,
            child: TextField(
              style: _appTextStyle,
             
              controller: _usercodeController,
                onChanged: (value) {
                      _formChanged = true; 
                    },
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.usercode),
            ),
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
            controller: _userFnameController,
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
       SizedBox(height: 12.0),
        _buildLanguageDropdown(context),
                SizedBox(height: 12.0),
                   _buildFontTextField(context),
        Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(AppLocalizations.of(context)!.active,style: _appTextStyle
          ),
          SizedBox(width: 10),
          AbsorbPointer(
            absorbing: true,
            child: Switch(
              value: _isActive,
              onChanged: (bool newValue) {
                setState(() {
                  _isActive = newValue;
                  _formChanged=true;
                });
                
                
              },
            ),
          ),
        ],
      ),
      ),
          ElevatedButton(
            onPressed: () {
              _updateUser(
               widget.usercode,
             _usercodeController.text,
                _usernameController.text,
                _userFnameController.text,
                _emailController.text,
                _passwordController.text,
                _phonenumberController.text,
                _imeicodeController.text,
                _selectedLanguage,
                _isActive,
                _selectedFont,
    
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

Widget _buildLanguageDropdown(BuildContext context) {
  TextStyle _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
  return Theme(
    data: Theme.of(context).copyWith(
      textTheme: TextTheme(
        subtitle1: TextStyle(
          fontSize: widget.appNotifier.fontSize.toDouble(),
          color: Colors.black,
        ),
      ),
    ),
    child: DropdownButtonFormField<String>(
      value: _selectedLanguage,
      onChanged: (String? newValue) async {
        if (_selectedLanguage != newValue) {
          setState(() {
            _selectedLanguage = newValue!;
            _formChanged=true;
          });

      
         

       
        }
      },
      items: ['English', 'عربي'].map((String userLang) {
        return DropdownMenuItem<String>(
          value: userLang,
          child: Text(userLang, style: _appTextStyle),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.languages,
      ),
      hint: Text(
        AppLocalizations.of(context)!.languages,
        style: _appTextStyle,
      ),
      isExpanded: true,
    ),
  );
}

Widget _buildFontTextField(BuildContext context) {
  TextStyle _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    SizedBox(height: 8.0);
  return Column(
    mainAxisSize: MainAxisSize.max,
    crossAxisAlignment: CrossAxisAlignment.start, 
    children: [
      Text(
        AppLocalizations.of(context)!.font,
         style: _appTextStyle,
      ),
      SizedBox(height: 8.0),
      Slider(
        value: _selectedFont.toDouble(),
        min: 12.0, // Minimum font size
        max: 30.0, // Maximum font size
        divisions: 29, // Number of divisions between min and max (adjust as needed)
        onChanged: (double value) {
          setState(() {
            _selectedFont = value.toInt();
            _formChanged=true;
          });
        },
      ),
     
      Center(
        child: Text(
          '$_selectedFont', // Display the selected font size
          style: _appTextStyle,
        ),
      ),
    ],
  );
}



Future<void> _updateLocalDatabase(
  int newUserCode,
  String newUsername,
  String newUserFname,
  String newEmail,
  String newPassword,
  String newPhoneNumber,
  String newImeiCode,
  bool newIsActive,
  int newSelectedFont
) async {
  try {
    var userBox = await Hive.openBox('userBox');

    // Retrieve user data from Hive box based on email
    var user = userBox.get(_usercodeController.text) as Map<dynamic, dynamic>?;

    // If the user is found, update the fields
    if (user != null) {
      user['usercode']=newUserCode;
      user['username'] = newUsername;
      user['userFname'] = newUserFname;
      user['email'] = newEmail;
      user['password'] = newPassword;
      user['phonenumber'] = newPhoneNumber;
      user['imeicode'] = newImeiCode;
      user['active'] = newIsActive;
      user['font']=newSelectedFont;

      // Put the updated user data back into the Hive box
      await userBox.put(_usercodeController.text, user);
 
    }
  } catch (e) {
    print('Error updating local database: $e');
  }
}



  void _updateUser(
  String oldEmail,
  String newUserCode,
  String newUsername,
  String newUserFname,
  String newEmail,
  String newPassword,
  String newPhoneNumber,
  String newImeiCode,
  String newSelectedLanguage,
  bool newIsActive,
  int newSelectedFont
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
    String userCode = widget.usercode;
    var user = userBox.get(userCode) as Map<dynamic, dynamic>?;

    // If the user is found, update the fields
    if (user != null) {
      user['usercode'] = newUserCode;
      user['username'] = newUsername;
      user['userFname']=newUserFname;
      user['email'] = newEmail;
      user['password'] = newPassword;
      user['phonenumber'] = newPhoneNumber;
      user['imeicode'] = newImeiCode;
      user['languages'] = newSelectedLanguage;
      user['active'] = newIsActive;
      user['font']=newSelectedFont;

      // Put the updated user data back into the Hive box
      await userBox.put(userCode, user);

    }
  } catch (e) {
    print('Error updating local database: $e');
  }

  

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.userUpdated)),
      );
       Provider.of<AppNotifier>(context, listen: false).setUserEmail(_emailController.text);
 await Provider.of<AppNotifier>(context, listen: false).updateLang(Locale(_selectedLanguage!));
                await Provider.of<AppNotifier>(context, listen: false)
                    .updateFontSize(_selectedFont);


          // Set the user locale after updating the language
          if (_selectedLanguage == 'English') {
            Provider.of<AppNotifier>(context, listen: false).updateLocale(Locale('en'));
          } else {
            Provider.of<AppNotifier>(context, listen: false).updateLocale(Locale('ar'));
          }
        
      // Navigate back to the admin page after updating
      Navigator.pop(context);
   
  } 
Future<bool> _showDiscardChangesDialog() async {
  bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.discardchanges),
        content: Text(AppLocalizations.of(context)!.areyousuretodiscardchanges),
        actions: <Widget>[
          TextButton(
            child: Text(AppLocalizations.of(context)!.no),
            onPressed: () {
              Navigator.of(context).pop(false); // Return false
            },
          ),
          TextButton(
            child: Text(AppLocalizations.of(context)!.yes),
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

      bool? newIsActive = userBox.get('active');

      print('Local Changes:');
      print('Username: $newUsername');
      print('Email: $newEmail');
      print('Password: $newPassword');
      print('Phone Number: $newPhoneNumber');
      print('IMEI Code: $newImeiCode');

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
