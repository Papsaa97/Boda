import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

/// Ukládá fotky k záznamům do složky aplikace.
///
/// Image picker vrací cestu do dočasné cache, kterou systém může kdykoli
/// smazat. Proto si fotku zkopírujeme do dokumentů aplikace.
///
/// V záznamu se drží jen **relativní** cesta (`activity_photos/…`).
/// Na iOS se absolutní cesta ke složce aplikace mění s každou aktualizací,
/// takže absolutní cesta by po updatu přestala platit. Plnou cestu
/// skládá až [resolve] při zobrazení.
class PhotoStorage {
  PhotoStorage(this.rootPath);

  /// Kořen úložiště, typicky složka dokumentů aplikace.
  final String rootPath;

  static const folder = 'activity_photos';

  String get _folderPath => p.join(rootPath, folder);

  Future<Directory> _ensureFolder() async {
    final dir = Directory(_folderPath);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String _newName(String sourcePath) {
    final ext = p.extension(sourcePath).isEmpty
        ? '.jpg'
        : p.extension(sourcePath);
    return '${DateTime.now().microsecondsSinceEpoch}$ext';
  }

  /// Zkopíruje vybranou fotku do složky aplikace a vrátí relativní cestu.
  Future<String> persist(XFile picked) async {
    await _ensureFolder();
    final relative = p.join(folder, _newName(picked.path));
    await picked.saveTo(p.join(rootPath, relative));
    return relative;
  }

  /// Plná cesta k uložené fotce, nebo null, když fotka není.
  ///
  /// Starší záznamy mají absolutní cestu. Když už neplatí (iOS po
  /// aktualizaci), zkusí se stejný soubor v dnešní složce aplikace.
  String? resolve(String? stored) {
    if (stored == null || stored.isEmpty) return null;
    if (!p.isAbsolute(stored)) return p.join(rootPath, stored);
    if (File(stored).existsSync()) return stored;
    final moved = p.join(_folderPath, p.basename(stored));
    return File(moved).existsSync() ? moved : stored;
  }

  /// Smaže fotku, pokud leží ve složce aplikace. Cizí soubory nechává být.
  Future<void> delete(String? stored) async {
    final path = resolve(stored);
    if (path == null || !p.isWithin(_folderPath, path)) return;
    final file = File(path);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  /// Převede uloženou cestu na relativní, je-li to možné.
  ///
  /// Fotka mimo složku aplikace (např. v cache z verze 0.1) se do ní
  /// zkopíruje, aby ji systém nemohl smazat. Vrací null, když fotka
  /// neexistuje a nejde ji zachránit; pak se cesta nechá, jak je.
  Future<String?> adopt(String stored) async {
    if (!p.isAbsolute(stored)) return stored;
    final path = resolve(stored)!;
    if (p.isWithin(_folderPath, path)) return p.relative(path, from: rootPath);
    final source = File(path);
    if (!source.existsSync()) return null;
    await _ensureFolder();
    final relative = p.join(folder, _newName(path));
    await source.copy(p.join(rootPath, relative));
    return relative;
  }
}
