import 'package:flutter/material.dart';
import 'package:project/Forms/Inventory_Form.dart';
import 'package:project/app_notifier.dart';
import 'package:project/wms/InventoryList_Form.dart';

class SupplierNewReceipt extends StatefulWidget {
  final AppNotifier appNotifier;
  final String usercode;
  final String supplierCode;
  const SupplierNewReceipt(
      {super.key,
      required this.appNotifier,
      required this.usercode,
      required this.supplierCode});

  @override
  State<SupplierNewReceipt> createState() => _SupplierNewReceiptState();
}

class _SupplierNewReceiptState extends State<SupplierNewReceipt> {
  static List<Map<String, dynamic>> items = [
  {
    'itemCode': '001',
    'units': '5 Units',
    'barCode': '123456789',
    'itemName': 'Widget A',
    'wareHouse': 'Warehouse X',
  },
  {
    'itemCode': '002',
    'units': '2 Units',
    'barCode': '987654321',
    'itemName': 'Gadget B',
    'wareHouse': 'Warehouse Y',
  },
  {
    'itemCode': '003',
    'units': '3 Units',
    'barCode': '555555555',
    'itemName': 'Thingamajig C',
    'wareHouse': 'Warehouse Z',
  },
  {
    'itemCode': '004',
    'units': '8 Units',
    'barCode': '888888888',
    'itemName': 'Doodad D',
    'wareHouse': 'Warehouse X',
  },
  {
    'itemCode': '005',
    'units': '1 Unit',
    'barCode': '777777777',
    'itemName': 'Contraption E',
    'wareHouse': 'Warehouse Z',
  },
  {
    'itemCode': '006',
    'units': '6 Units',
    'barCode': '444444444',
    'itemName': 'Gizmo F',
    'wareHouse': 'Warehouse Y',
  },
  {
    'itemCode': '007',
    'units': '4 Units',
    'barCode': '666666666',
    'itemName': 'Widget G',
    'wareHouse': 'Warehouse X',
  },
  {
    'itemCode': '008',
    'units': '2 Units',
    'barCode': '999999999',
    'itemName': 'Doodad H',
    'wareHouse': 'Warehouse Z',
  },
  {
    'itemCode': '009',
    'units': '7 Units',
    'barCode': '333333333',
    'itemName': 'Thingamajig I',
    'wareHouse': 'Warehouse Y',
  },
  {
    'itemCode': '010',
    'units': '3 Units',
    'barCode': '111111111',
    'itemName': 'Contraption J',
    'wareHouse': 'Warehouse X',
  },
];
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
                Icons.attach_file,
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
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (builder)=>InventoryList(appNotifier: widget.appNotifier, usercode: widget.usercode))
                );
              },
              child: Text(
                "Add Item",
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
                  "Item",
                  style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                      fontSize: widget.appNotifier.fontSize.toDouble() - 5),
                ),
                Text(
                  "Quantity",
                  style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                      fontSize: widget.appNotifier.fontSize.toDouble() - 5),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Card(
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ItemCode: ',
                              style: TextStyle(
                                fontSize:
                                    widget.appNotifier.fontSize.toDouble() - 2,
                              ),
                            ),
                            Text(
                              '4 Units',
                              style: TextStyle(
                                fontSize:
                                    widget.appNotifier.fontSize.toDouble() - 5,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BarCode: ',
                              style: TextStyle(
                                fontSize:
                                    widget.appNotifier.fontSize.toDouble() - 5,
                              ),
                            ),
                            Text(
                              'ItemName: ',
                              style: TextStyle(
                                fontSize:
                                    widget.appNotifier.fontSize.toDouble() - 5,
                              ),
                            ),
                            Text(
                              'WareHouse: ',
                              style: TextStyle(
                                fontSize:
                                    widget.appNotifier.fontSize.toDouble() - 5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}


