import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:project/app_notifier.dart';

class BookingDateScreen extends StatefulWidget {
  final AppNotifier appNotifier;
  final String usercode;
   BookingDateScreen(
      {required this.appNotifier, required this.usercode});

  @override
  State<BookingDateScreen> createState() => _BookingDateScreenState();
}

class _BookingDateScreenState extends State<BookingDateScreen> {
  TextEditingController bookingDateController = TextEditingController();
  TextEditingController dueDateController = TextEditingController();
  TextEditingController BpReferenceController = TextEditingController();
  TextEditingController commentsController = TextEditingController();
  TextEditingController createdByController = TextEditingController();

  DateTime _selectedDueDate = DateTime.now();
  DateTime _selectedBookingDate = DateTime.now();

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _selectBookingDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBookingDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedBookingDate) {
      setState(() {
        _selectedBookingDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Receipt',
          style: TextStyle(
              fontSize: widget.appNotifier.fontSize.toDouble(),
              color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.attach_file,
                color: Colors.white,
              )),
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
              )),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: bookingDateController,
                    decoration: InputDecoration(
                        labelText: 'Booking date',
                        labelStyle: TextStyle(
                            fontSize:
                                widget.appNotifier.fontSize.toDouble() - 2)),
                    onChanged: (value) {
                      // itemName = value;
                    },
                  ),
                ),
                IconButton(
                  onPressed: () => _selectDueDate(context),
                  icon: Icon(Icons.calendar_month),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: dueDateController,
                    decoration: InputDecoration(
                        labelText: 'Due date',
                        labelStyle: TextStyle(
                            fontSize:
                                widget.appNotifier.fontSize.toDouble() - 2)),
                    onChanged: (value) {
                      // itemName = value;
                    },
                  ),
                ),
                IconButton(
                  onPressed: () => _selectBookingDate,
                  icon: Icon(Icons.calendar_month),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: BpReferenceController,
              decoration: InputDecoration(
                  labelText: 'BP Reference',
                  labelStyle: TextStyle(
                      fontSize: widget.appNotifier.fontSize.toDouble() - 2)),
              onChanged: (value) {
                // itemName = value;
              },
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: commentsController,
              decoration: InputDecoration(
                  labelText: 'Comments',
                  labelStyle: TextStyle(
                      fontSize: widget.appNotifier.fontSize.toDouble() - 2)),
              onChanged: (value) {
                // itemName = value;
              },
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: createdByController,
              decoration: InputDecoration(
                  labelText: 'Created By',
                  labelStyle: TextStyle(
                      fontSize: widget.appNotifier.fontSize.toDouble() - 2)),
              onChanged: (value) {
                // itemName = value;
              },
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                // Navigator.of(context).push(
                //     MaterialPageRoute(builder: (builder) => SignatureScreen()));
              },
              child: Text(
                "Signature",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.appNotifier.fontSize.toDouble()),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      20), // Adjust borderRadius to maintain button shape
                ),
                backgroundColor: Colors.blue,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text(
                "Send",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.appNotifier.fontSize.toDouble()),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      20), // Adjust borderRadius to maintain button shape
                ),
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
