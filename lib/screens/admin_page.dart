import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/classes/UserClass.dart';
import 'package:project/Forms/edit_user_form.dart';
import 'package:project/Forms/user_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  TextEditingController _searchController = TextEditingController();
  late Stream<List<UserClass>> _usersStream;
  late List<UserClass> users = [];
  late List<UserClass> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _usersStream = _getUserStream();
  }

  Stream<List<UserClass>> _getUserStream() {
    return FirebaseFirestore.instance.collection('Users').snapshots().map(
      (QuerySnapshot querySnapshot) {
        users = querySnapshot.docs.map((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          String username = data['username'] as String? ?? 'DefaultUsername';
          String email = data['email'] as String? ?? 'DefaultEmail';
          String password = data['password'] as String? ?? 'DefaultPass';
          String phonenumber = data['phonenumber'] as String? ?? 'DefaultPhone';
          String warehouse = data['warehouse'] as String? ?? 'DefaultWarehouse';
       int usergroup = data['usergroup'] as int? ?? 0; // Assuming 0 as the default value
         int font = data['font'] as int? ?? 0; // Default value is 0 if data['font'] is null or not an int
       String imeicode = data['imeicode'] as String? ?? 'DefaultIMEI';
          String languages = data['languages'] as String? ?? 'DefaultLanguages';
          bool active = data['active'] as bool? ?? false; // Assuming false as the default value

          return UserClass(
            username: username,
            email: email,
            password: password,
            phonenumber: phonenumber,
            imeicode: imeicode,
            warehouse: warehouse,
            usergroup: usergroup,
            font: font,
            languages: languages,
            active: active,
          );
        }).toList();
        return users;
      },
    );
  }

void _deleteUser(String username) async {
  bool confirmDelete = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.confirmDeletion),
        content: Text(AppLocalizations.of(context)!.textDeletion('$username','$username')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Do not delete
            },
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Confirm deletion
            },
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      );
    },
  );

  if (confirmDelete == true) {
    try {
      // Query for the document with the given username
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('username', isEqualTo: username)
          .get();

      // Check if the document exists
      if (querySnapshot.docs.isNotEmpty) {
        // Delete the document
        await querySnapshot.docs.first.reference.delete();
      } else {
        print('Document with username $username not found.');
      }

      // No need to update the stream here; it will be updated in _getUserStream
    } catch (e) {
      print('Error deleting user: $e');
    }
  }
}

  void _searchUsers(String query) {
    setState(() {
      filteredUsers = users.where((user) {
        final userName = user.username.toLowerCase();
        final input = query.toLowerCase();
        return userName.contains(input) || user.email.toLowerCase().contains(input);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.adminPage),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.serchName,
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _searchUsers(value);
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<UserClass>>(
              stream: _usersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                List<UserClass> userList = snapshot.data ?? [];

                return ListView.builder(
                  itemCount: filteredUsers.isEmpty ? userList.length : filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers.isEmpty ? userList[index] : filteredUsers[index];
                    return ListTile(
                      title: Text(user.username),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            color: Colors.blue,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditUserForm(
                                    username: user.username,
                                    email: user.email,
                                    password: user.password,
                                    phonenumber: user.phonenumber,
                                    imeicode:user.imeicode,
                                    warehouse: user.warehouse,
                                    usergroup: user.usergroup,
                                    font: user.font,
                                    languages: user.languages,
                                    active: user.active,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () {
                              _deleteUser(user.username);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserForm()),
              );
            },
            child: Text(AppLocalizations.of(context)!.add),
          ),
        ],
      ),
    );
  }
}
