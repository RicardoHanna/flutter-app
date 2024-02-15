import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:project/Forms/Catalog_Order_Submit_Form.dart';
import 'package:project/Forms/Items_Info_Form.dart';
import 'package:project/Forms/Price_Lists_Items_Form.dart';
import 'package:project/app_notifier.dart';
import 'package:project/classes/DataSearchPriceLists.dart';
import 'package:project/hive/hiveuser.dart';
import 'package:project/hive/items_hive.dart';
import 'package:project/hive/pricelist_hive.dart';
import 'package:project/hive/pricelistauthorization_hive.dart';
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
import 'dart:typed_data';



class CatalogForm extends StatefulWidget {
  final AppNotifier appNotifier;
  final String usercode;
final List<Items>items;
  CatalogForm({required this.appNotifier, required this.usercode,required this.items});

  @override
  State<CatalogForm> createState() => _CatalogFormState();
}

class _CatalogFormState extends State<CatalogForm> {
  // Placeholder list of image URLs
  List<String> _imageUrls = [
    "https://firebasestorage.googleapis.com/v0/b/sales-bab47.appspot.com/o/profileImage?alt=media&token=f1d28d89-bfb8-47cd-8066-528b0775d2b7",
    "https://firebasestorage.googleapis.com/v0/b/sales-bab47.appspot.com/o/profileImage?alt=media&token=f0f100e1-ce8d-4662-8e94-64a78f1fba3e",
    "https://via.placeholder.com/300",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catalog'),
      ),
      body: PageView.builder(
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onDoubleTap: () {
              // Handle double tap to expand
              _showExpandedImage(widget.items[index]);
            },
            child: Image.network(
             widget.items[index].picture,
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }
  void _showExpandedImage(Items item) {



  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    item.picture,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Details: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                     
                    ],
                  ),
                  SizedBox(height: 8.0),
                
                  SizedBox(height: 16.0),
             

                ],
              ),
            ),
          );
        },
      );
    },
  );
}



}