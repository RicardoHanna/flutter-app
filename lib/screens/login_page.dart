import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:project/app_notifier.dart';
import 'package:project/screens/settings_page.dart';
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

Future<void> _loginLocalDatabase(String email, String password) async {
  var userBox = await Hive.openBox('userBox');

  // Print or log all data in the local database for debugging
  print('All data in local database: ${userBox.values.toList()}');

  // Retrieve user data from Hive based on email and password
  var userData;
  try {
    userData = userBox.values.firstWhere(
      (user) => user is Map && user['email'] == email && user['password'] == password,
      orElse: () => {
        'email': email,
        'password': password,
        'languages': 'English',  // Add a default language here if needed
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

  // Access and print specific values if userData is not null
  if (userData != null && userData is Map && userData['email'] == email) {
    print('Email: ${userData['email']}');
    print('Password: ${userData['password']}');
    print('Language: ${userData['languages']}');

    
 
    // Check if the entered email and password match any user in the local database
    if (userBox.containsKey(email.toLowerCase()) && userBox.get(email.toLowerCase())['password'] == password) {

            String userLanguage = userData['languages'];
                            int userFont=userData['font'];
                            if (userLanguage == 'English') {
                              Provider.of<AppNotifier>(context, listen: false).updateLocale(Locale('en'));
                            } else {
                              Provider.of<AppNotifier>(context, listen: false).updateLocale(Locale('ar'));
                            }
Provider.of<AppNotifier>(context, listen: false)
                    .updateFontSize(userFont);
      // User found in the local database, proceed with login
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => welcomePage(
            email: email,
            password: password,
            appNotifier: widget.appNotifier,
          ),
        ),
      );
    } else {
      // User not found in the local database
      TextStyle _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.invalidEmail, style: _appTextStyle),
        ),
      );
    }
  } else {
    // Handle the case where userData is null or email doesn't match
    TextStyle _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.invalidEmail, style: _appTextStyle),
      ),
    );
  }
}




  @override
  Widget build(BuildContext context) {
    TextStyle _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
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
                            color: Colors.purple,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          labelText: AppLocalizations.of(context)!.email,
                          hintText: 'your-email@domain.com',
                          labelStyle: TextStyle(color: Colors.purple),
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
                              color: Colors.purple,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            labelText: AppLocalizations.of(context)!.password,
                            hintText: '*********',
                            labelStyle: TextStyle(color: Colors.purple),
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
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: Colors.purple,
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

                        String email = _emailController.text.trim();
                        String password = _passwordController.text.trim();


  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
   await _loginLocalDatabase(
    email,
    password
  );
    return;
  }
  else{
                           
                        try {
                          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                              .collection('Users')
                              .where('email', isEqualTo: email)
                              .where('password', isEqualTo: password)
                              .get();

                          if (querySnapshot.docs.isNotEmpty) {
                            DocumentSnapshot userDoc =
                                await FirebaseFirestore.instance.collection('Users').doc(querySnapshot.docs.first.id).get();

                            String userLanguage = userDoc.get('languages');
                            int userFont=userDoc.get('font');
                            if (userLanguage == 'English') {
                              Provider.of<AppNotifier>(context, listen: false).updateLocale(Locale('en'));
                            } else {
                              Provider.of<AppNotifier>(context, listen: false).updateLocale(Locale('ar'));
                            }
Provider.of<AppNotifier>(context, listen: false)
                    .updateFontSize(userFont);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>welcomePage(
                                  email: email,
                                  password: password,
                                  appNotifier: widget.appNotifier,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!.invalidEmail, style: _appTextStyle),
                              ),
                            );
                          }
                        } catch (e) {
                          print("Error: $e");
                        }
                      }},
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