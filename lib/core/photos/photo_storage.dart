import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Ukládá fotky k záznamům do složky aplikace.
///
/// Image picker vrací cestu do dočasné cache, kterou systém může kdykoli
/// smazat. Proto si fotku zkopírujeme do dokumentů aplikace a v deníku
/// držíme cestu na tuto kopii.
class PhotoStorage {
  static const _folder = 'activity_photos';

  Future<Directory> _photosDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, _folder));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Zkopíruje vybranou fotku do složky aplikace a vrátí novou cestu.
  Future<String> persist(XFile picked) async {
    final dir = await _photosDir();
    final ext = p.extension(picked.path).isEmpty ? '.jpg' : p.extension(picked.path);
    final target = p.join(dir.path, '${DateTime.now().microsecondsSinceEpoch}$ext');
    await picked.saveTo(target);
    return target;
  }

  /// Smaže fotku, pokud leží ve složce aplikace. Cizí soubory nechává být.
  Future<void> delete(String? path) async {
    if (path == null || path.isEmpty) return;
    final dir = await _photosDir();
    if (!p.isWithin(dir.path, path)) return;
    final file = File(path);
    if (file.existsSync()) {
      await file.delete();
    }
  }
}
