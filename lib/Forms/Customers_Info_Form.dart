import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:project/Forms/Attachements_Item_Form.dart';
import 'package:project/app_notifier.dart';
import 'package:project/hive/customeraddresses_hive.dart';
import 'package:project/hive/customerbrandsspecialprice_hive.dart';
import 'package:project/hive/customercategspecialprice_hive.dart';
import 'package:project/hive/customercontacts_hive.dart';
import 'package:project/hive/customergroupbrandspecialprice_hive.dart';
import 'package:project/hive/customergroupcategspecialprice_hive.dart';
import 'package:project/hive/customergroupgroupspecialprice_hive.dart';
import 'package:project/hive/customergroupitemsspecialprice_hive.dart';
import 'package:project/hive/customergroupsspecialprice_hive.dart';
import 'package:project/hive/customeritemsspecialprice_hive.dart';
import 'package:project/hive/customerpropbrandspecialprice_hive.dart';
import 'package:project/hive/customerpropcategspecialprice_hive.dart';
import 'package:project/hive/customerproperties_hive.dart';
import 'package:project/hive/customerpropgroupspecialprice_hive.dart';
import 'package:project/hive/customerpropitemsspecialprice_hive.dart';
import 'package:project/hive/customers_hive.dart';
import 'package:project/hive/items_hive.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomersInfoForm extends StatelessWidget {
  final Customers customer;
  final AppNotifier appNotifier;

  CustomersInfoForm({required this.customer, required this.appNotifier});

  @override
  Widget build(BuildContext context) {
    TextStyle _appTextStyle = TextStyle(fontSize: appNotifier.fontSize.toDouble());
    TextStyle _appTextStyleAppBar = TextStyle(fontSize: appNotifier.fontSize.toDouble());

     return DefaultTabController(
      length: 5, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Expanded(
            child: Text('Customer Details', style: _appTextStyleAppBar),
          ),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Customers'),
              Tab(text: 'Customers Address'),
              Tab(text: 'Customers Contacts'),
            Tab(text: 'Customers Properties'),
            Tab(text: 'Customers Special Price'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCustomersTab(context),
            _buildCustomersAddressTab(context),
            _buildCustomersContactsTab(context),
            _buildCustomersPropertiesTab(context),
            _buildCustomersSpecialPriceTab(context),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigate to AttachementsItemForm when the button is pressed
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AttachementsItemForm(itemCode: customer.custCode, appNotifier: appNotifier),
              ),
            );
          },
          child: Icon(Icons.attach_file),
        ),
      ),
    );
  }

  // Create your tab content widgets here
  Widget _buildCustomersTab(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           Row(
                children: [
                 
           
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleText('Customer Code', customer.custCode ?? ''),
                      _buildTitleText('Customer Name', customer.custName ?? ''),
                          _buildTitleText('Customer FName', customer.custFName ?? ''),
                    ],
                  ),
                ],
              ),

          
            _buildTitleText('Company Code', customer.cmpCode ?? ''),
            _buildTitleText('Currency', customer.curCode ?? ''),
            _buildTitleText('Group', customer.groupCode ?? ''),
            _buildTitleText('MOFNum', customer.mofNum ?? ''),
            _buildTitleText('BarCode', customer.barcode ?? ''),
            _buildTitleText('Phone', customer.phone ?? ''),
            _buildTitleText('Mobile', customer.mobile ?? ''),
            _buildTitleText('Fax', customer.fax ?? ''),
            _buildTitleText('Website', customer.website ?? ''),
            _buildTitleText('Email', customer.email ?? ''),
            _buildTitleTextNumber('Active', customer.active),
          _buildTitleText('Print Layout', customer.printLayout ?? ''),
          _buildTitleText('Default AddressID', customer.dfltAddressID ?? ''),
            _buildTitleText('Cash Client', customer.cashClient ?? ''),
             _buildTitleText('Discount Type', customer.discType ?? ''),
             _buildTitleText('VAT Code', customer.vatCode ?? ''),
            _buildTitleText('PRList Code', customer.prListCode ?? ''),
             _buildTitleText('PayTerms Code', customer.payTermsCode ?? ''),
            _buildTitleTextNumber('Discount', customer.discount ?? ''),
            _buildTitleTextNumber('Credit Limit', customer.creditLimit ?? ''),
            _buildTitleTextNumber('Balance', customer.balance ?? ''),
            _buildTitleTextNumber('Balance Due', customer.balanceDue ?? ''),
            _buildTitleText('Notes', customer.notes ?? ''),
          ],
          ),
        ),
      

    );
  }
 Widget _buildCustomersAddressTab(BuildContext context) {
  return FutureBuilder<Box<CustomerAddresses>>(
    future: Hive.openBox<CustomerAddresses>('customerAddressesBox'),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          Box<CustomerAddresses> customerAddressesBox = snapshot.data!;
          String key = customer.cmpCode;
          String key1 = customer.custCode;

          List<CustomerAddresses> addresses = customerAddressesBox.values
              .where((address) => address.cmpCode == key && address.custCode == key1)
              .toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(addresses.length, (index) {
                  CustomerAddresses address = addresses[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleText('Address${index + 1}', address.address ?? 'N/A'),
                      _buildTitleText('AddressId', address.addressID ?? 'N/A'),
                      _buildTitleText('fAddress', address.fAddress ?? 'N/A'),
                      _buildTitleText('gpslat', address.gpslat ?? 'N/A'),
                      _buildTitleText('gpslong', address.gpslong ?? 'N/A'),
                      _buildTitleText('RegCode', address.regCode ?? 'N/A'),
                      _buildTitleText('Notes', address.notes ?? 'N/A'),
                      // Add more fields as needed
                      SizedBox(height: 16), // Add spacing between addresses
                    ],
                  );
                }),
              ),
            ),
          );
        }
      } else {
        return CircularProgressIndicator();
      }
    },
  );
}



  Widget _buildCustomersContactsTab(BuildContext context) {
     return FutureBuilder<Box<CustomerContacts>>(
    future: Hive.openBox<CustomerContacts>('customerContactsBox'),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          Box<CustomerContacts> customerContactsBox = snapshot.data!;
          // Fetch data from the box and use it in your UI
   String key = customer.cmpCode;
          String key1 = customer.custCode;

          List<CustomerContacts> contact = customerContactsBox.values
              .where((contact) => contact.cmpCode == key && contact.custCode == key1)
              .toList();


          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(contact.length, (index) {
                  CustomerContacts contacts = contact[index];
                     return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Display fetched data with null-aware operator
                  _buildTitleText('ContactId${index + 1}', contacts?.contactID ?? 'N/A'),
                
                  _buildTitleText('Contact Name', contacts?.contactName ?? 'N/A'),
                  _buildTitleText('Contact FName', contacts?.contactFName ?? 'N/A'),
                  _buildTitleText('Phone', contacts?.phone ?? 'N/A'),
                  _buildTitleText('Mobile', contacts?.mobile ?? 'N/A'),
                   _buildTitleText('Email', contacts?.email ?? 'N/A'),
                  _buildTitleText('Position', contacts?.position ?? 'N/A'),
                    _buildTitleText('Notes', contacts?.notes ?? 'N/A'),
                  // ... add more fields based on your 'CustomerAddresses' class

                    ]);
      }),
              ),
            ),
          );
        }
      } else {
        return CircularProgressIndicator();
      }
    },
  );
  }


  Widget _buildCustomersPropertiesTab(BuildContext context) {
     return FutureBuilder<Box<CustomerProperties>>(
    future: Hive.openBox<CustomerProperties>('customerPropertiesBox'),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          Box<CustomerProperties> customerPropertiesBox = snapshot.data!;
        
          // Fetch data from the box and use it in your UI
   String key = customer.cmpCode;
          String key1 = customer.custCode;

          List<CustomerProperties> property = customerPropertiesBox.values
              .where((property) => property.cmpCode == key && property.custCode == key1)
              .toList();


          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
               children: List.generate(property.length, (index) {
                  CustomerProperties properties = property[index];
                     return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Display fetched data with null-aware operator
                  _buildTitleText('PropCode${index+1}', properties?.propCode ?? 'N/A'),
                
                  _buildTitleText('Notes', properties?.notes ?? 'N/A'),
               
                 
                ]);
      }),
              ),
            ),
          );
        }
      } else {
        return CircularProgressIndicator();
      }
    },
  );
  }


 Widget _buildCustomersSpecialPriceTab(BuildContext context) {
  
  return SingleChildScrollView(
    child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBoxWidgetItemSpecial('customerItemsSpecialPriceBox'),
        _buildBoxWidgetBrandSpecial('customerBrandsSpecialPriceBox'), // Add more boxes as needed
        _buildBoxWidgetGroupSpecial('customerGroupsSpecialPriceBox'), // Add more boxes as needed
        _buildBoxWidgetCategSpecial('customerCategSpecialPriceBox'), // Add more boxes as needed
        _buildBoxWidgetGroupItemSpecial('customerGroupItemsSpecialPriceBox'), // Add more boxes as needed
        _buildBoxWidgetGroupBrandSpecial('customerGroupBrandSpecialPriceBox'), // Add more boxes as needed
        _buildBoxWidgetGroupGroupSpecial('customerGroupGroupSpecialPriceBox'), // Add more boxes as needed
        _buildBoxWidgetGroupCategSpecial('customerGroupCategSpecialPriceBox'), // Add more boxes as needed

        _buildBoxWidgetPropItemsSpecial('customerPropItemsSpecialPriceBox'), // Add more boxes as needed
        _buildBoxWidgetPropBrandSpecial('customerPropBrandSpecialPriceBox'), // Add more boxes as needed
     //   _buildBoxWidgetPropGroupSpecial('customerPropGroupSpecialPriceBox'), // Add more boxes as needed
   //     _buildBoxWidgetPropCategSpecial('customerPropCategSpecialPriceBox'), // Add more boxes as needed
        
      ],
    ),
  );
}

