import 'package:flutter/material.dart';
import 'package:project/Forms/Attachements_Item_Form.dart';
import 'package:project/app_notifier.dart';
import 'package:project/hive/items_hive.dart';
import 'package:project/hive/itemsprices_hive.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PriceItemsInfo extends StatelessWidget {
  
  
  final ItemsPrices itemsPrices;
  final AppNotifier appNotifier;

  PriceItemsInfo({required this.itemsPrices,required this.appNotifier});

  @override
  Widget build(BuildContext context) {
  TextStyle _appTextStyle = TextStyle(fontSize: appNotifier.fontSize.toDouble());
  TextStyle _appTextStyleAppBar = TextStyle(fontSize: appNotifier.fontSize.toDouble());
  
  return Scaffold(
    appBar: AppBar(
      title: Text(AppLocalizations.of(context)!.itempricedetails, style: _appTextStyleAppBar),
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: Text(AppLocalizations.of(context)!.plcode),
              subtitle: Text(itemsPrices.plCode ?? 'N/A'),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.itemcode),
              subtitle: Text(itemsPrices.itemCode ?? 'N/A'),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.uom),
              subtitle: Text(itemsPrices.uom ?? 'N/A'),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.baseprice),
              subtitle: Text(itemsPrices.basePrice.toString() ?? 'N/A'),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.currency),
              subtitle: Text(itemsPrices.currency.toString() ?? 'N/A'),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.authorizations),
              subtitle: Text(itemsPrices.auto.toString() ?? 'N/A'),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.disc),
              subtitle: Text(itemsPrices.disc.toString() ?? 'N/A'),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.price),
              subtitle: Text(itemsPrices.price.toString() ?? 'N/A'),
            ),
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
            builder: (context) => AttachementsItemForm(itemCode: itemsPrices.itemCode, appNotifier: appNotifier),
          ),
        );
      },
      child: Icon(Icons.attach_file),
    ),
  );
}


Widget _buildTitleText(String title, String value) {
  TextStyle _appTextStyle = TextStyle(fontSize: appNotifier.fontSize.toDouble() - 4);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          color: Colors.blue,
          fontSize: appNotifier.fontSize.toDouble(),
          fontWeight: FontWeight.bold,
        ),
        textDirection: TextDirection.rtl, // Set text direction to RTL
      ),
      Text(
        value,
        style: _appTextStyle,
        textDirection: TextDirection.rtl, // Set text direction to RTL
      ),
    ],
  );
}

Widget _buildTitleNumber(String title, Object value) {
  TextStyle _appTextStyle = TextStyle(fontSize: appNotifier.fontSize.toDouble() - 4);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          color: Colors.blue,
          fontSize: appNotifier.fontSize.toDouble(),
          fontWeight: FontWeight.bold,
        ),
        textDirection: TextDirection.rtl, // Set text direction to RTL
      ),
      Text(
        value.toString(),
        style: _appTextStyle,
        textDirection: TextDirection.rtl, // Set text direction to RTL
      ),
    ],
  );
}


  Widget _buildText(String title, String value) {
    return Text('$title $value');
  }
}