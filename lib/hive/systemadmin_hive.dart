import 'package:hive/hive.dart';

part 'systemadmin_hive.g.dart';

@HiveType(typeId: 16)
class SystemAdmin extends HiveObject {
  @HiveField(0)
  late bool autoExport;

  @HiveField(1)
  late String connDatabase;

  @HiveField(2)
  late String connServer;

  @HiveField(3)
  late String connUser;

  @HiveField(4)
  late String connPassword;

  @HiveField(5)
  late int connPort;

  @HiveField(6)
  late String typeDatabase;

  @HiveField(7)
  late int groupcode;

  @HiveField(8)
  late bool importFromErpToMobile;

  @HiveField(9)
  late bool importFromBackendToMobile;


  SystemAdmin({
   required  this.autoExport,
   required this.connDatabase,
   required this.connServer,
   required this.connUser,
   required this.connPassword,
   required this.connPort,
   required this.typeDatabase,
   required this.groupcode,
   required this.importFromErpToMobile,
   required this.importFromBackendToMobile
  }
  );
}
