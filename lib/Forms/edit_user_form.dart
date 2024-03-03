import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:project/app_notifier.dart';
import 'package:project/classes/numeriqrangeformatters.dart';
import 'package:project/hive/companies_hive.dart';
import 'package:project/hive/companiesusers_hive.dart';
import 'package:project/hive/pricelist_hive.dart';
import 'package:project/hive/pricelistauthorization_hive.dart';
import 'package:project/hive/salesemployees_hive.dart';
import 'package:project/hive/translations_hive.dart';
import 'package:project/hive/userssalesemployees_hive.dart';
import 'package:project/screens/admin_users_page.dart';
import 'package:validators/validators.dart';
import 'package:project/classes/validations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:project/classes/Languages.dart';
import 'package:collection/collection.dart';

class EditUserForm extends StatefulWidget {
  final String usercode;
  final String username;
  final String userFname;
  final String email;
  final String password;

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
   TimeOfDay noTime = TimeOfDay(hour: 0, minute: 0);

  String _selectedUserGroup = '0';
  TextEditingController _fontController = TextEditingController();
  TextEditingController _languageController = TextEditingController();
  bool _isActive = false; // Assuming default value is false
  TextEditingController _phonenumberController=TextEditingController();
    TextEditingController _imeicodeController=TextEditingController();
String _selectedLanguage = 'English';
List<String> userGroups = [];
  bool isInitialized = false;
  String defaultCompanyCode='';
String username='';
      bool _formChanged = false; // Added to track changes
      bool isDeletedSales = false;
      bool isDeletedCust=false;
       bool isDeletedAutho=false;
    List<String?> selectedSalesEmployees = [];
List<String> selectedCmpCodes = [];
List<String> selectedSeCodes = [];
List<String?> selectedCompanies = [];
List<String> selectedCompanyCodes = [];
List<String?> selectedPriceList = [];
List<String> selectedCmpCodesPriceList = [];
List<String> selectedAuthoGroup = [];


