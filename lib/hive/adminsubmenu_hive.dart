import 'package:hive/hive.dart';

part 'adminsubmenu_hive.g.dart';

@HiveType(typeId: 14)
class AdminSubMenu extends HiveObject {
  @HiveField(0)
  late int groupcode;

  @HiveField(1)
  late String groupname;

  @HiveField(2)
  late String grouparname;

static const int ADMIN_USERS_MENU_CODE = 101;
static const int SETTINGS_USERSGROUP_MENU_CODE = 102;
static const int AUTHORIZATIONS_MENU_CODE = 103;
static const int GENERAL_SETTINGS_MENU_CODE = 104;
static const int COMPANIES_SETTINGS_MENU_CODE = 105;
  AdminSubMenu({
  required  this.groupcode,
   required this.groupname,
   required this.grouparname,
  }
  );
}
