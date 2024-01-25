import 'package:hive/hive.dart';

part 'companiesusers_hive.g.dart';

@HiveType(typeId: 54)
class CompaniesUsers extends HiveObject {
  @HiveField(0)
  late String userCode; 
  
  @HiveField(1)
  late String cmpCode;
 
  CompaniesUsers({
   required  this.userCode,
   required this.cmpCode,

  }
  );
}
