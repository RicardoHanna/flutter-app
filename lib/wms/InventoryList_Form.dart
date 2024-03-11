import 'package:flutter/material.dart';
import 'package:project/app_notifier.dart';
import 'package:project/wms/ItemQuantity_Form.dart';

class InventoryList extends StatefulWidget {
  final AppNotifier appNotifier;
  final String usercode;
  const InventoryList(
      {super.key, required this.appNotifier, required this.usercode});

  @override
  State<InventoryList> createState() => _InventoryListState();
}

class _InventoryListState extends State<InventoryList> {
  TextEditingController itemNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inventory List',
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
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: itemNameController,
              decoration: InputDecoration(
                  labelText: 'Search',
                  labelStyle: TextStyle(
                      fontSize: widget.appNotifier.fontSize.toDouble() - 2)),
              onChanged: (value) {
                // itemName = value;
              },
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "OnHand",
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.black54,
                          fontSize: widget.appNotifier.fontSize.toDouble() - 5),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      "Commit.",
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.black54,
                          fontSize: widget.appNotifier.fontSize.toDouble() - 5),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      "Ordered",
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.black54,
                          fontSize: widget.appNotifier.fontSize.toDouble() - 5),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      "Avail.",
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.black54,
                          fontSize: widget.appNotifier.fontSize.toDouble() - 5),
                    ),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (builder)=>ItemQuantityScreen(appNotifier: widget.appNotifier, usercode: widget.usercode)));
                      },
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ItemCode: ',
                            style: TextStyle(
                                fontSize:
                                    widget.appNotifier.fontSize.toDouble() - 2),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "OnHand",
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize:
                                        widget.appNotifier.fontSize.toDouble() -
                                            5),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                "Commit.",
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize:
                                        widget.appNotifier.fontSize.toDouble() -
                                            5),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                "Ordered",
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize:
                                        widget.appNotifier.fontSize.toDouble() -
                                            5),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                "Avail.",
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize:
                                        widget.appNotifier.fontSize.toDouble() -
                                            5),
                              ),
                            ],
                          )
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WareHouses: ',
                            style: TextStyle(
                                    color: Colors.black54,
                                    fontSize:
                                        widget.appNotifier.fontSize.toDouble() -
                                            5),
                          ),
                          Text(
                            'BarCode: ',
                            style: TextStyle(
                                    color: Colors.black54,
                                    fontSize:
                                        widget.appNotifier.fontSize.toDouble() -
                                            5),
                          )
                        ],
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
