import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:project/Forms/Attachements_Item_Form.dart';
import 'package:project/app_notifier.dart';
import 'package:project/hive/customeraddresses_hive.dart';
import 'package:project/hive/customercontacts_hive.dart';
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
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Expanded(
            child: Text(AppLocalizations.of(context)!.itemdetails, style: _appTextStyleAppBar),
          ),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Customers'),
              Tab(text: 'Customers Address'),
              Tab(text: 'Customers Contacts'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCustomersTab(context),
            _buildCustomersAddressTab(context),
            _buildCustomersContactsTab(context),
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
                      _buildTitleText(AppLocalizations.of(context)!.itemcode, customer.custCode ?? ''),
                      _buildTitleText(AppLocalizations.of(context)!.itemname, customer.custName ?? ''),
                          _buildTitleText(AppLocalizations.of(context)!.itemname, customer.custFName ?? ''),
                    ],
                  ),
                ],
              ),

          
            _buildTitleText(AppLocalizations.of(context)!.itemprname, customer.cmpCode ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.itemfname, customer.curCode ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.groupcode, customer.groupCode ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.categcode, customer.mofNum ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.brandcode, customer.barcode ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.itemtype, customer.phone ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.barcode, customer.mobile ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.uom, customer.fax ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.remark, customer.website ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.brand, customer.email ?? ''),
            _buildTitleTextNumber(AppLocalizations.of(context)!.manageby, customer.active),
          _buildTitleText(AppLocalizations.of(context)!.remark, customer.printLayout ?? ''),
          _buildTitleText(AppLocalizations.of(context)!.remark, customer.dfltAddressID ?? ''),
           _buildTitleText(AppLocalizations.of(context)!.remark, customer.curCode ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.remark, customer.cashClient ?? ''),
             _buildTitleText(AppLocalizations.of(context)!.remark, customer.discType ?? ''),
             _buildTitleText(AppLocalizations.of(context)!.remark, customer.vatCode ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.remark, customer.prListCode ?? ''),
             _buildTitleText(AppLocalizations.of(context)!.remark, customer.payTermsCode ?? ''),
            _buildTitleTextNumber(AppLocalizations.of(context)!.vatrate, customer.discount ?? ''),
            _buildTitleTextNumber(AppLocalizations.of(context)!.active, customer.creditLimit ?? ''),
            _buildTitleTextNumber(AppLocalizations.of(context)!.weight, customer.balance ?? ''),
            _buildTitleTextNumber(AppLocalizations.of(context)!.charect1, customer.balanceDue ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.charect2, customer.notes ?? ''),
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
          // Fetch data from the box and use it in your UI
String key=customer.cmpCode;
String key1=customer.custCode;
String key3=customer.dfltAddressID;
CustomerAddresses? address = customerAddressesBox.get('$key$key1$key3');


          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display fetched data with null-aware operator
                  _buildTitleText('Address', address?.address ?? 'N/A'),
                
                  _buildTitleText('AddressId', address?.addressID ?? 'N/A'),
                  _buildTitleText('fAddress', address?.fAddress ?? 'N/A'),
                  _buildTitleText('gpslat', address?.gpslat ?? 'N/A'),
                  _buildTitleText('gpslong', address?.gpslong ?? 'N/A'),
                   _buildTitleText('RegCode', address?.regCode ?? 'N/A'),
                    _buildTitleText('Notes', address?.notes ?? 'N/A'),
                  // ... add more fields based on your 'CustomerAddresses' class
                ],
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
String key=customer.cmpCode;
String key1=customer.custCode;
String key3=customer.dfltContactID;
CustomerContacts? contact = customerContactsBox.get('$key$key1$key3');


          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display fetched data with null-aware operator
                  _buildTitleText('ContactId', contact?.contactID ?? 'N/A'),
                
                  _buildTitleText('Contact Name', contact?.contactName ?? 'N/A'),
                  _buildTitleText('Contact FName', contact?.contactFName ?? 'N/A'),
                  _buildTitleText('Phone', contact?.phone ?? 'N/A'),
                  _buildTitleText('Mobile', contact?.mobile ?? 'N/A'),
                   _buildTitleText('Email', contact?.email ?? 'N/A'),
                  _buildTitleText('Position', contact?.position ?? 'N/A'),
                    _buildTitleText('Notes', contact?.notes ?? 'N/A'),
                  // ... add more fields based on your 'CustomerAddresses' class
                ],
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
