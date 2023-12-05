import 'package:hive/hive.dart';

part 'hiveuser.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  late String username;

  @HiveField(1)
  late String email;

  @HiveField(2)
  late String password;

  @HiveField(3)
  late String phonenumber;

  @HiveField(4)
  late String imeicode;

  @HiveField(5)
  late String warehouse;

  @HiveField(6)
  late bool active;

  @HiveField(7)
  late String imageLink;
 
  @HiveField(8)
  late int usergroup;

  @HiveField(9)
  late String languages;

  @HiveField(10)
  late int font;

  User(
    this.username,
    this.email,
    this.password,
    this.phonenumber,
    this.imeicode,
    this.warehouse,
    this.active,
    this.imageLink,
    this.usergroup,
    this.languages,
    this.font,
  );
}
