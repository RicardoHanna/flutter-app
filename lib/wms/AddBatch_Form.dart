import 'package:flutter/material.dart';
import 'package:project/app_notifier.dart';

class AddBatch extends StatefulWidget {
  final AppNotifier appNotifier;
  final String usercode;
  final int index;
  final List<Map<dynamic, dynamic>> items;
  final int itemQuantities;
final Function(BuildContext,int, int , String) addQuantity;
  const AddBatch(
      {Key? key,
      required this.appNotifier,
      required this.usercode,
      required this.items,
      required this.index,
      required this.addQuantity, // Add this line
      required this.itemQuantities,

      })
      : super(key: key);

  @override
  State<AddBatch> createState() => _AddBatchState();
}

class _AddBatchState extends State<AddBatch> {
  TextEditingController quantityController = TextEditingController();
  String dropdownValue = 'Units';
  List<Map<dynamic, dynamic>> itemsorders = [];

  @override
  void initState() {
    super.initState();
    itemsorders = widget.items;
  }

  @override
 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Add Batch',
        style: TextStyle(
          color: Colors.white,
          fontSize: widget.appNotifier.fontSize.toDouble(),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.qr_code_scanner,
            color: Colors.white,
          ),
        ),
      ],
      backgroundColor: Colors.blue,
    ),
    body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${itemsorders[widget.index]['itemCode']} ${itemsorders[widget.index]['itemName']}',
            style: TextStyle(fontSize: widget.appNotifier.fontSize.toDouble() - 2),
          ),
          SizedBox(height: 10),
          Text(
            'Remaining Quantity: ${widget.itemQuantities.toString()??0}',
            style: TextStyle(fontSize: widget.appNotifier.fontSize.toDouble() - 2, color: Colors.black54),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    labelStyle: TextStyle(fontSize: widget.appNotifier.fontSize.toDouble() - 2),
                    suffixText: 'Units', // Text next to the text field
                  ),
                ),
              ),
            ],
          ),
              ElevatedButton(
  onPressed: () {
        int newQuantity = int.tryParse(quantityController.text) ?? 0;

    if(widget.itemQuantities<0 || widget.itemQuantities == 0 || newQuantity > widget.itemQuantities){
        ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Over Quantity Not Allowed!'),
                  ),
                );
                return;
    }
   // widget.addQuantity(context, widget.index, newQuantity); // Pass the context here
    Navigator.pop(context); // Close the screen
    Navigator.pop(context);
  },
  child: Text('Add Batch Number'),
),
          SizedBox(height: 10), // Add space between the text field and the button
         ElevatedButton(
  onPressed: () {
        int newQuantity = int.tryParse(quantityController.text) ?? 0;

    if(widget.itemQuantities<0 || widget.itemQuantities == 0 || newQuantity > widget.itemQuantities){
        ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Over Quantity Not Allowed!'),
                  ),
                );
                return;
    }
  //  widget.addQuantity(context, widget.index, newQuantity); // Pass the context here
    Navigator.pop(context); // Close the screen
    Navigator.pop(context);
  },
  child: Text('OK'),
),

        ],
      ),
    ),
  );
}
}