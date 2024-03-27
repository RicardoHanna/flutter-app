import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project/app_notifier.dart';

class DraftsForm extends StatefulWidget {
  final String usercode;
  final AppNotifier appNotifier;
  final List<Map<String,dynamic>> drafts;
  const DraftsForm({super.key, required this.usercode, required this.appNotifier, required this.drafts});

  @override
  State<DraftsForm> createState() => _DraftsFormState();
}

class _DraftsFormState extends State<DraftsForm> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Drafts"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: widget.drafts.length,
          itemBuilder: (builder,index){
            return Card(
              child: ListTile(
                title: Text('${widget.drafts[index]['Title']}'),
              ),
            );
          }
          ),
      ),
    );
  }
}