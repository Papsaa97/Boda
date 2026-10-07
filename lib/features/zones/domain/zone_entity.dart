import 'package:equatable/equatable.dart';

/// Zóna zahrady, ke které se váže záznam v deníku.
///
/// V MVP 0.1 je zóna jen pojmenovaná položka seznamu. Geometrie, pH,
/// půda a oslunění přijdou s 2D plátnem v MVP 1.0.
class ZoneEntity extends Equatable {
  final String id;
  final String name;

  const ZoneEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

/// Výchozí zóny pro novou zahradu.
///
/// Id Z1–Z3 odpovídají zónám, které byly v předchozí verzi formuláře
/// napevno, takže dřívější záznamy se na ně namapují.
const defaultZones = <ZoneEntity>[
  ZoneEntity(id: 'Z1', name: 'Zelenina'),
  ZoneEntity(id: 'Z2', name: 'Okrasná zahrada'),
  ZoneEntity(id: 'Z3', name: 'Ovocný sad'),
  ZoneEntity(id: 'Z4', name: 'Trávník'),
  ZoneEntity(id: 'Z5', name: 'Skleník'),
];
