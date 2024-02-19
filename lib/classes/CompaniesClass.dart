import 'dart:async';

import 'package:flutter/material.dart';

class CompaniesClass {
  final String cmpCode;
  final String cmpName;
  final String cmpFName;
  final String tel;
  final String mobile;
  final String address;
  final String fAddress;
  final String prHeader;
  final String prFHeader;
  final String prFFooter;
  final String mainCurCode;
  final String secCurCode;
  final String issueBatchMethod;
  final String systemAdminID;
  final String notes;
  final double priceDec;
  final double amntDec;
  final double qtyDec;
  final String rounding;
  final String importMethod;
  final TimeOfDay? time;
  CompaniesClass({required this.cmpCode,required this.cmpName, required this.cmpFName,required this.tel,required this.mobile, required this.address,required this.fAddress , required this.prHeader, required this.prFHeader, required this.prFFooter, required this.mainCurCode, required this.secCurCode,required this.issueBatchMethod,required this.systemAdminID,required this.notes,required this.priceDec, required this.amntDec, required this.qtyDec , required this.rounding,required this.importMethod,required this.time});
}
