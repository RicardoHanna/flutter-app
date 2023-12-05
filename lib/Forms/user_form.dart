import 'dart:ffi';
import 'package:hive/hive.dart';
import 'package:project/app_notifier.dart';
import 'package:project/classes/numeriqrangeformatters.dart';
import 'package:project/classes/validations.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:project/classes/Languages.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:project/hive/hiveuser.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
class UserForm extends StatefulWidget {

  final AppNotifier appNotifier;
  UserForm({required this.appNotifier});
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
 String selectedUserGroup = 'مسؤل'; // Set the default user group
  String selectedLanguage = 'English';
  List<String> userGroups = ['Admin', 'User'];
  bool isInitialized = false;
  String language='';
  
  TextStyle _appTextStyle=TextStyle();
String selectedUserGroupArabic = '';
  @override
  Widget build(BuildContext context) {
       _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
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
            _buildDigitsFont(AppLocalizations.of(context)!.font, Icons.font_download, fontController),
            _buildUserGroupDropdownLanguages(),
            _buildUserGroupActive(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _submitForm(context);
              },
              child: Text(AppLocalizations.of(context)!.submit,style: _appTextStyle),
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
        style: _appTextStyle,
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
        style: _appTextStyle,
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

Widget _buildDigitsFont(String label, IconData icon, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        style: _appTextStyle,
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
            
             LimitRange(1, 30),
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
      child: Theme(
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
                  Text(AppLocalizations.of(context)!.add,style: _appTextStyle),
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
            hintStyle: _appTextStyle,
            prefixIcon: Icon(Icons.group),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
            hint: Text(
        AppLocalizations.of(context)!.usergroup,
        style: _appTextStyle,
      ),
        ),
      ),
    );
  }

  Widget _buildUserGroupDropdownLanguages() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Theme(
         data: Theme.of(context).copyWith(
    // Set the text theme for the DropdownButtonFormField
    textTheme: TextTheme(
      subtitle1: TextStyle(
        fontSize: widget.appNotifier.fontSize.toDouble(),
        color: Colors.black,
      ),
    ),
  ),
        child: DropdownButtonFormField(
          value: selectedLanguage,
          items: Language.languageList().map<DropdownMenuItem<String>>((lang) =>
            DropdownMenuItem(
              value: AppLocalizations.of(context)!.language=='English'?lang.name:lang.nameInArabic,
              child: Row(children: <Widget>[Text( AppLocalizations.of(context)!.language=='English'?lang.name:lang.nameInArabic,style: _appTextStyle,)]),
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
            hint: Text(
        AppLocalizations.of(context)!.usergroup,
        style: _appTextStyle,
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
          Text(AppLocalizations.of(context)!.active,style: _appTextStyle,),
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

void _initializeConnectivity() {
  Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    if (result != ConnectivityResult.none) {
      _syncChangesWithFirestore();
    }
  });
}

// Call this method in your initState or didChangeDependencies


  @override
  void initState() {
    super.initState();
_initializeConnectivity();
    
   
  }

   @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Access inherited widgets or perform initialization based on inherited widgets here
    fetchUserGroups();
    if (!isInitialized) {
      selectedLanguage=AppLocalizations.of(context)!.language=='English'?'English':'إنجليزي';
      selectedUserGroup = AppLocalizations.of(context)!.language=='English'?'Admin':'مسؤل';
      userGroups=AppLocalizations.of(context)!.language=='English'?['Admin','User']:['مسؤل','مستخدم'];
      isInitialized = true;
    }
 
  }


Future<void> fetchUserGroups() async {
  try {
    // Determine the language based on the selected language in the app
    String language = AppLocalizations.of(context)!.language == 'English' ? 'en' : 'ar';

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Translations').get();

    List<String> fetchedUserGroups = querySnapshot.docs
        .map((doc) {
          Map<String, dynamic> translations = doc['translations'];
          return translations[language] as String;
        })
        .where((translatedGroup) => translatedGroup != null)
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


Future<void> _addNewUserGroup(BuildContext context) async {
  Map<String, String>? newGroupEn = await showDialog(
    context: context,
    builder: (BuildContext context) {
      TextEditingController newGroupControllerEn = TextEditingController();
      TextEditingController newGroupControllerAr = TextEditingController();
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.addUser, style: _appTextStyle),
        content: Column(
          children: [
            TextField(
              style: _appTextStyle,
              controller: newGroupControllerEn,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.usergroupen),
            ),
            TextField(
              style: _appTextStyle,
              controller: newGroupControllerAr,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.usergroupar),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cancel
            },
            child: Text(AppLocalizations.of(context)!.cancel, style: _appTextStyle),
          ),
          TextButton(
            onPressed: () async {
              String groupEn = newGroupControllerEn.text.trim();
              String groupAr = newGroupControllerAr.text.trim();

              if (groupEn.isEmpty || groupAr.isEmpty) {
                // Show an error message if either field is empty
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.bothNames)),
                );
                return;
              }

              // Check if the user group already exists
              bool groupExists = userGroups.any((existingGroup) =>
                  existingGroup.toLowerCase() == groupEn.toLowerCase());

              if (groupExists) {
                // Show an error message if the user group already exists
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.alreadyExists)),
                );
              } else {
                // Return the new group if it doesn't exist
                Navigator.of(context).pop({'en': groupEn, 'ar': groupAr});
              }
            },
            child: Text(AppLocalizations.of(context)!.add, style: _appTextStyle),
          ),
        ],
      );
    },
  );

  if (newGroupEn != null && newGroupEn['en'] != null && newGroupEn['ar'] != null) {
    setState(() {
      userGroups.add(newGroupEn['en']!);
      selectedUserGroup = newGroupEn['en']!;
      selectedUserGroupArabic = newGroupEn['ar']!;
    });
  }
}


 Future<int> addUserGroup(String newGroupEn, String newGroupAr) async {


 if(newGroupAr=='') newGroupAr=newGroupEn;
   
  int newUserCode = 0;

  // Define the language variable based on your logic
  String language = AppLocalizations.of(context)!.language == 'English' ? 'en' : 'ar';

  QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Translations').get();

  List<String> updatedUserGroups = querySnapshot.docs
      .map((doc) {
        Map<String, dynamic> translations = doc['translations'];
        return translations[language] as String;
      })
      .where((translatedGroup) => translatedGroup != null)
      .toList();

  // Update the setState block as follows
  setState(() {
    userGroups = [...updatedUserGroups];
  });

  bool groupExists = userGroups.any(
    (existingGroup) =>
        existingGroup.toLowerCase() == newGroupEn.toLowerCase() ||
        existingGroup.toLowerCase() == newGroupAr.toLowerCase(),
  );

  if (groupExists) {


    if(language=='en'){
    // Group exists, fetch user code from translations
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Translations')
        .where('translations.en', isEqualTo:newGroupEn)
        .get();
          if (querySnapshot.docs.isNotEmpty) {
  // Retrieve the username from the first document in the result
  newUserCode = querySnapshot.docs.first['usercode'];

}
    }
    else if (language=='ar'){
         QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Translations')
        .where('translations.ar', isEqualTo:newGroupAr)
        .get();
        if (querySnapshot.docs.isNotEmpty) {
  // Retrieve the username from the first document in the result
  newUserCode = querySnapshot.docs.first['usercode'];

}
    }




  } else {

    // Group doesn't exist, fetch user code from user groups collection
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('usergroup').get();
    int latestUserCode = 0;

    if (querySnapshot.docs.isNotEmpty) {
      latestUserCode = querySnapshot.docs
          .map<int>((doc) => doc['usercode'] as int)
          .reduce((value, element) => value > element ? value : element);
    }

    newUserCode = latestUserCode + 1;
    await FirebaseFirestore.instance.collection('usergroup').add({
      'usercode': newUserCode,
      'username': newGroupEn,
    });

    await FirebaseFirestore.instance.collection('Translations').add({
      'usercode': newUserCode,
      'translations': {
        'en': newGroupEn,
        'ar': newGroupAr,
      },
    });
  }

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
         SnackBar(content: Text(AppLocalizations.of(context)!.invalidNumber)),
      );
      return;
    }

    try {
    
      int userSelectGroup = 0;
      if (selectedUserGroup == 'Admin') {
        userSelectGroup = 1;
      } else if (selectedUserGroup == 'User') {
        userSelectGroup = 2;
      } else {
        int newUserGroupCode = await addUserGroup(selectedUserGroup,selectedUserGroupArabic);
        userSelectGroup = newUserGroupCode;
      }

      if(selectedLanguage=='إنجليزي') selectedLanguage='English'; else selectedLanguage='Arabic';

        await saveUserLocally(username, email, password, phonenumber, imeicode, userSelectGroup, warehouse, font,selectedLanguage,isActive);


      var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Changes will be applied when online.")),
    );
           Navigator.of(context).pop();
    return;
  }
  UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = userCredential.user!.uid;
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
         SnackBar(content: Text(AppLocalizations.of(context)!.userCreated,style: _appTextStyle)),
      );
      Navigator.of(context).pop();
    } catch (e) {
      print('Error creating user: $e');
    }
  }

