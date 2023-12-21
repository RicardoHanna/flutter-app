import 'package:flutter/material.dart';
import 'package:project/Forms/Attachements_Item_Form.dart';
import 'package:project/hive/items_hive.dart';
class ItemsInfoForm extends StatelessWidget {
  final Items item;

  ItemsInfoForm({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item Details'),
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
                      _buildTitleText('Item Code:', item.itemCode ?? ''),
                      _buildTitleText('Item Name:', item.itemName ?? ''),
                    ],
                  ),
                ],
              ),

            // Display item details below the picture and item code
            SizedBox(height: 16.0), // Add spacing between top and details
            _buildTitleText('Item PrName:', item.itemPrFName ?? ''),
            _buildTitleText('Item FName:', item.itemFName ?? ''),
            _buildTitleText('Group Code:', item.groupCode ?? ''),
            _buildTitleText('Categ Code:', item.categCode ?? ''),
            _buildTitleText('Brand Code:', item.brandCode ?? ''),
            _buildTitleText('Item Type:', item.itemType ?? ''),
            _buildTitleText('BarCode:', item.barCode ?? ''),
            _buildTitleText('UOM:', item.uom ?? ''),
            _buildTitleText('Remark:', item.remark ?? ''),
            _buildTitleText('Brand:', item.brand ?? ''),
            _buildTitleText('ManageBy:', item.manageBy ?? ''),
            _buildTitleTextNumber('vatRate:', item.vatRate ?? ''),
            _buildTitleTextNumber('Active:', item.active ?? ''),
            _buildTitleTextNumber('Weight:', item.weight ?? ''),
            _buildTitleText('Charect1:', item.charect1 ?? ''),
            _buildTitleText('Active:', item.charact2 ?? ''),
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
              builder: (context) => AttachementsItemForm(itemCode: item.itemCode),
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
  Widget _buildTitleTextNumber(String title, Object value) {
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