Widget _buildBoxWidgetItemSpecial(String boxName) {
  return FutureBuilder<Box<CustomerItemsSpecialPrice>>(
    future: Hive.openBox<CustomerItemsSpecialPrice>(boxName),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          Box<CustomerItemsSpecialPrice> customerItemsSpecialPriceBox = snapshot.data!;

          String key = customer.cmpCode;
          String key1 = customer.custCode;

          List<CustomerItemsSpecialPrice> itemspecial = customerItemsSpecialPriceBox.values
              .where((itemspecial) => itemspecial.cmpCode == key && itemspecial.custCode == key1)
              .toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(itemspecial.length, (index) {
                  CustomerItemsSpecialPrice itemspecials = itemspecial[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleText('ItemCode', itemspecials?.itemCode ?? 'N/A'),
                      _buildTitleText('UOM', itemspecials?.uom ?? 'N/A'),
                      _buildTitleTextNumber('BasePrice', itemspecials?.basePrice ?? 'N/A'),
                      _buildTitleTextNumber('Currency', itemspecials?.currency ?? 'N/A'),
                      _buildTitleTextNumber('Auto', itemspecials?.auto ?? 'N/A'),
                       _buildTitleTextNumber('Disc', itemspecials?.disc ?? 'N/A'),
                      _buildTitleTextNumber('Prices', itemspecials?.price ?? 'N/A'),
                        _buildTitleText('Notes', itemspecials?.notes ?? 'N/A'),

                      // Add more fields as needed
                    ],
                  );
                }),
              ),
            ),
          );
        }
      } else {
        return CircularProgressIndicator();
      }
    },
  );
}

