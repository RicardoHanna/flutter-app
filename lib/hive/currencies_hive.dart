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


  Currencies({
    required this.cmpCode,
    required this.curCode,
    required this.curName,
    required this.curFName,
    required this.notes
  });


}
