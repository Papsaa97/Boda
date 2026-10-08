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

  /// No description provided for @commonDiscardTitle.
  ///
  /// In cs, this message translates to:
  /// **'Zahodit změny?'**
  String get commonDiscardTitle;

  /// No description provided for @commonDiscardBody.
  ///
  /// In cs, this message translates to:
  /// **'Změny nejsou uložené.'**
  String get commonDiscardBody;

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

  /// No description provided for @commonSaveFailed.
  ///
  /// In cs, this message translates to:
  /// **'Uložení se nepovedlo. Zkus to znovu.'**
  String get commonSaveFailed;

  /// No description provided for @commonLoadFailed.
  ///
  /// In cs, this message translates to:
  /// **'Data se nepodařilo načíst. Zkus aplikaci zavřít a otevřít znovu.'**
  String get commonLoadFailed;

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
  /// **'Co jsi dělal(a)?'**
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

  /// No description provided for @photoPickFailed.
  ///
  /// In cs, this message translates to:
  /// **'Fotku se nepodařilo načíst. Zkontroluj, jestli má aplikace přístup k fotoaparátu a fotkám.'**
  String get photoPickFailed;

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
  /// **'K zóně {name} patří záznamy v deníku, úkoly, problémy nebo stavby. Můžeš ji archivovat: nebude se nabízet pro nové záznamy, ale všechno v ní zůstane.'**
  String zoneCannotDeleteBody(String name);

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

  /// No description provided for @zoneDeleteConfirmTitle.
  ///
  /// In cs, this message translates to:
  /// **'Smazat zónu {name}?'**
  String zoneDeleteConfirmTitle(String name);

  /// No description provided for @zoneDeleteConfirmBody.
  ///
  /// In cs, this message translates to:
  /// **'Smaže se i její obrys v plánu zahrady. Tohle nejde vrátit.'**
  String get zoneDeleteConfirmBody;

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
  /// **'Bez účtu jsou data jen v tomhle telefonu. Záloha zabere chvilku a uložíš ji třeba na Disk nebo do e-mailu.'**
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

  /// No description provided for @diaryCsvExport.
  ///
  /// In cs, this message translates to:
  /// **'Exportovat deník do tabulky'**
  String get diaryCsvExport;

  /// No description provided for @diaryCsvExportSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'CSV pro Excel nebo Google Tabulky'**
  String get diaryCsvExportSubtitle;

  /// No description provided for @diaryCsvShareSubject.
  ///
  /// In cs, this message translates to:
  /// **'Deník Zahradníka Bódi (CSV)'**
  String get diaryCsvShareSubject;

  /// No description provided for @diaryCsvFailed.
  ///
  /// In cs, this message translates to:
  /// **'Tabulku se nepodařilo vytvořit.'**
  String get diaryCsvFailed;

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
  /// **'Deník je v telefonu a funguje bez účtu. Na server jdou jen data, se kterými jsi souhlasil(a): synchronizace, dotazy pro Bóďu, poloha pro počasí a fotky k diagnostice.'**
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
  /// **'{active, plural, one{týden} few{týdny} other{týdnů}} z {weeks} s aspoň 2 záznamy'**
  String statsActiveWeeks(int active, int weeks);

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
  /// **'a {count, plural, one{1 další} few{{count} další} other{{count} dalších}}'**
  String notificationDigestMore(int count);

  /// No description provided for @zoneEditTitle.
  ///
  /// In cs, this message translates to:
  /// **'Upravit zónu'**
  String get zoneEditTitle;

  /// No description provided for @zoneEdit.
  ///
  /// In cs, this message translates to:
  /// **'Upravit'**
  String get zoneEdit;

  /// No description provided for @zoneNameLabel.
  ///
  /// In cs, this message translates to:
  /// **'Název'**
  String get zoneNameLabel;

  /// No description provided for @zoneAreaLabel.
  ///
  /// In cs, this message translates to:
  /// **'Výměra (m²)'**
  String get zoneAreaLabel;

  /// No description provided for @zoneAreaHint.
  ///
  /// In cs, this message translates to:
  /// **'např. 20'**
  String get zoneAreaHint;

  /// No description provided for @zoneAreaHelper.
  ///
  /// In cs, this message translates to:
  /// **'Stačí změřit pásmem: délka × šířka.'**
  String get zoneAreaHelper;

  /// No description provided for @zonePhLabel.
  ///
  /// In cs, this message translates to:
  /// **'pH půdy'**
  String get zonePhLabel;

  /// No description provided for @zonePhHint.
  ///
  /// In cs, this message translates to:
  /// **'např. 6,5'**
  String get zonePhHint;

  /// No description provided for @zonePhMeasuredLabel.
  ///
  /// In cs, this message translates to:
  /// **'Změřeno'**
  String get zonePhMeasuredLabel;

  /// No description provided for @zonePhMeasuredNone.
  ///
  /// In cs, this message translates to:
  /// **'Kdy jsi pH měřil(a)?'**
  String get zonePhMeasuredNone;

  /// No description provided for @zoneSoilLabel.
  ///
  /// In cs, this message translates to:
  /// **'Půda'**
  String get zoneSoilLabel;

  /// No description provided for @zoneSunLabel.
  ///
  /// In cs, this message translates to:
  /// **'Oslunění'**
  String get zoneSunLabel;

  /// No description provided for @zoneIrrigationLabel.
  ///
  /// In cs, this message translates to:
  /// **'Závlaha'**
  String get zoneIrrigationLabel;

  /// No description provided for @zoneCoveredLabel.
  ///
  /// In cs, this message translates to:
  /// **'Krytá zóna'**
  String get zoneCoveredLabel;

  /// No description provided for @zoneCoveredHelp.
  ///
  /// In cs, this message translates to:
  /// **'Skleník nebo fóliovník'**
  String get zoneCoveredHelp;

  /// No description provided for @zoneNotSet.
  ///
  /// In cs, this message translates to:
  /// **'Nevyplněno'**
  String get zoneNotSet;

  /// No description provided for @zoneNumberInvalid.
  ///
  /// In cs, this message translates to:
  /// **'Zadej číslo, třeba 12,5'**
  String get zoneNumberInvalid;

  /// No description provided for @zoneAreaOutOfRange.
  ///
  /// In cs, this message translates to:
  /// **'Výměra musí být mezi 0 a 100 000 m²'**
  String get zoneAreaOutOfRange;

  /// No description provided for @zonePhOutOfRange.
  ///
  /// In cs, this message translates to:
  /// **'pH bývá mezi 3 a 10'**
  String get zonePhOutOfRange;

  /// No description provided for @zoneSoilSandy.
  ///
  /// In cs, this message translates to:
  /// **'Písčitá'**
  String get zoneSoilSandy;

  /// No description provided for @zoneSoilLoamy.
  ///
  /// In cs, this message translates to:
  /// **'Hlinitá'**
  String get zoneSoilLoamy;

  /// No description provided for @zoneSoilClay.
  ///
  /// In cs, this message translates to:
  /// **'Jílovitá'**
  String get zoneSoilClay;

  /// No description provided for @zoneSoilUnknown.
  ///
  /// In cs, this message translates to:
  /// **'Nevím'**
  String get zoneSoilUnknown;

  /// No description provided for @zoneSunFull.
  ///
  /// In cs, this message translates to:
  /// **'Plné slunce (6 h a víc)'**
  String get zoneSunFull;

  /// No description provided for @zoneSunPartShade.
  ///
  /// In cs, this message translates to:
  /// **'Polostín (3–6 h)'**
  String get zoneSunPartShade;

  /// No description provided for @zoneSunShade.
  ///
  /// In cs, this message translates to:
  /// **'Stín (méně než 3 h)'**
  String get zoneSunShade;

  /// No description provided for @zoneIrrigationNone.
  ///
  /// In cs, this message translates to:
  /// **'Žádná'**
  String get zoneIrrigationNone;

  /// No description provided for @zoneIrrigationManual.
  ///
  /// In cs, this message translates to:
  /// **'Konev nebo hadice'**
  String get zoneIrrigationManual;

  /// No description provided for @zoneIrrigationDrip.
  ///
  /// In cs, this message translates to:
  /// **'Kapková'**
  String get zoneIrrigationDrip;

  /// No description provided for @zoneIrrigationSprinkler.
  ///
  /// In cs, this message translates to:
  /// **'Postřikovač'**
  String get zoneIrrigationSprinkler;

  /// No description provided for @zonePropertiesTitle.
  ///
  /// In cs, this message translates to:
  /// **'Vlastnosti'**
  String get zonePropertiesTitle;

  /// No description provided for @zonePropertiesEmpty.
  ///
  /// In cs, this message translates to:
  /// **'Doplň výměru a půdu. Bóďa pak spočítá dávky přesně pro tuhle zónu.'**
  String get zonePropertiesEmpty;

  /// No description provided for @zoneAreaValue.
  ///
  /// In cs, this message translates to:
  /// **'{area} m²'**
  String zoneAreaValue(String area);

  /// No description provided for @zonePhValue.
  ///
  /// In cs, this message translates to:
  /// **'pH {ph}'**
  String zonePhValue(String ph);

  /// No description provided for @zonePhValueDated.
  ///
  /// In cs, this message translates to:
  /// **'pH {ph} ({date})'**
  String zonePhValueDated(String ph, String date);

  /// No description provided for @zoneRecentActivities.
  ///
  /// In cs, this message translates to:
  /// **'Poslední záznamy'**
  String get zoneRecentActivities;

  /// No description provided for @zoneNoActivities.
  ///
  /// In cs, this message translates to:
  /// **'V téhle zóně zatím nic zapsaného.'**
  String get zoneNoActivities;

  /// No description provided for @zoneCoveredYes.
  ///
  /// In cs, this message translates to:
  /// **'Krytá (skleník, fóliovník)'**
  String get zoneCoveredYes;

  /// No description provided for @inventoryTitle.
  ///
  /// In cs, this message translates to:
  /// **'Sklad'**
  String get inventoryTitle;

  /// No description provided for @inventoryEmptyTitle.
  ///
  /// In cs, this message translates to:
  /// **'Sklad je zatím prázdný'**
  String get inventoryEmptyTitle;

  /// No description provided for @inventoryEmptyBody.
  ///
  /// In cs, this message translates to:
  /// **'Zapiš osiva, hnojiva, přípravky a nářadí, co máš doma. Bóďa pak radí s tím, co máš, a hlídá, co dochází.'**
  String get inventoryEmptyBody;

  /// No description provided for @inventoryAdd.
  ///
  /// In cs, this message translates to:
  /// **'Přidat do skladu'**
  String get inventoryAdd;

  /// No description provided for @inventoryNewTitle.
  ///
  /// In cs, this message translates to:
  /// **'Nová položka'**
  String get inventoryNewTitle;

  /// No description provided for @inventoryEditTitle.
  ///
  /// In cs, this message translates to:
  /// **'Upravit položku'**
  String get inventoryEditTitle;

  /// No description provided for @inventoryCategoryLabel.
  ///
  /// In cs, this message translates to:
  /// **'Kategorie'**
  String get inventoryCategoryLabel;

  /// No description provided for @inventoryCategorySeed.
  ///
  /// In cs, this message translates to:
  /// **'Osiva'**
  String get inventoryCategorySeed;

  /// No description provided for @inventoryCategoryFertilizer.
  ///
  /// In cs, this message translates to:
  /// **'Hnojiva'**
  String get inventoryCategoryFertilizer;

  /// No description provided for @inventoryCategoryPlantProtection.
  ///
  /// In cs, this message translates to:
  /// **'Přípravky na ochranu rostlin'**
  String get inventoryCategoryPlantProtection;

  /// No description provided for @inventoryCategoryTool.
  ///
  /// In cs, this message translates to:
  /// **'Nářadí'**
  String get inventoryCategoryTool;

  /// No description provided for @inventoryCategoryOther.
  ///
  /// In cs, this message translates to:
  /// **'Ostatní'**
  String get inventoryCategoryOther;

  /// No description provided for @inventoryNameLabel.
  ///
  /// In cs, this message translates to:
  /// **'Název'**
  String get inventoryNameLabel;

  /// No description provided for @inventoryNameRequired.
  ///
  /// In cs, this message translates to:
  /// **'Zadej název'**
  String get inventoryNameRequired;

  /// No description provided for @inventoryUnitLabel.
  ///
  /// In cs, this message translates to:
  /// **'Jednotka'**
  String get inventoryUnitLabel;

  /// No description provided for @inventoryStockLabel.
  ///
  /// In cs, this message translates to:
  /// **'Množství doma'**
  String get inventoryStockLabel;

  /// No description provided for @inventoryThresholdLabel.
  ///
  /// In cs, this message translates to:
  /// **'Upozornit, když klesne na'**
  String get inventoryThresholdLabel;

  /// No description provided for @inventoryThresholdHelper.
  ///
  /// In cs, this message translates to:
  /// **'Nech prázdné, když hlídat nechceš.'**
  String get inventoryThresholdHelper;

  /// No description provided for @inventoryUnitG.
  ///
  /// In cs, this message translates to:
  /// **'g'**
  String get inventoryUnitG;

  /// No description provided for @inventoryUnitKg.
  ///
  /// In cs, this message translates to:
  /// **'kg'**
  String get inventoryUnitKg;

  /// No description provided for @inventoryUnitMl.
  ///
  /// In cs, this message translates to:
  /// **'ml'**
  String get inventoryUnitMl;

  /// No description provided for @inventoryUnitL.
  ///
  /// In cs, this message translates to:
  /// **'l'**
  String get inventoryUnitL;

  /// No description provided for @inventoryUnitKs.
  ///
  /// In cs, this message translates to:
  /// **'ks'**
  String get inventoryUnitKs;

  /// No description provided for @inventoryUnitPack.
  ///
  /// In cs, this message translates to:
  /// **'bal.'**
  String get inventoryUnitPack;

  /// No description provided for @inventorySpeciesLabel.
  ///
  /// In cs, this message translates to:
  /// **'Druh (např. rajče)'**
  String get inventorySpeciesLabel;

  /// No description provided for @inventoryVarietyLabel.
  ///
  /// In cs, this message translates to:
  /// **'Odrůda'**
  String get inventoryVarietyLabel;

  /// No description provided for @inventoryLotLabel.
  ///
  /// In cs, this message translates to:
  /// **'Šarže'**
  String get inventoryLotLabel;

  /// No description provided for @inventoryBestBeforeLabel.
  ///
  /// In cs, this message translates to:
  /// **'Spotřebovat do'**
  String get inventoryBestBeforeLabel;

  /// No description provided for @inventoryDateNone.
  ///
  /// In cs, this message translates to:
  /// **'Nezadáno'**
  String get inventoryDateNone;

  /// No description provided for @inventoryNpkLabel.
  ///
  /// In cs, this message translates to:
  /// **'Živiny N-P-K (%)'**
  String get inventoryNpkLabel;

  /// No description provided for @inventoryNLabel.
  ///
  /// In cs, this message translates to:
  /// **'N'**
  String get inventoryNLabel;

  /// No description provided for @inventoryPLabel.
  ///
  /// In cs, this message translates to:
  /// **'P'**
  String get inventoryPLabel;

  /// No description provided for @inventoryKLabel.
  ///
  /// In cs, this message translates to:
  /// **'K'**
  String get inventoryKLabel;

  /// No description provided for @inventoryFormLabel.
  ///
  /// In cs, this message translates to:
  /// **'Forma'**
  String get inventoryFormLabel;

  /// No description provided for @inventoryFormGranular.
  ///
  /// In cs, this message translates to:
  /// **'Granule'**
  String get inventoryFormGranular;

  /// No description provided for @inventoryFormLiquid.
  ///
  /// In cs, this message translates to:
  /// **'Tekuté'**
  String get inventoryFormLiquid;

  /// No description provided for @inventoryFormPowder.
  ///
  /// In cs, this message translates to:
  /// **'Prášek'**
  String get inventoryFormPowder;

  /// No description provided for @inventoryFormOrganic.
  ///
  /// In cs, this message translates to:
  /// **'Organické'**
  String get inventoryFormOrganic;

  /// No description provided for @inventoryDoseLabel.
  ///
  /// In cs, this message translates to:
  /// **'Dávka na 1 m² podle obalu'**
  String get inventoryDoseLabel;

  /// No description provided for @inventoryDoseHelper.
  ///
  /// In cs, this message translates to:
  /// **'Opiš z obalu. Z tohohle čísla Bóďa počítá množství na zónu.'**
  String get inventoryDoseHelper;

  /// No description provided for @inventoryLabelWarning.
  ///
  /// In cs, this message translates to:
  /// **'Údaje opiš přesně z etikety. Bóďa doporučí jen přípravek povolený pro neprofesionální uživatele a dávku nikdy neodhaduje.'**
  String get inventoryLabelWarning;

  /// No description provided for @inventoryActiveSubstanceLabel.
  ///
  /// In cs, this message translates to:
  /// **'Účinná látka'**
  String get inventoryActiveSubstanceLabel;

  /// No description provided for @inventoryAuthorizationLabel.
  ///
  /// In cs, this message translates to:
  /// **'Číslo povolení'**
  String get inventoryAuthorizationLabel;

  /// No description provided for @inventoryPhiLabel.
  ///
  /// In cs, this message translates to:
  /// **'Ochranná lhůta do sklizně (dny)'**
  String get inventoryPhiLabel;

  /// No description provided for @inventoryNonProfessionalLabel.
  ///
  /// In cs, this message translates to:
  /// **'Povoleno pro neprofesionální uživatele'**
  String get inventoryNonProfessionalLabel;

  /// No description provided for @inventoryConditionLabel.
  ///
  /// In cs, this message translates to:
  /// **'Stav'**
  String get inventoryConditionLabel;

  /// No description provided for @inventoryConditionGood.
  ///
  /// In cs, this message translates to:
  /// **'V pořádku'**
  String get inventoryConditionGood;

  /// No description provided for @inventoryConditionNeedsService.
  ///
  /// In cs, this message translates to:
  /// **'Potřebuje servis'**
  String get inventoryConditionNeedsService;

  /// No description provided for @inventoryConditionBroken.
  ///
  /// In cs, this message translates to:
  /// **'Rozbité'**
  String get inventoryConditionBroken;

  /// No description provided for @inventoryServiceIntervalLabel.
  ///
  /// In cs, this message translates to:
  /// **'Servis každých (dní)'**
  String get inventoryServiceIntervalLabel;

  /// No description provided for @inventoryLastServiceLabel.
  ///
  /// In cs, this message translates to:
  /// **'Poslední servis'**
  String get inventoryLastServiceLabel;

  /// No description provided for @inventoryNumberInvalid.
  ///
  /// In cs, this message translates to:
  /// **'Zadej kladné číslo'**
  String get inventoryNumberInvalid;

  /// No description provided for @inventoryDeleteTitle.
  ///
  /// In cs, this message translates to:
  /// **'Smazat položku?'**
  String get inventoryDeleteTitle;

  /// No description provided for @inventoryDeleteBody.
  ///
  /// In cs, this message translates to:
  /// **'{name} zmizí ze skladu.'**
  String inventoryDeleteBody(String name);

  /// No description provided for @inventoryDeleted.
  ///
  /// In cs, this message translates to:
  /// **'{name} smazáno'**
  String inventoryDeleted(String name);

  /// No description provided for @inventorySaveFailed.
  ///
  /// In cs, this message translates to:
  /// **'Sklad se nepodařilo uložit.'**
  String get inventorySaveFailed;

  /// No description provided for @inventoryStock.
  ///
  /// In cs, this message translates to:
  /// **'{qty} {unit}'**
  String inventoryStock(String qty, String unit);

  /// No description provided for @inventoryPhi.
  ///
  /// In cs, this message translates to:
  /// **'ochranná lhůta {count, plural, =1{1 den} few{{count} dny} other{{count} dní}}'**
  String inventoryPhi(int count);

  /// No description provided for @inventoryBestBefore.
  ///
  /// In cs, this message translates to:
  /// **'do {date}'**
  String inventoryBestBefore(String date);

  /// No description provided for @inventoryAlertsTitle.
  ///
  /// In cs, this message translates to:
  /// **'Hlídač zásob'**
  String get inventoryAlertsTitle;

  /// No description provided for @inventoryAlertLowStock.
  ///
  /// In cs, this message translates to:
  /// **'{name}: dochází ({qty})'**
  String inventoryAlertLowStock(String name, String qty);

  /// No description provided for @inventoryAlertSeedExpired.
  ///
  /// In cs, this message translates to:
  /// **'{name}: osivo je po datu ({date})'**
  String inventoryAlertSeedExpired(String name, String date);

  /// No description provided for @inventoryAlertSeedExpiringSoon.
  ///
  /// In cs, this message translates to:
  /// **'{name}: osivo vydrží do {date}'**
  String inventoryAlertSeedExpiringSoon(String name, String date);

  /// No description provided for @inventoryAlertToolService.
  ///
  /// In cs, this message translates to:
  /// **'{name}: čas na servis'**
  String inventoryAlertToolService(String name);

  /// No description provided for @inventoryToShoppingList.
  ///
  /// In cs, this message translates to:
  /// **'Na nákupní seznam'**
  String get inventoryToShoppingList;

  /// No description provided for @inventoryAddedToShopping.
  ///
  /// In cs, this message translates to:
  /// **'{name} je na nákupním seznamu'**
  String inventoryAddedToShopping(String name);

  /// No description provided for @shoppingTitle.
  ///
  /// In cs, this message translates to:
  /// **'Nákupní seznam'**
  String get shoppingTitle;

  /// No description provided for @shoppingEmptyTitle.
  ///
  /// In cs, this message translates to:
  /// **'Nic nechybí'**
  String get shoppingEmptyTitle;

  /// No description provided for @shoppingEmptyBody.
  ///
  /// In cs, this message translates to:
  /// **'Sem přidáš, co koupit. Plní ho i Bóďa a hlídač zásob.'**
  String get shoppingEmptyBody;

  /// No description provided for @shoppingAdd.
  ///
  /// In cs, this message translates to:
  /// **'Přidat na seznam'**
  String get shoppingAdd;

  /// No description provided for @shoppingNameLabel.
  ///
  /// In cs, this message translates to:
  /// **'Co koupit'**
  String get shoppingNameLabel;

  /// No description provided for @shoppingQtyLabel.
  ///
  /// In cs, this message translates to:
  /// **'Množství (nepovinné)'**
  String get shoppingQtyLabel;

  /// No description provided for @shoppingClearDone.
  ///
  /// In cs, this message translates to:
  /// **'Smazat koupené'**
  String get shoppingClearDone;

  /// No description provided for @shoppingAlreadyListed.
  ///
  /// In cs, this message translates to:
  /// **'{name} už na seznamu je.'**
  String shoppingAlreadyListed(String name);

  /// No description provided for @shoppingSaveFailed.
  ///
  /// In cs, this message translates to:
  /// **'Nákupní seznam se nepodařilo uložit.'**
  String get shoppingSaveFailed;

  /// No description provided for @shoppingRestocked.
  ///
  /// In cs, this message translates to:
  /// **'Do skladu přidáno: {name} +{qty}'**
  String shoppingRestocked(String name, String qty);

  /// No description provided for @shoppingFromBoda.
  ///
  /// In cs, this message translates to:
  /// **'od Bódi'**
  String get shoppingFromBoda;

  /// No description provided for @shoppingFromLowStock.
  ///
  /// In cs, this message translates to:
  /// **'dochází'**
  String get shoppingFromLowStock;

  /// No description provided for @shoppingCount.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, =0{prázdný} =1{1 položka} few{{count} položky} other{{count} položek}}'**
  String shoppingCount(int count);

  /// No description provided for @navGarden.
  ///
  /// In cs, this message translates to:
  /// **'Zahrada'**
  String get navGarden;

  /// No description provided for @gardenZonesSection.
  ///
  /// In cs, this message translates to:
  /// **'Zóny'**
  String get gardenZonesSection;

  /// No description provided for @gardenInventoryCard.
  ///
  /// In cs, this message translates to:
  /// **'Sklad'**
  String get gardenInventoryCard;

  /// No description provided for @gardenInventorySummary.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, =0{Zatím prázdný} =1{1 položka} few{{count} položky} other{{count} položek}}'**
  String gardenInventorySummary(int count);

  /// No description provided for @gardenAlertsSummary.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, =1{1 upozornění} few{{count} upozornění} other{{count} upozornění}}'**
  String gardenAlertsSummary(int count);

  /// No description provided for @durationMinutes.
  ///
  /// In cs, this message translates to:
  /// **'{minutes} min'**
  String durationMinutes(int minutes);

  /// No description provided for @durationHours.
  ///
  /// In cs, this message translates to:
  /// **'{hours} h'**
  String durationHours(int hours);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In cs, this message translates to:
  /// **'{hours} h {minutes} min'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @taskDurationLabel.
  ///
  /// In cs, this message translates to:
  /// **'Odhad doby'**
  String get taskDurationLabel;

  /// No description provided for @taskDurationNone.
  ///
  /// In cs, this message translates to:
  /// **'Neuvedeno'**
  String get taskDurationNone;

  /// No description provided for @taskToolsLabel.
  ///
  /// In cs, this message translates to:
  /// **'Nářadí'**
  String get taskToolsLabel;

  /// No description provided for @taskToolsHint.
  ///
  /// In cs, this message translates to:
  /// **'Přidej nářadí, např. rýč'**
  String get taskToolsHint;

  /// No description provided for @taskToolAdd.
  ///
  /// In cs, this message translates to:
  /// **'Přidat nářadí'**
  String get taskToolAdd;

  /// No description provided for @taskToolRemove.
  ///
  /// In cs, this message translates to:
  /// **'Odebrat {name}'**
  String taskToolRemove(String name);

  /// No description provided for @taskMaterialsLabel.
  ///
  /// In cs, this message translates to:
  /// **'Materiál ze skladu'**
  String get taskMaterialsLabel;

  /// No description provided for @taskMaterialAdd.
  ///
  /// In cs, this message translates to:
  /// **'Přidat materiál'**
  String get taskMaterialAdd;

  /// No description provided for @taskMaterialRemove.
  ///
  /// In cs, this message translates to:
  /// **'Odebrat {name}'**
  String taskMaterialRemove(String name);

  /// No description provided for @taskMaterialItemLabel.
  ///
  /// In cs, this message translates to:
  /// **'Položka skladu'**
  String get taskMaterialItemLabel;

  /// No description provided for @taskMaterialQtyLabel.
  ///
  /// In cs, this message translates to:
  /// **'Množství'**
  String get taskMaterialQtyLabel;

  /// No description provided for @taskMaterialNoInventory.
  ///
  /// In cs, this message translates to:
  /// **'Ve skladu zatím nic není. Přidej položky v záložce Zahrada → Sklad.'**
  String get taskMaterialNoInventory;

  /// No description provided for @taskMaterialQty.
  ///
  /// In cs, this message translates to:
  /// **'{name}: {qty}'**
  String taskMaterialQty(String name, String qty);

  /// No description provided for @taskMaterialQtyInvalid.
  ///
  /// In cs, this message translates to:
  /// **'Zadej množství větší než 0.'**
  String get taskMaterialQtyInvalid;

  /// No description provided for @taskMaterialMissing.
  ///
  /// In cs, this message translates to:
  /// **'Neznámá položka'**
  String get taskMaterialMissing;

  /// No description provided for @weekendTitle.
  ///
  /// In cs, this message translates to:
  /// **'Víkend na chalupě'**
  String get weekendTitle;

  /// No description provided for @weekendTooltip.
  ///
  /// In cs, this message translates to:
  /// **'Víkend na chalupě'**
  String get weekendTooltip;

  /// No description provided for @weekendAvailable.
  ///
  /// In cs, this message translates to:
  /// **'Kolik máš času: {hours} h'**
  String weekendAvailable(int hours);

  /// No description provided for @weekendSummary.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, =0{Nic se nevejde} =1{Stihneš 1 úkol} few{Stihneš {count} úkoly} other{Stihneš {count} úkolů}} ({time})'**
  String weekendSummary(int count, String time);

  /// No description provided for @weekendNothing.
  ///
  /// In cs, this message translates to:
  /// **'Na příští týden nic otevřeného nemáš. Užij si chalupu.'**
  String get weekendNothing;

  /// No description provided for @weekendTakeAlong.
  ///
  /// In cs, this message translates to:
  /// **'Vezmi s sebou'**
  String get weekendTakeAlong;

  /// No description provided for @weekendLeftOver.
  ///
  /// In cs, this message translates to:
  /// **'Nevejde se'**
  String get weekendLeftOver;

  /// No description provided for @weekendEstimated.
  ///
  /// In cs, this message translates to:
  /// **'odhad'**
  String get weekendEstimated;

  /// No description provided for @weekendHint.
  ///
  /// In cs, this message translates to:
  /// **'Úkoly na řadě do týdne, nejdřív zpožděné. Doba bez odhadu se počítá jako 30 min.'**
  String get weekendHint;

  /// No description provided for @activityHarvestLabel.
  ///
  /// In cs, this message translates to:
  /// **'Sklizeno'**
  String get activityHarvestLabel;

  /// No description provided for @activityCostLabel.
  ///
  /// In cs, this message translates to:
  /// **'Náklady v Kč (nepovinné)'**
  String get activityCostLabel;

  /// No description provided for @activityHarvestValue.
  ///
  /// In cs, this message translates to:
  /// **'Sklizeno {qty}'**
  String activityHarvestValue(String qty);

  /// No description provided for @activityCostValue.
  ///
  /// In cs, this message translates to:
  /// **'Náklady {amount} Kč'**
  String activityCostValue(String amount);

  /// No description provided for @seasonTitle.
  ///
  /// In cs, this message translates to:
  /// **'Tvoje sezóna {year}'**
  String seasonTitle(int year);

  /// No description provided for @seasonCardBody.
  ///
  /// In cs, this message translates to:
  /// **'Zima je čas ohlédnout se. Kolik jsi toho letos zapsal(a) a sklidil(a)?'**
  String get seasonCardBody;

  /// No description provided for @seasonCardAction.
  ///
  /// In cs, this message translates to:
  /// **'Ukázat sezónu'**
  String get seasonCardAction;

  /// No description provided for @seasonEmpty.
  ///
  /// In cs, this message translates to:
  /// **'V tomhle roce zatím nic zapsaného.'**
  String get seasonEmpty;

  /// No description provided for @seasonActivities.
  ///
  /// In cs, this message translates to:
  /// **'záznamů'**
  String get seasonActivities;

  /// No description provided for @seasonActiveDays.
  ///
  /// In cs, this message translates to:
  /// **'dní na zahradě'**
  String get seasonActiveDays;

  /// No description provided for @seasonHarvestTitle.
  ///
  /// In cs, this message translates to:
  /// **'Sklizeň'**
  String get seasonHarvestTitle;

  /// No description provided for @seasonHarvestNone.
  ///
  /// In cs, this message translates to:
  /// **'Sklizeň s množstvím zatím nezapsaná.'**
  String get seasonHarvestNone;

  /// No description provided for @seasonCostTitle.
  ///
  /// In cs, this message translates to:
  /// **'Náklady'**
  String get seasonCostTitle;

  /// No description provided for @seasonTopZones.
  ///
  /// In cs, this message translates to:
  /// **'Nejvíc práce'**
  String get seasonTopZones;

  /// No description provided for @seasonPhotos.
  ///
  /// In cs, this message translates to:
  /// **'Fotky sezóny'**
  String get seasonPhotos;

  /// No description provided for @seasonOpen.
  ///
  /// In cs, this message translates to:
  /// **'Přehled sezóny'**
  String get seasonOpen;

  /// No description provided for @dashboardInventoryAlerts.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, =1{Hlídač zásob: 1 upozornění} few{Hlídač zásob: {count} upozornění} other{Hlídač zásob: {count} upozornění}}'**
  String dashboardInventoryAlerts(int count);

  /// No description provided for @navAssistant.
  ///
  /// In cs, this message translates to:
  /// **'Bóďa'**
  String get navAssistant;

  /// No description provided for @assistantTitle.
  ///
  /// In cs, this message translates to:
  /// **'Bóďa'**
  String get assistantTitle;

  /// No description provided for @assistantNewConversation.
  ///
  /// In cs, this message translates to:
  /// **'Nový rozhovor'**
  String get assistantNewConversation;

  /// No description provided for @assistantDeleteConversation.
  ///
  /// In cs, this message translates to:
  /// **'Smazat rozhovor'**
  String get assistantDeleteConversation;

  /// No description provided for @assistantDeleteConfirmTitle.
  ///
  /// In cs, this message translates to:
  /// **'Smazat rozhovor?'**
  String get assistantDeleteConfirmTitle;

  /// No description provided for @assistantDeleteConfirmBody.
  ///
  /// In cs, this message translates to:
  /// **'Dotazy i odpovědi z tohoto rozhovoru zmizí z telefonu.'**
  String get assistantDeleteConfirmBody;

  /// No description provided for @assistantDemoBanner.
  ///
  /// In cs, this message translates to:
  /// **'Ukázkový režim bez AI. Bóďa zatím jen spočítá dávky z tvých údajů a shrne, co o zahradě ví. Skutečné rady přijdou po přihlášení k účtu.'**
  String get assistantDemoBanner;

  /// No description provided for @assistantDemoLabel.
  ///
  /// In cs, this message translates to:
  /// **'Ukázkový režim'**
  String get assistantDemoLabel;

  /// No description provided for @assistantUsage.
  ///
  /// In cs, this message translates to:
  /// **'Tento měsíc {used} z {limit} dotazů'**
  String assistantUsage(int used, int limit);

  /// No description provided for @assistantPendingBanner.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, =1{1 dotaz čeká na připojení} few{{count} dotazy čekají na připojení} other{{count} dotazů čeká na připojení}}'**
  String assistantPendingBanner(int count);

  /// No description provided for @assistantSendPending.
  ///
  /// In cs, this message translates to:
  /// **'Odeslat'**
  String get assistantSendPending;

  /// No description provided for @assistantEmptyTitle.
  ///
  /// In cs, this message translates to:
  /// **'Zeptej se Bódi na svou zahradu'**
  String get assistantEmptyTitle;

  /// No description provided for @assistantEmptyBody.
  ///
  /// In cs, this message translates to:
  /// **'Bóďa vidí tvé zóny, poslední záznamy, úkoly a sklad. Dávky hnojiv počítá z údajů na obalu a výměry zóny.'**
  String get assistantEmptyBody;

  /// No description provided for @assistantSuggestionDose.
  ///
  /// In cs, this message translates to:
  /// **'Kolik hnojiva dát na zeleninu?'**
  String get assistantSuggestionDose;

  /// No description provided for @assistantSuggestionWeek.
  ///
  /// In cs, this message translates to:
  /// **'Co mám tento týden na zahradě udělat?'**
  String get assistantSuggestionWeek;

  /// No description provided for @assistantSuggestionStock.
  ///
  /// In cs, this message translates to:
  /// **'Co mi dochází ve skladu?'**
  String get assistantSuggestionStock;

  /// No description provided for @assistantInputHint.
  ///
  /// In cs, this message translates to:
  /// **'Napiš dotaz…'**
  String get assistantInputHint;

  /// No description provided for @assistantSend.
  ///
  /// In cs, this message translates to:
  /// **'Odeslat dotaz'**
  String get assistantSend;

  /// No description provided for @assistantThinking.
  ///
  /// In cs, this message translates to:
  /// **'Bóďa přemýšlí…'**
  String get assistantThinking;

  /// No description provided for @assistantStatusPending.
  ///
  /// In cs, this message translates to:
  /// **'Čeká na připojení. Odešle se, až budeš online.'**
  String get assistantStatusPending;

  /// No description provided for @assistantRetry.
  ///
  /// In cs, this message translates to:
  /// **'Zkusit znovu'**
  String get assistantRetry;

  /// No description provided for @assistantFailureNotSignedIn.
  ///
  /// In cs, this message translates to:
  /// **'Pro dotazy na Bóďu je potřeba se přihlásit k účtu.'**
  String get assistantFailureNotSignedIn;

  /// No description provided for @assistantFailureLimit.
  ///
  /// In cs, this message translates to:
  /// **'Tento měsíc máš vyčerpané dotazy ({limit}). Další přibudou 1. dne v měsíci.'**
  String assistantFailureLimit(int limit);

  /// No description provided for @assistantFailureNotConfigured.
  ///
  /// In cs, this message translates to:
  /// **'Bóďa teď není dostupný, server nemá dokončené nastavení.'**
  String get assistantFailureNotConfigured;

  /// No description provided for @assistantFailureUpstream.
  ///
  /// In cs, this message translates to:
  /// **'Bóďa teď neodpovídá. Zkus to za chvíli.'**
  String get assistantFailureUpstream;

  /// No description provided for @assistantSourcesTitle.
  ///
  /// In cs, this message translates to:
  /// **'Z čeho vycházím'**
  String get assistantSourcesTitle;

  /// No description provided for @assistantSourcesZones.
  ///
  /// In cs, this message translates to:
  /// **'Zóny: {zones}'**
  String assistantSourcesZones(String zones);

  /// No description provided for @assistantSourcesCounts.
  ///
  /// In cs, this message translates to:
  /// **'Záznamy z deníku: {activities} · otevřené úkoly: {tasks} · položky skladu: {items}'**
  String assistantSourcesCounts(int activities, int tasks, int items);

  /// No description provided for @assistantSourcesCalculations.
  ///
  /// In cs, this message translates to:
  /// **'Výpočty'**
  String get assistantSourcesCalculations;

  /// No description provided for @assistantSourcesNone.
  ///
  /// In cs, this message translates to:
  /// **'Bez výpočtů dávek. Dávku spočítám, když má zóna výměru a hnojivo dávku na m² z obalu.'**
  String get assistantSourcesNone;

  /// No description provided for @assistantCalculationLine.
  ///
  /// In cs, this message translates to:
  /// **'{label}: {result} ({source})'**
  String assistantCalculationLine(String label, String result, String source);

  /// No description provided for @assistantWarningUnverifiedDose.
  ///
  /// In cs, this message translates to:
  /// **'Číslo {text} nepochází z výpočtu ani z etikety. Než ho použiješ, ověř ho na obalu.'**
  String assistantWarningUnverifiedDose(String text);

  /// No description provided for @assistantWarningProfessionalOnly.
  ///
  /// In cs, this message translates to:
  /// **'{product} není povolený pro neprofesionální uživatele. Nepoužívej ho.'**
  String assistantWarningProfessionalOnly(String product);

  /// No description provided for @assistantWarningMissingPhi.
  ///
  /// In cs, this message translates to:
  /// **'U přípravku {product} chybí ochranná lhůta do sklizně. Najdeš ji na etiketě.'**
  String assistantWarningMissingPhi(String product);

  /// No description provided for @assistantActionTask.
  ///
  /// In cs, this message translates to:
  /// **'Přidat úkol: {title}'**
  String assistantActionTask(String title);

  /// No description provided for @assistantActionShopping.
  ///
  /// In cs, this message translates to:
  /// **'Na nákupní seznam: {name}'**
  String assistantActionShopping(String name);

  /// No description provided for @assistantActionActivity.
  ///
  /// In cs, this message translates to:
  /// **'Zapsat do deníku: {title}'**
  String assistantActionActivity(String title);

  /// No description provided for @assistantActionTaskDone.
  ///
  /// In cs, this message translates to:
  /// **'Úkol přidán'**
  String get assistantActionTaskDone;

  /// No description provided for @assistantActionShoppingDone.
  ///
  /// In cs, this message translates to:
  /// **'Přidáno na nákupní seznam'**
  String get assistantActionShoppingDone;

  /// No description provided for @assistantActionFailed.
  ///
  /// In cs, this message translates to:
  /// **'Akci se nepodařilo uložit.'**
  String get assistantActionFailed;

  /// No description provided for @assistantFeedbackUp.
  ///
  /// In cs, this message translates to:
  /// **'Dobrá odpověď'**
  String get assistantFeedbackUp;

  /// No description provided for @assistantFeedbackDown.
  ///
  /// In cs, this message translates to:
  /// **'Špatná odpověď'**
  String get assistantFeedbackDown;

  /// No description provided for @assistantFeedbackCommentTitle.
  ///
  /// In cs, this message translates to:
  /// **'Co bylo špatně?'**
  String get assistantFeedbackCommentTitle;

  /// No description provided for @assistantFeedbackCommentHint.
  ///
  /// In cs, this message translates to:
  /// **'Nepovinné. Pomůže to Bóďu zlepšit.'**
  String get assistantFeedbackCommentHint;

  /// No description provided for @assistantFeedbackThanks.
  ///
  /// In cs, this message translates to:
  /// **'Díky za zpětnou vazbu.'**
  String get assistantFeedbackThanks;

  /// No description provided for @assistantSaveFailed.
  ///
  /// In cs, this message translates to:
  /// **'Rozhovor se nepodařilo uložit.'**
  String get assistantSaveFailed;

  /// No description provided for @accountTitle.
  ///
  /// In cs, this message translates to:
  /// **'Účet a synchronizace'**
  String get accountTitle;

  /// No description provided for @accountSettingsTile.
  ///
  /// In cs, this message translates to:
  /// **'Účet a synchronizace'**
  String get accountSettingsTile;

  /// No description provided for @accountSettingsSignedOut.
  ///
  /// In cs, this message translates to:
  /// **'Bez účtu, data jsou jen v tomto telefonu'**
  String get accountSettingsSignedOut;

  /// No description provided for @accountSettingsSignedIn.
  ///
  /// In cs, this message translates to:
  /// **'Účet {email}'**
  String accountSettingsSignedIn(String email);

  /// No description provided for @accountUnavailable.
  ///
  /// In cs, this message translates to:
  /// **'Účet v této verzi aplikace zatím není. Všechno funguje i bez něj, data zůstávají v telefonu.'**
  String get accountUnavailable;

  /// No description provided for @accountIntro.
  ///
  /// In cs, this message translates to:
  /// **'S účtem se zahrada zálohuje do cloudu a jde otevřít i na dalším zařízení. Bóďa s umělou inteligencí účet potřebuje. Bez účtu vše funguje dál jen v tomto telefonu.'**
  String get accountIntro;

  /// No description provided for @accountEmailLabel.
  ///
  /// In cs, this message translates to:
  /// **'E-mail'**
  String get accountEmailLabel;

  /// No description provided for @accountSendCode.
  ///
  /// In cs, this message translates to:
  /// **'Poslat kód'**
  String get accountSendCode;

  /// No description provided for @accountSignIn.
  ///
  /// In cs, this message translates to:
  /// **'Přihlásit se'**
  String get accountSignIn;

  /// No description provided for @accountCodeSent.
  ///
  /// In cs, this message translates to:
  /// **'Kód jsme poslali na {email}. Platí jen chvíli.'**
  String accountCodeSent(String email);

  /// No description provided for @accountCodeLabel.
  ///
  /// In cs, this message translates to:
  /// **'Kód z e-mailu'**
  String get accountCodeLabel;

  /// No description provided for @accountVerify.
  ///
  /// In cs, this message translates to:
  /// **'Přihlásit'**
  String get accountVerify;

  /// No description provided for @accountChangeEmail.
  ///
  /// In cs, this message translates to:
  /// **'Jiný e-mail'**
  String get accountChangeEmail;

  /// No description provided for @accountErrorEmail.
  ///
  /// In cs, this message translates to:
  /// **'Tohle nevypadá jako e-mail.'**
  String get accountErrorEmail;

  /// No description provided for @accountErrorCode.
  ///
  /// In cs, this message translates to:
  /// **'Kód nesedí nebo už vypršel. Pošli si nový.'**
  String get accountErrorCode;

  /// No description provided for @accountErrorRate.
  ///
  /// In cs, this message translates to:
  /// **'Moc pokusů. Zkus to za pár minut.'**
  String get accountErrorRate;

  /// No description provided for @accountErrorOffline.
  ///
  /// In cs, this message translates to:
  /// **'Bez připojení. Zkus to, až budeš online.'**
  String get accountErrorOffline;

  /// No description provided for @accountErrorUnknown.
  ///
  /// In cs, this message translates to:
  /// **'Něco se nepovedlo. Zkus to znovu.'**
  String get accountErrorUnknown;

  /// No description provided for @accountSignedInAs.
  ///
  /// In cs, this message translates to:
  /// **'Účet {email}'**
  String accountSignedInAs(String email);

  /// No description provided for @accountSyncNow.
  ///
  /// In cs, this message translates to:
  /// **'Synchronizovat teď'**
  String get accountSyncNow;

  /// No description provided for @accountSyncRunning.
  ///
  /// In cs, this message translates to:
  /// **'Synchronizuji…'**
  String get accountSyncRunning;

  /// No description provided for @accountSyncNever.
  ///
  /// In cs, this message translates to:
  /// **'Ještě se nesynchronizovalo.'**
  String get accountSyncNever;

  /// No description provided for @accountSyncLast.
  ///
  /// In cs, this message translates to:
  /// **'Naposledy synchronizováno {time}'**
  String accountSyncLast(String time);

  /// No description provided for @accountSyncOffline.
  ///
  /// In cs, this message translates to:
  /// **'Bez připojení. Změny počkají v telefonu a odešlou se příště.'**
  String get accountSyncOffline;

  /// No description provided for @accountSyncFailed.
  ///
  /// In cs, this message translates to:
  /// **'Synchronizace se nepovedla. Data v telefonu jsou v pořádku, zkusí se to znovu.'**
  String get accountSyncFailed;

  /// No description provided for @accountConflictTitle.
  ///
  /// In cs, this message translates to:
  /// **'Účet už má jinou zahradu'**
  String get accountConflictTitle;

  /// No description provided for @accountConflictBody.
  ///
  /// In cs, this message translates to:
  /// **'K tomuto účtu patří zahrada z jiného zařízení. Můžeš ji použít i tady; data, která jsou teď v tomto telefonu, se nahradí. Když chceš data z telefonu zachovat, nejdřív si udělej zálohu.'**
  String get accountConflictBody;

  /// No description provided for @accountConflictUse.
  ///
  /// In cs, this message translates to:
  /// **'Použít zahradu z účtu'**
  String get accountConflictUse;

  /// No description provided for @accountConflictConfirmTitle.
  ///
  /// In cs, this message translates to:
  /// **'Nahradit data v telefonu?'**
  String get accountConflictConfirmTitle;

  /// No description provided for @accountConflictConfirmBody.
  ///
  /// In cs, this message translates to:
  /// **'Záznamy, úkoly, zóny a sklad v tomto telefonu se smažou a nahradí zahradou z účtu.'**
  String get accountConflictConfirmBody;

  /// No description provided for @accountConflictConfirm.
  ///
  /// In cs, this message translates to:
  /// **'Nahradit'**
  String get accountConflictConfirm;

  /// No description provided for @accountSignOut.
  ///
  /// In cs, this message translates to:
  /// **'Odhlásit se'**
  String get accountSignOut;

  /// No description provided for @accountSignOutBody.
  ///
  /// In cs, this message translates to:
  /// **'Data zůstanou v telefonu. Změny se do cloudu dostanou po dalším přihlášení.'**
  String get accountSignOutBody;

  /// No description provided for @accountDelete.
  ///
  /// In cs, this message translates to:
  /// **'Smazat účet'**
  String get accountDelete;

  /// No description provided for @accountDeleteTitle.
  ///
  /// In cs, this message translates to:
  /// **'Smazat účet?'**
  String get accountDeleteTitle;

  /// No description provided for @accountDeleteBody.
  ///
  /// In cs, this message translates to:
  /// **'Smaže se účet a všechna data na serveru: zahrada, fotky v cloudu, rozhovory s Bóďou. Sdílené zahrady přejdou na dalšího člena. Data v tomto telefonu zůstanou. Nejde to vrátit.'**
  String get accountDeleteBody;

  /// No description provided for @accountDeleteConfirm.
  ///
  /// In cs, this message translates to:
  /// **'Smazat natrvalo'**
  String get accountDeleteConfirm;

  /// No description provided for @accountDeleted.
  ///
  /// In cs, this message translates to:
  /// **'Účet je smazaný. Data v telefonu zůstala.'**
  String get accountDeleted;

  /// No description provided for @assistantDemoBannerSignIn.
  ///
  /// In cs, this message translates to:
  /// **'Ukázkový režim bez AI. Pro skutečné rady se přihlas v Nastavení, Účet a synchronizace.'**
  String get assistantDemoBannerSignIn;

  /// No description provided for @assistantConsentTitle.
  ///
  /// In cs, this message translates to:
  /// **'Než se zeptáš Bódi'**
  String get assistantConsentTitle;

  /// No description provided for @assistantConsentBody.
  ///
  /// In cs, this message translates to:
  /// **'Dotaz a vybraná data ze zahrady (zóny, poslední záznamy, úkoly, sklad, spočítané dávky) se pošlou na náš server a odtud jazykovému modelu, který připraví odpověď. Jména, e-maily a fotky se neposílají. Souhlas jde kdykoli odvolat v Nastavení.'**
  String get assistantConsentBody;

  /// No description provided for @assistantConsentAgree.
  ///
  /// In cs, this message translates to:
  /// **'Souhlasím'**
  String get assistantConsentAgree;

  /// No description provided for @settingsAiConsent.
  ///
  /// In cs, this message translates to:
  /// **'Zpracování dotazů na Bóďu umělou inteligencí'**
  String get settingsAiConsent;

  /// No description provided for @settingsAiConsentOn.
  ///
  /// In cs, this message translates to:
  /// **'Souhlas udělen {date}'**
  String settingsAiConsentOn(String date);

  /// No description provided for @settingsAiConsentOff.
  ///
  /// In cs, this message translates to:
  /// **'Bez souhlasu (Bóďa odpovídá jen v ukázkovém režimu)'**
  String get settingsAiConsentOff;

  /// No description provided for @onboardingHaveAccount.
  ///
  /// In cs, this message translates to:
  /// **'Už mám účet, přihlásit se'**
  String get onboardingHaveAccount;

  /// No description provided for @consentsTitle.
  ///
  /// In cs, this message translates to:
  /// **'Souhlasy a soukromí'**
  String get consentsTitle;

  /// No description provided for @consentsTile.
  ///
  /// In cs, this message translates to:
  /// **'Souhlasy a soukromí'**
  String get consentsTile;

  /// No description provided for @consentsTileSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Co odesíláme a s čím jsi souhlasil(a)'**
  String get consentsTileSubtitle;

  /// No description provided for @consentsIntro.
  ///
  /// In cs, this message translates to:
  /// **'Deník funguje i bez souhlasů a data zůstávají v telefonu. Každý souhlas je zvlášť a jde kdykoli odvolat.'**
  String get consentsIntro;

  /// No description provided for @consentsAiHelp.
  ///
  /// In cs, this message translates to:
  /// **'Dotaz a vybraná data ze zahrady jdou přes náš server jazykovému modelu. Bez souhlasu odpovídá Bóďa jen v ukázkovém režimu.'**
  String get consentsAiHelp;

  /// No description provided for @consentsAnalytics.
  ///
  /// In cs, this message translates to:
  /// **'Anonymní statistiky používání'**
  String get consentsAnalytics;

  /// No description provided for @consentsAnalyticsHelp.
  ///
  /// In cs, this message translates to:
  /// **'Kolik záznamů a úkolů vzniká a které funkce se používají, bez textů, fotek a polohy. Pomáhá rozhodnout, co zlepšit.'**
  String get consentsAnalyticsHelp;

  /// No description provided for @consentsAnalyticsOn.
  ///
  /// In cs, this message translates to:
  /// **'Souhlas udělen {date}'**
  String consentsAnalyticsOn(String date);

  /// No description provided for @consentsAnalyticsOff.
  ///
  /// In cs, this message translates to:
  /// **'Bez souhlasu, nic se neodesílá'**
  String get consentsAnalyticsOff;

  /// No description provided for @consentsSync.
  ///
  /// In cs, this message translates to:
  /// **'S účtem se souhlasy uloží i k účtu (verze zásad {version}).'**
  String consentsSync(String version);

  /// No description provided for @consentsPolicy.
  ///
  /// In cs, this message translates to:
  /// **'Zásady ochrany soukromí'**
  String get consentsPolicy;

  /// No description provided for @premiumTitle.
  ///
  /// In cs, this message translates to:
  /// **'Premium'**
  String get premiumTitle;

  /// No description provided for @premiumTile.
  ///
  /// In cs, this message translates to:
  /// **'Premium'**
  String get premiumTile;

  /// No description provided for @premiumTileFree.
  ///
  /// In cs, this message translates to:
  /// **'Tarif Free'**
  String get premiumTileFree;

  /// No description provided for @premiumTilePremium.
  ///
  /// In cs, this message translates to:
  /// **'Tarif Premium'**
  String get premiumTilePremium;

  /// No description provided for @premiumTilePremiumUntil.
  ///
  /// In cs, this message translates to:
  /// **'Tarif Premium do {date}'**
  String premiumTilePremiumUntil(String date);

  /// No description provided for @premiumTileUnknown.
  ///
  /// In cs, this message translates to:
  /// **'Tarif se nepodařilo ověřit'**
  String get premiumTileUnknown;

  /// No description provided for @premiumHeadline.
  ///
  /// In cs, this message translates to:
  /// **'Bóďa naplno'**
  String get premiumHeadline;

  /// No description provided for @premiumIntro.
  ///
  /// In cs, this message translates to:
  /// **'Deník, zóny, úkoly a záloha zůstávají vždy zdarma. Premium přidává chytrost navíc.'**
  String get premiumIntro;

  /// No description provided for @premiumCurrentFree.
  ///
  /// In cs, this message translates to:
  /// **'Teď máš Free.'**
  String get premiumCurrentFree;

  /// No description provided for @premiumCurrentPremium.
  ///
  /// In cs, this message translates to:
  /// **'Máš Premium. Díky!'**
  String get premiumCurrentPremium;

  /// No description provided for @premiumColumnFree.
  ///
  /// In cs, this message translates to:
  /// **'Free'**
  String get premiumColumnFree;

  /// No description provided for @premiumColumnPremium.
  ///
  /// In cs, this message translates to:
  /// **'Premium'**
  String get premiumColumnPremium;

  /// No description provided for @premiumRowDiary.
  ///
  /// In cs, this message translates to:
  /// **'Deník, zóny, úkoly, sklad, export'**
  String get premiumRowDiary;

  /// No description provided for @premiumRowGardens.
  ///
  /// In cs, this message translates to:
  /// **'Zahrady'**
  String get premiumRowGardens;

  /// No description provided for @premiumRowPhotos.
  ///
  /// In cs, this message translates to:
  /// **'Fotky v cloudu'**
  String get premiumRowPhotos;

  /// No description provided for @premiumRowBoda.
  ///
  /// In cs, this message translates to:
  /// **'Dotazy na Bóďu'**
  String get premiumRowBoda;

  /// No description provided for @premiumRowV2.
  ///
  /// In cs, this message translates to:
  /// **'Počasí, diagnostika z fotek, sdílení (V2)'**
  String get premiumRowV2;

  /// No description provided for @premiumUnlimited.
  ///
  /// In cs, this message translates to:
  /// **'bez omezení'**
  String get premiumUnlimited;

  /// No description provided for @premiumYes.
  ///
  /// In cs, this message translates to:
  /// **'ano'**
  String get premiumYes;

  /// No description provided for @premiumNo.
  ///
  /// In cs, this message translates to:
  /// **'ne'**
  String get premiumNo;

  /// No description provided for @premiumFreeGardens.
  ///
  /// In cs, this message translates to:
  /// **'1'**
  String get premiumFreeGardens;

  /// No description provided for @premiumFreePhotos.
  ///
  /// In cs, this message translates to:
  /// **'200'**
  String get premiumFreePhotos;

  /// No description provided for @premiumFreeBoda.
  ///
  /// In cs, this message translates to:
  /// **'10 měsíčně'**
  String get premiumFreeBoda;

  /// No description provided for @premiumPremiumBoda.
  ///
  /// In cs, this message translates to:
  /// **'300 měsíčně'**
  String get premiumPremiumBoda;

  /// No description provided for @premiumYearly.
  ///
  /// In cs, this message translates to:
  /// **'Ročně'**
  String get premiumYearly;

  /// No description provided for @premiumMonthly.
  ///
  /// In cs, this message translates to:
  /// **'Měsíčně'**
  String get premiumMonthly;

  /// No description provided for @premiumPerYear.
  ///
  /// In cs, this message translates to:
  /// **'{price} za rok'**
  String premiumPerYear(String price);

  /// No description provided for @premiumPerMonth.
  ///
  /// In cs, this message translates to:
  /// **'{price} za měsíc'**
  String premiumPerMonth(String price);

  /// No description provided for @premiumBestValue.
  ///
  /// In cs, this message translates to:
  /// **'Výhodnější'**
  String get premiumBestValue;

  /// No description provided for @premiumTrial.
  ///
  /// In cs, this message translates to:
  /// **'{days, plural, =1{1 den zdarma} few{{days} dny zdarma} other{{days} dní zdarma}}'**
  String premiumTrial(int days);

  /// No description provided for @premiumBuy.
  ///
  /// In cs, this message translates to:
  /// **'Vyzkoušet Premium'**
  String get premiumBuy;

  /// No description provided for @premiumRestore.
  ///
  /// In cs, this message translates to:
  /// **'Obnovit nákupy'**
  String get premiumRestore;

  /// No description provided for @premiumNotYet.
  ///
  /// In cs, this message translates to:
  /// **'Předplatné spustíme na začátku sezóny 2028. Do té doby máš všechno z Free.'**
  String get premiumNotYet;

  /// No description provided for @premiumSignInFirst.
  ///
  /// In cs, this message translates to:
  /// **'Předplatné patří k účtu. Nejdřív se přihlas.'**
  String get premiumSignInFirst;

  /// No description provided for @premiumSignIn.
  ///
  /// In cs, this message translates to:
  /// **'Přihlásit se'**
  String get premiumSignIn;

  /// No description provided for @premiumRenewal.
  ///
  /// In cs, this message translates to:
  /// **'Předplatné se obnovuje automaticky; zrušit jde kdykoli v obchodě (Google Play, App Store).'**
  String get premiumRenewal;

  /// No description provided for @premiumThanks.
  ///
  /// In cs, this message translates to:
  /// **'Premium je aktivní.'**
  String get premiumThanks;

  /// No description provided for @premiumPending.
  ///
  /// In cs, this message translates to:
  /// **'Platba čeká na potvrzení obchodu. Premium se zapne, až projde.'**
  String get premiumPending;

  /// No description provided for @premiumRestored.
  ///
  /// In cs, this message translates to:
  /// **'Nákupy obnovené.'**
  String get premiumRestored;

  /// No description provided for @premiumFailed.
  ///
  /// In cs, this message translates to:
  /// **'Nákup se nepovedl. Zkus to prosím znovu.'**
  String get premiumFailed;

  /// No description provided for @premiumOffline.
  ///
  /// In cs, this message translates to:
  /// **'Bez připojení. Zkus to, až budeš online.'**
  String get premiumOffline;

  /// No description provided for @assistantLimitPremium.
  ///
  /// In cs, this message translates to:
  /// **'Víc dotazů s Premium'**
  String get assistantLimitPremium;

  /// No description provided for @canvasTitle.
  ///
  /// In cs, this message translates to:
  /// **'Plán zahrady'**
  String get canvasTitle;

  /// No description provided for @canvasCardSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Obrys, zóny na mapě a jejich výměry'**
  String get canvasCardSubtitle;

  /// No description provided for @zonePlannedSection.
  ///
  /// In cs, this message translates to:
  /// **'V návrhu (plán zahrady)'**
  String get zonePlannedSection;

  /// No description provided for @canvasToolSelect.
  ///
  /// In cs, this message translates to:
  /// **'Vybrat'**
  String get canvasToolSelect;

  /// No description provided for @canvasToolOutline.
  ///
  /// In cs, this message translates to:
  /// **'Obrys'**
  String get canvasToolOutline;

  /// No description provided for @canvasToolZone.
  ///
  /// In cs, this message translates to:
  /// **'Zóna'**
  String get canvasToolZone;

  /// No description provided for @canvasToolCalibrate.
  ///
  /// In cs, this message translates to:
  /// **'Kalibrovat'**
  String get canvasToolCalibrate;

  /// No description provided for @canvasToolMeasure.
  ///
  /// In cs, this message translates to:
  /// **'Kontrola'**
  String get canvasToolMeasure;

  /// No description provided for @canvasUndo.
  ///
  /// In cs, this message translates to:
  /// **'Zpět'**
  String get canvasUndo;

  /// No description provided for @canvasRedo.
  ///
  /// In cs, this message translates to:
  /// **'Znovu'**
  String get canvasRedo;

  /// No description provided for @canvasLayerReality.
  ///
  /// In cs, this message translates to:
  /// **'Realita'**
  String get canvasLayerReality;

  /// No description provided for @canvasLayerPlan.
  ///
  /// In cs, this message translates to:
  /// **'Návrh'**
  String get canvasLayerPlan;

  /// No description provided for @canvasLayerBoth.
  ///
  /// In cs, this message translates to:
  /// **'Obojí'**
  String get canvasLayerBoth;

  /// No description provided for @canvasSnap.
  ///
  /// In cs, this message translates to:
  /// **'Přitahovat k mřížce (0,5 m)'**
  String get canvasSnap;

  /// No description provided for @canvasEmptyHint.
  ///
  /// In cs, this message translates to:
  /// **'Začni obrysem zahrady: vyber Obrys a klepáním přidávej rohy. Mřížka má čtverce 1 m.'**
  String get canvasEmptyHint;

  /// No description provided for @canvasHintOutline.
  ///
  /// In cs, this message translates to:
  /// **'Klepáním přidávej rohy obrysu. Uzavřeš ho klepnutím na první bod nebo tlačítkem Hotovo.'**
  String get canvasHintOutline;

  /// No description provided for @canvasHintZone.
  ///
  /// In cs, this message translates to:
  /// **'Klepáním přidávej rohy zóny. Uzavřeš ji klepnutím na první bod nebo tlačítkem Hotovo.'**
  String get canvasHintZone;

  /// No description provided for @canvasHintEdit.
  ///
  /// In cs, this message translates to:
  /// **'Táhni uzlem. Klepnutím na malý bod uprostřed hrany přidáš uzel.'**
  String get canvasHintEdit;

  /// No description provided for @canvasHintCalibrate.
  ///
  /// In cs, this message translates to:
  /// **'Klepni na začátek a konec úsečky, jejíž délku znáš (třeba plot nebo stěna domu).'**
  String get canvasHintCalibrate;

  /// No description provided for @canvasHintMeasure.
  ///
  /// In cs, this message translates to:
  /// **'Pro kontrolu klepni na začátek a konec jiné známé vzdálenosti.'**
  String get canvasHintMeasure;

  /// No description provided for @canvasDone.
  ///
  /// In cs, this message translates to:
  /// **'Hotovo'**
  String get canvasDone;

  /// No description provided for @canvasDiscard.
  ///
  /// In cs, this message translates to:
  /// **'Zahodit'**
  String get canvasDiscard;

  /// No description provided for @canvasEditNodes.
  ///
  /// In cs, this message translates to:
  /// **'Upravit uzly'**
  String get canvasEditNodes;

  /// No description provided for @canvasEditDone.
  ///
  /// In cs, this message translates to:
  /// **'Hotovo s úpravou'**
  String get canvasEditDone;

  /// No description provided for @canvasDeleteVertex.
  ///
  /// In cs, this message translates to:
  /// **'Smazat uzel'**
  String get canvasDeleteVertex;

  /// No description provided for @canvasRemoveShape.
  ///
  /// In cs, this message translates to:
  /// **'Odebrat z plánu'**
  String get canvasRemoveShape;

  /// No description provided for @canvasRemoveOutline.
  ///
  /// In cs, this message translates to:
  /// **'Smazat obrys'**
  String get canvasRemoveOutline;

  /// No description provided for @canvasRealize.
  ///
  /// In cs, this message translates to:
  /// **'Zrealizovat'**
  String get canvasRealize;

  /// No description provided for @canvasRealizedActivity.
  ///
  /// In cs, this message translates to:
  /// **'Zrealizováno podle plánu: {name}'**
  String canvasRealizedActivity(String name);

  /// No description provided for @canvasRealized.
  ///
  /// In cs, this message translates to:
  /// **'{name} je teď v Realitě a v deníku přibyl záznam.'**
  String canvasRealized(String name);

  /// No description provided for @canvasSelectedOutline.
  ///
  /// In cs, this message translates to:
  /// **'Obrys zahrady · {area} m²'**
  String canvasSelectedOutline(String area);

  /// No description provided for @canvasSelectedZone.
  ///
  /// In cs, this message translates to:
  /// **'{name} · {area} m²'**
  String canvasSelectedZone(String name, String area);

  /// No description provided for @canvasSelectedPlanned.
  ///
  /// In cs, this message translates to:
  /// **'{name} · {area} m² · v návrhu'**
  String canvasSelectedPlanned(String name, String area);

  /// No description provided for @canvasAssignTitle.
  ///
  /// In cs, this message translates to:
  /// **'Ke které zóně tvar patří?'**
  String get canvasAssignTitle;

  /// No description provided for @canvasAssignNew.
  ///
  /// In cs, this message translates to:
  /// **'Nová zóna'**
  String get canvasAssignNew;

  /// No description provided for @canvasAssignNewName.
  ///
  /// In cs, this message translates to:
  /// **'Název nové zóny'**
  String get canvasAssignNewName;

  /// No description provided for @canvasAssignCreate.
  ///
  /// In cs, this message translates to:
  /// **'Vytvořit zónu'**
  String get canvasAssignCreate;

  /// No description provided for @canvasAssignPlanned.
  ///
  /// In cs, this message translates to:
  /// **'Nová zóna půjde do vrstvy Návrh.'**
  String get canvasAssignPlanned;

  /// No description provided for @canvasOutsideOutline.
  ///
  /// In cs, this message translates to:
  /// **'Zóna přesahuje obrys zahrady. Zkontroluj uzly.'**
  String get canvasOutsideOutline;

  /// No description provided for @canvasAreaSuggest.
  ///
  /// In cs, this message translates to:
  /// **'Podle plánu má {name} {plan} m², zadáno je {current} m².'**
  String canvasAreaSuggest(String name, String plan, String current);

  /// No description provided for @canvasAreaUse.
  ///
  /// In cs, this message translates to:
  /// **'Použít'**
  String get canvasAreaUse;

  /// No description provided for @canvasLengthTitle.
  ///
  /// In cs, this message translates to:
  /// **'Skutečná délka'**
  String get canvasLengthTitle;

  /// No description provided for @canvasLengthLabel.
  ///
  /// In cs, this message translates to:
  /// **'Délka v metrech'**
  String get canvasLengthLabel;

  /// No description provided for @canvasLengthInvalid.
  ///
  /// In cs, this message translates to:
  /// **'Zadej kladné číslo.'**
  String get canvasLengthInvalid;

  /// No description provided for @canvasLengthDrawn.
  ///
  /// In cs, this message translates to:
  /// **'Na plánu teď {length} m.'**
  String canvasLengthDrawn(String length);

  /// No description provided for @canvasCalibrated.
  ///
  /// In cs, this message translates to:
  /// **'Plán je přepočtený na metry. Pro kontrolu změř ještě jednu známou vzdálenost.'**
  String get canvasCalibrated;

  /// No description provided for @canvasDeviationOk.
  ///
  /// In cs, this message translates to:
  /// **'Odchylka {value} %, měřítko sedí.'**
  String canvasDeviationOk(String value);

  /// No description provided for @canvasDeviationBad.
  ///
  /// In cs, this message translates to:
  /// **'Odchylka {value} % je víc než 5 %. Podklad je asi zkreslený (šikmá fotka, nepřesný plánek).'**
  String canvasDeviationBad(String value);

  /// No description provided for @canvasBackgroundPick.
  ///
  /// In cs, this message translates to:
  /// **'Vložit podklad'**
  String get canvasBackgroundPick;

  /// No description provided for @canvasBackgroundRemove.
  ///
  /// In cs, this message translates to:
  /// **'Odebrat podklad'**
  String get canvasBackgroundRemove;

  /// No description provided for @canvasBackgroundHelp.
  ///
  /// In cs, this message translates to:
  /// **'Fotka plánku nebo snímek mapy, který máš u sebe. Pak plán zkalibruj podle známé délky.'**
  String get canvasBackgroundHelp;

  /// No description provided for @canvasBackgroundFailed.
  ///
  /// In cs, this message translates to:
  /// **'Obrázek se nepodařilo načíst.'**
  String get canvasBackgroundFailed;

  /// No description provided for @canvasMore.
  ///
  /// In cs, this message translates to:
  /// **'Další volby'**
  String get canvasMore;

  /// No description provided for @canvasSemantics.
  ///
  /// In cs, this message translates to:
  /// **'Plán zahrady, {count, plural, =0{žádná zóna} =1{1 zóna} few{{count} zóny} other{{count} zón}}'**
  String canvasSemantics(int count);

  /// No description provided for @movementPurchase.
  ///
  /// In cs, this message translates to:
  /// **'Nákup'**
  String get movementPurchase;

  /// No description provided for @movementTask.
  ///
  /// In cs, this message translates to:
  /// **'Odpis úkolem'**
  String get movementTask;

  /// No description provided for @movementManual.
  ///
  /// In cs, this message translates to:
  /// **'Ruční úprava'**
  String get movementManual;

  /// No description provided for @movementReversal.
  ///
  /// In cs, this message translates to:
  /// **'Storno odpisu'**
  String get movementReversal;

  /// No description provided for @movementHistoryTitle.
  ///
  /// In cs, this message translates to:
  /// **'Pohyby na skladě'**
  String get movementHistoryTitle;

  /// No description provided for @stockConsumed.
  ///
  /// In cs, this message translates to:
  /// **'Ze skladu odepsáno: {items}.'**
  String stockConsumed(String items);

  /// No description provided for @stockShortage.
  ///
  /// In cs, this message translates to:
  /// **'Na skladě chybělo: {items}. Doplň zásobu.'**
  String stockShortage(String items);

  /// No description provided for @stockSkipped.
  ///
  /// In cs, this message translates to:
  /// **'Neodepsáno (jiná jednotka nebo smazaná položka): {items}.'**
  String stockSkipped(String items);

  /// No description provided for @incidentsTitle.
  ///
  /// In cs, this message translates to:
  /// **'Problémy na zahradě'**
  String get incidentsTitle;

  /// No description provided for @incidentsCardSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Choroby, škůdci a jiné potíže s plánem řešení a kontrolami'**
  String get incidentsCardSubtitle;

  /// No description provided for @incidentsCardOpen.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, =0{Žádný otevřený problém} =1{1 otevřený problém} few{{count} otevřené problémy} other{{count} otevřených problémů}}'**
  String incidentsCardOpen(int count);

  /// No description provided for @incidentsEmpty.
  ///
  /// In cs, this message translates to:
  /// **'Zatím žádný problém. Když uvidíš mšice, plíseň nebo jiné potíže, zapiš je sem: Bóďa naplánuje kontroly za 3 a za 7 dní.'**
  String get incidentsEmpty;

  /// No description provided for @incidentNew.
  ///
  /// In cs, this message translates to:
  /// **'Nový problém'**
  String get incidentNew;

  /// No description provided for @incidentEditTitle.
  ///
  /// In cs, this message translates to:
  /// **'Upravit problém'**
  String get incidentEditTitle;

  /// No description provided for @incidentLabel.
  ///
  /// In cs, this message translates to:
  /// **'Co se děje'**
  String get incidentLabel;

  /// No description provided for @incidentLabelHint.
  ///
  /// In cs, this message translates to:
  /// **'Např. mšice na rybízu'**
  String get incidentLabelHint;

  /// No description provided for @incidentLabelRequired.
  ///
  /// In cs, this message translates to:
  /// **'Napiš, co se děje.'**
  String get incidentLabelRequired;

  /// No description provided for @incidentZoneRequired.
  ///
  /// In cs, this message translates to:
  /// **'Vyber zónu.'**
  String get incidentZoneRequired;

  /// No description provided for @incidentPhotos.
  ///
  /// In cs, this message translates to:
  /// **'Fotky (první je „před“, poslední „po“)'**
  String get incidentPhotos;

  /// No description provided for @incidentPlanBio.
  ///
  /// In cs, this message translates to:
  /// **'Šetrné řešení'**
  String get incidentPlanBio;

  /// No description provided for @incidentPlanBioHelper.
  ///
  /// In cs, this message translates to:
  /// **'Nejdřív bez chemie: ruční sběr, vodní sprcha, sítě, užitečný hmyz, výluhy.'**
  String get incidentPlanBioHelper;

  /// No description provided for @incidentPlanChem.
  ///
  /// In cs, this message translates to:
  /// **'Chemické řešení (nepovinné)'**
  String get incidentPlanChem;

  /// No description provided for @incidentPlanChemHelper.
  ///
  /// In cs, this message translates to:
  /// **'Jen přípravek povolený pro neprofesionální uživatele. Dávku a ochrannou lhůtu ber z etikety, ne odjinud, a dbej na ochranu včel.'**
  String get incidentPlanChemHelper;

  /// No description provided for @incidentChecksNote.
  ///
  /// In cs, this message translates to:
  /// **'Po uložení přibudou úkoly zkontrolovat stav za 3 a za 7 dní.'**
  String get incidentChecksNote;

  /// No description provided for @incidentCheckTask.
  ///
  /// In cs, this message translates to:
  /// **'Kontrola po {days} dnech: {label}'**
  String incidentCheckTask(int days, String label);

  /// No description provided for @incidentCreated.
  ///
  /// In cs, this message translates to:
  /// **'Problém je zapsaný, kontroly jsou v úkolech.'**
  String get incidentCreated;

  /// No description provided for @incidentSaveFailed.
  ///
  /// In cs, this message translates to:
  /// **'Problém se nepodařilo uložit.'**
  String get incidentSaveFailed;

  /// No description provided for @incidentOpen.
  ///
  /// In cs, this message translates to:
  /// **'Otevřený'**
  String get incidentOpen;

  /// No description provided for @incidentResolved.
  ///
  /// In cs, this message translates to:
  /// **'Vyřešeno'**
  String get incidentResolved;

  /// No description provided for @incidentResolve.
  ///
  /// In cs, this message translates to:
  /// **'Označit jako vyřešené'**
  String get incidentResolve;

  /// No description provided for @incidentReopen.
  ///
  /// In cs, this message translates to:
  /// **'Znovu otevřít'**
  String get incidentReopen;

  /// No description provided for @incidentBeforeAfter.
  ///
  /// In cs, this message translates to:
  /// **'Před a po'**
  String get incidentBeforeAfter;

  /// No description provided for @incidentCandidates.
  ///
  /// In cs, this message translates to:
  /// **'Možné příčiny'**
  String get incidentCandidates;

  /// No description provided for @incidentChecks.
  ///
  /// In cs, this message translates to:
  /// **'Kontroly'**
  String get incidentChecks;

  /// No description provided for @incidentCheckDone.
  ///
  /// In cs, this message translates to:
  /// **'Zkontrolováno'**
  String get incidentCheckDone;

  /// No description provided for @incidentCheckSkipped.
  ///
  /// In cs, this message translates to:
  /// **'Vynecháno'**
  String get incidentCheckSkipped;

  /// No description provided for @incidentDeleteTitle.
  ///
  /// In cs, this message translates to:
  /// **'Smazat problém?'**
  String get incidentDeleteTitle;

  /// No description provided for @incidentGone.
  ///
  /// In cs, this message translates to:
  /// **'Tenhle problém už neexistuje.'**
  String get incidentGone;

  /// No description provided for @incidentDeleteBody.
  ///
  /// In cs, this message translates to:
  /// **'Smaže se karta „{label}“ i její fotky. Otevřené kontroly k ní se přeskočí.'**
  String incidentDeleteBody(String label);

  /// No description provided for @weatherTitle.
  ///
  /// In cs, this message translates to:
  /// **'Počasí a kalendář prací'**
  String get weatherTitle;

  /// No description provided for @weatherCardSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Zálivka podle deště, mráz a co je teď na řadě'**
  String get weatherCardSubtitle;

  /// No description provided for @weatherSiteTitle.
  ///
  /// In cs, this message translates to:
  /// **'Poloha zahrady'**
  String get weatherSiteTitle;

  /// No description provided for @weatherSiteNotSet.
  ///
  /// In cs, this message translates to:
  /// **'Poloha není zadaná. Bez ní nejde stáhnout počasí.'**
  String get weatherSiteNotSet;

  /// No description provided for @weatherSiteSummary.
  ///
  /// In cs, this message translates to:
  /// **'{lat}, {lng} · {altitude}'**
  String weatherSiteSummary(String lat, String lng, String altitude);

  /// No description provided for @weatherAltitudeValue.
  ///
  /// In cs, this message translates to:
  /// **'{meters} m n. m.'**
  String weatherAltitudeValue(String meters);

  /// No description provided for @weatherAltitudeFromWeather.
  ///
  /// In cs, this message translates to:
  /// **'{meters} m n. m. (podle počasí)'**
  String weatherAltitudeFromWeather(String meters);

  /// No description provided for @weatherAltitudeUnknown.
  ///
  /// In cs, this message translates to:
  /// **'výška nezadaná'**
  String get weatherAltitudeUnknown;

  /// No description provided for @weatherSiteEdit.
  ///
  /// In cs, this message translates to:
  /// **'Upravit polohu'**
  String get weatherSiteEdit;

  /// No description provided for @weatherSiteSet.
  ///
  /// In cs, this message translates to:
  /// **'Zadat polohu'**
  String get weatherSiteSet;

  /// No description provided for @weatherLocationIntro.
  ///
  /// In cs, this message translates to:
  /// **'Poloha slouží jen pro počasí a kalendář prací. Ukládá se zaokrouhlená na zhruba 1 km.'**
  String get weatherLocationIntro;

  /// No description provided for @weatherLatLabel.
  ///
  /// In cs, this message translates to:
  /// **'Zeměpisná šířka'**
  String get weatherLatLabel;

  /// No description provided for @weatherLatHint.
  ///
  /// In cs, this message translates to:
  /// **'např. 49,19'**
  String get weatherLatHint;

  /// No description provided for @weatherLngLabel.
  ///
  /// In cs, this message translates to:
  /// **'Zeměpisná délka'**
  String get weatherLngLabel;

  /// No description provided for @weatherLngHint.
  ///
  /// In cs, this message translates to:
  /// **'např. 16,61'**
  String get weatherLngHint;

  /// No description provided for @weatherAltitudeLabel.
  ///
  /// In cs, this message translates to:
  /// **'Nadmořská výška (m)'**
  String get weatherAltitudeLabel;

  /// No description provided for @weatherAltitudeHelper.
  ///
  /// In cs, this message translates to:
  /// **'Nepovinné. Když ji nezadáš, vezme se z počasí.'**
  String get weatherAltitudeHelper;

  /// No description provided for @weatherUseDeviceLocation.
  ///
  /// In cs, this message translates to:
  /// **'Použít polohu telefonu'**
  String get weatherUseDeviceLocation;

  /// No description provided for @weatherClearLocation.
  ///
  /// In cs, this message translates to:
  /// **'Smazat polohu'**
  String get weatherClearLocation;

  /// No description provided for @weatherInvalidCoordinate.
  ///
  /// In cs, this message translates to:
  /// **'Zadej číslo, například 49,19'**
  String get weatherInvalidCoordinate;

  /// No description provided for @weatherImplausibleLocation.
  ///
  /// In cs, this message translates to:
  /// **'Tahle poloha neleží v Česku. Nejsou šířka a délka prohozené?'**
  String get weatherImplausibleLocation;

  /// No description provided for @weatherAltitudeInvalid.
  ///
  /// In cs, this message translates to:
  /// **'Zadej výšku v metrech (0 až 2000)'**
  String get weatherAltitudeInvalid;

  /// No description provided for @weatherLocationIncomplete.
  ///
  /// In cs, this message translates to:
  /// **'Vyplň šířku i délku, nebo obojí nech prázdné.'**
  String get weatherLocationIncomplete;

  /// No description provided for @weatherDeviceLocationDisabled.
  ///
  /// In cs, this message translates to:
  /// **'Poloha v telefonu je vypnutá.'**
  String get weatherDeviceLocationDisabled;

  /// No description provided for @weatherDeviceLocationDenied.
  ///
  /// In cs, this message translates to:
  /// **'Aplikace nemá povolení k poloze. Zadej ji ručně.'**
  String get weatherDeviceLocationDenied;

  /// No description provided for @weatherDeviceLocationFailed.
  ///
  /// In cs, this message translates to:
  /// **'Polohu telefonu se nepodařilo zjistit.'**
  String get weatherDeviceLocationFailed;

  /// No description provided for @weatherDeviceLocationUnsupported.
  ///
  /// In cs, this message translates to:
  /// **'Tady polohu telefonu zjistit nejde. Zadej ji ručně.'**
  String get weatherDeviceLocationUnsupported;

  /// No description provided for @weatherSectionForecast.
  ///
  /// In cs, this message translates to:
  /// **'Počasí'**
  String get weatherSectionForecast;

  /// No description provided for @weatherUnavailable.
  ///
  /// In cs, this message translates to:
  /// **'Počasí potřebuje připojení k serveru, které tahle verze aplikace nemá.'**
  String get weatherUnavailable;

  /// No description provided for @weatherNotSignedIn.
  ///
  /// In cs, this message translates to:
  /// **'Pro počasí se přihlas v Nastavení, v části Účet.'**
  String get weatherNotSignedIn;

  /// No description provided for @weatherNotPremium.
  ///
  /// In cs, this message translates to:
  /// **'Počasí a zálivka podle deště jsou v Premium. Kalendář prací je zdarma.'**
  String get weatherNotPremium;

  /// No description provided for @weatherShowPremium.
  ///
  /// In cs, this message translates to:
  /// **'Zobrazit Premium'**
  String get weatherShowPremium;

  /// No description provided for @weatherNoLocation.
  ///
  /// In cs, this message translates to:
  /// **'Zadej polohu zahrady a počasí se stáhne.'**
  String get weatherNoLocation;

  /// No description provided for @weatherOffline.
  ///
  /// In cs, this message translates to:
  /// **'Bez připojení. Zkusím to znovu později.'**
  String get weatherOffline;

  /// No description provided for @weatherProviderError.
  ///
  /// In cs, this message translates to:
  /// **'Počasí se teď nepodařilo stáhnout.'**
  String get weatherProviderError;

  /// No description provided for @weatherRetry.
  ///
  /// In cs, this message translates to:
  /// **'Zkusit znovu'**
  String get weatherRetry;

  /// No description provided for @weatherFetchedAt.
  ///
  /// In cs, this message translates to:
  /// **'Staženo {time}'**
  String weatherFetchedAt(String time);

  /// No description provided for @weatherRainLast7.
  ///
  /// In cs, this message translates to:
  /// **'Za posledních 7 dní napršelo {mm} mm'**
  String weatherRainLast7(String mm);

  /// No description provided for @weatherDayRow.
  ///
  /// In cs, this message translates to:
  /// **'{precip} mm · {tmin} až {tmax} °C'**
  String weatherDayRow(String precip, String tmin, String tmax);

  /// No description provided for @weatherDayRowNoTemp.
  ///
  /// In cs, this message translates to:
  /// **'{precip} mm'**
  String weatherDayRowNoTemp(String precip);

  /// No description provided for @weatherSectionWatering.
  ///
  /// In cs, this message translates to:
  /// **'Zálivka'**
  String get weatherSectionWatering;

  /// No description provided for @weatherWateringEmpty.
  ///
  /// In cs, this message translates to:
  /// **'Žádná zóna teď zálivku neřeší.'**
  String get weatherWateringEmpty;

  /// No description provided for @weatherAdviceRained.
  ///
  /// In cs, this message translates to:
  /// **'Může počkat: napršelo {mm} mm (práh {threshold} mm)'**
  String weatherAdviceRained(String mm, String threshold);

  /// No description provided for @weatherAdviceRainExpected.
  ///
  /// In cs, this message translates to:
  /// **'Může počkat: do zítřka má pršet'**
  String get weatherAdviceRainExpected;

  /// No description provided for @weatherAdviceWater.
  ///
  /// In cs, this message translates to:
  /// **'Zalij podle potřeby: napršelo {mm} z {threshold} mm'**
  String weatherAdviceWater(String mm, String threshold);

  /// No description provided for @weatherAdviceCovered.
  ///
  /// In cs, this message translates to:
  /// **'Krytá zóna: déšť nedostane, zalij podle potřeby'**
  String get weatherAdviceCovered;

  /// No description provided for @weatherPostponeButton.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, =1{Odložit 1 zálivku} few{Odložit {count} zálivky} other{Odložit {count} zálivek}}'**
  String weatherPostponeButton(int count);

  /// No description provided for @weatherPostponed.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, =1{Zálivka odložena o den} few{{count} zálivky odloženy o den} other{{count} zálivek odloženo o den}}'**
  String weatherPostponed(int count);

  /// No description provided for @weatherAutoPostpone.
  ///
  /// In cs, this message translates to:
  /// **'Odkládat zálivku automaticky'**
  String get weatherAutoPostpone;

  /// No description provided for @weatherAutoPostponeSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Jednou denně po stažení počasí, když napršelo nebo má pršet'**
  String get weatherAutoPostponeSubtitle;

  /// No description provided for @weatherFrostTitle.
  ///
  /// In cs, this message translates to:
  /// **'Mráz {temp} °C {day}'**
  String weatherFrostTitle(String temp, String day);

  /// No description provided for @weatherFrostZones.
  ///
  /// In cs, this message translates to:
  /// **'Zakryj nebo ochraň: {zones}'**
  String weatherFrostZones(String zones);

  /// No description provided for @weatherSectionPhenology.
  ///
  /// In cs, this message translates to:
  /// **'Kalendář prací'**
  String get weatherSectionPhenology;

  /// No description provided for @weatherPhenologyAltitude.
  ///
  /// In cs, this message translates to:
  /// **'Termíny jsou posunuté pro {altitude}. Řiď se i tím, jak jaro skutečně běží.'**
  String weatherPhenologyAltitude(String altitude);

  /// No description provided for @weatherPhenologyNow.
  ///
  /// In cs, this message translates to:
  /// **'Teď je čas'**
  String get weatherPhenologyNow;

  /// No description provided for @weatherPhenologySoon.
  ///
  /// In cs, this message translates to:
  /// **'Brzy přijde'**
  String get weatherPhenologySoon;

  /// No description provided for @weatherPhenologyEmpty.
  ///
  /// In cs, this message translates to:
  /// **'Teď ani v příštích třech týdnech podle kalendáře nic. Kalendář se řídí druhy zón, které na zahradě máš.'**
  String get weatherPhenologyEmpty;

  /// No description provided for @weatherPhenologyRange.
  ///
  /// In cs, this message translates to:
  /// **'{from} až {to}'**
  String weatherPhenologyRange(String from, String to);

  /// No description provided for @weatherPhenologyAddTask.
  ///
  /// In cs, this message translates to:
  /// **'Přidat jako úkol'**
  String get weatherPhenologyAddTask;

  /// No description provided for @weatherPhenologyTaskAdded.
  ///
  /// In cs, this message translates to:
  /// **'Úkol přidán'**
  String get weatherPhenologyTaskAdded;

  /// No description provided for @weatherPhenologyTaskExists.
  ///
  /// In cs, this message translates to:
  /// **'Takový úkol už v seznamu máš.'**
  String get weatherPhenologyTaskExists;

  /// No description provided for @weatherCardNow.
  ///
  /// In cs, this message translates to:
  /// **'Teď je čas: {items}'**
  String weatherCardNow(String items);

  /// No description provided for @weatherCardRained.
  ///
  /// In cs, this message translates to:
  /// **'Zálivka může počkat: napršelo {mm} mm'**
  String weatherCardRained(String mm);

  /// No description provided for @weatherCardRainExpected.
  ///
  /// In cs, this message translates to:
  /// **'Zálivka může počkat: do zítřka má pršet'**
  String get weatherCardRainExpected;

  /// No description provided for @diagnosisButton.
  ///
  /// In cs, this message translates to:
  /// **'Zkusit poznat z fotky'**
  String get diagnosisButton;

  /// No description provided for @diagnosisButtonHelper.
  ///
  /// In cs, this message translates to:
  /// **'Bóďa tipne 1 až 3 možné příčiny. Premium, počítá se do měsíčního limitu dotazů.'**
  String get diagnosisButtonHelper;

  /// No description provided for @diagnosisRunning.
  ///
  /// In cs, this message translates to:
  /// **'Bóďa si fotku prohlíží…'**
  String get diagnosisRunning;

  /// No description provided for @diagnosisConsentTitle.
  ///
  /// In cs, this message translates to:
  /// **'Poslat fotku k diagnóze?'**
  String get diagnosisConsentTitle;

  /// No description provided for @diagnosisConsentBody.
  ///
  /// In cs, this message translates to:
  /// **'První fotka se odešle poskytovateli umělé inteligence přes náš server. Před odesláním z ní odstraníme polohu a další údaje z fotoaparátu. Fotka se u nás neukládá a souhlas můžeš kdykoli odvolat v Nastavení, v části Souhlasy.'**
  String get diagnosisConsentBody;

  /// No description provided for @diagnosisConsentAgree.
  ///
  /// In cs, this message translates to:
  /// **'Souhlasím a poslat'**
  String get diagnosisConsentAgree;

  /// No description provided for @diagnosisResultTitle.
  ///
  /// In cs, this message translates to:
  /// **'Možná jde o…'**
  String get diagnosisResultTitle;

  /// No description provided for @diagnosisDisclaimer.
  ///
  /// In cs, this message translates to:
  /// **'Je to jen tip, ne jistá diagnóza. Ověř ho podle popisu, a když si nevíš rady, zeptej se v zahradnictví.'**
  String get diagnosisDisclaimer;

  /// No description provided for @diagnosisCheck.
  ///
  /// In cs, this message translates to:
  /// **'Ověř: {text}'**
  String diagnosisCheck(String text);

  /// No description provided for @diagnosisCare.
  ///
  /// In cs, this message translates to:
  /// **'Šetrně: {text}'**
  String diagnosisCare(String text);

  /// No description provided for @diagnosisUse.
  ///
  /// In cs, this message translates to:
  /// **'Použít'**
  String get diagnosisUse;

  /// No description provided for @diagnosisUnclear.
  ///
  /// In cs, this message translates to:
  /// **'Z fotky nejde nic spolehlivě poznat. Zkus ji vyfotit zblízka a na světle.'**
  String get diagnosisUnclear;

  /// No description provided for @diagnosisUnavailable.
  ///
  /// In cs, this message translates to:
  /// **'Diagnostika potřebuje připojení k serveru, které tahle verze aplikace nemá.'**
  String get diagnosisUnavailable;

  /// No description provided for @diagnosisNotSignedIn.
  ///
  /// In cs, this message translates to:
  /// **'Pro diagnostiku se přihlas v Nastavení, v části Účet.'**
  String get diagnosisNotSignedIn;

  /// No description provided for @diagnosisNotPremium.
  ///
  /// In cs, this message translates to:
  /// **'Diagnostika z fotek je v Premium.'**
  String get diagnosisNotPremium;

  /// No description provided for @diagnosisNoConsent.
  ///
  /// In cs, this message translates to:
  /// **'Bez souhlasu s odesláním fotek diagnostika nejde.'**
  String get diagnosisNoConsent;

  /// No description provided for @diagnosisLimitReached.
  ///
  /// In cs, this message translates to:
  /// **'Tento měsíc už je limit dotazů vyčerpaný.'**
  String get diagnosisLimitReached;

  /// No description provided for @diagnosisBadImage.
  ///
  /// In cs, this message translates to:
  /// **'Tuhle fotku nejde poslat. Zkus jinou, nebo ji vyfoť znovu.'**
  String get diagnosisBadImage;

  /// No description provided for @diagnosisOffline.
  ///
  /// In cs, this message translates to:
  /// **'Bez připojení. Zkus to, až budeš online.'**
  String get diagnosisOffline;

  /// No description provided for @diagnosisFailed.
  ///
  /// In cs, this message translates to:
  /// **'Diagnostika se teď nepovedla. Zkus to později.'**
  String get diagnosisFailed;

  /// No description provided for @consentsPhoto.
  ///
  /// In cs, this message translates to:
  /// **'Diagnostika z fotek'**
  String get consentsPhoto;

  /// No description provided for @consentsPhotoOn.
  ///
  /// In cs, this message translates to:
  /// **'Souhlas od {date}'**
  String consentsPhotoOn(String date);

  /// No description provided for @consentsPhotoOff.
  ///
  /// In cs, this message translates to:
  /// **'Bez souhlasu'**
  String get consentsPhotoOff;

  /// No description provided for @consentsPhotoHelp.
  ///
  /// In cs, this message translates to:
  /// **'Fotka problému se odešle poskytovateli umělé inteligence. Polohu a údaje z fotoaparátu před odesláním odstraníme.'**
  String get consentsPhotoHelp;

  /// No description provided for @sharingTitle.
  ///
  /// In cs, this message translates to:
  /// **'Sdílení zahrady'**
  String get sharingTitle;

  /// No description provided for @sharingTileSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Pozvi rodinu, ať zapisujete do jedné zahrady'**
  String get sharingTileSubtitle;

  /// No description provided for @sharingIntro.
  ///
  /// In cs, this message translates to:
  /// **'Členové vidí a zapisují všechno v zahradě: zóny, deník, úkoly, sklad i plán. Změny se mezi telefony přenesou synchronizací.'**
  String get sharingIntro;

  /// No description provided for @sharingMembers.
  ///
  /// In cs, this message translates to:
  /// **'Členové'**
  String get sharingMembers;

  /// No description provided for @sharingRoleOwner.
  ///
  /// In cs, this message translates to:
  /// **'Vlastník'**
  String get sharingRoleOwner;

  /// No description provided for @sharingRoleEditor.
  ///
  /// In cs, this message translates to:
  /// **'Člen'**
  String get sharingRoleEditor;

  /// No description provided for @sharingRoleViewer.
  ///
  /// In cs, this message translates to:
  /// **'Jen čtení'**
  String get sharingRoleViewer;

  /// No description provided for @sharingYou.
  ///
  /// In cs, this message translates to:
  /// **'{name} (ty)'**
  String sharingYou(String name);

  /// No description provided for @sharingNotSynced.
  ///
  /// In cs, this message translates to:
  /// **'Zahrada ještě není nahraná na server. Počkej na synchronizaci a zkus to znovu.'**
  String get sharingNotSynced;

  /// No description provided for @sharingInvite.
  ///
  /// In cs, this message translates to:
  /// **'Pozvat člena'**
  String get sharingInvite;

  /// No description provided for @sharingInviteHelp.
  ///
  /// In cs, this message translates to:
  /// **'Pozvat může vlastník s Premium. Kód platí 7 dní a jde použít jednou.'**
  String get sharingInviteHelp;

  /// No description provided for @sharingInviteCode.
  ///
  /// In cs, this message translates to:
  /// **'Kód pozvánky'**
  String get sharingInviteCode;

  /// No description provided for @sharingInviteValid.
  ///
  /// In cs, this message translates to:
  /// **'Platí do {date}'**
  String sharingInviteValid(String date);

  /// No description provided for @sharingInviteShare.
  ///
  /// In cs, this message translates to:
  /// **'Poslat kód'**
  String get sharingInviteShare;

  /// No description provided for @sharingInviteShareText.
  ///
  /// In cs, this message translates to:
  /// **'Připoj se k mé zahradě v aplikaci Zahradník Bóďa: v Nastavení otevři Účet, Sdílení zahrady a zadej kód {code}. Kód platí do {date}.'**
  String sharingInviteShareText(String code, String date);

  /// No description provided for @sharingJoin.
  ///
  /// In cs, this message translates to:
  /// **'Připojit se ke sdílené zahradě'**
  String get sharingJoin;

  /// No description provided for @sharingJoinHelp.
  ///
  /// In cs, this message translates to:
  /// **'Máš kód od někoho z rodiny? Zadej ho tady.'**
  String get sharingJoinHelp;

  /// No description provided for @sharingJoinCode.
  ///
  /// In cs, this message translates to:
  /// **'Kód (8 znaků)'**
  String get sharingJoinCode;

  /// No description provided for @sharingJoinInvalid.
  ///
  /// In cs, this message translates to:
  /// **'Kód má 8 písmen a číslic, například ABCD-EFGH.'**
  String get sharingJoinInvalid;

  /// No description provided for @sharingJoinConfirmTitle.
  ///
  /// In cs, this message translates to:
  /// **'Připojit se ke sdílené zahradě?'**
  String get sharingJoinConfirmTitle;

  /// No description provided for @sharingJoinConfirmBody.
  ///
  /// In cs, this message translates to:
  /// **'Data v tomto telefonu nahradí sdílená zahrada. Tvoje dosavadní zahrada zůstane v účtu, změny z telefonu se před přepnutím odešlou.'**
  String get sharingJoinConfirmBody;

  /// No description provided for @sharingJoinConfirm.
  ///
  /// In cs, this message translates to:
  /// **'Připojit se'**
  String get sharingJoinConfirm;

  /// No description provided for @sharingJoinAlready.
  ///
  /// In cs, this message translates to:
  /// **'Do téhle zahrady už patříš.'**
  String get sharingJoinAlready;

  /// No description provided for @sharingRemove.
  ///
  /// In cs, this message translates to:
  /// **'Odebrat'**
  String get sharingRemove;

  /// No description provided for @sharingRemoveTitle.
  ///
  /// In cs, this message translates to:
  /// **'Odebrat člena?'**
  String get sharingRemoveTitle;

  /// No description provided for @sharingRemoveBody.
  ///
  /// In cs, this message translates to:
  /// **'{name} přestane vidět zahradu a nebude do ní moct zapisovat.'**
  String sharingRemoveBody(String name);

  /// No description provided for @sharingRemoved.
  ///
  /// In cs, this message translates to:
  /// **'Člen odebrán'**
  String get sharingRemoved;

  /// No description provided for @sharingLeave.
  ///
  /// In cs, this message translates to:
  /// **'Opustit sdílenou zahradu'**
  String get sharingLeave;

  /// No description provided for @sharingLeaveTitle.
  ///
  /// In cs, this message translates to:
  /// **'Opustit sdílenou zahradu?'**
  String get sharingLeaveTitle;

  /// No description provided for @sharingLeaveBody.
  ///
  /// In cs, this message translates to:
  /// **'Zahrada z tohoto telefonu zmizí a začneš s novou prázdnou zahradou. Ostatním členům zůstane.'**
  String get sharingLeaveBody;

  /// No description provided for @sharingLeaveConfirm.
  ///
  /// In cs, this message translates to:
  /// **'Opustit'**
  String get sharingLeaveConfirm;

  /// No description provided for @sharingNewGardenName.
  ///
  /// In cs, this message translates to:
  /// **'Moje zahrada'**
  String get sharingNewGardenName;

  /// No description provided for @sharingUnavailable.
  ///
  /// In cs, this message translates to:
  /// **'Sdílení potřebuje připojení k serveru, které tahle verze aplikace nemá.'**
  String get sharingUnavailable;

  /// No description provided for @sharingNotSignedIn.
  ///
  /// In cs, this message translates to:
  /// **'Pro sdílení se nejdřív přihlas.'**
  String get sharingNotSignedIn;

  /// No description provided for @sharingNotPremium.
  ///
  /// In cs, this message translates to:
  /// **'Pozvat člena může vlastník s Premium.'**
  String get sharingNotPremium;

  /// No description provided for @sharingNotOwner.
  ///
  /// In cs, this message translates to:
  /// **'Tohle může jen vlastník zahrady.'**
  String get sharingNotOwner;

  /// No description provided for @sharingInvalidCode.
  ///
  /// In cs, this message translates to:
  /// **'Kód neplatí. Možná už vypršel nebo byl použitý; požádej o nový.'**
  String get sharingInvalidCode;

  /// No description provided for @sharingOffline.
  ///
  /// In cs, this message translates to:
  /// **'Bez připojení. Zkus to, až budeš online.'**
  String get sharingOffline;

  /// No description provided for @sharingFailed.
  ///
  /// In cs, this message translates to:
  /// **'Nepovedlo se to. Zkus to znovu.'**
  String get sharingFailed;

  /// No description provided for @accountLostAccessTitle.
  ///
  /// In cs, this message translates to:
  /// **'Sdílená zahrada už není dostupná'**
  String get accountLostAccessTitle;

  /// No description provided for @accountLostAccessBody.
  ///
  /// In cs, this message translates to:
  /// **'Vlastník tě ze zahrady odebral, nebo ji přestal sdílet. Data v telefonu zůstala, ale nebudou se synchronizovat.'**
  String get accountLostAccessBody;

  /// No description provided for @accountLostAccessStart.
  ///
  /// In cs, this message translates to:
  /// **'Začít vlastní zahradu'**
  String get accountLostAccessStart;

  /// No description provided for @buildsTitle.
  ///
  /// In cs, this message translates to:
  /// **'Stavby'**
  String get buildsTitle;

  /// No description provided for @buildsCardSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Záhony, chodníky, mostky a přístřešky s výkazem materiálu a rozpočtem'**
  String get buildsCardSubtitle;

  /// No description provided for @buildsEmpty.
  ///
  /// In cs, this message translates to:
  /// **'Zatím žádný návrh. Vyber šablonu a uvidíš výkres, materiál i rozpočet.'**
  String get buildsEmpty;

  /// No description provided for @buildsNew.
  ///
  /// In cs, this message translates to:
  /// **'Nový návrh'**
  String get buildsNew;

  /// No description provided for @buildsChooseTemplate.
  ///
  /// In cs, this message translates to:
  /// **'Co chceš postavit?'**
  String get buildsChooseTemplate;

  /// No description provided for @buildsName.
  ///
  /// In cs, this message translates to:
  /// **'Název'**
  String get buildsName;

  /// No description provided for @buildsNameRequired.
  ///
  /// In cs, this message translates to:
  /// **'Zadej název'**
  String get buildsNameRequired;

  /// No description provided for @buildsFixParams.
  ///
  /// In cs, this message translates to:
  /// **'Nejdřív oprav parametry s chybou.'**
  String get buildsFixParams;

  /// No description provided for @buildsZone.
  ///
  /// In cs, this message translates to:
  /// **'Zóna'**
  String get buildsZone;

  /// No description provided for @buildsNoZone.
  ///
  /// In cs, this message translates to:
  /// **'Bez zóny'**
  String get buildsNoZone;

  /// No description provided for @buildsParams.
  ///
  /// In cs, this message translates to:
  /// **'Parametry'**
  String get buildsParams;

  /// No description provided for @buildsDrawingTop.
  ///
  /// In cs, this message translates to:
  /// **'Půdorys'**
  String get buildsDrawingTop;

  /// No description provided for @buildsDrawingSection.
  ///
  /// In cs, this message translates to:
  /// **'Příčný řez'**
  String get buildsDrawingSection;

  /// No description provided for @buildsChecks.
  ///
  /// In cs, this message translates to:
  /// **'Kontrola návrhu'**
  String get buildsChecks;

  /// No description provided for @buildsChecksOk.
  ///
  /// In cs, this message translates to:
  /// **'Návrh je v mezích orientačních limitů.'**
  String get buildsChecksOk;

  /// No description provided for @buildsMaterial.
  ///
  /// In cs, this message translates to:
  /// **'Výkaz materiálu'**
  String get buildsMaterial;

  /// No description provided for @buildsTotal.
  ///
  /// In cs, this message translates to:
  /// **'Celkem orientačně {total} Kč'**
  String buildsTotal(String total);

  /// No description provided for @buildsPricesNote.
  ///
  /// In cs, this message translates to:
  /// **'Ceny jsou orientační. Klepni na položku a zadej cenu ze svého obchodu.'**
  String get buildsPricesNote;

  /// No description provided for @buildsPriceTitle.
  ///
  /// In cs, this message translates to:
  /// **'Cena: {material}'**
  String buildsPriceTitle(String material);

  /// No description provided for @buildsPricePerUnit.
  ///
  /// In cs, this message translates to:
  /// **'Kč za {unit}'**
  String buildsPricePerUnit(String unit);

  /// No description provided for @buildsPriceReset.
  ///
  /// In cs, this message translates to:
  /// **'Výchozí cena'**
  String get buildsPriceReset;

  /// No description provided for @buildsLineTotal.
  ///
  /// In cs, this message translates to:
  /// **'{qty} {unit} × {price} Kč'**
  String buildsLineTotal(String qty, String unit, String price);

  /// No description provided for @buildsLineAmount.
  ///
  /// In cs, this message translates to:
  /// **'{amount} Kč'**
  String buildsLineAmount(String amount);

  /// No description provided for @buildsAddToShopping.
  ///
  /// In cs, this message translates to:
  /// **'Přidat na nákupní seznam'**
  String get buildsAddToShopping;

  /// No description provided for @buildsAddedToShopping.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, =0{Všechno už na nákupním seznamu je} =1{Na nákupní seznam přibyla 1 položka} few{Na nákupní seznam přibyly {count} položky} other{Na nákupní seznam přibylo {count} položek}}'**
  String buildsAddedToShopping(int count);

  /// No description provided for @buildsDelete.
  ///
  /// In cs, this message translates to:
  /// **'Smazat návrh'**
  String get buildsDelete;

  /// No description provided for @buildsDeleteTitle.
  ///
  /// In cs, this message translates to:
  /// **'Smazat návrh?'**
  String get buildsDeleteTitle;

  /// No description provided for @buildsDeleteBody.
  ///
  /// In cs, this message translates to:
  /// **'Návrh „{name}“ zmizí ze seznamu.'**
  String buildsDeleteBody(String name);

  /// No description provided for @buildsDeleted.
  ///
  /// In cs, this message translates to:
  /// **'Návrh smazán'**
  String get buildsDeleted;

  /// No description provided for @buildsSaved.
  ///
  /// In cs, this message translates to:
  /// **'Návrh uložen'**
  String get buildsSaved;

  /// No description provided for @buildsRangeError.
  ///
  /// In cs, this message translates to:
  /// **'Zadej číslo od {min} do {max}'**
  String buildsRangeError(String min, String max);

  /// No description provided for @buildsDiscardTitle.
  ///
  /// In cs, this message translates to:
  /// **'Zahodit změny v návrhu?'**
  String get buildsDiscardTitle;

  /// No description provided for @buildsDiscardKeep.
  ///
  /// In cs, this message translates to:
  /// **'Pokračovat v úpravách'**
  String get buildsDiscardKeep;

  /// No description provided for @buildsDiscardConfirm.
  ///
  /// In cs, this message translates to:
  /// **'Zahodit'**
  String get buildsDiscardConfirm;

  /// No description provided for @buildsDisclaimer.
  ///
  /// In cs, this message translates to:
  /// **'Orientační návrh, nejde o autorizovaný statický výpočet.'**
  String get buildsDisclaimer;

  /// No description provided for @buildsEngineer.
  ///
  /// In cs, this message translates to:
  /// **'Konstrukce nese osoby nad stanovenou mez. Než začneš stavět, nech návrh posoudit statikem.'**
  String get buildsEngineer;

  /// No description provided for @buildsUpdated.
  ///
  /// In cs, this message translates to:
  /// **'Upraveno {date}'**
  String buildsUpdated(String date);

  /// No description provided for @buildsSnowHelp.
  ///
  /// In cs, this message translates to:
  /// **'Podle mapy sněhových oblastí ČR: nížiny většinou I a II, vrchoviny III, hory IV a výš. Nad oblastí V nech přístřešek navrhnout statikem.'**
  String get buildsSnowHelp;

  /// No description provided for @buildTemplateRaisedBed.
  ///
  /// In cs, this message translates to:
  /// **'Vyvýšený záhon'**
  String get buildTemplateRaisedBed;

  /// No description provided for @buildTemplatePath.
  ///
  /// In cs, this message translates to:
  /// **'Chodník'**
  String get buildTemplatePath;

  /// No description provided for @buildTemplateBridge.
  ///
  /// In cs, this message translates to:
  /// **'Mostek'**
  String get buildTemplateBridge;

  /// No description provided for @buildTemplateShelter.
  ///
  /// In cs, this message translates to:
  /// **'Přístřešek'**
  String get buildTemplateShelter;

  /// No description provided for @buildTemplateRaisedBedHint.
  ///
  /// In cs, this message translates to:
  /// **'Prkna, sloupky, náplň a ochrana proti hryzcům'**
  String get buildTemplateRaisedBedHint;

  /// No description provided for @buildTemplatePathHint.
  ///
  /// In cs, this message translates to:
  /// **'Štěrk, dlažba, nášlapy nebo kůra včetně podkladu'**
  String get buildTemplatePathHint;

  /// No description provided for @buildTemplateBridgeHint.
  ///
  /// In cs, this message translates to:
  /// **'Lávka pro pěší přes jezírko nebo potok'**
  String get buildTemplateBridgeHint;

  /// No description provided for @buildTemplateShelterHint.
  ///
  /// In cs, this message translates to:
  /// **'Pultová střecha na sloupcích, třeba na dřevo nebo kola'**
  String get buildTemplateShelterHint;

  /// No description provided for @buildParamLength.
  ///
  /// In cs, this message translates to:
  /// **'Délka'**
  String get buildParamLength;

  /// No description provided for @buildParamWidth.
  ///
  /// In cs, this message translates to:
  /// **'Šířka'**
  String get buildParamWidth;

  /// No description provided for @buildParamHeight.
  ///
  /// In cs, this message translates to:
  /// **'Výška'**
  String get buildParamHeight;

  /// No description provided for @buildParamFrontHeight.
  ///
  /// In cs, this message translates to:
  /// **'Výška vpředu'**
  String get buildParamFrontHeight;

  /// No description provided for @buildParamBoardThickness.
  ///
  /// In cs, this message translates to:
  /// **'Tloušťka prken'**
  String get buildParamBoardThickness;

  /// No description provided for @buildParamMoleMesh.
  ///
  /// In cs, this message translates to:
  /// **'Pletivo proti hryzcům na dno'**
  String get buildParamMoleMesh;

  /// No description provided for @buildParamLiner.
  ///
  /// In cs, this message translates to:
  /// **'Fólie na vnitřní stěny'**
  String get buildParamLiner;

  /// No description provided for @buildParamSurface.
  ///
  /// In cs, this message translates to:
  /// **'Povrch'**
  String get buildParamSurface;

  /// No description provided for @buildParamEdging.
  ///
  /// In cs, this message translates to:
  /// **'Obrubník'**
  String get buildParamEdging;

  /// No description provided for @buildParamSpan.
  ///
  /// In cs, this message translates to:
  /// **'Rozpětí'**
  String get buildParamSpan;

  /// No description provided for @buildParamBeamSection.
  ///
  /// In cs, this message translates to:
  /// **'Průřez nosníků'**
  String get buildParamBeamSection;

  /// No description provided for @buildParamBeamCount.
  ///
  /// In cs, this message translates to:
  /// **'Počet nosníků'**
  String get buildParamBeamCount;

  /// No description provided for @buildParamDeckThickness.
  ///
  /// In cs, this message translates to:
  /// **'Tloušťka podlahových prken'**
  String get buildParamDeckThickness;

  /// No description provided for @buildParamHeightAbove.
  ///
  /// In cs, this message translates to:
  /// **'Výška nad hladinou nebo terénem'**
  String get buildParamHeightAbove;

  /// No description provided for @buildParamRailing.
  ///
  /// In cs, this message translates to:
  /// **'Zábradlí'**
  String get buildParamRailing;

  /// No description provided for @buildParamDepth.
  ///
  /// In cs, this message translates to:
  /// **'Hloubka'**
  String get buildParamDepth;

  /// No description provided for @buildParamRoofing.
  ///
  /// In cs, this message translates to:
  /// **'Krytina'**
  String get buildParamRoofing;

  /// No description provided for @buildParamRafterSection.
  ///
  /// In cs, this message translates to:
  /// **'Průřez krokví'**
  String get buildParamRafterSection;

  /// No description provided for @buildParamPostSection.
  ///
  /// In cs, this message translates to:
  /// **'Průřez sloupků'**
  String get buildParamPostSection;

  /// No description provided for @buildParamSnowRegion.
  ///
  /// In cs, this message translates to:
  /// **'Sněhová oblast'**
  String get buildParamSnowRegion;

  /// No description provided for @buildOptionMm.
  ///
  /// In cs, this message translates to:
  /// **'{mm} mm'**
  String buildOptionMm(String mm);

  /// No description provided for @buildOptionSection.
  ///
  /// In cs, this message translates to:
  /// **'{section} mm'**
  String buildOptionSection(String section);

  /// No description provided for @buildOptionGravel.
  ///
  /// In cs, this message translates to:
  /// **'Štěrk'**
  String get buildOptionGravel;

  /// No description provided for @buildOptionPavers.
  ///
  /// In cs, this message translates to:
  /// **'Betonová dlažba'**
  String get buildOptionPavers;

  /// No description provided for @buildOptionStepping.
  ///
  /// In cs, this message translates to:
  /// **'Nášlapné kameny'**
  String get buildOptionStepping;

  /// No description provided for @buildOptionMulch.
  ///
  /// In cs, this message translates to:
  /// **'Kůra nebo štěpka'**
  String get buildOptionMulch;

  /// No description provided for @buildOptionPolycarbonate.
  ///
  /// In cs, this message translates to:
  /// **'Polykarbonát'**
  String get buildOptionPolycarbonate;

  /// No description provided for @buildOptionMetalSheet.
  ///
  /// In cs, this message translates to:
  /// **'Trapézový plech'**
  String get buildOptionMetalSheet;

  /// No description provided for @buildUnitM.
  ///
  /// In cs, this message translates to:
  /// **'m'**
  String get buildUnitM;

  /// No description provided for @buildUnitM2.
  ///
  /// In cs, this message translates to:
  /// **'m²'**
  String get buildUnitM2;

  /// No description provided for @buildUnitM3.
  ///
  /// In cs, this message translates to:
  /// **'m³'**
  String get buildUnitM3;

  /// No description provided for @buildUnitT.
  ///
  /// In cs, this message translates to:
  /// **'t'**
  String get buildUnitT;

  /// No description provided for @buildUnitPcs.
  ///
  /// In cs, this message translates to:
  /// **'ks'**
  String get buildUnitPcs;

  /// No description provided for @buildUnitL.
  ///
  /// In cs, this message translates to:
  /// **'l'**
  String get buildUnitL;

  /// No description provided for @buildMaterialBoard25.
  ///
  /// In cs, this message translates to:
  /// **'Prkno modřín 25 × 145 mm'**
  String get buildMaterialBoard25;

  /// No description provided for @buildMaterialBoard32.
  ///
  /// In cs, this message translates to:
  /// **'Prkno modřín 32 × 145 mm'**
  String get buildMaterialBoard32;

  /// No description provided for @buildMaterialBoard40.
  ///
  /// In cs, this message translates to:
  /// **'Prkno modřín 40 × 145 mm'**
  String get buildMaterialBoard40;

  /// No description provided for @buildMaterialPost50.
  ///
  /// In cs, this message translates to:
  /// **'Hranol 50 × 50 mm'**
  String get buildMaterialPost50;

  /// No description provided for @buildMaterialPost70.
  ///
  /// In cs, this message translates to:
  /// **'Hranol 70 × 70 mm'**
  String get buildMaterialPost70;

  /// No description provided for @buildMaterialPost100.
  ///
  /// In cs, this message translates to:
  /// **'Hranol 100 × 100 mm'**
  String get buildMaterialPost100;

  /// No description provided for @buildMaterialPost120.
  ///
  /// In cs, this message translates to:
  /// **'Hranol 120 × 120 mm'**
  String get buildMaterialPost120;

  /// No description provided for @buildMaterialBeam.
  ///
  /// In cs, this message translates to:
  /// **'Hranol KVH {section} mm'**
  String buildMaterialBeam(String section);

  /// No description provided for @buildMaterialDeck.
  ///
  /// In cs, this message translates to:
  /// **'Terasové prkno {mm} mm'**
  String buildMaterialDeck(String mm);

  /// No description provided for @buildMaterialScrews.
  ///
  /// In cs, this message translates to:
  /// **'Vruty do dřeva, nerez'**
  String get buildMaterialScrews;

  /// No description provided for @buildMaterialTieRod.
  ///
  /// In cs, this message translates to:
  /// **'Závitová tyč M10 s maticemi'**
  String get buildMaterialTieRod;

  /// No description provided for @buildMaterialMoleMesh.
  ///
  /// In cs, this message translates to:
  /// **'Pletivo proti hryzcům'**
  String get buildMaterialMoleMesh;

  /// No description provided for @buildMaterialLiner.
  ///
  /// In cs, this message translates to:
  /// **'Nopová fólie'**
  String get buildMaterialLiner;

  /// No description provided for @buildMaterialFill.
  ///
  /// In cs, this message translates to:
  /// **'Náplň: zemina a kompost'**
  String get buildMaterialFill;

  /// No description provided for @buildMaterialWoodOil.
  ///
  /// In cs, this message translates to:
  /// **'Olej nebo lazura na dřevo'**
  String get buildMaterialWoodOil;

  /// No description provided for @buildMaterialGravel032.
  ///
  /// In cs, this message translates to:
  /// **'Štěrk 0–32 na podklad'**
  String get buildMaterialGravel032;

  /// No description provided for @buildMaterialChippings816.
  ///
  /// In cs, this message translates to:
  /// **'Drť 8–16 na povrch'**
  String get buildMaterialChippings816;

  /// No description provided for @buildMaterialChippings48.
  ///
  /// In cs, this message translates to:
  /// **'Drť 4–8 do lože'**
  String get buildMaterialChippings48;

  /// No description provided for @buildMaterialGeotextile.
  ///
  /// In cs, this message translates to:
  /// **'Geotextilie'**
  String get buildMaterialGeotextile;

  /// No description provided for @buildMaterialPavers.
  ///
  /// In cs, this message translates to:
  /// **'Betonová dlažba 6 cm'**
  String get buildMaterialPavers;

  /// No description provided for @buildMaterialSteppingStone.
  ///
  /// In cs, this message translates to:
  /// **'Nášlapný kámen 40 × 40 cm'**
  String get buildMaterialSteppingStone;

  /// No description provided for @buildMaterialMulch.
  ///
  /// In cs, this message translates to:
  /// **'Mulčovací kůra nebo štěpka'**
  String get buildMaterialMulch;

  /// No description provided for @buildMaterialEdging.
  ///
  /// In cs, this message translates to:
  /// **'Zahradní obrubník'**
  String get buildMaterialEdging;

  /// No description provided for @buildMaterialConcreteBag.
  ///
  /// In cs, this message translates to:
  /// **'Beton v pytli 25 kg'**
  String get buildMaterialConcreteBag;

  /// No description provided for @buildMaterialRailing.
  ///
  /// In cs, this message translates to:
  /// **'Zábradlí (sloupky a madlo)'**
  String get buildMaterialRailing;

  /// No description provided for @buildMaterialPostAnchor.
  ///
  /// In cs, this message translates to:
  /// **'Kotevní patka sloupku'**
  String get buildMaterialPostAnchor;

  /// No description provided for @buildMaterialPolycarbonate.
  ///
  /// In cs, this message translates to:
  /// **'Polykarbonát dutinkový'**
  String get buildMaterialPolycarbonate;

  /// No description provided for @buildMaterialMetalSheet.
  ///
  /// In cs, this message translates to:
  /// **'Trapézový plech'**
  String get buildMaterialMetalSheet;

  /// No description provided for @buildMaterialRoofScrews.
  ///
  /// In cs, this message translates to:
  /// **'Šrouby na krytinu s podložkou'**
  String get buildMaterialRoofScrews;

  /// No description provided for @buildSummaryRows.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, =1{1 řada prken} few{{count} řady prken} other{{count} řad prken}} po 145 mm, výška {height} m'**
  String buildSummaryRows(int count, String height);

  /// No description provided for @buildSummaryFill.
  ///
  /// In cs, this message translates to:
  /// **'Náplň {volume} m³'**
  String buildSummaryFill(String volume);

  /// No description provided for @buildSummaryExcavation.
  ///
  /// In cs, this message translates to:
  /// **'Výkop {volume} m³'**
  String buildSummaryExcavation(String volume);

  /// No description provided for @buildSummaryBeam.
  ///
  /// In cs, this message translates to:
  /// **'Nosníky využité na {percent} %'**
  String buildSummaryBeam(int percent);

  /// No description provided for @buildSummaryRafter.
  ///
  /// In cs, this message translates to:
  /// **'Krokve využité na {percent} %'**
  String buildSummaryRafter(int percent);

  /// No description provided for @buildSummaryPosts.
  ///
  /// In cs, this message translates to:
  /// **'Sloupky po {spacing} m, vaznice {section} mm'**
  String buildSummaryPosts(String spacing, String section);

  /// No description provided for @buildSummaryRoof.
  ///
  /// In cs, this message translates to:
  /// **'Střecha {area} m², vzadu výška {height} m'**
  String buildSummaryRoof(String area, String height);

  /// No description provided for @buildFindingBedTooWide.
  ///
  /// In cs, this message translates to:
  /// **'Záhon široký {width} m: do středu nedosáhneš. Záhon přístupný z obou stran má mít nejvýš 1,2 m, u zdi nejvýš 0,6 m.'**
  String buildFindingBedTooWide(String width);

  /// No description provided for @buildFindingBedThinBoards.
  ///
  /// In cs, this message translates to:
  /// **'Prkna 25 mm se u vyššího záhonu vyboulí pod tlakem zeminy. Zvol 32 nebo 40 mm.'**
  String get buildFindingBedThinBoards;

  /// No description provided for @buildFindingBedMidPosts.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, =1{Přidán 1 mezisloupek} few{Přidány {count} mezisloupky} other{Přidáno {count} mezisloupků}}, prkna mezi sloupky mají nejvýš {spacing} m, ať se stěny neprohýbají.'**
  String buildFindingBedMidPosts(int count, String spacing);

  /// No description provided for @buildFindingBedTieRods.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, =1{Přidána 1 příčná rozpěra} few{Přidány {count} příčné rozpěry} other{Přidáno {count} příčných rozpěr}} proti roztlačení dlouhých stěn.'**
  String buildFindingBedTieRods(int count);

  /// No description provided for @buildFindingBedTallFill.
  ///
  /// In cs, this message translates to:
  /// **'Vysoký záhon: spodek naplň větvemi a hrubým kompostem, ušetříš substrát a záhon lépe odvodní.'**
  String get buildFindingBedTallFill;

  /// No description provided for @buildFindingPathNarrow.
  ///
  /// In cs, this message translates to:
  /// **'Chodník užší než 0,6 m: kolečko projede jen těsně.'**
  String get buildFindingPathNarrow;

  /// No description provided for @buildFindingPathPaversNeedEdging.
  ///
  /// In cs, this message translates to:
  /// **'Dlažba bez obrubníku se po krajích rozjede. Přidej obrubník.'**
  String get buildFindingPathPaversNeedEdging;

  /// No description provided for @buildFindingPathGravelEdging.
  ///
  /// In cs, this message translates to:
  /// **'Štěrk bez obruby se rozhrnuje do trávníku a záhonů.'**
  String get buildFindingPathGravelEdging;

  /// No description provided for @buildFindingPathSteppingWide.
  ///
  /// In cs, this message translates to:
  /// **'Nášlapy jsou na šířku jednoho kroku. Pro širší chodník zvol štěrk nebo dlažbu.'**
  String get buildFindingPathSteppingWide;

  /// No description provided for @buildFindingPathMulchTopUp.
  ///
  /// In cs, this message translates to:
  /// **'Kůru nebo štěpku je potřeba po 2 až 3 letech doplnit.'**
  String get buildFindingPathMulchTopUp;

  /// No description provided for @buildFindingBridgeBeamFails.
  ///
  /// In cs, this message translates to:
  /// **'Nosníky jsou přetížené ({percent} % únosnosti nebo průhybu). Zvol průřez {section} mm.'**
  String buildFindingBridgeBeamFails(int percent, String section);

  /// No description provided for @buildFindingBridgeBeamFailsNoSection.
  ///
  /// In cs, this message translates to:
  /// **'Nosníky jsou přetížené ({percent} % únosnosti nebo průhybu). Přidej nosník nebo zkrať rozpětí.'**
  String buildFindingBridgeBeamFailsNoSection(int percent);

  /// No description provided for @buildFindingBridgeSpanOverLimit.
  ///
  /// In cs, this message translates to:
  /// **'Rozpětí nad {meters} m bez podpory ve vodě: dřevěný mostek nech navrhnout statikem, nebo přidej podpěru uprostřed.'**
  String buildFindingBridgeSpanOverLimit(String meters);

  /// No description provided for @buildFindingBridgeTooHigh.
  ///
  /// In cs, this message translates to:
  /// **'Mostek výš než {meters} m nad hladinou nebo terénem: pád je nebezpečný. Návrh nech posoudit statikem a počítej se zábradlím.'**
  String buildFindingBridgeTooHigh(String meters);

  /// No description provided for @buildFindingBridgeNeedsRailing.
  ///
  /// In cs, this message translates to:
  /// **'Mostek je víc než 0,5 m nad hladinou nebo terénem. Přidej zábradlí, hlavně kvůli dětem.'**
  String get buildFindingBridgeNeedsRailing;

  /// No description provided for @buildFindingBridgeNarrow.
  ///
  /// In cs, this message translates to:
  /// **'Mostek užší než 0,6 m se špatně přechází. Doporučená šířka je aspoň 0,8 m.'**
  String get buildFindingBridgeNarrow;

  /// No description provided for @buildFindingBridgeDeckSpan.
  ///
  /// In cs, this message translates to:
  /// **'Podlahová prkna by mezi nosníky měla moc velké pole. Zvol {beams, plural, one{1 nosník} few{{beams} nosníky} other{{beams} nosníků}} nebo silnější prkna.'**
  String buildFindingBridgeDeckSpan(int beams);

  /// No description provided for @buildFindingShelterRafterFails.
  ///
  /// In cs, this message translates to:
  /// **'Krokve neunesou sníh ({percent} % únosnosti nebo průhybu). Zvol průřez {section} mm.'**
  String buildFindingShelterRafterFails(int percent, String section);

  /// No description provided for @buildFindingShelterRafterFailsNoSection.
  ///
  /// In cs, this message translates to:
  /// **'Krokve neunesou sníh ({percent} % únosnosti nebo průhybu). Zmenši hloubku přístřešku nebo dej krokve hustěji.'**
  String buildFindingShelterRafterFailsNoSection(int percent);

  /// No description provided for @buildFindingShelterHeaderFails.
  ///
  /// In cs, this message translates to:
  /// **'Vaznice neunesou střechu se sněhem ani se sloupky po 1 m. Návrh nech posoudit statikem.'**
  String get buildFindingShelterHeaderFails;

  /// No description provided for @buildFindingShelterHeaderPosts.
  ///
  /// In cs, this message translates to:
  /// **'Kvůli sněhu jsou sloupky blíž u sebe, po {spacing} m.'**
  String buildFindingShelterHeaderPosts(String spacing);

  /// No description provided for @buildFindingShelterPermit.
  ///
  /// In cs, this message translates to:
  /// **'Stavba nad {area} m² může potřebovat povolení. Ověř to na stavebním úřadě.'**
  String buildFindingShelterPermit(String area);

  /// No description provided for @buildFindingShelterAnchoring.
  ///
  /// In cs, this message translates to:
  /// **'Sloupky ukotvi do betonových patek: vítr umí lehkou střechu nadzvednout.'**
  String get buildFindingShelterAnchoring;
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
