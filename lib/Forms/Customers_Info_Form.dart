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
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.customerDetails, style: _appTextStyleAppBar),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: AppLocalizations.of(context)!.general),
              Tab(text: AppLocalizations.of(context)!.customerAddresses),
              Tab(text: AppLocalizations.of(context)!.customerContacts),
              Tab(text: AppLocalizations.of(context)!.customerProperties),
              Tab(text: AppLocalizations.of(context)!.customerItemsSpecialPrice),
              Tab(text: AppLocalizations.of(context)!.customerGroupSpecialPrice),
              Tab(text: AppLocalizations.of(context)!.customerPropSpecialPrice),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCustomersTab(context),
            _buildCustomersAddressTab(context),
            _buildCustomersContactsTab(context),
            _buildCustomersPropertiesTab(context),
            _buildCustomersItemsSpecialPriceTab(context),
            _buildCustomersGroupSpecialPriceTab(context),
            _buildCustomersPropSpecialPriceTab(context),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: null,
          onPressed: () {
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
                    _buildTitleText(AppLocalizations.of(context)!.customerCode, customer.custCode ?? ''),
                    _buildTitleText(AppLocalizations.of(context)!.customerName, customer.custName ?? ''),
                    _buildTitleText(AppLocalizations.of(context)!.customerFName, customer.custFName ?? ''),
                  ],
                ),
              ],
            ),
          
            _buildTitleText(AppLocalizations.of(context)!.cmpCode, customer.cmpCode ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.currency, customer.curCode ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.groupcode, customer.groupCode ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.mofNum, customer.mofNum ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.barcode, customer.barcode ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.phoneNumber, customer.phone ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.mobile, customer.mobile ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.fax, customer.fax ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.website, customer.website ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.email, customer.email ?? ''),
            _buildTitleTextNumber(AppLocalizations.of(context)!.active, customer.active),
          _buildTitleText(AppLocalizations.of(context)!.printLayout, customer.printLayout ?? ''),
          _buildTitleText(AppLocalizations.of(context)!.defaultAddressID, customer.dfltAddressID ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.cashClient, customer.cashClient ?? ''),
             _buildTitleText(AppLocalizations.of(context)!.discountType, customer.discType ?? ''),
             _buildTitleText(AppLocalizations.of(context)!.vatCode, customer.vatCode ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.prListCode, customer.prListCode ?? ''),
             _buildTitleText(AppLocalizations.of(context)!.payTermsCode, customer.payTermsCode ?? ''),
            _buildTitleTextNumber(AppLocalizations.of(context)!.discount, customer.discount ?? ''),
            _buildTitleTextNumber(AppLocalizations.of(context)!.creditLimit, customer.creditLimit ?? ''),
            _buildTitleTextNumber(AppLocalizations.of(context)!.balance, customer.balance ?? ''),
            _buildTitleTextNumber(AppLocalizations.of(context)!.balanceDue, customer.balanceDue ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.note, customer.notes ?? ''),
            Divider(),
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
                      _buildTitleText(AppLocalizations.of(context)!.address+'${index + 1}', address.address ?? 'N/A'),
                      _buildTitleText(AppLocalizations.of(context)!.addressId,address.addressID ?? 'N/A'),
                      _buildTitleText(AppLocalizations.of(context)!.fAddress,address.fAddress ?? 'N/A'),
                      _buildTitleText(AppLocalizations.of(context)!.gpslat, address.gpslat ?? 'N/A'),
                      _buildTitleText(AppLocalizations.of(context)!.gpslong, address.gpslong ?? 'N/A'),
                      _buildTitleText(AppLocalizations.of(context)!.regCode, address.regCode ?? 'N/A'),
                      _buildTitleText(AppLocalizations.of(context)!.note, address.notes ?? 'N/A'),
                      // Add more fields as needed
                     Divider(),
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
                  _buildTitleText(AppLocalizations.of(context)!.contactId+'${index + 1}', contacts?.contactID ?? 'N/A'),
                
                  _buildTitleText(AppLocalizations.of(context)!.contactName, contacts?.contactName ?? 'N/A'),
                  _buildTitleText(AppLocalizations.of(context)!.contactFName, contacts?.contactFName ?? 'N/A'),
                  _buildTitleText(AppLocalizations.of(context)!.fAddress, contacts?.phone ?? 'N/A'),
                  _buildTitleText(AppLocalizations.of(context)!.mobile, contacts?.mobile ?? 'N/A'),
                   _buildTitleText(AppLocalizations.of(context)!.email, contacts?.email ?? 'N/A'),
                  _buildTitleText(AppLocalizations.of(context)!.position, contacts?.position ?? 'N/A'),
                    _buildTitleText(AppLocalizations.of(context)!.note, contacts?.notes ?? 'N/A'),
                  // ... add more fields based on your 'CustomerAddresses' class
