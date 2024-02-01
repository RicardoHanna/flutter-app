import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
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


import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;


class ReportForm extends StatefulWidget {
  final AppNotifier appNotifier;
  final String usercode;

  ReportForm({required this.appNotifier, required this.usercode});

  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  late FirebaseFirestore _firestore;
  late CollectionReference<Map<String, dynamic>> _specialPriceCollection;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    _specialPriceCollection = _firestore.collection('CustomerGroupItemsSpecialPrice');
  }
Future<Uint8List> _generatePdf(PdfPageFormat format) async {
  final pdf = pw.Document();
  final specialPrices = await _specialPriceCollection.get(); // Fetch data from Firestore

  final List<List<String>> tableData = [
    // Header row
    ['Item Code', 'Price', 'Company Code', 'Customer Group Code', 'UOM', 'Base Price', 'Currency', 'Auto', 'Disc', 'Notes'],
    // Data rows
    for (var specialPrice in specialPrices.docs)
      [
        specialPrice['itemCode'] ?? '',
        specialPrice['price']?.toString() ?? '',
        specialPrice['cmpCode'] ?? '',
        specialPrice['custGroupCode'] ?? '',
        specialPrice['uom'] ?? '',
        specialPrice['basePrice']?.toString() ?? '',
        specialPrice['currency'] ?? '',
        specialPrice['auto']?.toString() ?? '',
        specialPrice['disc']?.toString() ?? '',
        specialPrice['notes'] ?? '',
      ],
  ];

  pdf.addPage(
    pw.Page(
      pageFormat: format,
      build: (context) {
        return pw.Table(
          columnWidths: {
            0: pw.FixedColumnWidth(80),
            1: pw.FixedColumnWidth(80),
            2: pw.FixedColumnWidth(80),
            3: pw.FixedColumnWidth(80),
            4: pw.FixedColumnWidth(80),
            5: pw.FixedColumnWidth(80),
            6: pw.FixedColumnWidth(80),
            7: pw.FixedColumnWidth(80),
            8: pw.FixedColumnWidth(80),
            9: pw.FixedColumnWidth(80),
          },
          children: [
            for (var row in tableData)
              pw.TableRow(
                children: [for (var cell in row) pw.Text(cell)],
              ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report'),
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () => _printReport(),
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => _generatePdf(format),
      ),
    );
  }

  Future<void> _printReport() async {
    final Uint8List uint8List = await _generatePdf(PdfPageFormat.a4);

    Printing.layoutPdf(onLayout: (_) => uint8List);
  }
}
