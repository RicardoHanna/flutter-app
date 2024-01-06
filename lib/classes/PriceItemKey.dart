class PriceItemKey {
  final String plCode;
  final String itemCode;

  PriceItemKey(this.plCode, this.itemCode);

  @override
  int get hashCode => plCode.hashCode ^ itemCode.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriceItemKey &&
          runtimeType == other.runtimeType &&
          plCode == other.plCode &&
          itemCode == other.itemCode;
}
