import 'package:flutter/material.dart';
import 'package:project/Forms/Items_Info_Form.dart';
import 'package:project/hive/items_hive.dart';

class DataSearch extends SearchDelegate<String> {
  final List<Items> itemsList;

  DataSearch({required this.itemsList});

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
    final results = itemsList
        .where((item) =>
            item.itemCode.contains(query) ||
            item.itemName.contains(query) ||
            // ... add other fields as needed
            item.charact2.contains(query))
        .toList();

    return _buildSearchResults(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Show suggestions while the user types
    final suggestionList = query.isEmpty
        ? itemsList
        : itemsList
            .where((item) =>
                item.itemCode.contains(query) ||
                item.itemName.contains(query) ||
                // ... add other fields as needed
                item.charact2.contains(query))
            .toList();

    return _buildSearchResults(suggestionList);
  }

  Widget _buildSearchResults(List<Items> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          title: Text(item.itemName),
          subtitle: Text(item.itemCode),
        onTap: () {
                        // Navigate to the ItemsInfoForm page and pass the selected item
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemsInfoForm(item: item),
                          ),
                        );
                      },
        );
      },
    );
  }
}
