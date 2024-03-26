import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project/app_notifier.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart'; // Import Dio package for making HTTP requests
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

class ItemAttachDocumentPage extends StatefulWidget {
  final AppNotifier appNotifier;
  final String usercode;
  final List<Map<dynamic, dynamic>> items;
  final Map<int,int> itemQuantities;
  final List<Map<String, dynamic>> attachListDocument; // Add this line

  const ItemAttachDocumentPage({
    Key? key,
    required this.appNotifier,
    required this.usercode,
    required this.items,
    required this.itemQuantities,
    required this.attachListDocument,
  }) : super(key: key);

  @override
  State<ItemAttachDocumentPage> createState() => _ItemAttachDocumentPageState();
}

class _ItemAttachDocumentPageState extends State<ItemAttachDocumentPage> {
  TextEditingController notesController = TextEditingController();
  String dropdownValue = 'Good';
  List<Map<dynamic, dynamic>> itemsorders = [];
  String apiurl = 'http://5.189.188.139:8080/api/';
  bool _isLoading = false;
  List<Map<dynamic, dynamic>> fetchedData = [];
  List<File> imageFiles = []; // Changed to List<File>
  String notes = '';
  List<Map<dynamic, dynamic>> imageFilesWithRemarks =
      []; // Store both image File and remark
  List<Map<String, dynamic>> attachListDocument = [];
  String userCode = '';

  @override
  void initState() {
    super.initState();
    itemsorders = widget.items;
    attachListDocument = widget.attachListDocument;
    userCode = widget.usercode;

  }

  Future<void> addNewPicture(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      

      // Check if a status with the same identifier already exists
      

   
        // If no status with the same identifier exists, add a new status
        setState(() {
          attachListDocument.add({
            
            'attachments':
                File(pickedFile.path), // Ensure to set attachments properly
            'remark': notesController.text,
            'userCode': userCode,
          });
        });
     
    }
  }

  void deletePicture(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this image?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () {
                setState(() {
                  attachListDocument.removeAt(index);
                });

                Navigator.of(context).pop(); // Close the dialog

                //confirmDelete(index); // Call the confirmDelete method
              },
            ),
          ],
        );
      },
    );
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
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
       
            ElevatedButton(
              onPressed: () => addNewPicture(ImageSource.camera),
              child: Text('New Picture'),
            ),
            ElevatedButton(
              onPressed: () => addNewPicture(ImageSource.gallery),
              child: Text('Choose Picture'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: attachListDocument.length,
                itemBuilder: (context, index) {
                  // Filter the attachList based on the identifier
                 
                  // Check if the current attachList entry matches the identifier
                  if (
                      attachListDocument[index]['attachments'] != null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          child: ListTile(
                            title: Container(
                              width: 100,
                              height: 100,
                              child: attachListDocument[index]['attachments'] != null
                                  ? Image.file(
                                      attachListDocument[index]['attachments'],
                                      fit: BoxFit.cover,
                                    )
                                  : Container(), // Show an empty container when attachments field is null
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              color: Colors.red,
                              onPressed: () {
                                deletePicture(index);
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: TextEditingController(
                              text: attachListDocument[index]['remark'],
                            ),
                            onChanged: (value) {
                              // Update remark in the data structure
                              attachListDocument[index]['remark'] = value;
                            },
                            decoration: InputDecoration(
                              labelText: 'Remark',
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                    );
                  } else {
                    return Container(); // Return an empty container if the entry does not match the identifier
                  }
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (attachListDocument.isNotEmpty && dropdownValue.isNotEmpty) {
                  // Upload images here
                  // Update remark for each image
                  final attachDocProvider =
                      Provider.of<AppNotifier>(context, listen: false);
                  attachDocProvider.updateAttachListDocument(attachListDocument);

                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Please insert at least 1 picture and insert remark.'),
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
