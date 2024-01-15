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
  late double basePL;

  @HiveField(4)
  late double factor;

  @HiveField(5)
  late bool incVAT;

  @HiveField(6)
  late String securityGroup;

  @HiveField(7)
  late String cmpCode;

  PriceList(
    this.plCode,
    this.plName,
    this.currency,
    this.basePL,
    this.factor,
    this.incVAT,
    this.securityGroup,
    this.cmpCode
  );
}
