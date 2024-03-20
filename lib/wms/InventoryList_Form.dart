import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project/app_notifier.dart';
import 'package:project/wms/ItemQuantity_Form.dart';
import 'package:http/http.dart' as http;

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
  String apiurl = 'http://5.189.188.139:8081/api/';
  bool _isLoading = false;
  String searchQuery = '';
  List<Map<dynamic, dynamic>> filteredItems = [];

  List<Map<dynamic, dynamic>> fetchedData = []; // Define fetchedData list

  @override
  void initState() {
    super.initState();
    fetchItems().then((_) {
      setState(() {
        filteredItems = List.from(fetchedData);
      });
    });
  }

  void _updateFilteredItems(String query) {
    setState(() {
      searchQuery = query;
      filteredItems = fetchedData.where((fetcheddata) {
        final lowerCaseQuery = query.toLowerCase();
        return fetcheddata['itemCode']!
                .toLowerCase()
                .contains(lowerCaseQuery) ||
            fetcheddata['barcode']!.toLowerCase().contains(lowerCaseQuery);
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

  Future<void> fetchItems() async {
    setState(() {
      _isLoading = true;
    });
    final cmpCode = await fetchCmpCode(widget.usercode);

    try {
      Map<String, dynamic> requestBody = {
        'cmpCode': cmpCode,
      };

      // Make a POST request with the request body
      final response = await http.post(
        Uri.parse('${apiurl}getItemsInventory'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          fetchedData = List<Map<dynamic, dynamic>>.from(data.map((item) {
            return Map<dynamic, dynamic>.from(item);
          }));
          _isLoading = false;
          _updateFilteredItems(
              searchQuery);
        });
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
        padding: EdgeInsets.all(4.0),
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
                _updateFilteredItems(
                    value); // Update filtered items when search query changes
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
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item =
                            filteredItems[index]; // Get the item at the
                        return Card(
                          child: ListTile(
                            onTap: () {
                              // Navigator.of(context).push(MaterialPageRoute(builder: (builder)=>ItemQuantityScreen(appNotifier: widget.appNotifier, usercode: widget.usercode,items: filteredItems,index: index,changeQuantity: ,)));
                            },
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  item['itemCode'],
                                  style: TextStyle(
                                      fontSize: widget.appNotifier.fontSize
                                              .toDouble() -
                                          2),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      '',
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: widget.appNotifier.fontSize
                                                  .toDouble() -
                                              5),
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Text(
                                      "10.",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: widget.appNotifier.fontSize
                                                  .toDouble() -
                                              5),
                                    ),
                                    SizedBox(
                                      width: 45,
                                    ),
                                    Text(
                                      '',
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: widget.appNotifier.fontSize
                                                  .toDouble() -
                                              5),
                                    ),
                                    SizedBox(
                                      width: 45,
                                    ),
                                    Text(
                                      "12.",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: widget.appNotifier.fontSize
                                                  .toDouble() -
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
                                      fontSize: widget.appNotifier.fontSize
                                              .toDouble() -
                                          5),
                                ),
                                Text(
                                  'BarCode: ' + item['barcode'],
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: widget.appNotifier.fontSize
                                              .toDouble() -
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
