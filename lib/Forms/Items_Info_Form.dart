import 'package:flutter/material.dart';
import 'package:project/Forms/Attachements_Item_Form.dart';
import 'package:project/app_notifier.dart';
import 'package:project/hive/items_hive.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class ItemsInfoForm extends StatelessWidget {
  final Items item;
    final AppNotifier appNotifier;

  ItemsInfoForm({required this.item,required this.appNotifier});

  @override
  Widget build(BuildContext context) {
  TextStyle   _appTextStyle = TextStyle(fontSize:appNotifier.fontSize.toDouble());
    TextStyle   _appTextStyleAppBar = TextStyle(fontSize:appNotifier.fontSize.toDouble());
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.itemdetails,style: _appTextStyleAppBar,),
      ),
    body: SingleChildScrollView( // Wrap with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display item picture, item code, and item name in a row
              Row(
                children: [
                  Container(
                    height: 80, // Adjust the height as needed
                    width: 80, // Adjust the width as needed
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(item.picture ?? ''), // Use the item's picture URL
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0), // Add spacing between picture and text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleText(AppLocalizations.of(context)!.itemcode, item.itemCode ?? ''),
                      _buildTitleText(AppLocalizations.of(context)!.itemname, item.itemName ?? ''),
                    ],
                  ),
                ],
              ),

            // Display item details below the picture and item code
            SizedBox(height: 16.0), // Add spacing between top and details
            _buildTitleText(AppLocalizations.of(context)!.itemprname, item.itemPrFName ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.itemfname, item.itemFName ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.groupcode, item.groupCode ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.categcode, item.categCode ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.brandcode, item.brandCode ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.itemtype, item.itemType ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.barcode, item.barCode ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.uom, item.uom ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.remark, item.remark ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.brand, item.brand ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.manageby, item.manageBy ?? ''),
            _buildTitleTextNumber(AppLocalizations.of(context)!.vatrate, item.vatRate ?? ''),
            _buildTitleTextNumber(AppLocalizations.of(context)!.active, item.active ?? ''),
            _buildTitleTextNumber(AppLocalizations.of(context)!.weight, item.weight ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.charect1, item.charect1 ?? ''),
            _buildTitleText(AppLocalizations.of(context)!.charect2, item.charact2 ?? ''),
          ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to AttachementsItemForm when the button is pressed
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AttachementsItemForm(itemCode: item.itemCode,appNotifier: appNotifier,),
            ),
          );
        },
        child: Icon(Icons.attach_file),
      ),
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
