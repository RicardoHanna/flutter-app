import 'package:hive/hive.dart';

part 'hiveuser.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  late int usercode;

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
  late String warehouse;

  @HiveField(8)
  late bool active;

  @HiveField(9)
  late String imageLink;
 
  @HiveField(10)
  late int usergroup;

  @HiveField(11)
  late String languages;

  @HiveField(12)
  late int font;

  User(
    this.usercode,
    this.username,
    this.userFname,
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
