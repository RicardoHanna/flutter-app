import 'package:hive/hive.dart';

part 'customeraddresses_hive.g.dart';

@HiveType(typeId: 36)
class CustomerAddresses extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String custCode;

  @HiveField(2)
  late String addressID;

  @HiveField(3)
  late String address;

  @HiveField(4)
  late String fAddress;

  @HiveField(5)
  late String regCode;

  @HiveField(6)
  late String gpslat;

  @HiveField(7)
  late String gpslong;

  @HiveField(8)
  late String notes;

  @HiveField(9)
  late String addressType;

  @HiveField(10)
  late String countryCode;

  @HiveField(11)
  late String city;

  @HiveField(12)
  late String block;

  @HiveField(13)
  late String street;

  @HiveField(14)
  late String zipCode;

  @HiveField(15)
  late String building;




 
  CustomerAddresses({
    required this.cmpCode,
    required this.custCode,
    required this.addressID,
    required this.address,
    required this.fAddress,
    required this.regCode,
    required this.gpslat,
    required this.gpslong,
    required this.notes,
    required this.addressType,
    required this.countryCode,
    required this.city,
    required this.block,
    required this.street,
    required this.zipCode,
    required this.building,
  });


}
