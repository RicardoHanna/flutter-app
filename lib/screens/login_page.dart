import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:project/Synchronize/DataSynchronizerFromFirebaseToHive.dart';
import 'package:project/app_notifier.dart';
import 'package:project/classes/LoadingHelper.dart';
import 'package:project/screens/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validators/validators.dart';
import 'package:project/screens/welcome_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:project/app_notifier.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

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
  DataSynchronizerFromFirebaseToHive synchronizer =
      DataSynchronizerFromFirebaseToHive();
  late final LocalAuthentication auth;
  bool _supportState = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Load saved login information from SharedPreferences
    _loadSavedLoginInfo();
    auth = LocalAuthentication();
    auth.isDeviceSupported().then((bool isSupported) => setState(() {
          _supportState = isSupported;
        }));
  }

  Future<void> _synchronizeDatatoHive() async {
    TextStyle _appTextStyle =
        TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    try {
      // Set loading state to true before starting synchronization
      setState(() {
        _loading = true;
      });

      // Your existing synchronization logic
      DataSynchronizerFromFirebaseToHive synchronizer =
          DataSynchronizerFromFirebaseToHive();

      // Run the synchronization process

      await synchronizer.synchronizeDataUser();
      await synchronizer.synchronizeDataMenu();
      await synchronizer.synchronizeDataAuthorization();
      await synchronizer.synchronizeDataUserGroup();
      await synchronizer.synchronizeDataUserGroupTranslations();
      await synchronizer.synchronizeDataGeneralSettings();
      //await synchronizer.synchronizeUserSalesEmployees();
      await synchronizer.synchronizeDataPriceListsAutho();
      await synchronizer.synchronizeCompanies();
      await synchronizer.synchronizeDataCompaniesUsers();
      await synchronizer.synchronizeDataWarehousesUsers();
      // Simulate a delay for demonstration purposes (remove in production)
      await Future.delayed(Duration(seconds: 3));

      // Display a success message or update UI as needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Data synchronized successfully',
            style: _appTextStyle,
          ),
        ),
      );
    } catch (e) {
      // Handle errors and display an error message or update UI accordingly
      print('Error synchronizing data: $e');
    } finally {
      // Set loading state to false after synchronization
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _loginWithFingerprint(String identifier) async {
    if (_supportState) {
      // If fingerprint is supported, use fingerprint
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Using fingerprint for login."),
        ),
      );

      // Add your fingerprint login logic here
      // For now, let's assume fingerprint authentication is successful
      bool fingerprintAuthenticationSuccessful = true;

      if (fingerprintAuthenticationSuccessful) {
        // If fingerprint authentication is successful, proceed with login
        await _loginLocalDatabase(identifier, "");
      } else {
        // Handle the case where fingerprint authentication fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Fingerprint authentication failed."),
          ),
        );
      }
    } else {
      // Handle the case where fingerprint is not supported
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Fingerprint not supported."),
        ),
      );
    }
  }

  Future<void> _authenticate() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Use Your Finger to Login',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );

      print("Authenticated : $authenticated");

      if (authenticated) {
        // If fingerprint authentication is successful, proceed with fingerprint login
        String identifier =
            _emailController.text.trim(); // Use email by default
        if (isEmail(identifier)) {
          // If it's a valid email, use email
          identifier = _emailController.text.trim();
        } else if (isNumeric(identifier)) {
          identifier = _emailController.text.trim();
        } else {
          // If it's not an email or numeric, assume it's a username
          identifier = _emailController.text.trim();
        }
        LoadingHelper.configureLoading();
        LoadingHelper.showLoading(); // Show loading indicator
        await _loginLocalDatabaseWithFingerprint(identifier);
        LoadingHelper.dismissLoading(); // Dismiss loading indicator
      }
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();

    print('list od available bio :$availableBiometrics');

    if (!mounted) return;
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

  Future<void> _loginLocalDatabaseWithFingerprint(String identifier) async {
    var userBox = await Hive.openBox('userBox');

    String identifierField = 'email'; // Default to email
    if (isEmail(identifier)) {
      identifierField = 'email';
    } else if (isInt(identifier)) {
      identifierField = 'usercode';
    } else {
      identifierField = 'usercode';
    }

    // Print or log all data in the local database for debugging
    print('All data in local database: ${userBox.values.toList()}');

    await synchronizer.synchronizeDataUserGroup();
    await synchronizer.synchronizeDataUserGroupTranslations();

    // Retrieve user data from Hive based on identifier
    var userData;
    try {
      userData = userBox.values.firstWhere(
        (user) => user is Map && user[identifierField] == identifier,
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
      print('User found in local database');

      String userLanguage = userData['languages'] ?? '';
      int userFont = userData['font'] ?? '';
      String email = userData['email'] ?? ''; // Initialize with an empty string
      String usercode = userData['usercode'] ?? '';

      print('Identifier: $identifierField');
      print('Value: $identifier');
      print('Language: $userLanguage');

      if (userBox.containsKey(usercode)) {
        // User found in the local database, proceed with login
        String userLanguage = userBox.get(usercode)?['languages'];
        int userFont = userBox.get(usercode)?['font'];
        email = userBox.get(usercode)?['email'] ?? ''; // Reassign the variable

        if (userLanguage == 'English') {
          Provider.of<AppNotifier>(context, listen: false)
              .updateLocale(Locale('en'));
        } else {
          Provider.of<AppNotifier>(context, listen: false)
              .updateLocale(Locale('ar'));
        }

        Provider.of<AppNotifier>(context, listen: false)
            .updateFontSize(userFont);

        print('Login with fingerprint successful');
        if (userBox.containsKey(usercode) &&
            userBox.get(usercode)?['active'] == true) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => welcomePage(
                identifier: identifier,
                password:
                    "", // Password is empty when logging in with fingerprint
                appNotifier: widget.appNotifier,
                email: email,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User is not Active'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Finger Prints Not Detected'),
          ),
        );
      }
    } else {
      print('User not found in the local database');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.invalidEmail),
        ),
      );
      // Handle the case where the user is not found in the local database
    }
  }

  Future<void> _loginLocalDatabase(String identifier, String password) async {
    var userBox = await Hive.openBox('userBox');

    String identifierField = 'email'; // Default to email
    if (isEmail(identifier)) {
      identifierField = 'email';
    } else if (isInt(identifier)) {
      identifierField = 'usercode';
    } else {
      identifierField = 'usercode';
    }

    if (_rememberMe) {
      // Save the login information locally using SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('identifier', identifier);
      prefs.setString('password', password);
    } else {
      // Clear the saved login information when "Remember Me" is unchecked
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // prefs.remove('identifier');
      prefs.remove('password');
    }

    // Print or log all data in the local database for debugging
    print('All data in local database: ${userBox.values.toList()}');

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
    if (identifier == '' || password == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User and Password is incorrect!'),
        ),
      );
      return;
    }
    if (userData[identifierField] != null) {
      print('loo');
      String userLanguage = userData['languages'] ?? '';
      int userFont = userData['font'] ?? 0;
      String email = userData['email'] ?? ''; // Initialize with an empty string
      String usercode = userData['usercode'] ?? '';

      print('Identifier: $identifierField');
      print('Value: $identifier');
      print('Language: $userLanguage');
      print('Password: ${userData['password']}');

      if (userBox.containsKey(usercode) &&
          userBox.get(usercode)?['password'] == password) {
        // User found in the local database, proceed with login
        String userLanguage = userBox.get(usercode)?['languages'];
        int userFont = userBox.get(usercode)?['font'];
        usercode =
            userBox.get(usercode)?['usercode'] ?? ''; // Reassign the variable
        print(userLanguage);
        print('kopl');
        if (userLanguage == 'English') {
          Provider.of<AppNotifier>(context, listen: false)
              .updateLocale(Locale('en'));
        } else {
          Provider.of<AppNotifier>(context, listen: false)
              .updateLocale(Locale('ar'));
        }

        Provider.of<AppNotifier>(context, listen: false)
            .updateFontSize(userFont);

        if (userBox.containsKey(usercode) &&
            userBox.get(usercode)?['active'] == true) {
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
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User is not Active'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.invalidEmail),
          ),
        );
      }
    } else {
      print('kooo');
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        try {
          var response = await http.get(
            Uri.parse(
                'http://5.189.188.139:8080/api/getUsers?identifier=$identifier&password=$password'),
          );

          if (response.statusCode == 200) {
            var userData = jsonDecode(response.body);
            print('User data: $userData');
            String usercode = userData[0]['usercode']
                .toString(); // Ensure usercode is a string
            print('lk');
            String email =
                userData[0]['email'].toString(); // Ensure email is a string
            print('lkop');
            bool active = userData[0]['active'] == 1
                ? true
                : false; // Convert '1' to true, '0' to false
            userData[0]['active'] = active;

            // Put the user data into Hive
            userBox.put(usercode, userData);
            await _synchronizeDatatoHive();

            String userLanguage = userData[0]['languages']
                .toString(); // Ensure languages is a string
            int userFont = int.parse(userData[0]['font']
                .toString()); // Ensure font is parsed as an integer

            if (userLanguage == 'English') {
              Provider.of<AppNotifier>(context, listen: false)
                  .updateLocale(Locale('en'));
            } else {
              Provider.of<AppNotifier>(context, listen: false)
                  .updateLocale(Locale('ar'));
            }

            Provider.of<AppNotifier>(context, listen: false)
                .updateFontSize(userFont);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => welcomePage(
                  identifier: identifier, // Use usercode instead of identifier
                  password: password,
                  appNotifier: widget.appNotifier,
                  email: email,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Invalid email or password.'),
              ),
            );
          }
        } catch (e) {
          print("Error: $e");
        }
      } else {
        // Handle the case when there is no internet connection
        print('No internet connection. Cannot fetch user from API.');
        // You may want to display a message to the user or handle this case differently
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _appTextStyle =
        TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    TextStyle _appRemTextStyle =
        TextStyle(fontSize: widget.appNotifier.fontSize.toDouble() - 5);
    TextStyle _SappTextStyle = TextStyle(
        fontSize: widget.appNotifier.fontSize.toDouble(),
        fontWeight: FontWeight.bold);
    TextStyle _appFingerTextStyle =
        TextStyle(fontSize: widget.appNotifier.fontSize.toDouble() - 8);
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
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20, top: 20),
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
                          labelText: AppLocalizations.of(context)!
                              .emailusercodeusername,
                          hintText: 'your-email@domain.com',
                          labelStyle: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
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
                                labelText:
                                    AppLocalizations.of(context)!.password,
                                hintText: '*********',
                                labelStyle: TextStyle(color: Colors.blue),
                              ),
                              validator: (value) {
                                if (value!.isEmpty && value.length < 5) {
                                  return AppLocalizations.of(context)!
                                      .validPassword;
                                }
                                return null;
                              },
                            ),
                            Text(AppLocalizations.of(context)!.orfingerprints,
                                style: _appFingerTextStyle),
                            const SizedBox(
                              height: 8,
                            ),
                            GestureDetector(
                              onTap: () async {
                                _authenticate();
                              },
                              child: Icon(
                                Icons.fingerprint,
                                size: 40,
                                color: Colors.blue,
                              ),
                            ),
                          ],
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
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: Colors.blue,
                        fixedSize: Size(
                            250, 20), // Adjust the width and height as needed
                      ),
// Update your login button onPressed to call _login instead of _loginLocalDatabase
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

                        int userC = 0;
                        String identifier = _emailController.text
                            .trim(); // Use email by default
                        if (isEmail(identifier)) {
                          // If it's a valid email, use email
                          identifier = _emailController.text.trim();
                        } else if (isNumeric(identifier)) {
                          identifier = _emailController.text.trim();
                        } else {
                          // If it's not an email or numeric, assume it's a username
                          identifier = _emailController.text.trim();
                        }

                        print('hids' + identifier);

                        String password = _passwordController.text.trim();
                        LoadingHelper.configureLoading();
                        LoadingHelper.showLoading(); // Show loading indicator
                        await _loginLocalDatabase(identifier, password);

                        LoadingHelper
                            .dismissLoading(); // Dismiss loading indicator

                        if (_rememberMe) {
                          // Save the login information locally using SharedPreferences
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
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
