class UserPreferences {
  bool showActive = true;
  bool showWeight = true;
  bool showItemType = true;
 // bool showItemName = true;
  bool showGroupCode = true;
  Map<String, String> fieldValues = {};

  List<String> getSelectedFields() {
    List<String> selectedFields = [];
    if (showActive) selectedFields.add('Active');
    if (showWeight) selectedFields.add('Weight');
    if (showItemType) selectedFields.add('ItemType');
    //if (showItemName) selectedFields.add('ItemName');
    if (showGroupCode) selectedFields.add('GroupCode');
    return selectedFields;
  }


  bool showActiveCustomers = true;
  bool showDiscTypeCustomers = true;
  bool showCurCodeCustomers = true;
  bool showMOFNumCustomers = true;

List<String> getSelectedFieldsCust() {
    List<String> selectedFields = [];
    if (showActiveCustomers) selectedFields.add('Active');
    if (showDiscTypeCustomers) selectedFields.add('DiscType');
    if (showCurCodeCustomers) selectedFields.add('CurCode');
    if (showMOFNumCustomers) selectedFields.add('MOFNum');
    return selectedFields;
  }


  bool showAddressIdCustMap=false;
   bool showAddressCustMap=false;
     bool showregCodeCustMap=false;
   
List<String> getSelectedFieldsCustMap() {
    List<String> selectedFields = [];
    if (showAddressIdCustMap) selectedFields.add('AddressId');
    if (showAddressCustMap) selectedFields.add('Address');
    if (showregCodeCustMap) selectedFields.add('RegCode');
    return selectedFields;
  }


     bool showBarcode=false;
   bool showWarehouse=false;
     bool showOutQuantity=false;
   
List<String> getSelectedFieldsItemReceive() {
    List<String> selectedFields = [];
    if (showBarcode) selectedFields.add('barcode');
    if (showWarehouse) selectedFields.add('warehouse');
    if (showOutQuantity) selectedFields.add('outquantity');
    return selectedFields;
  }

}
