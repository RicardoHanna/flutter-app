import 'package:hive/hive.dart';

part 'exchangerate_hive.g.dart';

@HiveType(typeId: 19)
class ExchangeRate extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String curCode;

  @HiveField(2)
  late DateTime fDate;

  @HiveField(3)
  late DateTime tDate;

  @HiveField(4)
  late int rate;


  ExchangeRate({
    required this.cmpCode,
    required this.curCode,
    required this.fDate,
    required this.tDate,
    required this.rate
  });


}
