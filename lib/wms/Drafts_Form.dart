import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DraftsForm extends StatefulWidget {
  final String usercode;
  const DraftsForm({super.key, required this.usercode});

  @override
  State<DraftsForm> createState() => _DraftsFormState();
}

class _DraftsFormState extends State<DraftsForm> {
  String apiurl = 'http://5.189.188.139:8081/api/';
  List<Map<String , dynamic>> drafts = [];
  Future<void> loadDrafts() async {
    try {
      final cmpCode = await fetchCmpCode(widget.usercode);

      final response = await http.post(Uri.parse('${apiurl}getDrafts'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'cmpCode': cmpCode,
            'userCode': widget.usercode,
          }));

      if (response.statusCode == 200) {
        List<dynamic> drafts = jsonDecode(response.body);
        List<Map<String, dynamic>> draftsMap = drafts
            .map((dynamic item) => item as Map<String, dynamic>)
            .toList(); // Transformation here
        print(draftsMap);
      }
    } catch (err) {}
  }

  Future<String?> fetchCmpCode(String userCode) async {
    try {
      final response = await http.get(
        Uri.parse('${apiurl}getDefaultCompCode?userCode=$userCode'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return data[0]['cmpCode'].toString();
        }
      }
    } catch (error) {
      print('Error fetching cmpCode: $error');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Drafts"),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
      ),
    );
  }
}