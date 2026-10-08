/// Veličina jednotky; převádět jde jen v rámci stejné (FR-S2).
enum Quantity { mass, volume, count, pack }

/// Jednotka množství ve skladu a v nákupním seznamu.
enum InventoryUnit {
  g(Quantity.mass, 1),
  kg(Quantity.mass, 1000),
  ml(Quantity.volume, 1),
  l(Quantity.volume, 1000),
  ks(Quantity.count, 1),
  pack(Quantity.pack, 1);

  const InventoryUnit(this.quantity, this._base);

  final Quantity quantity;

  /// Kolik základních jednotek (g, ml) je jedna tahle jednotka.
  final double _base;

  static InventoryUnit? fromKey(String? key) {
    for (final u in values) {
      if (u.name == key) return u;
    }
    return null;
  }

  /// Jednotky, na které jde tahle převést (včetně sebe).
  List<InventoryUnit> get compatible => [
    for (final u in values)
      if (u.quantity == quantity) u,
  ];

  /// Převede [value] z této jednotky na [to]; null, když jde o jinou
  /// veličinu (kg na litry nejde bez hustoty).
  double? convert(double value, InventoryUnit to) {
    if (to.quantity != quantity) return null;
    return value * _base / to._base;
  }
}
