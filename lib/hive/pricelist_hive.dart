import 'package:hive/hive.dart';

part 'pricelist_hive.g.dart';

@HiveType(typeId: 9)
class PriceList extends HiveObject {
  @HiveField(0)
  late String plCode;

  @HiveField(1)
  late String plName;

  @HiveField(2)
  late String currency;

  @HiveField(3)
  late dynamic basePL;

  @HiveField(4)
  late double factor;

  @HiveField(5)
  late bool incVAT;

  @HiveField(6)
  late String cmpCode;

  @HiveField(7)
  late String authoGroup;
  
  @HiveField(8)
  late String plFName;

  @HiveField(9)
  late String notes;

  PriceList(
    this.plCode,
    this.plName,
    this.currency,
    this.basePL,
    this.factor,
    this.incVAT,
    this.cmpCode,
    this.authoGroup,
    this.plFName,
    this.notes
  );
}