Divider(),
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
                  _buildTitleText(AppLocalizations.of(context)!.propCode+'${index+1}', properties?.propCode ?? 'N/A'),
                
                  _buildTitleText(AppLocalizations.of(context)!.note, properties?.notes ?? 'N/A'),
               Divider(),
                 
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


 Widget _buildCustomersItemsSpecialPriceTab(BuildContext context) {
  
  return SingleChildScrollView(
    child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       
        _buildBoxWidgetItemSpecial('customerItemsSpecialPriceBox'),
        _buildBoxWidgetBrandSpecial('customerBrandsSpecialPriceBox'), // Add more boxes as needed
        _buildBoxWidgetGroupSpecial('customerGroupsSpecialPriceBox'), // Add more boxes as needed
        _buildBoxWidgetCategSpecial('customerCategSpecialPriceBox'), // Add more boxes as needed
        
        
      ],
    ),
  );
}

Widget _buildCustomersGroupSpecialPriceTab(BuildContext context) {
  
  return SingleChildScrollView(
    child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        

       
        _buildBoxWidgetGroupItemSpecial('customerGroupItemsSpecialPriceBox'), // Add more boxes as needed
        _buildBoxWidgetGroupBrandSpecial('customerGroupBrandSpecialPriceBox'), // Add more boxes as needed
        _buildBoxWidgetGroupGroupSpecial('customerGroupGroupSpecialPriceBox'), // Add more boxes as needed
        _buildBoxWidgetGroupCategSpecial('customerGroupCategSpecialPriceBox'), // Add more boxes as needed
 
        
      ],
    ),
  );
}

