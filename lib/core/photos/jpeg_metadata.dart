import 'dart:typed_data';

/// Odstraní z JPEG metadata (FR-V1): APP1 (EXIF včetně GPS, XMP), APP13
/// (IPTC), komentáře a ostatní aplikační segmenty kromě APP0 (JFIF),
/// APP2 (barevný profil) a APP14 (Adobe, barevný prostor). Obrazová data
/// zůstanou beze změny. Vrací null, když to není čitelný JPEG.
Uint8List? stripJpegMetadata(Uint8List bytes) {
  if (bytes.length < 4 || bytes[0] != 0xff || bytes[1] != 0xd8) return null;
  final out = BytesBuilder(copy: false)..add(const [0xff, 0xd8]);
  var i = 2;
  while (i + 4 <= bytes.length) {
    if (bytes[i] != 0xff) return null;
    final marker = bytes[i + 1];
    if (marker == 0xff) {
      i++;
      continue;
    }
    // Začátek obrazových dat: zbytek souboru se zkopíruje celý.
    if (marker == 0xda) {
      out.add(Uint8List.sublistView(bytes, i));
      return out.takeBytes();
    }
    if (marker == 0xd9) break;
    final length = (bytes[i + 2] << 8) | bytes[i + 3];
    if (length < 2 || i + 2 + length > bytes.length) return null;
    final isApp = marker >= 0xe0 && marker <= 0xef;
    final keep =
        marker != 0xfe &&
        (!isApp || marker == 0xe0 || marker == 0xe2 || marker == 0xee);
    if (keep) out.add(Uint8List.sublistView(bytes, i, i + 2 + length));
    i += 2 + length;
  }
  return null;
}
