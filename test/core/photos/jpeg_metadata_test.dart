import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:zahradnik_boda/core/photos/jpeg_metadata.dart';

/// Segment JPEG: značka a data s délkou.
List<int> segment(int marker, List<int> data) => [
  0xff,
  marker,
  (data.length + 2) >> 8,
  (data.length + 2) & 0xff,
  ...data,
];

final exif = segment(0xe1, [0x45, 0x78, 0x69, 0x66, 0, 0, 1, 2, 3]);
final jfif = segment(0xe0, [0x4a, 0x46, 0x49, 0x46, 0]);
final icc = segment(0xe2, [1, 2]);
final iptc = segment(0xed, [9, 9]);
final comment = segment(0xfe, [0x41]);
final quant = segment(0xdb, [0, 1, 2]);
const scan = [0xff, 0xda, 0x00, 0x02, 0x11, 0x22, 0xff, 0x00, 0x33, 0xff, 0xd9];

Uint8List jpeg(List<List<int>> segments) =>
    Uint8List.fromList([0xff, 0xd8, for (final s in segments) ...s, ...scan]);

void main() {
  test('removes EXIF, IPTC and comments, keeps image data', () {
    final stripped = stripJpegMetadata(
      jpeg([jfif, exif, icc, iptc, comment, quant]),
    );
    expect(stripped, jpeg([jfif, icc, quant]));
  });

  test('a clean JPEG stays the same', () {
    final clean = jpeg([jfif, quant]);
    expect(stripJpegMetadata(clean), clean);
  });

  test('not a JPEG or truncated = null', () {
    expect(stripJpegMetadata(Uint8List.fromList([0x89, 0x50, 0x4e])), isNull);
    expect(
      stripJpegMetadata(Uint8List.fromList([0xff, 0xd8, 0xff, 0xe1, 0x00])),
      isNull,
    );
    expect(
      stripJpegMetadata(Uint8List.fromList([0xff, 0xd8, 0xff, 0xe1, 0x40, 0])),
      isNull,
    );
  });
}
