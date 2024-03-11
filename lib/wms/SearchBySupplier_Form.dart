import 'package:flutter/material.dart';
import 'package:project/app_notifier.dart';
import 'package:project/wms/Receiving_Form.dart';

class SearchBySupplierScreen extends StatefulWidget {
  final AppNotifier appNotifier;
  final String usercode;
  const SearchBySupplierScreen(
      {super.key, required this.appNotifier, required this.usercode});

  @override
  State<SearchBySupplierScreen> createState() => _SearchBySupplierScreenState();
}

class _SearchBySupplierScreenState extends State<SearchBySupplierScreen> {
  TextEditingController supplierNameController = TextEditingController();
  List<Map<String, dynamic>> suppliers = [
    {"SupplierCode": "001", "SupplierName": "Supplier A"},
    {"SupplierCode": "002", "SupplierName": "Supplier B"},
    {"SupplierCode": "003", "SupplierName": "Supplier C"},
    {"SupplierCode": "004", "SupplierName": "Supplier D"},
    {"SupplierCode": "005", "SupplierName": "Supplier E"},
    {"SupplierCode": "006", "SupplierName": "Supplier F"},
    {"SupplierCode": "007", "SupplierName": "Supplier G"},
    {"SupplierCode": "008", "SupplierName": "Supplier H"},
    {"SupplierCode": "009", "SupplierName": "Supplier I"},
    {"SupplierCode": "010", "SupplierName": "Supplier J"},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Suppliers',
          style: TextStyle(
              color: Colors.white,
              fontSize: widget.appNotifier.fontSize.toDouble()),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
              )),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: supplierNameController,
              decoration: InputDecoration(
                  labelText: 'Search',
                  labelStyle: TextStyle(
                      fontSize: widget.appNotifier.fontSize.toDouble() - 2)),
              onChanged: (value) {
                // itemName = value;
              },
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: suppliers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 1.0),
                      child: Card(
                        child: ListTile(
                            onTap: () {
                              // itemNameController.text = suppliers[index]["SupplierCode"];
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (builder) => ReceivingScreen(
                                          appNotifier: widget.appNotifier,
                                          usercode: widget.usercode)));
                            },
                            title: Text(
                              "SupplierCode: ${suppliers[index]["SupplierCode"]}",
                              style: TextStyle(
                                fontSize:
                                    widget.appNotifier.fontSize.toDouble() - 2,
                              ),
                            ),
                            subtitle: Text(
                              "SupplierName: ${suppliers[index]["SupplierName"]}",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize:
                                    widget.appNotifier.fontSize.toDouble() - 5,
                              ),
                            )),
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
