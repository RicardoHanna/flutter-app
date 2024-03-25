import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:project/app_notifier.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ItemStatus extends StatefulWidget {
  final AppNotifier appNotifier;
  final String usercode;
  final int index;
  final List<Map<dynamic, dynamic>> items;
  final int itemQuantities;
    final List<Map<String, dynamic>> statusList; // Add this line

  const ItemStatus({
    Key? key,
    required this.appNotifier,
    required this.usercode,
    required this.items,
    required this.index,
    required this.itemQuantities,
    required this.statusList
  }) : super(key: key);

  @override
  State<ItemStatus> createState() => _ItemStatusState();
}

class _ItemStatusState extends State<ItemStatus> {
  TextEditingController notesController = TextEditingController();
  String dropdownValue = 'Good';
  String dropdownValueWhs = '';
  List<Map<dynamic, dynamic>> itemsorders = [];
  String apiurl = 'http://5.189.188.139:8080/api/';
  bool _isLoading = false;
  List<Map<dynamic, dynamic>> fetchedData = [];
  List<File> imageFiles = []; // Changed to List<File>
  String notes = '';
  TextEditingController quantityController = TextEditingController();
  List<Map<String, dynamic>> statusList =
      []; // List to store status information
String userCode='';
@override
void initState() {
  super.initState();
  itemsorders = widget.items;
  userCode=widget.usercode;
  fetchWarehouses().then((_) {
    setState(() {
      print('Fetched Data: $fetchedData');
      dropdownValueWhs = fetchedData.isNotEmpty
          ? fetchedData.first['ANY_VALUE(u.whsCode)'].toString()
          : ''; // Set default value to an empty string if fetched data is empty
      print('Dropdown Value: $dropdownValueWhs');
    });
  });
  print('hii');
print(itemsorders[widget.index]['docEntry']??'');
  // Check if statusList is not null
  if (widget.statusList != null && widget.statusList.isNotEmpty && widget.index < widget.statusList.length) {
  if (widget.statusList[widget.index]['docEntry'] == itemsorders[widget.index]['docEntry'] &&
      widget.statusList[widget.index]['lineID'] == itemsorders[widget.index]['lineNum'] &&
      widget.statusList[widget.index]['cmpCode'] == itemsorders[widget.index]['cmpCode']) {
    // If it's not null and the index is within bounds, update the local statusList variable with the values from AppNotifier
    statusList = widget.statusList;
  }
}

  print('hiiii');
  print(widget.usercode);
}


  Future<void> fetchWarehouses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> requestBody = {'userCode': widget.usercode};

      final response = await http.post(
        Uri.parse('${apiurl}getWarehousesUsers'),
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
        });
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

  void editStatus(int index) {
    setState(() {
      dropdownValueWhs = statusList[index]['Warehouse'];
      dropdownValue = statusList[index]['Status'];
      quantityController.text = statusList[index]['Quantity'];
      notesController.text = statusList[index]['Notes'];
    itemsorders[widget.index]['docEntry'] = statusList[index]['docEntry'];
    itemsorders[widget.index]['lineNum'] =  statusList[index]['lineID'];
    itemsorders[widget.index]['cmpCode'] =  statusList[index]['cmpCode'];

    userCode=statusList[index]['userCode'];


      // Remove the status from the list to edit
      //statusList.removeAt(index);
    });
  }

 void deleteStatus(int index) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this status?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                // Remove the status from the list
                statusList.removeAt(index);
              });
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Delete'),
          ),
        ],
      );
    },
  );
}

void addStatus() {
  if (notesController.text.isEmpty || quantityController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please fill in both notes and quantity fields.'),
      ),
    );
  } else {
    // Construct a unique identifier for the status entry
    String identifier = '${itemsorders[widget.index]['docEntry']}_${itemsorders[widget.index]['lineNum']}_${itemsorders[widget.index]['cmpCode']}';

    // Check if a status with the same identifier already exists
    int existingIndex = statusList.indexWhere((status) => status['identifier'] == identifier);

    if (existingIndex != -1) {
      // If a status with the same identifier exists, update it
      setState(() {
        statusList[existingIndex]['Warehouse'] = dropdownValueWhs;
        statusList[existingIndex]['Status'] = dropdownValue;
        statusList[existingIndex]['Quantity'] = quantityController.text;
        statusList[existingIndex]['Notes'] = notesController.text;
        statusList[existingIndex]['userCode'] = userCode;
      });
    } else {
      // If no status with the same identifier exists, add a new status
      setState(() {
        statusList.add({
          'identifier': identifier,
          'Warehouse': dropdownValueWhs,
          'Status': dropdownValue,
          'Quantity': quantityController.text,
          'Notes': notesController.text,
          'docEntry': itemsorders[widget.index]['docEntry'],
          'lineID': itemsorders[widget.index]['lineNum'],
          'cmpCode': itemsorders[widget.index]['cmpCode'],
          'userCode': userCode,
        });
      });
    }

    // Clear the text fields after adding a status
    quantityController.clear();
    notesController.clear();
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Status'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Widgets for user input
            DropdownButton<String>(
              value: dropdownValueWhs ?? '',
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValueWhs = newValue!;
                });
              },
              items: fetchedData.map<DropdownMenuItem<String>>(
                  (Map<dynamic, dynamic> warehouse) {
                return DropdownMenuItem<String>(
                  value: warehouse['ANY_VALUE(u.whsCode)'].toString(),
                  child: Text(warehouse['ANY_VALUE(w.whsName)'].toString()),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: dropdownValue,
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                });
              },
              items: <String>['Good', 'Bad', 'Other']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantity',
              ),
            ),
            TextField(
              controller: notesController,
              onChanged: (value) {
                setState(() {
                  notes = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Enter notes...',
              ),
            ),
            // Button to add status
            ElevatedButton(
              onPressed: addStatus,
              child: Text('Add Status'),
            ),
            // List to display added status
            Expanded(
              child: ListView.builder(
                itemCount: statusList.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text('Warehouse: ${statusList[index]['Warehouse']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: ${statusList[index]['Status']}'),
                        Text('Quantity: ${statusList[index]['Quantity']}'),
                        Text('Notes: ${statusList[index]['Notes']}'),
                      ],
                    ),
                    // Add edit and delete buttons
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          color: Colors.blue,
                          onPressed: () {
                            editStatus(index);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () {
                            deleteStatus(index);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
       ElevatedButton(
        
  onPressed: () {
    final statusProvider = Provider.of<AppNotifier>(context, listen: false);

    print('Status list length: ${widget.statusList.length}');
    print('Requested index: ${widget.index}');
      print(statusList.toList());
        statusProvider.updateStatusList(statusList);
   
    Navigator.pop(context);
  },
  child: Text('Done'),
)


          ],
        ),
      ),
    );
  }
}
