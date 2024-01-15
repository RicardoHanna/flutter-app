import 'package:hive/hive.dart';

part 'customercontacts_hive.g.dart';

@HiveType(typeId: 37)
class CustomerContacts extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String custCode;

  @HiveField(2)
  late String contactID;

  @HiveField(3)
  late String contactName;

  @HiveField(4)
  late String contactFName;

  @HiveField(5)
  late String phone;

  @HiveField(6)
  late String mobile;

  @HiveField(7)
  late String email;

  @HiveField(8)
  late String position;

  @HiveField(9)
  late String notes;

 
  CustomerContacts({
    required this.cmpCode,
    required this.custCode,
    required this.contactID,
    required this.contactName,
    required this.contactFName,
    required this.phone,
    required this.mobile,
    required this.email,
    required this.position,
    required this.notes,
  });


}