Future<void> saveUserLocally(String username, String email, String password, String phonenumber, String imeicode,
    int userSelectGroup, String warehouse, int font, String selectedLanguage, bool isActive) async {
  try {
    // Open the Hive box
    final userBox = await Hive.openBox('userBox');
    print('Save Locally Add: $username, $email, $password, $phonenumber, $imeicode, $userSelectGroup, $warehouse, $font, $selectedLanguage, $isActive');
    print('Ricardo');

    // Use the user's email as a unique identifier for the key
    final userKey = email.toLowerCase(); // Use lowercase to ensure consistency
    // Add user data to the box using the unique key
    await userBox.put(userKey, {
      'username': username,
      'email': email,
      'password': password,
      'phonenumber': phonenumber,
      'imeicode': imeicode,
      'warehouse': warehouse,
      'active': isActive,
      'usergroup': userSelectGroup,
      'languages': selectedLanguage,
      'font': font,
    });
  } catch (e) {
    print('Error saving user locally: $e');
  }
}


Future<void> _syncChangesWithFirestore() async {
  print('hi');
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult != ConnectivityResult.none) {
    print('Connectivity Result: $connectivityResult');

    try {
      // Retrieve changes from the local database
      var userBox = await Hive.openBox('userBox');
      print('Hive Box Opened: ${userBox.isOpen}');

      // Get all keys in the local database
      List<String> allKeys = userBox.keys.cast<String>().toList();

      // Loop through each key and retrieve user data
      for (String key in allKeys) {
        // Retrieve user data as a dynamic map
        dynamic userDataDynamic = userBox.get(key);

        // Convert the dynamic map to Map<String, dynamic> or null
        Map<String, dynamic>? userData = userDataDynamic is Map ? Map<String, dynamic>.from(userDataDynamic) : null;

        print('hive get userData for key $key: $userData');

        // Check if userData is not null
        if (userData != null) {
          // Check if the user already exists in Firestore based on a unique identifier (e.g., email)
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('Users')
              .where('email', isEqualTo: userData['email'])
              .get();

          if (querySnapshot.docs.isEmpty) {
            // User does not exist, create a new one
            UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: userData['email'],
              password: userData['password'],
            );

            String userId = userCredential.user!.uid;

            // Update Firestore using a batch to ensure atomicity
            WriteBatch batch = FirebaseFirestore.instance.batch();
            batch.set(
              FirebaseFirestore.instance.collection('Users').doc(userId),
              userData,
            );

            // Commit the batch
            await batch.commit();

            // Remove the synced user data from the local database
           // await userBox.delete(key);

            print('Changes synced with Firestore for key $key.');
          } else {
            // User already exists, handle accordingly
            print('User already exists in Firestore for key $key.');
          }
        } else {
          // Handle the case where userData is null
          print('User data is null for key $key');
        }
      }
    } catch (e) {
      print('Error syncing changes with Firestore: $e');
    }
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
