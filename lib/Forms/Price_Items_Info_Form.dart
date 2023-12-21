import 'package:flutter/material.dart';
import 'package:project/Forms/Attachements_Item_Form.dart';
import 'package:project/app_notifier.dart';
import 'package:project/hive/items_hive.dart';
import 'package:project/hive/itemsprices_hive.dart';


class PriceItemsInfo extends StatelessWidget {
  
  
  final ItemsPrices itemsPrices;
  final AppNotifier appNotifier;

  PriceItemsInfo({required this.itemsPrices,required this.appNotifier});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item Price Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleText('PL Code: ', itemsPrices.plCode ?? ''),
            _buildTitleText('Item Code: ',itemsPrices.itemCode ?? ''),
            _buildTitleText('UOM: ',itemsPrices.uom?? ''),
            _buildTitleNumber('Base Price: ',itemsPrices.basePrice?? ''),
            _buildTitleText('Currency: ',itemsPrices.currency?? ''),
            _buildTitleNumber('Auto: ',itemsPrices.auto?? ''),
            _buildTitleNumber('Disc:',itemsPrices.disc?? ''),
            _buildTitleNumber('Price: ',itemsPrices.price?? ''),
            // Add more details if needed
          ],
        ),
      ),
         floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to AttachementsItemForm when the button is pressed
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AttachementsItemForm(itemCode: itemsPrices.itemCode),
            ),
          );
        },
        child: Icon(Icons.attach_file),
      ),
    );
  }

  Widget _buildTitleText(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.blue, // Set the text color to blue
            fontSize: 16.0, // Set the font size
            fontWeight: FontWeight.bold, // Set the font weight to bold
          ),
        ),
        Text(value),
      ],
    );
  }

  Widget _buildTitleNumber(String title, Object value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.blue, // Set the text color to blue
            fontSize: 16.0, // Set the font size
            fontWeight: FontWeight.bold, // Set the font weight to bold
          ),
        ),
        Text(value.toString()),
      ],
    );
  }

  Widget _buildText(String title, String value) {
    return Text('$title $value');
  }
}