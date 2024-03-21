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
  TextEditingController quantityController = TextEditingController();
  String dropdownValue = '';
  String dropdownValueUOM='';
  List<Map<dynamic, dynamic>> itemsorders = [];
  String apiurl = 'http://5.189.188.139:8080/api/';
  bool _isLoading = false;
  List<Map<dynamic, dynamic>> fetchedData = []; // Define fetchedData list
  List<Map<dynamic, dynamic>> fetchedDataUOM = []; // Define fetchedData list
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    itemsorders = widget.items;
  }

  // Method to handle adding new picture
// Method to handle adding new picture
Future<void> addNewPicture() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.camera);
  if (pickedFile != null) {
    setState(() {
      imageUrls.add(pickedFile.path);
    });
  }
}

// Method to handle choosing picture
Future<void> choosePicture() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    setState(() {
      imageUrls.add(pickedFile.path);
    });
  }
}


  // Method to handle deleting picture
  void deletePicture(int index) {
    setState(() {
      imageUrls.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Attach',
          style: TextStyle(
            color: Colors.white,
            fontSize: widget.appNotifier.fontSize.toDouble(),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.attach_file,
              color: Colors.white,
            ),
          ),
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
              style: TextStyle(
                fontSize: widget.appNotifier.fontSize.toDouble() - 2,
              ),
            ),
            ElevatedButton(
              onPressed: addNewPicture,
              child: Text('New Picture'),
            ),
            ElevatedButton(
              onPressed: choosePicture,
              child: Text('Choose Picture'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Image.file(File(imageUrls[index])),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        deletePicture(index);
                      },
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
