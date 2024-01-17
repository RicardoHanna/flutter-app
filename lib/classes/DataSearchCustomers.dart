import 'package:flutter/material.dart';
import 'package:project/Forms/Customers_Info_Form.dart';
import 'package:project/Forms/Items_Info_Form.dart';
import 'package:project/app_notifier.dart';
import 'package:project/hive/customers_hive.dart';
import 'package:project/hive/items_hive.dart';

class DataSearchCustomers extends SearchDelegate<String> {
  final List<Customers> customersList;
  final AppNotifier appNotifier;

 TextStyle   _appTextStyleNormal = TextStyle();
  DataSearchCustomers({required this.customersList,required this.appNotifier});

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
    final results = customersList
        .where((customer) =>
            customer.custCode.contains(query) ||
            customer.custName.contains(query))
         
        .toList();

    return _buildSearchResults(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Show suggestions while the user types
    final suggestionList = query.isEmpty
        ? customersList
        : customersList
            .where((item) =>
                item.custCode.contains(query) ||
                item.custName.contains(query))
            .toList();

    return _buildSearchResults(suggestionList);
  }

  Widget _buildSearchResults(List<Customers> results) {
     TextStyle   _appTextStyle = TextStyle(fontSize: appNotifier.fontSize.toDouble());
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final customer = results[index];
        return ListTile(
          title: Text(customer.custName,style: _appTextStyle,),
          subtitle: Text(customer.custCode,style: _appTextStyle,),
        onTap: () {
                        // Navigate to the ItemsInfoForm page and pass the selected item
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CustomersInfoForm(customer: customer,appNotifier:this.appNotifier,),
                          ),
                        );
                      },
        );
      },
    );
  }
}
