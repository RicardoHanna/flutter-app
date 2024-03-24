import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:project/app_notifier.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ItemStatus extends StatefulWidget {
  final AppNotifier appNotifier;
  final String usercode;
  final int index;
  final List<Map<dynamic, dynamic>> items;
  final int itemQuantities;
  const ItemStatus({
    Key? key,
    required this.appNotifier,
    required this.usercode,
    required this.items,
    required this.index,
    required this.itemQuantities,
  }) : super(key: key);

  @override
  State<ItemStatus> createState() => _ItemStatusState();
}

class _ItemStatusState extends State<ItemStatus> {
  TextEditingController notesController = TextEditingController();
  String dropdownValue = 'Good';
  String dropdownValueWhs='';
  List<Map<dynamic, dynamic>> itemsorders = [];
  String apiurl = 'http://5.189.188.139:8080/api/';
  bool _isLoading = false;
  List<Map<dynamic, dynamic>> fetchedData = [];
  List<File> imageFiles = []; // Changed to List<File>
  String notes = '';

  @override
  void initState() {
    super.initState();
    itemsorders = widget.items;
     fetchWarehouses().then((_) {
      setState(() {
        print('Fetched Data: $fetchedData');
        dropdownValueWhs = fetchedData.isNotEmpty
            ? fetchedData.first['ANY_VALUE(u.whsCode)'].toString()
            : ''; // Set default value to an empty string if fetched data is empty
        print('Dropdown Value: $dropdownValueWhs');
      });
    });
    print(itemsorders[widget.index]['whsCode']);
    //fetchData();
  }
@override
  void dispose() {
    // Cancel any ongoing asynchronous tasks here
    super.dispose();
  }

 Future<void> fetchWarehouses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> requestBody = {'userCode': widget.usercode};

      // Make a POST request with the request body
      final response = await http.post(
        Uri.parse('${apiurl}getWarehousesUsers'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          // Update state with the fetched data
          fetchedData = List<Map<dynamic, dynamic>>.from(data.map((item) {
            // Convert each item in the response to a map
            return Map<dynamic, dynamic>.from(item);
          }));
          _isLoading = false;
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

  Future<void> fetchData() async {
  setState(() {
    _isLoading = true;
  });

  try {
    final response = await http.post(
      Uri.parse('${apiurl}getItemStatusAndImages'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'userCode': widget.usercode,
        'itemCode': itemsorders[widget.index]['itemCode'],
        'whsCode': itemsorders[widget.index]['whsCode'],
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        dropdownValue = data['status']??'Good';
        if(dropdownValue==''){
          dropdownValue='Good';
        }
        notesController.text = data['notes']??'';
        imageFiles = List<File>.from(data['imageUrls']);
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
  print(dropdownValue);
  print(notesController.text);
}


  Future<void> insertItemStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> requestBody = {
        'userCode': widget.usercode,
        'itemCode': itemsorders[widget.index]['itemCode'],
        'whsCode': itemsorders[widget.index]['whsCode'],
        'status': dropdownValue,
        'notes': notes,
      };

      final response = await http.post(
        Uri.parse('${apiurl}setItemStatus'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print('Item status inserted successfully');
      } else {
        throw Exception('Failed to insert item status');
      }
    } catch (error) {
      print('Error inserting item status: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

Future<void> uploadImages(String userCode, String itemCode, String whsCode,
      List<File> imageFiles) async {
    setState(() {
      _isLoading = true;
    });

    try {
        var request = http.MultipartRequest('POST', Uri.parse('${apiurl}uploadImageStatus'));
        request.fields['userCode'] = userCode;
        request.fields['itemCode'] = itemCode;
        request.fields['whsCode'] = whsCode;

        for (var imageFile in imageFiles) {
            String fileName = imageFile.path.split('/').last;
            request.files.add(await http.MultipartFile.fromPath('imageFile', imageFile.path, filename: fileName));
        }

        var response = await request.send();
        if (response.statusCode == 200) {
            print('Image uploaded successfully');
        } else {
            // Get the error message from the response
            String errorMessage = await response.stream.bytesToString();
            throw Exception('Failed to upload image: $errorMessage');
        }

        setState(() {
            _isLoading = false;
        });
    } catch (error) {
        print('Error uploading images: $error');
        setState(() {
            _isLoading = false;
        });
    }
}


Future<void> insertItemStatusAndImages() async {
  try {
    await insertItemStatus();
    if (mounted) { // Check if the widget is still mounted
      await uploadImages(
        widget.usercode,
        itemsorders[widget.index]['itemCode'],
        itemsorders[widget.index]['whsCode'],
        imageFiles,
      );

      if (mounted) { // Check again before calling setState()
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item status and images inserted successfully'),
          ),
        );
      }
    }
  } catch (error) {
    print('Error inserting item status and images: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to insert item status and images'),
      ),
    );
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Status',
          style: TextStyle(
            color: Colors.white,
            fontSize: widget.appNotifier.fontSize.toDouble(),
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${itemsorders[widget.index]['itemCode']} ${itemsorders[widget.index]['itemName']}',
              style: TextStyle(
                fontSize: widget.appNotifier.fontSize.toDouble() - 2,
              ),
            ),
            SizedBox(height: 10,),
            Text(
                  'Warehouse',
                  style: TextStyle(
                      fontSize: widget.appNotifier.fontSize.toDouble() - 2,
                      color: Colors.black54),
                ),
                DropdownButton<String>(
                  value: dropdownValueWhs ??'',
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValueWhs = newValue ??'';
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
                Text(
              'Status',
              style: TextStyle(
                  fontSize: widget.appNotifier.fontSize.toDouble() - 2,
                  color: Colors.black54),
            ),
            DropdownButton<String>(
              value: dropdownValue??'Good',
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
                Text(
              'Notes',
              style: TextStyle(
                  fontSize: widget.appNotifier.fontSize.toDouble() - 2,
                  color: Colors.black54),
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

            ElevatedButton(
              onPressed: () {
                if (imageFiles.isNotEmpty &&
                    dropdownValue.isNotEmpty &&
                    notesController.text.isNotEmpty) {
                  insertItemStatusAndImages();
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Please  select status, and enter notes.'),
                    ),
                  );
                }
              },
              child: Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
