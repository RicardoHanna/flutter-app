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
import 'package:project/hive/companies_hive.dart';
import 'package:project/hive/companiesusers_hive.dart';
import 'package:project/hive/hiveuser.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project/hive/pricelist_hive.dart';
import 'package:project/hive/pricelistauthorization_hive.dart';
import 'package:project/hive/salesemployees_hive.dart';
import 'package:project/hive/translations_hive.dart';
import 'package:project/hive/usergroup_hive.dart';
import 'package:project/hive/userssalesemployees_hive.dart';
import 'package:project/screens/admin_users_page.dart';
  import 'package:multi_select_flutter/multi_select_flutter.dart';
class UserForm extends StatefulWidget {

  final AppNotifier appNotifier;
  UserForm({required this.appNotifier});
  @override
  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final TextEditingController usercodeController = TextEditingController();
  final TextEditingController userFnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController salesemployeesController = TextEditingController();
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
    List<String?> selectedSalesEmployees = [];
  TextStyle _appTextStyle=TextStyle();
String selectedUserGroupArabic = '';
 List<String> selectedCmpCodes = [];
List<String> selectedSeCodes = [];
List<String?> selectedCompanies=[];
List<String> selectedCompanyNames=[];
List <String>selectedCompanyCodes=[];
List <String?>selectedPriceList=[];
 List<String> selectedCmpCodesPriceList = [];
 List<String> selectedAuthoGroup = [];
    int defaultFontSize = 18;
    int minValue = 12;
int maxValue = 30;
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
            _buildTextField(AppLocalizations.of(context)!.usercode, Icons.code, usercodeController),
            _buildTextField(AppLocalizations.of(context)!.username, Icons.person, usernameController),
             _buildTextField(AppLocalizations.of(context)!.userFname, Icons.person_2, userFnameController),
            _buildTextField(AppLocalizations.of(context)!.email, Icons.email, emailController),
            _buildTextField(AppLocalizations.of(context)!.password, Icons.lock, passwordController, obscureText: true),
            _buildDigits(AppLocalizations.of(context)!.phoneNumber, Icons.phone, phoneNumberController),
            _buildDigits(AppLocalizations.of(context)!.imeiNumber, Icons.code, imeiCodeController),
    
            _buildUserGroupDropdown(),
            _buildUserGroupDropdownLanguages(),
             SizedBox(height: 8.0),
            _buildTextFieldDropDownSalesEmployees(),
            SizedBox(height: 8.0),

            SizedBox(height: 8.0),
            _buildTextFieldDropDownCompanies(),
            SizedBox(height: 8.0),

            SizedBox(height: 8.0),
            _buildTextFieldDropDownPriceListAutho(),
            SizedBox(height: 8.0),
            
            
              _buildDigitsFont(AppLocalizations.of(context)!.font, Icons.font_download, fontController),
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
  int currentValue = int.tryParse(controller.text) ?? defaultFontSize;

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: _appTextStyle,
      ),
      SizedBox(height: 8.0),
      Slider(
        value: currentValue.toDouble(),
        min: minValue.toDouble(),
        max: maxValue.toDouble(),
        divisions: maxValue - minValue,
        onChanged: (double value) {
          setState(() {
            currentValue = value.toInt();
            controller.text = currentValue.toString();
          });
        },
      ),
      Center(
        child: Text(
          ' ${controller.text.isEmpty ? defaultFontSize.toString() : controller.text}', // Display the selected font size or default size if not changed
          style: _appTextStyle,
        ),
      ),
    ],
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

