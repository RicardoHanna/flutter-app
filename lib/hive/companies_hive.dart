import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'companies_hive.g.dart';

@HiveType(typeId: 17)
class Companies extends HiveObject {
  @HiveField(0)
  late String cmpCode;

  @HiveField(1)
  late String cmpName;

  @HiveField(2)
  late String cmpFName;

  @HiveField(3)
  late String tel;

  @HiveField(4)
  late String mobile;

  @HiveField(5)
  late String address;

  @HiveField(6)
  late String fAddress;

  @HiveField(7)
  late String prHeader;

  @HiveField(8)
  late String prFHeader;

  @HiveField(9)
  late String prFooter;

  @HiveField(10)
  late String prFFooter;

  @HiveField(11)
  late String mainCurCode;

  @HiveField(12)
  late String secCurCode;

  @HiveField(13)
  late String rateType;

  @HiveField(14)
  late String issueBatchMethod;

  @HiveField(15)
  late String systemAdminID;

  @HiveField(16)
  late String notes;

  @HiveField(17)
  late dynamic priceDec;

  @HiveField(18)
  late dynamic amntDec;

  @HiveField(19)
  late dynamic qtyDec;

  @HiveField(20)
  late String roundMethod;

  @HiveField(21)
  late String importMethod;

  @HiveField(22)
  late TimeOfDay time;


  Companies({
    required this.cmpCode,
    required this.cmpName,
    required this.cmpFName,
    required this.tel,
    required this.mobile,
    required this.address,
    required this.fAddress,
    required this.prHeader,
    required this.prFHeader,
    required this.prFooter,
    required this.prFFooter,
    required this.mainCurCode,
    required this.secCurCode,
    required this.rateType,
    required this.issueBatchMethod,
    required this.systemAdminID,
    required this.notes,
    required this.priceDec,
    required this.amntDec,
    required this.qtyDec,
    required this.roundMethod,
    required this.importMethod,
    required this.time
  });

    Map<String, dynamic> toJson() {
    return {
      'cmpCode': cmpCode,
      'cmpName': cmpName,
      'cmpFName': cmpFName,
      'tel': tel,
      'mobile': mobile,
      'address': address,
      'fAddress': fAddress,
      'prHeader': prHeader,
      'prFHeader': prFHeader,
      'prFooter': prFooter,
      'prFFooter': prFFooter,
      'mainCurCode': mainCurCode,
      'secCurCode': secCurCode,
      'rateType': rateType,
      'issueBatchMethod': issueBatchMethod,
      'systemAdminID': systemAdminID,
      'notes': notes,
      'priceDec': priceDec,
      'amntDec': amntDec,
      'qtyDec': qtyDec,
      'rounding': roundMethod,
      'importMethod': importMethod,
      'time': time



    };
  }


}
