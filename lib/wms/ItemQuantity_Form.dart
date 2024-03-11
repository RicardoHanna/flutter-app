import 'package:flutter/material.dart';
import 'package:project/app_notifier.dart';

class ItemQuantityScreen extends StatefulWidget {
  final AppNotifier appNotifier;
  final String usercode;
  const ItemQuantityScreen(
      {super.key, required this.appNotifier, required this.usercode});

  @override
  State<ItemQuantityScreen> createState() => _ItemQuantityScreenState();
}

class _ItemQuantityScreenState extends State<ItemQuantityScreen> {
  TextEditingController quantityController = TextEditingController();
  String dropdownValue = 'Units';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Quantity',
          style: TextStyle(
              color: Colors.white,
              fontSize: widget.appNotifier.fontSize.toDouble()),
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
              )),
        ],
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Item: ItemCode (ItemName)',
              style: TextStyle(
                  fontSize: widget.appNotifier.fontSize.toDouble() - 2,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    decoration: InputDecoration(
                        labelText: 'Quantity',
                        labelStyle: TextStyle(
                            fontSize:
                                widget.appNotifier.fontSize.toDouble() - 2)),
                    onChanged: (value) {
                      // itemName = value;
                    },
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    style: TextStyle(fontSize:
                                widget.appNotifier.fontSize.toDouble() - 2,color: Colors.black),
                    underline: Container(
                      height: 2,
                      color: Colors.black45,
                    ),
                    items: <String>['Units', 'Two', 'Three', 'Four']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {},
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
