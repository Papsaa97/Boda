import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('cs')];

  /// No description provided for @appTitle.
  ///
  /// In cs, this message translates to:
  /// **'Zahradník Bóďa'**
  String get appTitle;

  /// No description provided for @commonCancel.
  ///
  /// In cs, this message translates to:
  /// **'Zrušit'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In cs, this message translates to:
  /// **'Uložit'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In cs, this message translates to:
  /// **'Smazat'**
  String get commonDelete;

  /// No description provided for @commonBack.
  ///
  /// In cs, this message translates to:
  /// **'Zpět'**
  String get commonBack;

  /// No description provided for @commonEdit.
  ///
  /// In cs, this message translates to:
  /// **'Upravit'**
  String get commonEdit;

  /// No description provided for @commonClose.
  ///
  /// In cs, this message translates to:
  /// **'Zavřít'**
  String get commonClose;

  /// No description provided for @commonContinue.
  ///
  /// In cs, this message translates to:
  /// **'Pokračovat'**
  String get commonContinue;

  /// No description provided for @commonUnknownZone.
  ///
  /// In cs, this message translates to:
  /// **'Neznámá zóna'**
  String get commonUnknownZone;

  /// No description provided for @commonErrorWithDetail.
  ///
  /// In cs, this message translates to:
  /// **'Chyba: {error}'**
  String commonErrorWithDetail(Object error);

  /// No description provided for @zonesLoadError.
  ///
  /// In cs, this message translates to:
  /// **'Chyba při načítání zón: {error}'**
  String zonesLoadError(Object error);

  /// No description provided for @navToday.
  ///
  /// In cs, this message translates to:
  /// **'Dnes'**
  String get navToday;

  /// No description provided for @navDiary.
  ///
  /// In cs, this message translates to:
  /// **'Deník'**
  String get navDiary;

  /// No description provided for @navTasks.
  ///
  /// In cs, this message translates to:
  /// **'Úkoly'**
  String get navTasks;

  /// No description provided for @navZones.
  ///
  /// In cs, this message translates to:
  /// **'Zóny'**
  String get navZones;

  /// No description provided for @newActivityTooltip.
  ///
  /// In cs, this message translates to:
  /// **'Nový záznam'**
  String get newActivityTooltip;

  /// No description provided for @newTaskTooltip.
  ///
  /// In cs, this message translates to:
  /// **'Nový úkol'**
  String get newTaskTooltip;

  /// No description provided for @relativeToday.
  ///
  /// In cs, this message translates to:
  /// **'dnes'**
  String get relativeToday;

  /// No description provided for @relativeYesterday.
  ///
  /// In cs, this message translates to:
  /// **'včera'**
  String get relativeYesterday;

  /// No description provided for @relativeDaysAgo.
  ///
  /// In cs, this message translates to:
  /// **'před {days} dny'**
  String relativeDaysAgo(int days);

  /// No description provided for @dayHeaderToday.
  ///
  /// In cs, this message translates to:
  /// **'Dnes'**
  String get dayHeaderToday;

  /// No description provided for @dayHeaderYesterday.
  ///
  /// In cs, this message translates to:
  /// **'Včera'**
  String get dayHeaderYesterday;

  /// No description provided for @dayHeaderTomorrow.
  ///
  /// In cs, this message translates to:
  /// **'Zítra'**
  String get dayHeaderTomorrow;

  /// No description provided for @onboardingZonesTitle.
  ///
  /// In cs, this message translates to:
  /// **'Co pěstuješ?'**
  String get onboardingZonesTitle;

  /// No description provided for @onboardingZonesBody.
  ///
  /// In cs, this message translates to:
  /// **'Vyber, co máš na zahradě. Z toho budou zóny, ke kterým budeš zapisovat práci. Upravit je můžeš kdykoli.'**
  String get onboardingZonesBody;

  /// No description provided for @onboardingPickAtLeastOne.
  ///
  /// In cs, this message translates to:
  /// **'Vyber aspoň jednu'**
  String get onboardingPickAtLeastOne;

  /// No description provided for @onboardingFinish.
  ///
  /// In cs, this message translates to:
  /// **'Jdeme na zahradu'**
  String get onboardingFinish;

  /// No description provided for @onboardingSaveFailed.
  ///
  /// In cs, this message translates to:
  /// **'Zóny se nepodařilo uložit, zkus to znovu.'**
  String get onboardingSaveFailed;

  /// No description provided for @onboardingSkip.
  ///
  /// In cs, this message translates to:
  /// **'Přeskočit'**
  String get onboardingSkip;

  /// No description provided for @activityTypeSowing.
  ///
  /// In cs, this message translates to:
  /// **'Výsev'**
  String get activityTypeSowing;

  /// No description provided for @activityTypePlanting.
  ///
  /// In cs, this message translates to:
  /// **'Výsadba'**
  String get activityTypePlanting;

  /// No description provided for @activityTypeWatering.
  ///
  /// In cs, this message translates to:
  /// **'Zálivka'**
  String get activityTypeWatering;

  /// No description provided for @activityTypeFertilizing.
  ///
  /// In cs, this message translates to:
  /// **'Hnojení'**
  String get activityTypeFertilizing;

  /// No description provided for @activityTypeSpraying.
  ///
  /// In cs, this message translates to:
  /// **'Postřik'**
  String get activityTypeSpraying;

  /// No description provided for @activityTypePruning.
  ///
  /// In cs, this message translates to:
  /// **'Řez'**
  String get activityTypePruning;

  /// No description provided for @activityTypeHarvest.
  ///
  /// In cs, this message translates to:
  /// **'Sklizeň'**
  String get activityTypeHarvest;

  /// No description provided for @activityTypeWeeding.
  ///
  /// In cs, this message translates to:
  /// **'Pletí'**
  String get activityTypeWeeding;

  /// No description provided for @activityTypeMowing.
  ///
  /// In cs, this message translates to:
  /// **'Sekání'**
  String get activityTypeMowing;

  /// No description provided for @activityTypeOther.
  ///
  /// In cs, this message translates to:
  /// **'Jiné'**
  String get activityTypeOther;

  /// No description provided for @activityHasNote.
  ///
  /// In cs, this message translates to:
  /// **'Má poznámku'**
  String get activityHasNote;

  /// No description provided for @activityNewTitle.
  ///
  /// In cs, this message translates to:
  /// **'Nový záznam'**
  String get activityNewTitle;

  /// No description provided for @activityEditTitle.
  ///
  /// In cs, this message translates to:
  /// **'Upravit záznam'**
  String get activityEditTitle;

  /// No description provided for @activityDetailTitle.
  ///
  /// In cs, this message translates to:
  /// **'Záznam'**
  String get activityDetailTitle;

  /// No description provided for @activityTypeLabel.
  ///
  /// In cs, this message translates to:
  /// **'Co jsi dělal?'**
  String get activityTypeLabel;

  /// No description provided for @activityTitleLabel.
  ///
  /// In cs, this message translates to:
  /// **'Název aktivity'**
  String get activityTitleLabel;

  /// No description provided for @activityTitleHint.
  ///
  /// In cs, this message translates to:
  /// **'např. Zálivka rajčat'**
  String get activityTitleHint;

  /// No description provided for @activityTitleRequired.
  ///
  /// In cs, this message translates to:
  /// **'Zadej název aktivity'**
  String get activityTitleRequired;

  /// No description provided for @activityDateLabel.
  ///
  /// In cs, this message translates to:
  /// **'Datum a čas'**
  String get activityDateLabel;

  /// No description provided for @activityZoneLabel.
  ///
  /// In cs, this message translates to:
  /// **'Zóna'**
  String get activityZoneLabel;

  /// No description provided for @activityZoneRequired.
  ///
  /// In cs, this message translates to:
  /// **'Vyber zónu'**
  String get activityZoneRequired;

  /// No description provided for @activityNotesLabel.
  ///
  /// In cs, this message translates to:
  /// **'Poznámka (volitelné)'**
  String get activityNotesLabel;

  /// No description provided for @activitySaveNew.
  ///
  /// In cs, this message translates to:
  /// **'Uložit záznam'**
  String get activitySaveNew;

  /// No description provided for @activitySaveChanges.
  ///
  /// In cs, this message translates to:
  /// **'Uložit změny'**
  String get activitySaveChanges;

  /// No description provided for @activitySaveFailed.
  ///
  /// In cs, this message translates to:
  /// **'Záznam se nepodařilo uložit.'**
  String get activitySaveFailed;

  /// No description provided for @activityDeleteTitle.
  ///
  /// In cs, this message translates to:
  /// **'Smazat záznam?'**
  String get activityDeleteTitle;

  /// No description provided for @activityDeleteBody.
  ///
  /// In cs, this message translates to:
  /// **'Záznam i jeho fotky zmizí z deníku.'**
  String get activityDeleteBody;

  /// No description provided for @activityDeleteFailed.
  ///
  /// In cs, this message translates to:
  /// **'Záznam se nepodařilo smazat.'**
  String get activityDeleteFailed;

  /// No description provided for @activityGone.
  ///
  /// In cs, this message translates to:
  /// **'Záznam už neexistuje.'**
  String get activityGone;

  /// No description provided for @photoTake.
  ///
  /// In cs, this message translates to:
  /// **'Vyfotit'**
  String get photoTake;

  /// No description provided for @photoFromGallery.
  ///
  /// In cs, this message translates to:
  /// **'Vybrat z galerie'**
  String get photoFromGallery;

  /// No description provided for @photoRemove.
  ///
  /// In cs, this message translates to:
  /// **'Odebrat fotku'**
  String get photoRemove;

  /// No description provided for @photoSaveFailed.
  ///
  /// In cs, this message translates to:
  /// **'Fotku se nepodařilo uložit.'**
  String get photoSaveFailed;

  /// No description provided for @photoAdd.
  ///
  /// In cs, this message translates to:
  /// **'Přidat fotku ({count}/{max})'**
  String photoAdd(int count, int max);

  /// No description provided for @photoLimitReached.
  ///
  /// In cs, this message translates to:
  /// **'Víc než {max} fotek k záznamu nejde'**
  String photoLimitReached(int max);

  /// No description provided for @timelineSearch.
  ///
  /// In cs, this message translates to:
  /// **'Hledat v deníku'**
  String get timelineSearch;

  /// No description provided for @timelineSearchClose.
  ///
  /// In cs, this message translates to:
  /// **'Zavřít hledání'**
  String get timelineSearchClose;

  /// No description provided for @timelineSearchHint.
  ///
  /// In cs, this message translates to:
  /// **'Hledat v názvu a poznámce'**
  String get timelineSearchHint;

  /// No description provided for @timelineLoadError.
  ///
  /// In cs, this message translates to:
  /// **'Chyba při načítání deníku: {error}'**
  String timelineLoadError(Object error);

  /// No description provided for @timelineEmptyTitle.
  ///
  /// In cs, this message translates to:
  /// **'Zatím žádné záznamy'**
  String get timelineEmptyTitle;

  /// No description provided for @timelineEmptyBody.
  ///
  /// In cs, this message translates to:
  /// **'Zapiš první práci na zahradě tlačítkem dole.'**
  String get timelineEmptyBody;

  /// No description provided for @filterAllZones.
  ///
  /// In cs, this message translates to:
  /// **'Všechny zóny'**
  String get filterAllZones;

  /// No description provided for @filterAllTypes.
  ///
  /// In cs, this message translates to:
  /// **'Všechny práce'**
  String get filterAllTypes;

  /// No description provided for @filterResultCount.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, =0{Nic nenalezeno} =1{1 záznam} few{{count} záznamy} other{{count} záznamů}}'**
  String filterResultCount(int count);

  /// No description provided for @filterNoMatch.
  ///
  /// In cs, this message translates to:
  /// **'Tomuhle filtru nic neodpovídá.'**
  String get filterNoMatch;

  /// No description provided for @photoSemantic.
  ///
  /// In cs, this message translates to:
  /// **'Fotka záznamu'**
  String get photoSemantic;

  /// No description provided for @photoSemanticOf.
  ///
  /// In cs, this message translates to:
  /// **'Fotka záznamu {title}'**
  String photoSemanticOf(String title);

  /// No description provided for @photoViewerTitle.
  ///
  /// In cs, this message translates to:
  /// **'{title} ({index}/{count})'**
  String photoViewerTitle(String title, int index, int count);

  /// No description provided for @activityDiscardTitle.
  ///
  /// In cs, this message translates to:
  /// **'Zahodit změny?'**
  String get activityDiscardTitle;

  /// No description provided for @activityDiscardBody.
  ///
  /// In cs, this message translates to:
  /// **'Záznam není uložený.'**
  String get activityDiscardBody;

  /// No description provided for @activityDiscardKeepEditing.
  ///
  /// In cs, this message translates to:
  /// **'Pokračovat v úpravách'**
  String get activityDiscardKeepEditing;

  /// No description provided for @activityDiscardConfirm.
  ///
  /// In cs, this message translates to:
  /// **'Zahodit'**
  String get activityDiscardConfirm;

  /// No description provided for @photoOpenFullscreen.
  ///
  /// In cs, this message translates to:
  /// **'Zobrazit fotku přes celou obrazovku'**
  String get photoOpenFullscreen;

  /// No description provided for @zoneNewTitle.
  ///
  /// In cs, this message translates to:
  /// **'Nová zóna'**
  String get zoneNewTitle;

  /// No description provided for @zoneRenameTitle.
  ///
  /// In cs, this message translates to:
  /// **'Přejmenovat zónu'**
  String get zoneRenameTitle;

  /// No description provided for @zoneNameHint.
  ///
  /// In cs, this message translates to:
  /// **'např. Záhon u plotu'**
  String get zoneNameHint;

  /// No description provided for @zoneSaveFailed.
  ///
  /// In cs, this message translates to:
  /// **'Změnu zón se nepodařilo uložit.'**
  String get zoneSaveFailed;

  /// No description provided for @zoneCannotDeleteTitle.
  ///
  /// In cs, this message translates to:
  /// **'Zónu nejde smazat'**
  String get zoneCannotDeleteTitle;

  /// No description provided for @zoneCannotDeleteBody.
  ///
  /// In cs, this message translates to:
  /// **'{name} má v deníku {count, plural, =1{1 záznam} few{{count} záznamy} other{{count} záznamů}}. Můžeš ji archivovat: nebude se nabízet pro nové záznamy, ale záznamy zůstanou.'**
  String zoneCannotDeleteBody(String name, int count);

  /// No description provided for @zoneArchive.
  ///
  /// In cs, this message translates to:
  /// **'Archivovat'**
  String get zoneArchive;

  /// No description provided for @zoneUnarchive.
  ///
  /// In cs, this message translates to:
  /// **'Vrátit z archivu'**
  String get zoneUnarchive;

  /// No description provided for @zoneDelete.
  ///
  /// In cs, this message translates to:
  /// **'Smazat zónu'**
  String get zoneDelete;

  /// No description provided for @zoneKeepOne.
  ///
  /// In cs, this message translates to:
  /// **'Aspoň jedna zóna musí zůstat.'**
  String get zoneKeepOne;

  /// No description provided for @zoneArchivedSection.
  ///
  /// In cs, this message translates to:
  /// **'Archivované'**
  String get zoneArchivedSection;

  /// No description provided for @zoneActivityCount.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, =0{Zatím bez záznamů} =1{1 záznam} few{{count} záznamy} other{{count} záznamů}}'**
  String zoneActivityCount(int count);

  /// No description provided for @zoneTypeVegetable.
  ///
  /// In cs, this message translates to:
  /// **'Zelenina'**
  String get zoneTypeVegetable;

  /// No description provided for @zoneTypeHerbs.
  ///
  /// In cs, this message translates to:
  /// **'Bylinky'**
  String get zoneTypeHerbs;

  /// No description provided for @zoneTypeFruit.
  ///
  /// In cs, this message translates to:
  /// **'Ovocný sad'**
  String get zoneTypeFruit;

  /// No description provided for @zoneTypeOrnamental.
  ///
  /// In cs, this message translates to:
  /// **'Okrasná zahrada'**
  String get zoneTypeOrnamental;

  /// No description provided for @zoneTypeLawn.
  ///
  /// In cs, this message translates to:
  /// **'Trávník'**
  String get zoneTypeLawn;

  /// No description provided for @zoneTypeGreenhouse.
  ///
  /// In cs, this message translates to:
  /// **'Skleník'**
  String get zoneTypeGreenhouse;

  /// No description provided for @zoneTypePond.
  ///
  /// In cs, this message translates to:
  /// **'Jezírko'**
  String get zoneTypePond;

  /// No description provided for @zoneTypeStructure.
  ///
  /// In cs, this message translates to:
  /// **'Stavba'**
  String get zoneTypeStructure;

  /// No description provided for @zoneTypeOther.
  ///
  /// In cs, this message translates to:
  /// **'Jiné'**
  String get zoneTypeOther;

  /// No description provided for @zoneTypeLabel.
  ///
  /// In cs, this message translates to:
  /// **'Druh zóny'**
  String get zoneTypeLabel;

  /// No description provided for @zoneNameEmpty.
  ///
  /// In cs, this message translates to:
  /// **'Zadej název zóny'**
  String get zoneNameEmpty;

  /// No description provided for @zoneNameDuplicate.
  ///
  /// In cs, this message translates to:
  /// **'Zóna s tímhle názvem už existuje'**
  String get zoneNameDuplicate;

  /// No description provided for @zoneTitle.
  ///
  /// In cs, this message translates to:
  /// **'Zóny'**
  String get zoneTitle;

  /// No description provided for @zoneArchiveKeepOne.
  ///
  /// In cs, this message translates to:
  /// **'Poslední aktivní zónu nejde archivovat.'**
  String get zoneArchiveKeepOne;

  /// No description provided for @zoneMoreActions.
  ///
  /// In cs, this message translates to:
  /// **'Další akce pro {name}'**
  String zoneMoreActions(String name);

  /// No description provided for @zoneArchived.
  ///
  /// In cs, this message translates to:
  /// **'Archivováno'**
  String get zoneArchived;

  /// No description provided for @zoneDeleted.
  ///
  /// In cs, this message translates to:
  /// **'Zóna {name} smazána'**
  String zoneDeleted(String name);

  /// No description provided for @dashboardTitle.
  ///
  /// In cs, this message translates to:
  /// **'Co dnes?'**
  String get dashboardTitle;

  /// No description provided for @dashboardLastWeek.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, =1{záznam za 7 dní} few{záznamy za 7 dní} other{záznamů za 7 dní}}'**
  String dashboardLastWeek(int count);

  /// No description provided for @dashboardLastEntry.
  ///
  /// In cs, this message translates to:
  /// **'poslední záznam'**
  String get dashboardLastEntry;

  /// No description provided for @dashboardHeroToday.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, =1{Dnes máš zapsaný 1 záznam} few{Dnes máš zapsané {count} záznamy} other{Dnes máš zapsáno {count} záznamů}}'**
  String dashboardHeroToday(int count);

  /// No description provided for @dashboardHeroTodayBody.
  ///
  /// In cs, this message translates to:
  /// **'Dobrá práce. Zahrada ti to vrátí.'**
  String get dashboardHeroTodayBody;

  /// No description provided for @dashboardHeroNothing.
  ///
  /// In cs, this message translates to:
  /// **'Dnes zatím nic'**
  String get dashboardHeroNothing;

  /// No description provided for @dashboardHeroZoneEmpty.
  ///
  /// In cs, this message translates to:
  /// **'V zóně {zone} ještě nemáš žádný záznam. Co se tam teď děje?'**
  String dashboardHeroZoneEmpty(String zone);

  /// No description provided for @dashboardHeroZoneStale.
  ///
  /// In cs, this message translates to:
  /// **'Poslední záznam v zóně {zone} je {when}. Mrkni, jak se jí daří.'**
  String dashboardHeroZoneStale(String zone, String when);

  /// No description provided for @dashboardHeroAllFresh.
  ///
  /// In cs, this message translates to:
  /// **'Všechny zóny máš za poslední týden zapsané. Co dnes uděláš?'**
  String get dashboardHeroAllFresh;

  /// No description provided for @dashboardLogActivity.
  ///
  /// In cs, this message translates to:
  /// **'Zapsat aktivitu'**
  String get dashboardLogActivity;

  /// No description provided for @dashboardTip.
  ///
  /// In cs, this message translates to:
  /// **'Tip od Bódi'**
  String get dashboardTip;

  /// No description provided for @dashboardAttention.
  ///
  /// In cs, this message translates to:
  /// **'Zaslouží pozornost'**
  String get dashboardAttention;

  /// No description provided for @dashboardZoneNoEntry.
  ///
  /// In cs, this message translates to:
  /// **'zatím bez záznamu'**
  String get dashboardZoneNoEntry;

  /// No description provided for @dashboardZoneLast.
  ///
  /// In cs, this message translates to:
  /// **'naposledy {when}'**
  String dashboardZoneLast(String when);

  /// No description provided for @dashboardTodayTasks.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, =1{Dnes je na řadě 1 úkol} few{Dnes jsou na řadě {count} úkoly} other{Dnes je na řadě {count} úkolů}}'**
  String dashboardTodayTasks(int count);

  /// No description provided for @dashboardAllTasks.
  ///
  /// In cs, this message translates to:
  /// **'Všechny úkoly'**
  String get dashboardAllTasks;

  /// No description provided for @backupShareSubject.
  ///
  /// In cs, this message translates to:
  /// **'Záloha deníku Zahradník Bóďa'**
  String get backupShareSubject;

  /// No description provided for @backupExportDone.
  ///
  /// In cs, this message translates to:
  /// **'Záloha je hotová.'**
  String get backupExportDone;

  /// No description provided for @backupExportFailed.
  ///
  /// In cs, this message translates to:
  /// **'Zálohu se nepodařilo vytvořit.'**
  String get backupExportFailed;

  /// No description provided for @backupImportConfirmTitle.
  ///
  /// In cs, this message translates to:
  /// **'Nahradit všechna data?'**
  String get backupImportConfirmTitle;

  /// No description provided for @backupImportConfirmBody.
  ///
  /// In cs, this message translates to:
  /// **'Záloha obsahuje {activities, plural, =1{1 záznam} few{{activities} záznamy} other{{activities} záznamů}}, {tasks, plural, =1{1 úkol} few{{tasks} úkoly} other{{tasks} úkolů}} a {photos, plural, =1{1 fotku} few{{photos} fotky} other{{photos} fotek}}. Všechno, co teď v aplikaci máš, se smaže a nahradí obsahem zálohy.'**
  String backupImportConfirmBody(int activities, int tasks, int photos);

  /// No description provided for @backupImportConfirm.
  ///
  /// In cs, this message translates to:
  /// **'Nahradit'**
  String get backupImportConfirm;

  /// No description provided for @backupImportDone.
  ///
  /// In cs, this message translates to:
  /// **'Data ze zálohy jsou obnovená.'**
  String get backupImportDone;

  /// No description provided for @backupImportFailed.
  ///
  /// In cs, this message translates to:
  /// **'Obnova se nepovedla, data zůstala beze změny.'**
  String get backupImportFailed;

  /// No description provided for @backupErrorNotABackup.
  ///
  /// In cs, this message translates to:
  /// **'Tohle není záloha ze Zahradníka Bódi.'**
  String get backupErrorNotABackup;

  /// No description provided for @backupErrorCorrupted.
  ///
  /// In cs, this message translates to:
  /// **'Záloha je poškozená a nejde načíst.'**
  String get backupErrorCorrupted;

  /// No description provided for @backupErrorTooNew.
  ///
  /// In cs, this message translates to:
  /// **'Záloha je z novější verze aplikace. Nejdřív si aplikaci aktualizuj.'**
  String get backupErrorTooNew;

  /// No description provided for @backupReminderTitle.
  ///
  /// In cs, this message translates to:
  /// **'Zálohuj si deník'**
  String get backupReminderTitle;

  /// No description provided for @backupReminderBody.
  ///
  /// In cs, this message translates to:
  /// **'Data jsou jen v tomhle telefonu. Záloha zabere chvilku a uložíš ji třeba na Disk nebo do e-mailu.'**
  String get backupReminderBody;

  /// No description provided for @backupReminderAction.
  ///
  /// In cs, this message translates to:
  /// **'Zálohovat'**
  String get backupReminderAction;

  /// No description provided for @backupExport.
  ///
  /// In cs, this message translates to:
  /// **'Exportovat zálohu'**
  String get backupExport;

  /// No description provided for @backupExportSubtitleNever.
  ///
  /// In cs, this message translates to:
  /// **'Zatím žádná záloha'**
  String get backupExportSubtitleNever;

  /// No description provided for @backupExportSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Naposledy {date}'**
  String backupExportSubtitle(String date);

  /// No description provided for @backupImport.
  ///
  /// In cs, this message translates to:
  /// **'Obnovit ze zálohy'**
  String get backupImport;

  /// No description provided for @backupImportSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Nahradí všechna data obsahem ZIP souboru'**
  String get backupImportSubtitle;

  /// No description provided for @backupUnavailableWeb.
  ///
  /// In cs, this message translates to:
  /// **'Záloha je dostupná v aplikaci pro Android a iOS.'**
  String get backupUnavailableWeb;

  /// No description provided for @settingsTitle.
  ///
  /// In cs, this message translates to:
  /// **'Nastavení'**
  String get settingsTitle;

  /// No description provided for @settingsTooltip.
  ///
  /// In cs, this message translates to:
  /// **'Nastavení'**
  String get settingsTooltip;

  /// No description provided for @settingsAppearance.
  ///
  /// In cs, this message translates to:
  /// **'Vzhled'**
  String get settingsAppearance;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In cs, this message translates to:
  /// **'Podle systému'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In cs, this message translates to:
  /// **'Světlý'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In cs, this message translates to:
  /// **'Tmavý'**
  String get settingsThemeDark;

  /// No description provided for @settingsNotifications.
  ///
  /// In cs, this message translates to:
  /// **'Připomínky'**
  String get settingsNotifications;

  /// No description provided for @settingsQuietStart.
  ///
  /// In cs, this message translates to:
  /// **'Tiché hodiny od'**
  String get settingsQuietStart;

  /// No description provided for @settingsQuietEnd.
  ///
  /// In cs, this message translates to:
  /// **'Tiché hodiny do'**
  String get settingsQuietEnd;

  /// No description provided for @settingsQuietHelp.
  ///
  /// In cs, this message translates to:
  /// **'V tichých hodinách žádná připomínka nepřijde. Co by na ně připadlo, přijde po jejich konci.'**
  String get settingsQuietHelp;

  /// No description provided for @settingsDigest.
  ///
  /// In cs, this message translates to:
  /// **'Ranní přehled úkolů'**
  String get settingsDigest;

  /// No description provided for @digestAuto.
  ///
  /// In cs, this message translates to:
  /// **'Automaticky'**
  String get digestAuto;

  /// No description provided for @digestDaily.
  ///
  /// In cs, this message translates to:
  /// **'Denně'**
  String get digestDaily;

  /// No description provided for @digestWeekly.
  ///
  /// In cs, this message translates to:
  /// **'Týdně'**
  String get digestWeekly;

  /// No description provided for @digestOff.
  ///
  /// In cs, this message translates to:
  /// **'Vypnuto'**
  String get digestOff;

  /// No description provided for @digestAutoHelp.
  ///
  /// In cs, this message translates to:
  /// **'Denně, v zimě (listopad až únor) jen v pondělí'**
  String get digestAutoHelp;

  /// No description provided for @digestDailyHelp.
  ///
  /// In cs, this message translates to:
  /// **'Každé ráno po konci tichých hodin'**
  String get digestDailyHelp;

  /// No description provided for @digestWeeklyHelp.
  ///
  /// In cs, this message translates to:
  /// **'V pondělí ráno, úkoly na celý týden'**
  String get digestWeeklyHelp;

  /// No description provided for @digestOffHelp.
  ///
  /// In cs, this message translates to:
  /// **'Jen připomínky u jednotlivých úkolů'**
  String get digestOffHelp;

  /// No description provided for @settingsData.
  ///
  /// In cs, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// No description provided for @settingsAbout.
  ///
  /// In cs, this message translates to:
  /// **'O aplikaci'**
  String get settingsAbout;

  /// No description provided for @settingsPrivacy.
  ///
  /// In cs, this message translates to:
  /// **'Všechna data zůstávají jen v tomhle zařízení. Aplikace nic neodesílá.'**
  String get settingsPrivacy;

  /// No description provided for @settingsVersion.
  ///
  /// In cs, this message translates to:
  /// **'Verze {version}'**
  String settingsVersion(String version);

  /// No description provided for @statsTitle.
  ///
  /// In cs, this message translates to:
  /// **'Statistika'**
  String get statsTitle;

  /// No description provided for @statsSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Záznamy po týdnech a nejaktivnější zóny'**
  String get statsSubtitle;

  /// No description provided for @statsTotal.
  ///
  /// In cs, this message translates to:
  /// **'záznamů celkem'**
  String get statsTotal;

  /// No description provided for @statsThisWeek.
  ///
  /// In cs, this message translates to:
  /// **'tento týden'**
  String get statsThisWeek;

  /// No description provided for @statsActiveWeeks.
  ///
  /// In cs, this message translates to:
  /// **'týdnů z {weeks} s aspoň 2 záznamy'**
  String statsActiveWeeks(int weeks);

  /// No description provided for @statsPerWeek.
  ///
  /// In cs, this message translates to:
  /// **'Záznamy po týdnech'**
  String get statsPerWeek;

  /// No description provided for @statsTopZones.
  ///
  /// In cs, this message translates to:
  /// **'Nejaktivnější zóny'**
  String get statsTopZones;

  /// No description provided for @statsTopTypes.
  ///
  /// In cs, this message translates to:
  /// **'Nejčastější práce'**
  String get statsTopTypes;

  /// No description provided for @statsEmpty.
  ///
  /// In cs, this message translates to:
  /// **'Zatím žádné záznamy.'**
  String get statsEmpty;

  /// No description provided for @taskNewTitle.
  ///
  /// In cs, this message translates to:
  /// **'Nový úkol'**
  String get taskNewTitle;

  /// No description provided for @taskEditTitle.
  ///
  /// In cs, this message translates to:
  /// **'Upravit úkol'**
  String get taskEditTitle;

  /// No description provided for @taskTitleLabel.
  ///
  /// In cs, this message translates to:
  /// **'Co je potřeba udělat'**
  String get taskTitleLabel;

  /// No description provided for @taskTitleHint.
  ///
  /// In cs, this message translates to:
  /// **'např. Postříkat broskvoň'**
  String get taskTitleHint;

  /// No description provided for @taskTitleRequired.
  ///
  /// In cs, this message translates to:
  /// **'Zadej, co je potřeba udělat'**
  String get taskTitleRequired;

  /// No description provided for @taskDueLabel.
  ///
  /// In cs, this message translates to:
  /// **'Termín'**
  String get taskDueLabel;

  /// No description provided for @taskReminderLabel.
  ///
  /// In cs, this message translates to:
  /// **'Připomenout'**
  String get taskReminderLabel;

  /// No description provided for @taskReminderAt.
  ///
  /// In cs, this message translates to:
  /// **'V {time}'**
  String taskReminderAt(String time);

  /// No description provided for @taskReminderOff.
  ///
  /// In cs, this message translates to:
  /// **'Jen v ranním přehledu'**
  String get taskReminderOff;

  /// No description provided for @taskReminderChange.
  ///
  /// In cs, this message translates to:
  /// **'Změnit čas'**
  String get taskReminderChange;

  /// No description provided for @taskZoneLabel.
  ///
  /// In cs, this message translates to:
  /// **'Zóna'**
  String get taskZoneLabel;

  /// No description provided for @taskNoZone.
  ///
  /// In cs, this message translates to:
  /// **'Bez zóny'**
  String get taskNoZone;

  /// No description provided for @taskRepeatLabel.
  ///
  /// In cs, this message translates to:
  /// **'Opakovat'**
  String get taskRepeatLabel;

  /// No description provided for @taskRepeatMonthsLabel.
  ///
  /// In cs, this message translates to:
  /// **'Jen v měsících (nic = celý rok)'**
  String get taskRepeatMonthsLabel;

  /// No description provided for @taskNotesLabel.
  ///
  /// In cs, this message translates to:
  /// **'Poznámka (volitelné)'**
  String get taskNotesLabel;

  /// No description provided for @taskSaveNew.
  ///
  /// In cs, this message translates to:
  /// **'Uložit úkol'**
  String get taskSaveNew;

  /// No description provided for @taskSaveFailed.
  ///
  /// In cs, this message translates to:
  /// **'Úkol se nepodařilo uložit.'**
  String get taskSaveFailed;

  /// No description provided for @taskDeleteTitle.
  ///
  /// In cs, this message translates to:
  /// **'Smazat úkol?'**
  String get taskDeleteTitle;

  /// No description provided for @taskMarkDone.
  ///
  /// In cs, this message translates to:
  /// **'Označit jako hotové'**
  String get taskMarkDone;

  /// No description provided for @taskMoreActions.
  ///
  /// In cs, this message translates to:
  /// **'Další akce'**
  String get taskMoreActions;

  /// No description provided for @taskSkip.
  ///
  /// In cs, this message translates to:
  /// **'Přeskočit'**
  String get taskSkip;

  /// No description provided for @taskReopen.
  ///
  /// In cs, this message translates to:
  /// **'Vrátit mezi otevřené'**
  String get taskReopen;

  /// No description provided for @taskStatusDone.
  ///
  /// In cs, this message translates to:
  /// **'Hotovo'**
  String get taskStatusDone;

  /// No description provided for @taskStatusSkipped.
  ///
  /// In cs, this message translates to:
  /// **'Přeskočeno'**
  String get taskStatusSkipped;

  /// No description provided for @taskDoneSnack.
  ///
  /// In cs, this message translates to:
  /// **'Hotovo: {title}'**
  String taskDoneSnack(String title);

  /// No description provided for @taskDoneRecurringSnack.
  ///
  /// In cs, this message translates to:
  /// **'Hotovo: {title}. Příště {date}.'**
  String taskDoneRecurringSnack(String title, String date);

  /// No description provided for @taskLogToDiary.
  ///
  /// In cs, this message translates to:
  /// **'Zapsat do deníku'**
  String get taskLogToDiary;

  /// No description provided for @repeatNone.
  ///
  /// In cs, this message translates to:
  /// **'Neopakovat'**
  String get repeatNone;

  /// No description provided for @repeatWeekly.
  ///
  /// In cs, this message translates to:
  /// **'Každý týden'**
  String get repeatWeekly;

  /// No description provided for @repeatMonthly.
  ///
  /// In cs, this message translates to:
  /// **'Každý měsíc'**
  String get repeatMonthly;

  /// No description provided for @repeatYearly.
  ///
  /// In cs, this message translates to:
  /// **'Každý rok'**
  String get repeatYearly;

  /// No description provided for @repeatInMonths.
  ///
  /// In cs, this message translates to:
  /// **'{base} ({months})'**
  String repeatInMonths(String base, String months);

  /// No description provided for @snoozeOneDay.
  ///
  /// In cs, this message translates to:
  /// **'Odložit o den'**
  String get snoozeOneDay;

  /// No description provided for @snoozeWeekend.
  ///
  /// In cs, this message translates to:
  /// **'Odložit na víkend'**
  String get snoozeWeekend;

  /// No description provided for @snoozeOneWeek.
  ///
  /// In cs, this message translates to:
  /// **'Odložit o týden'**
  String get snoozeOneWeek;

  /// No description provided for @tasksOverdue.
  ///
  /// In cs, this message translates to:
  /// **'Po termínu'**
  String get tasksOverdue;

  /// No description provided for @tasksNext7Days.
  ///
  /// In cs, this message translates to:
  /// **'Příštích 7 dní'**
  String get tasksNext7Days;

  /// No description provided for @tasksLater.
  ///
  /// In cs, this message translates to:
  /// **'Později'**
  String get tasksLater;

  /// No description provided for @tasksClosedSection.
  ///
  /// In cs, this message translates to:
  /// **'Hotové a přeskočené ({count})'**
  String tasksClosedSection(int count);

  /// No description provided for @tasksPrevWeek.
  ///
  /// In cs, this message translates to:
  /// **'Předchozí týden'**
  String get tasksPrevWeek;

  /// No description provided for @tasksNextWeek.
  ///
  /// In cs, this message translates to:
  /// **'Další týden'**
  String get tasksNextWeek;

  /// No description provided for @tasksDaySemantics.
  ///
  /// In cs, this message translates to:
  /// **'{date}, {count, plural, =0{žádný úkol} =1{1 úkol} few{{count} úkoly} other{{count} úkolů}}'**
  String tasksDaySemantics(String date, int count);

  /// No description provided for @tasksNoneThatDay.
  ///
  /// In cs, this message translates to:
  /// **'Na tenhle den nic není.'**
  String get tasksNoneThatDay;

  /// No description provided for @tasksEmptyTitle.
  ///
  /// In cs, this message translates to:
  /// **'Zatím žádné úkoly'**
  String get tasksEmptyTitle;

  /// No description provided for @tasksEmptyBody.
  ///
  /// In cs, this message translates to:
  /// **'Přidej, co tě na zahradě čeká. Připomenu ti to, ale nikdy v tichých hodinách.'**
  String get tasksEmptyBody;

  /// No description provided for @notificationChannelName.
  ///
  /// In cs, this message translates to:
  /// **'Připomínky úkolů'**
  String get notificationChannelName;

  /// No description provided for @notificationTaskBody.
  ///
  /// In cs, this message translates to:
  /// **'Úkol na zahradě je na řadě.'**
  String get notificationTaskBody;

  /// No description provided for @notificationDigestDailyTitle.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, =1{Dnes tě čeká 1 úkol} few{Dnes tě čekají {count} úkoly} other{Dnes tě čeká {count} úkolů}}'**
  String notificationDigestDailyTitle(int count);

  /// No description provided for @notificationDigestWeeklyTitle.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, =1{Tento týden tě čeká 1 úkol} few{Tento týden tě čekají {count} úkoly} other{Tento týden tě čeká {count} úkolů}}'**
  String notificationDigestWeeklyTitle(int count);

  /// No description provided for @notificationDigestMore.
  ///
  /// In cs, this message translates to:
  /// **'a {count} další'**
  String notificationDigestMore(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['cs'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs':
      return AppLocalizationsCs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
