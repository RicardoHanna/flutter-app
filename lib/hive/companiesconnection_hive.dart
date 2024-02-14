import 'package:hive/hive.dart';

part 'companiesconnection_hive.g.dart';

@HiveType(typeId: 52)
class CompaniesConnection extends HiveObject {
  @HiveField(0)
  late String connectionID; 
  
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

 
  CompaniesConnection({
   required  this.connectionID,
   required this.connDatabase,
   required this.connServer,
   required this.connUser,
   required this.connPassword,
   required this.connPort,
   required this.typeDatabase,
  }
  );
   // Convert UserGroup instance to JSON format
  Map<String, dynamic> toJson() {
    return {
      'connectionID': connectionID,
      'connDatabase': connDatabase,
      'connServer': connServer,
      'connUser': connUser,
      'connPassword':connPassword,
      'connPort': connPort,
      'typeDatabase': typeDatabase
    };
  }
}
