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
}
