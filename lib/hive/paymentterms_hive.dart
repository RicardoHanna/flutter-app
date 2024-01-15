import 'package:hive/hive.dart';

part 'paymentterms_hive.g.dart';

@HiveType(typeId: 26)
class PaymentTerms extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String ptCode;

  @HiveField(2)
  late String ptName;

  @HiveField(3)
  late String ptFName;

  @HiveField(4)
  late String startFrom;

  @HiveField(5)
  late int nbrofDays;

  @HiveField(6)
  late String notes;



  PaymentTerms({
    required this.cmpCode,
    required this.ptCode,
    required this.ptName,
    required this.ptFName,
    required this.startFrom,
    required this.nbrofDays,
    required this.notes
  });


}
