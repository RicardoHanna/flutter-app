import 'package:flutter/material.dart';
import 'rounded_icon.dart';
import 'package:project/screens/admin_page.dart';
import 'settings_page.dart';
class welcomePage extends StatefulWidget {
  final String email;
  final String password;
  
  welcomePage({required this.email,required this.password});

  @override
  State<welcomePage> createState() => _welcomePageState();
}

class _welcomePageState extends State<welcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Welcome Page'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 12,horizontal: 12),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RoundedIcon(
                icon: Icons.settings,
                onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  SettingsPage(email: widget.email,password: widget.password),
                  ));
                },
              ),
              SizedBox(height: 20,width: 12,),
              RoundedIcon(
                icon: Icons.admin_panel_settings,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  AdminPage(),
                  ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

