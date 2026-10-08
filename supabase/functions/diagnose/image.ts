// Kontrola fotky pro diagnostiku (FR-V1): jen JPEG, rozumná velikost
// a bez metadat (EXIF s GPS odstraní aplikace, server to jen ověří).

/** Nejvyšší velikost fotky po dekódování (aplikace posílá ~1600 px). */
export const MAX_IMAGE_BYTES = 3 * 1024 * 1024;

/** Dekóduje base64; při chybě nebo překročení velikosti vrátí null. */
export function decodeImage(data: unknown): Uint8Array | null {
  if (typeof data !== "string" || data.length === 0) return null;
  if (data.length > Math.ceil(MAX_IMAGE_BYTES / 3) * 4) return null;
  try {
    const bin = atob(data);
    const bytes = new Uint8Array(bin.length);
    for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
    return bytes;
  } catch {
    return null;
  }
}

export function isJpeg(bytes: Uint8Array): boolean {
  return bytes.length > 4 && bytes[0] === 0xff && bytes[1] === 0xd8 && bytes[2] === 0xff;
}

/**
 * Má JPEG segment s metadaty (APP1 = EXIF/XMP, APP13 = IPTC, COM)?
 * Prochází hlavičky až po začátek obrazových dat (SOS).
 */
export function hasJpegMetadata(bytes: Uint8Array): boolean {
  let i = 2;
  while (i + 4 <= bytes.length) {
    if (bytes[i] !== 0xff) return false;
    const marker = bytes[i + 1];
    if (marker === 0xff) {
      i++;
      continue;
    }
    if (marker === 0xda || marker === 0xd9) return false;
    if (marker >= 0xd0 && marker <= 0xd7) {
      i += 2;
      continue;
    }
    if (marker === 0xe1 || marker === 0xed || marker === 0xfe) return true;
    const length = (bytes[i + 2] << 8) | bytes[i + 3];
    if (length < 2) return false;
    i += 2 + length;
  }
  return false;
}
