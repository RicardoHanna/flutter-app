import 'package:hive/hive.dart';

part 'hiveuser.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  late String usercode;

  @HiveField(1)
  late String username;

  @HiveField(2)
  late String userFname;

  @HiveField(3)
  late String email;

  @HiveField(4)
  late String password;

  @HiveField(5)
  late String phonenumber;

  @HiveField(6)
  late String imeicode;

  @HiveField(7)
  late bool active;

  @HiveField(8)
  late String imageLink;
 
  @HiveField(9)
  late int usergroup;

  @HiveField(10)
  late String languages;

  @HiveField(11)
  late int font;

  User(
    this.usercode,
    this.username,
    this.userFname,
    this.email,
    this.password,
    this.phonenumber,
    this.imeicode,
    this.active,
    this.imageLink,
    this.usergroup,
    this.languages,
    this.font,
  );

   Map<String, dynamic> toJson() {
    return {
      'usercode': usercode,
      'username': username,
      'userFname': userFname,
      'email': email,
      'password': password,
      'phonenumber': phonenumber,
      'imeicode': imeicode,
      'active': active,
      'imageLink': imageLink,
      'usergroup': usergroup,
      'languages': languages,
      'font': font,
    };
  }
}
