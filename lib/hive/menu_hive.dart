import 'package:hive/hive.dart';

part 'menu_hive.g.dart';

@HiveType(typeId: 12)
class Menu extends HiveObject {
  @HiveField(0)
  late int menucode;

  @HiveField(1)
  late String menuname;

static const int ADMIN_MENU_CODE = 1;
static const int SETTINGS_MENU_CODE = 2;
static const int SYNCRONIZE_MENU_CODE = 3;
static const int ITEMS_MENU_CODE = 4;
static const int PRICELISTS_MENU_CODE = 5;
  Menu({
  required  this.menucode,
   required this.menuname,
  }
  );
}
