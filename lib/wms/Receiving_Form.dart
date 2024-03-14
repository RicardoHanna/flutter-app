import 'dart:convert';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show ByteData, PlatformException, rootBundle;
import 'package:project/app_notifier.dart';
import 'package:project/wms/NewReceipt_Form.dart';
import 'package:project/wms/Order_Form.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:project/wms/SearchBySupplier_Form.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReceivingScreen extends StatefulWidget {
  final AppNotifier appNotifier;
  final String usercode;

  ReceivingScreen({required this.appNotifier, required this.usercode});
  @override
  _ReceivingScreenState createState() => _ReceivingScreenState();
}

class _ReceivingScreenState extends State<ReceivingScreen> {
  String apiurl = 'http://5.189.188.139:8080/api/';
  TextEditingController itemNameController = TextEditingController();
  bool _isLoading = false;
  String searchQuery = '';
  bool _incompletePurchaseReceipt = false; // Track incomplete purchase receipt

  List<Map<String, String>> orders = [];
  List<Map<String, String>> filteredOrders = [];

  String itemName = '';


@override
void initState() {
  super.initState();
  _fetchOrders(widget.usercode).then((_) {
    setState(() {
      filteredOrders = List.from(orders);
    });
  });

}
@override
void didChangeDependencies() { 
super.didChangeDependencies();
      _checkIncompletePurchaseReceipt();


}
  void _updateFilteredOrders(String query) {
    setState(() {
      searchQuery = query;
      filteredOrders = orders.where((order) {
        final lowerCaseQuery = query.toLowerCase();
        return order['docEntry']!.toLowerCase().contains(lowerCaseQuery) ||
            order['docDelDate']!.toLowerCase().contains(lowerCaseQuery) ||
            order['cmpCode']!.toLowerCase().contains(lowerCaseQuery);
      }).toList();
    });
  }

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

 Future<void> _fetchOrders(String userCode) async {
  setState(() {
    _isLoading = true;
  });

  try {
    // Fetch cmpCode based on userCode
    final cmpCode = await fetchCmpCode(userCode);

    // Proceed to fetch orders if cmpCode is retrieved successfully
    if (cmpCode != null) {
      final response = await http.get(
        Uri.parse('${apiurl}getOpor?cmpCode=$cmpCode'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final DateFormat dateFormat =
            DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
        final DateFormat dateFormatter = DateFormat("yyyy-MM-dd");
        setState(() {
          orders = List<Map<String, String>>.from(data.map((item) => {
                "docEntry": item["docEntry"].toString(),
                "docDelDate":
                    dateFormatter.format(dateFormat.parse(item["docDelDate"])),
                "cmpCode": item["cmpCode"].toString(),
              }));
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch orders');
      }
    } else {
      throw Exception('Failed to fetch cmpCode');
    }
  } catch (error) {
    print('Error fetching orders: $error');
    setState(() {
      _isLoading = false;
    });
  }
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
                     _updateFilteredOrders(value);
                    },
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    print(orders.length);
                Navigator.of(context).push(MaterialPageRoute(
                        builder: (builder) => SearchBySupplierScreen(
                            appNotifier: widget.appNotifier,
                            usercode: widget.usercode)));
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
              onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (builder) => NewReceipt(
                          appNotifier: widget.appNotifier,
                          usercode: widget.usercode,
                        )));
              },
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
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                      fontSize: widget.appNotifier.fontSize.toDouble() - 5),
                ),
                Text(
                  "DeliveryDate",
                  style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                      fontSize: widget.appNotifier.fontSize.toDouble() - 5),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 1.0),
                          child: Card(
                            child: ListTile(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (builder) => OrderForm(
                                        order: filteredOrders[index],
                                        usercode : widget.usercode,
                                        appNotifier: widget.appNotifier)));
                              },
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${filteredOrders[index]["docEntry"]}",
                                    style: TextStyle(
                                      fontSize: widget.appNotifier.fontSize
                                              .toDouble() -
                                          2,
                                    ),
                                  ),
                                  Text(
                                    "${filteredOrders[index]["docDelDate"]}",
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: widget.appNotifier.fontSize
                                              .toDouble() -
                                          5,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                "${filteredOrders[index]["cmpCode"]}",
                                style: TextStyle(
                                  fontSize:
                                      widget.appNotifier.fontSize.toDouble() -
                                          5,
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


 Future<void> _checkIncompletePurchaseReceipt() async {
    // Check if the user has an incomplete purchase receipt
    // Replace this with your own logic to determine if there's an incomplete purchase receipt
    bool hasIncompleteReceipt = await hasIncompletePurchaseReceipt();
    setState(() {
      _incompletePurchaseReceipt = hasIncompleteReceipt;
    });

    // If there's an incomplete purchase receipt, show the dialog
    if (_incompletePurchaseReceipt) {
      _showIncompleteReceiptDialog();
    }
  }


Future<bool> hasIncompletePurchaseReceipt() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // Check if there is incomplete data saved in shared preferences
  print('@@@@@@');
  print(prefs.getBool('incompletePurchaseReceipt'));
  return prefs.getBool('incompletePurchaseReceipt') ?? false;
}

  Future<void> _showIncompleteReceiptDialog() async {
    
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('You have an incomplete purchase receipt'),
          content: Text('Do you want to continue or discard it?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (builder) => OrderForm(
                                        order: filteredOrders.first,
                                        usercode : widget.usercode,
                                        appNotifier: widget.appNotifier)));
              },
              child: Text('Continue'),
            ),
            TextButton(
              onPressed: () {
                // Discard the incomplete purchase receipt
                // Replace this with your own logic
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Discard'),
            ),
            TextButton(
              onPressed: () {
                // Cancel and stay on the current screen
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

    Future<String> scanBarcode() async {
  try {
    ScanResult result = await BarcodeScanner.scan();
    String barcode = result.rawContent.replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '');
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
