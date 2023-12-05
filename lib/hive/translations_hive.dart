import 'package:hive/hive.dart';

part 'translations_hive.g.dart';

@HiveType(typeId: 2)
class Translations extends HiveObject {
  @HiveField(0)
  int usercode;

  @HiveField(1)
  Map<String, String> translations;

  Translations({
    required this.usercode,
    required this.translations,
  });
}
