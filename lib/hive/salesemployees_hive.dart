import 'package:hive/hive.dart';

part 'salesemployees_hive.g.dart';

@HiveType(typeId: 27)
class SalesEmployees extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String seCode;

  @HiveField(2)
  late String seName;

  @HiveField(3)
  late String seFName;

  @HiveField(4)
  late String mobile;

  @HiveField(5)
  late String email;

  @HiveField(6)
  late String whsCode;

  @HiveField(7)
  late dynamic reqFromWhsCode;

  @HiveField(8)
  late String notes;

  @HiveField(9)
  late String cashSalesCustCode;

  @HiveField(10)
  late bool allowUpdDisc;

  @HiveField(11)
  late dynamic maxDiscPerc;

  @HiveField(12)
  late bool allowFreeItm;

  @HiveField(13)
  late bool allowFreeInv;

  SalesEmployees({
    required this.cmpCode,
    required this.seCode,
    required this.seName,
    required this.seFName,
    required this.mobile,
    required this.email,
    required this.whsCode,
    required this.reqFromWhsCode,
    required this.notes,
    required this.cashSalesCustCode,
    required this.allowUpdDisc,
    required this.maxDiscPerc,
    required this.allowFreeItm,
    required this.allowFreeInv
  });


}
