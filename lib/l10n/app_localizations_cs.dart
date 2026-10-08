// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get appTitle => 'Zahradník Bóďa';

  @override
  String get commonCancel => 'Zrušit';

  @override
  String get commonSave => 'Uložit';

  @override
  String get commonDelete => 'Smazat';

  @override
  String get commonBack => 'Zpět';

  @override
  String get commonEdit => 'Upravit';

  @override
  String get commonClose => 'Zavřít';

  @override
  String get commonContinue => 'Pokračovat';

  @override
  String get commonUnknownZone => 'Neznámá zóna';

  @override
  String commonErrorWithDetail(Object error) {
    return 'Chyba: $error';
  }

  @override
  String zonesLoadError(Object error) {
    return 'Chyba při načítání zón: $error';
  }

  @override
  String get navToday => 'Dnes';

  @override
  String get navDiary => 'Deník';

  @override
  String get navTasks => 'Úkoly';

  @override
  String get navZones => 'Zóny';

  @override
  String get newActivityTooltip => 'Nový záznam';

  @override
  String get newTaskTooltip => 'Nový úkol';

  @override
  String get relativeToday => 'dnes';

  @override
  String get relativeYesterday => 'včera';

  @override
  String relativeDaysAgo(int days) {
    return 'před $days dny';
  }

  @override
  String get dayHeaderToday => 'Dnes';

  @override
  String get dayHeaderYesterday => 'Včera';

  @override
  String get dayHeaderTomorrow => 'Zítra';

  @override
  String get onboardingZonesTitle => 'Co pěstuješ?';

  @override
  String get onboardingZonesBody =>
      'Vyber, co máš na zahradě. Z toho budou zóny, ke kterým budeš zapisovat práci. Upravit je můžeš kdykoli.';

  @override
  String get onboardingPickAtLeastOne => 'Vyber aspoň jednu';

  @override
  String get onboardingFinish => 'Jdeme na zahradu';

  @override
  String get onboardingSaveFailed =>
      'Zóny se nepodařilo uložit, zkus to znovu.';

  @override
  String get onboardingSkip => 'Přeskočit';

  @override
  String get activityTypeSowing => 'Výsev';

  @override
  String get activityTypePlanting => 'Výsadba';

  @override
  String get activityTypeWatering => 'Zálivka';

  @override
  String get activityTypeFertilizing => 'Hnojení';

  @override
  String get activityTypeSpraying => 'Postřik';

  @override
  String get activityTypePruning => 'Řez';

  @override
  String get activityTypeHarvest => 'Sklizeň';

  @override
  String get activityTypeWeeding => 'Pletí';

  @override
  String get activityTypeMowing => 'Sekání';

  @override
  String get activityTypeOther => 'Jiné';

  @override
  String get activityHasNote => 'Má poznámku';

  @override
  String get activityNewTitle => 'Nový záznam';

  @override
  String get activityEditTitle => 'Upravit záznam';

  @override
  String get activityDetailTitle => 'Záznam';

  @override
  String get activityTypeLabel => 'Co jsi dělal?';

  @override
  String get activityTitleLabel => 'Název aktivity';

  @override
  String get activityTitleHint => 'např. Zálivka rajčat';

  @override
  String get activityTitleRequired => 'Zadej název aktivity';

  @override
  String get activityDateLabel => 'Datum a čas';

  @override
  String get activityZoneLabel => 'Zóna';

  @override
  String get activityZoneRequired => 'Vyber zónu';

  @override
  String get activityNotesLabel => 'Poznámka (volitelné)';

  @override
  String get activitySaveNew => 'Uložit záznam';

  @override
  String get activitySaveChanges => 'Uložit změny';

  @override
  String get activitySaveFailed => 'Záznam se nepodařilo uložit.';

  @override
  String get activityDeleteTitle => 'Smazat záznam?';

  @override
  String get activityDeleteBody => 'Záznam i jeho fotky zmizí z deníku.';

  @override
  String get activityDeleteFailed => 'Záznam se nepodařilo smazat.';

  @override
  String get activityGone => 'Záznam už neexistuje.';

  @override
  String get photoTake => 'Vyfotit';

  @override
  String get photoFromGallery => 'Vybrat z galerie';

  @override
  String get photoRemove => 'Odebrat fotku';

  @override
  String get photoSaveFailed => 'Fotku se nepodařilo uložit.';

  @override
  String photoAdd(int count, int max) {
    return 'Přidat fotku ($count/$max)';
  }

  @override
  String photoLimitReached(int max) {
    return 'Víc než $max fotek k záznamu nejde';
  }

  @override
  String get timelineSearch => 'Hledat v deníku';

  @override
  String get timelineSearchClose => 'Zavřít hledání';

  @override
  String get timelineSearchHint => 'Hledat v názvu a poznámce';

  @override
  String timelineLoadError(Object error) {
    return 'Chyba při načítání deníku: $error';
  }

  @override
  String get timelineEmptyTitle => 'Zatím žádné záznamy';

  @override
  String get timelineEmptyBody =>
      'Zapiš první práci na zahradě tlačítkem dole.';

  @override
  String get filterAllZones => 'Všechny zóny';

  @override
  String get filterAllTypes => 'Všechny práce';

  @override
  String filterResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count záznamů',
      few: '$count záznamy',
      one: '1 záznam',
      zero: 'Nic nenalezeno',
    );
    return '$_temp0';
  }

  @override
  String get filterNoMatch => 'Tomuhle filtru nic neodpovídá.';

  @override
  String get photoSemantic => 'Fotka záznamu';

  @override
  String photoSemanticOf(String title) {
    return 'Fotka záznamu $title';
  }

  @override
  String photoViewerTitle(String title, int index, int count) {
    return '$title ($index/$count)';
  }

  @override
  String get activityDiscardTitle => 'Zahodit změny?';

  @override
  String get activityDiscardBody => 'Záznam není uložený.';

  @override
  String get activityDiscardKeepEditing => 'Pokračovat v úpravách';

  @override
  String get activityDiscardConfirm => 'Zahodit';

  @override
  String get photoOpenFullscreen => 'Zobrazit fotku přes celou obrazovku';

  @override
  String get zoneNewTitle => 'Nová zóna';

  @override
  String get zoneRenameTitle => 'Přejmenovat zónu';

  @override
  String get zoneNameHint => 'např. Záhon u plotu';

  @override
  String get zoneSaveFailed => 'Změnu zón se nepodařilo uložit.';

  @override
  String get zoneCannotDeleteTitle => 'Zónu nejde smazat';

  @override
  String zoneCannotDeleteBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count záznamů',
      few: '$count záznamy',
      one: '1 záznam',
    );
    return '$name má v deníku $_temp0. Můžeš ji archivovat: nebude se nabízet pro nové záznamy, ale záznamy zůstanou.';
  }

  @override
  String get zoneArchive => 'Archivovat';

  @override
  String get zoneUnarchive => 'Vrátit z archivu';

  @override
  String get zoneDelete => 'Smazat zónu';

  @override
  String get zoneKeepOne => 'Aspoň jedna zóna musí zůstat.';

  @override
  String get zoneArchivedSection => 'Archivované';

  @override
  String zoneActivityCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count záznamů',
      few: '$count záznamy',
      one: '1 záznam',
      zero: 'Zatím bez záznamů',
    );
    return '$_temp0';
  }

  @override
  String get zoneTypeVegetable => 'Zelenina';

  @override
  String get zoneTypeHerbs => 'Bylinky';

  @override
  String get zoneTypeFruit => 'Ovocný sad';

  @override
  String get zoneTypeOrnamental => 'Okrasná zahrada';

  @override
  String get zoneTypeLawn => 'Trávník';

  @override
  String get zoneTypeGreenhouse => 'Skleník';

  @override
  String get zoneTypePond => 'Jezírko';

  @override
  String get zoneTypeStructure => 'Stavba';

  @override
  String get zoneTypeOther => 'Jiné';

  @override
  String get zoneTypeLabel => 'Druh zóny';

  @override
  String get zoneNameEmpty => 'Zadej název zóny';

  @override
  String get zoneNameDuplicate => 'Zóna s tímhle názvem už existuje';

  @override
  String get zoneTitle => 'Zóny';

  @override
  String get zoneArchiveKeepOne => 'Poslední aktivní zónu nejde archivovat.';

  @override
  String zoneMoreActions(String name) {
    return 'Další akce pro $name';
  }

  @override
  String get zoneArchived => 'Archivováno';

  @override
  String zoneDeleted(String name) {
    return 'Zóna $name smazána';
  }

  @override
  String get dashboardTitle => 'Co dnes?';

  @override
  String dashboardLastWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'záznamů za 7 dní',
      few: 'záznamy za 7 dní',
      one: 'záznam za 7 dní',
    );
    return '$_temp0';
  }

  @override
  String get dashboardLastEntry => 'poslední záznam';

  @override
  String dashboardHeroToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dnes máš zapsáno $count záznamů',
      few: 'Dnes máš zapsané $count záznamy',
      one: 'Dnes máš zapsaný 1 záznam',
    );
    return '$_temp0';
  }

  @override
  String get dashboardHeroTodayBody => 'Dobrá práce. Zahrada ti to vrátí.';

  @override
  String get dashboardHeroNothing => 'Dnes zatím nic';

  @override
  String dashboardHeroZoneEmpty(String zone) {
    return 'V zóně $zone ještě nemáš žádný záznam. Co se tam teď děje?';
  }

  @override
  String dashboardHeroZoneStale(String zone, String when) {
    return 'Poslední záznam v zóně $zone je $when. Mrkni, jak se jí daří.';
  }

  @override
  String get dashboardHeroAllFresh =>
      'Všechny zóny máš za poslední týden zapsané. Co dnes uděláš?';

  @override
  String get dashboardLogActivity => 'Zapsat aktivitu';

  @override
  String get dashboardTip => 'Tip od Bódi';

  @override
  String get dashboardAttention => 'Zaslouží pozornost';

  @override
  String get dashboardZoneNoEntry => 'zatím bez záznamu';

  @override
  String dashboardZoneLast(String when) {
    return 'naposledy $when';
  }

  @override
  String dashboardTodayTasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dnes je na řadě $count úkolů',
      few: 'Dnes jsou na řadě $count úkoly',
      one: 'Dnes je na řadě 1 úkol',
    );
    return '$_temp0';
  }

  @override
  String get dashboardAllTasks => 'Všechny úkoly';

  @override
  String get backupShareSubject => 'Záloha deníku Zahradník Bóďa';

  @override
  String get backupExportDone => 'Záloha je hotová.';

  @override
  String get backupExportFailed => 'Zálohu se nepodařilo vytvořit.';

  @override
  String get backupImportConfirmTitle => 'Nahradit všechna data?';

  @override
  String backupImportConfirmBody(int activities, int tasks, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      activities,
      locale: localeName,
      other: '$activities záznamů',
      few: '$activities záznamy',
      one: '1 záznam',
    );
    String _temp1 = intl.Intl.pluralLogic(
      tasks,
      locale: localeName,
      other: '$tasks úkolů',
      few: '$tasks úkoly',
      one: '1 úkol',
    );
    String _temp2 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos fotek',
      few: '$photos fotky',
      one: '1 fotku',
    );
    return 'Záloha obsahuje $_temp0, $_temp1 a $_temp2. Všechno, co teď v aplikaci máš, se smaže a nahradí obsahem zálohy.';
  }

  @override
  String get backupImportConfirm => 'Nahradit';

  @override
  String get backupImportDone => 'Data ze zálohy jsou obnovená.';

  @override
  String get backupImportFailed =>
      'Obnova se nepovedla, data zůstala beze změny.';

  @override
  String get backupErrorNotABackup => 'Tohle není záloha ze Zahradníka Bódi.';

  @override
  String get backupErrorCorrupted => 'Záloha je poškozená a nejde načíst.';

  @override
  String get backupErrorTooNew =>
      'Záloha je z novější verze aplikace. Nejdřív si aplikaci aktualizuj.';

  @override
  String get backupReminderTitle => 'Zálohuj si deník';

  @override
  String get backupReminderBody =>
      'Data jsou jen v tomhle telefonu. Záloha zabere chvilku a uložíš ji třeba na Disk nebo do e-mailu.';

  @override
  String get backupReminderAction => 'Zálohovat';

  @override
  String get backupExport => 'Exportovat zálohu';

  @override
  String get backupExportSubtitleNever => 'Zatím žádná záloha';

  @override
  String backupExportSubtitle(String date) {
    return 'Naposledy $date';
  }

  @override
  String get backupImport => 'Obnovit ze zálohy';

  @override
  String get backupImportSubtitle => 'Nahradí všechna data obsahem ZIP souboru';

  @override
  String get backupUnavailableWeb =>
      'Záloha je dostupná v aplikaci pro Android a iOS.';

  @override
  String get settingsTitle => 'Nastavení';

  @override
  String get settingsTooltip => 'Nastavení';

  @override
  String get settingsAppearance => 'Vzhled';

  @override
  String get settingsThemeSystem => 'Podle systému';

  @override
  String get settingsThemeLight => 'Světlý';

  @override
  String get settingsThemeDark => 'Tmavý';

  @override
  String get settingsNotifications => 'Připomínky';

  @override
  String get settingsQuietStart => 'Tiché hodiny od';

  @override
  String get settingsQuietEnd => 'Tiché hodiny do';

  @override
  String get settingsQuietHelp =>
      'V tichých hodinách žádná připomínka nepřijde. Co by na ně připadlo, přijde po jejich konci.';

  @override
  String get settingsDigest => 'Ranní přehled úkolů';

  @override
  String get digestAuto => 'Automaticky';

  @override
  String get digestDaily => 'Denně';

  @override
  String get digestWeekly => 'Týdně';

  @override
  String get digestOff => 'Vypnuto';

  @override
  String get digestAutoHelp => 'Denně, v zimě (listopad až únor) jen v pondělí';

  @override
  String get digestDailyHelp => 'Každé ráno po konci tichých hodin';

  @override
  String get digestWeeklyHelp => 'V pondělí ráno, úkoly na celý týden';

  @override
  String get digestOffHelp => 'Jen připomínky u jednotlivých úkolů';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsAbout => 'O aplikaci';

  @override
  String get settingsPrivacy =>
      'Všechna data zůstávají jen v tomhle zařízení. Aplikace nic neodesílá.';

  @override
  String settingsVersion(String version) {
    return 'Verze $version';
  }

  @override
  String get statsTitle => 'Statistika';

  @override
  String get statsSubtitle => 'Záznamy po týdnech a nejaktivnější zóny';

  @override
  String get statsTotal => 'záznamů celkem';

  @override
  String get statsThisWeek => 'tento týden';

  @override
  String statsActiveWeeks(int weeks) {
    return 'týdnů z $weeks s aspoň 2 záznamy';
  }

  @override
  String get statsPerWeek => 'Záznamy po týdnech';

  @override
  String get statsTopZones => 'Nejaktivnější zóny';

  @override
  String get statsTopTypes => 'Nejčastější práce';

  @override
  String get statsEmpty => 'Zatím žádné záznamy.';

  @override
  String get taskNewTitle => 'Nový úkol';

  @override
  String get taskEditTitle => 'Upravit úkol';

  @override
  String get taskTitleLabel => 'Co je potřeba udělat';

  @override
  String get taskTitleHint => 'např. Postříkat broskvoň';

  @override
  String get taskTitleRequired => 'Zadej, co je potřeba udělat';

  @override
  String get taskDueLabel => 'Termín';

  @override
  String get taskReminderLabel => 'Připomenout';

  @override
  String taskReminderAt(String time) {
    return 'V $time';
  }

  @override
  String get taskReminderOff => 'Jen v ranním přehledu';

  @override
  String get taskReminderChange => 'Změnit čas';

  @override
  String get taskZoneLabel => 'Zóna';

  @override
  String get taskNoZone => 'Bez zóny';

  @override
  String get taskRepeatLabel => 'Opakovat';

  @override
  String get taskRepeatMonthsLabel => 'Jen v měsících (nic = celý rok)';

  @override
  String get taskNotesLabel => 'Poznámka (volitelné)';

  @override
  String get taskSaveNew => 'Uložit úkol';

  @override
  String get taskSaveFailed => 'Úkol se nepodařilo uložit.';

  @override
  String get taskDeleteTitle => 'Smazat úkol?';

  @override
  String get taskMarkDone => 'Označit jako hotové';

  @override
  String get taskMoreActions => 'Další akce';

  @override
  String get taskSkip => 'Přeskočit';

  @override
  String get taskReopen => 'Vrátit mezi otevřené';

  @override
  String get taskStatusDone => 'Hotovo';

  @override
  String get taskStatusSkipped => 'Přeskočeno';

  @override
  String taskDoneSnack(String title) {
    return 'Hotovo: $title';
  }

  @override
  String taskDoneRecurringSnack(String title, String date) {
    return 'Hotovo: $title. Příště $date.';
  }

  @override
  String get taskLogToDiary => 'Zapsat do deníku';

  @override
  String get repeatNone => 'Neopakovat';

  @override
  String get repeatWeekly => 'Každý týden';

  @override
  String get repeatMonthly => 'Každý měsíc';

  @override
  String get repeatYearly => 'Každý rok';

  @override
  String repeatInMonths(String base, String months) {
    return '$base ($months)';
  }

  @override
  String get snoozeOneDay => 'Odložit o den';

  @override
  String get snoozeWeekend => 'Odložit na víkend';

  @override
  String get snoozeOneWeek => 'Odložit o týden';

  @override
  String get tasksOverdue => 'Po termínu';

  @override
  String get tasksNext7Days => 'Příštích 7 dní';

  @override
  String get tasksLater => 'Později';

  @override
  String tasksClosedSection(int count) {
    return 'Hotové a přeskočené ($count)';
  }

  @override
  String get tasksPrevWeek => 'Předchozí týden';

  @override
  String get tasksNextWeek => 'Další týden';

  @override
  String tasksDaySemantics(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count úkolů',
      few: '$count úkoly',
      one: '1 úkol',
      zero: 'žádný úkol',
    );
    return '$date, $_temp0';
  }

  @override
  String get tasksNoneThatDay => 'Na tenhle den nic není.';

  @override
  String get tasksEmptyTitle => 'Zatím žádné úkoly';

  @override
  String get tasksEmptyBody =>
      'Přidej, co tě na zahradě čeká. Připomenu ti to, ale nikdy v tichých hodinách.';

  @override
  String get notificationChannelName => 'Připomínky úkolů';

  @override
  String get notificationTaskBody => 'Úkol na zahradě je na řadě.';

  @override
  String notificationDigestDailyTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dnes tě čeká $count úkolů',
      few: 'Dnes tě čekají $count úkoly',
      one: 'Dnes tě čeká 1 úkol',
    );
    return '$_temp0';
  }

  @override
  String notificationDigestWeeklyTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tento týden tě čeká $count úkolů',
      few: 'Tento týden tě čekají $count úkoly',
      one: 'Tento týden tě čeká 1 úkol',
    );
    return '$_temp0';
  }

  @override
  String notificationDigestMore(int count) {
    return 'a $count další';
  }

  @override
  String get zoneEditTitle => 'Upravit zónu';

  @override
  String get zoneEdit => 'Upravit';

  @override
  String get zoneNameLabel => 'Název';

  @override
  String get zoneAreaLabel => 'Výměra (m²)';

  @override
  String get zoneAreaHint => 'např. 20';

  @override
  String get zoneAreaHelper => 'Stačí změřit pásmem: délka × šířka.';

  @override
  String get zonePhLabel => 'pH půdy';

  @override
  String get zonePhHint => 'např. 6,5';

  @override
  String get zonePhMeasuredLabel => 'Změřeno';

  @override
  String get zonePhMeasuredNone => 'Kdy jsi pH měřil(a)?';

  @override
  String get zoneSoilLabel => 'Půda';

  @override
  String get zoneSunLabel => 'Oslunění';

  @override
  String get zoneIrrigationLabel => 'Závlaha';

  @override
  String get zoneCoveredLabel => 'Krytá zóna';

  @override
  String get zoneCoveredHelp => 'Skleník nebo fóliovník';

  @override
  String get zoneNotSet => 'Nevyplněno';

  @override
  String get zoneNumberInvalid => 'Zadej číslo, třeba 12,5';

  @override
  String get zoneAreaOutOfRange => 'Výměra musí být mezi 0 a 100 000 m²';

  @override
  String get zonePhOutOfRange => 'pH bývá mezi 3 a 10';

  @override
  String get zoneSoilSandy => 'Písčitá';

  @override
  String get zoneSoilLoamy => 'Hlinitá';

  @override
  String get zoneSoilClay => 'Jílovitá';

  @override
  String get zoneSoilUnknown => 'Nevím';

  @override
  String get zoneSunFull => 'Plné slunce (6 h a víc)';

  @override
  String get zoneSunPartShade => 'Polostín (3–6 h)';

  @override
  String get zoneSunShade => 'Stín (méně než 3 h)';

  @override
  String get zoneIrrigationNone => 'Žádná';

  @override
  String get zoneIrrigationManual => 'Konev nebo hadice';

  @override
  String get zoneIrrigationDrip => 'Kapková';

  @override
  String get zoneIrrigationSprinkler => 'Postřikovač';

  @override
  String get zonePropertiesTitle => 'Vlastnosti';

  @override
  String get zonePropertiesEmpty =>
      'Doplň výměru a půdu. Bóďa pak spočítá dávky přesně pro tuhle zónu.';

  @override
  String zoneAreaValue(String area) {
    return '$area m²';
  }

  @override
  String zonePhValue(String ph) {
    return 'pH $ph';
  }

  @override
  String zonePhValueDated(String ph, String date) {
    return 'pH $ph ($date)';
  }

  @override
  String get zoneRecentActivities => 'Poslední záznamy';

  @override
  String get zoneNoActivities => 'V téhle zóně zatím nic zapsaného.';

  @override
  String get zoneCoveredYes => 'Krytá (skleník, fóliovník)';

  @override
  String get inventoryTitle => 'Sklad';

  @override
  String get inventoryEmptyTitle => 'Sklad je zatím prázdný';

  @override
  String get inventoryEmptyBody =>
      'Zapiš osiva, hnojiva, přípravky a nářadí, co máš doma. Bóďa pak radí s tím, co máš, a hlídá, co dochází.';

  @override
  String get inventoryAdd => 'Přidat do skladu';

  @override
  String get inventoryNewTitle => 'Nová položka';

  @override
  String get inventoryEditTitle => 'Upravit položku';

  @override
  String get inventoryCategoryLabel => 'Kategorie';

  @override
  String get inventoryCategorySeed => 'Osiva';

  @override
  String get inventoryCategoryFertilizer => 'Hnojiva';

  @override
  String get inventoryCategoryPlantProtection => 'Přípravky na ochranu rostlin';

  @override
  String get inventoryCategoryTool => 'Nářadí';

  @override
  String get inventoryCategoryOther => 'Ostatní';

  @override
  String get inventoryNameLabel => 'Název';

  @override
  String get inventoryNameRequired => 'Zadej název';

  @override
  String get inventoryUnitLabel => 'Jednotka';

  @override
  String get inventoryStockLabel => 'Množství doma';

  @override
  String get inventoryThresholdLabel => 'Upozornit, když klesne na';

  @override
  String get inventoryThresholdHelper => 'Nech prázdné, když hlídat nechceš.';

  @override
  String get inventoryUnitG => 'g';

  @override
  String get inventoryUnitKg => 'kg';

  @override
  String get inventoryUnitMl => 'ml';

  @override
  String get inventoryUnitL => 'l';

  @override
  String get inventoryUnitKs => 'ks';

  @override
  String get inventoryUnitPack => 'bal.';

  @override
  String get inventorySpeciesLabel => 'Druh (např. rajče)';

  @override
  String get inventoryVarietyLabel => 'Odrůda';

  @override
  String get inventoryLotLabel => 'Šarže';

  @override
  String get inventoryBestBeforeLabel => 'Spotřebovat do';

  @override
  String get inventoryDateNone => 'Nezadáno';

  @override
  String get inventoryNpkLabel => 'Živiny N-P-K (%)';

  @override
  String get inventoryNLabel => 'N';

  @override
  String get inventoryPLabel => 'P';

  @override
  String get inventoryKLabel => 'K';

  @override
  String get inventoryFormLabel => 'Forma';

  @override
  String get inventoryFormGranular => 'Granule';

  @override
  String get inventoryFormLiquid => 'Tekuté';

  @override
  String get inventoryFormPowder => 'Prášek';

  @override
  String get inventoryFormOrganic => 'Organické';

  @override
  String get inventoryDoseLabel => 'Dávka na 1 m² podle obalu';

  @override
  String get inventoryDoseHelper =>
      'Opiš z obalu. Z tohohle čísla Bóďa počítá množství na zónu.';

  @override
  String get inventoryLabelWarning =>
      'Údaje opiš přesně z etikety. Bóďa doporučí jen přípravek povolený pro neprofesionální uživatele a dávku nikdy neodhaduje.';

  @override
  String get inventoryActiveSubstanceLabel => 'Účinná látka';

  @override
  String get inventoryAuthorizationLabel => 'Číslo povolení';

  @override
  String get inventoryPhiLabel => 'Ochranná lhůta do sklizně (dny)';

  @override
  String get inventoryNonProfessionalLabel =>
      'Povoleno pro neprofesionální uživatele';

  @override
  String get inventoryConditionLabel => 'Stav';

  @override
  String get inventoryConditionGood => 'V pořádku';

  @override
  String get inventoryConditionNeedsService => 'Potřebuje servis';

  @override
  String get inventoryConditionBroken => 'Rozbité';

  @override
  String get inventoryServiceIntervalLabel => 'Servis každých (dní)';

  @override
  String get inventoryLastServiceLabel => 'Poslední servis';

  @override
  String get inventoryNumberInvalid => 'Zadej kladné číslo';

  @override
  String get inventoryDeleteTitle => 'Smazat položku?';

  @override
  String inventoryDeleteBody(String name) {
    return '$name zmizí ze skladu.';
  }

  @override
  String inventoryDeleted(String name) {
    return '$name smazáno';
  }

  @override
  String get inventorySaveFailed => 'Sklad se nepodařilo uložit.';

  @override
  String inventoryStock(String qty, String unit) {
    return '$qty $unit';
  }

  @override
  String inventoryPhi(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dní',
      few: '$count dny',
      one: '1 den',
    );
    return 'ochranná lhůta $_temp0';
  }

  @override
  String inventoryBestBefore(String date) {
    return 'do $date';
  }

  @override
  String get inventoryAlertsTitle => 'Hlídač zásob';

  @override
  String inventoryAlertLowStock(String name, String qty) {
    return '$name: dochází ($qty)';
  }

  @override
  String inventoryAlertSeedExpired(String name, String date) {
    return '$name: osivo je po datu ($date)';
  }

  @override
  String inventoryAlertSeedExpiringSoon(String name, String date) {
    return '$name: osivo vydrží do $date';
  }

  @override
  String inventoryAlertToolService(String name) {
    return '$name: čas na servis';
  }

  @override
  String get inventoryToShoppingList => 'Na nákupní seznam';

  @override
  String inventoryAddedToShopping(String name) {
    return '$name je na nákupním seznamu';
  }

  @override
  String get shoppingTitle => 'Nákupní seznam';

  @override
  String get shoppingEmptyTitle => 'Nic nechybí';

  @override
  String get shoppingEmptyBody =>
      'Sem přidáš, co koupit. Plní ho i Bóďa a hlídač zásob.';

  @override
  String get shoppingAdd => 'Přidat na seznam';

  @override
  String get shoppingNameLabel => 'Co koupit';

  @override
  String get shoppingQtyLabel => 'Množství (nepovinné)';

  @override
  String get shoppingClearDone => 'Smazat koupené';

  @override
  String shoppingRestocked(String name, String qty) {
    return 'Do skladu přidáno: $name +$qty';
  }

  @override
  String get shoppingFromBoda => 'od Bódi';

  @override
  String get shoppingFromLowStock => 'dochází';

  @override
  String shoppingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count položek',
      few: '$count položky',
      one: '1 položka',
      zero: 'prázdný',
    );
    return '$_temp0';
  }

  @override
  String get navGarden => 'Zahrada';

  @override
  String get gardenZonesSection => 'Zóny';

  @override
  String get gardenInventoryCard => 'Sklad';

  @override
  String gardenInventorySummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count položek',
      few: '$count položky',
      one: '1 položka',
      zero: 'Zatím prázdný',
    );
    return '$_temp0';
  }

  @override
  String gardenAlertsSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count upozornění',
      few: '$count upozornění',
      one: '1 upozornění',
    );
    return '$_temp0';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String durationHours(int hours) {
    return '$hours h';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get taskDurationLabel => 'Odhad doby';

  @override
  String get taskDurationNone => 'Neuvedeno';

  @override
  String get taskToolsLabel => 'Nářadí';

  @override
  String get taskToolsHint => 'Přidej nářadí, např. rýč';

  @override
  String get taskToolAdd => 'Přidat nářadí';

  @override
  String taskToolRemove(String name) {
    return 'Odebrat $name';
  }

  @override
  String get taskMaterialsLabel => 'Materiál ze skladu';

  @override
  String get taskMaterialAdd => 'Přidat materiál';

  @override
  String taskMaterialRemove(String name) {
    return 'Odebrat $name';
  }

  @override
  String get taskMaterialItemLabel => 'Položka skladu';

  @override
  String get taskMaterialQtyLabel => 'Množství';

  @override
  String get taskMaterialNoInventory =>
      'Ve skladu zatím nic není. Přidej položky v záložce Zahrada → Sklad.';

  @override
  String taskMaterialQty(String name, String qty) {
    return '$name: $qty';
  }

  @override
  String get taskMaterialMissing => 'Neznámá položka';

  @override
  String get weekendTitle => 'Víkend na chalupě';

  @override
  String get weekendTooltip => 'Víkend na chalupě';

  @override
  String weekendAvailable(int hours) {
    return 'Kolik máš času: $hours h';
  }

  @override
  String weekendSummary(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Stihneš $count úkolů',
      few: 'Stihneš $count úkoly',
      one: 'Stihneš 1 úkol',
      zero: 'Nic se nevejde',
    );
    return '$_temp0 ($time)';
  }

  @override
  String get weekendNothing =>
      'Na příští týden nic otevřeného nemáš. Užij si chalupu.';

  @override
  String get weekendTakeAlong => 'Vezmi s sebou';

  @override
  String get weekendLeftOver => 'Nevejde se';

  @override
  String get weekendEstimated => 'odhad';

  @override
  String get weekendHint =>
      'Úkoly na řadě do týdne, nejdřív zpožděné. Doba bez odhadu se počítá jako 30 min.';

  @override
  String get activityHarvestLabel => 'Sklizeno';

  @override
  String get activityCostLabel => 'Náklady v Kč (nepovinné)';

  @override
  String activityHarvestValue(String qty) {
    return 'Sklizeno $qty';
  }

  @override
  String activityCostValue(String amount) {
    return 'Náklady $amount Kč';
  }

  @override
  String seasonTitle(int year) {
    return 'Tvoje sezóna $year';
  }

  @override
  String get seasonCardBody =>
      'Zima je čas ohlédnout se. Kolik jsi toho letos zapsal(a) a sklidil(a)?';

  @override
  String get seasonCardAction => 'Ukázat sezónu';

  @override
  String get seasonEmpty => 'V tomhle roce zatím nic zapsaného.';

  @override
  String get seasonActivities => 'záznamů';

  @override
  String get seasonActiveDays => 'dní na zahradě';

  @override
  String get seasonHarvestTitle => 'Sklizeň';

  @override
  String get seasonHarvestNone => 'Sklizeň s množstvím zatím nezapsaná.';

  @override
  String get seasonCostTitle => 'Náklady';

  @override
  String get seasonTopZones => 'Nejvíc práce';

  @override
  String get seasonPhotos => 'Fotky sezóny';

  @override
  String get seasonOpen => 'Přehled sezóny';

  @override
  String dashboardInventoryAlerts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hlídač zásob: $count upozornění',
      few: 'Hlídač zásob: $count upozornění',
      one: 'Hlídač zásob: 1 upozornění',
    );
    return '$_temp0';
  }

  @override
  String get navAssistant => 'Bóďa';

  @override
  String get assistantTitle => 'Bóďa';

  @override
  String get assistantNewConversation => 'Nový rozhovor';

  @override
  String get assistantDeleteConversation => 'Smazat rozhovor';

  @override
  String get assistantDeleteConfirmTitle => 'Smazat rozhovor?';

  @override
  String get assistantDeleteConfirmBody =>
      'Dotazy i odpovědi z tohoto rozhovoru zmizí z telefonu.';

  @override
  String get assistantDemoBanner =>
      'Ukázkový režim bez AI. Bóďa zatím jen spočítá dávky z tvých údajů a shrne, co o zahradě ví. Skutečné rady přijdou po přihlášení k účtu.';

  @override
  String get assistantDemoLabel => 'Ukázkový režim';

  @override
  String assistantUsage(int used, int limit) {
    return 'Tento měsíc $used z $limit dotazů';
  }

  @override
  String assistantPendingBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dotazů čeká na připojení',
      few: '$count dotazy čekají na připojení',
      one: '1 dotaz čeká na připojení',
    );
    return '$_temp0';
  }

  @override
  String get assistantSendPending => 'Odeslat';

  @override
  String get assistantEmptyTitle => 'Zeptej se Bódi na svou zahradu';

  @override
  String get assistantEmptyBody =>
      'Bóďa vidí tvé zóny, poslední záznamy, úkoly a sklad. Dávky hnojiv počítá z údajů na obalu a výměry zóny.';

  @override
  String get assistantSuggestionDose => 'Kolik hnojiva dát na zeleninu?';

  @override
  String get assistantSuggestionWeek => 'Co mám tento týden na zahradě udělat?';

  @override
  String get assistantSuggestionStock => 'Co mi dochází ve skladu?';

  @override
  String get assistantInputHint => 'Napiš dotaz…';

  @override
  String get assistantSend => 'Odeslat dotaz';

  @override
  String get assistantThinking => 'Bóďa přemýšlí…';

  @override
  String get assistantStatusPending =>
      'Čeká na připojení. Odešle se, až budeš online.';

  @override
  String get assistantRetry => 'Zkusit znovu';

  @override
  String get assistantFailureNotSignedIn =>
      'Pro dotazy na Bóďu je potřeba se přihlásit k účtu.';

  @override
  String assistantFailureLimit(int limit) {
    return 'Tento měsíc máš vyčerpané dotazy ($limit). Další přibudou 1. dne v měsíci.';
  }

  @override
  String get assistantFailureNotConfigured =>
      'Bóďa teď není dostupný, server nemá dokončené nastavení.';

  @override
  String get assistantFailureUpstream =>
      'Bóďa teď neodpovídá. Zkus to za chvíli.';

  @override
  String get assistantSourcesTitle => 'Z čeho vycházím';

  @override
  String assistantSourcesZones(String zones) {
    return 'Zóny: $zones';
  }

  @override
  String assistantSourcesCounts(int activities, int tasks, int items) {
    return 'Záznamy z deníku: $activities · otevřené úkoly: $tasks · položky skladu: $items';
  }

  @override
  String get assistantSourcesCalculations => 'Výpočty';

  @override
  String get assistantSourcesNone =>
      'Bez výpočtů dávek. Dávku spočítám, když má zóna výměru a hnojivo dávku na m² z obalu.';

  @override
  String assistantCalculationLine(String label, String result, String source) {
    return '$label: $result ($source)';
  }

  @override
  String assistantWarningUnverifiedDose(String text) {
    return 'Číslo $text nepochází z výpočtu ani z etikety. Než ho použiješ, ověř ho na obalu.';
  }

  @override
  String assistantWarningProfessionalOnly(String product) {
    return '$product není povolený pro neprofesionální uživatele. Nepoužívej ho.';
  }

  @override
  String assistantWarningMissingPhi(String product) {
    return 'U přípravku $product chybí ochranná lhůta do sklizně. Najdeš ji na etiketě.';
  }

  @override
  String assistantActionTask(String title) {
    return 'Přidat úkol: $title';
  }

  @override
  String assistantActionShopping(String name) {
    return 'Na nákupní seznam: $name';
  }

  @override
  String assistantActionActivity(String title) {
    return 'Zapsat do deníku: $title';
  }

  @override
  String get assistantActionTaskDone => 'Úkol přidán';

  @override
  String get assistantActionShoppingDone => 'Přidáno na nákupní seznam';

  @override
  String get assistantActionFailed => 'Akci se nepodařilo uložit.';

  @override
  String get assistantFeedbackUp => 'Dobrá odpověď';

  @override
  String get assistantFeedbackDown => 'Špatná odpověď';

  @override
  String get assistantFeedbackCommentTitle => 'Co bylo špatně?';

  @override
  String get assistantFeedbackCommentHint =>
      'Nepovinné. Pomůže to Bóďu zlepšit.';

  @override
  String get assistantFeedbackThanks => 'Díky za zpětnou vazbu.';

  @override
  String get assistantSaveFailed => 'Rozhovor se nepodařilo uložit.';

  @override
  String get accountTitle => 'Účet a synchronizace';

  @override
  String get accountSettingsTile => 'Účet a synchronizace';

  @override
  String get accountSettingsSignedOut =>
      'Bez účtu, data jsou jen v tomto telefonu';

  @override
  String accountSettingsSignedIn(String email) {
    return 'Účet $email';
  }

  @override
  String get accountUnavailable =>
      'Účet v této verzi aplikace zatím není. Všechno funguje i bez něj, data zůstávají v telefonu.';

  @override
  String get accountIntro =>
      'S účtem se zahrada zálohuje do cloudu a jde otevřít i na dalším zařízení. Bóďa s umělou inteligencí účet potřebuje. Bez účtu vše funguje dál jen v tomto telefonu.';

  @override
  String get accountEmailLabel => 'E-mail';

  @override
  String get accountSendCode => 'Poslat kód';

  @override
  String accountCodeSent(String email) {
    return 'Kód jsme poslali na $email. Platí jen chvíli.';
  }

  @override
  String get accountCodeLabel => 'Kód z e-mailu';

  @override
  String get accountVerify => 'Přihlásit';

  @override
  String get accountChangeEmail => 'Jiný e-mail';

  @override
  String get accountErrorEmail => 'Tohle nevypadá jako e-mail.';

  @override
  String get accountErrorCode => 'Kód nesedí nebo už vypršel. Pošli si nový.';

  @override
  String get accountErrorRate => 'Moc pokusů. Zkus to za pár minut.';

  @override
  String get accountErrorOffline => 'Bez připojení. Zkus to, až budeš online.';

  @override
  String get accountErrorUnknown => 'Něco se nepovedlo. Zkus to znovu.';

  @override
  String accountSignedInAs(String email) {
    return 'Účet $email';
  }

  @override
  String get accountSyncNow => 'Synchronizovat teď';

  @override
  String get accountSyncRunning => 'Synchronizuji…';

  @override
  String get accountSyncNever => 'Ještě se nesynchronizovalo.';

  @override
  String accountSyncLast(String time) {
    return 'Naposledy synchronizováno $time';
  }

  @override
  String get accountSyncOffline =>
      'Bez připojení. Změny počkají v telefonu a odešlou se příště.';

  @override
  String get accountSyncFailed =>
      'Synchronizace se nepovedla. Data v telefonu jsou v pořádku, zkusí se to znovu.';

  @override
  String get accountConflictTitle => 'Účet už má jinou zahradu';

  @override
  String get accountConflictBody =>
      'K tomuto účtu patří zahrada z jiného zařízení. Můžeš ji použít i tady; data, která jsou teď v tomto telefonu, se nahradí. Když chceš data z telefonu zachovat, nejdřív si udělej zálohu.';

  @override
  String get accountConflictUse => 'Použít zahradu z účtu';

  @override
  String get accountConflictConfirmTitle => 'Nahradit data v telefonu?';

  @override
  String get accountConflictConfirmBody =>
      'Záznamy, úkoly, zóny a sklad v tomto telefonu se smažou a nahradí zahradou z účtu.';

  @override
  String get accountConflictConfirm => 'Nahradit';

  @override
  String get accountSignOut => 'Odhlásit se';

  @override
  String get accountSignOutBody =>
      'Data zůstanou v telefonu. Změny se do cloudu dostanou po dalším přihlášení.';

  @override
  String get accountDelete => 'Smazat účet';

  @override
  String get accountDeleteTitle => 'Smazat účet?';

  @override
  String get accountDeleteBody =>
      'Smaže se účet a všechna data na serveru: zahrada, fotky v cloudu, rozhovory s Bóďou. Sdílené zahrady přejdou na dalšího člena. Data v tomto telefonu zůstanou. Nejde to vrátit.';

  @override
  String get accountDeleteConfirm => 'Smazat natrvalo';

  @override
  String get accountDeleted => 'Účet je smazaný. Data v telefonu zůstala.';

  @override
  String get assistantDemoBannerSignIn =>
      'Ukázkový režim bez AI. Pro skutečné rady se přihlas v Nastavení, Účet a synchronizace.';

  @override
  String get assistantConsentTitle => 'Než se zeptáš Bódi';

  @override
  String get assistantConsentBody =>
      'Dotaz a vybraná data ze zahrady (zóny, poslední záznamy, úkoly, sklad, spočítané dávky) se pošlou na náš server a odtud jazykovému modelu, který připraví odpověď. Jména, e-maily a fotky se neposílají. Souhlas jde kdykoli odvolat v Nastavení.';

  @override
  String get assistantConsentAgree => 'Souhlasím';

  @override
  String get settingsAiConsent =>
      'Zpracování dotazů na Bóďu umělou inteligencí';

  @override
  String settingsAiConsentOn(String date) {
    return 'Souhlas udělen $date';
  }

  @override
  String get settingsAiConsentOff =>
      'Bez souhlasu (Bóďa odpovídá jen v ukázkovém režimu)';

  @override
  String get onboardingHaveAccount => 'Už mám účet, přihlásit se';

  @override
  String get consentsTitle => 'Souhlasy a soukromí';

  @override
  String get consentsTile => 'Souhlasy a soukromí';

  @override
  String get consentsTileSubtitle => 'Co odesíláme a s čím jsi souhlasil(a)';

  @override
  String get consentsIntro =>
      'Deník funguje i bez souhlasů a data zůstávají v telefonu. Každý souhlas je zvlášť a jde kdykoli odvolat.';

  @override
  String get consentsAiHelp =>
      'Dotaz a vybraná data ze zahrady jdou přes náš server jazykovému modelu. Bez souhlasu odpovídá Bóďa jen v ukázkovém režimu.';

  @override
  String get consentsAnalytics => 'Anonymní statistiky používání';

  @override
  String get consentsAnalyticsHelp =>
      'Kolik záznamů a úkolů vzniká a které funkce se používají, bez textů, fotek a polohy. Pomáhá rozhodnout, co zlepšit.';

  @override
  String consentsAnalyticsOn(String date) {
    return 'Souhlas udělen $date';
  }

  @override
  String get consentsAnalyticsOff => 'Bez souhlasu, nic se neodesílá';

  @override
  String consentsSync(String version) {
    return 'S účtem se souhlasy uloží i k účtu (verze zásad $version).';
  }

  @override
  String get consentsPolicy => 'Zásady ochrany soukromí';

  @override
  String get premiumTitle => 'Premium';

  @override
  String get premiumTile => 'Premium';

  @override
  String get premiumTileFree => 'Tarif Free';

  @override
  String get premiumTilePremium => 'Tarif Premium';

  @override
  String premiumTilePremiumUntil(String date) {
    return 'Tarif Premium do $date';
  }

  @override
  String get premiumTileUnknown => 'Tarif se nepodařilo ověřit';

  @override
  String get premiumHeadline => 'Bóďa naplno';

  @override
  String get premiumIntro =>
      'Deník, zóny, úkoly a záloha zůstávají vždy zdarma. Premium přidává chytrost navíc.';

  @override
  String get premiumCurrentFree => 'Teď máš Free.';

  @override
  String get premiumCurrentPremium => 'Máš Premium. Díky!';

  @override
  String get premiumColumnFree => 'Free';

  @override
  String get premiumColumnPremium => 'Premium';

  @override
  String get premiumRowDiary => 'Deník, zóny, úkoly, sklad, export';

  @override
  String get premiumRowGardens => 'Zahrady';

  @override
  String get premiumRowPhotos => 'Fotky v cloudu';

  @override
  String get premiumRowBoda => 'Dotazy na Bóďu';

  @override
  String get premiumRowV2 => 'Počasí, diagnostika z fotek, sdílení (V2)';

  @override
  String get premiumUnlimited => 'bez omezení';

  @override
  String get premiumYes => 'ano';

  @override
  String get premiumNo => 'ne';

  @override
  String get premiumFreeGardens => '1';

  @override
  String get premiumFreePhotos => '200';

  @override
  String get premiumFreeBoda => '10 měsíčně';

  @override
  String get premiumPremiumBoda => '300 měsíčně';

  @override
  String get premiumYearly => 'Ročně';

  @override
  String get premiumMonthly => 'Měsíčně';

  @override
  String premiumPerYear(String price) {
    return '$price za rok';
  }

  @override
  String premiumPerMonth(String price) {
    return '$price za měsíc';
  }

  @override
  String get premiumBestValue => 'Výhodnější';

  @override
  String premiumTrial(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dní zdarma',
      few: '$days dny zdarma',
      one: '1 den zdarma',
    );
    return '$_temp0';
  }

  @override
  String get premiumBuy => 'Vyzkoušet Premium';

  @override
  String get premiumRestore => 'Obnovit nákupy';

  @override
  String get premiumNotYet =>
      'Předplatné spustíme na začátku sezóny 2028. Do té doby máš všechno z Free.';

  @override
  String get premiumSignInFirst =>
      'Předplatné patří k účtu. Nejdřív se přihlas.';

  @override
  String get premiumSignIn => 'Přihlásit se';

  @override
  String get premiumRenewal =>
      'Předplatné se obnovuje automaticky; zrušit jde kdykoli v obchodě (Google Play, App Store).';

  @override
  String get premiumThanks => 'Premium je aktivní.';

  @override
  String get premiumPending =>
      'Platba čeká na potvrzení obchodu. Premium se zapne, až projde.';

  @override
  String get premiumRestored => 'Nákupy obnovené.';

  @override
  String get premiumFailed => 'Nákup se nepovedl. Zkus to prosím znovu.';

  @override
  String get premiumOffline => 'Bez připojení. Zkus to, až budeš online.';

  @override
  String get assistantLimitPremium => 'Víc dotazů s Premium';

  @override
  String get canvasTitle => 'Plán zahrady';

  @override
  String get canvasCardSubtitle => 'Obrys, zóny na mapě a jejich výměry';

  @override
  String get zonePlannedSection => 'V návrhu (plán zahrady)';

  @override
  String get canvasToolSelect => 'Vybrat';

  @override
  String get canvasToolOutline => 'Obrys';

  @override
  String get canvasToolZone => 'Zóna';

  @override
  String get canvasToolCalibrate => 'Kalibrovat';

  @override
  String get canvasToolMeasure => 'Kontrola';

  @override
  String get canvasUndo => 'Zpět';

  @override
  String get canvasRedo => 'Znovu';

  @override
  String get canvasLayerReality => 'Realita';

  @override
  String get canvasLayerPlan => 'Návrh';

  @override
  String get canvasLayerBoth => 'Obojí';

  @override
  String get canvasSnap => 'Přitahovat k mřížce (0,5 m)';

  @override
  String get canvasEmptyHint =>
      'Začni obrysem zahrady: vyber Obrys a klepáním přidávej rohy. Mřížka má čtverce 1 m.';

  @override
  String get canvasHintOutline =>
      'Klepáním přidávej rohy obrysu. Uzavřeš ho klepnutím na první bod nebo tlačítkem Hotovo.';

  @override
  String get canvasHintZone =>
      'Klepáním přidávej rohy zóny. Uzavřeš ji klepnutím na první bod nebo tlačítkem Hotovo.';

  @override
  String get canvasHintEdit =>
      'Táhni uzlem. Klepnutím na malý bod uprostřed hrany přidáš uzel.';

  @override
  String get canvasHintCalibrate =>
      'Klepni na začátek a konec úsečky, jejíž délku znáš (třeba plot nebo stěna domu).';

  @override
  String get canvasHintMeasure =>
      'Pro kontrolu klepni na začátek a konec jiné známé vzdálenosti.';

  @override
  String get canvasDone => 'Hotovo';

  @override
  String get canvasDiscard => 'Zahodit';

  @override
  String get canvasEditNodes => 'Upravit uzly';

  @override
  String get canvasEditDone => 'Hotovo s úpravou';

  @override
  String get canvasDeleteVertex => 'Smazat uzel';

  @override
  String get canvasRemoveShape => 'Odebrat z plánu';

  @override
  String get canvasRemoveOutline => 'Smazat obrys';

  @override
  String get canvasRealize => 'Zrealizovat';

  @override
  String canvasRealizedActivity(String name) {
    return 'Zrealizováno podle plánu: $name';
  }

  @override
  String canvasRealized(String name) {
    return '$name je teď v Realitě a v deníku přibyl záznam.';
  }

  @override
  String canvasSelectedOutline(String area) {
    return 'Obrys zahrady · $area m²';
  }

  @override
  String canvasSelectedZone(String name, String area) {
    return '$name · $area m²';
  }

  @override
  String canvasSelectedPlanned(String name, String area) {
    return '$name · $area m² · v návrhu';
  }

  @override
  String get canvasAssignTitle => 'Ke které zóně tvar patří?';

  @override
  String get canvasAssignNew => 'Nová zóna';

  @override
  String get canvasAssignNewName => 'Název nové zóny';

  @override
  String get canvasAssignCreate => 'Vytvořit zónu';

  @override
  String get canvasAssignPlanned => 'Nová zóna půjde do vrstvy Návrh.';

  @override
  String get canvasOutsideOutline =>
      'Zóna přesahuje obrys zahrady. Zkontroluj uzly.';

  @override
  String canvasAreaSuggest(String name, String plan, String current) {
    return 'Podle plánu má $name $plan m², zadáno je $current m².';
  }

  @override
  String get canvasAreaUse => 'Použít';

  @override
  String get canvasLengthTitle => 'Skutečná délka';

  @override
  String get canvasLengthLabel => 'Délka v metrech';

  @override
  String get canvasLengthInvalid => 'Zadej kladné číslo.';

  @override
  String canvasLengthDrawn(String length) {
    return 'Na plánu teď $length m.';
  }

  @override
  String get canvasCalibrated =>
      'Plán je přepočtený na metry. Pro kontrolu změř ještě jednu známou vzdálenost.';

  @override
  String canvasDeviationOk(String value) {
    return 'Odchylka $value %, měřítko sedí.';
  }

  @override
  String canvasDeviationBad(String value) {
    return 'Odchylka $value % je víc než 5 %. Podklad je asi zkreslený (šikmá fotka, nepřesný plánek).';
  }

  @override
  String get canvasBackgroundPick => 'Vložit podklad';

  @override
  String get canvasBackgroundRemove => 'Odebrat podklad';

  @override
  String get canvasBackgroundHelp =>
      'Fotka plánku nebo snímek mapy, který máš u sebe. Pak plán zkalibruj podle známé délky.';

  @override
  String get canvasBackgroundFailed => 'Obrázek se nepodařilo načíst.';

  @override
  String get canvasMore => 'Další volby';

  @override
  String canvasSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zón',
      few: '$count zóny',
      one: '1 zóna',
      zero: 'žádná zóna',
    );
    return 'Plán zahrady, $_temp0';
  }

  @override
  String get movementPurchase => 'Nákup';

  @override
  String get movementTask => 'Odpis úkolem';

  @override
  String get movementManual => 'Ruční úprava';

  @override
  String get movementReversal => 'Storno odpisu';

  @override
  String get movementHistoryTitle => 'Pohyby na skladě';

  @override
  String stockConsumed(String items) {
    return 'Ze skladu odepsáno: $items.';
  }

  @override
  String stockShortage(String items) {
    return 'Na skladě chybělo: $items. Doplň zásobu.';
  }

  @override
  String stockSkipped(String items) {
    return 'Neodepsáno (jiná jednotka nebo smazaná položka): $items.';
  }

  @override
  String get incidentsTitle => 'Problémy na zahradě';

  @override
  String get incidentsCardSubtitle =>
      'Choroby, škůdci a jiné potíže s plánem řešení a kontrolami';

  @override
  String incidentsCardOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count otevřených problémů',
      few: '$count otevřené problémy',
      one: '1 otevřený problém',
      zero: 'Žádný otevřený problém',
    );
    return '$_temp0';
  }

  @override
  String get incidentsEmpty =>
      'Zatím žádný problém. Když uvidíš mšice, plíseň nebo jiné potíže, zapiš je sem: Bóďa naplánuje kontroly za 3 a za 7 dní.';

  @override
  String get incidentNew => 'Nový problém';

  @override
  String get incidentEditTitle => 'Upravit problém';

  @override
  String get incidentLabel => 'Co se děje';

  @override
  String get incidentLabelHint => 'Např. mšice na rybízu';

  @override
  String get incidentLabelRequired => 'Napiš, co se děje.';

  @override
  String get incidentZoneRequired => 'Vyber zónu.';

  @override
  String get incidentPhotos => 'Fotky (první je „před“, poslední „po“)';

  @override
  String get incidentPlanBio => 'Šetrné řešení';

  @override
  String get incidentPlanBioHelper =>
      'Nejdřív bez chemie: ruční sběr, vodní sprcha, sítě, užitečný hmyz, výluhy.';

  @override
  String get incidentPlanChem => 'Chemické řešení (nepovinné)';

  @override
  String get incidentPlanChemHelper =>
      'Jen přípravek povolený pro neprofesionální uživatele. Dávku a ochrannou lhůtu ber z etikety, ne odjinud, a dbej na ochranu včel.';

  @override
  String get incidentChecksNote =>
      'Po uložení přibudou úkoly zkontrolovat stav za 3 a za 7 dní.';

  @override
  String incidentCheckTask(int days, String label) {
    return 'Kontrola po $days dnech: $label';
  }

  @override
  String get incidentCreated => 'Problém je zapsaný, kontroly jsou v úkolech.';

  @override
  String get incidentSaveFailed => 'Problém se nepodařilo uložit.';

  @override
  String get incidentOpen => 'Otevřený';

  @override
  String get incidentResolved => 'Vyřešeno';

  @override
  String get incidentResolve => 'Označit jako vyřešené';

  @override
  String get incidentReopen => 'Znovu otevřít';

  @override
  String get incidentBeforeAfter => 'Před a po';

  @override
  String get incidentCandidates => 'Možné příčiny';

  @override
  String get incidentChecks => 'Kontroly';

  @override
  String get incidentCheckDone => 'Zkontrolováno';

  @override
  String get incidentCheckSkipped => 'Vynecháno';

  @override
  String get incidentDeleteTitle => 'Smazat problém?';

  @override
  String incidentDeleteBody(String label) {
    return 'Smaže se karta „$label“ i její fotky. Úkoly kontrol zůstanou.';
  }
}