Widget _buildTextFieldDropDownSalesEmployees() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: FutureBuilder(
      future: Future.wait([
        Hive.openBox<SalesEmployees>('salesEmployeesBox'),
        Hive.openBox<Companies>('companiesBox'),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          var salesEmployeesBox = snapshot.data![0] as Box<SalesEmployees>;
          var companyBox = snapshot.data![1] as Box<Companies>;

          List<String> salesEmployeeList = salesEmployeesBox.values
              .map((salesEmployee) {
                Companies company = companyBox.values
                    .firstWhere((company) => company.cmpCode == salesEmployee.cmpCode);
                return '${salesEmployee.seName} - ${company.cmpName}';
              })
              .toList();

          return Theme(
            data: Theme.of(context).copyWith(
              textTheme: TextTheme(
                subtitle1: TextStyle(
                  fontSize: widget.appNotifier.fontSize.toDouble(),
                  color: Colors.black,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.selectSalesEmployees,
                  style: _appTextStyle,
                ),
                SizedBox(height: 8.0),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: MultiSelectDialogField(
                    items: salesEmployeeList
                        .map((seName) => MultiSelectItem<String>(seName, seName))
                        .toList(),
                    initialValue: selectedSalesEmployees,
                  onConfirm: (List<String?> values) {
  setState(() {
    selectedSalesEmployees = values;

    // Retrieve cmpCode and seCode based on selected values
    selectedCmpCodes = [];
    selectedSeCodes = [];

    values.forEach((selectedSalesEmployee) {
      if (selectedSalesEmployee != null) {
        List<String> parts = selectedSalesEmployee.split(' - ');

        // Find Company based on cmpName
        Companies selectedCompany = companyBox.values
            .firstWhere((company) => company.cmpName == parts[1]);

        // Assign cmpCode and seCode to lists
        selectedCmpCodes.add(selectedCompany.cmpCode);
        selectedSeCodes.add(salesEmployeesBox.values
            .firstWhere((se) => se.seName == parts[0])
            .seCode);
      }
    });

    print(selectedCmpCodes);
    print(selectedSeCodes);
  });
},

                  ),
                ),
              ],
            ),
          );
        } else {
          return Container(); // You can replace this with a loading indicator
        }
      },
    ),
  );
}





