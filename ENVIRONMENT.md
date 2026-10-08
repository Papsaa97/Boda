# ENVIRONMENT

| Nástroj | Verze |
| --- | --- |
| Flutter | 3.47.6 (stable) |
| Dart | 3.13.5 |

Ověřeno: `flutter analyze` bez nálezů, `flutter test` zelený, `flutter build web` projde.

## Platformy
* **Android / iOS** – plná funkčnost včetně fotek. iOS má v `Info.plist` popisky oprávnění pro fotoaparát a galerii.
* **Web** – deník, zóny a dashboard fungují (Hive ukládá do IndexedDB), fotky jsou vypnuté.

## CI
GitHub Actions (`.github/workflows/ci.yml`) na každý push a PR spustí `flutter analyze` a `flutter test`.
