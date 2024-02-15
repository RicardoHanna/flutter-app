import 'package:flutter/material.dart';
class CatalogOrderSubmitForm extends StatefulWidget {
  final String imageUrl;
  final int quantity;
  final double price;

  CatalogOrderSubmitForm({
    required this.imageUrl,
    required this.quantity,
    required this.price,
  });

  @override
  State<CatalogOrderSubmitForm> createState() => _CatalogOrderSubmitFormState();
}

class _CatalogOrderSubmitFormState extends State<CatalogOrderSubmitForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Order'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Confirm Order Details:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            // Display the selected image
            Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              width: 200, // Adjust the width as needed
              height: 200, // Adjust the height as needed
            ),
            SizedBox(height: 16.0),
            Text('Quantity: ${widget.quantity}'),
            Text('Price: \$${widget.price.toStringAsFixed(2)}'),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                // Implement order confirmation logic
                _confirmOrder(context);
              },
              child: Text('Confirm Order'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmOrder(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Order Confirmed'),
          content: Text('Your order has been confirmed. Thank you!'),
          actions: [
            TextButton(
  onPressed: () {
    Navigator.of(context).pop();
  },
  child: Text('Close'),
),

          ],
        );
      },
    );
  }
}
