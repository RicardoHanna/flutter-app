import 'package:hive/hive.dart';

part 'itemcateg_hive.g.dart';

@HiveType(typeId: 5)
class ItemCateg extends HiveObject {
  @HiveField(0)
  late String categCode;

  @HiveField(1)
  late String categName;

  @HiveField(2)
  late String categFName;

  @HiveField(3)
  late String cmpCode;

  ItemCateg(
    this.categCode,
    this.categName,
    this.categFName,
    this.cmpCode
  );
}