Widget _buildTextFieldDropDownCompanies() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: FutureBuilder(
      future: Hive.openBox<Companies>('companiesBox'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          var companyBox = snapshot.data as Box<Companies>;

          List<String> companyList = companyBox.values
              .map((company) => company.cmpName)
              .toList();

          return Theme(
            data: Theme.of(context).copyWith(
              textTheme: TextTheme(
                subtitle1: TextStyle(
                  fontSize: widget.appNotifier.fontSize.toDouble(),
                  color: Colors.black,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.selectCompany,
                  style: _appTextStyle,
                ),
                SizedBox(height: 8.0),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: MultiSelectDialogField(
                    items: companyList
                        .map((companyName) =>
                            MultiSelectItem<String>(companyName, companyName))
                        .toList(),
                    initialValue: selectedCompanies,
                    onConfirm: (List<String?> values) {
                      setState(() {
                        selectedCompanies = values;

                        // Retrieve company codes based on selected values
                        selectedCompanyCodes = values
                            .map((selectedCompanyName) {
                              String companyName = selectedCompanyName!;
                              Companies selectedCompany = companyBox.values
                                  .firstWhere(
                                      (company) => company.cmpName == companyName);
                              return selectedCompany.cmpCode;
                            })
                            .toList();

                        print(selectedCompanyCodes);
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container(); // You can replace this with a loading indicator
        }
      },
    ),
  );
}

Widget _buildTextFieldDropDownPriceListAutho() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: FutureBuilder(
      future: Future.wait([
        Hive.openBox<PriceList>('pricelists'),
        Hive.openBox<Companies>('companiesBox'),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          var priceListsBox = snapshot.data![0] as Box<PriceList>;
          var companyBox = snapshot.data![1] as Box<Companies>;

          List<String> priceList = priceListsBox.values
    .map((pricelist) {
      Companies company = companyBox.values
          .firstWhere((company) => company.cmpCode == pricelist.cmpCode, orElse: () => Companies(
                address: '',
                cmpCode: '',
                cmpName: '',
                cmpFName: '',
                tel: '',
                mobile: '',
                fAddress: '',
                prHeader: '',
                prFHeader: '',
                prFooter: '',
                mainCurCode: '',
                prFFooter: '',
                secCurCode: '',
                rateType: '',
                issueBatchMethod: '',
                systemAdminID: '',
                notes: '',
              ));

      return '${pricelist.authoGroup ?? ''} - ${company.cmpName ?? ''}';
    })
    .toList();


              print(priceList.toList());
           

          return Theme(
            data: Theme.of(context).copyWith(
              textTheme: TextTheme(
                subtitle1: TextStyle(
                  fontSize: widget.appNotifier.fontSize.toDouble(),
                  color: Colors.black,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.selectPriceListAuthorization,
                  style: _appTextStyle,
                ),
                SizedBox(height: 8.0),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: MultiSelectDialogField(
                    items: priceList
                        .map((authoGroup) => MultiSelectItem<String>(authoGroup, authoGroup))
                        .toList(),
                    initialValue: selectedPriceList,
                  onConfirm: (List<String?> values) {
  setState(() {
    selectedPriceList = values;

    // Retrieve cmpCode and seCode based on selected values
    selectedCmpCodesPriceList = [];
    selectedAuthoGroup = [];

    values.forEach((selectedSalesEmployee) {
      if (selectedSalesEmployee != null) {
        List<String> parts = selectedSalesEmployee.split(' - ');

        // Find Company based on cmpName
        Companies selectedCompany = companyBox.values
            .firstWhere((company) => company.cmpName == parts[1]);

        // Assign cmpCode and seCode to lists
        selectedCmpCodesPriceList.add(selectedCompany.cmpCode);
        selectedAuthoGroup.add(priceListsBox.values
            .firstWhere((se) => se.authoGroup == parts[0])
            .authoGroup);
      }
    });

    print(selectedCmpCodesPriceList);
    print(selectedAuthoGroup);
  });
},

                  ),
                ),
              ],
            ),
          );
        } else {
          return Container(); // You can replace this with a loading indicator
        }
      },
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
//_initializeConnectivity();
    
   
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
  if (newGroupAr == '') newGroupAr = newGroupEn;

  int newUserCode = 0;

  // Define the language variable based on your logic
  String language =
      AppLocalizations.of(context)!.language == 'English' ? 'en' : 'ar';

  // Open the Hive box for translations
  var translationsBox = await Hive.openBox<Translations>('translationsBox');

  List<String> updatedUserGroups = translationsBox.values
      .map((translations) {
        return translations.translations[language] ?? '';
      })
      .where((translatedGroup) => translatedGroup.isNotEmpty)
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
    // Group exists, fetch user code from translations
    var translation = translationsBox.values.firstWhere(
      (t) =>
          t.translations[language]?.toLowerCase() == newGroupEn.toLowerCase() ||
          t.translations[language]?.toLowerCase() == newGroupAr.toLowerCase(),
      orElse: () => Translations(groupcode: 0, translations: {}),
    );

    newUserCode = translation.groupcode;
  
  } else {
    // Group doesn't exist, fetch user code from user groups collection
    var userGroupBox = await Hive.openBox<UserGroup>('userGroupBox');
    int latestUserCode = 0;

    if (userGroupBox.isNotEmpty) {
      latestUserCode = userGroupBox.values
          .map<int>((userGroup) => userGroup.groupcode)
          .reduce((value, element) => value > element ? value : element);
    }

    newUserCode = latestUserCode + 1;

    // Add the new user group to the user groups box
    await userGroupBox.add(UserGroup(groupcode: newUserCode, groupname: newGroupEn));

    // Add the new translation to the translations box
    await translationsBox.add(Translations(
      groupcode: newUserCode,
      translations: {'en': newGroupEn, 'ar': newGroupAr},
    ));
    
  }

  return newUserCode;
}


  Future<void> _submitForm(BuildContext context) async {
  // Retrieve values from controllers
  final String usercode=usercodeController.text;
  final String email = emailController.text;
  final String userFname = userFnameController.text;
  final String password = passwordController.text;
  final String username = usernameController.text;
  final String phonenumber = phoneNumberController.text;
  final String imeicode = imeiCodeController.text;

final int font ;
if(fontController.text!=''){
 font = int.parse(fontController.text);
}else{
  font=defaultFontSize;
}

print(selectedCmpCodes);
print(selectedSeCodes);

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
      int newUserGroupCode = await addUserGroup(
          selectedUserGroup, selectedUserGroupArabic);
      userSelectGroup = newUserGroupCode;
    }

    // Check if the email or username already exists
    if (userExists(email, username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.useroremailExists)),
      );
      return;
    }

 // Check if the email or username already exists
    if (userCodeExists(usercode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.usercodeExists)),
      );
      return;
    }


    // Open the Hive box
    final userBox = await Hive.openBox('userBox');
    final userSalesEmployeesBox = await Hive.openBox<UserSalesEmployees>('userSalesEmployeesBox');
    final userCompaniesUsersBox = await Hive.openBox<CompaniesUsers>('companiesUsersBox');
    final priceListAuthorizationBox = await Hive.openBox<PriceListAuthorization>('pricelistAuthorizationBox');

    // Use the user's email as a unique identifier for the key
    final userKey = usercode; // Use lowercase to ensure consistency
    // Add user data to the box using the unique key
    await userBox.put(userKey, {
      'usercode': usercode,
      'username': username,
      'userFname': userFname,
      'email': email,
      'password': password,
      'phonenumber': phonenumber,
      'imeicode': imeicode,
      'active': isActive,
      'usergroup': userSelectGroup,
      'languages': selectedLanguage,
      'font': font,
    });
    // Insert into UserSalesEmployees box
