import 'package:flutter/material.dart';
import 'package:project/Forms/Items_Info_Form.dart';
import 'package:project/Forms/Price_Items_Info_Form.dart';
import 'package:project/Forms/Price_Lists_Items_Form.dart';
import 'package:project/app_notifier.dart';
import 'package:project/hive/items_hive.dart';
import 'package:project/hive/itemsprices_hive.dart';
import 'package:project/hive/pricelist_hive.dart';

class DataSearchPriceListsItems extends SearchDelegate<String> {
    final List<ItemsPrices> pricesitemsList;
  final AppNotifier appNotifier;
  final String plCode; // Add this field

  DataSearchPriceListsItems({
    required this.pricesitemsList,
    required this.appNotifier,
    required this.plCode, // Initialize it in the constructor
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, '');
      },
    );
  }
   
@override
  Widget buildResults(BuildContext context) {
    final results = pricesitemsList
        .where((priceitem) =>
            priceitem.plCode == plCode &&
            (priceitem.itemCode.contains(query) ||
                priceitem.uom.contains(query)))
        .toList();

    return _buildSearchResults(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = pricesitemsList
        .where((priceitem) =>
            priceitem.plCode == plCode &&
            (priceitem.itemCode.contains(query) ||
                priceitem.uom.contains(query)))
        .toList();

    return _buildSearchResults(suggestionList);
  }



  Widget _buildSearchResults(List<ItemsPrices> results) {
         TextStyle   _appTextStyle = TextStyle(fontSize:appNotifier.fontSize.toDouble());
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final price = results[index];
        return ListTile(
          title: Text(price.itemCode,style: _appTextStyle,),
          subtitle: Text(price.uom,style: _appTextStyle,),
        onTap: () {
                        // Navigate to the ItemsInfoForm page and pass the selected item
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PriceItemsInfo(itemsPrices: price, appNotifier:appNotifier),
                          ),
                        );
                      },
        );
      },
    );
  }
}
