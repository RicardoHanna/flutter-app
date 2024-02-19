import 'package:flutter/material.dart';
import 'package:project/Forms/Items_Info_Form.dart';
import 'package:project/Forms/Price_Lists_Items_Form.dart';
import 'package:project/app_notifier.dart';
import 'package:project/hive/items_hive.dart';
import 'package:project/hive/pricelist_hive.dart';

class DataSearchPriceLists extends SearchDelegate<String> {
  final List<PriceList> pricesList;
  final AppNotifier appNotifier;
  DataSearchPriceLists({required this.pricesList,required this.appNotifier});

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
    // Implement the logic to filter items based on the search query
    final results = pricesList
        .where((price) =>
            price.plCode.contains(query) ||
            price.plName.contains(query) )
        .toList();

    return _buildSearchResults(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Show suggestions while the user types
    final suggestionList = query.isEmpty
        ? pricesList
        : pricesList
            .where((price) =>
                price.plCode.contains(query) ||
                price.plName.contains(query) )
            .toList();

    return _buildSearchResults(suggestionList);
  }

  Widget _buildSearchResults(List<PriceList> results) {
         TextStyle   _appTextStyle = TextStyle(fontSize:appNotifier.fontSize.toDouble());
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final price = results[index];
        return ListTile(
          title: Text(price.plCode,style: _appTextStyle,),
          subtitle: Text(price.plName,style: _appTextStyle,),
        onTap: () {
                        // Navigate to the ItemsInfoForm page and pass the selected item
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PriceListsItems(priceList: price, appNotifier:appNotifier),
                          ),
                        );
                      },
        );
      },
    );
  }
}