Widget _buildBoxWidgetBrandSpecial(String boxName) {
  return FutureBuilder<Box<CustomerBrandsSpecialPrice>>(
    future: Hive.openBox<CustomerBrandsSpecialPrice>(boxName),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          Box<CustomerBrandsSpecialPrice> customerBrandSpecialPriceBox = snapshot.data!;

          String key = customer.cmpCode;
          String key1 = customer.custCode;

          List<CustomerBrandsSpecialPrice> brandpecials = customerBrandSpecialPriceBox.values
              .where((brandpecials) => brandpecials.cmpCode == key && brandpecials.custCode == key1)
              .toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(brandpecials.length, (index) {
                  CustomerBrandsSpecialPrice brandspecials = brandpecials[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleText('BrandCode', brandspecials?.brandCode ?? 'N/A'),
                      _buildTitleTextNumber('Disc', brandspecials?.disc ?? 'N/A'),
                      _buildTitleText('Notes', brandspecials?.notes ?? 'N/A'),
                      // Add more fields as needed
                    ],
                  );
                }),
              ),
            ),
          );
        }
      } else {
        return CircularProgressIndicator();
      }
    },
  );
}

Widget _buildBoxWidgetGroupSpecial(String boxName) {
  return FutureBuilder<Box<CustomerGroupsSpecialPrice>>(
    future: Hive.openBox<CustomerGroupsSpecialPrice>(boxName),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          Box<CustomerGroupsSpecialPrice> customerGroupSpecialPriceBox = snapshot.data!;

          String key = customer.cmpCode;
          String key1 = customer.custCode;

          List<CustomerGroupsSpecialPrice> groupspecials = customerGroupSpecialPriceBox.values
              .where((groupspecials) => groupspecials.cmpCode == key && groupspecials.custCode == key1)
              .toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(groupspecials.length, (index) {
                  CustomerGroupsSpecialPrice grouppecials = groupspecials[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleText('GroupCode', grouppecials?.groupCode ?? 'N/A'),
                      _buildTitleTextNumber('Disc', grouppecials?.disc ?? 'N/A'),
                      _buildTitleText('Notes', grouppecials?.notes ?? 'N/A'),
                      // Add more fields as needed
                    ],
                  );
                }),
              ),
            ),
          );
        }
      } else {
        return CircularProgressIndicator();
      }
    },
  );
}


