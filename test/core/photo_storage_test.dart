import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:zahradnik_boda_mvp01/core/photos/photo_storage.dart';

void main() {
  late Directory dir;
  late String root;
  late PhotoStorage photos;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('boda_photos');
    root = p.join(dir.path, 'docs');
    photos = PhotoStorage(root);
  });

  tearDown(() => dir.delete(recursive: true));

  File tempPhoto(String name) => File(p.join(dir.path, 'cache', name))
    ..createSync(recursive: true)
    ..writeAsBytesSync([7, 7, 7]);

  test('persist copies the photo and returns a relative path', () async {
    final stored = await photos.persist(XFile(tempPhoto('a.jpg').path));

    expect(p.isRelative(stored), isTrue);
    expect(File(photos.resolve(stored)!).readAsBytesSync(), [7, 7, 7]);
  });

  test(
    'absolute path from an old app container falls back to the current folder',
    () async {
      // Na iOS se po aktualizaci změní cesta ke složce aplikace.
      final stored = await photos.persist(XFile(tempPhoto('b.jpg').path));
      final oldAbsolute = p.join('/old/container/Documents', stored);

      expect(photos.resolve(oldAbsolute), p.join(root, stored));
    },
  );

  test('delete removes only photos inside the app folder', () async {
    final stored = await photos.persist(XFile(tempPhoto('c.jpg').path));
    final outside = tempPhoto('d.jpg');

    await photos.delete(stored);
    await photos.delete(outside.path);

    expect(File(p.join(root, stored)).existsSync(), isFalse);
    expect(outside.existsSync(), isTrue);
  });

  test('resolve returns null for no photo', () {
    expect(photos.resolve(null), isNull);
    expect(photos.resolve(''), isNull);
  });
}