for (int i = 0; i < selectedCmpCodes.length; i++) {
  UserSalesEmployees userSalesEmployee = UserSalesEmployees(
    userCode: usercode,
    cmpCode: selectedCmpCodes[i],
    seCode: selectedSeCodes[i],
    notes: ''
  );

  await userSalesEmployeesBox.put(
    '${usercode}${selectedCmpCodes[i]}${selectedSeCodes[i]}',
    userSalesEmployee,
  );
}

 // Insert into CompaniesUser box
for (int i = 0; i < selectedCompanyCodes.length; i++) {
  CompaniesUsers companiesUsers = CompaniesUsers(
    userCode: usercode,
    cmpCode: selectedCompanyCodes[i],
    defaultcmpCode: ''
   
  );

  await userCompaniesUsersBox.put(
    '${usercode}${selectedCompanyCodes[i]}',
    companiesUsers,
  );
}

 // Insert into PriceListAuthoGroup box
for (int i = 0; i < selectedCmpCodesPriceList.length; i++) {
  PriceListAuthorization pricelistautho = PriceListAuthorization(
    userCode: usercode,
    cmpCode: selectedCmpCodesPriceList[i],
    authoGroup: selectedAuthoGroup[i],
   
  );

  await priceListAuthorizationBox.put(
    '${usercode}${selectedCmpCodesPriceList[i]}${selectedAuthoGroup[i]}',
    pricelistautho,
  );
}


    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.userCreated, style: _appTextStyle)),
    );

    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AdminUsersPage(appNotifier: widget.appNotifier),
      ),
    );

  } catch (e) {
    print('Error creating user: $e');
  }
}

bool userExists(String email, String username) {
  final userBox = Hive.box('userBox');
  final lowerEmail = email.toLowerCase();
  return userBox.values.any((user) =>
      user['email'] == lowerEmail || user['username'] == username);
}

bool userCodeExists(String usercode) {
  final userBox = Hive.box('userBox');
  return userBox.values.any((user) =>
      user['usercode'] == usercode);
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
              .where('usercode', isEqualTo: userData['email'])
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

    super.dispose();
  }
}