 TextStyle _appTextStyle=TextStyle();
@override
void initState() {
  super.initState();
  // Initialize the controllers with the existing username and email
  _usercodeController.text=widget.usercode;
   _usernameFController.text = widget.userFname;
  _usernameController.text = widget.username;
  _emailController.text = widget.email;
  _passwordController.text = widget.password;
  _phonenumberController.text = widget.phonenumber;
    _imeicodeController.text = widget.imeicode;
  _selectedUserGroup = widget.usergroup.toString(); // Set the default value from widget

  // Parse _fontController.text to an integer and assign it to sfont
  _fontController.text=widget.font.toString();

  _languageController.text = widget.languages;
  _isActive = widget.active;
  _selectedLanguage=widget.languages;
  

       fetchSalesEmployeesAndCompanies(widget.usercode);
   
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

Future<void> fetchSalesEmployeesAndCompanies(String selectedUserGroup) async {
  try {
    // Fetch sales employees based on the selected user group
    var userSalesEmployeesBox = await Hive.openBox<UserSalesEmployees>('userSalesEmployeesBox');
    List<String> salesEmployeeList = userSalesEmployeesBox.values
        .where((userSalesEmployee) => userSalesEmployee.userCode == selectedUserGroup)
        .map((userSalesEmployee) {
          // Retrieve cmpName based on cmpCode from the Companies box
          var companiesBox = Hive.box<Companies>('companiesBox');
            var salesEmployeesBox = Hive.box<SalesEmployees>('salesEmployeesBox');
          Companies company = companiesBox.values
              .firstWhere((company) => company.cmpCode == userSalesEmployee.cmpCode,
              orElse: () => Companies(cmpCode: userSalesEmployee.cmpCode, cmpName: 'Unknown Company', cmpFName: '', tel: '', mobile: '', address: '', fAddress: '', prHeader: '', prFHeader: '', prFooter: '', prFFooter: '', mainCurCode: '', secCurCode: '', rateType: '', issueBatchMethod: '', systemAdminID: '', notes: '', priceDec: null, amntDec: null, qtyDec: null, roundMethod: '', importMethod: '', time:noTime));

              SalesEmployees salesemployees = salesEmployeesBox.values
              .firstWhere((salesemployees) => salesemployees.seCode == userSalesEmployee.seCode,
              orElse: () => SalesEmployees(cmpCode: '', seCode: '', seName: '', seFName: '', mobile: '', email: '', whsCode: '', reqFromWhsCode: 0 , notes: ''));

          return '${salesemployees.seName} - ${company.cmpName}';
        })
        .toList();

    setState(() {
      // Update the sales employees dropdown
      selectedSalesEmployees = salesEmployeeList;
      print(selectedSalesEmployees);
    });

    // Fetch companies based on the selected user group
    var companiesBox = await Hive.openBox<CompaniesUsers>('companiesUsersBox');

    List<String> companyList = companiesBox.values
        .where((companyuser) => companyuser.userCode == selectedUserGroup)
         .map((companyuser) {
          // Retrieve cmpName based on cmpCode from the Companies box
          var companiesBox = Hive.box<Companies>('companiesBox');
   
          Companies company = companiesBox.values
              .firstWhere((company) => company.cmpCode == companyuser.cmpCode,
              orElse: () => Companies(cmpCode:'', cmpName: 'Unknown Company', cmpFName: '', tel: '', mobile: '', address: '', fAddress: '', prHeader: '', prFHeader: '', prFooter: '', prFFooter: '', mainCurCode: '', secCurCode: '', rateType: '', issueBatchMethod: '', systemAdminID: '', notes: '', priceDec: null, amntDec: null, qtyDec: null, roundMethod: '', importMethod: '', time:noTime));
defaultCompanyCode=company.cmpCode;

          return '${company.cmpName}';
        })
        .toList();
    setState(() {
      // Update the companies dropdown
      selectedCompanies = companyList;
      defaultCompanyCode=defaultCompanyCode;
    
      print(selectedCompanies);
      print(defaultCompanyCode);
    });

    // Fetch price list based on the selected user group
    var priceListBox = await Hive.openBox<PriceListAuthorization>('pricelistAuthorizationBox');

  
    List<String> priceList = priceListBox.values
        .where((pricelist) => pricelist.userCode == selectedUserGroup)
        .map((pricelist) {
          // Retrieve cmpName based on cmpCode from the Companies box
          var companiesBox = Hive.box<Companies>('companiesBox');
          Companies company = companiesBox.values
              .firstWhere((company) => company.cmpCode == pricelist.cmpCode,
            orElse: () => Companies(cmpCode: pricelist.cmpCode, cmpName: 'Unknown Company', cmpFName: '', tel: '', mobile: '', address: '', fAddress: '', prHeader: '', prFHeader: '', prFooter: '', prFFooter: '', mainCurCode: '', secCurCode: '', rateType: '', issueBatchMethod: '', systemAdminID: '', notes: '', priceDec: null, amntDec: null, qtyDec: null, roundMethod: '', importMethod: '', time: noTime));


 return '${company.cmpName ?? ''} - ${'Group'+' '+pricelist.authoGroup ?? ''}';        })
        .toList();

    setState(() {
      // Update the price list dropdown
      selectedPriceList = priceList.map((authoGroup) => '$authoGroup').toList();
      print(selectedPriceList);
      print('hiiiiiiii');
      print(priceList.toList());
    });
  } catch (e) {
    print('Error fetching sales employees and companies: $e');
  }
}

  // Existing code...

String getCompanyName(String companyCode) {
  // Fetch company name based on the company code (you need to implement this)
  // For example, if you have a box of companies:
  var companyBox = Hive.box<Companies>('companiesBox');
  Companies company = companyBox.values.firstWhere(
    (c) => c.cmpCode == companyCode,
   
  );
  return company.cmpName;
}

String getSalesName(String companyCode) {
  // Fetch company name based on the company code (you need to implement this)
  // For example, if you have a box of companies:
  var companyBox = Hive.box<Companies>('companiesBox');
  Companies company = companyBox.values.firstWhere((c) => c.cmpCode == companyCode);
  return company.cmpName;
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

   // Retrieve the username from the translation
  return username = translation.translations[language] ?? groupcode.toString();

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
        print(_selectedLanguage);
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
                   SizedBox(height: 16),

                 _buildTextFieldDropDownSalesEmployees(),
                      SizedBox(height: 16),
                    _buildTextFieldDropDownCompanies(),
                      SizedBox(height: 16),
                  _buildTextFieldDropDownPriceListAutho(),



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
               _usercodeController.text,
                _usernameController.text,
                _usernameFController.text,
                _emailController.text,
                _passwordController.text,
                _phonenumberController.text,
                _imeicodeController.text,
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
                    initialValue: selectedSalesEmployees, // Set the initial values here
                    onConfirm: (List<String?> values) {
                      setState(() {
                        selectedSalesEmployees = values;
                           _formChanged=true;
                           isDeletedSales=true;
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

                            // Additional action: Print a message when a sales employee is selected
                            print('Selected Sales Employee: ${parts[0]} from Company: ${parts[1]}');
                          }
                        });

                        // Print selected cmpCodes and seCodes
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
                             _formChanged=true;
                           isDeletedCust=true;
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
          print('looo');
          print(priceListsBox.values.toList());
          print(companyBox.values.toList());
          for(var l in companyBox.values.toList()){
            print(l.cmpCode);
          }
          for(var y in priceListsBox.values.toList()){
            print(y.cmpCode);
            print(y.authoGroup);
          }
        List<String> priceList = groupBy(
  priceListsBox.values,
  (pricelist) => [pricelist.cmpCode, pricelist.authoGroup],
).entries
  .map((entry) {
    String cmpCode = entry.key[0];
    String authoGroup = entry.key[1];

    Companies company = companyBox.values
        .firstWhere((company) => company.cmpCode == cmpCode, orElse: () => Companies(
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
      notes: '', priceDec: null, amntDec: null, qtyDec: null, roundMethod: '', importMethod: '', time:noTime,
    ));

    return '${company.cmpName ?? ''} - ${'Group'+' '+authoGroup ?? ''}';
  })
  .toSet() // Convert to set to remove duplicates
  .toList(); // Convert back to list



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
                        _formChanged=true;
                        isDeletedAutho=true;
                        // Retrieve cmpCode and seCode based on selected values
                        selectedCmpCodesPriceList = [];
                        selectedAuthoGroup = [];

                        values.forEach((selectedSalesEmployee) {
                          if (selectedSalesEmployee != null) {
                 List<String> parts = selectedSalesEmployee.split(' - ');
var group = parts[1].replaceAll('Group', '').trim();

print(group);
print(parts[0]);
                            print('##################');

                            // Find Company based on cmpName
                            Companies selectedCompany = companyBox.values
                                .firstWhere((company) => company.cmpName == parts[0]);
print('hiiiii');
                            // Assign cmpCode and seCode to lists
                            selectedCmpCodesPriceList.add(selectedCompany.cmpCode);
                            print('vvv');
                            selectedAuthoGroup.add(priceListsBox.values
                                .firstWhere((se) => se.authoGroup == group)
                                .authoGroup);
                                print('ooop');
                          }
                        });
                     print('@@@@@@@@@@@@@@@@@@@@@@@@@@');
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
    String newUsercode,
    String newUsername,
    String newFUsername,
    String newEmail,
    String newPassword,
    String newPhoneNumber,
     String newImeiCode,
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
  orElse: () => Translations(groupcode: 1, translations: {}), // Provide a default value
);

// Now, you can safely use the translation
userSelectGroup = translation.groupcode;

print(userSelectGroup);

      }