Widget _buildBoxWidgetCategSpecial(String boxName) {
  return FutureBuilder<Box<CustomerCategSpecialPrice>>(
    future: Hive.openBox<CustomerCategSpecialPrice>(boxName),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          Box<CustomerCategSpecialPrice> customerCategSpecialPriceBox = snapshot.data!;

          String key = customer.cmpCode;
          String key1 = customer.custCode;

          List<CustomerCategSpecialPrice> categspecials = customerCategSpecialPriceBox.values
              .where((categspecials) => categspecials.cmpCode == key && categspecials.custCode == key1)
              .toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(categspecials.length, (index) {
                  CustomerCategSpecialPrice categpecials = categspecials[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleText('CategCode', categpecials?.categCode ?? 'N/A'),
                      _buildTitleTextNumber('Disc', categpecials?.disc ?? 'N/A'),
                      _buildTitleText('Notes', categpecials?.notes ?? 'N/A'),
                      // Add more fields as needed
                    ],
                  );
                }),
              ),
            ),
          );
        }
      } else {
        return CircularProgressIndicator();
      }
    },
  );
}
        

     Widget _buildBoxWidgetGroupItemSpecial(String boxName) {
  return FutureBuilder<Box<CustomerGroupItemsSpecialPrice>>(
    future: Hive.openBox<CustomerGroupItemsSpecialPrice>(boxName),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          Box<CustomerGroupItemsSpecialPrice> customerGroupItemsSpecialPriceBox = snapshot.data!;

          String key = customer.cmpCode;
          String key1 = customer.groupCode;

          List<CustomerGroupItemsSpecialPrice> categspecials = customerGroupItemsSpecialPriceBox.values
              .where((categspecials) => categspecials.cmpCode == key && categspecials.custGroupCode == key1)
              .toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(categspecials.length, (index) {
                  CustomerGroupItemsSpecialPrice categpecials = categspecials[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleText('GroupCode', categpecials?.custGroupCode ?? 'N/A'),
                      _buildTitleText('ItemCode', categpecials?.itemCode ?? 'N/A'),
                      _buildTitleText('UOM', categpecials?.uom ?? 'N/A'),
                      _buildTitleTextNumber('BasePrice', categpecials?.basePrice ?? 'N/A'),
                    _buildTitleTextNumber('Auto', categpecials?.auto ?? 'N/A'),
                    _buildTitleTextNumber('Disc', categpecials?.disc ?? 'N/A'),
                    _buildTitleTextNumber('Price', categpecials?.price ?? 'N/A'),
                     _buildTitleTextNumber('Notes', categpecials?.notes ?? 'N/A'),
                      // Add more fields as needed
                    ],
                  );
                }),
              ),
            ),
          );
        }
      } else {
        return CircularProgressIndicator();
      }
    },
  );
}
   
         Widget _buildBoxWidgetGroupBrandSpecial(String boxName) {
  return FutureBuilder<Box<CustomerGroupBrandSpecialPrice>>(
    future: Hive.openBox<CustomerGroupBrandSpecialPrice>(boxName),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          Box<CustomerGroupBrandSpecialPrice> customerGroupBrandSpecialPriceBox = snapshot.data!;

          String key = customer.cmpCode;
          String key1 = customer.groupCode;

          List<CustomerGroupBrandSpecialPrice> brandspecials = customerGroupBrandSpecialPriceBox.values
              .where((brandspecials) => brandspecials.cmpCode == key && brandspecials.custGroupCode == key1)
              .toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(brandspecials.length, (index) {
                  CustomerGroupBrandSpecialPrice brandpecials = brandspecials[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    
                      _buildTitleText('BrandCode', brandpecials?.brandCode ?? 'N/A'),
                    _buildTitleTextNumber('Disc', brandpecials?.disc ?? 'N/A'),
                     _buildTitleTextNumber('Notes', brandpecials?.notes ?? 'N/A'),
                      // Add more fields as needed
                    ],
                  );
                }),
              ),
            ),
          );
        }
      } else {
        return CircularProgressIndicator();
      }
    },
  );
}
    

       Widget _buildBoxWidgetGroupGroupSpecial(String boxName) {
  return FutureBuilder<Box<CustomerGroupGroupSpecialPrice>>(
    future: Hive.openBox<CustomerGroupGroupSpecialPrice>(boxName),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          Box<CustomerGroupGroupSpecialPrice> customerGroupGroupSpecialPriceBox = snapshot.data!;

          String key = customer.cmpCode;
          String key1 = customer.groupCode;

          List<CustomerGroupGroupSpecialPrice> groupspecials = customerGroupGroupSpecialPriceBox.values
              .where((groupspecials) => groupspecials.cmpCode == key && groupspecials.custGroupCode == key1)
              .toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(groupspecials.length, (index) {
                  CustomerGroupGroupSpecialPrice brandpecials = groupspecials[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleText('GroupCode', brandpecials?.custGroupCode ?? 'N/A'),
                    _buildTitleTextNumber('Disc', brandpecials?.disc ?? 'N/A'),
                     _buildTitleTextNumber('Notes', brandpecials?.notes ?? 'N/A'),
                      // Add more fields as needed
                    ],
                  );
                }),
              ),
            ),
          );
        }
      } else {
        return CircularProgressIndicator();
      }
    },
  );
}

  Widget _buildBoxWidgetGroupCategSpecial(String boxName) {
  return FutureBuilder<Box<CustomerGroupCategSpecialPrice>>(
    future: Hive.openBox<CustomerGroupCategSpecialPrice>(boxName),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          Box<CustomerGroupCategSpecialPrice> customerGroupCategSpecialPriceBox = snapshot.data!;

          String key = customer.cmpCode;
          String key1 = customer.groupCode;

          List<CustomerGroupCategSpecialPrice> categspecials = customerGroupCategSpecialPriceBox.values
              .where((categspecials) => categspecials.cmpCode == key && categspecials.custGroupCode == key1)
              .toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(categspecials.length, (index) {
                  CustomerGroupCategSpecialPrice categpecials = categspecials[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleText('CategCode', categpecials?.categCode ?? 'N/A'),
                    _buildTitleTextNumber('Disc', categpecials?.disc ?? 'N/A'),
                     _buildTitleTextNumber('Notes', categpecials?.notes ?? 'N/A'),
                      // Add more fields as needed
                    ],
                  );
                }),
              ),
            ),
          );
        }
      } else {
        return CircularProgressIndicator();
      }
    },
  );
}

