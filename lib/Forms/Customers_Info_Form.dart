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
              ListTile(
                      title: Text(AppLocalizations.of(context)!.customerCode),
                    subtitle: Text(customer.custCode ?? ''),
                    ),
                      ListTile(
                      title: Text(AppLocalizations.of(context)!.customerName),
                    subtitle: Text(customer.custName ?? ''),
                    ),
                      ListTile(
                      title: Text(AppLocalizations.of(context)!.customerFName),
                    subtitle: Text(customer.custFName ?? ''),
                    ),
  
                ListTile(
                      title: Text(AppLocalizations.of(context)!.cmpCode),
                    subtitle: Text(customer.cmpCode ?? ''),
                    ),
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.curCode),
                    subtitle: Text(customer.curCode ?? ''),
                    ),
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.groupcode),
                    subtitle: Text(customer.groupCode ?? ''),
                    ),
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.mofNum),
                    subtitle: Text(customer.mofNum ?? ''),
                    ),
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.barcode),
                    subtitle: Text(customer.barcode ?? ''),
                    ),
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.phoneNumber),
                    subtitle: Text(customer.phone ?? ''),
                    ),
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.mobile),
                    subtitle: Text(customer.mobile ?? ''),
                    ),
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.fax),
                    subtitle: Text(customer.cmpCode ?? ''),
                    ),
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.website),
                    subtitle: Text(customer.website ?? ''),
                    ),
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.email),
                    subtitle: Text(customer.email ?? ''),
                    ),
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.active),
                    subtitle: Text(customer.active.toString() ?? ''),
                    ),
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.printLayout),
                    subtitle: Text(customer.printLayout ?? ''),
                    ),
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.defaultAddressID),
                    subtitle: Text(customer.dfltAddressID ?? ''),
                    ),
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.cashClient),
                    subtitle: Text(customer.cashClient ?? ''),
                    ),
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.discountType),
                    subtitle: Text(customer.discType ?? ''),
                    ),
       ListTile(
                      title: Text(AppLocalizations.of(context)!.vatCode),
                    subtitle: Text(customer.vatCode ?? ''),
                    ),
 ListTile(
                      title: Text(AppLocalizations.of(context)!.prListCode),
                    subtitle: Text(customer.prListCode ?? ''),
                    ),

 ListTile(
                      title: Text(AppLocalizations.of(context)!.payTermsCode),
                    subtitle: Text(customer.payTermsCode ?? ''),
                    ),

                     ListTile(
                      title: Text(AppLocalizations.of(context)!.discount),
                    subtitle: Text(customer.discount.toString() ?? ''),
                    ),

                     ListTile(
                      title: Text(AppLocalizations.of(context)!.creditLimit),
                    subtitle: Text(customer.creditLimit.toString() ?? ''),
                    ),

                     ListTile(
                      title: Text(AppLocalizations.of(context)!.balance),
                    subtitle: Text(customer.vatCode ?? ''),
                    ),

                     ListTile(
                      title: Text(AppLocalizations.of(context)!.balanceDue),
                    subtitle: Text(customer.balanceDue.toString() ?? ''),
                    ),

                     ListTile(
                      title: Text(AppLocalizations.of(context)!.note),
                    subtitle: Text(customer.notes ?? ''),
                    ),
           
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
                   return Card(
                      child: ListTile(
                        title: Text(AppLocalizations.of(context)!.address + '${index + 1}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.addressId,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(address.addressID ?? 'N/A'),
                            Text(AppLocalizations.of(context)!.fAddress,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(address.fAddress ?? 'N/A'),
                            Text(AppLocalizations.of(context)!.gpslat,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(address.gpslat ?? 'N/A'),
                              Text(AppLocalizations.of(context)!.gpslong,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(address.gpslong ?? 'N/A'),
                            Text(AppLocalizations.of(context)!.regCode,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(address.regCode ?? 'N/A'),
                             Text('Address Type',style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(address.addressType ?? 'N/A'),
                             Text('Country Code',style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(address.countryCode ?? 'N/A'),
                                Text('City',style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(address.city ?? 'N/A'),
                            Text('Street',style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(address.street ?? 'N/A'),
                            Text('Building',style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(address.building ?? 'N/A'),
                                  Text('Zip Code',style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(address.zipCode ?? 'N/A'),
                              Text(AppLocalizations.of(context)!.note,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(address.notes ?? 'N/A'),
                          ],
                        ),
                      ),
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
                   return Card(
                      child: ListTile(
                        title: Text('Contact' + '${index + 1}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.contactId,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(contacts.contactID ?? 'N/A'),
                            Text(AppLocalizations.of(context)!.contactFName,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(contacts.contactName ?? 'N/A'),
                            Text(AppLocalizations.of(context)!.contactFName,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(contacts.contactFName ?? 'N/A'),
                              Text(AppLocalizations.of(context)!.phoneNumber,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(contacts.phone ?? 'N/A'),
                            Text(AppLocalizations.of(context)!.mobile,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(contacts.mobile ?? 'N/A'),
                             Text(AppLocalizations.of(context)!.email,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(contacts.email ?? 'N/A'),
                             Text(AppLocalizations.of(context)!.position,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(contacts.position ?? 'N/A'),
                        
                     
                              Text(AppLocalizations.of(context)!.note,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(contacts.notes ?? 'N/A'),
                          ],
                        ),
                      ),
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
                      return Card(
                      child: ListTile(
                        title: Text('Property' + '${index + 1}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.propCode,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(properties.propCode ?? 'N/A'),
                            Text(AppLocalizations.of(context)!.note,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(properties.notes ?? 'N/A'),
                            
                          ],
                        ),
                      ),
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
                  return Card(
                      child: ListTile(
                        title: Text('Item Special' + '${index + 1}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.itemcode,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(itemspecials.itemCode ?? 'N/A'),
                            Text(AppLocalizations.of(context)!.uom,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(itemspecials.uom ?? 'N/A'),
                              Text(AppLocalizations.of(context)!.baseprice,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(itemspecials.basePrice ?? 'N/A'),
                               Text(AppLocalizations.of(context)!.auto,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(itemspecials.auto.toString() ?? 'N/A'),
                               Text(AppLocalizations.of(context)!.disc,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(itemspecials.disc.toString() ?? 'N/A'),
                               Text(AppLocalizations.of(context)!.price,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(itemspecials.price.toString() ?? 'N/A'),
                              Text(AppLocalizations.of(context)!.note,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(itemspecials.notes?? 'N/A'),
                          ],
                        ),
                      ),
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
                   return Card(
                      child: ListTile(
                        title: Text('Group Special' + '${index + 1}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.groupcode,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(grouppecials.groupCode ?? 'N/A'),
                            Text(AppLocalizations.of(context)!.disc,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(grouppecials.disc ?? 'N/A'),
                              Text(AppLocalizations.of(context)!.note,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(grouppecials.notes ?? 'N/A'),
                               
                          ],
                        ),
                      ),
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
                    return Card(
                      child: ListTile(
                        title: Text('Categ Special' + '${index + 1}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.categcode,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(categpecials.categCode ?? 'N/A'),
                            Text(AppLocalizations.of(context)!.disc,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(categpecials.disc ?? 'N/A'),
                              Text(AppLocalizations.of(context)!.note,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(categpecials.notes ?? 'N/A'),
                               
                          ],
                        ),
                      ),
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

                   return Card(
                      child: ListTile(
                        title: Text('Group Item Special' + '${index + 1}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.groupcode,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(categpecials.custGroupCode ?? 'N/A'),
                            Text(AppLocalizations.of(context)!.itemcode,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(categpecials.itemCode ?? 'N/A'),
                              Text(AppLocalizations.of(context)!.uom,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(categpecials.uom ?? 'N/A'),
                               Text(AppLocalizations.of(context)!.baseprice,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(categpecials.basePrice ?? 'N/A'),
                             Text(AppLocalizations.of(context)!.auto,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(categpecials.auto.toString() ?? 'N/A'),
                             Text(AppLocalizations.of(context)!.disc,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(categpecials.disc.toString() ?? 'N/A'),
                               Text(AppLocalizations.of(context)!.price,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(categpecials.price.toString() ?? 'N/A'),
                               Text(AppLocalizations.of(context)!.note,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(categpecials.notes ?? 'N/A'),
                          ],
                        ),
                      ),
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
                   return Card(
                      child: ListTile(
                        title: Text('Group Brand Special' + '${index + 1}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.brandcode,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(brandpecials.brandCode?? 'N/A'),
                              Text(AppLocalizations.of(context)!.disc,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(brandpecials.disc.toString()?? 'N/A'),
                              Text(AppLocalizations.of(context)!.note,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(brandpecials.notes ?? 'N/A'),
                        
                          ],
                        ),
                      ),
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
                    return Card(
                      child: ListTile(
                        title: Text('Group Group Special' + '${index + 1}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.groupcode,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(brandpecials.groupCode?? 'N/A'),
                              Text(AppLocalizations.of(context)!.disc,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(brandpecials.disc.toString()?? 'N/A'),
                              Text(AppLocalizations.of(context)!.note,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(brandpecials.notes ?? 'N/A'),
                        
                          ],
                        ),
                      ),
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
                    return Card(
                      child: ListTile(
                        title: Text('Group Categ Special' + '${index + 1}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.categcode,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(categpecials.categCode?? 'N/A'),
                              Text(AppLocalizations.of(context)!.disc,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(categpecials.disc.toString()?? 'N/A'),
                              Text(AppLocalizations.of(context)!.note,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(categpecials.notes ?? 'N/A'),
                        
                          ],
                        ),
                      ),
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
                   return Card(
                      child: ListTile(
                        title: Text('Prop Item Special' + '${index + 1}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.propCode,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(propitemspecialss.custPropCode?? 'N/A'),
                              Text(AppLocalizations.of(context)!.itemcode,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(propitemspecialss.itemCode?? 'N/A'),
                              Text(AppLocalizations.of(context)!.baseprice,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(propitemspecialss.basePrice ?? 'N/A'),
                              Text(AppLocalizations.of(context)!.currency,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(propitemspecialss.currency ?? 'N/A'),
                               Text(AppLocalizations.of(context)!.auto,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(propitemspecialss.auto.toString() ?? 'N/A'),
                        
                          ],
                        ),
                      ),
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

                    return Card(
                      child: ListTile(
                        title: Text('Prop Brand Special' + '${index + 1}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.brandcode,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(propitemspecialss.brandCode?? 'N/A'),
                              Text(AppLocalizations.of(context)!.disc,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(propitemspecialss.disc.toString()?? 'N/A'),
                              Text(AppLocalizations.of(context)!.note,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(propitemspecialss.notes ?? 'N/A'),
                           
                        
                          ],
                        ),
                      ),
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
                    return Card(
                      child: ListTile(
                        title: Text('Prop Group Special' + '${index + 1}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.groupcode,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(propitemspecialss.custGroupCode?? 'N/A'),
                              Text(AppLocalizations.of(context)!.disc,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(propitemspecialss.disc.toString()?? 'N/A'),
                              Text(AppLocalizations.of(context)!.note,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(propitemspecialss.notes ?? 'N/A'),
                           
                        
                          ],
                        ),
                      ),
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

                   return Card(
                      child: ListTile(
                        title: Text('Prop Categ Special' + '${index + 1}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.categcode,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(propitemspecialss.categCode?? 'N/A'),
                              Text(AppLocalizations.of(context)!.disc,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(propitemspecialss.disc.toString()?? 'N/A'),
                              Text(AppLocalizations.of(context)!.note,style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(propitemspecialss.notes ?? 'N/A'),
                           
                        
                          ],
                        ),
                      ),
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
