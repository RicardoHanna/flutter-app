import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:project/Forms/Attachements_Item_Form.dart';
import 'package:project/app_notifier.dart';
import 'package:project/hive/items_hive.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:project/hive/itemuom_hive.dart';

class ItemsInfoForm extends StatelessWidget {
  final Items item;
  final AppNotifier appNotifier;

  ItemsInfoForm({required this.item, required this.appNotifier});

  @override
  Widget build(BuildContext context) {
    TextStyle _appTextStyle = TextStyle(fontSize: appNotifier.fontSize.toDouble());
    TextStyle _appTextStyleAppBar = TextStyle(fontSize: appNotifier.fontSize.toDouble());
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.itemdetails, style: _appTextStyleAppBar),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: AppLocalizations.of(context)!.general),
              Tab(text: AppLocalizations.of(context)!.itemuom),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildItemsTab(context),
            _buildItemsUom(context),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigate to AttachementsItemForm when the button is pressed
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AttachementsItemForm(itemCode: item.itemCode, appNotifier: appNotifier),
              ),
            );
          },
          child: Icon(Icons.attach_file),
        ),
      ),
    );
  }

  // Create your tab content widgets here
 Widget _buildItemsTab(BuildContext context) {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
             ListTile(
              title: Text(AppLocalizations.of(context)!.itemcode),
              subtitle: Text(item.itemCode ?? 'N/A'),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.itemname),
              subtitle: Text(item.itemName ?? 'N/A'),
            ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.itemprname),
            subtitle: Text(item.itemPrFName ?? 'N/A'),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.itemfname),
            subtitle: Text(item.itemFName ?? 'N/A'),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.groupcode),
            subtitle: Text(item.groupCode ?? 'N/A'),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.categcode),
            subtitle: Text(item.categCode ?? 'N/A'),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.brandcode),
            subtitle: Text(item.brandCode ?? 'N/A'),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.itemtype),
            subtitle: Text(item.itemType ?? 'N/A'),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.barcode),
            subtitle: Text(item.barCode ?? 'N/A'),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.uom),
            subtitle: Text(item.uom ?? 'N/A'),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.remark),
            subtitle: Text(item.remark ?? 'N/A'),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.manageby),
            subtitle: Text(item.manageBy ?? 'N/A'),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.vatrate),
            subtitle: Text(item.vatCode.toString() ?? 'N/A'),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.weight),
            subtitle: Text(item.weight.toString() ?? 'N/A'),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildItemsUom(BuildContext context) {
    return FutureBuilder<Box<ItemUOM>>(
      future: Hive.openBox<ItemUOM>('itemuom'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            Box<ItemUOM> itemUOMBox = snapshot.data!;
            String key = item.uom;
            String key1 = item.itemCode;
            String key2 = item.cmpCode;
            List<ItemUOM> itemuom = itemUOMBox.values
                .where((itemuom) => itemuom.uom == key && itemuom.itemCode == key1 && itemuom.cmpCode == key2)
                .toList();

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(itemuom.length, (index) {
                    ItemUOM itemuoms = itemuom[index];
                    return Card(
                      child: ListTile(
                        title: Text(AppLocalizations.of(context)!.uom + '${index + 1}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.cmpCode),
                            Text(itemuoms.cmpCode ?? 'N/A'),
                            Text(AppLocalizations.of(context)!.itemcode),
                            Text(itemuoms.itemCode ?? 'N/A'),
                              Text('Doc Type'),
                            Text(itemuoms.docType ?? 'N/A'),
                            Text(AppLocalizations.of(context)!.qtyperUOM),
                            Text(itemuoms.qtyperUOM.toString() ?? 'N/A'),
                            Text('Notes'),
                            Text(itemuoms.notes ?? 'N/A'),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            );
          }
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
