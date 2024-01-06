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


}
