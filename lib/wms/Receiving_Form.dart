import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:project/app_notifier.dart';
import 'package:project/wms/Order_Form.dart';

class ReceivingScreen extends StatefulWidget {
  final AppNotifier appNotifier;
  final String usercode;

  ReceivingScreen({required this.appNotifier, required this.usercode});
  @override
  _ReceivingScreenState createState() => _ReceivingScreenState();
}

class _ReceivingScreenState extends State<ReceivingScreen> {
  TextEditingController itemNameController = TextEditingController();
  List<Map<String, String>> orders = [
    {"OrderNumber": "123", "DeliveryDate": "2024-03-10", "cmpCode": "ABC"},
    {"OrderNumber": "456", "DeliveryDate": "2024-03-15", "cmpCode": "XYZ"},
    {"OrderNumber": "789", "DeliveryDate": "2024-03-20", "cmpCode": "DEF"},
    {"OrderNumber": "101", "DeliveryDate": "2024-03-25", "cmpCode": "GHI"},
    {"OrderNumber": "202", "DeliveryDate": "2024-03-30", "cmpCode": "JKL"},
    {"OrderNumber": "303", "DeliveryDate": "2024-04-05", "cmpCode": "MNO"},
    {"OrderNumber": "404", "DeliveryDate": "2024-04-10", "cmpCode": "PQR"},
    {"OrderNumber": "505", "DeliveryDate": "2024-04-15", "cmpCode": "STU"},
    {"OrderNumber": "606", "DeliveryDate": "2024-04-20", "cmpCode": "VWX"},
    {"OrderNumber": "707", "DeliveryDate": "2024-04-25", "cmpCode": "YZA"},
    {"OrderNumber": "123", "DeliveryDate": "2024-03-10", "cmpCode": "ABC"},
    {"OrderNumber": "456", "DeliveryDate": "2024-03-15", "cmpCode": "XYZ"},
    {"OrderNumber": "789", "DeliveryDate": "2024-03-20", "cmpCode": "DEF"},
    {"OrderNumber": "101", "DeliveryDate": "2024-03-25", "cmpCode": "GHI"},
    {"OrderNumber": "202", "DeliveryDate": "2024-03-30", "cmpCode": "JKL"},
    {"OrderNumber": "303", "DeliveryDate": "2024-04-05", "cmpCode": "MNO"},
    {"OrderNumber": "404", "DeliveryDate": "2024-04-10", "cmpCode": "PQR"},
    {"OrderNumber": "505", "DeliveryDate": "2024-04-15", "cmpCode": "STU"},
    {"OrderNumber": "606", "DeliveryDate": "2024-04-20", "cmpCode": "VWX"},
    {"OrderNumber": "707", "DeliveryDate": "2024-04-25", "cmpCode": "YZA"},
  ];

  String itemName = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Receipt',
          style: TextStyle(
              color: Colors.white,
              fontSize: widget.appNotifier.fontSize.toDouble()),
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.history,
                color: Colors.white,
              )),
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: itemNameController,
                    decoration: InputDecoration(
                        labelText: 'Search',
                        labelStyle: TextStyle(
                            fontSize:
                                widget.appNotifier.fontSize.toDouble() - 2)),
                    onChanged: (value) {
                      itemName = value;
                    },
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    print(orders.length);
                  },
                  child: SizedBox(
                    width: 40, // Decrease width here
                    height: 40, // Decrease height here
                    child: Center(
                      child: Text(
                        "...",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: widget.appNotifier.fontSize.toDouble(),
                        ),
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero, // Remove padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          20), // Adjust borderRadius to maintain button shape
                    ),
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text(
                "New Receipt",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.appNotifier.fontSize.toDouble()),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          20), // Adjust borderRadius to maintain button shape
                    ),
                backgroundColor: Colors.blue,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "OrderNumber",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: widget.appNotifier.fontSize.toDouble() - 5),
                ),
                Text(
                  "DeliveryDate",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: widget.appNotifier.fontSize.toDouble() - 5),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 1.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (builder) => OrderForm(
                                  order: orders[index],
                                  appNotifier: widget.appNotifier)));
                        },
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${orders[index]["OrderNumber"]}",
                              style: TextStyle(
                                fontSize:
                                    widget.appNotifier.fontSize.toDouble()-2,
                              ),
                            ),
                            Text(
                              "${orders[index]["DeliveryDate"]}",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize:
                                    widget.appNotifier.fontSize.toDouble()-5,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          "${orders[index]["cmpCode"]}",
                          style: TextStyle(
                            fontSize: widget.appNotifier.fontSize.toDouble()-5,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
