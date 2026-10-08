# Značka

Zdrojové soubory ikony a úvodní obrazovky (SVG). Barvy jsou z
`lib/core/theme/app_theme.dart`: tyrkysová `#0F766E` / `#14B8A6`, pozadí
`#F8FAFC` (světlý) a `#020617` (tmavý).

| Soubor | Kde se používá |
| --- | --- |
| `icon.svg`, `icon-1024.png` | ikona aplikace (Android `mipmap-*/ic_launcher.png`, iOS `AppIcon.appiconset`, web `icons/`), obchody chtějí 512×512 (Google Play) a 1024×1024 (App Store) |
| `icon_foreground.svg` | popředí adaptivní ikony Androidu (`mipmap-*/ic_launcher_foreground.png`), pozadí je barva `ic_launcher_background` |
| `splash_light.svg`, `splash_dark.svg` | lístek na úvodní obrazovce (Android `drawable-*/splash_logo.png` a `drawable-night-*`, iOS `LaunchImage.imageset`) |

Rastry se z SVG dělají ve velikostech, které platformy chtějí (Android
48/72/96/144/192 px, popředí ×108/48, splash 160 dp; iOS podle
`Contents.json`; web 192 a 512 px). Při změně značky stačí přegenerovat
tyhle PNG, kód se nemění.
