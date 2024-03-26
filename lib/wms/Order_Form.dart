import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:printing/printing.dart';
import 'package:project/Forms/Inventory_Form.dart';
import 'package:project/Forms/wms_Form.dart';
import 'package:project/app_notifier.dart';
import 'package:http/http.dart' as http;
import 'package:project/classes/UserPreferences.dart';
import 'package:project/screens/welcome_page.dart';
import 'package:project/wms/AddBatch_Form.dart';
import 'package:project/wms/AddSerialNumber_Form.dart';
import 'package:project/wms/BookingDate_Form.dart';
import 'package:project/wms/ChangeBatchNumber_Form.dart';
import 'package:project/wms/ChangeSerialNumber_Form.dart';
import 'package:project/wms/InventoryList_Form.dart';
import 'package:project/wms/ItemQuantity_Form.dart';
import 'package:project/wms/Receiving_Form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OrderForm extends StatefulWidget {
  final Map<String, String> order;
  final List<dynamic> multiorders;
  final String vendor;
  final AppNotifier appNotifier;
  final String usercode;

  final bool isNewReceiptOnPo;

  const OrderForm(
      {super.key,
      required this.order,
      required this.usercode,
      required this.appNotifier,
      required this.multiorders,
      required this.vendor,
      required this.isNewReceiptOnPo});

  @override
  State<OrderForm> createState() => _OrderFormState();
}

late CollectionReference<Map<String, dynamic>> _specialPriceCollection;

class _OrderFormState extends State<OrderForm> {
  String apiurl = 'http://5.189.188.139:8081/api/';
  UserPreferences userPreferences = UserPreferences();
  TextEditingController draftTitleController = TextEditingController();
  bool _isLoading = false;
  List<Map<dynamic, dynamic>> fetchedData = []; // Define fetchedData list
  List<String> itemCodes = [];
  TextStyle _appTextStyleNormal = TextStyle();
  Map<int, int> itemQuantities =
      {}; // Map to store item quantities, with item index as key
  Map<int, Color> itemColors =
      {}; // Map to store item colors, with item index as key
  Map<int, String> updatedWarehouses = {};
  Map<int, int> countSerial = {};
  Map<int, List<String>> serials = {};
  Map<int, List<String>> batches = {};
  Map<int, int> countBatch = {};
  Map<int, List<String>> quantities = {};
  Map<int, List<DateTime>> prodDate = {};
  Map<int, List<DateTime>> expDate = {};

  //added by elie barbar
  Future<String?> fetchCmpCode(String userCode) async {
    try {
      final response = await http.get(
        Uri.parse('${apiurl}getDefaultCompCode?userCode=$userCode'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return data[0]['cmpCode'].toString();
        }
      }
    } catch (error) {
      print('Error fetching cmpCode: $error');
    }
    return null;
  }

  Future<void> getItemsFromPdn1() async {
    try {
      final cmpCode = await fetchCmpCode(widget.usercode);

      final response = await http.post(Uri.parse('${apiurl}geteItemsOfNewPO'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(
              {'docEntry': widget.order['docEntry'], 'cmpCode': cmpCode}));
      if (response.statusCode == 200) {
        setState(() {
          //items = jsonDecode(response.body);
        });
        print(response.body);
      } else {
        print('Failed to fetch user groups: ${response.statusCode}');
        // Handle error accordingly
      }
    } catch (e) {
      print('Error fetching user groups: $e');
      // Handle error accordingly
    }
  }
  //end by elie barbar

  // Save the state when the user decides to save and continue later
  Future<void> saveState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convert the itemQuantities map to a JSON encodable format
    Map<String, dynamic> encodedItemQuantities = {};
    itemQuantities.forEach((key, value) {
      encodedItemQuantities[key.toString()] = value;
    });

    // Convert the itemColors map to a JSON encodable format
    Map<String, dynamic> encodedItemColors = {};
    itemColors.forEach((key, value) {
      encodedItemColors[key.toString()] = value.value; // Store the color value
    });

    // Save the encoded itemQuantities to shared preferences
    await prefs.setString('itemQuantities', json.encode(encodedItemQuantities));

    // Save the encoded itemColors to shared preferences
    await prefs.setString('itemColors', json.encode(encodedItemColors));
  }

  Future<void> restoreState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the saved item quantities from shared preferences
    String? itemQuantitiesString = prefs.getString('itemQuantities');
    print('4444');
    print(itemQuantitiesString);
    if (itemQuantitiesString != null) {
      // Parse the JSON string to a Map<String, dynamic>
      Map<String, dynamic> decodedItemQuantities =
          json.decode(itemQuantitiesString);

      // Clear the existing item quantities
      itemQuantities.clear();

      // Update the itemQuantities map with the decoded data
      decodedItemQuantities.forEach((key, value) {
        itemQuantities[int.parse(key)] = value;
      });
    } else {
      // Initialize itemQuantities with default values if it's empty
      initializeItemQuantities();
    }