String getKey1FromCustomerProperties() {
  // Assuming CustomerProperties has a propCode field
  String custCode = customer.custCode;
  
  // Open the CustomerProperties box
  Box<CustomerProperties> customerPropertiesBox = Hive.box<CustomerProperties>('customerPropertiesBox');

  // Find the CustomerProperties item where propCode is equal to customer.custCode
  CustomerProperties customerProperty = customerPropertiesBox.values
      .firstWhere((property) => property.custCode == custCode);

  // Retrieve key1 from the found CustomerProperties item
  String key1 = customerProperty.propCode;

  return key1;
}


//_buildBoxWidgetPropItemsSpecial
  Widget _buildBoxWidgetPropItemsSpecial(String boxName) {
  return FutureBuilder<Box<CustomerPropItemsSpecialPrice>>(
    future: Hive.openBox<CustomerPropItemsSpecialPrice>(boxName),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          Box<CustomerPropItemsSpecialPrice> customerPropItemsSpecialPriceBox = snapshot.data!;

          String key = customer.cmpCode;
        String key1 = getKey1FromCustomerProperties();

          List<CustomerPropItemsSpecialPrice> propitemspecials = customerPropItemsSpecialPriceBox.values
              .where((propitemspecials) => propitemspecials.cmpCode == key && propitemspecials.custPropCode == key1)
              .toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(propitemspecials.length, (index) {
                  CustomerPropItemsSpecialPrice propitemspecialss = propitemspecials[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleText('PropCode', propitemspecialss?.custPropCode ?? 'N/A'),
                    _buildTitleTextNumber('ItemCode', propitemspecialss?.itemCode ?? 'N/A'),
                     _buildTitleTextNumber('BasePrice', propitemspecialss?.basePrice ?? 'N/A'),
                      _buildTitleTextNumber('Currency', propitemspecialss?.currency ?? 'N/A'),
                             _buildTitleTextNumber('Auto', propitemspecialss?.auto ?? 'N/A'),
                                _buildTitleTextNumber('Disc', propitemspecialss?.disc ?? 'N/A'),
                           _buildTitleTextNumber('Notes', propitemspecialss?.auto ?? 'N/A'),

                      // Add more fields as needed
                    ],
                  );
                }),
              ),
            ),
          );
        }
      } else {
        return CircularProgressIndicator();
      }
    },
  );
}

  Widget _buildBoxWidgetPropBrandSpecial(String boxName) {
  return FutureBuilder<Box<CustomerPropBrandSpecialPrice>>(
    future: Hive.openBox<CustomerPropBrandSpecialPrice>(boxName),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          Box<CustomerPropBrandSpecialPrice> customerPropBrandSpecialPriceBox = snapshot.data!;

          String key = customer.cmpCode;
        String key1 = getKey1FromCustomerProperties();

          List<CustomerPropBrandSpecialPrice> propbrandspecials = customerPropBrandSpecialPriceBox.values
              .where((propbrandspecials) => propbrandspecials.cmpCode == key && propbrandspecials.custPropCode == key1)
              .toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(propbrandspecials.length, (index) {
                  CustomerPropBrandSpecialPrice propitemspecialss = propbrandspecials[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                
                    _buildTitleTextNumber('BrandCode', propitemspecialss?.brandCode ?? 'N/A'),
                     _buildTitleTextNumber('Disc', propitemspecialss?.disc ?? 'N/A'),
                      _buildTitleTextNumber('Notes', propitemspecialss?.notes ?? 'N/A'),
                          

                      // Add more fields as needed
                    ],
                  );
                }),
              ),
            ),
          );
        }
      } else {
        return CircularProgressIndicator();
      }
    },
  );
}

 Widget _buildBoxWidgetPropGroupSpecial(String boxName) {
  return FutureBuilder<Box<CustomerPropGroupSpecialPrice>>(
    future: Hive.openBox<CustomerPropGroupSpecialPrice>(boxName),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          Box<CustomerPropGroupSpecialPrice> customerPropGroupSpecialPriceBox = snapshot.data!;

          String key = customer.cmpCode;
        String key1 = customer.groupCode;

          List<CustomerPropGroupSpecialPrice> propgroupspecials = customerPropGroupSpecialPriceBox.values
              .where((propgroupspecials) => propgroupspecials.cmpCode == key && propgroupspecials.custGroupCode == key1)
              .toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(propgroupspecials.length, (index) {
                  CustomerPropGroupSpecialPrice propitemspecialss = propgroupspecials[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                
                    _buildTitleTextNumber('PropCode', propitemspecialss?.propCode ?? 'N/A'),
                     _buildTitleTextNumber('Disc', propitemspecialss?.disc ?? 'N/A'),
                      _buildTitleTextNumber('Notes', propitemspecialss?.notes ?? 'N/A'),
                          

                      // Add more fields as needed
                    ],
                  );
                }),
              ),
            ),
          );
        }
      } else {
        return CircularProgressIndicator();
      }
    },
  );
}

 Widget _buildBoxWidgetPropCategSpecial(String boxName) {
  return FutureBuilder<Box<CustomerPropCategSpecialPrice>>(
    future: Hive.openBox<CustomerPropCategSpecialPrice>(boxName),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          Box<CustomerPropCategSpecialPrice> customerPropCategSpecialPriceBox = snapshot.data!;

          String key = customer.cmpCode;
    String key1 = getKey1FromCustomerProperties();

          List<CustomerPropCategSpecialPrice> propcategspecials = customerPropCategSpecialPriceBox.values
              .where((propcategspecials) => propcategspecials.cmpCode == key && propcategspecials.custPropCode == key1)
              .toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(propcategspecials.length, (index) {
                  CustomerPropCategSpecialPrice propitemspecialss = propcategspecials[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                
                    _buildTitleTextNumber('CategCode', propitemspecialss?.categCode ?? 'N/A'),
                     _buildTitleTextNumber('Disc', propitemspecialss?.disc ?? 'N/A'),
                      _buildTitleTextNumber('Notes', propitemspecialss?.notes ?? 'N/A'),
                          

                      // Add more fields as needed
                    ],
                  );
                }),
              ),
            ),
          );
        }
      } else {
        return CircularProgressIndicator();
      }
    },
  );
}
  Widget _buildTitleText(String title, String value) {
             TextStyle   _appTextStyle = TextStyle(fontSize:appNotifier.fontSize.toDouble()-4);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
                 

            color: Colors.blue, // Set the text color to blue
            fontSize:appNotifier.fontSize.toDouble() ,// Set the font size
            fontWeight: FontWeight.bold, // Set the font weight to bold
          ),
        ),
        Text(value,style: _appTextStyle),
      ],
    );
  }
  Widget _buildTitleTextNumber(String title, Object value) {
     TextStyle   _appTextStyle = TextStyle(fontSize:appNotifier.fontSize.toDouble()-4);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.blue, // Set the text color to blue
            fontSize: appNotifier.fontSize.toDouble(), // Set the font size
            fontWeight: FontWeight.bold, // Set the font weight to bold
          ),
        ),
        Text(value.toString(),style: _appTextStyle,),
      ],
    );
  }

  Widget _buildText(String title, String value) {
    return Text('$title $value');
  }
}
