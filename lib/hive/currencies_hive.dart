import 'package:hive/hive.dart';

part 'currencies_hive.g.dart';

@HiveType(typeId: 20)
class Currencies extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String curCode;

  @HiveField(2)
  late String curName;

  @HiveField(3)
  late String curFName;

  @HiveField(4)
  late String notes;

  @HiveField(5)
  late dynamic amntDec;

  @HiveField(6)
  late String rounding;


  Currencies({
    required this.cmpCode,
    required this.curCode,
    required this.curName,
    required this.curFName,
    required this.notes,
    required this.amntDec,
    required this.rounding
  });


}
