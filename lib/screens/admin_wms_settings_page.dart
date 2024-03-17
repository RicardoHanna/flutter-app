import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project/app_notifier.dart';
import 'package:http/http.dart' as http;

class WmsSettings extends StatefulWidget {
  final AppNotifier appNotifier;
  final String userCode;

  const WmsSettings(
      {super.key, required this.appNotifier, required this.userCode});

  @override
  State<WmsSettings> createState() => _WmsSettingsState();
}

class _WmsSettingsState extends State<WmsSettings> {
  String baseUrl = "http://5.189.188.139:8081/api/";

  TextEditingController _searchController = TextEditingController();
  List<dynamic> userGroups = [];
  List<dynamic> wmsSetup = [];
  Map<String, dynamic> menuwms = {
    "allowExceedQty": "Allow Exceed Quantity",
    "allowAddItems": "Allow Add Items",
    "allowAdditionalQty": "Allow Additional Quantity"
  };

  Future<void> getUserGroups() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}getUserGroups'));
      if (response.statusCode == 200) {
        setState(() {
          userGroups = jsonDecode(response.body);
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

  Future<void> updateWmsSetup(Map<String, dynamic> data) async {
    print(data);
    try {
      final response = await http.post(Uri.parse('${baseUrl}updateWmsSetup'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({'data': data}));
      if (response.statusCode == 200) {
        
      } else {}
    } catch (e) {}
  }

  Future<void> getWmsSetup() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}getWmsSetup'));
      if (response.statusCode == 200) {
        setState(() {
          wmsSetup = jsonDecode(response.body);
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

  @override
  void initState() {
    userGroupWaiter();
    wmsSetupWaiter();
    super.initState();
  }

  userGroupWaiter() async {
    await getUserGroups();
  }

  wmsSetupWaiter() async {
    await getWmsSetup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wms Settings',
          style: TextStyle(
              fontSize: widget.appNotifier.fontSize.toDouble(),
              color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                style:
                    TextStyle(fontSize: widget.appNotifier.fontSize.toDouble()),
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search By Name",
                  prefixIcon: Icon(
                    Icons.search,
                  ),
                ),
                onChanged: (value) {},
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: userGroups.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      "${userGroups[index]['groupname']}",
                      style: TextStyle(
                          fontSize: widget.appNotifier.fontSize.toDouble()),
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                final keysList = menuwms.keys.toList();
                                final bools = wmsSetup.where((element) =>
                                    element['groupCode'] ==
                                    userGroups[index]['groupcode']);
                                return AlertDialog(
                                  title:
                                      Text("Assign User Group To Wms Action"),
                                  content: Container(
                                    width: double.maxFinite,
                                    height:
                                        200, // You can adjust the height as needed
                                    child: ListView.builder(
                                      itemCount: menuwms.keys.length,
                                      itemBuilder: (context, i) {
                                        return ListTile(
                                          title: Text(menuwms[keysList[i]]),
                                          trailing: Checkbox(
                                            onChanged: (bool? value) {
                                              setState(() {
                                                bools.first[keysList[i]] =
                                                    value == true ? 1 : 0;
                                                print(bools);
                                              });
                                            },
                                            value: bools.first[keysList[i]] == 1
                                                ? true
                                                : false,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                      },
                                      child: Text("Close"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        print(jsonEncode(bools.first));
                                        await updateWmsSetup(bools.first);
                                      },
                                      child: Text("Update"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                      icon: Icon(
                        Icons.assignment_add,
                        color: Colors.blue,
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