    // Retrieve the saved item colors from shared preferences
    String? itemColorsString = prefs.getString('itemColors');
    if (itemColorsString != null) {
      // Parse the JSON string to a Map<String, dynamic>
      Map<String, dynamic> decodedItemColors = json.decode(itemColorsString);

      // Clear the existing item colors
      itemColors.clear();

      // Update the itemColors map with the decoded data
      decodedItemColors.forEach((key, value) {
        itemColors[int.parse(key)] = Color(value);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchItemCodes();
    loadCheckboxPreferences();
    initializeItemQuantities();
    restoreState();
  }

  @override
  void dispose() {
    saveState();
    super.dispose();
  }

  Future<void> fetchItemCodes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> requestBody = {
        'docEntry': widget.order['docEntry'],
        'cmpCode': widget.order['cmpCode'],
      };
      //start by elie barbar
      List<String> ordersDocEntry = widget.multiorders
          .map((dynamic element) {
            if (element is Map<String, dynamic>) {
              return element['docEntry'] as String?;
            }
            return null;
          })
          .where((value) => value != null)
          .map((e) => e!)
          .toList();

      if (ordersDocEntry.length > 0) {
        requestBody = {
          'docEntry': ordersDocEntry,
          'cmpCode': widget.multiorders[0]['cmpCode'],
        };
      }
      print(requestBody);
      //end by elie barbar

      // Make a POST request with the request body
      final response = await http.post(
        Uri.parse('${apiurl}getpor1'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print(data.length);
        setState(() {
          // Update state with the fetched data
          fetchedData = List<Map<dynamic, dynamic>>.from(data.map((item) {
            // Convert each item in the response to a map
            return Map<dynamic, dynamic>.from(item);
          }));
          _isLoading = false;
        });
        print("#########################");
        print(fetchedData);
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void initializeItemQuantities() {
    for (int i = 0; i < fetchedData.length; i++) {
      itemQuantities[i] = fetchedData[i]['recQty'];
    }
  }

  void changeQuantity(BuildContext context, int index, int newQuantity) {
    // Update the quantity directly
    setState(() {
      itemQuantities[index] = newQuantity;
    });

    // Show the action dialog if the new quantity is 0
    if (newQuantity == 0) {
      _showActionDialog(context, fetchedData[index], index);
    }
  }

  void addQuantity(
      BuildContext context, int index, int? newQuantity, String newWarehouses) {
    // Update the quantity directly
    setState(() {
      itemQuantities[index] = (newQuantity ?? 0) + (itemQuantities[index] ?? 0);
      updatedWarehouses[index] = newWarehouses;
    });

    // Show the action dialog if the new quantity is 0
    if (newQuantity == 0) {
      _showActionDialog(context, fetchedData[index], index);
    }
  }

  void addQuantitySerial(
      BuildContext context,
      int index,
      int? newQuantity,
      String newWarehouses,
      int newcountSerial,
      Map<int, List<String>> serialsComeFrom) {
    // Update the quantity directly
    setState(() {
      itemQuantities[index] = (newQuantity ?? 0) + (itemQuantities[index] ?? 0);
      updatedWarehouses[index] = newWarehouses;
      countSerial[index] = (newcountSerial ?? 0) + (countSerial[index] ?? 0);

      // Merge the serials
      if (serialsComeFrom.containsKey(index)) {
        // If serials already exist for the given index, merge the new list with the existing one
        serials[index] = [
          ...(serials[index] ?? []),
          ...serialsComeFrom[index]!
              .where((serial) => !serials[index]!.contains(serial)),
        ];
      } else {
        // If not, assign the serials directly
        serials[index] = serialsComeFrom[index] ?? [];
      }

      print('Updated serials:');
      print(serials); // Print the updated serials
    });

    // Show the action dialog if the new quantity is 0
    if (newQuantity == 0) {
      _showActionDialog(context, fetchedData[index], index);
    }
  }

  void addBatchSerial(
      BuildContext context,
      int index,
      int? newQuantity,
      String newWarehouses,
      int newcountBatch,
      Map<int, List<String>> batchesComeFrom,
      Map<int, List<String>> quantitiesComeForm,
      Map<int, List<DateTime>> prodDateComeFrom,
      Map<int, List<DateTime>> expDateComeFrom) {
    // Update the quantity directly
    setState(() {
      itemQuantities[index] = (newQuantity ?? 0) + (itemQuantities[index] ?? 0);
      updatedWarehouses[index] = newWarehouses;
      countBatch[index] = (newcountBatch ?? 0) + (countBatch[index] ?? 0);

      // Merge the serials
      if (batchesComeFrom.containsKey(index)) {
        // If serials already exist for the given index, merge the new list with the existing one
        batches[index] = [
          ...(batches[index] ?? []),
          ...batchesComeFrom[index]!
              .where((batch) => !batches[index]!.contains(batch)),
        ];
      } else {
        // If not, assign the serials directly
        serials[index] = batchesComeFrom[index] ?? [];
      }

      // Merge the serials
      if (quantitiesComeForm.containsKey(index)) {
        // If serials already exist for the given index, merge the new list with the existing one
        quantities[index] = [
          ...(quantities[index] ?? []),
          ...quantitiesComeForm[index]!
              .where((quantity) => !quantities[index]!.contains(quantity)),
        ];
      } else {
        // If not, assign the serials directly
        quantities[index] = quantitiesComeForm[index] ?? [];
      }

      // Merge the serials
      if (prodDateComeFrom.containsKey(index)) {
        // If serials already exist for the given index, merge the new list with the existing one
        prodDate[index] = [
          ...(prodDate[index] ?? []),
          ...prodDateComeFrom[index]!
              .where((proddate) => !prodDate[index]!.contains(proddate)),
        ];
      } else {
        // If not, assign the serials directly
        prodDate[index] = prodDateComeFrom[index] ?? [];
      }

      // Merge the serials
      if (expDateComeFrom.containsKey(index)) {
        // If serials already exist for the given index, merge the new list with the existing one
        expDate[index] = [
          ...(expDate[index] ?? []),
          ...expDateComeFrom[index]!
              .where((expdate) => !expDate[index]!.contains(expdate)),
        ];
      } else {
        // If not, assign the serials directly
        expDate[index] = expDateComeFrom[index] ?? [];
      }

      print('Updated batches:');
      print(countBatch);
      print(itemQuantities);
      print(batches); // Print the updated serials
      print(batchesComeFrom);
      print(quantitiesComeForm);
      print(prodDateComeFrom);
    });

    // Show the action dialog if the new quantity is 0
    if (newQuantity == 0) {
      _showActionDialog(context, fetchedData[index], index);
    }
  }

  void changeQuantitySerial(BuildContext context, int index, int? newQuantity,
      int newcountSerial, Map<int, List<String>> serialsComeFrom) {
    // Update the quantity directly
    setState(() {
      countSerial[index] = newQuantity!;

      print('?????????????');
      print(newQuantity);
      print(itemQuantities[index]);
      print(countSerial[index]);
      // Merge the serials
      if (serialsComeFrom.containsKey(index)) {
        // If serials already exist for the given index, merge the new list with the existing one
        serials[index] = [
          ...(serials[index] ?? []),
          ...serialsComeFrom[index]!
              .where((serial) => !serials[index]!.contains(serial)),
        ];
      } else {
        // If not, assign the serials directly
        serials[index] = serialsComeFrom[index] ?? [];
      }

      print('Updated serials:');
      print(serials); // Print the updated serials
    });

    // Show the action dialog if the new quantity is 0
    if (newQuantity == 0) {
      _showActionDialog(context, fetchedData[index], index);
    }
  }

  void changeQuantityBatch(
      BuildContext context,
      int index,
      int? newQuantity,
      int newcountBatch,
      Map<int, List<String>> batchesComeFrom,
      Map<int, List<String>> quantitiesComeForm,
      Map<int, List<DateTime>> prodDateComeFrom,
      Map<int, List<DateTime>> expDateComeFrom) {
    // Update the quantity directly
    setState(() {
      countBatch[index] = newQuantity!;

      print('?????????????');
      print(newQuantity);
      print(itemQuantities[index]);
      print(countBatch[index]);
      // Merge the serials
      if (batchesComeFrom.containsKey(index)) {
        // If serials already exist for the given index, merge the new list with the existing one
        batches[index] = [
          ...(batches[index] ?? []),
          ...batchesComeFrom[index]!
              .where((batch) => !batches[index]!.contains(batch)),
        ];
      } else {
        // If not, assign the serials directly
        batches[index] = batchesComeFrom[index] ?? [];
      }

      if (quantitiesComeForm.containsKey(index)) {
        // If serials already exist for the given index, merge the new list with the existing one
        quantities[index] = [
          ...(quantities[index] ?? []),
          ...quantitiesComeForm[index]!
              .where((quantity) => !quantities[index]!.contains(quantity)),
        ];
      } else {
        // If not, assign the serials directly
        quantities[index] = quantitiesComeForm[index] ?? [];
      }

      if (prodDateComeFrom.containsKey(index)) {
        // If serials already exist for the given index, merge the new list with the existing one
        prodDate[index] = [
          ...(prodDate[index] ?? []),
          ...prodDateComeFrom[index]!
              .where((proddate) => !prodDate[index]!.contains(proddate)),
        ];
      } else {
        // If not, assign the serials directly
        quantities[index] = quantitiesComeForm[index] ?? [];
      }

      if (expDateComeFrom.containsKey(index)) {
        // If serials already exist for the given index, merge the new list with the existing one
        expDate[index] = [
          ...(expDate[index] ?? []),
          ...expDateComeFrom[index]!
              .where((expdate) => !expDate[index]!.contains(expdate)),
        ];
      } else {
        // If not, assign the serials directly
        expDate[index] = expDateComeFrom[index] ?? [];
      }

      print('Updated serials:');
      print(serials); // Print the updated serials
    });

    // Show the action dialog if the new quantity is 0
    if (newQuantity == 0) {
      _showActionDialog(context, fetchedData[index], index);
    }
  }

// Function to get the background color based on quantity
  Color getBackgroundColor(int recQty, int ordQty, int index) {
    if (countSerial[index] == null && countBatch[index] == null) {
      if (recQty == 0) {
        return Colors.transparent;
      } else if (recQty == ordQty) {
        return Colors
            .green.shade100; // If quantity equals order quantity, show green
      } else if (recQty < ordQty) {
        return Colors.yellow
            .shade100; // If quantity is less than order quantity, show yellow
      } else {
        return Colors.red
            .shade100; // If quantity is greater than order quantity, show red
      }
    } else if (countSerial[index] != null) {
      if (countSerial[index] == 0) {
        return Colors.transparent;
      }
      return Colors.blue.shade100;
    } else {
      if (countBatch[index] == 0) {
        return Colors.transparent;
      }
      return Colors.blue.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.multiorders);
    return WillPopScope(
      onWillPop: () async {
        // Check if any itemQuantities are not null (not empty)
        bool anyQuantitiesNotEmpty = itemQuantities.values
            .any((quantity) => quantity != null && quantity > 0);
        if (anyQuantitiesNotEmpty) {
          // Show the dialog if itemQuantities are not empty
          return await _showExitConfirmationDialog(context);
        }
        // Allow navigation if itemQuantities are empty
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.multiorders.length != 0
                ? 'Receipt'
                : widget.order['docEntry']!,
            style: TextStyle(
                color: Colors.white,
                fontSize: widget.appNotifier.fontSize.toDouble()),
          ),
          actions: [
            IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.attachment,
                  color: Colors.white,
                )),
            IconButton(
                onPressed: () async {
                  String barcode = await scanBarcode();
                  if (barcode.isNotEmpty) {
                    // Perform logic to check if the scanned barcode exists in the items
                    // and display the corresponding item details.
                    // You can use a method similar to how you display items in the list.

                    // For example:
                    bool itemFound = false;
                    /*    for (var item in filteredItems) {
    
          if (item.barCode == barcode) {
            itemFound = true;
            // Show item details for the scanned item
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ItemsInfoForm(item: item, appNotifier: widget.appNotifier,),
              ),
            );
            break; // Exit the loop since the item is found
          }
        }*/
                    if (!itemFound) {
                      // Display a message indicating that the scanned item was not found
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Scanned item not found'),
                        ),
                      );
                    }
                  }
                },
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
                "Supplier Number: ${widget.multiorders.length == 0 ? widget.order['docDelDate'] : widget.vendor}",
                style: TextStyle(
                  fontSize: widget.appNotifier.fontSize.toDouble(),
                  color: Colors.black54,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              widget.multiorders.length != 0
                  ? Text(
                      'Purshase Order Number:${widget.multiorders.map((dynamic element) {
                            if (element is Map<String, dynamic>) {
                              return element['docEntry'] as String?;
                            }
                            return null;
                          }).where((value) => value != null).join(',')}',
                      style: TextStyle(
                          fontSize: widget.appNotifier.fontSize.toDouble(),
                          color: Colors.black54),
                    )
                  : Text(
                      '${widget.order['cmpCode']!}',
                      style: TextStyle(
                          fontSize: widget.appNotifier.fontSize.toDouble(),
                          color: Colors.black54),
                    ),
              widget.multiorders.length != 0
                  ? SizedBox(
                      width: 0,
                      height: 0,
                    )
                  : SizedBox(
                      height: 5,
                    ),
              ElevatedButton(
                onPressed: () {
                  if (widget.isNewReceiptOnPo) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InventoryList(
                          appNotifier: widget.appNotifier,
                          usercode: widget.usercode,
                          docEntry: '',
                        ),
                      ),
                    );
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (builder) => InventoryList(
                              appNotifier: widget.appNotifier,
                              usercode: widget.usercode,
                              docEntry: '',
                            )));
                  }
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
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                        fontSize: widget.appNotifier.fontSize.toDouble() - 5),
                  ),
                  Text(
                    "Quantity",
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                        fontSize: widget.appNotifier.fontSize.toDouble() - 5),
                  )
                ],
              ),
              SizedBox(
                height: 8,
              ),
              _isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: fetchedData.length,
                        itemBuilder: (context, index) {
                          final itemCode = fetchedData[index];
                          return GestureDetector(
                            onTap: () {
                              // Show dialog when card is tapped
                              _showActionDialog(context, itemCode, index);
                              print(index);
                              print(fetchedData[index]);
                            },
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: Card(
                                child: ListTile(
                                  tileColor: getBackgroundColor(
                                      itemQuantities[index] ??
                                          itemCode['reqQty'] ??
                                          0,
                                      itemCode['ordQty'],
                                      index), // Set background color here
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        itemCode['itemCode'] ?? '',
                                        style: TextStyle(
                                            fontSize: widget
                                                    .appNotifier.fontSize
                                                    .toDouble() -
                                                2),
                                      ),
                                      if (countSerial[index] != null)
                                        Text(
                                          "${countSerial[index]} Units", // Use itemQuantities[index] here
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: widget
                                                      .appNotifier.fontSize
                                                      .toDouble() -
                                                  5),
                                        )
                                      else if (itemQuantities[index] != null)
                                        Text(
                                          "${itemQuantities[index]} Units", // Use itemQuantities[index] here
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: widget
                                                      .appNotifier.fontSize
                                                      .toDouble() -
                                                  5),
                                        )
                                      else
                                        Text(
                                          "${itemQuantities[index] ?? itemCode['recQty'] ?? 0} / ${itemCode['ordQty']} Units", // Use itemQuantities[index] here
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: widget
                                                      .appNotifier.fontSize
                                                      .toDouble() -
                                                  5),
                                        ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 5),
                                      Text(
                                        "ItemName: ${itemCode['itemName']}",
                                        style: TextStyle(
                                            fontSize: widget
                                                    .appNotifier.fontSize
                                                    .toDouble() -
                                                5),
                                      ),
                                      Text(
                                        "Warehouse:  ${updatedWarehouses[index] ?? itemCode['whsName']}",
                                        style: TextStyle(
                                          fontSize: widget.appNotifier.fontSize
                                                  .toDouble() -
                                              5,
                                        ),
                                      ),
                                      widget.multiorders.length > 0
                                          ? Text(
                                              'Doc Entry: ${itemCode['docEntry']}')
                                          : SizedBox(),
                                      if (countSerial[index] != null)
                                        Text(
                                          "Contains:  ${countSerial[index]} Serial Numbers",
                                          style: TextStyle(
                                            fontSize: widget
                                                    .appNotifier.fontSize
                                                    .toDouble() -
                                                5,
                                          ),
                                        )
                                      else if (countBatch[index] != null)
                                        Text(
                                          "Batches:  ${countBatch[index]}",
                                          style: TextStyle(
                                            fontSize: widget
                                                    .appNotifier.fontSize
                                                    .toDouble() -
                                                5,
                                          ),
                                        )
                                      else
                                        Container(),
                                      buildTrailingWidget(fetchedData, index),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              ElevatedButton(
                onPressed: () {
                  print('llll');
                  print(itemQuantities.entries);

                  if (itemQuantities.entries
                      .every((entry) => entry.value == 0)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Select at least row'),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingDateScreen(
                          appNotifier: widget.appNotifier,
                          usercode: widget.usercode,
                        ),
                      ),
                    );
                  }
                },
                child: Text(
                  "Next",
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
            ],
          ),
        ),
        floatingActionButton: Align(
          alignment: Directionality.of(context) == TextDirection.rtl
              ? Alignment.bottomRight
              : Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.only(
              right:
                  Directionality.of(context) == TextDirection.rtl ? 23.0 : 0.0,
              left:
                  Directionality.of(context) == TextDirection.ltr ? 23.0 : 0.0,
            ),
            // child: _getFAB(),
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Quit Activity'),
              content: Text(
                  'Do you want to save and continue later, or discard data?',
                  style: TextStyle(
                      fontSize: widget.appNotifier.fontSize.toDouble() - 1)),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    print(widget.order);
                    // Navigator.of(context).pop(true);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('DraftName'),
                          content: TextField(
                            controller: draftTitleController,
                            decoration: InputDecoration(
                              labelText: 'Draft Title',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                if (widget.multiorders.length == 0) {
                                  await updateDocToDraft(
                                      widget.order['newDocEntry']!);

                                  for (var i = 0; i < fetchedData.length; i++) {
                                    await updateItemsStatusToDraft(
                                        '${fetchedData[i]['lineNum']}',
                                        widget.order['newDocEntry']!,'${itemQuantities[i]}');
                                  }
                                } else {
                                  for (var o in widget.multiorders) {
                                    await updateDocToDraft(o['newDocEntry']!);

                                    for (var i = 0;
                                        i < fetchedData.length;
                                        i++) {
                                      await updateItemsStatusToDraft(
                                          '${fetchedData[i]['lineNum']}',
                                          o['newDocEntry']!,
                                          '${itemQuantities[i]}');
                                    }
                                  }
                                }
                                Navigator.of(context).pop();
                                Navigator.of(context)
                                    .pop(); 
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();

                                    // Close the AlertDialog
                              },
                              child: Text('Submit'),
                            ),
                          ],
                        );
                      },
                    );
                    /*
                    await saveState();
                    await saveIncompletePurchaseReceipt();
                    // Navigate back to the Welcome screen
                    Navigator.of(context).pop(true);
                    Navigator.of(context).pop(true);
                    Navigator.of(context).pop(true);*/
                  },
                  child: Text('Save and continue later',
                      style: TextStyle(
                          fontSize:
                              widget.appNotifier.fontSize.toDouble() - 2)),
                ),
                TextButton(
                  onPressed: () async {
                    if (widget.multiorders.length == 0) {
                      await updateDocToDeleted(widget.order['newDocEntry']!);
                      for (var i = 0; i < fetchedData.length; i++) {
                                    await updateItemsStatusToDeleted(
                                        '${fetchedData[i]['lineNum']}',
                                        widget.order['newDocEntry']!);
                                  }
                    } else {
                      for (var o in widget.multiorders) {
                        await updateDocToDeleted(o['newDocEntry']!);
                        for (var i = 0;
                                        i < fetchedData.length;
                                        i++) {
                                      await updateItemsStatusToDeleted(
                                          '${fetchedData[i]['lineNum']}',
                                          o['newDocEntry']!);
                                    }
                      }
                    }

                    Navigator.of(context).pop(true);
                    Navigator.of(context).pop(true);
                    Navigator.of(context).pop(true);
                    Navigator.of(context).pop(true);

                    print(widget.order['docEntry']);
                    print(fetchedData);
                    print(itemQuantities);

                    /*
                    initializeItemQuantities(); // Reset item quantities
                    setState(() {
                      itemColors.clear(); // Clear item colors
                    });
                    await discardIncompletePurchaseReceipt();
                    
                    */
                  },
                  child: Text('Discard data',
                      style: TextStyle(
                          fontSize:
                              widget.appNotifier.fontSize.toDouble() - 2)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Stay on the current screen
                  },
                  child: Text('Cancel',
                      style: TextStyle(
                          fontSize:
                              widget.appNotifier.fontSize.toDouble() - 2)),
                ),
              ],
            );
          },
        ) ??
        false; // Ensure a default value is returned if showDialog returns null
  }

  Future<void> updateDocToDraft(String docEntry) async {
    try {
      final response = await http.post(
          Uri.parse('${apiurl}updateReceiptStatusDraft'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(
              {'docEntry': docEntry, 'title': draftTitleController.text}));
    } catch (error) {
      print("$error");
    }
  }

  Future<void> updateDocToDeleted(String docEntry) async {
    try {
      final response = await http.post(
          Uri.parse('${apiurl}updateReceiptStatusDeleted'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({'docEntry': docEntry}));
    } catch (error) {
      print("$error");
    }
  }

  Future<void> updateItemsStatusToDraft(
      String lineNum, String docEntry, String qty) async {
    try {
      final response = await http.post(Uri.parse('${apiurl}updateItemToDraft'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(
              {'docEntry': docEntry, 'lineNum': lineNum, 'qty': qty}));
    } catch (error) {}
  }

  Future<void> updateItemsStatusToDeleted(
      String lineNum, String docEntry) async {
    try {
      final response = await http.post(Uri.parse('${apiurl}updateItemToDeleted'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(
              {'docEntry': docEntry, 'lineNum': lineNum}));
    } catch (error) {}
  }

  Future<void> _showActionDialog(
      BuildContext context, Map<dynamic, dynamic> itemCode, int index) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        // Check if itemCode['manageBy'] is 'Serial'
        if (itemCode['manageBy'] == 'Serial') {
          // Return the dialog with options related to serial management
          return AlertDialog(
            title: Text('Choose an action'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionItem('Add Serial', () {
                  dynamic remainingQty =
                      (itemCode['ordQty'] ?? 0) - (itemQuantities[index] ?? 0);
                  print(remainingQty);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddSerialNumber(
                        appNotifier: widget.appNotifier,
                        usercode: widget.usercode,
                        items: fetchedData,
                        index: index,
                        addQuantitySerial: addQuantitySerial,
                        itemQuantities: remainingQty ?? 0,
                        serials: serials,
                      ),
                    ),
                  );
                }),
                _buildActionItem('Change Serial', () {
                  Navigator.pop(context);
                  dynamic remainingQty =
                      (itemCode['ordQty'] ?? 0) - (itemQuantities[index] ?? 0);
                  print(remainingQty);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeSerialNumber(
                        appNotifier: widget.appNotifier,
                        usercode: widget.usercode,
                        items: fetchedData,
                        index: index,
                        changeQuantitySerial: changeQuantitySerial,
                        itemQuantities: remainingQty ?? 0,
                        serials: serials,
                      ),
                    ),
                  );
                  // Handle Change Serial action
                }),
                _buildActionItem('Print Label', () {
                  Navigator.pop(context);
                  print('%%%%');
                  print(itemCode['itemCode']);
                  _printLabel(context, itemCode, index, itemQuantities[index]!);
                }),
                _buildActionItem('Delete', () {
                  _showDeleteDialog(index);
                }),
                // Other options related to serial management
              ],
            ),
          );
        } else if (itemCode['manageBy'] == 'Batch') {
          // Return the dialog with options related to serial management
          return AlertDialog(
            title: Text('Choose an action'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionItem('Add Batch', () {
                  dynamic remainingQty =
                      (itemCode['ordQty'] ?? 0) - (itemQuantities[index] ?? 0);
                  print(remainingQty);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddBatch(
                          appNotifier: widget.appNotifier,
                          usercode: widget.usercode,
                          items: fetchedData,
                          index: index,
                          addBatchSerial: addBatchSerial,
                          itemQuantities: remainingQty ?? 0,
                          batches: batches,
                          quantities: quantities,
                          prodDate: prodDate,
                          expDate: expDate),
                    ),
                  );
                }),
                _buildActionItem('Change Batch', () {
                  Navigator.pop(context);
                  dynamic remainingQty =
                      (itemCode['ordQty'] ?? 0) - (itemQuantities[index] ?? 0);
                  print(remainingQty);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeBatchNumber(
                        appNotifier: widget.appNotifier,
                        usercode: widget.usercode,
                        items: fetchedData,
                        index: index,
                        changeQuantityBatch: changeQuantityBatch,
                        itemQuantities: remainingQty ?? 0,
                        batches: batches,
                        quantities: quantities,
                        prodDate: prodDate,
                        expDate: expDate,
                      ),
                    ),
                  );
                  // Handle Change Serial action
                }),
                _buildActionItem('Print Label', () {
                  Navigator.pop(context);
                  print('%%%%');
                  print(itemCode['itemCode']);
                  _printLabel(context, itemCode, index, itemQuantities[index]!);
                }),
                _buildActionItem('Delete', () {
                  _showDeleteDialog(index);
                }),
                // Other options related to serial management
              ],
            ),
          );
        } else {
          // Return the dialog with options not related to serial management
          return SingleChildScrollView(
            child: AlertDialog(
              title: Text('Choose an action'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionItem('Add Quantity', () {
                    dynamic remainingQty = (itemCode['ordQty'] ?? 0) -
                        (itemQuantities[index] ?? 0);
                    print(remainingQty);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemQuantityScreen(
                          appNotifier: widget.appNotifier,
                          usercode: widget.usercode,
                          items: fetchedData,
                          index: index,
                          addQuantity: addQuantity,
                          itemQuantities: remainingQty ?? 0,
                        ),
                      ),
                    );
                  }),
                  _buildActionItem('Change Quantity', () {
                    Navigator.pop(context);
                    _showChangeQuantityDialog(
                        context, itemCode, index, itemQuantities[index]!);
                    // Handle Change Serial action
                  }),
                  _buildActionItem('Print Label', () {
                    Navigator.pop(context);
                    print('%%%%');
                    print(itemCode['itemCode']);
                    _printLabel(
                        context, itemCode, index, itemQuantities[index]!);
                  }),
                  _buildActionItem('Delete', () {
                    // Handle Delete action
                  }),
                  // Other options related to serial management
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _printLabel1(String itemCode, String barcode, int index) async {
    // Create PDF document
    final Uint8List pdfBytes = await _generatePdf(itemCode, barcode);

    // Define custom page size with width and height ratio
    final PdfPageFormat format =
        PdfPageFormat(200 + 60, 50 + 60); // Adjust as needed

    // Display PDF preview
    await Printing.layoutPdf(onLayout: (_) => pdfBytes, format: format);
  }

  Future<Uint8List> _generatePdf(String itemCode, String barcode) async {
    final pdf = pw.Document();

    // Add content to the PDF document
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat(100, 80), // Adjust as needed
      build: (pw.Context context) {
        return pw.Stack(
          children: [
            // Insert BarcodeWidget with QR code at the center
            pw.Center(
              child: pw.BarcodeWidget(
                barcode: pw.Barcode.code128(),
                data: barcode,
                width: 90,
                height: 30,
              ),
            ),
            // Insert item code at the top left
            pw.Positioned(
              child:
                  pw.Text('Code : $itemCode', style: pw.TextStyle(fontSize: 5)),
              top: 10.0, // Adjust as needed
              left: 10.0, // Adjust as needed
            ),
          ],
        );
      },
    ));

    // Save the PDF document as bytes
    return pdf.save();
  }

  Future<void> _printLabel(BuildContext context, Map<dynamic, dynamic> itemCode,
      int index, int existingQuantity) async {
    TextEditingController quantityController =
        TextEditingController(text: existingQuantity.toString());

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Label'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () async {
                  print('@@@@@@@@@');
                  print(itemCode['itemCode']);
                  _printLabel1(
                      itemCode['itemCode'], itemCode['barcode'], index);
                },
                child: Text(
                  'Sample 1',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Handle sample 2 selection
                  // For example:
                  // _handleLabelSelection(context, 'Sample 2');
                },
                child:
                    Text('Sample 2', style: TextStyle(color: Colors.black54)),
              ),
              TextButton(
                onPressed: () {
                  // Handle sample 3 selection
                  // For example:
                  // _handleLabelSelection(context, 'Sample 3');
                },
                child:
                    Text('Sample 3', style: TextStyle(color: Colors.black54)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String quantityText = quantityController.text;
                int newQuantity = int.tryParse(quantityText) ?? 0;
                changeQuantity(context, index, newQuantity);
                Navigator.pop(context); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog without deleting
                Navigator.of(context)
                    .pop(); // Close the dialog without deleting
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                print('##');
                print(index);
                print(fetchedData[index]);
                setState(() {
                  fetchedData.removeAt(index); // Remove the item from the list
                });
                Navigator.of(context).pop(); // Close the dialog after deleting
                Navigator.of(context).pop(); // Close the dialog after deleting
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showChangeQuantityDialog(BuildContext context,
      Map<dynamic, dynamic> itemCode, int index, int existingQuantity) async {
    TextEditingController quantityController =
        TextEditingController(text: existingQuantity.toString());

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter quantity'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Qty',
                  suffix: Text('Units'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String quantityText = quantityController.text;
                int newQuantity = int.tryParse(quantityText) ?? 0;
                changeQuantity(context, index, newQuantity);
                Navigator.pop(context); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Helper function to build each action item in the dialog
  Widget _buildActionItem(String title, Function() onTap) {
    return ListTile(
      title: Text(title),
      onTap: onTap,
    );
  }

  List<Widget> _buildSeparatedWidgets(List<Widget> widgets) {
    List<Widget> separatedWidgets = [];

    for (int i = 0; i < widgets.length; i++) {
      separatedWidgets.add(widgets[i]);

      if (i < widgets.length - 1) {
        // Add SizedBox with vertical space between items, not after the last item
        separatedWidgets.add(SizedBox(height: 2));
      }
    }

    return separatedWidgets;
  }

  Future<void> _showSettingsDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String?> selectedOptions = [
      userPreferences.showBarcode ? 'barcode' : null,
      userPreferences.showWarehouse ? 'warehouse' : null,
      userPreferences.showOutQuantity ? 'outquantity' : null,
    ];

    // ignore: use_build_context_synchronously
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.choosefields,
                style: _appTextStyleNormal,
              ),
              content: Column(
                children: <Widget>[
                  for (int i = 0; i < 3; i++)
                    _buildDropdown(
                      AppLocalizations.of(context)!.field + '${i + 1}',
                      selectedOptions[i],
                      (String? newValue) {
                        setState(() {
                          selectedOptions[i] = newValue;
                        });
                      },
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    AppLocalizations.of(context)!.save,
                    style: _appTextStyleNormal,
                  ),
                  onPressed: () async {
                    userPreferences.showBarcode =
                        selectedOptions.contains('barcode');
                    userPreferences.showWarehouse =
                        selectedOptions.contains('warehouse');
                    userPreferences.showOutQuantity =
                        selectedOptions.contains('outquantity');

                    // Save dropdown preferences to shared preferences
                    await prefs.setBool(
                        'showBarcode', userPreferences.showBarcode);
                    await prefs.setBool(
                        'showWarehouse', userPreferences.showWarehouse);
                    await prefs.setBool(
                        'showOutQuantity', userPreferences.showOutQuantity);

                    fetchItemCodes();
                    // _applySorting(); // Call the method to update items
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> saveIncompletePurchaseReceipt() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Save the incomplete purchase receipt flag to shared preferences
    await prefs.setBool('incompletePurchaseReceipt', true);
  }

  Future<void> discardIncompletePurchaseReceipt() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Save the incomplete purchase receipt flag to shared preferences
    await prefs.setBool('incompletePurchaseReceipt', false);
  }

  Future<bool> hasIncompletePurchaseReceipt() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Check if there is incomplete data saved in shared preferences
    return prefs.getBool('incompletePurchaseReceipt') ?? false;
  }

  Future<void> loadCheckboxPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      userPreferences.showBarcode = prefs.getBool('showBarcode') ?? false;
      userPreferences.showWarehouse = prefs.getBool('showWarehouse') ?? false;
      userPreferences.showOutQuantity =
          prefs.getBool('showOutQuantity') ?? false;
    });
  }

  Widget _getFAB() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22),
      backgroundColor: Color(0xFF2196F3),
      visible: true,
      curve: Curves.bounceIn,
      children: [
        // Sub button 2
        SpeedDialChild(
          child: Icon(Icons.add),
          backgroundColor: Color(0xFF2196F3),
          onTap: () {
            _showSettingsDialog();
          },
          label: 'Add Fields Items',
          labelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 16.0,
          ),
          labelBackgroundColor: Color(0xFF2196F3),
        ),
      ],
    );
  }

  Widget buildTrailingWidget(
      List<Map<dynamic, dynamic>> fetchedData, int index) {
    TextStyle _appTextStylewidgets =
        TextStyle(fontSize: widget.appNotifier.fontSize.toDouble() - 5);
    List<Widget> widgets = [];
    List<String> selectedFields =
        userPreferences.getSelectedFieldsItemReceive();

    for (var field in selectedFields) {
      switch (field) {
        case 'barcode':
          widgets.add(Text(
            'Barcode: ' + fetchedData[index]['barcode'] ?? '',
            style: _appTextStylewidgets,
          ));
          break;
        case 'warehouse':
          widgets.add(
            Text(
              'Warehouse: ' + fetchedData[index]['whsCode'] ?? '',
              style: _appTextStylewidgets,
            ),
          );
          break;

        case 'outquantity':
          widgets.add(Text(
            'OutBound Quantity: ' + fetchedData[index]['invQty'].toString() ??
                '',
            style: _appTextStylewidgets,
          ));
          break;
      }
    }

    return Container(
      padding: EdgeInsets.all(1.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildSeparatedWidgets(widgets),
      ),
    );
  }

  Widget _buildDropdown(
      String label, String? selectedValue, Function(String?) onChanged) {
    return Row(
      children: [
        Text(label),
        SizedBox(width: 10),
        DropdownButton<String>(
          value: selectedValue,
          onChanged: onChanged,
          items: [
            DropdownMenuItem<String>(
              value: 'barcode',
              child: Text(AppLocalizations.of(context)!.barcode),
            ),
            DropdownMenuItem<String>(
              value: 'warehouse',
              child: Text(AppLocalizations.of(context)!.warehouse),
            ),
            DropdownMenuItem<String>(
              value: 'outquantity',
              child: Text('Outbound'),
            ),

            DropdownMenuItem<String>(
              value: '',
              child: Text(''),
            ),
            // Add other options as needed
          ],
        ),
      ],
    );
  }

  Future<String> scanBarcode() async {
    try {
      ScanResult result = await BarcodeScanner.scan();
      String barcode =
          result.rawContent.replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '');
      // This regular expression removes control characters from the string.
      print(barcode);
      return barcode;
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        // Handle camera permission denied
        print('Camera permission denied');
      } else {
        // Handle other exceptions
        print('Error: $e');
      }
      return '';
    }
  }
}
