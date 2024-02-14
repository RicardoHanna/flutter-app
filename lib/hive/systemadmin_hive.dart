import 'package:hive/hive.dart';

part 'systemadmin_hive.g.dart';

@HiveType(typeId: 16)
class SystemAdmin extends HiveObject {
  @HiveField(0)
  late bool autoExport;

  @HiveField(1)
  late int groupcode;

  @HiveField(2)
  late bool importFromErpToMobile;

  @HiveField(3)
  late bool importFromBackendToMobile;


  SystemAdmin({
   required  this.autoExport,
   required this.groupcode,
   required this.importFromErpToMobile,
   required this.importFromBackendToMobile
  }
  );
   // Convert UserGroup instance to JSON format
  Map<String, dynamic> toJson() {
    return {
      'autoExport': autoExport,
      'groupcode': groupcode,
      'importFromErpToMobile':importFromErpToMobile,
      'importFromBackendToMobile':importFromBackendToMobile
    };
  }
}