      print(newLanguages);

if(AppLocalizations.of(context)!.language !='English'){
      if(newLanguages=='إنجليزي') newLanguages='English'; else newLanguages='Arabic';
}

    try {
    var userBox = await Hive.openBox('userBox');
final userSalesEmployeesBox = await Hive.openBox<UserSalesEmployees>('userSalesEmployeesBox');
    final userCompaniesUsersBox = await Hive.openBox<CompaniesUsers>('companiesUsersBox');
    final priceListAuthorizationBox = await Hive.openBox<PriceListAuthorization>('pricelistAuthorizationBox');
    // Retrieve user data from Hive box based on email
    String userCode = widget.usercode;
    var user = userBox.get(userCode) as Map<dynamic, dynamic>?;

    // If the user is found, update the fields
    if (user != null) {
     user['usercode']=newUsercode;
      user['username'] = newUsername;
      user['userFname'] = newFUsername;
      user['email'] = newEmail;
      user['password'] = newPassword;
      user['phonenumber'] = newPhoneNumber;
      user['imeicode'] = newImeiCode;
      user['usergroup'] = userSelectGroup;
      user['font'] = newFont;
      user['languages'] = newLanguages;
      user['active'] = newisActive;

      // Put the updated user data back into the Hive box
      await userBox.put(userCode, user);
      
    }

 // Retrieve existing sales employees, companies users, and price list authorizations
    List<UserSalesEmployees> existingSalesEmployees = await userSalesEmployeesBox.values
        .where((userSalesEmployee) => userSalesEmployee.userCode == widget.usercode)
        .toList();

    List<CompaniesUsers> existingCompaniesUsers = await userCompaniesUsersBox.values
        .where((companiesUser) => companiesUser.userCode == widget.usercode)
        .toList();

    List<PriceListAuthorization> existingPriceListAuthorizations = await priceListAuthorizationBox.values
        .where((pricelistautho) => pricelistautho.userCode == widget.usercode)
        .toList();

    // Delete unchecked sales employees
    if(isDeletedSales){
    for (var existingSalesEmployee in existingSalesEmployees) {
      if (!selectedSeCodes.contains(existingSalesEmployee.seCode)) {
        await userSalesEmployeesBox.delete('${widget.usercode}${existingSalesEmployee.cmpCode}${existingSalesEmployee.seCode}');
      }
    }
    }
print(selectedSeCodes);
    // Delete unchecked companies users
    if(isDeletedCust){
    for (var existingCompaniesUser in existingCompaniesUsers) {
      if (!selectedCompanyCodes.contains(existingCompaniesUser.cmpCode)) {
        await userCompaniesUsersBox.delete('${widget.usercode}${existingCompaniesUser.cmpCode}');
      }
    }
    }
    print(selectedCompanyCodes);

if(isDeletedAutho){
 // Delete unchecked price list authorizations
    for (var existingPriceListAuthorization in existingPriceListAuthorizations) {
      if (!selectedCmpCodesPriceList.contains(existingPriceListAuthorization.cmpCode) ||
          !selectedAuthoGroup.contains(existingPriceListAuthorization.authoGroup)) {
        await priceListAuthorizationBox.delete('${widget.usercode}${existingPriceListAuthorization.cmpCode}${existingPriceListAuthorization.authoGroup}');
      }
    }
}


       // Insert into UserSalesEmployees box
for (int i = 0; i < selectedCmpCodes.length; i++) {
  UserSalesEmployees userSalesEmployee = UserSalesEmployees(
    userCode: widget.usercode,
    cmpCode: selectedCmpCodes[i],
    seCode: selectedSeCodes[i],
    notes: ''
  );

  await userSalesEmployeesBox.put(
    '${widget.usercode}${selectedCmpCodes[i]}${selectedSeCodes[i]}',
    userSalesEmployee,
  );
}

 // Insert into CompaniesUser box
for (int i = 0; i < selectedCompanyCodes.length; i++) {
  CompaniesUsers companiesUsers = CompaniesUsers(
    userCode: widget.usercode,
    cmpCode: selectedCompanyCodes[i],
    defaultcmpCode:defaultCompanyCode 
   
  );

  await userCompaniesUsersBox.put(
    '${widget.usercode}${selectedCompanyCodes[i]}',
    companiesUsers,
  );
}

 // Insert into PriceListAuthoGroup box
for (int i = 0; i < selectedCmpCodesPriceList.length; i++) {
  PriceListAuthorization pricelistautho = PriceListAuthorization(
    userCode: widget.usercode,
    cmpCode: selectedCmpCodesPriceList[i],
    authoGroup: selectedAuthoGroup[i],
   
  );

  await priceListAuthorizationBox.put(
    '${widget.usercode}${selectedCmpCodesPriceList[i]}${selectedAuthoGroup[i]}',
    pricelistautho,
  );
}

  } catch (e) {
    print('Error updating local database: $e');
  }
 ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(AppLocalizations.of(context)!.userUpdated,style: _appTextStyle)),
             );
      // Navigate back to the admin page after updating
      Navigator.pop(context);
    Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => AdminUsersPage(appNotifier: widget.appNotifier),
  ),
);

    
  }
}