Widget _buildCustomersPropSpecialPriceTab(BuildContext context) {
  
  return SingleChildScrollView(
    child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      
  
        _buildBoxWidgetPropItemsSpecial('customerPropItemsSpecialPriceBox'), // Add more boxes as needed
        _buildBoxWidgetPropBrandSpecial('customerPropBrandSpecialPriceBox'), // Add more boxes as needed
        _buildBoxWidgetPropGroupSpecial('customerPropGroupSpecialPriceBox'), // Add more boxes as needed
        _buildBoxWidgetPropCategSpecial('customerPropCategSpecialPriceBox'), // Add more boxes as needed
        
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
                      _buildTitleText(AppLocalizations.of(context)!.itemcode, itemspecials?.itemCode ?? 'N/A'),
                      _buildTitleText(AppLocalizations.of(context)!.uom, itemspecials?.uom ?? 'N/A'),
                      _buildTitleTextNumber(AppLocalizations.of(context)!.baseprice, itemspecials?.basePrice ?? 'N/A'),
                      _buildTitleTextNumber(AppLocalizations.of(context)!.currency, itemspecials?.currency ?? 'N/A'),
                      _buildTitleTextNumber(AppLocalizations.of(context)!.auto, itemspecials?.auto ?? 'N/A'),
                       _buildTitleTextNumber(AppLocalizations.of(context)!.disc, itemspecials?.disc ?? 'N/A'),
                      _buildTitleTextNumber(AppLocalizations.of(context)!.price, itemspecials?.price ?? 'N/A'),
                        _buildTitleText(AppLocalizations.of(context)!.note, itemspecials?.notes ?? 'N/A'),
                          Divider(),
                      
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
                      _buildTitleText(AppLocalizations.of(context)!.brandcode, brandspecials?.brandCode ?? 'N/A'),
                      _buildTitleTextNumber(AppLocalizations.of(context)!.disc, brandspecials?.disc ?? 'N/A'),
                      _buildTitleText(AppLocalizations.of(context)!.note, brandspecials?.notes ?? 'N/A'),
                      Divider(),
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
                      _buildTitleText(AppLocalizations.of(context)!.fAddress, grouppecials?.groupCode ?? 'N/A'),
                      _buildTitleTextNumber(AppLocalizations.of(context)!.disc, grouppecials?.disc ?? 'N/A'),
                      _buildTitleText(AppLocalizations.of(context)!.note, grouppecials?.notes ?? 'N/A'),
                      Divider(),
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
                      _buildTitleText(AppLocalizations.of(context)!.categcode, categpecials?.categCode ?? 'N/A'),
                      _buildTitleTextNumber(AppLocalizations.of(context)!.disc, categpecials?.disc ?? 'N/A'),
                      _buildTitleText(AppLocalizations.of(context)!.note, categpecials?.notes ?? 'N/A'),
                      Divider(),
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
                      _buildTitleText(AppLocalizations.of(context)!.groupcode, categpecials?.custGroupCode ?? 'N/A'),
                      _buildTitleText(AppLocalizations.of(context)!.itemcode, categpecials?.itemCode ?? 'N/A'),
                      _buildTitleText(AppLocalizations.of(context)!.uom, categpecials?.uom ?? 'N/A'),
                      _buildTitleTextNumber(AppLocalizations.of(context)!.baseprice, categpecials?.basePrice ?? 'N/A'),
                    _buildTitleTextNumber(AppLocalizations.of(context)!.auto, categpecials?.auto ?? 'N/A'),
                    _buildTitleTextNumber(AppLocalizations.of(context)!.disc, categpecials?.disc ?? 'N/A'),
                    _buildTitleTextNumber(AppLocalizations.of(context)!.price, categpecials?.price ?? 'N/A'),
                     _buildTitleTextNumber(AppLocalizations.of(context)!.note, categpecials?.notes ?? 'N/A'),
                     Divider(),
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
                    
                      _buildTitleText(AppLocalizations.of(context)!.brandcode, brandpecials?.brandCode ?? 'N/A'),
                    _buildTitleTextNumber(AppLocalizations.of(context)!.disc, brandpecials?.disc ?? 'N/A'),
                     _buildTitleTextNumber(AppLocalizations.of(context)!.note, brandpecials?.notes ?? 'N/A'),
                     Divider(),
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
                      _buildTitleText(AppLocalizations.of(context)!.groupcode, brandpecials?.custGroupCode ?? 'N/A'),
                    _buildTitleTextNumber(AppLocalizations.of(context)!.disc, brandpecials?.disc ?? 'N/A'),
                     _buildTitleTextNumber(AppLocalizations.of(context)!.note, brandpecials?.notes ?? 'N/A'),
                     Divider(),
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
                      _buildTitleText(AppLocalizations.of(context)!.categcode, categpecials?.categCode ?? 'N/A'),
                    _buildTitleTextNumber(AppLocalizations.of(context)!.disc, categpecials?.disc ?? 'N/A'),
                     _buildTitleTextNumber(AppLocalizations.of(context)!.note, categpecials?.notes ?? 'N/A'),
                     Divider(),
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
                      _buildTitleText(AppLocalizations.of(context)!.propCode, propitemspecialss?.custPropCode ?? 'N/A'),
                    _buildTitleTextNumber(AppLocalizations.of(context)!.itemcode, propitemspecialss?.itemCode ?? 'N/A'),
                     _buildTitleTextNumber(AppLocalizations.of(context)!.baseprice, propitemspecialss?.basePrice ?? 'N/A'),
                      _buildTitleTextNumber(AppLocalizations.of(context)!.currency, propitemspecialss?.currency ?? 'N/A'),
                             _buildTitleTextNumber(AppLocalizations.of(context)!.auto, propitemspecialss?.auto ?? 'N/A'),
                                _buildTitleTextNumber(AppLocalizations.of(context)!.disc, propitemspecialss?.disc ?? 'N/A'),
                           _buildTitleTextNumber(AppLocalizations.of(context)!.note, propitemspecialss?.auto ?? 'N/A'),
                           Divider(),

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
                
                    _buildTitleTextNumber(AppLocalizations.of(context)!.brandcode, propitemspecialss?.brandCode ?? 'N/A'),
                     _buildTitleTextNumber(AppLocalizations.of(context)!.disc, propitemspecialss?.disc ?? 'N/A'),
                      _buildTitleTextNumber(AppLocalizations.of(context)!.note, propitemspecialss?.notes ?? 'N/A'),
                      Divider(),
                          

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
                
                    _buildTitleTextNumber(AppLocalizations.of(context)!.groupcode, propitemspecialss?.custGroupCode ?? 'N/A'),
                     _buildTitleTextNumber(AppLocalizations.of(context)!.disc, propitemspecialss?.disc ?? 'N/A'),
                      _buildTitleTextNumber(AppLocalizations.of(context)!.note, propitemspecialss?.notes ?? 'N/A'),
                      Divider(),
                          

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
                
                    _buildTitleTextNumber(AppLocalizations.of(context)!.categcode, propitemspecialss?.categCode ?? 'N/A'),
                     _buildTitleTextNumber(AppLocalizations.of(context)!.disc, propitemspecialss?.disc ?? 'N/A'),
                      _buildTitleTextNumber(AppLocalizations.of(context)!.note, propitemspecialss?.notes ?? 'N/A'),
                      Divider(),
                          

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
