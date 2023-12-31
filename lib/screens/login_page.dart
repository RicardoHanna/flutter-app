import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:project/Synchronize/DataSynchronizerFromFirebaseToHive.dart';
import 'package:project/app_notifier.dart';
import 'package:project/screens/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validators/validators.dart';
import 'package:project/screens/welcome_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:project/app_notifier.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class LoginPage extends StatefulWidget {
  final AppNotifier appNotifier;
  const LoginPage({required this.appNotifier});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
bool _rememberMe = false;
 DataSynchronizerFromFirebaseToHive synchronizer = DataSynchronizerFromFirebaseToHive();


 @override
  void initState() {
    super.initState();
    // Load saved login information from SharedPreferences
    _loadSavedLoginInfo();
  }

void _loadSavedLoginInfo() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String storedEmail = prefs.getString('identifier') ?? '';
  String storedPassword = prefs.getString('password') ?? '';

  setState(() {
    _emailController.text = storedEmail;
    _passwordController.text = storedPassword;
    if (storedEmail.isNotEmpty && storedPassword.isNotEmpty) {
      _rememberMe = true;
    } else {
      _rememberMe = false;
    }
  });
}

Future<void> _loginLocalDatabase(String identifier, String password) async {
  var userBox = await Hive.openBox('userBox');

  String identifierField = 'email'; // Default to email
  if (isEmail(identifier)) {
    identifierField = 'email';
  } else if (isInt(identifier)) {
    identifierField = 'usercode';
  } else {
    identifierField = 'username';
  }

  if (_rememberMe) {
    // Save the login information locally using SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('identifier', identifier);
    prefs.setString('password', password);
  } else {
    // Clear the saved login information when "Remember Me" is unchecked
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('identifier');
    prefs.remove('password');
  }

  // Print or log all data in the local database for debugging
  print('All data in local database: ${userBox.values.toList()}');

  await synchronizer.synchronizeDataUserGroup();
  await synchronizer.synchronizeDataUserGroupTranslations();

  // Retrieve user data from Hive based on identifier and password
  var userData;
print(identifierField);
  try {
    userData = userBox.values.firstWhere(
      (user) =>
          user is Map &&
          user[identifierField] == identifier &&
          user['password'] == password,
      orElse: () => {
        'email': '',
        'password': '',
       
        // Add other default values here
      },
    );
  } catch (e) {
    print('Error retrieving user data: $e');
    // Handle the error as needed
    return;
  }

  // Print or log the user data for debugging
  print('User data from local database: $userData');

   if (userData[identifierField] != null) {
    print('loo');
  String userLanguage = userData['languages'];
  int userFont = userData['font'];
  String email = userData['email'] ?? ''; // Initialize with an empty string

  print('Identifier: $identifierField');
  print('Value: $identifier');
  print('Language: $userLanguage');
  print('Password: ${userData['password']}');

  if (userBox.containsKey(email.toLowerCase()) &&
      userBox.get(email.toLowerCase())?['password'] == password) {
    // User found in the local database, proceed with login
    String userLanguage = userBox.get(email.toLowerCase())?['languages'];
    int userFont = userBox.get(email.toLowerCase())?['font'];
    email = userBox.get(email.toLowerCase())?['email'] ?? ''; // Reassign the variable

    if (userLanguage == 'English') {
      Provider.of<AppNotifier>(context, listen: false).updateLocale(Locale('en'));
    } else {
      Provider.of<AppNotifier>(context, listen: false).updateLocale(Locale('ar'));
    }

    Provider.of<AppNotifier>(context, listen: false).updateFontSize(userFont);

    print('hiiiiii');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => welcomePage(
          identifier: identifier,
          password: password,
          appNotifier: widget.appNotifier,
          email: email,
        ),
      ),
    );
  }else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.invalidEmail),
              ),
            );
          }
   }
 else {
      print('kooo');
      // User not found in the local database, fetch from Firebase
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        try {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('Users')
              .where(identifierField, isEqualTo: identifier)
              .where('password', isEqualTo: password)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            DocumentSnapshot userDoc = querySnapshot.docs.first;

            var userData = {
              'usercode': userDoc.get('usercode'),
              'username': userDoc.get('username'),
              'userFname': userDoc.get('userFname'),
              'email': userDoc.get('email'),
              'password': userDoc.get('password'),
              'phonenumber': userDoc.get('phonenumber'),
              'imeicode': userDoc.get('imeicode'),
              'warehouse': userDoc.get('warehouse'),
              'usergroup': userDoc.get('usergroup'),
              'font': userDoc.get('font'),
              'languages': userDoc.get('languages'),
              'active': userDoc.get('active'),
            };
String _emailkey=userDoc.get('email');
            // Add the user to the local Hive box
            userBox.put(_emailkey, userData);

            // Proceed with login for the new user
            String userLanguage = userData['languages'];
            int userFont = userData['font'];

            if (userLanguage == 'English') {
              Provider.of<AppNotifier>(context, listen: false).updateLocale(Locale('en'));
            } else {
              Provider.of<AppNotifier>(context, listen: false).updateLocale(Locale('ar'));
            }

            Provider.of<AppNotifier>(context, listen: false).updateFontSize(userFont);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => welcomePage(
                  identifier: identifier,
                  password: password,
                  appNotifier: widget.appNotifier,
                  email: _emailkey,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.invalidEmail),
              ),
            );
          }
        } catch (e) {
          print("Error: $e");
        }
      } else {
        // Handle the case when there is no internet connection
        print('No internet connection. Cannot fetch user from Firebase.');
        // You may want to display a message to the user or handle this case differently
      }
    }
}





  @override
  Widget build(BuildContext context) {
    TextStyle _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
        TextStyle _appRemTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble()-5);
    TextStyle _SappTextStyle =
        TextStyle(fontSize: widget.appNotifier.fontSize.toDouble(), fontWeight: FontWeight.bold);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.network(
                'https://assets6.lottiefiles.com/packages/lf20_k9wsvzgd.json',
                animate: true,
                height: 120,
                width: 600,
              ),
              Text(
                AppLocalizations.of(context)!.login,
                style: _SappTextStyle,
              ),
              const SizedBox(height: 30),
              Container(
                width: MediaQuery.of(context).size.width / 1.1,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                 
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 20),
                      child: TextFormField(
                        controller: _emailController,
                        style: _appTextStyle,
                        onChanged: (val) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.blue,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          labelText: AppLocalizations.of(context)!.emailusercodeusername,
                          hintText: 'your-email@domain.com',
                          labelStyle: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
            
                    Padding(
                      
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Form(
                        key: _formKey,
                        child: TextFormField(
                          style: _appTextStyle,
                          controller: _passwordController,
                          obscuringCharacter: '*',
                          obscureText: true,
                          decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.key,
                              color: Colors.blue,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            labelText: AppLocalizations.of(context)!.password,
                            hintText: '*********',
                            labelStyle: TextStyle(color: Colors.blue),
                          ),
                          
                          validator: (value) {
                            if (value!.isEmpty && value.length < 5) {
                              return AppLocalizations.of(context)!.validPassword;
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    CheckboxListTile(
                    title: Text(
                      AppLocalizations.of(context)!.rememberMe,
                      style: _appRemTextStyle,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _rememberMe,
                    onChanged: (bool? value) {
                      setState(() {
                        _rememberMe = value!;
                      });
                    },
                  ),
                  SizedBox(height: 20,),
                    ElevatedButton(
  style: ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    backgroundColor: Colors.blue,
        fixedSize: Size(250, 20), // Adjust the width and height as needed

  ),
  onPressed: () async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.processingData,
            style: _appTextStyle,
          ),
        ),
      );
    }
int userC=0;
   String identifier = _emailController.text.trim(); // Use email by default
if (isEmail(identifier)) {
  // If it's a valid email, use email
  identifier = _emailController.text.trim();
} else if (isNumeric(identifier)) {
 
    identifier = _emailController.text.trim();
 
} else {
  // If it's not an email or numeric, assume it's a username
  identifier = _emailController.text.trim();
}

print('hids'+identifier);

String password = _passwordController.text.trim();

await _loginLocalDatabase(identifier, password);


 if (_rememberMe) {
          // Save the login information locally using SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('identifier', identifier);
          prefs.setString('password', password);
        }
  },
  child: Text(
    AppLocalizations.of(context)!.login,
    style: _appTextStyle,
  ),
),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}