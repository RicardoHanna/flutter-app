import 'package:hive/hive.dart';

part 'itemattach_hive.g.dart';

@HiveType(typeId: 7)
class ItemAttach extends HiveObject {
  @HiveField(0)
  late String itemCode;

  @HiveField(1)
  late String attachmentType; // e.g., 'image', 'pdf', etc.

  @HiveField(2)
  late String attachmentPath; // File path or content

  @HiveField(3)
  late String note;

  ItemAttach(
    this.itemCode,
    this.attachmentType,
    this.attachmentPath,
    this.note,
  );
}
