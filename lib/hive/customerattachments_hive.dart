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

  @HiveField(5)
  late String lineID;

  @HiveField(6)
  late String attachPath;

  @HiveField(7)
  late String attachFile;

 
  CustomerAttachments({
    required this.cmpCode,
    required this.custCode,
    required this.attach,
    required this.attachType,
    required this.notes,
    required this.lineID,
    required this.attachPath,
    required this.attachFile
  });


}
