import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project/app_notifier.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ChangeBatchNumber extends StatefulWidget {
  final AppNotifier appNotifier;
  final String usercode;
  final int index;
  final List<Map<dynamic, dynamic>> items;
  final int itemQuantities;
  final Map<int, List<String>> batches;
    final Map<int, List<String>> quantities;
      final Map<int, List<DateTime>> prodDate;
        final Map<int, List<DateTime>> expDate;
  final Function(BuildContext, int, int, int, Map<int, List<String>>,Map<int, List<String>>,Map<int, List<DateTime>>,Map<int, List<DateTime>>)
      changeQuantityBatch;
  const ChangeBatchNumber(
      {Key? key,
      required this.appNotifier,
      required this.usercode,
      required this.items,
      required this.index,
      required this.changeQuantityBatch, // Add this line
      required this.itemQuantities,
      required this.batches,
      required this.quantities,
      required this.prodDate,
      required this.expDate
      })
      : super(key: key);

  @override
  State<ChangeBatchNumber> createState() => _ChangeBatchNumberState();
}

class _ChangeBatchNumberState extends State<ChangeBatchNumber> {
  TextEditingController quantityController = TextEditingController();
  TextEditingController productionDateController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();
  TextEditingController batchController = TextEditingController();

  List<Map<dynamic, dynamic>> itemsorders = [];
  String apiurl = 'http://5.189.188.139:8080/api/';
  bool _isLoading = false;
  List<Map<dynamic, dynamic>> fetchedData = []; // Define fetchedData list
  List<String> batchNumbers = []; // Maintain a list of serial numbers
  List<TextEditingController> batchControllers =
      []; // Maintain controllers for each serial text field

  @override
  void initState() {
    super.initState();
    itemsorders = widget.items;
  }
  Future<void> _selectDate(BuildContext context, bool isProductionDate, int index) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2015, 8),
    lastDate: DateTime(2101),
  );
  if (picked != null) {
    setState(() {
      if (isProductionDate) {
        widget.prodDate[widget.index]![index] = picked;
      } else {
        widget.expDate[widget.index]![index] = picked;
      }
    });
  }
}


  void updateSerialNumbers(
    BuildContext context,
    ValueChanged<bool> updateReturnBack,
  ) {
    // Check if any serial number is changed to empty
    if (widget.batches.containsKey(widget.index)) {
      for (int i = 0; i < widget.batches[widget.index]!.length; i++) {
        if (widget.batches[widget.index]![i].isEmpty) {
          updateReturnBack(false); // Update the returnBack variable
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please do not change a batch number to empty'),
            ),
          );
          return; // Stop the update process
        }
      }
    }

    // Check if any serial number is changed to a value that already exists in the same map
    for (int i = 0; i < widget.batches[widget.index]!.length; i++) {
      String currentSerial = widget.batches[widget.index]![i];
      for (int j = 0; j < widget.batches[widget.index]!.length; j++) {
        if (i != j && currentSerial == widget.batches[widget.index]![j]) {
          updateReturnBack(false); // Update the returnBack variable
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please do not enter a batch number that already exists',
              ),
            ),
          );
          return; // Stop the update process
        }
      }
    }

    // Calculate the updated quantity after deleting serial number(s)
    int updatedBatchNumber = widget.batches[widget.index]!.length;
      batchController.text = updatedBatchNumber.toString();

    // Update the serial numbers and quantity
    widget.changeQuantityBatch(
      context,
      widget.index,
      int.tryParse(batchController.text) ?? 0,
      widget.batches[widget.index]!.length, // Pass the updated serials count
      widget.batches, // Pass the updated serials map
      widget.quantities,
      widget.prodDate,
      widget.expDate
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Change Batch',
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${itemsorders[widget.index]['itemCode']} ${itemsorders[widget.index]['itemName']}',
                style: TextStyle(
                    fontSize: widget.appNotifier.fontSize.toDouble() - 2),
              ),
              SizedBox(height: 10),
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    if (widget.batches.containsKey(widget.index))
      for (int i = 0; i < widget.batches[widget.index]!.length; i++)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text field for batch number
            TextFormField(
              initialValue: widget.batches[widget.index]![i],
              onChanged: (value) {
                // Update the batch number in the batches map
                setState(() {
                  widget.batches[widget.index]![i] = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Batch ${i + 1}',
                labelStyle: TextStyle(
                  fontSize: widget.appNotifier.fontSize.toDouble() - 2,
                ),
                suffixText: 'Units',
                suffixIcon: IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Delete Batch'),
                          content: Text(
                            'Are you sure you want to delete this Batch?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  // Remove the corresponding batch number from the list
                                  widget.batches[widget.index]!.removeAt(i);
                                });
                                Navigator.pop(context);
                              },
                              child: Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.delete),
                  color: Colors.red,
                ),
              ),
            ),
            // Text field for quantity
            TextFormField(
              initialValue: widget.quantities[widget.index]![i],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantity',
                // Other decoration properties as needed
              ),
              onChanged: (value) {
                setState(() {
                  widget.quantities[widget.index]![i] = value;
                });
              },
            ),
            // Row for production date and expiry date
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: widget.prodDate[widget.index]![i] != null
                        ? DateFormat.yMd().format(widget.prodDate[widget.index]![i])
                        : null,
                    keyboardType: TextInputType.datetime,
                    decoration: InputDecoration(
                      labelText: 'Production Date',
                      // Other decoration properties as needed
                    ),
                    onChanged: (value) {
                      DateTime? parsedDate = DateTime.tryParse(value);
                      if (parsedDate != null) {
                        setState(() {
                          if (!widget.prodDate.containsKey(widget.index)) {
                            widget.prodDate[widget.index] = []; // Initialize list if not exists
                          }
                          widget.prodDate[widget.index]![i] = parsedDate;
                        });
                      }
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _selectDate(context, true, i);
                  },
                  icon: Icon(Icons.calendar_today),
                  
                ),
                SizedBox(width: 8), // Adjust the spacing between the text field and the icon
                Expanded(
                  child: TextFormField(
                    initialValue: widget.expDate[widget.index]![i] != null
                        ? DateFormat.yMd().format(widget.expDate[widget.index]![i])
                        : null,
                    keyboardType: TextInputType.datetime,
                    decoration: InputDecoration(
                      labelText: 'Expiry Date',
                      // Other decoration properties as needed
                    ),
                    onChanged: (value) {
                      DateTime? parsedDate = DateTime.tryParse(value);
                      if (parsedDate != null) {
                        setState(() {
                          if (!widget.expDate.containsKey(widget.index)) {
                            widget.expDate[widget.index] = []; // Initialize list if not exists
                          }
                          widget.expDate[widget.index]![i] = parsedDate;
                        });
                      }
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _selectDate(context, false, i);
                  },
                  icon: Icon(Icons.calendar_today),
                ),
              ],
            ),
          ],
        ),
  ],
),


            ]
        ),
        
      ),
      )
    );
  }
}
