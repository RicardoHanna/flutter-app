import 'package:hive/hive.dart';

part 'menu_hive.g.dart';

@HiveType(typeId: 12)
class Menu extends HiveObject {
  @HiveField(0)
  late int menucode;

  @HiveField(1)
  late String menuname;

  @HiveField(3)
  late String menuarname;

static const int ADMIN_MENU_CODE = 1;
static const int SETTINGS_MENU_CODE = 2;
static const int SYNCRONIZE_MENU_CODE = 3;
static const int ITEMS_MENU_CODE = 4;
static const int PRICELISTS_MENU_CODE = 5;
static const int CUSTOMERS_MENU_CODE=6;
static const int REPORT_MENU_CODE=7;
static const int INVENTORY_MENU_CODE=8;
static const int BP_MENU_CODE=9;
static const int WMS_MENU_CODE=10;
static const int RECEIVE_MENU_CODE=11;
static const int PICKING_MENU_CODE=12;
static const int PUTAWAY_MENU_CODE=13;
static const int PACKING_MENU_CODE=14;
static const int TRANSACTIONS_MENU_CODE=15;
static const int CYCLE_MENU_CODE=15;



  Menu({
  required  this.menucode,
   required this.menuname,
   required this.menuarname,
  }
  );
}
