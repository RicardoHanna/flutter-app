import 'package:hive/hive.dart';

part 'customers_hive.g.dart';

@HiveType(typeId: 35)
class Customers extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String custCode;

  @HiveField(2)
  late String custName;

  @HiveField(3)
  late String custFName;

  @HiveField(4)
  late String groupCode;

  @HiveField(5)
  late String mofNum;

  @HiveField(6)
  late String barcode;

  @HiveField(7)
  late String phone;

  @HiveField(8)
  late String mobile;

  @HiveField(9)
  late String fax;

  @HiveField(10)
  late String website;

  @HiveField(11)
  late String email;

  @HiveField(12)
  late bool active;

  @HiveField(13)
  late String printLayout;

  @HiveField(14)
  late String dfltAddressID;

  @HiveField(15)
  late String dfltContactID;

  @HiveField(16)
  late String curCode;

  @HiveField(17)
  late String cashClient;

  @HiveField(18)
  late String discType;

  @HiveField(19)
  late String vatCode;

  @HiveField(20)
  late String prListCode;

  @HiveField(21)
  late String payTermsCode;

  @HiveField(22)
  late double discount;

  @HiveField(23)
  late double creditLimit;

  @HiveField(24)
  late double balance;

  @HiveField(25)
  late double balanceDue;

  @HiveField(26)
  late String notes;

  Customers({
    required this.cmpCode,
    required this.custCode,
    required this.custName,
    required this.custFName,
    required this.groupCode,
    required this.mofNum,
    required this.barcode,
    required this.phone,
    required this.mobile,
    required this.fax,
    required this.website,
    required this.email,
    required this.active,
    required this.printLayout,
    required this.dfltAddressID,
    required this.dfltContactID,
    required this.curCode,
    required this.cashClient,
    required this.discType,
    required this.vatCode,
    required this.prListCode,
    required this.payTermsCode,
    required this.discount,
    required this.creditLimit,
    required this.balance,
    required this.balanceDue,
    required this.notes,

  });


}
