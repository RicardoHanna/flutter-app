import 'package:hive/hive.dart';

part 'companiesusers_hive.g.dart';

@HiveType(typeId: 54)
class CompaniesUsers extends HiveObject {
  @HiveField(0)
  late String userCode; 
  
  @HiveField(1)
  late String cmpCode;
 
  @HiveField(2)
  late dynamic defaultcmpCode;

  CompaniesUsers({
   required  this.userCode,
   required this.cmpCode,
   required this.defaultcmpCode

  }
  );
}
