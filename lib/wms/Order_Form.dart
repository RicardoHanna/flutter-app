import 'package:flutter/material.dart';
import 'package:project/app_notifier.dart';

class OrderForm extends StatefulWidget {
  final Map<String, String> order;
  final AppNotifier appNotifier;
  const OrderForm({super.key, required this.order, required this.appNotifier});

  @override
  State<OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.order['OrderNumber']!,
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
            Text(
              "${widget.order['DeliveryDate']}",
              style:
                  TextStyle(fontSize: widget.appNotifier.fontSize.toDouble(),color: Colors.black54,),
                 
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              '${widget.order['cmpCode']!}',
              style:
                  TextStyle(fontSize: widget.appNotifier.fontSize.toDouble(),color: Colors.black54),
            ),
            SizedBox(
              height: 5,
            ),
            ElevatedButton(
              onPressed: () {},
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
                    color: Colors.black54,
                      fontSize: widget.appNotifier.fontSize.toDouble()-5),
                ),
                Text(
                  "Quantity",
                  style: TextStyle(
                       color: Colors.black54,
                      fontSize: widget.appNotifier.fontSize.toDouble()-5),
                )
              ],
            ),
            SizedBox(
              height: 8,
            ),
       Expanded(
  child: ListView.builder(
    itemCount: 6, // Assuming you have only one order
    itemBuilder: (context, index) {
      return Padding(
        padding: EdgeInsets.only(bottom: 8.0),
        child: Card(
          child: ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "ItemCode",
                  style: TextStyle(
                      fontSize: widget.appNotifier.fontSize.toDouble()-2),
                ),
                Text(
                  "0 / 4 Units",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: widget.appNotifier.fontSize.toDouble()-5),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                Text(
                  "BarCode: ",
                  style: TextStyle(
                      fontSize: widget.appNotifier.fontSize.toDouble()-5),
                ),
                Text(
                  "ItemName",
                  style: TextStyle(
                      fontSize: widget.appNotifier.fontSize.toDouble()-5),
                ),
                Text(
                  "WareHouse",
                  style: TextStyle(
                      fontSize: widget.appNotifier.fontSize.toDouble()-5),
                ),
                Text(
                  "OutBound Quantity",
                  style: TextStyle(
                      fontSize: widget.appNotifier.fontSize.toDouble()-5),
                ),
              ],
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
