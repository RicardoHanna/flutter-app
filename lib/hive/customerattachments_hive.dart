import 'package:hive/hive.dart';

part 'customerattachments_hive.g.dart';

@HiveType(typeId: 39)
class CustomerAttachments extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String custCode;

  @HiveField(2)
  late String attach;

  @HiveField(3)
  late String attachType;

  @HiveField(4)
  late String notes;

 
  CustomerAttachments({
    required this.cmpCode,
    required this.custCode,
    required this.attach,
    required this.attachType,
    required this.notes,
  });


}
