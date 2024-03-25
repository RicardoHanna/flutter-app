import 'package:flutter/material.dart';
import 'package:project/app_notifier.dart';
import 'package:project/wms/Order_Form.dart';
import 'package:project/wms/SupplierNewReceipt_Form.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewReceipt extends StatefulWidget {
  final AppNotifier appNotifier;
  final String usercode;
  const NewReceipt(
      {super.key, required this.appNotifier, required this.usercode});

  @override
  State<NewReceipt> createState() => _NewReceiptState();
}

class _NewReceiptState extends State<NewReceipt> {
  TextEditingController supplierNameController = TextEditingController();
  List<dynamic> suppliers = [];
  List<dynamic> filteredSuppliers = [];
  String baseUrl = "http://5.189.188.139:8081/api/";

  Future<void> getSuppliers() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}getSuppliers'));
      if (response.statusCode == 200) {
        setState(() {
          suppliers = jsonDecode(response.body);
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

  Future<String?> fetchCmpCode(String userCode) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}getDefaultCompCode?userCode=$userCode'),
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

  Future<String> saveNewReceiptNoPO(String cardName, String cardCode) async {
    try {
      final cmpCode = await fetchCmpCode(widget.usercode);

      final response =
          await http.post(Uri.parse('${baseUrl}insertNewReceiptNoPO'),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                'cmpCode': cmpCode,
                'userCode': widget.usercode,
                'date': DateTime.now().toString(),
                'cardCode': cardCode,
                'cardName': cardName,
                
              }));

      if (response.statusCode == 200) {
        print(response.body);
        Map<String, dynamic> js = jsonDecode(response.body);
        print(js);
        return '${js['docNum']}';
      }
    } catch (error) {
      print('Error fetching cmpCode: $error');
      return '';
    }
    return '';
  }

  /*
  Future<bool> updateToDraft() async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}updateReceiptStatusDraft'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'docEntry': widget.docNb}),
      );

      // Check the response status code to determine success or failure
      if (response.statusCode == 200) {
        return true; // Update successful
      } else {
        return false; // Update failed
      }
    } catch (err) {
      print(err);
      return false; // Update failed due to error
    }
  }

  Future<bool> updateToDeleted() async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}updateReceiptStatusDeleted'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'docEntry': widget.docNb}),
      );

      // Check the response status code to determine success or failure
      if (response.statusCode == 200) {
        return true; // Update successful
      } else {
        return false; // Update failed
      }
    } catch (err) {
      print(err);
      return false; // Update failed due to error
    }
  }
*/
  supplierWaiter() async {
    await getSuppliers();
  }

  @override
  void initState() {
    supplierWaiter();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool confirm = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Quit Activity'),
              content: Text(
                  'Do you want to save and continue later, or discard data'),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    /*bool updated = await updateToDraft();
                      print("#############################################");

                    if (updated) {
                      Navigator.of(context)
                          .pop(true); // User cancels going back
                    } else {
                      // Handle update failure
                      print("#############################################");
                    }*/
                  },
                  child: Text('Save and continue later'),
                ),
                TextButton(
                  onPressed: () async {
                    /*bool updated = await updateToDeleted();
                    if (updated) {
                      Navigator.of(context)
                          .pop(true); // User cancels going back
                    } else {
                      // Handle update failure
                    }*/
                  },
                  child: Text('Discard data'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // User confirms going back
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
        return confirm ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Suppliers',
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
              TextField(
                controller: supplierNameController,
                decoration: InputDecoration(
                    labelText: 'Search',
                    labelStyle: TextStyle(
                        fontSize: widget.appNotifier.fontSize.toDouble() - 2)),
                onChanged: (value) {
                  // itemName = value;
                  _updateFilteredOrders(value);
                },
              ),
              SizedBox(
                height: 10,
              ),
              suppliers.length != 0
                  ? Expanded(
                      child: ListView.builder(
                          itemCount: filteredSuppliers.length == 0
                              ? suppliers.length
                              : filteredSuppliers.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 1.0),
                              child: Card(
                                child: ListTile(
                                    onTap: () async {
                                      String docEntry =
                                          await saveNewReceiptNoPO(
                                              filteredSuppliers.length == 0
                                                  ? suppliers[index]["cardCode"]
                                                  : filteredSuppliers[index]
                                                      ["cardCode"],
                                              filteredSuppliers.length == 0
                                                  ? suppliers[index]["cardName"]
                                                  : filteredSuppliers[index]
                                                      ["cardName"]);

                                      String? cmpCode =
                                          await fetchCmpCode(widget.usercode);
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (builder) => OrderForm(
                                                  order: {
                                                    'docEntry': docEntry,
                                                    'cmpCode': cmpCode!
                                                  },
                                                  usercode: widget.usercode,
                                                  appNotifier:
                                                      widget.appNotifier,
                                                  multiorders: [],
                                                  vendor: filteredSuppliers
                                                              .length ==
                                                          0
                                                      ? suppliers[index]
                                                          ["cardCode"]
                                                      : filteredSuppliers[index]
                                                          ["cardCode"],
                                                  isNewReceiptOnPo: false)));
                                    },
                                    title: Text(
                                      "SupplierCode: ${filteredSuppliers.length == 0 ? suppliers[index]["cardCode"] : filteredSuppliers[index]["cardCode"]}",
                                      style: TextStyle(
                                        fontSize: widget.appNotifier.fontSize
                                                .toDouble() -
                                            2,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "SupplierName: ${filteredSuppliers.length == 0 ? suppliers[index]["cardName"] : filteredSuppliers[index]["cardName"]}",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: widget.appNotifier.fontSize
                                                .toDouble() -
                                            5,
                                      ),
                                    )),
                              ),
                            );
                          }),
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    )
            ],
          ),
        ),
      ),
    );
  }

  void _updateFilteredOrders(String query) {
    setState(() {
      print(query);

      filteredSuppliers = suppliers.where((order) {
        final lowerCaseQuery = query.toLowerCase();
        return order['cardCode']!.toLowerCase().contains(lowerCaseQuery) ||
            order['cardName']!.toLowerCase().contains(lowerCaseQuery);
      }).toList();
    });
  }
}
