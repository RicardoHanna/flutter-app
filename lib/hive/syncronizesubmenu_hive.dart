import 'package:hive/hive.dart';

part 'syncronizesubmenu_hive.g.dart';

@HiveType(typeId: 15)
class SynchronizeSubMenu extends HiveObject {
  @HiveField(0)
  late int syncronizecode;

  @HiveField(1)
  late String syncronizename;

  @HiveField(2)
  late String syncronizearname;

static const int IMPORT_FROM_ERP_MENU_CODE = 201;
static const int EXPORT_MENU_CODE = 202;
static const int IMPORT_FROM_BACKEND_MENU_CODE = 203;

  SynchronizeSubMenu({
  required  this.syncronizecode,
   required this.syncronizename,
   required this.syncronizearname,
  }
  );
}
