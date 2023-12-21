import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:project/Forms/Items_Info_Form.dart';
import 'package:project/Forms/Price_Lists_Items_Form.dart';
import 'package:project/app_notifier.dart';
import 'package:project/hive/hiveuser.dart';
import 'package:project/hive/itemattach_hive.dart';
import 'package:project/hive/items_hive.dart';
import 'package:project/hive/pricelist_hive.dart';
import 'package:project/hive/translations_hive.dart';
import 'package:project/screens/login_page.dart';
import 'package:project/utils.dart';
import 'package:project/screens/admin_users_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/resources/add_data.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project/hive/usergroup_hive.dart';
import 'package:project/Synchronize/DataSynchronizer.dart';

class AttachementsItemForm extends StatefulWidget {
  final String itemCode;

  AttachementsItemForm({required this.itemCode});

  @override
  _AttachementsItemFormState createState() => _AttachementsItemFormState();
}

class _AttachementsItemFormState extends State<AttachementsItemForm> {
  @override
  void initState() {
    super.initState();
    // Insert sample data on initialization
    //insertSampleData();
  }
  


  Future<Uint8List> _getLocalImageBytes(String localPath) async {
  // Use the file package to read image bytes from the local file path
  // Example: https://pub.dev/packages/file
  File file = File(localPath);
  return await file.readAsBytes();
}

  Future<void> insertSampleData() async {
    var itemAttachBox = await Hive.openBox<ItemAttach>('itemattach');
    // Insert sample data
    var attach1 = ItemAttach('001', 'images', 'https://firebasestorage.googleapis.com/v0/b/sales-bab47.appspot.com/o/profileImage?alt=media&token=c74746f0-cb07-422b-8428-fc236d0e1339', 'Note1');
    var attach2 = ItemAttach('002', 'pdf', 'path_to_pdf.pdf', 'Note2');
    var attach3= ItemAttach('001', 'images', 'https://firebasestorage.googleapis.com/v0/b/sales-bab47.appspot.com/o/profileImage?alt=media&token=c74746f0-cb07-422b-8428-fc236d0e1339', 'Note2');

    await itemAttachBox.put(attach1.itemCode, attach1);
    await itemAttachBox.put(attach2.itemCode, attach2);
  // await itemAttachBox.add(attach3);

  }

  Future<List<ItemAttach>> _getItemAttachments() async {
    var itemAttachBox = await Hive.openBox<ItemAttach>('itemattach');
    var attachments = itemAttachBox.values.where((attach) => attach.itemCode == widget.itemCode).toList();
    return attachments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attachments for Item ${widget.itemCode}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<ItemAttach>>(
          future: _getItemAttachments(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('No attachments found for Item ${widget.itemCode}');
            } else {
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var attachment = snapshot.data![index];

                  // Check if the attachment type is 'images' and it has a valid URL
                  if (attachment.attachmentType == 'Image' && attachment.attachmentPath.isNotEmpty) {
                    return Card(
                      child: Column(
                        children: [
                          Image.network(
                            attachment.attachmentPath,
                            height: 100,
                            width: 300,
                            
                          ),
                          ListTile(
                            title: Text('Type: ${attachment.attachmentType}'),
                            subtitle: Text('Note: ${attachment.note}'),
                            trailing: Icon(Icons.attach_file),
                          ),
                        ],
                      ),
                    );
                  }

                  // For other types or if the URL is not valid, display a placeholder
                  return Card(
                    child: ListTile(
                      title: Text('Type: ${attachment.attachmentType}'),
                      subtitle: Text('Note: ${attachment.note}'),
                      trailing: Icon(Icons.attach_file),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}