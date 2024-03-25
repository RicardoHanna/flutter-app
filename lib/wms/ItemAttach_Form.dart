import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project/app_notifier.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart'; // Import Dio package for making HTTP requests
import 'package:cached_network_image/cached_network_image.dart';

class ItemAttachPage extends StatefulWidget {
  final AppNotifier appNotifier;
  final String usercode;
  final int index;
  final List<Map<dynamic, dynamic>> items;
  final int itemQuantities;
  const ItemAttachPage({
    Key? key,
    required this.appNotifier,
    required this.usercode,
    required this.items,
    required this.index,
    required this.itemQuantities,
  }) : super(key: key);

  @override
  State<ItemAttachPage> createState() => _ItemAttachPageState();
}

class _ItemAttachPageState extends State<ItemAttachPage> {
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

  @override
  void initState() {
    super.initState();
    itemsorders = widget.items;
    fetchData();
    print(int.parse(itemsorders[widget.index]['lineNum']));
  }

  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse('${apiurl}getItemImages'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'userCode': widget.usercode,
          'cmpCode': itemsorders[widget.index]['cmpCode'],
          'docEntry': itemsorders[widget.index]['docEntry'],
          'lineID': itemsorders[widget.index]['lineNum'],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          List<Map<String, dynamic>> imageUrlList =
              List<Map<String, dynamic>>.from(
                  data['imageUrls']); // Get imageUrls array

          // Clear existing imageFilesWithRemarks before adding new ones
          imageFilesWithRemarks.clear();

          // Perform asynchronous operations outside setState()
          for (var item in imageUrlList) {
            String imageUrl = item['imageUrl']; // Access imageUrl key
            String remark = item['remark']; // Access remark key
            int attachID = item['attachID'];
            print('ImageUrl: $imageUrl');
            print('Remark: $remark');
            print('attachID:$attachID');
            Dio dio = Dio();
            dio.options.responseType = ResponseType.bytes;
            Response response = await dio.get(imageUrl);
            Directory tempDir = await getTemporaryDirectory();
            File imageFile = File(
                '${tempDir.path}/image_${DateTime.now().millisecondsSinceEpoch}.png');
            await imageFile.writeAsBytes(response.data);

            // Check if the image already exists in the list
            bool imageExists = imageFilesWithRemarks
                .any((element) => element['imageUrl'] == imageUrl);

            // Only add the image if it doesn't already exist in the list
            if (!imageExists) {
              imageFilesWithRemarks.add({
                'imageFile': imageFile,
                'remark': remark,
                'attachID': attachID
              });
            }
          }

          setState(() {
            _isLoading = false;
          });
        }
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

  Future<void> uploadImages(String userCode, String cmpCode, String docEntry,
      int lineID, List<Map<dynamic, dynamic>> imageFilesWithRemarks) async {
    print('jooopp');
    print(lineID);
    setState(() {
      _isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('${apiurl}uploadImageStatus'));
      request.fields['userCode'] = userCode;
      request.fields['cmpCode'] = cmpCode;
      request.fields['docEntry'] = docEntry;
      request.fields['lineID'] = lineID.toString();

      for (var item in imageFilesWithRemarks) {
        File? imageFile = item['imageFile']; // Add null check
        String? remark = item['remark']; // Add null check
        print('Image file: $imageFile');
        print('Remark: $remark');
        if (imageFile != null && remark != null) {
          // Check if imageFile and remark are not null
          String fileName = imageFile.path.split('/').last;
          request.files.add(await http.MultipartFile.fromPath(
              'imageFile', imageFile.path,
              filename: fileName));
          request.fields['remark'] = remark;
        }
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        print('Images uploaded successfully');
      } else {
        String errorMessage = await response.stream.bytesToString();
        throw Exception('Failed to upload images: $errorMessage');
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
      if (mounted) {
        // Check if the widget is still mounted
        await uploadImages(
          widget.usercode,
          itemsorders[widget.index]['cmpCode'],
          itemsorders[widget.index]['docEntry'],
          int.parse(itemsorders[widget.index]['lineNum'] ?? 1),
          imageFilesWithRemarks,
        );

        if (mounted) {
          // Check again before calling setState()
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Item images inserted successfully'),
            ),
          );
        }
      }
    } catch (error) {
      print('Error inserting and images: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to insert images'),
        ),
      );
    }
  }

  Future<void> addNewPicture(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        imageFilesWithRemarks.add({
          'imageFile': File(pickedFile.path), // Store image File directly
          'remark': '', // Initialize remark as empty string
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
                Navigator.of(context).pop(); // Close the dialog
                confirmDelete(index); // Call the confirmDelete method
              },
            ),
          ],
        );
      },
    );
  }

  void confirmDelete(int index) async {
    int attachID = imageFilesWithRemarks[index]['attachID'];
    try {
      final response = await http.post(
        Uri.parse('${apiurl}deleteImage'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'attachID': attachID}),
      );
      if (response.statusCode == 200) {
        // Image deleted successfully from backend, now remove from the UI
        setState(() {
          imageFilesWithRemarks.removeAt(index);
        });
      } else {
        throw Exception('Failed to delete image');
      }
    } catch (error) {
      print('Error deleting image: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete image'),
        ),
      );
    }
  }

  void updateRemark(int index) async {
    int attachID = imageFilesWithRemarks[index]['attachID'];
    String remark =
        imageFilesWithRemarks[index]['remark']; // Get updated remark
    try {
      final response = await http.post(
        Uri.parse('${apiurl}updateRemark'), // Corrected API endpoint
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {'attachID': attachID, 'remark': remark}), // Send updated remark
      );
      if (response.statusCode == 200) {
        // Remark updated successfully
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Remark updated successfully'),
          ),
        );
      } else {
        throw Exception('Failed to update remark');
      }
    } catch (error) {
      print('Error updating remark: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update remark'),
        ),
      );
    }
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
            Text(
              '${itemsorders[widget.index]['itemCode']} ${itemsorders[widget.index]['itemName']}',
              style: TextStyle(
                fontSize: widget.appNotifier.fontSize.toDouble() - 2,
              ),
            ),
            ElevatedButton(
              onPressed: () => addNewPicture(ImageSource.camera),
              child: Text('New Picture'),
            ),
            ElevatedButton(
              onPressed: () => addNewPicture(ImageSource.gallery),
              child: Text('Choose Picture'),
            ),
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: imageFilesWithRemarks.length,
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double
                                  .infinity, // Set width to match the parent width
                              child: ListTile(
                                title: Container(
                                  width:
                                      100, // Set the desired width for the image
                                  height:
                                      100, // Set the desired height for the image
                                  child: Image.file(
                                    imageFilesWithRemarks[index]['imageFile'],
                                    fit: BoxFit
                                        .cover, // Ensure the image covers the entire container
                                  ),
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
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      16), // Add padding to the text field
                              child: TextField(
                                controller: TextEditingController(
                                    text: imageFilesWithRemarks[index]
                                        ['remark']),
                                onChanged: (value) {
                                  // Update remark in data structure
                                  imageFilesWithRemarks[index]['remark'] =
                                      value;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Remark',
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                          ],
                        );
                      },
                    ),
                  ),
            ElevatedButton(
              onPressed: () {
                if (imageFilesWithRemarks.isNotEmpty &&
                    dropdownValue.isNotEmpty) {
                  // Upload images here
                  insertItemStatusAndImages();
                  // Update remark for each image
                  for (int i = 0; i < imageFilesWithRemarks.length; i++) {
                    updateRemark(i);
                  }
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Please insert at least 1 picture and select status.'),
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
