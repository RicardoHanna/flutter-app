import 'package:hive/hive.dart';

part 'userpl_hive.g.dart';

@HiveType(typeId: 11)
class UserPL extends HiveObject {
  @HiveField(0)
  late String userCode;

  @HiveField(1)
  late String plSecGroup;


  UserPL(
    this.userCode,
    this.plSecGroup,
  
  );
}
