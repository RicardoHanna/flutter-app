import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show ByteData, rootBundle;

class ItemGroup {
  final String groupName;
  final int minExpiryMonths; // Minimum number of months for expiry dates

  ItemGroup({
    required this.groupName,
    required this.minExpiryMonths,
  });
}

class BatchInfo {
  final String batchNumber;
  final int orderedQuantity;
  final int receivedQuantity;
  final String quality;
  final String supplierCatalogNumber;
  final String project;
  final String batchStatus;
  final String productionDate;
  final String expiryDate; // Added expiry date
  final String uom;
  final int qtyPerUom;
  final int inventoryQuantity;
  Uint8List? itemPhoto;

  BatchInfo({
    required this.batchNumber,
    required this.orderedQuantity,
    required this.receivedQuantity,
    required this.quality,
    required this.supplierCatalogNumber,
    required this.project,
    required this.batchStatus,
    required this.productionDate,
    required this.expiryDate,
    required this.uom,
    required this.qtyPerUom,
    required this.inventoryQuantity,
    this.itemPhoto,
  });
}

class ReceivingScreen extends StatefulWidget {
  @override
  _ReceivingScreenState createState() => _ReceivingScreenState();
}

class _ReceivingScreenState extends State<ReceivingScreen> {
  TextEditingController itemNameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController supplierController = TextEditingController();
  TextEditingController batchNumberController = TextEditingController();
  TextEditingController warehouseController = TextEditingController();
  TextEditingController itemQualityController = TextEditingController();
  TextEditingController itemStatusController = TextEditingController();
  TextEditingController itemCommentsController = TextEditingController();
  TextEditingController supplierCatalogNumberController = TextEditingController();
  TextEditingController projectController = TextEditingController();
  TextEditingController batchStatusController = TextEditingController();
  TextEditingController productionDateController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController(); // Controller for expiry date
  TextEditingController uomController = TextEditingController(); // Unit of Measurement
  TextEditingController qtyPerUomController = TextEditingController(); // Quantity per UOM

  String itemName = '';
  int quantity = 0;
  String location = '';
  String supplier = '';
  String batchNumber = '';
  String warehouse = '';
  String itemQuality = '';
  String itemStatus = '';
  String itemComments = '';
  String supplierCatalogNumber = '';
  String project = '';
  String batchStatus = '';
  String productionDate = '';
  String expiryDate = ''; // Added expiry date
  String selectedUOM = ''; // Selected Unit of Measurement
  int qtyPerUOM = 0; // Quantity per UOM
  int inventoryQuantity = 0; // Calculated Inventory Quantity

  List<BatchInfo> batches = [];
  List<String> availableUOMs = []; // List to store available UOMs for the selected item

  ItemGroup selectedGroup = ItemGroup(groupName: '', minExpiryMonths: 0); // Selected item group

  Uint8List? customerLogo;

  @override
  void initState() {
    super.initState();
    loadCustomerLogo();
  }

  Future<void> loadCustomerLogo() async {
    final ByteData data = await rootBundle.load('assets/images/customer_logo.png');
    setState(() {
      customerLogo = data.buffer.asUint8List();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receiving Module'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: itemNameController,
                decoration: InputDecoration(labelText: 'Item Name'),
                onChanged: (value) {
                  itemName = value;
                  // Fetch available UOMs for the selected item
                  fetchAvailableUOMs();
                },
              ),
              // Add more text fields for manual input as needed
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  receiveItem();
                },
                child: Text('Receive'),
              ),
              SizedBox(height: 20),
              Text(
                'Batch Information:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Column(
                children: batches.map((batch) {
                  int difference = batch.orderedQuantity - batch.receivedQuantity;
                  return ListTile(
                    title: Text('Batch: ${batch.batchNumber}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Supplier Catalog Number: ${batch.supplierCatalogNumber}'),
                        Text('Ordered Quantity: ${batch.orderedQuantity}'),
                        Text('Received Quantity: ${batch.receivedQuantity}'),
                        Text('Difference: $difference'),
                        Text('Quality: ${batch.quality}'),
                        Text('Project: ${batch.project}'),
                        Text('Batch Status: ${batch.batchStatus}'),
                        Text('Production Date: ${batch.productionDate}'),
                        Text('Expiry Date: ${batch.expiryDate}'), // Display expiry date
                        if (batch.itemPhoto != null) Image.memory(batch.itemPhoto!),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: () {
                        _takePhotoForItem(batch);
                      },
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  printReceipt();
                },
                child: Text('Print Receipt'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  printDocument();
                },
                child: Text('Print Document'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void fetchAvailableUOMs() {
    // Fetch available UOMs for the selected item from the UOM table
    // You can use your preferred method for fetching data (e.g., HTTP request, database query)
    // Once data is fetched, update the availableUOMs list
  }

  void receiveItem() {
    print('Received: $quantity $itemName at $location from $supplier (Batch: $batchNumber, Warehouse: $warehouse)');
    print('Quality: $itemQuality, Status: $itemStatus, Comments: $itemComments');

    BatchInfo batchInfo = BatchInfo(
      batchNumber: batchNumber,
      orderedQuantity: quantity,
      receivedQuantity: quantity,
      quality: itemQuality,
      supplierCatalogNumber: supplierCatalogNumber,
      project: project,
      batchStatus: batchStatus,
      productionDate: productionDate,
      expiryDate: expiryDate, // Pass expiry date
      uom: selectedUOM,
      qtyPerUom: qtyPerUOM,
      inventoryQuantity: inventoryQuantity,
    );
    setState(() {
      batches.add(batchInfo);
    });

    // Clear text field controllers
    itemNameController.clear();
    supplierCatalogNumberController.clear();
    quantityController.clear();
    locationController.clear();
    supplierController.clear();
    batchNumberController.clear();
    warehouseController.clear();
    itemQualityController.clear();
    itemStatusController.clear();
    itemCommentsController.clear();
    projectController.clear();
    batchStatusController.clear();
    productionDateController.clear();
    expiryDateController.clear(); // Clear expiry date controller
    uomController.clear();
    qtyPerUomController.clear();

    // Reset data variables
    itemName = '';
    quantity = 0;
    location = '';
    supplier = '';
    batchNumber = '';
    warehouse = '';
    itemQuality = '';
    itemStatus = '';
    itemComments = '';
    supplierCatalogNumber = '';
    project = '';
    batchStatus = '';
    productionDate = '';
    expiryDate = ''; // Reset expiry date
    selectedUOM = '';
    qtyPerUOM = 0;
    inventoryQuantity = 0;
  }

  Future<void> _takePhotoForItem(BatchInfo batch) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final Uint8List? photoBytes = await pickedFile.readAsBytes();
      setState(() {
        batch.itemPhoto = photoBytes;
      });
    } else {
      // User canceled the photo capturing
    }
  }

  Future<void> printReceipt() async {
    // Printing receipt logic
  }

  Future<void> printDocument() async {
    // Printing document logic
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    // Implement the expiry date selection logic if needed
  }
}
