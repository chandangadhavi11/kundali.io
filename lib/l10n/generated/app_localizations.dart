import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_as.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_or.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('as'),
    Locale('bn'),
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
    Locale('kn'),
    Locale('ml'),
    Locale('mr'),
    Locale('or'),
    Locale('pa'),
    Locale('ta'),
    Locale('te'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Kundali'**
  String get appName;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get common_share;

  /// No description provided for @common_download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get common_download;

  /// No description provided for @common_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get common_loading;

  /// No description provided for @common_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get common_error;

  /// No description provided for @common_success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get common_success;

  /// No description provided for @common_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @common_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get common_yes;

  /// No description provided for @common_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get common_no;

  /// No description provided for @common_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_close;

  /// No description provided for @common_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get common_back;

  /// No description provided for @common_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get common_next;

  /// No description provided for @common_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get common_done;

  /// No description provided for @common_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get common_confirm;

  /// No description provided for @common_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// No description provided for @common_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get common_submit;

  /// No description provided for @common_update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get common_update;

  /// No description provided for @common_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get common_reset;

  /// No description provided for @common_apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get common_apply;

  /// No description provided for @common_search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get common_search;

  /// No description provided for @common_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get common_settings;

  /// No description provided for @insight_whatThisMeans.
  ///
  /// In en, this message translates to:
  /// **'What This Means'**
  String get insight_whatThisMeans;

  /// No description provided for @insight_significance.
  ///
  /// In en, this message translates to:
  /// **'Significance'**
  String get insight_significance;

  /// No description provided for @insight_keyPoints.
  ///
  /// In en, this message translates to:
  /// **'Key Points'**
  String get insight_keyPoints;

  /// No description provided for @common_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get common_language;

  /// No description provided for @common_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get common_theme;

  /// No description provided for @common_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get common_logout;

  /// No description provided for @common_login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get common_login;

  /// No description provided for @common_signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get common_signup;

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_horoscope.
  ///
  /// In en, this message translates to:
  /// **'Horoscope'**
  String get nav_horoscope;

  /// No description provided for @nav_panchang.
  ///
  /// In en, this message translates to:
  /// **'Panchang'**
  String get nav_panchang;

  /// No description provided for @nav_chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get nav_chat;

  /// No description provided for @nav_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get nav_profile;

  /// No description provided for @display_tab_chart.
  ///
  /// In en, this message translates to:
  /// **'Chart'**
  String get display_tab_chart;

  /// No description provided for @display_tab_details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get display_tab_details;

  /// No description provided for @display_tab_planets.
  ///
  /// In en, this message translates to:
  /// **'Planets'**
  String get display_tab_planets;

  /// No description provided for @display_tab_houses.
  ///
  /// In en, this message translates to:
  /// **'Houses'**
  String get display_tab_houses;

  /// No description provided for @display_tab_dasha.
  ///
  /// In en, this message translates to:
  /// **'Dasha'**
  String get display_tab_dasha;

  /// No description provided for @display_tab_yogas.
  ///
  /// In en, this message translates to:
  /// **'Yogas'**
  String get display_tab_yogas;

  /// No description provided for @display_tab_transit.
  ///
  /// In en, this message translates to:
  /// **'Transit'**
  String get display_tab_transit;

  /// No description provided for @display_tab_panchang.
  ///
  /// In en, this message translates to:
  /// **'Panchang'**
  String get display_tab_panchang;

  /// No description provided for @display_tab_strength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get display_tab_strength;

  /// No description provided for @display_menu_exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get display_menu_exportPdf;

  /// No description provided for @display_menu_setAsPrimary.
  ///
  /// In en, this message translates to:
  /// **'Set as Primary'**
  String get display_menu_setAsPrimary;

  /// No description provided for @display_menu_duplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get display_menu_duplicate;

  /// No description provided for @display_menu_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get display_menu_delete;

  /// No description provided for @display_menu_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get display_menu_language;

  /// No description provided for @display_viewChartFor.
  ///
  /// In en, this message translates to:
  /// **'View Chart For'**
  String get display_viewChartFor;

  /// No description provided for @display_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get display_date;

  /// No description provided for @display_time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get display_time;

  /// No description provided for @display_viewCurrentTimeChart.
  ///
  /// In en, this message translates to:
  /// **'View Current Time Chart'**
  String get display_viewCurrentTimeChart;

  /// No description provided for @display_chartTypes.
  ///
  /// In en, this message translates to:
  /// **'Chart Types'**
  String get display_chartTypes;

  /// No description provided for @display_divisionalCharts.
  ///
  /// In en, this message translates to:
  /// **'Divisional Charts'**
  String get display_divisionalCharts;

  /// No description provided for @display_chartStyle.
  ///
  /// In en, this message translates to:
  /// **'Chart Style'**
  String get display_chartStyle;

  /// No description provided for @display_northIndian.
  ///
  /// In en, this message translates to:
  /// **'North Indian'**
  String get display_northIndian;

  /// No description provided for @display_southIndian.
  ///
  /// In en, this message translates to:
  /// **'South Indian'**
  String get display_southIndian;

  /// No description provided for @display_fullscreen.
  ///
  /// In en, this message translates to:
  /// **'Fullscreen'**
  String get display_fullscreen;

  /// No description provided for @display_zoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom In'**
  String get display_zoomIn;

  /// No description provided for @display_zoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom Out'**
  String get display_zoomOut;

  /// No description provided for @display_selectChartType.
  ///
  /// In en, this message translates to:
  /// **'Select Chart Type'**
  String get display_selectChartType;

  /// No description provided for @display_learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get display_learnMore;

  /// No description provided for @chart_lagna.
  ///
  /// In en, this message translates to:
  /// **'Lagna'**
  String get chart_lagna;

  /// No description provided for @chart_moon.
  ///
  /// In en, this message translates to:
  /// **'Moon'**
  String get chart_moon;

  /// No description provided for @chart_sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get chart_sun;

  /// No description provided for @chart_bhava.
  ///
  /// In en, this message translates to:
  /// **'Bhava'**
  String get chart_bhava;

  /// No description provided for @chart_hora.
  ///
  /// In en, this message translates to:
  /// **'Hora'**
  String get chart_hora;

  /// No description provided for @chart_drekkana.
  ///
  /// In en, this message translates to:
  /// **'Drekkana'**
  String get chart_drekkana;

  /// No description provided for @chart_chaturthamsa.
  ///
  /// In en, this message translates to:
  /// **'Chaturthamsa'**
  String get chart_chaturthamsa;

  /// No description provided for @chart_saptamsa.
  ///
  /// In en, this message translates to:
  /// **'Saptamsa'**
  String get chart_saptamsa;

  /// No description provided for @chart_navamsa.
  ///
  /// In en, this message translates to:
  /// **'Navamsa'**
  String get chart_navamsa;

  /// No description provided for @chart_dasamsa.
  ///
  /// In en, this message translates to:
  /// **'Dasamsa'**
  String get chart_dasamsa;

  /// No description provided for @chart_dwadasamsa.
  ///
  /// In en, this message translates to:
  /// **'Dwadasamsa'**
  String get chart_dwadasamsa;

  /// No description provided for @chart_shodasamsa.
  ///
  /// In en, this message translates to:
  /// **'Shodasamsa'**
  String get chart_shodasamsa;

  /// No description provided for @chart_vimsamsa.
  ///
  /// In en, this message translates to:
  /// **'Vimsamsa'**
  String get chart_vimsamsa;

  /// No description provided for @chart_chaturvimsamsa.
  ///
  /// In en, this message translates to:
  /// **'Chaturvimsamsa'**
  String get chart_chaturvimsamsa;

  /// No description provided for @chart_bhamsa.
  ///
  /// In en, this message translates to:
  /// **'Bhamsa'**
  String get chart_bhamsa;

  /// No description provided for @chart_trimshamsa.
  ///
  /// In en, this message translates to:
  /// **'Trimshamsa'**
  String get chart_trimshamsa;

  /// No description provided for @chart_khavedamsa.
  ///
  /// In en, this message translates to:
  /// **'Khavedamsa'**
  String get chart_khavedamsa;

  /// No description provided for @chart_akshavedamsa.
  ///
  /// In en, this message translates to:
  /// **'Akshavedamsa'**
  String get chart_akshavedamsa;

  /// No description provided for @chart_shashtiamsa.
  ///
  /// In en, this message translates to:
  /// **'Shashtiamsa'**
  String get chart_shashtiamsa;

  /// No description provided for @chart_sudarshan.
  ///
  /// In en, this message translates to:
  /// **'Sudarshan'**
  String get chart_sudarshan;

  /// No description provided for @chart_ashtakavarga.
  ///
  /// In en, this message translates to:
  /// **'Ashtakavarga'**
  String get chart_ashtakavarga;

  /// No description provided for @chart_category_primary.
  ///
  /// In en, this message translates to:
  /// **'Primary Charts'**
  String get chart_category_primary;

  /// No description provided for @chart_category_primary_desc.
  ///
  /// In en, this message translates to:
  /// **'The main birth charts for overall life analysis'**
  String get chart_category_primary_desc;

  /// No description provided for @chart_category_divisional.
  ///
  /// In en, this message translates to:
  /// **'Divisional Charts (Vargas)'**
  String get chart_category_divisional;

  /// No description provided for @chart_category_divisional_desc.
  ///
  /// In en, this message translates to:
  /// **'Specialized charts for specific life areas'**
  String get chart_category_divisional_desc;

  /// No description provided for @chart_category_special.
  ///
  /// In en, this message translates to:
  /// **'Special Charts'**
  String get chart_category_special;

  /// No description provided for @chart_category_special_desc.
  ///
  /// In en, this message translates to:
  /// **'Unique analytical methods'**
  String get chart_category_special_desc;

  /// No description provided for @display_shareComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Share coming soon'**
  String get display_shareComingSoon;

  /// No description provided for @display_am.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get display_am;

  /// No description provided for @display_pm.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get display_pm;

  /// No description provided for @language_title.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language_title;

  /// No description provided for @language_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get language_subtitle;

  /// No description provided for @language_changed.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String language_changed(String language);

  /// No description provided for @input_title.
  ///
  /// In en, this message translates to:
  /// **'Create Kundali'**
  String get input_title;

  /// No description provided for @input_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get input_name;

  /// No description provided for @input_namePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get input_namePlaceholder;

  /// No description provided for @input_dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get input_dateOfBirth;

  /// No description provided for @input_timeOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Time of Birth'**
  String get input_timeOfBirth;

  /// No description provided for @input_placeOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Place of Birth'**
  String get input_placeOfBirth;

  /// No description provided for @input_placePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter city name'**
  String get input_placePlaceholder;

  /// No description provided for @input_gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get input_gender;

  /// No description provided for @input_male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get input_male;

  /// No description provided for @input_female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get input_female;

  /// No description provided for @input_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get input_other;

  /// No description provided for @input_generateKundali.
  ///
  /// In en, this message translates to:
  /// **'Generate Kundali'**
  String get input_generateKundali;

  /// No description provided for @input_saveAndView.
  ///
  /// In en, this message translates to:
  /// **'Save & View'**
  String get input_saveAndView;

  /// No description provided for @input_advancedOptions.
  ///
  /// In en, this message translates to:
  /// **'Advanced Options'**
  String get input_advancedOptions;

  /// No description provided for @input_chartStyle.
  ///
  /// In en, this message translates to:
  /// **'Chart Style'**
  String get input_chartStyle;

  /// No description provided for @input_timezone.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get input_timezone;

  /// No description provided for @input_setPrimary.
  ///
  /// In en, this message translates to:
  /// **'Set as Primary'**
  String get input_setPrimary;

  /// No description provided for @input_validationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get input_validationNameRequired;

  /// No description provided for @input_validationPlaceRequired.
  ///
  /// In en, this message translates to:
  /// **'Place of birth is required'**
  String get input_validationPlaceRequired;

  /// No description provided for @input_selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get input_selectDate;

  /// No description provided for @input_selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get input_selectTime;

  /// No description provided for @input_searchPlace.
  ///
  /// In en, this message translates to:
  /// **'Search place...'**
  String get input_searchPlace;

  /// No description provided for @input_recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get input_recentSearches;

  /// No description provided for @input_popularCities.
  ///
  /// In en, this message translates to:
  /// **'Popular Cities'**
  String get input_popularCities;

  /// No description provided for @input_noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get input_noResultsFound;

  /// No description provided for @input_generating.
  ///
  /// In en, this message translates to:
  /// **'Generating Kundali...'**
  String get input_generating;

  /// No description provided for @planet_sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get planet_sun;

  /// No description provided for @planet_moon.
  ///
  /// In en, this message translates to:
  /// **'Moon'**
  String get planet_moon;

  /// No description provided for @planet_mars.
  ///
  /// In en, this message translates to:
  /// **'Mars'**
  String get planet_mars;

  /// No description provided for @planet_mercury.
  ///
  /// In en, this message translates to:
  /// **'Mercury'**
  String get planet_mercury;

  /// No description provided for @planet_jupiter.
  ///
  /// In en, this message translates to:
  /// **'Jupiter'**
  String get planet_jupiter;

  /// No description provided for @planet_venus.
  ///
  /// In en, this message translates to:
  /// **'Venus'**
  String get planet_venus;

  /// No description provided for @planet_saturn.
  ///
  /// In en, this message translates to:
  /// **'Saturn'**
  String get planet_saturn;

  /// No description provided for @planet_rahu.
  ///
  /// In en, this message translates to:
  /// **'Rahu'**
  String get planet_rahu;

  /// No description provided for @planet_ketu.
  ///
  /// In en, this message translates to:
  /// **'Ketu'**
  String get planet_ketu;

  /// No description provided for @planet_uranus.
  ///
  /// In en, this message translates to:
  /// **'Uranus'**
  String get planet_uranus;

  /// No description provided for @planet_neptune.
  ///
  /// In en, this message translates to:
  /// **'Neptune'**
  String get planet_neptune;

  /// No description provided for @planet_pluto.
  ///
  /// In en, this message translates to:
  /// **'Pluto'**
  String get planet_pluto;

  /// No description provided for @planet_sun_sanskrit.
  ///
  /// In en, this message translates to:
  /// **'Surya'**
  String get planet_sun_sanskrit;

  /// No description provided for @planet_moon_sanskrit.
  ///
  /// In en, this message translates to:
  /// **'Chandra'**
  String get planet_moon_sanskrit;

  /// No description provided for @planet_mars_sanskrit.
  ///
  /// In en, this message translates to:
  /// **'Mangal'**
  String get planet_mars_sanskrit;

  /// No description provided for @planet_mercury_sanskrit.
  ///
  /// In en, this message translates to:
  /// **'Budh'**
  String get planet_mercury_sanskrit;

  /// No description provided for @planet_jupiter_sanskrit.
  ///
  /// In en, this message translates to:
  /// **'Guru'**
  String get planet_jupiter_sanskrit;

  /// No description provided for @planet_venus_sanskrit.
  ///
  /// In en, this message translates to:
  /// **'Shukra'**
  String get planet_venus_sanskrit;

  /// No description provided for @planet_saturn_sanskrit.
  ///
  /// In en, this message translates to:
  /// **'Shani'**
  String get planet_saturn_sanskrit;

  /// No description provided for @planet_rahu_sanskrit.
  ///
  /// In en, this message translates to:
  /// **'Rahu'**
  String get planet_rahu_sanskrit;

  /// No description provided for @planet_ketu_sanskrit.
  ///
  /// In en, this message translates to:
  /// **'Ketu'**
  String get planet_ketu_sanskrit;

  /// No description provided for @planet_sun_abbr.
  ///
  /// In en, this message translates to:
  /// **'Su'**
  String get planet_sun_abbr;

  /// No description provided for @planet_moon_abbr.
  ///
  /// In en, this message translates to:
  /// **'Mo'**
  String get planet_moon_abbr;

  /// No description provided for @planet_mars_abbr.
  ///
  /// In en, this message translates to:
  /// **'Ma'**
  String get planet_mars_abbr;

  /// No description provided for @planet_mercury_abbr.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get planet_mercury_abbr;

  /// No description provided for @planet_jupiter_abbr.
  ///
  /// In en, this message translates to:
  /// **'Ju'**
  String get planet_jupiter_abbr;

  /// No description provided for @planet_venus_abbr.
  ///
  /// In en, this message translates to:
  /// **'Ve'**
  String get planet_venus_abbr;

  /// No description provided for @planet_saturn_abbr.
  ///
  /// In en, this message translates to:
  /// **'Sa'**
  String get planet_saturn_abbr;

  /// No description provided for @planet_rahu_abbr.
  ///
  /// In en, this message translates to:
  /// **'Ra'**
  String get planet_rahu_abbr;

  /// No description provided for @planet_ketu_abbr.
  ///
  /// In en, this message translates to:
  /// **'Ke'**
  String get planet_ketu_abbr;

  /// No description provided for @planet_uranus_abbr.
  ///
  /// In en, this message translates to:
  /// **'Ur'**
  String get planet_uranus_abbr;

  /// No description provided for @planet_neptune_abbr.
  ///
  /// In en, this message translates to:
  /// **'Ne'**
  String get planet_neptune_abbr;

  /// No description provided for @planet_pluto_abbr.
  ///
  /// In en, this message translates to:
  /// **'Pl'**
  String get planet_pluto_abbr;

  /// No description provided for @planets_overview.
  ///
  /// In en, this message translates to:
  /// **'Planets Overview'**
  String get planets_overview;

  /// No description provided for @planets_position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get planets_position;

  /// No description provided for @planets_degree.
  ///
  /// In en, this message translates to:
  /// **'Degree'**
  String get planets_degree;

  /// No description provided for @planets_sign.
  ///
  /// In en, this message translates to:
  /// **'Sign'**
  String get planets_sign;

  /// No description provided for @planets_house.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get planets_house;

  /// No description provided for @planets_nakshatra.
  ///
  /// In en, this message translates to:
  /// **'Nakshatra'**
  String get planets_nakshatra;

  /// No description provided for @planets_retrograde.
  ///
  /// In en, this message translates to:
  /// **'Retrograde'**
  String get planets_retrograde;

  /// No description provided for @planets_combust.
  ///
  /// In en, this message translates to:
  /// **'Combust'**
  String get planets_combust;

  /// No description provided for @planets_exalted.
  ///
  /// In en, this message translates to:
  /// **'Exalted'**
  String get planets_exalted;

  /// No description provided for @planets_debilitated.
  ///
  /// In en, this message translates to:
  /// **'Debilitated'**
  String get planets_debilitated;

  /// No description provided for @planets_ownSign.
  ///
  /// In en, this message translates to:
  /// **'Own Sign'**
  String get planets_ownSign;

  /// No description provided for @planets_friendly.
  ///
  /// In en, this message translates to:
  /// **'Friendly'**
  String get planets_friendly;

  /// No description provided for @planets_neutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get planets_neutral;

  /// No description provided for @planets_enemy.
  ///
  /// In en, this message translates to:
  /// **'Enemy'**
  String get planets_enemy;

  /// No description provided for @zodiac_aries.
  ///
  /// In en, this message translates to:
  /// **'Aries'**
  String get zodiac_aries;

  /// No description provided for @zodiac_taurus.
  ///
  /// In en, this message translates to:
  /// **'Taurus'**
  String get zodiac_taurus;

  /// No description provided for @zodiac_gemini.
  ///
  /// In en, this message translates to:
  /// **'Gemini'**
  String get zodiac_gemini;

  /// No description provided for @zodiac_cancer.
  ///
  /// In en, this message translates to:
  /// **'Cancer'**
  String get zodiac_cancer;

  /// No description provided for @zodiac_leo.
  ///
  /// In en, this message translates to:
  /// **'Leo'**
  String get zodiac_leo;

  /// No description provided for @zodiac_virgo.
  ///
  /// In en, this message translates to:
  /// **'Virgo'**
  String get zodiac_virgo;

  /// No description provided for @zodiac_libra.
  ///
  /// In en, this message translates to:
  /// **'Libra'**
  String get zodiac_libra;

  /// No description provided for @zodiac_scorpio.
  ///
  /// In en, this message translates to:
  /// **'Scorpio'**
  String get zodiac_scorpio;

  /// No description provided for @zodiac_sagittarius.
  ///
  /// In en, this message translates to:
  /// **'Sagittarius'**
  String get zodiac_sagittarius;

  /// No description provided for @zodiac_capricorn.
  ///
  /// In en, this message translates to:
  /// **'Capricorn'**
  String get zodiac_capricorn;

  /// No description provided for @zodiac_aquarius.
  ///
  /// In en, this message translates to:
  /// **'Aquarius'**
  String get zodiac_aquarius;

  /// No description provided for @zodiac_pisces.
  ///
  /// In en, this message translates to:
  /// **'Pisces'**
  String get zodiac_pisces;

  /// No description provided for @zodiac_aries_abbr.
  ///
  /// In en, this message translates to:
  /// **'Ari'**
  String get zodiac_aries_abbr;

  /// No description provided for @zodiac_taurus_abbr.
  ///
  /// In en, this message translates to:
  /// **'Tau'**
  String get zodiac_taurus_abbr;

  /// No description provided for @zodiac_gemini_abbr.
  ///
  /// In en, this message translates to:
  /// **'Gem'**
  String get zodiac_gemini_abbr;

  /// No description provided for @zodiac_cancer_abbr.
  ///
  /// In en, this message translates to:
  /// **'Can'**
  String get zodiac_cancer_abbr;

  /// No description provided for @zodiac_leo_abbr.
  ///
  /// In en, this message translates to:
  /// **'Leo'**
  String get zodiac_leo_abbr;

  /// No description provided for @zodiac_virgo_abbr.
  ///
  /// In en, this message translates to:
  /// **'Vir'**
  String get zodiac_virgo_abbr;

  /// No description provided for @zodiac_libra_abbr.
  ///
  /// In en, this message translates to:
  /// **'Lib'**
  String get zodiac_libra_abbr;

  /// No description provided for @zodiac_scorpio_abbr.
  ///
  /// In en, this message translates to:
  /// **'Sco'**
  String get zodiac_scorpio_abbr;

  /// No description provided for @zodiac_sagittarius_abbr.
  ///
  /// In en, this message translates to:
  /// **'Sag'**
  String get zodiac_sagittarius_abbr;

  /// No description provided for @zodiac_capricorn_abbr.
  ///
  /// In en, this message translates to:
  /// **'Cap'**
  String get zodiac_capricorn_abbr;

  /// No description provided for @zodiac_aquarius_abbr.
  ///
  /// In en, this message translates to:
  /// **'Aqu'**
  String get zodiac_aquarius_abbr;

  /// No description provided for @zodiac_pisces_abbr.
  ///
  /// In en, this message translates to:
  /// **'Pis'**
  String get zodiac_pisces_abbr;

  /// No description provided for @zodiac_aries_sanskrit.
  ///
  /// In en, this message translates to:
  /// **'Mesha'**
  String get zodiac_aries_sanskrit;

  /// No description provided for @zodiac_taurus_sanskrit.
  ///
  /// In en, this message translates to:
  /// **'Vrishabha'**
  String get zodiac_taurus_sanskrit;

  /// No description provided for @zodiac_gemini_sanskrit.
  ///
  /// In en, this message translates to:
  /// **'Mithuna'**
  String get zodiac_gemini_sanskrit;

  /// No description provided for @zodiac_cancer_sanskrit.
  ///
  /// In en, this message translates to:
  /// **'Karka'**
  String get zodiac_cancer_sanskrit;

  /// No description provided for @zodiac_leo_sanskrit.
  ///
  /// In en, this message translates to:
  /// **'Simha'**
  String get zodiac_leo_sanskrit;

  /// No description provided for @zodiac_virgo_sanskrit.
  ///
  /// In en, this message translates to:
  /// **'Kanya'**
  String get zodiac_virgo_sanskrit;

  /// No description provided for @zodiac_libra_sanskrit.
  ///
  /// In en, this message translates to:
  /// **'Tula'**
  String get zodiac_libra_sanskrit;

  /// No description provided for @zodiac_scorpio_sanskrit.
  ///
  /// In en, this message translates to:
  /// **'Vrishchika'**
  String get zodiac_scorpio_sanskrit;

  /// No description provided for @zodiac_sagittarius_sanskrit.
  ///
  /// In en, this message translates to:
  /// **'Dhanu'**
  String get zodiac_sagittarius_sanskrit;

  /// No description provided for @zodiac_capricorn_sanskrit.
  ///
  /// In en, this message translates to:
  /// **'Makara'**
  String get zodiac_capricorn_sanskrit;

  /// No description provided for @zodiac_aquarius_sanskrit.
  ///
  /// In en, this message translates to:
  /// **'Kumbha'**
  String get zodiac_aquarius_sanskrit;

  /// No description provided for @zodiac_pisces_sanskrit.
  ///
  /// In en, this message translates to:
  /// **'Meena'**
  String get zodiac_pisces_sanskrit;

  /// No description provided for @nakshatra_ashwini.
  ///
  /// In en, this message translates to:
  /// **'Ashwini'**
  String get nakshatra_ashwini;

  /// No description provided for @nakshatra_bharani.
  ///
  /// In en, this message translates to:
  /// **'Bharani'**
  String get nakshatra_bharani;

  /// No description provided for @nakshatra_krittika.
  ///
  /// In en, this message translates to:
  /// **'Krittika'**
  String get nakshatra_krittika;

  /// No description provided for @nakshatra_rohini.
  ///
  /// In en, this message translates to:
  /// **'Rohini'**
  String get nakshatra_rohini;

  /// No description provided for @nakshatra_mrigashira.
  ///
  /// In en, this message translates to:
  /// **'Mrigashira'**
  String get nakshatra_mrigashira;

  /// No description provided for @nakshatra_ardra.
  ///
  /// In en, this message translates to:
  /// **'Ardra'**
  String get nakshatra_ardra;

  /// No description provided for @nakshatra_punarvasu.
  ///
  /// In en, this message translates to:
  /// **'Punarvasu'**
  String get nakshatra_punarvasu;

  /// No description provided for @nakshatra_pushya.
  ///
  /// In en, this message translates to:
  /// **'Pushya'**
  String get nakshatra_pushya;

  /// No description provided for @nakshatra_ashlesha.
  ///
  /// In en, this message translates to:
  /// **'Ashlesha'**
  String get nakshatra_ashlesha;

  /// No description provided for @nakshatra_magha.
  ///
  /// In en, this message translates to:
  /// **'Magha'**
  String get nakshatra_magha;

  /// No description provided for @nakshatra_purvaphalguni.
  ///
  /// In en, this message translates to:
  /// **'Purva Phalguni'**
  String get nakshatra_purvaphalguni;

  /// No description provided for @nakshatra_uttaraphalguni.
  ///
  /// In en, this message translates to:
  /// **'Uttara Phalguni'**
  String get nakshatra_uttaraphalguni;

  /// No description provided for @nakshatra_hasta.
  ///
  /// In en, this message translates to:
  /// **'Hasta'**
  String get nakshatra_hasta;

  /// No description provided for @nakshatra_chitra.
  ///
  /// In en, this message translates to:
  /// **'Chitra'**
  String get nakshatra_chitra;

  /// No description provided for @nakshatra_swati.
  ///
  /// In en, this message translates to:
  /// **'Swati'**
  String get nakshatra_swati;

  /// No description provided for @nakshatra_vishakha.
  ///
  /// In en, this message translates to:
  /// **'Vishakha'**
  String get nakshatra_vishakha;

  /// No description provided for @nakshatra_anuradha.
  ///
  /// In en, this message translates to:
  /// **'Anuradha'**
  String get nakshatra_anuradha;

  /// No description provided for @nakshatra_jyeshtha.
  ///
  /// In en, this message translates to:
  /// **'Jyeshtha'**
  String get nakshatra_jyeshtha;

  /// No description provided for @nakshatra_mula.
  ///
  /// In en, this message translates to:
  /// **'Mula'**
  String get nakshatra_mula;

  /// No description provided for @nakshatra_purvashadha.
  ///
  /// In en, this message translates to:
  /// **'Purva Ashadha'**
  String get nakshatra_purvashadha;

  /// No description provided for @nakshatra_uttarashadha.
  ///
  /// In en, this message translates to:
  /// **'Uttara Ashadha'**
  String get nakshatra_uttarashadha;

  /// No description provided for @nakshatra_shravana.
  ///
  /// In en, this message translates to:
  /// **'Shravana'**
  String get nakshatra_shravana;

  /// No description provided for @nakshatra_dhanishta.
  ///
  /// In en, this message translates to:
  /// **'Dhanishta'**
  String get nakshatra_dhanishta;

  /// No description provided for @nakshatra_shatabhisha.
  ///
  /// In en, this message translates to:
  /// **'Shatabhisha'**
  String get nakshatra_shatabhisha;

  /// No description provided for @nakshatra_purvabhadrapada.
  ///
  /// In en, this message translates to:
  /// **'Purva Bhadrapada'**
  String get nakshatra_purvabhadrapada;

  /// No description provided for @nakshatra_uttarabhadrapada.
  ///
  /// In en, this message translates to:
  /// **'Uttara Bhadrapada'**
  String get nakshatra_uttarabhadrapada;

  /// No description provided for @nakshatra_revati.
  ///
  /// In en, this message translates to:
  /// **'Revati'**
  String get nakshatra_revati;

  /// No description provided for @element_fire.
  ///
  /// In en, this message translates to:
  /// **'Fire'**
  String get element_fire;

  /// No description provided for @element_earth.
  ///
  /// In en, this message translates to:
  /// **'Earth'**
  String get element_earth;

  /// No description provided for @element_air.
  ///
  /// In en, this message translates to:
  /// **'Air'**
  String get element_air;

  /// No description provided for @element_water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get element_water;

  /// No description provided for @element_fire_desc.
  ///
  /// In en, this message translates to:
  /// **'Dynamic'**
  String get element_fire_desc;

  /// No description provided for @element_earth_desc.
  ///
  /// In en, this message translates to:
  /// **'Grounded'**
  String get element_earth_desc;

  /// No description provided for @element_air_desc.
  ///
  /// In en, this message translates to:
  /// **'Intellectual'**
  String get element_air_desc;

  /// No description provided for @element_water_desc.
  ///
  /// In en, this message translates to:
  /// **'Intuitive'**
  String get element_water_desc;

  /// No description provided for @gana_deva.
  ///
  /// In en, this message translates to:
  /// **'Deva'**
  String get gana_deva;

  /// No description provided for @gana_manushya.
  ///
  /// In en, this message translates to:
  /// **'Manushya'**
  String get gana_manushya;

  /// No description provided for @gana_rakshasa.
  ///
  /// In en, this message translates to:
  /// **'Rakshasa'**
  String get gana_rakshasa;

  /// No description provided for @varna_brahmin.
  ///
  /// In en, this message translates to:
  /// **'Brahmin'**
  String get varna_brahmin;

  /// No description provided for @varna_kshatriya.
  ///
  /// In en, this message translates to:
  /// **'Kshatriya'**
  String get varna_kshatriya;

  /// No description provided for @varna_vaishya.
  ///
  /// In en, this message translates to:
  /// **'Vaishya'**
  String get varna_vaishya;

  /// No description provided for @varna_shudra.
  ///
  /// In en, this message translates to:
  /// **'Shudra'**
  String get varna_shudra;

  /// No description provided for @vashya_chatushpad.
  ///
  /// In en, this message translates to:
  /// **'Chatushpad'**
  String get vashya_chatushpad;

  /// No description provided for @vashya_vanchar.
  ///
  /// In en, this message translates to:
  /// **'Vanchar'**
  String get vashya_vanchar;

  /// No description provided for @vashya_nara.
  ///
  /// In en, this message translates to:
  /// **'Nara'**
  String get vashya_nara;

  /// No description provided for @vashya_jalachara.
  ///
  /// In en, this message translates to:
  /// **'Jalachara'**
  String get vashya_jalachara;

  /// No description provided for @vashya_keeta.
  ///
  /// In en, this message translates to:
  /// **'Keeta'**
  String get vashya_keeta;

  /// No description provided for @nadi_aadi.
  ///
  /// In en, this message translates to:
  /// **'Aadi'**
  String get nadi_aadi;

  /// No description provided for @nadi_madhya.
  ///
  /// In en, this message translates to:
  /// **'Madhya'**
  String get nadi_madhya;

  /// No description provided for @nadi_antya.
  ///
  /// In en, this message translates to:
  /// **'Antya'**
  String get nadi_antya;

  /// No description provided for @day_sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get day_sunday;

  /// No description provided for @day_monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get day_monday;

  /// No description provided for @day_tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get day_tuesday;

  /// No description provided for @day_wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get day_wednesday;

  /// No description provided for @day_thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get day_thursday;

  /// No description provided for @day_friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get day_friday;

  /// No description provided for @day_saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get day_saturday;

  /// No description provided for @metal_gold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get metal_gold;

  /// No description provided for @metal_silver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get metal_silver;

  /// No description provided for @metal_copper.
  ///
  /// In en, this message translates to:
  /// **'Copper'**
  String get metal_copper;

  /// No description provided for @metal_iron.
  ///
  /// In en, this message translates to:
  /// **'Iron'**
  String get metal_iron;

  /// No description provided for @metal_brass.
  ///
  /// In en, this message translates to:
  /// **'Brass'**
  String get metal_brass;

  /// No description provided for @metal_bronze.
  ///
  /// In en, this message translates to:
  /// **'Bronze'**
  String get metal_bronze;

  /// No description provided for @metal_tin.
  ///
  /// In en, this message translates to:
  /// **'Tin'**
  String get metal_tin;

  /// No description provided for @metal_lead.
  ///
  /// In en, this message translates to:
  /// **'Lead'**
  String get metal_lead;

  /// No description provided for @gemstone_ruby.
  ///
  /// In en, this message translates to:
  /// **'Ruby'**
  String get gemstone_ruby;

  /// No description provided for @gemstone_pearl.
  ///
  /// In en, this message translates to:
  /// **'Pearl'**
  String get gemstone_pearl;

  /// No description provided for @gemstone_redcoral.
  ///
  /// In en, this message translates to:
  /// **'Red Coral'**
  String get gemstone_redcoral;

  /// No description provided for @gemstone_emerald.
  ///
  /// In en, this message translates to:
  /// **'Emerald'**
  String get gemstone_emerald;

  /// No description provided for @gemstone_yellowsapphire.
  ///
  /// In en, this message translates to:
  /// **'Yellow Sapphire'**
  String get gemstone_yellowsapphire;

  /// No description provided for @gemstone_diamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get gemstone_diamond;

  /// No description provided for @gemstone_bluesapphire.
  ///
  /// In en, this message translates to:
  /// **'Blue Sapphire'**
  String get gemstone_bluesapphire;

  /// No description provided for @gemstone_hessonite.
  ///
  /// In en, this message translates to:
  /// **'Hessonite'**
  String get gemstone_hessonite;

  /// No description provided for @gemstone_catseye.
  ///
  /// In en, this message translates to:
  /// **'Cat\'s Eye'**
  String get gemstone_catseye;

  /// No description provided for @yoni_horse.
  ///
  /// In en, this message translates to:
  /// **'Horse'**
  String get yoni_horse;

  /// No description provided for @yoni_elephant.
  ///
  /// In en, this message translates to:
  /// **'Elephant'**
  String get yoni_elephant;

  /// No description provided for @yoni_goat.
  ///
  /// In en, this message translates to:
  /// **'Goat'**
  String get yoni_goat;

  /// No description provided for @yoni_serpent.
  ///
  /// In en, this message translates to:
  /// **'Serpent'**
  String get yoni_serpent;

  /// No description provided for @yoni_dog.
  ///
  /// In en, this message translates to:
  /// **'Dog'**
  String get yoni_dog;

  /// No description provided for @yoni_cat.
  ///
  /// In en, this message translates to:
  /// **'Cat'**
  String get yoni_cat;

  /// No description provided for @yoni_rat.
  ///
  /// In en, this message translates to:
  /// **'Rat'**
  String get yoni_rat;

  /// No description provided for @yoni_cow.
  ///
  /// In en, this message translates to:
  /// **'Cow'**
  String get yoni_cow;

  /// No description provided for @yoni_buffalo.
  ///
  /// In en, this message translates to:
  /// **'Buffalo'**
  String get yoni_buffalo;

  /// No description provided for @yoni_tiger.
  ///
  /// In en, this message translates to:
  /// **'Tiger'**
  String get yoni_tiger;

  /// No description provided for @yoni_deer.
  ///
  /// In en, this message translates to:
  /// **'Deer'**
  String get yoni_deer;

  /// No description provided for @yoni_monkey.
  ///
  /// In en, this message translates to:
  /// **'Monkey'**
  String get yoni_monkey;

  /// No description provided for @yoni_mongoose.
  ///
  /// In en, this message translates to:
  /// **'Mongoose'**
  String get yoni_mongoose;

  /// No description provided for @yoni_lion.
  ///
  /// In en, this message translates to:
  /// **'Lion'**
  String get yoni_lion;

  /// No description provided for @tara_janma.
  ///
  /// In en, this message translates to:
  /// **'Janma'**
  String get tara_janma;

  /// No description provided for @tara_sampat.
  ///
  /// In en, this message translates to:
  /// **'Sampat'**
  String get tara_sampat;

  /// No description provided for @tara_vipat.
  ///
  /// In en, this message translates to:
  /// **'Vipat'**
  String get tara_vipat;

  /// No description provided for @tara_kshema.
  ///
  /// In en, this message translates to:
  /// **'Kshema'**
  String get tara_kshema;

  /// No description provided for @tara_pratyak.
  ///
  /// In en, this message translates to:
  /// **'Pratyak'**
  String get tara_pratyak;

  /// No description provided for @tara_sadhana.
  ///
  /// In en, this message translates to:
  /// **'Sadhana'**
  String get tara_sadhana;

  /// No description provided for @tara_naidhana.
  ///
  /// In en, this message translates to:
  /// **'Naidhana'**
  String get tara_naidhana;

  /// No description provided for @tara_mitra.
  ///
  /// In en, this message translates to:
  /// **'Mitra'**
  String get tara_mitra;

  /// No description provided for @tara_paramamitra.
  ///
  /// In en, this message translates to:
  /// **'Parama Mitra'**
  String get tara_paramamitra;

  /// No description provided for @house_1.
  ///
  /// In en, this message translates to:
  /// **'1st House'**
  String get house_1;

  /// No description provided for @house_2.
  ///
  /// In en, this message translates to:
  /// **'2nd House'**
  String get house_2;

  /// No description provided for @house_3.
  ///
  /// In en, this message translates to:
  /// **'3rd House'**
  String get house_3;

  /// No description provided for @house_4.
  ///
  /// In en, this message translates to:
  /// **'4th House'**
  String get house_4;

  /// No description provided for @house_5.
  ///
  /// In en, this message translates to:
  /// **'5th House'**
  String get house_5;

  /// No description provided for @house_6.
  ///
  /// In en, this message translates to:
  /// **'6th House'**
  String get house_6;

  /// No description provided for @house_7.
  ///
  /// In en, this message translates to:
  /// **'7th House'**
  String get house_7;

  /// No description provided for @house_8.
  ///
  /// In en, this message translates to:
  /// **'8th House'**
  String get house_8;

  /// No description provided for @house_9.
  ///
  /// In en, this message translates to:
  /// **'9th House'**
  String get house_9;

  /// No description provided for @house_10.
  ///
  /// In en, this message translates to:
  /// **'10th House'**
  String get house_10;

  /// No description provided for @house_11.
  ///
  /// In en, this message translates to:
  /// **'11th House'**
  String get house_11;

  /// No description provided for @house_12.
  ///
  /// In en, this message translates to:
  /// **'12th House'**
  String get house_12;

  /// No description provided for @house_1_name.
  ///
  /// In en, this message translates to:
  /// **'Lagna'**
  String get house_1_name;

  /// No description provided for @house_2_name.
  ///
  /// In en, this message translates to:
  /// **'Dhana'**
  String get house_2_name;

  /// No description provided for @house_3_name.
  ///
  /// In en, this message translates to:
  /// **'Sahaja'**
  String get house_3_name;

  /// No description provided for @house_4_name.
  ///
  /// In en, this message translates to:
  /// **'Sukha'**
  String get house_4_name;

  /// No description provided for @house_5_name.
  ///
  /// In en, this message translates to:
  /// **'Putra'**
  String get house_5_name;

  /// No description provided for @house_6_name.
  ///
  /// In en, this message translates to:
  /// **'Ripu'**
  String get house_6_name;

  /// No description provided for @house_7_name.
  ///
  /// In en, this message translates to:
  /// **'Kalatra'**
  String get house_7_name;

  /// No description provided for @house_8_name.
  ///
  /// In en, this message translates to:
  /// **'Ayu'**
  String get house_8_name;

  /// No description provided for @house_9_name.
  ///
  /// In en, this message translates to:
  /// **'Dharma'**
  String get house_9_name;

  /// No description provided for @house_10_name.
  ///
  /// In en, this message translates to:
  /// **'Karma'**
  String get house_10_name;

  /// No description provided for @house_11_name.
  ///
  /// In en, this message translates to:
  /// **'Labha'**
  String get house_11_name;

  /// No description provided for @house_12_name.
  ///
  /// In en, this message translates to:
  /// **'Vyaya'**
  String get house_12_name;

  /// No description provided for @house_1_meaning.
  ///
  /// In en, this message translates to:
  /// **'Self, personality, physical body, health'**
  String get house_1_meaning;

  /// No description provided for @house_2_meaning.
  ///
  /// In en, this message translates to:
  /// **'Wealth, family, speech, values'**
  String get house_2_meaning;

  /// No description provided for @house_3_meaning.
  ///
  /// In en, this message translates to:
  /// **'Siblings, courage, communication, short travels'**
  String get house_3_meaning;

  /// No description provided for @house_4_meaning.
  ///
  /// In en, this message translates to:
  /// **'Mother, home, property, happiness, education'**
  String get house_4_meaning;

  /// No description provided for @house_5_meaning.
  ///
  /// In en, this message translates to:
  /// **'Children, creativity, intelligence, romance'**
  String get house_5_meaning;

  /// No description provided for @house_6_meaning.
  ///
  /// In en, this message translates to:
  /// **'Enemies, diseases, debts, daily work'**
  String get house_6_meaning;

  /// No description provided for @house_7_meaning.
  ///
  /// In en, this message translates to:
  /// **'Marriage, partnerships, business, spouse'**
  String get house_7_meaning;

  /// No description provided for @house_8_meaning.
  ///
  /// In en, this message translates to:
  /// **'Longevity, transformation, inheritance, occult'**
  String get house_8_meaning;

  /// No description provided for @house_9_meaning.
  ///
  /// In en, this message translates to:
  /// **'Fortune, dharma, father, higher learning'**
  String get house_9_meaning;

  /// No description provided for @house_10_meaning.
  ///
  /// In en, this message translates to:
  /// **'Career, status, fame, authority'**
  String get house_10_meaning;

  /// No description provided for @house_11_meaning.
  ///
  /// In en, this message translates to:
  /// **'Gains, income, friends, aspirations'**
  String get house_11_meaning;

  /// No description provided for @house_12_meaning.
  ///
  /// In en, this message translates to:
  /// **'Losses, expenses, spirituality, foreign lands'**
  String get house_12_meaning;

  /// No description provided for @houses_significations.
  ///
  /// In en, this message translates to:
  /// **'Significations'**
  String get houses_significations;

  /// No description provided for @houses_lord.
  ///
  /// In en, this message translates to:
  /// **'Lord'**
  String get houses_lord;

  /// No description provided for @houses_planets.
  ///
  /// In en, this message translates to:
  /// **'Planets'**
  String get houses_planets;

  /// No description provided for @houses_aspects.
  ///
  /// In en, this message translates to:
  /// **'Aspects'**
  String get houses_aspects;

  /// No description provided for @houses_strength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get houses_strength;

  /// No description provided for @chartType_lagna.
  ///
  /// In en, this message translates to:
  /// **'Lagna'**
  String get chartType_lagna;

  /// No description provided for @chartType_moon.
  ///
  /// In en, this message translates to:
  /// **'Moon'**
  String get chartType_moon;

  /// No description provided for @chartType_sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get chartType_sun;

  /// No description provided for @chartType_navamsa.
  ///
  /// In en, this message translates to:
  /// **'Navamsa (D9)'**
  String get chartType_navamsa;

  /// No description provided for @chartType_hora.
  ///
  /// In en, this message translates to:
  /// **'Hora (D2)'**
  String get chartType_hora;

  /// No description provided for @chartType_drekkana.
  ///
  /// In en, this message translates to:
  /// **'Drekkana (D3)'**
  String get chartType_drekkana;

  /// No description provided for @chartType_chaturthamsa.
  ///
  /// In en, this message translates to:
  /// **'Chaturthamsa (D4)'**
  String get chartType_chaturthamsa;

  /// No description provided for @chartType_saptamsa.
  ///
  /// In en, this message translates to:
  /// **'Saptamsa (D7)'**
  String get chartType_saptamsa;

  /// No description provided for @chartType_dasamsa.
  ///
  /// In en, this message translates to:
  /// **'Dasamsa (D10)'**
  String get chartType_dasamsa;

  /// No description provided for @chartType_dwadasamsa.
  ///
  /// In en, this message translates to:
  /// **'Dwadasamsa (D12)'**
  String get chartType_dwadasamsa;

  /// No description provided for @chartType_shodasamsa.
  ///
  /// In en, this message translates to:
  /// **'Shodasamsa (D16)'**
  String get chartType_shodasamsa;

  /// No description provided for @chartType_vimsamsa.
  ///
  /// In en, this message translates to:
  /// **'Vimsamsa (D20)'**
  String get chartType_vimsamsa;

  /// No description provided for @chartType_chaturvimsamsa.
  ///
  /// In en, this message translates to:
  /// **'Chaturvimsamsa (D24)'**
  String get chartType_chaturvimsamsa;

  /// No description provided for @chartType_saptavimsamsa.
  ///
  /// In en, this message translates to:
  /// **'Saptavimsamsa (D27)'**
  String get chartType_saptavimsamsa;

  /// No description provided for @chartType_trimsamsa.
  ///
  /// In en, this message translates to:
  /// **'Trimsamsa (D30)'**
  String get chartType_trimsamsa;

  /// No description provided for @chartType_khavedamsa.
  ///
  /// In en, this message translates to:
  /// **'Khavedamsa (D40)'**
  String get chartType_khavedamsa;

  /// No description provided for @chartType_akshavedamsa.
  ///
  /// In en, this message translates to:
  /// **'Akshavedamsa (D45)'**
  String get chartType_akshavedamsa;

  /// No description provided for @chartType_shashtiamsa.
  ///
  /// In en, this message translates to:
  /// **'Shashtiamsa (D60)'**
  String get chartType_shashtiamsa;

  /// No description provided for @dasha_mahadasha.
  ///
  /// In en, this message translates to:
  /// **'Mahadasha'**
  String get dasha_mahadasha;

  /// No description provided for @dasha_antardasha.
  ///
  /// In en, this message translates to:
  /// **'Antardasha'**
  String get dasha_antardasha;

  /// No description provided for @dasha_pratyantardasha.
  ///
  /// In en, this message translates to:
  /// **'Pratyantardasha'**
  String get dasha_pratyantardasha;

  /// No description provided for @dasha_currentPeriod.
  ///
  /// In en, this message translates to:
  /// **'Current Period'**
  String get dasha_currentPeriod;

  /// No description provided for @dasha_startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get dasha_startDate;

  /// No description provided for @dasha_endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get dasha_endDate;

  /// No description provided for @dasha_duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get dasha_duration;

  /// No description provided for @dasha_years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get dasha_years;

  /// No description provided for @dasha_months.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get dasha_months;

  /// No description provided for @dasha_days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get dasha_days;

  /// No description provided for @dasha_remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get dasha_remaining;

  /// No description provided for @dasha_elapsed.
  ///
  /// In en, this message translates to:
  /// **'Elapsed'**
  String get dasha_elapsed;

  /// No description provided for @dasha_vimshottari.
  ///
  /// In en, this message translates to:
  /// **'Vimshottari Dasha'**
  String get dasha_vimshottari;

  /// No description provided for @dasha_yogini.
  ///
  /// In en, this message translates to:
  /// **'Yogini Dasha'**
  String get dasha_yogini;

  /// No description provided for @dasha_chara.
  ///
  /// In en, this message translates to:
  /// **'Chara Dasha'**
  String get dasha_chara;

  /// No description provided for @dasha_tab_vimshottari.
  ///
  /// In en, this message translates to:
  /// **'Vimshottari'**
  String get dasha_tab_vimshottari;

  /// No description provided for @dasha_tab_phala.
  ///
  /// In en, this message translates to:
  /// **'Phala'**
  String get dasha_tab_phala;

  /// No description provided for @dasha_tab_yogini.
  ///
  /// In en, this message translates to:
  /// **'Yogini'**
  String get dasha_tab_yogini;

  /// No description provided for @dasha_tab_char.
  ///
  /// In en, this message translates to:
  /// **'Char'**
  String get dasha_tab_char;

  /// No description provided for @dasha_now.
  ///
  /// In en, this message translates to:
  /// **'NOW'**
  String get dasha_now;

  /// No description provided for @dasha_duration_years.
  ///
  /// In en, this message translates to:
  /// **'{years} y, {months} m, {days} d'**
  String dasha_duration_years(Object days, Object months, Object years);

  /// No description provided for @dasha_duration_months.
  ///
  /// In en, this message translates to:
  /// **'{months} m, {days} d'**
  String dasha_duration_months(Object days, Object months);

  /// No description provided for @dasha_duration_days.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String dasha_duration_days(Object days);

  /// No description provided for @dasha_duration_days_hours.
  ///
  /// In en, this message translates to:
  /// **'{days} d, {hours} h'**
  String dasha_duration_days_hours(Object days, Object hours);

  /// No description provided for @dasha_duration_hours.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours'**
  String dasha_duration_hours(Object hours);

  /// No description provided for @dasha_duration_hours_minutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} h, {minutes} m'**
  String dasha_duration_hours_minutes(Object hours, Object minutes);

  /// No description provided for @dasha_duration_minutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String dasha_duration_minutes(Object minutes);

  /// No description provided for @dasha_duration_lessThanMinute.
  ///
  /// In en, this message translates to:
  /// **'< 1 min'**
  String get dasha_duration_lessThanMinute;

  /// No description provided for @vimshottari_nav_current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get vimshottari_nav_current;

  /// No description provided for @vimshottari_nav_birth.
  ///
  /// In en, this message translates to:
  /// **'Birth'**
  String get vimshottari_nav_birth;

  /// No description provided for @vimshottari_nav_timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get vimshottari_nav_timeline;

  /// No description provided for @vimshottari_activePeriods.
  ///
  /// In en, this message translates to:
  /// **'Active Periods'**
  String get vimshottari_activePeriods;

  /// No description provided for @vimshottari_birthConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Birth Configuration'**
  String get vimshottari_birthConfiguration;

  /// No description provided for @vimshottari_lifeTimeline.
  ///
  /// In en, this message translates to:
  /// **'Life Timeline'**
  String get vimshottari_lifeTimeline;

  /// No description provided for @vimshottari_infoFooter.
  ///
  /// In en, this message translates to:
  /// **'Vimshottari Dasha is a 120-year cycle based on Moon\'s nakshatra at birth. Tap any period to see sub-periods.'**
  String get vimshottari_infoFooter;

  /// No description provided for @vimshottari_active.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get vimshottari_active;

  /// No description provided for @vimshottari_planetMahadasha.
  ///
  /// In en, this message translates to:
  /// **'{planet} Mahadasha'**
  String vimshottari_planetMahadasha(Object planet);

  /// No description provided for @vimshottari_journeyProgress.
  ///
  /// In en, this message translates to:
  /// **'Journey Progress'**
  String get vimshottari_journeyProgress;

  /// No description provided for @vimshottari_remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get vimshottari_remaining;

  /// No description provided for @vimshottari_duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get vimshottari_duration;

  /// No description provided for @vimshottari_cycles.
  ///
  /// In en, this message translates to:
  /// **'Cycles'**
  String get vimshottari_cycles;

  /// No description provided for @vimshottari_yearsAbbr.
  ///
  /// In en, this message translates to:
  /// **'{years} yrs'**
  String vimshottari_yearsAbbr(Object years);

  /// No description provided for @vimshottari_started.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get vimshottari_started;

  /// No description provided for @vimshottari_ends.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get vimshottari_ends;

  /// No description provided for @vimshottari_left.
  ///
  /// In en, this message translates to:
  /// **'{duration} left'**
  String vimshottari_left(Object duration);

  /// No description provided for @vimshottari_nakshatraLord.
  ///
  /// In en, this message translates to:
  /// **'Nakshatra Lord'**
  String get vimshottari_nakshatraLord;

  /// No description provided for @vimshottari_balanceAtBirth.
  ///
  /// In en, this message translates to:
  /// **'Balance at Birth'**
  String get vimshottari_balanceAtBirth;

  /// No description provided for @vimshottari_sookshma.
  ///
  /// In en, this message translates to:
  /// **'Sookshma'**
  String get vimshottari_sookshma;

  /// No description provided for @vimshottari_prana.
  ///
  /// In en, this message translates to:
  /// **'Prana'**
  String get vimshottari_prana;

  /// No description provided for @vimshottari_levelPeriods.
  ///
  /// In en, this message translates to:
  /// **'{level} Periods'**
  String vimshottari_levelPeriods(Object level);

  /// No description provided for @vimshottari_loadingSubPeriods.
  ///
  /// In en, this message translates to:
  /// **'Loading sub-periods...'**
  String get vimshottari_loadingSubPeriods;

  /// No description provided for @vimshottari_start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get vimshottari_start;

  /// No description provided for @vimshottari_end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get vimshottari_end;

  /// No description provided for @vimshottari_desc_sun.
  ///
  /// In en, this message translates to:
  /// **'Period of authority and leadership'**
  String get vimshottari_desc_sun;

  /// No description provided for @vimshottari_desc_moon.
  ///
  /// In en, this message translates to:
  /// **'Period of emotions and intuition'**
  String get vimshottari_desc_moon;

  /// No description provided for @vimshottari_desc_mars.
  ///
  /// In en, this message translates to:
  /// **'Period of action and courage'**
  String get vimshottari_desc_mars;

  /// No description provided for @vimshottari_desc_mercury.
  ///
  /// In en, this message translates to:
  /// **'Period of intellect and learning'**
  String get vimshottari_desc_mercury;

  /// No description provided for @vimshottari_desc_jupiter.
  ///
  /// In en, this message translates to:
  /// **'Period of wisdom and fortune'**
  String get vimshottari_desc_jupiter;

  /// No description provided for @vimshottari_desc_venus.
  ///
  /// In en, this message translates to:
  /// **'Period of love and prosperity'**
  String get vimshottari_desc_venus;

  /// No description provided for @vimshottari_desc_saturn.
  ///
  /// In en, this message translates to:
  /// **'Period of discipline and karma'**
  String get vimshottari_desc_saturn;

  /// No description provided for @vimshottari_desc_rahu.
  ///
  /// In en, this message translates to:
  /// **'Period of worldly desires'**
  String get vimshottari_desc_rahu;

  /// No description provided for @vimshottari_desc_ketu.
  ///
  /// In en, this message translates to:
  /// **'Period of spiritual growth'**
  String get vimshottari_desc_ketu;

  /// No description provided for @vimshottari_desc_default.
  ///
  /// In en, this message translates to:
  /// **'Planetary period of influence'**
  String get vimshottari_desc_default;

  /// No description provided for @yogini_nav_current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get yogini_nav_current;

  /// No description provided for @yogini_nav_yoginis.
  ///
  /// In en, this message translates to:
  /// **'Yoginis'**
  String get yogini_nav_yoginis;

  /// No description provided for @yogini_nav_timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get yogini_nav_timeline;

  /// No description provided for @yogini_activeYoginiPeriods.
  ///
  /// In en, this message translates to:
  /// **'Active Yogini Periods'**
  String get yogini_activeYoginiPeriods;

  /// No description provided for @yogini_divineYoginis.
  ///
  /// In en, this message translates to:
  /// **'The 8 Divine Yoginis'**
  String get yogini_divineYoginis;

  /// No description provided for @yogini_timeline.
  ///
  /// In en, this message translates to:
  /// **'Yogini Timeline'**
  String get yogini_timeline;

  /// No description provided for @yogini_infoFooter.
  ///
  /// In en, this message translates to:
  /// **'Yogini Dasha is a 36-year cycle based on 8 divine Yoginis representing cosmic feminine energies.'**
  String get yogini_infoFooter;

  /// No description provided for @yogini_unavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Yogini Dasha Unavailable'**
  String get yogini_unavailableTitle;

  /// No description provided for @yogini_unavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to calculate Yogini Dasha for this chart.'**
  String get yogini_unavailableMessage;

  /// No description provided for @yogini_active.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get yogini_active;

  /// No description provided for @yogini_dashaName.
  ///
  /// In en, this message translates to:
  /// **'{yogini} Dasha'**
  String yogini_dashaName(Object yogini);

  /// No description provided for @yogini_journeyProgress.
  ///
  /// In en, this message translates to:
  /// **'Journey Progress'**
  String get yogini_journeyProgress;

  /// No description provided for @yogini_remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get yogini_remaining;

  /// No description provided for @yogini_duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get yogini_duration;

  /// No description provided for @yogini_cycles.
  ///
  /// In en, this message translates to:
  /// **'Cycles'**
  String get yogini_cycles;

  /// No description provided for @yogini_yearsAbbr.
  ///
  /// In en, this message translates to:
  /// **'{years} yrs'**
  String yogini_yearsAbbr(Object years);

  /// No description provided for @yogini_left.
  ///
  /// In en, this message translates to:
  /// **'{duration} left'**
  String yogini_left(Object duration);

  /// No description provided for @yogini_ruledBy.
  ///
  /// In en, this message translates to:
  /// **'Ruled by {planet}'**
  String yogini_ruledBy(Object planet);

  /// No description provided for @yogini_start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get yogini_start;

  /// No description provided for @yogini_end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get yogini_end;

  /// No description provided for @yogini_subPeriods.
  ///
  /// In en, this message translates to:
  /// **'Sub-Periods ({count})'**
  String yogini_subPeriods(Object count);

  /// No description provided for @yogini_noSubPeriods.
  ///
  /// In en, this message translates to:
  /// **'No sub-periods available'**
  String get yogini_noSubPeriods;

  /// No description provided for @phala_nav_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get phala_nav_theme;

  /// No description provided for @phala_nav_effects.
  ///
  /// In en, this message translates to:
  /// **'Effects'**
  String get phala_nav_effects;

  /// No description provided for @phala_nav_lifeAreas.
  ///
  /// In en, this message translates to:
  /// **'Life Areas'**
  String get phala_nav_lifeAreas;

  /// No description provided for @phala_nav_remedies.
  ///
  /// In en, this message translates to:
  /// **'Remedies'**
  String get phala_nav_remedies;

  /// No description provided for @phala_overallTheme.
  ///
  /// In en, this message translates to:
  /// **'Overall Theme'**
  String get phala_overallTheme;

  /// No description provided for @phala_keyEffects.
  ///
  /// In en, this message translates to:
  /// **'Key Effects'**
  String get phala_keyEffects;

  /// No description provided for @phala_lifeAreas.
  ///
  /// In en, this message translates to:
  /// **'Life Areas'**
  String get phala_lifeAreas;

  /// No description provided for @phala_remediesRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Remedies & Recommendations'**
  String get phala_remediesRecommendations;

  /// No description provided for @phala_infoFooter.
  ///
  /// In en, this message translates to:
  /// **'Mahadasha Phala provides general predictions. Consult an astrologer for personalized guidance.'**
  String get phala_infoFooter;

  /// No description provided for @phala_unavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Interpretation Unavailable'**
  String get phala_unavailableTitle;

  /// No description provided for @phala_unavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to load Mahadasha interpretation.'**
  String get phala_unavailableMessage;

  /// No description provided for @phala_badge.
  ///
  /// In en, this message translates to:
  /// **'PHALA'**
  String get phala_badge;

  /// No description provided for @phala_mahadashaName.
  ///
  /// In en, this message translates to:
  /// **'{planet} Mahadasha'**
  String phala_mahadashaName(Object planet);

  /// No description provided for @phala_remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get phala_remaining;

  /// No description provided for @phala_day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get phala_day;

  /// No description provided for @phala_color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get phala_color;

  /// No description provided for @phala_favorable.
  ///
  /// In en, this message translates to:
  /// **'Favorable'**
  String get phala_favorable;

  /// No description provided for @phala_challenges.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get phala_challenges;

  /// No description provided for @phala_antardashaName.
  ///
  /// In en, this message translates to:
  /// **'{antardasha} Antardasha'**
  String phala_antardashaName(Object antardasha);

  /// No description provided for @phala_remaining_duration.
  ///
  /// In en, this message translates to:
  /// **'{duration} remaining'**
  String phala_remaining_duration(Object duration);

  /// No description provided for @phala_gemstone.
  ///
  /// In en, this message translates to:
  /// **'Gemstone'**
  String get phala_gemstone;

  /// No description provided for @phala_deity.
  ///
  /// In en, this message translates to:
  /// **'Deity'**
  String get phala_deity;

  /// No description provided for @phala_mantra.
  ///
  /// In en, this message translates to:
  /// **'Mantra'**
  String get phala_mantra;

  /// No description provided for @phala_suggestedPractices.
  ///
  /// In en, this message translates to:
  /// **'Suggested Practices'**
  String get phala_suggestedPractices;

  /// No description provided for @phala_day_sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get phala_day_sunday;

  /// No description provided for @phala_day_monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get phala_day_monday;

  /// No description provided for @phala_day_tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get phala_day_tuesday;

  /// No description provided for @phala_day_wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get phala_day_wednesday;

  /// No description provided for @phala_day_thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get phala_day_thursday;

  /// No description provided for @phala_day_friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get phala_day_friday;

  /// No description provided for @phala_day_saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get phala_day_saturday;

  /// No description provided for @phala_day_sun_short.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get phala_day_sun_short;

  /// No description provided for @phala_day_mon_short.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get phala_day_mon_short;

  /// No description provided for @phala_day_tue_short.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get phala_day_tue_short;

  /// No description provided for @phala_day_wed_short.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get phala_day_wed_short;

  /// No description provided for @phala_day_thu_short.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get phala_day_thu_short;

  /// No description provided for @phala_day_fri_short.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get phala_day_fri_short;

  /// No description provided for @phala_day_sat_short.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get phala_day_sat_short;

  /// No description provided for @dasha_insight_system.
  ///
  /// In en, this message translates to:
  /// **'Dasha System'**
  String get dasha_insight_system;

  /// No description provided for @dasha_insight_whatThisMeans.
  ///
  /// In en, this message translates to:
  /// **'What This Means'**
  String get dasha_insight_whatThisMeans;

  /// No description provided for @dasha_insight_significance.
  ///
  /// In en, this message translates to:
  /// **'Significance'**
  String get dasha_insight_significance;

  /// No description provided for @dasha_insight_keyPoints.
  ///
  /// In en, this message translates to:
  /// **'Key Points'**
  String get dasha_insight_keyPoints;

  /// No description provided for @dasha_vimshottari_title.
  ///
  /// In en, this message translates to:
  /// **'Vimshottari'**
  String get dasha_vimshottari_title;

  /// No description provided for @dasha_vimshottari_desc.
  ///
  /// In en, this message translates to:
  /// **'Vimshottari Dasha is the most widely used planetary period system in Vedic astrology. It\'s a 120-year cycle based on the Moon\'s Nakshatra (lunar mansion) at birth.'**
  String get dasha_vimshottari_desc;

  /// No description provided for @dasha_vimshottari_significance.
  ///
  /// In en, this message translates to:
  /// **'This system reveals the timing of life events by showing which planetary energies are active during specific periods of your life.'**
  String get dasha_vimshottari_significance;

  /// No description provided for @dasha_vimshottari_point1.
  ///
  /// In en, this message translates to:
  /// **'Based on Moon\'s birth Nakshatra'**
  String get dasha_vimshottari_point1;

  /// No description provided for @dasha_vimshottari_point2.
  ///
  /// In en, this message translates to:
  /// **'120-year complete cycle'**
  String get dasha_vimshottari_point2;

  /// No description provided for @dasha_vimshottari_point3.
  ///
  /// In en, this message translates to:
  /// **'9 planetary periods (Mahadasha)'**
  String get dasha_vimshottari_point3;

  /// No description provided for @dasha_vimshottari_point4.
  ///
  /// In en, this message translates to:
  /// **'Each period has sub-periods (Antardasha)'**
  String get dasha_vimshottari_point4;

  /// No description provided for @dasha_vimshottari_point5.
  ///
  /// In en, this message translates to:
  /// **'Most accurate for timing predictions'**
  String get dasha_vimshottari_point5;

  /// No description provided for @dasha_phala_title.
  ///
  /// In en, this message translates to:
  /// **'Mahadasha Phala'**
  String get dasha_phala_title;

  /// No description provided for @dasha_phala_desc.
  ///
  /// In en, this message translates to:
  /// **'Mahadasha Phala focuses on the results and effects of major planetary periods. It provides detailed predictions for each Mahadasha based on planetary positions.'**
  String get dasha_phala_desc;

  /// No description provided for @dasha_phala_significance.
  ///
  /// In en, this message translates to:
  /// **'This analysis helps understand what specific results each Mahadasha will bring based on the planet\'s house placement and aspects.'**
  String get dasha_phala_significance;

  /// No description provided for @dasha_phala_point1.
  ///
  /// In en, this message translates to:
  /// **'Focuses on period results'**
  String get dasha_phala_point1;

  /// No description provided for @dasha_phala_point2.
  ///
  /// In en, this message translates to:
  /// **'House-based predictions'**
  String get dasha_phala_point2;

  /// No description provided for @dasha_phala_point3.
  ///
  /// In en, this message translates to:
  /// **'Considers planetary aspects'**
  String get dasha_phala_point3;

  /// No description provided for @dasha_phala_point4.
  ///
  /// In en, this message translates to:
  /// **'Shows favorable/unfavorable periods'**
  String get dasha_phala_point4;

  /// No description provided for @dasha_phala_point5.
  ///
  /// In en, this message translates to:
  /// **'Helps in life planning'**
  String get dasha_phala_point5;

  /// No description provided for @dasha_yogini_title.
  ///
  /// In en, this message translates to:
  /// **'Yogini'**
  String get dasha_yogini_title;

  /// No description provided for @dasha_yogini_desc.
  ///
  /// In en, this message translates to:
  /// **'Yogini Dasha is a unique 36-year cycle named after 8 Yoginis (divine feminine energies). It\'s particularly useful for timing events and is known for its accuracy.'**
  String get dasha_yogini_desc;

  /// No description provided for @dasha_yogini_significance.
  ///
  /// In en, this message translates to:
  /// **'This shorter cycle system is excellent for precise timing and is said to give results that are more immediately noticeable.'**
  String get dasha_yogini_significance;

  /// No description provided for @dasha_yogini_point1.
  ///
  /// In en, this message translates to:
  /// **'36-year complete cycle'**
  String get dasha_yogini_point1;

  /// No description provided for @dasha_yogini_point2.
  ///
  /// In en, this message translates to:
  /// **'8 Yogini periods'**
  String get dasha_yogini_point2;

  /// No description provided for @dasha_yogini_point3.
  ///
  /// In en, this message translates to:
  /// **'Named after divine feminine'**
  String get dasha_yogini_point3;

  /// No description provided for @dasha_yogini_point4.
  ///
  /// In en, this message translates to:
  /// **'Excellent for timing events'**
  String get dasha_yogini_point4;

  /// No description provided for @dasha_yogini_point5.
  ///
  /// In en, this message translates to:
  /// **'Complementary to Vimshottari'**
  String get dasha_yogini_point5;

  /// No description provided for @dasha_char_title.
  ///
  /// In en, this message translates to:
  /// **'Chara (Jaimini)'**
  String get dasha_char_title;

  /// No description provided for @dasha_char_desc.
  ///
  /// In en, this message translates to:
  /// **'Chara Dasha is from the Jaimini system of astrology. It uses zodiac signs rather than planets and is based on the Karakamsha (soul\'s desire).'**
  String get dasha_char_desc;

  /// No description provided for @dasha_char_significance.
  ///
  /// In en, this message translates to:
  /// **'This sign-based system provides a different perspective on life timing and is particularly useful for understanding soul-level desires and karmic patterns.'**
  String get dasha_char_significance;

  /// No description provided for @dasha_char_point1.
  ///
  /// In en, this message translates to:
  /// **'Jaimini astrology system'**
  String get dasha_char_point1;

  /// No description provided for @dasha_char_point2.
  ///
  /// In en, this message translates to:
  /// **'Sign-based periods'**
  String get dasha_char_point2;

  /// No description provided for @dasha_char_point3.
  ///
  /// In en, this message translates to:
  /// **'Based on Karakamsha'**
  String get dasha_char_point3;

  /// No description provided for @dasha_char_point4.
  ///
  /// In en, this message translates to:
  /// **'Shows karmic patterns'**
  String get dasha_char_point4;

  /// No description provided for @dasha_char_point5.
  ///
  /// In en, this message translates to:
  /// **'Complements planetary Dashas'**
  String get dasha_char_point5;

  /// No description provided for @yoga_rajaYoga.
  ///
  /// In en, this message translates to:
  /// **'Raja Yoga'**
  String get yoga_rajaYoga;

  /// No description provided for @yoga_dhanaYoga.
  ///
  /// In en, this message translates to:
  /// **'Dhana Yoga'**
  String get yoga_dhanaYoga;

  /// No description provided for @yoga_gajaKesari.
  ///
  /// In en, this message translates to:
  /// **'Gaja Kesari Yoga'**
  String get yoga_gajaKesari;

  /// No description provided for @yoga_budhAditya.
  ///
  /// In en, this message translates to:
  /// **'Budh-Aditya Yoga'**
  String get yoga_budhAditya;

  /// No description provided for @yoga_hamsa.
  ///
  /// In en, this message translates to:
  /// **'Hamsa Yoga'**
  String get yoga_hamsa;

  /// No description provided for @yoga_malavya.
  ///
  /// In en, this message translates to:
  /// **'Malavya Yoga'**
  String get yoga_malavya;

  /// No description provided for @yoga_bhadra.
  ///
  /// In en, this message translates to:
  /// **'Bhadra Yoga'**
  String get yoga_bhadra;

  /// No description provided for @yoga_ruchaka.
  ///
  /// In en, this message translates to:
  /// **'Ruchaka Yoga'**
  String get yoga_ruchaka;

  /// No description provided for @yoga_shasha.
  ///
  /// In en, this message translates to:
  /// **'Shasha Yoga'**
  String get yoga_shasha;

  /// No description provided for @yogas_title.
  ///
  /// In en, this message translates to:
  /// **'Yogas & Doshas'**
  String get yogas_title;

  /// No description provided for @yogas_beneficial.
  ///
  /// In en, this message translates to:
  /// **'Beneficial Yogas'**
  String get yogas_beneficial;

  /// No description provided for @yogas_challenging.
  ///
  /// In en, this message translates to:
  /// **'Challenging Doshas'**
  String get yogas_challenging;

  /// No description provided for @yogas_planets.
  ///
  /// In en, this message translates to:
  /// **'Planets'**
  String get yogas_planets;

  /// No description provided for @yogas_strength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get yogas_strength;

  /// No description provided for @yogas_excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get yogas_excellent;

  /// No description provided for @yogas_veryFavorable.
  ///
  /// In en, this message translates to:
  /// **'Very Favorable'**
  String get yogas_veryFavorable;

  /// No description provided for @yogas_favorable.
  ///
  /// In en, this message translates to:
  /// **'Favorable'**
  String get yogas_favorable;

  /// No description provided for @yogas_mixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get yogas_mixed;

  /// No description provided for @yogas_challenging_label.
  ///
  /// In en, this message translates to:
  /// **'Challenging'**
  String get yogas_challenging_label;

  /// No description provided for @yogas_whatThisMeans.
  ///
  /// In en, this message translates to:
  /// **'What This Means'**
  String get yogas_whatThisMeans;

  /// No description provided for @yogas_significance.
  ///
  /// In en, this message translates to:
  /// **'Significance'**
  String get yogas_significance;

  /// No description provided for @yogas_keyPoints.
  ///
  /// In en, this message translates to:
  /// **'Key Points'**
  String get yogas_keyPoints;

  /// No description provided for @yogas_overview.
  ///
  /// In en, this message translates to:
  /// **'Yoga & Dosha Overview'**
  String get yogas_overview;

  /// No description provided for @dosha_manglik.
  ///
  /// In en, this message translates to:
  /// **'Manglik Dosha'**
  String get dosha_manglik;

  /// No description provided for @dosha_kalaSarpa.
  ///
  /// In en, this message translates to:
  /// **'Kala Sarpa Dosha'**
  String get dosha_kalaSarpa;

  /// No description provided for @dosha_pitruDosha.
  ///
  /// In en, this message translates to:
  /// **'Pitru Dosha'**
  String get dosha_pitruDosha;

  /// No description provided for @dosha_sadesati.
  ///
  /// In en, this message translates to:
  /// **'Sade Sati'**
  String get dosha_sadesati;

  /// No description provided for @dosha_dhaiya.
  ///
  /// In en, this message translates to:
  /// **'Shani Dhaiya'**
  String get dosha_dhaiya;

  /// No description provided for @strength_shadbala.
  ///
  /// In en, this message translates to:
  /// **'Shadbala'**
  String get strength_shadbala;

  /// No description provided for @strength_ashtakavarga.
  ///
  /// In en, this message translates to:
  /// **'Ashtakavarga'**
  String get strength_ashtakavarga;

  /// No description provided for @strength_digbala.
  ///
  /// In en, this message translates to:
  /// **'Dig Bala'**
  String get strength_digbala;

  /// No description provided for @strength_kalabala.
  ///
  /// In en, this message translates to:
  /// **'Kala Bala'**
  String get strength_kalabala;

  /// No description provided for @strength_chestabala.
  ///
  /// In en, this message translates to:
  /// **'Chesta Bala'**
  String get strength_chestabala;

  /// No description provided for @strength_naisargikabala.
  ///
  /// In en, this message translates to:
  /// **'Naisargika Bala'**
  String get strength_naisargikabala;

  /// No description provided for @strength_drikbala.
  ///
  /// In en, this message translates to:
  /// **'Drik Bala'**
  String get strength_drikbala;

  /// No description provided for @strength_sthanabala.
  ///
  /// In en, this message translates to:
  /// **'Sthana Bala'**
  String get strength_sthanabala;

  /// No description provided for @strength_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get strength_total;

  /// No description provided for @strength_strong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get strength_strong;

  /// No description provided for @strength_average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get strength_average;

  /// No description provided for @strength_weak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get strength_weak;

  /// No description provided for @strength_nav_overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get strength_nav_overview;

  /// No description provided for @strength_nav_shadbala.
  ///
  /// In en, this message translates to:
  /// **'Shadbala'**
  String get strength_nav_shadbala;

  /// No description provided for @strength_nav_vimshopaka.
  ///
  /// In en, this message translates to:
  /// **'Vimshopaka'**
  String get strength_nav_vimshopaka;

  /// No description provided for @strength_nav_ashtaka.
  ///
  /// In en, this message translates to:
  /// **'Ashtaka'**
  String get strength_nav_ashtaka;

  /// No description provided for @strength_excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get strength_excellent;

  /// No description provided for @strength_good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get strength_good;

  /// No description provided for @strength_needsSupport.
  ///
  /// In en, this message translates to:
  /// **'Needs Support'**
  String get strength_needsSupport;

  /// No description provided for @strength_medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get strength_medium;

  /// No description provided for @strength_chartStrength.
  ///
  /// In en, this message translates to:
  /// **'Chart Strength'**
  String get strength_chartStrength;

  /// No description provided for @strength_chartStrength_desc.
  ///
  /// In en, this message translates to:
  /// **'Your overall chart strength is measured by averaging the Shadbala (six-fold strength) of all planets. This indicates how well the planets are positioned to deliver their results in your life.'**
  String get strength_chartStrength_desc;

  /// No description provided for @strength_chartStrength_significance.
  ///
  /// In en, this message translates to:
  /// **'With {strongCount} strong planets and {weakCount} weak planets out of {totalPlanets}, your chart shows {result}.'**
  String strength_chartStrength_significance(
    int strongCount,
    int weakCount,
    int totalPlanets,
    String result,
  );

  /// No description provided for @strength_goodOverallStrength.
  ///
  /// In en, this message translates to:
  /// **'good overall planetary strength'**
  String get strength_goodOverallStrength;

  /// No description provided for @strength_needsRemedies.
  ///
  /// In en, this message translates to:
  /// **'areas that may benefit from remedial measures'**
  String get strength_needsRemedies;

  /// No description provided for @strength_avgStrength.
  ///
  /// In en, this message translates to:
  /// **'Average Strength: {value}%'**
  String strength_avgStrength(String value);

  /// No description provided for @strength_strongPlanets.
  ///
  /// In en, this message translates to:
  /// **'Strong Planets: {count} (≥100% of required)'**
  String strength_strongPlanets(int count);

  /// No description provided for @strength_weakPlanets.
  ///
  /// In en, this message translates to:
  /// **'Weak Planets: {count} (<100% of required)'**
  String strength_weakPlanets(int count);

  /// No description provided for @strength_strengthLevel.
  ///
  /// In en, this message translates to:
  /// **'Strength Level: {level}'**
  String strength_strengthLevel(String level);

  /// No description provided for @strength_excellentResult.
  ///
  /// In en, this message translates to:
  /// **'Excellent! Most planets can deliver strong results'**
  String get strength_excellentResult;

  /// No description provided for @strength_goodResult.
  ///
  /// In en, this message translates to:
  /// **'Good strength with minor areas to improve'**
  String get strength_goodResult;

  /// No description provided for @strength_considerRemedies.
  ///
  /// In en, this message translates to:
  /// **'Consider remedies for weak planets'**
  String get strength_considerRemedies;

  /// No description provided for @strength_shadbala_title.
  ///
  /// In en, this message translates to:
  /// **'Shadbala (षड्बल)'**
  String get strength_shadbala_title;

  /// No description provided for @strength_shadbala_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Six-fold planetary strength'**
  String get strength_shadbala_subtitle;

  /// No description provided for @strength_shadbala_desc.
  ///
  /// In en, this message translates to:
  /// **'Shadbala (षड्बल) means \"six-fold strength\" - the comprehensive Vedic system to calculate planetary power. A planet needs 100% of its required strength to give good results.'**
  String get strength_shadbala_desc;

  /// No description provided for @strength_shadbala_significance.
  ///
  /// In en, this message translates to:
  /// **'{planet} ranks #{rank} out of {total} planets with {bala} Rupas ({percentage}% of the {required} required). {status}'**
  String strength_shadbala_significance(
    String planet,
    int rank,
    int total,
    String bala,
    String percentage,
    String required,
    String status,
  );

  /// No description provided for @strength_shadbala_strongStatus.
  ///
  /// In en, this message translates to:
  /// **'This planet is strong and well-positioned to deliver positive results.'**
  String get strength_shadbala_strongStatus;

  /// No description provided for @strength_shadbala_weakStatus.
  ///
  /// In en, this message translates to:
  /// **'This planet may need strengthening through remedies.'**
  String get strength_shadbala_weakStatus;

  /// No description provided for @strength_totalShadbala.
  ///
  /// In en, this message translates to:
  /// **'Total Shadbala: {value} Rupas'**
  String strength_totalShadbala(String value);

  /// No description provided for @strength_required.
  ///
  /// In en, this message translates to:
  /// **'Required: {value} Rupas'**
  String strength_required(String value);

  /// No description provided for @strength_percentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage: {value}%'**
  String strength_percentage(String value);

  /// No description provided for @strength_rank.
  ///
  /// In en, this message translates to:
  /// **'Rank: #{rank} of {total} planets'**
  String strength_rank(int rank, int total);

  /// No description provided for @strength_statusStrong.
  ///
  /// In en, this message translates to:
  /// **'Status: Strong ✓'**
  String get strength_statusStrong;

  /// No description provided for @strength_statusNeedsSupport.
  ///
  /// In en, this message translates to:
  /// **'Status: Needs Support ⚠'**
  String get strength_statusNeedsSupport;

  /// No description provided for @strength_sthanaBala.
  ///
  /// In en, this message translates to:
  /// **'Sthana Bala: {value} (Position)'**
  String strength_sthanaBala(String value);

  /// No description provided for @strength_digBala.
  ///
  /// In en, this message translates to:
  /// **'Dig Bala: {value} (Direction)'**
  String strength_digBala(String value);

  /// No description provided for @strength_kalaBala.
  ///
  /// In en, this message translates to:
  /// **'Kala Bala: {value} (Time)'**
  String strength_kalaBala(String value);

  /// No description provided for @strength_chestaBala.
  ///
  /// In en, this message translates to:
  /// **'Chesta Bala: {value} (Motion)'**
  String strength_chestaBala(String value);

  /// No description provided for @strength_naisargikaBala.
  ///
  /// In en, this message translates to:
  /// **'Naisargika Bala: {value} (Natural)'**
  String strength_naisargikaBala(String value);

  /// No description provided for @strength_drikBala.
  ///
  /// In en, this message translates to:
  /// **'Drik Bala: {value} (Aspect)'**
  String strength_drikBala(String value);

  /// No description provided for @strength_vimshopaka_title.
  ///
  /// In en, this message translates to:
  /// **'Vimshopaka Bala'**
  String get strength_vimshopaka_title;

  /// No description provided for @strength_vimshopaka_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Divisional chart strength (20-point scale)'**
  String get strength_vimshopaka_subtitle;

  /// No description provided for @strength_vimshopaka_desc.
  ///
  /// In en, this message translates to:
  /// **'Vimshopaka Bala (20-point strength) evaluates planetary strength across 16 divisional charts (Shodasavarga). Each planet is scored out of {maxScore} points based on its dignity (exalted, own sign, friendly, etc.) in each divisional chart.'**
  String strength_vimshopaka_desc(String maxScore);

  /// No description provided for @strength_vimshopaka_significance.
  ///
  /// In en, this message translates to:
  /// **'{planet} scores {score}/{maxScore} ({percentage}%), classified as \"{strength}\". {result}'**
  String strength_vimshopaka_significance(
    String planet,
    String score,
    String maxScore,
    String percentage,
    String strength,
    String result,
  );

  /// No description provided for @strength_vimshopaka_strongResult.
  ///
  /// In en, this message translates to:
  /// **'This planet has excellent dignity across divisional charts.'**
  String get strength_vimshopaka_strongResult;

  /// No description provided for @strength_vimshopaka_mediumResult.
  ///
  /// In en, this message translates to:
  /// **'This planet has moderate dignity.'**
  String get strength_vimshopaka_mediumResult;

  /// No description provided for @strength_vimshopaka_weakResult.
  ///
  /// In en, this message translates to:
  /// **'This planet may need strengthening.'**
  String get strength_vimshopaka_weakResult;

  /// No description provided for @strength_vimshopakaScore.
  ///
  /// In en, this message translates to:
  /// **'Vimshopaka Score: {score}/{max}'**
  String strength_vimshopakaScore(String score, String max);

  /// No description provided for @strength_strengthCategory.
  ///
  /// In en, this message translates to:
  /// **'Strength Category: {category}'**
  String strength_strengthCategory(String category);

  /// No description provided for @strength_strongRange.
  ///
  /// In en, this message translates to:
  /// **'Strong: 75-100%'**
  String get strength_strongRange;

  /// No description provided for @strength_mediumRange.
  ///
  /// In en, this message translates to:
  /// **'Medium: 50-75%'**
  String get strength_mediumRange;

  /// No description provided for @strength_weakRange.
  ///
  /// In en, this message translates to:
  /// **'Weak: 0-50%'**
  String get strength_weakRange;

  /// No description provided for @strength_basedOnDivisional.
  ///
  /// In en, this message translates to:
  /// **'Based on dignity in 16 divisional charts'**
  String get strength_basedOnDivisional;

  /// No description provided for @strength_vimshopakaSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get strength_vimshopakaSummary;

  /// No description provided for @strength_vimshopakaSummary_desc.
  ///
  /// In en, this message translates to:
  /// **'Vimshopaka Bala (20-point strength) evaluates how well planets are placed across all 16 divisional charts (Shodasavarga). Each planet receives dignity points based on its placement in each divisional chart.'**
  String get strength_vimshopakaSummary_desc;

  /// No description provided for @strength_vimshopakaSummary_significance.
  ///
  /// In en, this message translates to:
  /// **'Of {total} planets: {strong} are Strong (75-100%), {medium} are Medium (50-75%), and {weak} are Weak (<50%).'**
  String strength_vimshopakaSummary_significance(
    int total,
    int strong,
    int medium,
    int weak,
  );

  /// No description provided for @strength_strongPlanetsCount.
  ///
  /// In en, this message translates to:
  /// **'Strong Planets: {count} (15-20 points)'**
  String strength_strongPlanetsCount(int count);

  /// No description provided for @strength_mediumPlanetsCount.
  ///
  /// In en, this message translates to:
  /// **'Medium Planets: {count} (10-15 points)'**
  String strength_mediumPlanetsCount(int count);

  /// No description provided for @strength_weakPlanetsCount.
  ///
  /// In en, this message translates to:
  /// **'Weak Planets: {count} (0-10 points)'**
  String strength_weakPlanetsCount(int count);

  /// No description provided for @strength_basedOn16Charts.
  ///
  /// In en, this message translates to:
  /// **'Based on 16 divisional charts (D1 to D60)'**
  String get strength_basedOn16Charts;

  /// No description provided for @strength_maxScorePlanet.
  ///
  /// In en, this message translates to:
  /// **'Max score: 20 points per planet'**
  String get strength_maxScorePlanet;

  /// No description provided for @strength_strongVimshopakaGoodDignity.
  ///
  /// In en, this message translates to:
  /// **'Strong Vimshopaka = Good dignity across all charts'**
  String get strength_strongVimshopakaGoodDignity;

  /// No description provided for @strength_tapForExplanation.
  ///
  /// In en, this message translates to:
  /// **'Tap for detailed explanation'**
  String get strength_tapForExplanation;

  /// No description provided for @strength_strengthFrom16Charts.
  ///
  /// In en, this message translates to:
  /// **'Strength from 16 divisional charts'**
  String get strength_strengthFrom16Charts;

  /// No description provided for @strength_med.
  ///
  /// In en, this message translates to:
  /// **'Med'**
  String get strength_med;

  /// No description provided for @strength_ashtakavarga_title.
  ///
  /// In en, this message translates to:
  /// **'Ashtakavarga (अष्टकवर्ग)'**
  String get strength_ashtakavarga_title;

  /// No description provided for @strength_ashtakavarga_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Transit strength by sign'**
  String get strength_ashtakavarga_subtitle;

  /// No description provided for @strength_ashtakavarga_transitSystem.
  ///
  /// In en, this message translates to:
  /// **'Transit Strength System'**
  String get strength_ashtakavarga_transitSystem;

  /// No description provided for @strength_ashtakavarga_desc.
  ///
  /// In en, this message translates to:
  /// **'Ashtakavarga is a unique Vedic system to evaluate sign strength for transit predictions. Each of the 7 planets contributes 0-8 benefic points (bindus) to each sign. The Sarvashtakavarga (SAV) is the combined score of all planets for each sign.'**
  String get strength_ashtakavarga_desc;

  /// No description provided for @strength_ashtakavarga_significance.
  ///
  /// In en, this message translates to:
  /// **'Your strongest sign for transits is {strongSign} ({strongPoints} points) and weakest is {weakSign} ({weakPoints} points). Total SAV across all signs is {total}.'**
  String strength_ashtakavarga_significance(
    String strongSign,
    int strongPoints,
    String weakSign,
    int weakPoints,
    int total,
  );

  /// No description provided for @strength_strongestSign.
  ///
  /// In en, this message translates to:
  /// **'Strongest Sign: {sign} ({points} pts)'**
  String strength_strongestSign(String sign, int points);

  /// No description provided for @strength_weakestSign.
  ///
  /// In en, this message translates to:
  /// **'Weakest Sign: {sign} ({points} pts)'**
  String strength_weakestSign(String sign, int points);

  /// No description provided for @strength_totalSav.
  ///
  /// In en, this message translates to:
  /// **'Total SAV: {points} points'**
  String strength_totalSav(int points);

  /// No description provided for @strength_individualBav.
  ///
  /// In en, this message translates to:
  /// **'Individual BAV: 0-8 points per planet-sign'**
  String get strength_individualBav;

  /// No description provided for @strength_savCombined.
  ///
  /// In en, this message translates to:
  /// **'SAV: 0-56 points per sign (combined)'**
  String get strength_savCombined;

  /// No description provided for @strength_goodBav.
  ///
  /// In en, this message translates to:
  /// **'Good BAV: ≥4 points'**
  String get strength_goodBav;

  /// No description provided for @strength_strongSav.
  ///
  /// In en, this message translates to:
  /// **'Strong SAV: ≥28 points'**
  String get strength_strongSav;

  /// No description provided for @strength_sarvashtakavarga.
  ///
  /// In en, this message translates to:
  /// **'Sarvashtakavarga'**
  String get strength_sarvashtakavarga;

  /// No description provided for @strength_sav_desc.
  ///
  /// In en, this message translates to:
  /// **'Sarvashtakavarga (SAV) is the combined Ashtakavarga points of all 7 planets for each sign. It shows the overall strength of each sign for transits and results. Maximum possible is 56 points (8 points × 7 planets).'**
  String get strength_sav_desc;

  /// No description provided for @strength_sav_signStrong.
  ///
  /// In en, this message translates to:
  /// **'{sign} has {points} SAV points. This sign is strong and transits through it generally give positive results.'**
  String strength_sav_signStrong(String sign, int points);

  /// No description provided for @strength_sav_signWeak.
  ///
  /// In en, this message translates to:
  /// **'{sign} has {points} SAV points. Transits through this sign may need more attention.'**
  String strength_sav_signWeak(String sign, int points);

  /// No description provided for @strength_bav_desc.
  ///
  /// In en, this message translates to:
  /// **'Ashtakavarga shows benefic points (0-8) each planet contributes to each sign. Points ≥4 are auspicious. This helps predict transit effects - planets transiting signs with higher points give better results.'**
  String get strength_bav_desc;

  /// No description provided for @strength_bav_signStrong.
  ///
  /// In en, this message translates to:
  /// **'{sign} has {points} bindus. Transits of this planet through {sign} are generally favorable.'**
  String strength_bav_signStrong(String sign, int points);

  /// No description provided for @strength_bav_signWeak.
  ///
  /// In en, this message translates to:
  /// **'{sign} has {points} bindus. Extra care needed during transits through this sign.'**
  String strength_bav_signWeak(String sign, int points);

  /// No description provided for @strength_sign.
  ///
  /// In en, this message translates to:
  /// **'Sign: {sign}'**
  String strength_sign(String sign);

  /// No description provided for @strength_pointsSav.
  ///
  /// In en, this message translates to:
  /// **'Points: {points}/56'**
  String strength_pointsSav(int points);

  /// No description provided for @strength_pointsBav.
  ///
  /// In en, this message translates to:
  /// **'Points: {points}/8'**
  String strength_pointsBav(int points);

  /// No description provided for @strength_typeSav.
  ///
  /// In en, this message translates to:
  /// **'Type: Sarvashtakavarga (Combined)'**
  String get strength_typeSav;

  /// No description provided for @strength_typeBav.
  ///
  /// In en, this message translates to:
  /// **'Type: Bhinna Ashtakavarga (Individual)'**
  String get strength_typeBav;

  /// No description provided for @strength_strongSavThreshold.
  ///
  /// In en, this message translates to:
  /// **'Strong: ≥28 points'**
  String get strength_strongSavThreshold;

  /// No description provided for @strength_auspiciousBavThreshold.
  ///
  /// In en, this message translates to:
  /// **'Auspicious: ≥4 points'**
  String get strength_auspiciousBavThreshold;

  /// No description provided for @strength_usedForTransit.
  ///
  /// In en, this message translates to:
  /// **'Used for transit predictions'**
  String get strength_usedForTransit;

  /// No description provided for @strength_totalSarvashtakavarga.
  ///
  /// In en, this message translates to:
  /// **'Total Sarvashtakavarga'**
  String get strength_totalSarvashtakavarga;

  /// No description provided for @strength_totalSav_points.
  ///
  /// In en, this message translates to:
  /// **'{points} Points'**
  String strength_totalSav_points(int points);

  /// No description provided for @strength_totalSav_desc.
  ///
  /// In en, this message translates to:
  /// **'The Total SAV is the sum of all Sarvashtakavarga points across all 12 signs. Maximum possible is 337 points. A higher total indicates overall stronger chart for transits.'**
  String get strength_totalSav_desc;

  /// No description provided for @strength_totalSav_excellent.
  ///
  /// In en, this message translates to:
  /// **'Your total SAV of {points} points is excellent, indicating a strong overall chart.'**
  String strength_totalSav_excellent(int points);

  /// No description provided for @strength_totalSav_good.
  ///
  /// In en, this message translates to:
  /// **'Your total SAV of {points} points is good, showing balanced strength.'**
  String strength_totalSav_good(int points);

  /// No description provided for @strength_totalSav_focus.
  ///
  /// In en, this message translates to:
  /// **'Your total SAV of {points} points suggests focusing on beneficial transit periods.'**
  String strength_totalSav_focus(int points);

  /// No description provided for @strength_maxPossible.
  ///
  /// In en, this message translates to:
  /// **'Maximum possible: 337 points'**
  String get strength_maxPossible;

  /// No description provided for @strength_calculationSum.
  ///
  /// In en, this message translates to:
  /// **'Calculation: Sum of all 12 sign SAV values'**
  String get strength_calculationSum;

  /// No description provided for @strength_higherBetter.
  ///
  /// In en, this message translates to:
  /// **'Higher = Better overall transit strength'**
  String get strength_higherBetter;

  /// No description provided for @strength_lagnaLord.
  ///
  /// In en, this message translates to:
  /// **'Lagna Lord'**
  String get strength_lagnaLord;

  /// No description provided for @strength_lagnaLord_strength.
  ///
  /// In en, this message translates to:
  /// **'Lagna Lord Strength'**
  String get strength_lagnaLord_strength;

  /// No description provided for @strength_lagnaLord_desc.
  ///
  /// In en, this message translates to:
  /// **'The Lagna Lord (Ascendant Lord) is the most important planet in your chart. It rules your Ascendant sign and represents your overall life path, personality, and vitality. Its strength directly impacts your ability to achieve success.'**
  String get strength_lagnaLord_desc;

  /// No description provided for @strength_lagnaLord_significance.
  ///
  /// In en, this message translates to:
  /// **'{lagnaLord} rules {ascendantSign} (your Ascendant). {status}'**
  String strength_lagnaLord_significance(
    String lagnaLord,
    String ascendantSign,
    String status,
  );

  /// No description provided for @strength_lagnaLord_strong.
  ///
  /// In en, this message translates to:
  /// **'Your Lagna Lord is strong, indicating good vitality and ability to overcome obstacles.'**
  String get strength_lagnaLord_strong;

  /// No description provided for @strength_lagnaLord_weak.
  ///
  /// In en, this message translates to:
  /// **'Your Lagna Lord needs strengthening for better life results.'**
  String get strength_lagnaLord_weak;

  /// No description provided for @strength_lagnaLord_label.
  ///
  /// In en, this message translates to:
  /// **'Lagna Lord: {planet}'**
  String strength_lagnaLord_label(String planet);

  /// No description provided for @strength_rules.
  ///
  /// In en, this message translates to:
  /// **'Rules: {sign} Ascendant'**
  String strength_rules(String sign);

  /// No description provided for @strength_lagnaLordCondition.
  ///
  /// In en, this message translates to:
  /// **'The Lagna Lord\'s condition affects overall life success'**
  String get strength_lagnaLordCondition;

  /// No description provided for @strength_legend_sthana.
  ///
  /// In en, this message translates to:
  /// **'Sthana'**
  String get strength_legend_sthana;

  /// No description provided for @strength_legend_sthana_hint.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get strength_legend_sthana_hint;

  /// No description provided for @strength_legend_dig.
  ///
  /// In en, this message translates to:
  /// **'Dig'**
  String get strength_legend_dig;

  /// No description provided for @strength_legend_dig_hint.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get strength_legend_dig_hint;

  /// No description provided for @strength_legend_kala.
  ///
  /// In en, this message translates to:
  /// **'Kala'**
  String get strength_legend_kala;

  /// No description provided for @strength_legend_kala_hint.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get strength_legend_kala_hint;

  /// No description provided for @strength_legend_chesta.
  ///
  /// In en, this message translates to:
  /// **'Chesta'**
  String get strength_legend_chesta;

  /// No description provided for @strength_legend_chesta_hint.
  ///
  /// In en, this message translates to:
  /// **'Motion'**
  String get strength_legend_chesta_hint;

  /// No description provided for @strength_legend_naisarg.
  ///
  /// In en, this message translates to:
  /// **'Naisarg'**
  String get strength_legend_naisarg;

  /// No description provided for @strength_legend_naisarg_hint.
  ///
  /// In en, this message translates to:
  /// **'Natural'**
  String get strength_legend_naisarg_hint;

  /// No description provided for @strength_legend_drik.
  ///
  /// In en, this message translates to:
  /// **'Drik'**
  String get strength_legend_drik;

  /// No description provided for @strength_legend_drik_hint.
  ///
  /// In en, this message translates to:
  /// **'Aspect'**
  String get strength_legend_drik_hint;

  /// No description provided for @strength_rupas.
  ///
  /// In en, this message translates to:
  /// **'{value} / {required} Rupas'**
  String strength_rupas(String value, String required);

  /// No description provided for @strength_strongest.
  ///
  /// In en, this message translates to:
  /// **'Strongest'**
  String get strength_strongest;

  /// No description provided for @strength_weakest.
  ///
  /// In en, this message translates to:
  /// **'Weakest'**
  String get strength_weakest;

  /// No description provided for @strength_pointsPerSign.
  ///
  /// In en, this message translates to:
  /// **'Points 0-8 per sign'**
  String get strength_pointsPerSign;

  /// No description provided for @strength_goodThreshold.
  ///
  /// In en, this message translates to:
  /// **'≥4 Good'**
  String get strength_goodThreshold;

  /// No description provided for @strength_savThreshold.
  ///
  /// In en, this message translates to:
  /// **'SAV ≥28 Strong'**
  String get strength_savThreshold;

  /// No description provided for @strength_points.
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get strength_points;

  /// No description provided for @strength_pts.
  ///
  /// In en, this message translates to:
  /// **'pts'**
  String get strength_pts;

  /// No description provided for @strength_vimshopakaStrength.
  ///
  /// In en, this message translates to:
  /// **'Vimshopaka Strength'**
  String get strength_vimshopakaStrength;

  /// No description provided for @strength_vimshopakaStrength_strong_desc.
  ///
  /// In en, this message translates to:
  /// **'Planets with 15-20 Vimshopaka points (75-100%). These planets have excellent dignity across divisional charts and give strong results.'**
  String get strength_vimshopakaStrength_strong_desc;

  /// No description provided for @strength_vimshopakaStrength_medium_desc.
  ///
  /// In en, this message translates to:
  /// **'Planets with 10-15 Vimshopaka points (50-75%). These planets have moderate dignity and give balanced results.'**
  String get strength_vimshopakaStrength_medium_desc;

  /// No description provided for @strength_vimshopakaStrength_weak_desc.
  ///
  /// In en, this message translates to:
  /// **'Planets with 0-10 Vimshopaka points (<50%). These planets may need strengthening through remedies.'**
  String get strength_vimshopakaStrength_weak_desc;

  /// No description provided for @strength_vimshopakaStrength_significance.
  ///
  /// In en, this message translates to:
  /// **'You have {count} {category} planet(s) based on Vimshopaka Bala scoring.'**
  String strength_vimshopakaStrength_significance(int count, String category);

  /// No description provided for @strength_countPlanets.
  ///
  /// In en, this message translates to:
  /// **'Count: {count} planets'**
  String strength_countPlanets(int count);

  /// No description provided for @strength_category.
  ///
  /// In en, this message translates to:
  /// **'Category: {category}'**
  String strength_category(String category);

  /// No description provided for @strength_scoreRangeStrong.
  ///
  /// In en, this message translates to:
  /// **'Score Range: 15-20 points (75-100%)'**
  String get strength_scoreRangeStrong;

  /// No description provided for @strength_scoreRangeMedium.
  ///
  /// In en, this message translates to:
  /// **'Score Range: 10-15 points (50-75%)'**
  String get strength_scoreRangeMedium;

  /// No description provided for @strength_scoreRangeWeak.
  ///
  /// In en, this message translates to:
  /// **'Score Range: 0-10 points (0-50%)'**
  String get strength_scoreRangeWeak;

  /// No description provided for @strength_planetsPlanets.
  ///
  /// In en, this message translates to:
  /// **'{label} Planets'**
  String strength_planetsPlanets(String label);

  /// No description provided for @strength_haveCount.
  ///
  /// In en, this message translates to:
  /// **'You have {value} {label} planets in your chart.'**
  String strength_haveCount(String value, String label);

  /// No description provided for @strength_countLabel.
  ///
  /// In en, this message translates to:
  /// **'Count: {value} planets'**
  String strength_countLabel(String value);

  /// No description provided for @strength_statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status: {label}'**
  String strength_statusLabel(String label);

  /// No description provided for @transit_current.
  ///
  /// In en, this message translates to:
  /// **'Current Transit'**
  String get transit_current;

  /// No description provided for @transit_effects.
  ///
  /// In en, this message translates to:
  /// **'Transit Effects'**
  String get transit_effects;

  /// No description provided for @transit_planetaryPositions.
  ///
  /// In en, this message translates to:
  /// **'Planetary Positions'**
  String get transit_planetaryPositions;

  /// No description provided for @transit_aspects.
  ///
  /// In en, this message translates to:
  /// **'Aspects'**
  String get transit_aspects;

  /// No description provided for @transit_prediction.
  ///
  /// In en, this message translates to:
  /// **'Prediction'**
  String get transit_prediction;

  /// No description provided for @transit_favorable.
  ///
  /// In en, this message translates to:
  /// **'Favorable'**
  String get transit_favorable;

  /// No description provided for @transit_unfavorable.
  ///
  /// In en, this message translates to:
  /// **'Unfavorable'**
  String get transit_unfavorable;

  /// No description provided for @transit_neutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get transit_neutral;

  /// No description provided for @panchang_tithi.
  ///
  /// In en, this message translates to:
  /// **'Tithi'**
  String get panchang_tithi;

  /// No description provided for @panchang_nakshatra.
  ///
  /// In en, this message translates to:
  /// **'Nakshatra'**
  String get panchang_nakshatra;

  /// No description provided for @panchang_yoga.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get panchang_yoga;

  /// No description provided for @panchang_karana.
  ///
  /// In en, this message translates to:
  /// **'Karana'**
  String get panchang_karana;

  /// No description provided for @panchang_vara.
  ///
  /// In en, this message translates to:
  /// **'Vara'**
  String get panchang_vara;

  /// No description provided for @panchang_sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get panchang_sunrise;

  /// No description provided for @panchang_sunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get panchang_sunset;

  /// No description provided for @panchang_moonrise.
  ///
  /// In en, this message translates to:
  /// **'Moonrise'**
  String get panchang_moonrise;

  /// No description provided for @panchang_moonset.
  ///
  /// In en, this message translates to:
  /// **'Moonset'**
  String get panchang_moonset;

  /// No description provided for @panchang_rahuKalam.
  ///
  /// In en, this message translates to:
  /// **'Rahu Kalam'**
  String get panchang_rahuKalam;

  /// No description provided for @panchang_yamaGandam.
  ///
  /// In en, this message translates to:
  /// **'Yama Gandam'**
  String get panchang_yamaGandam;

  /// No description provided for @panchang_gulika.
  ///
  /// In en, this message translates to:
  /// **'Gulika Kalam'**
  String get panchang_gulika;

  /// No description provided for @panchang_abhijit.
  ///
  /// In en, this message translates to:
  /// **'Abhijit Muhurta'**
  String get panchang_abhijit;

  /// No description provided for @panchang_auspicious.
  ///
  /// In en, this message translates to:
  /// **'Auspicious Times'**
  String get panchang_auspicious;

  /// No description provided for @panchang_inauspicious.
  ///
  /// In en, this message translates to:
  /// **'Inauspicious Times'**
  String get panchang_inauspicious;

  /// No description provided for @panchang_moonPhase.
  ///
  /// In en, this message translates to:
  /// **'Moon Phase'**
  String get panchang_moonPhase;

  /// No description provided for @details_birthDetails.
  ///
  /// In en, this message translates to:
  /// **'Birth Details'**
  String get details_birthDetails;

  /// No description provided for @details_birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get details_birthDate;

  /// No description provided for @details_birthTime.
  ///
  /// In en, this message translates to:
  /// **'Birth Time'**
  String get details_birthTime;

  /// No description provided for @details_birthPlace.
  ///
  /// In en, this message translates to:
  /// **'Birth Place'**
  String get details_birthPlace;

  /// No description provided for @details_latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get details_latitude;

  /// No description provided for @details_longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get details_longitude;

  /// No description provided for @details_timezone.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get details_timezone;

  /// No description provided for @details_ascendant.
  ///
  /// In en, this message translates to:
  /// **'Ascendant'**
  String get details_ascendant;

  /// No description provided for @details_moonSign.
  ///
  /// In en, this message translates to:
  /// **'Moon Sign'**
  String get details_moonSign;

  /// No description provided for @details_sunSign.
  ///
  /// In en, this message translates to:
  /// **'Sun Sign'**
  String get details_sunSign;

  /// No description provided for @details_birthNakshatra.
  ///
  /// In en, this message translates to:
  /// **'Birth Nakshatra'**
  String get details_birthNakshatra;

  /// No description provided for @details_pada.
  ///
  /// In en, this message translates to:
  /// **'Pada {number}'**
  String details_pada(int number);

  /// No description provided for @details_varna.
  ///
  /// In en, this message translates to:
  /// **'Varna'**
  String get details_varna;

  /// No description provided for @details_vashya.
  ///
  /// In en, this message translates to:
  /// **'Vashya'**
  String get details_vashya;

  /// No description provided for @details_yoni.
  ///
  /// In en, this message translates to:
  /// **'Yoni'**
  String get details_yoni;

  /// No description provided for @details_gan.
  ///
  /// In en, this message translates to:
  /// **'Gan'**
  String get details_gan;

  /// No description provided for @details_nadi.
  ///
  /// In en, this message translates to:
  /// **'Nadi'**
  String get details_nadi;

  /// No description provided for @alert_sadeSati.
  ///
  /// In en, this message translates to:
  /// **'Shani Sade Sati'**
  String get alert_sadeSati;

  /// No description provided for @alert_sadeSatiActive.
  ///
  /// In en, this message translates to:
  /// **'Sade Sati Active'**
  String get alert_sadeSatiActive;

  /// No description provided for @alert_sadeSatiDescription.
  ///
  /// In en, this message translates to:
  /// **'Saturn is transiting through your Moon sign, causing a 7.5 year challenging period'**
  String get alert_sadeSatiDescription;

  /// No description provided for @alert_risingPhase.
  ///
  /// In en, this message translates to:
  /// **'Rising Phase (1st)'**
  String get alert_risingPhase;

  /// No description provided for @alert_peakPhase.
  ///
  /// In en, this message translates to:
  /// **'Peak Phase'**
  String get alert_peakPhase;

  /// No description provided for @alert_settingPhase.
  ///
  /// In en, this message translates to:
  /// **'Setting Phase (3rd)'**
  String get alert_settingPhase;

  /// No description provided for @alert_shaniDhaiya.
  ///
  /// In en, this message translates to:
  /// **'Shani Dhaiya'**
  String get alert_shaniDhaiya;

  /// No description provided for @alert_saturnIn.
  ///
  /// In en, this message translates to:
  /// **'Saturn in {house} from Moon'**
  String alert_saturnIn(String house);

  /// No description provided for @alert_mahadasha.
  ///
  /// In en, this message translates to:
  /// **'{planet} Mahadasha'**
  String alert_mahadasha(String planet);

  /// No description provided for @alert_currentMajorPeriod.
  ///
  /// In en, this message translates to:
  /// **'Current major period'**
  String get alert_currentMajorPeriod;

  /// No description provided for @alert_manglikDosha.
  ///
  /// In en, this message translates to:
  /// **'Manglik Dosha'**
  String get alert_manglikDosha;

  /// No description provided for @alert_manglikDescription.
  ///
  /// In en, this message translates to:
  /// **'Mars is placed in houses that affect marriage prospects'**
  String get alert_manglikDescription;

  /// No description provided for @alert_marsInHouse.
  ///
  /// In en, this message translates to:
  /// **'Mars in {house} house'**
  String alert_marsInHouse(String house);

  /// No description provided for @alert_lunarSensitivity.
  ///
  /// In en, this message translates to:
  /// **'Lunar Sensitivity'**
  String get alert_lunarSensitivity;

  /// No description provided for @alert_moonWith.
  ///
  /// In en, this message translates to:
  /// **'Moon with {planet}'**
  String alert_moonWith(String planet);

  /// No description provided for @alert_moonInHouse.
  ///
  /// In en, this message translates to:
  /// **'Moon in {house} house'**
  String alert_moonInHouse(String house);

  /// No description provided for @alert_beneficialYoga.
  ///
  /// In en, this message translates to:
  /// **'Beneficial Yoga'**
  String get alert_beneficialYoga;

  /// No description provided for @alert_kalaSarpa.
  ///
  /// In en, this message translates to:
  /// **'Kala Sarpa Dosha'**
  String get alert_kalaSarpa;

  /// No description provided for @alert_kalaSarpaDescription.
  ///
  /// In en, this message translates to:
  /// **'All planets are hemmed between Rahu and Ketu'**
  String get alert_kalaSarpaDescription;

  /// No description provided for @alert_currentDasha.
  ///
  /// In en, this message translates to:
  /// **'Current Dasha Period'**
  String get alert_currentDasha;

  /// No description provided for @alert_remedy.
  ///
  /// In en, this message translates to:
  /// **'Remedies'**
  String get alert_remedy;

  /// No description provided for @alert_priority_high.
  ///
  /// In en, this message translates to:
  /// **'High Priority'**
  String get alert_priority_high;

  /// No description provided for @alert_priority_medium.
  ///
  /// In en, this message translates to:
  /// **'Medium Priority'**
  String get alert_priority_medium;

  /// No description provided for @alert_priority_low.
  ///
  /// In en, this message translates to:
  /// **'Low Priority'**
  String get alert_priority_low;

  /// No description provided for @alert_viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all {count}'**
  String alert_viewAll(int count);

  /// No description provided for @details_nav_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get details_nav_profile;

  /// No description provided for @details_nav_star.
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get details_nav_star;

  /// No description provided for @details_nav_panchang.
  ///
  /// In en, this message translates to:
  /// **'Panchang'**
  String get details_nav_panchang;

  /// No description provided for @details_nav_dasha.
  ///
  /// In en, this message translates to:
  /// **'Dasha'**
  String get details_nav_dasha;

  /// No description provided for @details_nav_guna.
  ///
  /// In en, this message translates to:
  /// **'Guna'**
  String get details_nav_guna;

  /// No description provided for @details_nav_lucky.
  ///
  /// In en, this message translates to:
  /// **'Lucky'**
  String get details_nav_lucky;

  /// No description provided for @details_nav_planets.
  ///
  /// In en, this message translates to:
  /// **'Planets'**
  String get details_nav_planets;

  /// No description provided for @details_section_coreElements.
  ///
  /// In en, this message translates to:
  /// **'Core Elements'**
  String get details_section_coreElements;

  /// No description provided for @details_section_birthStar.
  ///
  /// In en, this message translates to:
  /// **'Birth Star'**
  String get details_section_birthStar;

  /// No description provided for @details_section_panchang.
  ///
  /// In en, this message translates to:
  /// **'Panchang'**
  String get details_section_panchang;

  /// No description provided for @details_section_currentPeriod.
  ///
  /// In en, this message translates to:
  /// **'Current Period'**
  String get details_section_currentPeriod;

  /// No description provided for @details_section_gunaFactors.
  ///
  /// In en, this message translates to:
  /// **'Guna Factors'**
  String get details_section_gunaFactors;

  /// No description provided for @details_section_favorableElements.
  ///
  /// In en, this message translates to:
  /// **'Favorable Elements'**
  String get details_section_favorableElements;

  /// No description provided for @details_section_planetaryStatus.
  ///
  /// In en, this message translates to:
  /// **'Planetary Status'**
  String get details_section_planetaryStatus;

  /// No description provided for @details_risingSign.
  ///
  /// In en, this message translates to:
  /// **'Rising Sign'**
  String get details_risingSign;

  /// No description provided for @details_element.
  ///
  /// In en, this message translates to:
  /// **'Element'**
  String get details_element;

  /// No description provided for @details_lagnaLord.
  ///
  /// In en, this message translates to:
  /// **'Lagna Lord'**
  String get details_lagnaLord;

  /// No description provided for @details_nakshatraLord.
  ///
  /// In en, this message translates to:
  /// **'Nakshatra Lord'**
  String get details_nakshatraLord;

  /// No description provided for @details_chartRuler.
  ///
  /// In en, this message translates to:
  /// **'Chart ruler'**
  String get details_chartRuler;

  /// No description provided for @details_starLord.
  ///
  /// In en, this message translates to:
  /// **'Star lord'**
  String get details_starLord;

  /// No description provided for @details_lord.
  ///
  /// In en, this message translates to:
  /// **'Lord'**
  String get details_lord;

  /// No description provided for @details_deity.
  ///
  /// In en, this message translates to:
  /// **'Deity'**
  String get details_deity;

  /// No description provided for @details_paksha.
  ///
  /// In en, this message translates to:
  /// **'{name} Paksha'**
  String details_paksha(String name);

  /// No description provided for @details_yoga.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get details_yoga;

  /// No description provided for @details_karana.
  ///
  /// In en, this message translates to:
  /// **'Karana'**
  String get details_karana;

  /// No description provided for @details_vara.
  ///
  /// In en, this message translates to:
  /// **'Vara'**
  String get details_vara;

  /// No description provided for @details_nakshatra.
  ///
  /// In en, this message translates to:
  /// **'Nakshatra'**
  String get details_nakshatra;

  /// No description provided for @details_tithi.
  ///
  /// In en, this message translates to:
  /// **'Tithi'**
  String get details_tithi;

  /// No description provided for @details_varaDay.
  ///
  /// In en, this message translates to:
  /// **'Vara (Day)'**
  String get details_varaDay;

  /// No description provided for @details_mahadasha.
  ///
  /// In en, this message translates to:
  /// **'{planet} Mahadasha'**
  String details_mahadasha(String planet);

  /// No description provided for @details_yearsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{years} years remaining'**
  String details_yearsRemaining(String years);

  /// No description provided for @details_upcoming.
  ///
  /// In en, this message translates to:
  /// **'UPCOMING'**
  String get details_upcoming;

  /// No description provided for @details_gunaInfo.
  ///
  /// In en, this message translates to:
  /// **'Your Ashtakoot factors for compatibility matching'**
  String get details_gunaInfo;

  /// No description provided for @details_primaryGemstone.
  ///
  /// In en, this message translates to:
  /// **'Primary Gemstone'**
  String get details_primaryGemstone;

  /// No description provided for @details_wearOn.
  ///
  /// In en, this message translates to:
  /// **'Wear on {day}'**
  String details_wearOn(String day);

  /// No description provided for @details_numbers.
  ///
  /// In en, this message translates to:
  /// **'Numbers'**
  String get details_numbers;

  /// No description provided for @details_day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get details_day;

  /// No description provided for @details_colors.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get details_colors;

  /// No description provided for @details_metal.
  ///
  /// In en, this message translates to:
  /// **'Metal'**
  String get details_metal;

  /// No description provided for @details_exalted.
  ///
  /// In en, this message translates to:
  /// **'Exalted'**
  String get details_exalted;

  /// No description provided for @details_debilitated.
  ///
  /// In en, this message translates to:
  /// **'Debilitated'**
  String get details_debilitated;

  /// No description provided for @details_retrograde.
  ///
  /// In en, this message translates to:
  /// **'Retrograde'**
  String get details_retrograde;

  /// No description provided for @details_combust.
  ///
  /// In en, this message translates to:
  /// **'Combust'**
  String get details_combust;

  /// No description provided for @details_none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get details_none;

  /// No description provided for @details_whatThisMeans.
  ///
  /// In en, this message translates to:
  /// **'What This Means'**
  String get details_whatThisMeans;

  /// No description provided for @details_significance.
  ///
  /// In en, this message translates to:
  /// **'Significance'**
  String get details_significance;

  /// No description provided for @details_keyPoints.
  ///
  /// In en, this message translates to:
  /// **'Key Points'**
  String get details_keyPoints;

  /// No description provided for @details_moon.
  ///
  /// In en, this message translates to:
  /// **'Moon'**
  String get details_moon;

  /// No description provided for @details_sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get details_sun;

  /// No description provided for @details_vedicDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Based on Vedic planetary positions.'**
  String get details_vedicDisclaimer;

  /// No description provided for @details_westernAstrology.
  ///
  /// In en, this message translates to:
  /// **'Western astrology:'**
  String get details_westernAstrology;

  /// No description provided for @details_dynamic.
  ///
  /// In en, this message translates to:
  /// **'Dynamic'**
  String get details_dynamic;

  /// No description provided for @details_grounded.
  ///
  /// In en, this message translates to:
  /// **'Grounded'**
  String get details_grounded;

  /// No description provided for @details_intellectual.
  ///
  /// In en, this message translates to:
  /// **'Intellectual'**
  String get details_intellectual;

  /// No description provided for @details_intuitive.
  ///
  /// In en, this message translates to:
  /// **'Intuitive'**
  String get details_intuitive;

  /// No description provided for @auth_welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get auth_welcome;

  /// No description provided for @auth_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get auth_email;

  /// No description provided for @auth_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_password;

  /// No description provided for @auth_confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get auth_confirmPassword;

  /// No description provided for @auth_forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get auth_forgotPassword;

  /// No description provided for @auth_continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get auth_continueWithGoogle;

  /// No description provided for @auth_continueWithFacebook.
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get auth_continueWithFacebook;

  /// No description provided for @auth_guestMode.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get auth_guestMode;

  /// No description provided for @auth_loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get auth_loginRequired;

  /// No description provided for @auth_loginToSave.
  ///
  /// In en, this message translates to:
  /// **'Please login to save your Kundali'**
  String get auth_loginToSave;

  /// No description provided for @home_dailyHoroscope.
  ///
  /// In en, this message translates to:
  /// **'Daily Horoscope'**
  String get home_dailyHoroscope;

  /// No description provided for @home_generateKundli.
  ///
  /// In en, this message translates to:
  /// **'Generate Kundli'**
  String get home_generateKundli;

  /// No description provided for @home_panchangToday.
  ///
  /// In en, this message translates to:
  /// **'Panchang Today'**
  String get home_panchangToday;

  /// No description provided for @home_talkToAstrologer.
  ///
  /// In en, this message translates to:
  /// **'Talk to Astrologer'**
  String get home_talkToAstrologer;

  /// No description provided for @home_kundliMatching.
  ///
  /// In en, this message translates to:
  /// **'Kundli Matching'**
  String get home_kundliMatching;

  /// No description provided for @home_savedKundalis.
  ///
  /// In en, this message translates to:
  /// **'Saved Kundalis'**
  String get home_savedKundalis;

  /// No description provided for @home_noKundalis.
  ///
  /// In en, this message translates to:
  /// **'No Kundalis saved yet'**
  String get home_noKundalis;

  /// No description provided for @error_generic.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error_generic;

  /// No description provided for @error_network.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection'**
  String get error_network;

  /// No description provided for @error_locationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Location not found'**
  String get error_locationNotFound;

  /// No description provided for @error_calculationFailed.
  ///
  /// In en, this message translates to:
  /// **'Kundali calculation failed'**
  String get error_calculationFailed;

  /// No description provided for @error_tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please try again'**
  String get error_tryAgain;

  /// No description provided for @houses_nav_overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get houses_nav_overview;

  /// No description provided for @houses_nav_kendra.
  ///
  /// In en, this message translates to:
  /// **'Kendra'**
  String get houses_nav_kendra;

  /// No description provided for @houses_nav_trikona.
  ///
  /// In en, this message translates to:
  /// **'Trikona'**
  String get houses_nav_trikona;

  /// No description provided for @houses_nav_dusthana.
  ///
  /// In en, this message translates to:
  /// **'Dusthana'**
  String get houses_nav_dusthana;

  /// No description provided for @houses_nav_upachaya.
  ///
  /// In en, this message translates to:
  /// **'Upachaya'**
  String get houses_nav_upachaya;

  /// No description provided for @houses_nav_maraka.
  ///
  /// In en, this message translates to:
  /// **'Maraka'**
  String get houses_nav_maraka;

  /// No description provided for @houses_bhavas.
  ///
  /// In en, this message translates to:
  /// **'12 BHAVAS'**
  String get houses_bhavas;

  /// No description provided for @houses_lagna.
  ///
  /// In en, this message translates to:
  /// **'{ascendant} Lagna'**
  String houses_lagna(String ascendant);

  /// No description provided for @houses_startingFrom.
  ///
  /// In en, this message translates to:
  /// **'Houses starting from {ascendant}'**
  String houses_startingFrom(String ascendant);

  /// No description provided for @houses_occupied.
  ///
  /// In en, this message translates to:
  /// **'Occupied'**
  String get houses_occupied;

  /// No description provided for @houses_empty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get houses_empty;

  /// No description provided for @houses_planetsCount.
  ///
  /// In en, this message translates to:
  /// **'Planets'**
  String get houses_planetsCount;

  /// No description provided for @houses_kendra_title.
  ///
  /// In en, this message translates to:
  /// **'Kendra Houses'**
  String get houses_kendra_title;

  /// No description provided for @houses_kendra_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Angular • 1, 4, 7, 10'**
  String get houses_kendra_subtitle;

  /// No description provided for @houses_trikona_title.
  ///
  /// In en, this message translates to:
  /// **'Trikona Houses'**
  String get houses_trikona_title;

  /// No description provided for @houses_trikona_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Trinal • 5, 9'**
  String get houses_trikona_subtitle;

  /// No description provided for @houses_dusthana_title.
  ///
  /// In en, this message translates to:
  /// **'Dusthana Houses'**
  String get houses_dusthana_title;

  /// No description provided for @houses_dusthana_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Malefic • 6, 8, 12'**
  String get houses_dusthana_subtitle;

  /// No description provided for @houses_upachaya_title.
  ///
  /// In en, this message translates to:
  /// **'Upachaya Houses'**
  String get houses_upachaya_title;

  /// No description provided for @houses_upachaya_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Growth • 3, 11'**
  String get houses_upachaya_subtitle;

  /// No description provided for @houses_maraka_title.
  ///
  /// In en, this message translates to:
  /// **'Maraka Houses'**
  String get houses_maraka_title;

  /// No description provided for @houses_maraka_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Death Inflicting • 2, 7'**
  String get houses_maraka_subtitle;

  /// No description provided for @houses_houseNumber.
  ///
  /// In en, this message translates to:
  /// **'House {number}'**
  String houses_houseNumber(int number);

  /// No description provided for @houses_lagnaChip.
  ///
  /// In en, this message translates to:
  /// **'LAGNA'**
  String get houses_lagnaChip;

  /// No description provided for @houses_houseBhava.
  ///
  /// In en, this message translates to:
  /// **'{name} • {sign}'**
  String houses_houseBhava(String name, String sign);

  /// No description provided for @houses_inHouse.
  ///
  /// In en, this message translates to:
  /// **'in H{placement}'**
  String houses_inHouse(int placement);

  /// No description provided for @houses_retrograde_abbr.
  ///
  /// In en, this message translates to:
  /// **'R'**
  String get houses_retrograde_abbr;

  /// No description provided for @houses_insight_whatThisMeans.
  ///
  /// In en, this message translates to:
  /// **'What This Means'**
  String get houses_insight_whatThisMeans;

  /// No description provided for @houses_insight_significance.
  ///
  /// In en, this message translates to:
  /// **'Significance'**
  String get houses_insight_significance;

  /// No description provided for @houses_insight_keyPoints.
  ///
  /// In en, this message translates to:
  /// **'Key Points'**
  String get houses_insight_keyPoints;

  /// No description provided for @houses_houseCategory.
  ///
  /// In en, this message translates to:
  /// **'House Category'**
  String get houses_houseCategory;

  /// No description provided for @houses_kendra_value.
  ///
  /// In en, this message translates to:
  /// **'Kendra Houses'**
  String get houses_kendra_value;

  /// No description provided for @houses_kendra_desc.
  ///
  /// In en, this message translates to:
  /// **'Kendra houses (1, 4, 7, 10) are the angular or quadrant houses. They form the pillars of the horoscope and are considered the most powerful houses for planetary placement.'**
  String get houses_kendra_desc;

  /// No description provided for @houses_kendra_significance.
  ///
  /// In en, this message translates to:
  /// **'Planets in Kendra houses gain strength and their results become prominent in life. Benefics here protect and promote, while malefics can cause significant challenges.'**
  String get houses_kendra_significance;

  /// No description provided for @houses_kendra_point1.
  ///
  /// In en, this message translates to:
  /// **'1st House - Self, personality, physical body'**
  String get houses_kendra_point1;

  /// No description provided for @houses_kendra_point2.
  ///
  /// In en, this message translates to:
  /// **'4th House - Home, mother, emotional peace'**
  String get houses_kendra_point2;

  /// No description provided for @houses_kendra_point3.
  ///
  /// In en, this message translates to:
  /// **'7th House - Marriage, partnerships, others'**
  String get houses_kendra_point3;

  /// No description provided for @houses_kendra_point4.
  ///
  /// In en, this message translates to:
  /// **'10th House - Career, status, public life'**
  String get houses_kendra_point4;

  /// No description provided for @houses_kendra_point5.
  ///
  /// In en, this message translates to:
  /// **'Also called Vishnu Sthanas (seats of Vishnu)'**
  String get houses_kendra_point5;

  /// No description provided for @houses_trikona_value.
  ///
  /// In en, this message translates to:
  /// **'Trikona Houses'**
  String get houses_trikona_value;

  /// No description provided for @houses_trikona_desc.
  ///
  /// In en, this message translates to:
  /// **'Trikona houses (1, 5, 9) are the trinal houses forming a triangle with the Ascendant. They are the most auspicious houses, representing dharma (purpose) and good fortune.'**
  String get houses_trikona_desc;

  /// No description provided for @houses_trikona_significance.
  ///
  /// In en, this message translates to:
  /// **'Lords of Trikona houses become yogakarakas (auspicious) regardless of their natural nature. Planets here bring blessings, wisdom, and spiritual growth.'**
  String get houses_trikona_significance;

  /// No description provided for @houses_trikona_point1.
  ///
  /// In en, this message translates to:
  /// **'1st House - Self and personality (also Kendra)'**
  String get houses_trikona_point1;

  /// No description provided for @houses_trikona_point2.
  ///
  /// In en, this message translates to:
  /// **'5th House - Creativity, children, intelligence'**
  String get houses_trikona_point2;

  /// No description provided for @houses_trikona_point3.
  ///
  /// In en, this message translates to:
  /// **'9th House - Fortune, dharma, higher learning'**
  String get houses_trikona_point3;

  /// No description provided for @houses_trikona_point4.
  ///
  /// In en, this message translates to:
  /// **'Also called Lakshmi Sthanas (seats of Lakshmi)'**
  String get houses_trikona_point4;

  /// No description provided for @houses_trikona_point5.
  ///
  /// In en, this message translates to:
  /// **'Best houses for benefic planets'**
  String get houses_trikona_point5;

  /// No description provided for @houses_dusthana_value.
  ///
  /// In en, this message translates to:
  /// **'Dusthana Houses'**
  String get houses_dusthana_value;

  /// No description provided for @houses_dusthana_desc.
  ///
  /// In en, this message translates to:
  /// **'Dusthana houses (6, 8, 12) are considered malefic or challenging houses. They represent difficulties, obstacles, and areas requiring transformation.'**
  String get houses_dusthana_desc;

  /// No description provided for @houses_dusthana_significance.
  ///
  /// In en, this message translates to:
  /// **'While often feared, these houses are essential for growth. They show where we face challenges that ultimately lead to strength, wisdom, and spiritual evolution.'**
  String get houses_dusthana_significance;

  /// No description provided for @houses_dusthana_point1.
  ///
  /// In en, this message translates to:
  /// **'6th House - Enemies, diseases, debts, service'**
  String get houses_dusthana_point1;

  /// No description provided for @houses_dusthana_point2.
  ///
  /// In en, this message translates to:
  /// **'8th House - Transformation, death, occult, inheritance'**
  String get houses_dusthana_point2;

  /// No description provided for @houses_dusthana_point3.
  ///
  /// In en, this message translates to:
  /// **'12th House - Losses, expenses, liberation, foreign'**
  String get houses_dusthana_point3;

  /// No description provided for @houses_dusthana_point4.
  ///
  /// In en, this message translates to:
  /// **'Malefics do well here (Vipreet Raja Yoga potential)'**
  String get houses_dusthana_point4;

  /// No description provided for @houses_dusthana_point5.
  ///
  /// In en, this message translates to:
  /// **'Lords of these houses can cause difficulties'**
  String get houses_dusthana_point5;

  /// No description provided for @houses_upachaya_value.
  ///
  /// In en, this message translates to:
  /// **'Upachaya Houses'**
  String get houses_upachaya_value;

  /// No description provided for @houses_upachaya_desc.
  ///
  /// In en, this message translates to:
  /// **'Upachaya houses (3, 6, 10, 11) are growth houses where results improve over time. Malefic planets actually do well here, providing drive and competitive edge.'**
  String get houses_upachaya_desc;

  /// No description provided for @houses_upachaya_significance.
  ///
  /// In en, this message translates to:
  /// **'These houses show areas where effort leads to improvement. Unlike other houses, the challenges here decrease with age and experience.'**
  String get houses_upachaya_significance;

  /// No description provided for @houses_upachaya_point1.
  ///
  /// In en, this message translates to:
  /// **'3rd House - Courage, siblings, communication'**
  String get houses_upachaya_point1;

  /// No description provided for @houses_upachaya_point2.
  ///
  /// In en, this message translates to:
  /// **'6th House - Enemies, health issues, competition'**
  String get houses_upachaya_point2;

  /// No description provided for @houses_upachaya_point3.
  ///
  /// In en, this message translates to:
  /// **'10th House - Career, public standing, authority'**
  String get houses_upachaya_point3;

  /// No description provided for @houses_upachaya_point4.
  ///
  /// In en, this message translates to:
  /// **'11th House - Gains, friends, aspirations'**
  String get houses_upachaya_point4;

  /// No description provided for @houses_upachaya_point5.
  ///
  /// In en, this message translates to:
  /// **'Mars, Saturn, Rahu excel in Upachaya houses'**
  String get houses_upachaya_point5;

  /// No description provided for @houses_maraka_value.
  ///
  /// In en, this message translates to:
  /// **'Maraka Houses'**
  String get houses_maraka_value;

  /// No description provided for @houses_maraka_desc.
  ///
  /// In en, this message translates to:
  /// **'Maraka houses (2, 7) are death-inflicting houses in Vedic astrology. Their lords can cause health issues or endings during their planetary periods.'**
  String get houses_maraka_desc;

  /// No description provided for @houses_maraka_significance.
  ///
  /// In en, this message translates to:
  /// **'The 2nd and 7th houses are 12th from the 3rd and 8th houses respectively, making them potential terminators of longevity factors.'**
  String get houses_maraka_significance;

  /// No description provided for @houses_maraka_point1.
  ///
  /// In en, this message translates to:
  /// **'2nd House - Family, wealth, food, death'**
  String get houses_maraka_point1;

  /// No description provided for @houses_maraka_point2.
  ///
  /// In en, this message translates to:
  /// **'7th House - Spouse, partnerships, death'**
  String get houses_maraka_point2;

  /// No description provided for @houses_maraka_point3.
  ///
  /// In en, this message translates to:
  /// **'Maraka planets can cause illness in their periods'**
  String get houses_maraka_point3;

  /// No description provided for @houses_maraka_point4.
  ///
  /// In en, this message translates to:
  /// **'2nd is stronger Maraka than 7th'**
  String get houses_maraka_point4;

  /// No description provided for @houses_maraka_point5.
  ///
  /// In en, this message translates to:
  /// **'Effects modified by overall chart strength'**
  String get houses_maraka_point5;

  /// No description provided for @houses_bhava_lagna.
  ///
  /// In en, this message translates to:
  /// **'Lagna'**
  String get houses_bhava_lagna;

  /// No description provided for @houses_bhava_dhana.
  ///
  /// In en, this message translates to:
  /// **'Dhana'**
  String get houses_bhava_dhana;

  /// No description provided for @houses_bhava_sahaja.
  ///
  /// In en, this message translates to:
  /// **'Sahaja'**
  String get houses_bhava_sahaja;

  /// No description provided for @houses_bhava_sukha.
  ///
  /// In en, this message translates to:
  /// **'Sukha'**
  String get houses_bhava_sukha;

  /// No description provided for @houses_bhava_putra.
  ///
  /// In en, this message translates to:
  /// **'Putra'**
  String get houses_bhava_putra;

  /// No description provided for @houses_bhava_ari.
  ///
  /// In en, this message translates to:
  /// **'Ari'**
  String get houses_bhava_ari;

  /// No description provided for @houses_bhava_yuvati.
  ///
  /// In en, this message translates to:
  /// **'Yuvati'**
  String get houses_bhava_yuvati;

  /// No description provided for @houses_bhava_mrityu.
  ///
  /// In en, this message translates to:
  /// **'Mrityu'**
  String get houses_bhava_mrityu;

  /// No description provided for @houses_bhava_dharma.
  ///
  /// In en, this message translates to:
  /// **'Dharma'**
  String get houses_bhava_dharma;

  /// No description provided for @houses_bhava_karma.
  ///
  /// In en, this message translates to:
  /// **'Karma'**
  String get houses_bhava_karma;

  /// No description provided for @houses_bhava_labha.
  ///
  /// In en, this message translates to:
  /// **'Labha'**
  String get houses_bhava_labha;

  /// No description provided for @houses_bhava_vyaya.
  ///
  /// In en, this message translates to:
  /// **'Vyaya'**
  String get houses_bhava_vyaya;

  /// No description provided for @houses_sign_key.
  ///
  /// In en, this message translates to:
  /// **'Sign: {sign} ({symbol})'**
  String houses_sign_key(String sign, String symbol);

  /// No description provided for @houses_lord_key.
  ///
  /// In en, this message translates to:
  /// **'Lord: {lord}'**
  String houses_lord_key(String lord);

  /// No description provided for @houses_cusp_key.
  ///
  /// In en, this message translates to:
  /// **'Cusp: {degree}°'**
  String houses_cusp_key(String degree);

  /// No description provided for @houses_karaka_key.
  ///
  /// In en, this message translates to:
  /// **'Karaka: {karaka}'**
  String houses_karaka_key(String karaka);

  /// No description provided for @houses_significations_key.
  ///
  /// In en, this message translates to:
  /// **'Significations: {significations}'**
  String houses_significations_key(String significations);

  /// No description provided for @houses_bhava_label.
  ///
  /// In en, this message translates to:
  /// **'{name} Bhava'**
  String houses_bhava_label(String name);

  /// No description provided for @houses_withSign.
  ///
  /// In en, this message translates to:
  /// **'With {sign} as the sign and {lord} as the lord, this house takes on the qualities of {sign} energy in your chart.'**
  String houses_withSign(String sign, String lord);

  /// No description provided for @houses_1_desc.
  ///
  /// In en, this message translates to:
  /// **'The First House, also known as the Ascendant or Lagna, represents your self, physical body, appearance, and how you present yourself to the world. It\'s the most personal house in the chart.'**
  String get houses_1_desc;

  /// No description provided for @houses_2_desc.
  ///
  /// In en, this message translates to:
  /// **'The Second House governs wealth, family values, speech, and early childhood. It shows your relationship with money, possessions, and how you communicate.'**
  String get houses_2_desc;

  /// No description provided for @houses_3_desc.
  ///
  /// In en, this message translates to:
  /// **'The Third House rules communication, short journeys, siblings, and courage. It represents your mental strength, skills, and ability to express yourself.'**
  String get houses_3_desc;

  /// No description provided for @houses_4_desc.
  ///
  /// In en, this message translates to:
  /// **'The Fourth House represents your mother, home, emotional foundation, and inner peace. It shows your roots, domestic happiness, and property matters.'**
  String get houses_4_desc;

  /// No description provided for @houses_5_desc.
  ///
  /// In en, this message translates to:
  /// **'The Fifth House governs creativity, children, romance, and intelligence. It represents your creative expression, speculative gains, and past life merits.'**
  String get houses_5_desc;

  /// No description provided for @houses_6_desc.
  ///
  /// In en, this message translates to:
  /// **'The Sixth House deals with enemies, diseases, debts, and daily work. It shows challenges you must overcome and your capacity for service.'**
  String get houses_6_desc;

  /// No description provided for @houses_7_desc.
  ///
  /// In en, this message translates to:
  /// **'The Seventh House rules marriage, partnerships, and business relationships. It represents your spouse, contracts, and how you relate to others.'**
  String get houses_7_desc;

  /// No description provided for @houses_8_desc.
  ///
  /// In en, this message translates to:
  /// **'The Eighth House governs transformation, longevity, inheritance, and hidden matters. It represents deep changes, occult knowledge, and joint resources.'**
  String get houses_8_desc;

  /// No description provided for @houses_9_desc.
  ///
  /// In en, this message translates to:
  /// **'The Ninth House represents higher learning, spirituality, luck, and long journeys. It shows your father, gurus, and philosophical outlook.'**
  String get houses_9_desc;

  /// No description provided for @houses_10_desc.
  ///
  /// In en, this message translates to:
  /// **'The Tenth House rules career, status, reputation, and achievements. It represents your professional life, authority figures, and public standing.'**
  String get houses_10_desc;

  /// No description provided for @houses_11_desc.
  ///
  /// In en, this message translates to:
  /// **'The Eleventh House governs gains, friendships, aspirations, and elder siblings. It represents your social network, hopes, and recurring income.'**
  String get houses_11_desc;

  /// No description provided for @houses_12_desc.
  ///
  /// In en, this message translates to:
  /// **'The Twelfth House deals with losses, spirituality, foreign lands, and liberation. It represents expenses, isolation, and the journey towards moksha.'**
  String get houses_12_desc;

  /// No description provided for @panchang_nav_moon.
  ///
  /// In en, this message translates to:
  /// **'Moon'**
  String get panchang_nav_moon;

  /// No description provided for @panchang_nav_elements.
  ///
  /// In en, this message translates to:
  /// **'Elements'**
  String get panchang_nav_elements;

  /// No description provided for @panchang_nav_hora.
  ///
  /// In en, this message translates to:
  /// **'Hora'**
  String get panchang_nav_hora;

  /// No description provided for @panchang_nav_periods.
  ///
  /// In en, this message translates to:
  /// **'Periods'**
  String get panchang_nav_periods;

  /// No description provided for @panchang_nav_varshphal.
  ///
  /// In en, this message translates to:
  /// **'Varshphal'**
  String get panchang_nav_varshphal;

  /// No description provided for @panchang_fiveLimbs.
  ///
  /// In en, this message translates to:
  /// **'Five Limbs of Time'**
  String get panchang_fiveLimbs;

  /// No description provided for @panchang_elementsAtBirth.
  ///
  /// In en, this message translates to:
  /// **'Panchang elements at birth'**
  String get panchang_elementsAtBirth;

  /// No description provided for @panchang_horaWeekday.
  ///
  /// In en, this message translates to:
  /// **'Hora & Weekday'**
  String get panchang_horaWeekday;

  /// No description provided for @panchang_horaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Planetary hour and day influences'**
  String get panchang_horaSubtitle;

  /// No description provided for @panchang_inauspiciousPeriods.
  ///
  /// In en, this message translates to:
  /// **'Inauspicious Periods'**
  String get panchang_inauspiciousPeriods;

  /// No description provided for @panchang_onDay.
  ///
  /// In en, this message translates to:
  /// **'On {day}'**
  String panchang_onDay(String day);

  /// No description provided for @panchang_varshphalYear.
  ///
  /// In en, this message translates to:
  /// **'Varshphal {year}'**
  String panchang_varshphalYear(int year);

  /// No description provided for @panchang_solarReturnSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Solar Return / Annual Horoscope'**
  String get panchang_solarReturnSubtitle;

  /// No description provided for @panchang_insight_whatThisMeans.
  ///
  /// In en, this message translates to:
  /// **'What This Means'**
  String get panchang_insight_whatThisMeans;

  /// No description provided for @panchang_insight_significance.
  ///
  /// In en, this message translates to:
  /// **'Significance'**
  String get panchang_insight_significance;

  /// No description provided for @panchang_insight_keyPoints.
  ///
  /// In en, this message translates to:
  /// **'Key Points'**
  String get panchang_insight_keyPoints;

  /// No description provided for @panchang_tithi_title.
  ///
  /// In en, this message translates to:
  /// **'Tithi'**
  String get panchang_tithi_title;

  /// No description provided for @panchang_tithi_desc.
  ///
  /// In en, this message translates to:
  /// **'Tithi is the lunar day in the Hindu calendar, representing the angle between the Sun and Moon. Each Tithi has its own energy and is ruled by a specific planet.'**
  String get panchang_tithi_desc;

  /// No description provided for @panchang_tithi_significance.
  ///
  /// In en, this message translates to:
  /// **'Your birth Tithi is {tithi} ({tithiNumber}/15 in {paksha} Paksha), ruled by {lord}. This influences your emotional nature and the lunar energy you carry.'**
  String panchang_tithi_significance(
    String tithi,
    int tithiNumber,
    String paksha,
    String lord,
  );

  /// No description provided for @panchang_tithi_point1.
  ///
  /// In en, this message translates to:
  /// **'Tithi Number: {number} of 15'**
  String panchang_tithi_point1(int number);

  /// No description provided for @panchang_tithi_point2.
  ///
  /// In en, this message translates to:
  /// **'Paksha: {paksha} ({type} Moon)'**
  String panchang_tithi_point2(String paksha, String type);

  /// No description provided for @panchang_tithi_point3.
  ///
  /// In en, this message translates to:
  /// **'Tithi Lord: {lord}'**
  String panchang_tithi_point3(String lord);

  /// No description provided for @panchang_tithi_point4.
  ///
  /// In en, this message translates to:
  /// **'Each Tithi spans approximately 12 degrees of Moon-Sun elongation'**
  String get panchang_tithi_point4;

  /// No description provided for @panchang_tithi_point5.
  ///
  /// In en, this message translates to:
  /// **'Tithis are used for muhurta (auspicious timing)'**
  String get panchang_tithi_point5;

  /// No description provided for @panchang_waxing.
  ///
  /// In en, this message translates to:
  /// **'Waxing'**
  String get panchang_waxing;

  /// No description provided for @panchang_waning.
  ///
  /// In en, this message translates to:
  /// **'Waning'**
  String get panchang_waning;

  /// No description provided for @panchang_nakshatra_title.
  ///
  /// In en, this message translates to:
  /// **'Nakshatra'**
  String get panchang_nakshatra_title;

  /// No description provided for @panchang_nakshatra_value.
  ///
  /// In en, this message translates to:
  /// **'{nakshatra} (Pada {pada})'**
  String panchang_nakshatra_value(String nakshatra, int pada);

  /// No description provided for @panchang_nakshatra_desc.
  ///
  /// In en, this message translates to:
  /// **'Nakshatra is the lunar mansion or star constellation where the Moon was positioned at birth. There are 27 Nakshatras, each spanning 13°20\' of the zodiac. Each Nakshatra has 4 Padas (quarters) of 3°20\' each.'**
  String get panchang_nakshatra_desc;

  /// No description provided for @panchang_nakshatra_significance.
  ///
  /// In en, this message translates to:
  /// **'The Moon in {nakshatra} Nakshatra, Pada {pada}, shapes your inner emotional nature, instincts, and subconscious patterns. The Nakshatra lord {lord} influences your Vimshottari Dasha sequence.'**
  String panchang_nakshatra_significance(
    String nakshatra,
    int pada,
    String lord,
  );

  /// No description provided for @panchang_nakshatra_point1.
  ///
  /// In en, this message translates to:
  /// **'Nakshatra: {nakshatra}'**
  String panchang_nakshatra_point1(String nakshatra);

  /// No description provided for @panchang_nakshatra_point2.
  ///
  /// In en, this message translates to:
  /// **'Pada (Quarter): {pada} of 4'**
  String panchang_nakshatra_point2(int pada);

  /// No description provided for @panchang_nakshatra_point3.
  ///
  /// In en, this message translates to:
  /// **'Nakshatra Lord: {lord}'**
  String panchang_nakshatra_point3(String lord);

  /// No description provided for @panchang_nakshatra_point4.
  ///
  /// In en, this message translates to:
  /// **'Each Nakshatra has a presiding deity and specific qualities'**
  String get panchang_nakshatra_point4;

  /// No description provided for @panchang_nakshatra_point5.
  ///
  /// In en, this message translates to:
  /// **'Determines the starting Mahadasha in Vimshottari Dasha system'**
  String get panchang_nakshatra_point5;

  /// No description provided for @panchang_yoga_title.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get panchang_yoga_title;

  /// No description provided for @panchang_yoga_value.
  ///
  /// In en, this message translates to:
  /// **'{yoga} ({number}/27)'**
  String panchang_yoga_value(String yoga, int number);

  /// No description provided for @panchang_yoga_desc.
  ///
  /// In en, this message translates to:
  /// **'Yoga in Panchang is calculated from the combined longitude of the Sun and Moon. There are 27 Yogas, each spanning 13°20\'.'**
  String get panchang_yoga_desc;

  /// No description provided for @panchang_yoga_significance.
  ///
  /// In en, this message translates to:
  /// **'Your birth Yoga is {yoga}, which is considered {type}. This cosmic combination of Sun and Moon energies influences your life path and the general fortune you carry.'**
  String panchang_yoga_significance(String yoga, String type);

  /// No description provided for @panchang_yoga_point1.
  ///
  /// In en, this message translates to:
  /// **'Yoga: {yoga}'**
  String panchang_yoga_point1(String yoga);

  /// No description provided for @panchang_yoga_point2.
  ///
  /// In en, this message translates to:
  /// **'Number: {number} of 27'**
  String panchang_yoga_point2(int number);

  /// No description provided for @panchang_yoga_point3.
  ///
  /// In en, this message translates to:
  /// **'Type: {type}'**
  String panchang_yoga_point3(String type);

  /// No description provided for @panchang_yoga_point4.
  ///
  /// In en, this message translates to:
  /// **'Formula: (Sun longitude + Moon longitude) ÷ 13°20\''**
  String get panchang_yoga_point4;

  /// No description provided for @panchang_yoga_point5.
  ///
  /// In en, this message translates to:
  /// **'Affects overall auspiciousness of the birth moment'**
  String get panchang_yoga_point5;

  /// No description provided for @panchang_yoga_auspicious.
  ///
  /// In en, this message translates to:
  /// **'Auspicious'**
  String get panchang_yoga_auspicious;

  /// No description provided for @panchang_yoga_inauspicious.
  ///
  /// In en, this message translates to:
  /// **'Inauspicious'**
  String get panchang_yoga_inauspicious;

  /// No description provided for @panchang_yoga_neutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get panchang_yoga_neutral;

  /// No description provided for @panchang_karana_title.
  ///
  /// In en, this message translates to:
  /// **'Karana'**
  String get panchang_karana_title;

  /// No description provided for @panchang_karana_desc.
  ///
  /// In en, this message translates to:
  /// **'Karana is half of a Tithi, with 11 Karanas repeating to make 60 half-Tithis in a lunar month. 7 are movable (Chara) and 4 are fixed (Sthira).'**
  String get panchang_karana_desc;

  /// No description provided for @panchang_karana_significance.
  ///
  /// In en, this message translates to:
  /// **'Born in {karana} Karana, which is {type}. Karanas influence specific activities and the energy of the half-day period.'**
  String panchang_karana_significance(String karana, String type);

  /// No description provided for @panchang_karana_point1.
  ///
  /// In en, this message translates to:
  /// **'Karana: {karana}'**
  String panchang_karana_point1(String karana);

  /// No description provided for @panchang_karana_point2.
  ///
  /// In en, this message translates to:
  /// **'Type: {type}'**
  String panchang_karana_point2(String type);

  /// No description provided for @panchang_karana_point3.
  ///
  /// In en, this message translates to:
  /// **'7 Movable (Chara): Bava to Vishti, repeat 8 times'**
  String get panchang_karana_point3;

  /// No description provided for @panchang_karana_point4.
  ///
  /// In en, this message translates to:
  /// **'4 Fixed (Sthira): Shakuni, Chatushpada, Naga, Kimstughna'**
  String get panchang_karana_point4;

  /// No description provided for @panchang_karana_point5.
  ///
  /// In en, this message translates to:
  /// **'Vishti (Bhadra) is considered inauspicious'**
  String get panchang_karana_point5;

  /// No description provided for @panchang_karana_chara.
  ///
  /// In en, this message translates to:
  /// **'Chara (Movable)'**
  String get panchang_karana_chara;

  /// No description provided for @panchang_karana_sthira.
  ///
  /// In en, this message translates to:
  /// **'Sthira (Fixed)'**
  String get panchang_karana_sthira;

  /// No description provided for @panchang_karana_bhadra.
  ///
  /// In en, this message translates to:
  /// **'Bhadra (Avoid)'**
  String get panchang_karana_bhadra;

  /// No description provided for @panchang_vara_title.
  ///
  /// In en, this message translates to:
  /// **'Vara (Weekday)'**
  String get panchang_vara_title;

  /// No description provided for @panchang_vara_desc.
  ///
  /// In en, this message translates to:
  /// **'Vara is the weekday, one of the five limbs of Panchang. Each day is ruled by a planet, influencing the energy and suitable activities for that day.'**
  String get panchang_vara_desc;

  /// No description provided for @panchang_vara_significance.
  ///
  /// In en, this message translates to:
  /// **'Born on {vara}, ruled by {lord}. This planetary influence colors your personality and the types of activities that come naturally to you.'**
  String panchang_vara_significance(String vara, String lord);

  /// No description provided for @panchang_vara_point1.
  ///
  /// In en, this message translates to:
  /// **'Vara: {vara}'**
  String panchang_vara_point1(String vara);

  /// No description provided for @panchang_vara_point2.
  ///
  /// In en, this message translates to:
  /// **'Vara Lord: {lord}'**
  String panchang_vara_point2(String lord);

  /// No description provided for @panchang_vara_point3.
  ///
  /// In en, this message translates to:
  /// **'Presiding Deity: {deity}'**
  String panchang_vara_point3(String deity);

  /// No description provided for @panchang_vara_point4.
  ///
  /// In en, this message translates to:
  /// **'Each Vara has specific auspicious and inauspicious hours'**
  String get panchang_vara_point4;

  /// No description provided for @panchang_vara_point5.
  ///
  /// In en, this message translates to:
  /// **'Vara lord placement in chart strengthens its effects'**
  String get panchang_vara_point5;

  /// No description provided for @panchang_moonPhase_title.
  ///
  /// In en, this message translates to:
  /// **'Moon Phase'**
  String get panchang_moonPhase_title;

  /// No description provided for @panchang_moonPhase_desc.
  ///
  /// In en, this message translates to:
  /// **'The Moon phase at birth indicates the relationship between the Sun and Moon, reflecting the interplay of consciousness (Sun) and mind (Moon).'**
  String get panchang_moonPhase_desc;

  /// No description provided for @panchang_moonPhase_significance.
  ///
  /// In en, this message translates to:
  /// **'Born during {paksha} Paksha with {illumination}% illumination. This indicates a {nature}.'**
  String panchang_moonPhase_significance(
    String paksha,
    String illumination,
    String nature,
  );

  /// No description provided for @panchang_moonPhase_nature_shukla.
  ///
  /// In en, this message translates to:
  /// **'more outgoing, action-oriented nature with growing vitality'**
  String get panchang_moonPhase_nature_shukla;

  /// No description provided for @panchang_moonPhase_nature_krishna.
  ///
  /// In en, this message translates to:
  /// **'more introspective, wisdom-seeking nature with releasing tendencies'**
  String get panchang_moonPhase_nature_krishna;

  /// No description provided for @panchang_moonPhase_point1.
  ///
  /// In en, this message translates to:
  /// **'Phase: {phase}'**
  String panchang_moonPhase_point1(String phase);

  /// No description provided for @panchang_moonPhase_point2.
  ///
  /// In en, this message translates to:
  /// **'Paksha: {paksha} ({type})'**
  String panchang_moonPhase_point2(String paksha, String type);

  /// No description provided for @panchang_moonPhase_point3.
  ///
  /// In en, this message translates to:
  /// **'Illumination: {illumination}%'**
  String panchang_moonPhase_point3(String illumination);

  /// No description provided for @panchang_moonPhase_point4.
  ///
  /// In en, this message translates to:
  /// **'Tithi: {tithi} ({number}/15)'**
  String panchang_moonPhase_point4(String tithi, int number);

  /// No description provided for @panchang_moonPhase_point5.
  ///
  /// In en, this message translates to:
  /// **'Moon phase affects emotional patterns and life cycles'**
  String get panchang_moonPhase_point5;

  /// No description provided for @panchang_phase_waxingCrescent.
  ///
  /// In en, this message translates to:
  /// **'Waxing Crescent'**
  String get panchang_phase_waxingCrescent;

  /// No description provided for @panchang_phase_firstQuarter.
  ///
  /// In en, this message translates to:
  /// **'First Quarter'**
  String get panchang_phase_firstQuarter;

  /// No description provided for @panchang_phase_waxingGibbous.
  ///
  /// In en, this message translates to:
  /// **'Waxing Gibbous'**
  String get panchang_phase_waxingGibbous;

  /// No description provided for @panchang_phase_nearlyFull.
  ///
  /// In en, this message translates to:
  /// **'Nearly Full'**
  String get panchang_phase_nearlyFull;

  /// No description provided for @panchang_phase_fullMoon.
  ///
  /// In en, this message translates to:
  /// **'Full Moon (Purnima)'**
  String get panchang_phase_fullMoon;

  /// No description provided for @panchang_phase_waningGibbous.
  ///
  /// In en, this message translates to:
  /// **'Waning Gibbous'**
  String get panchang_phase_waningGibbous;

  /// No description provided for @panchang_phase_thirdQuarter.
  ///
  /// In en, this message translates to:
  /// **'Third Quarter'**
  String get panchang_phase_thirdQuarter;

  /// No description provided for @panchang_phase_waningCrescent.
  ///
  /// In en, this message translates to:
  /// **'Waning Crescent'**
  String get panchang_phase_waningCrescent;

  /// No description provided for @panchang_phase_nearlyNew.
  ///
  /// In en, this message translates to:
  /// **'Nearly New'**
  String get panchang_phase_nearlyNew;

  /// No description provided for @panchang_phase_newMoon.
  ///
  /// In en, this message translates to:
  /// **'New Moon (Amavasya)'**
  String get panchang_phase_newMoon;

  /// No description provided for @panchang_hora_title.
  ///
  /// In en, this message translates to:
  /// **'Hora'**
  String get panchang_hora_title;

  /// No description provided for @panchang_hora_value.
  ///
  /// In en, this message translates to:
  /// **'{planet} Hora'**
  String panchang_hora_value(String planet);

  /// No description provided for @panchang_hora_desc.
  ///
  /// In en, this message translates to:
  /// **'Hora divides each day into 24 planetary hours, with each hour ruled by a planet in a specific sequence. The Hora at birth indicates the planetary influence active at that moment.'**
  String get panchang_hora_desc;

  /// No description provided for @panchang_hora_significance.
  ///
  /// In en, this message translates to:
  /// **'Born during {planet} Hora, you carry the energy of {planet} in your personality and approach to life. Activities related to {planet} come naturally to you.'**
  String panchang_hora_significance(String planet);

  /// No description provided for @panchang_hora_point1.
  ///
  /// In en, this message translates to:
  /// **'Birth Hora: {planet}'**
  String panchang_hora_point1(String planet);

  /// No description provided for @panchang_hora_point2.
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String panchang_hora_point2(String time);

  /// No description provided for @panchang_hora_point3.
  ///
  /// In en, this message translates to:
  /// **'Hora sequence follows: Sun→Venus→Mercury→Moon→Saturn→Jupiter→Mars'**
  String get panchang_hora_point3;

  /// No description provided for @panchang_hora_point4.
  ///
  /// In en, this message translates to:
  /// **'Each hora lasts approximately 1 hour'**
  String get panchang_hora_point4;

  /// No description provided for @panchang_hora_point5.
  ///
  /// In en, this message translates to:
  /// **'Hora influences the energy available for activities'**
  String get panchang_hora_point5;

  /// No description provided for @panchang_hora_desc_sun.
  ///
  /// In en, this message translates to:
  /// **'Authority, government work, leadership'**
  String get panchang_hora_desc_sun;

  /// No description provided for @panchang_hora_desc_moon.
  ///
  /// In en, this message translates to:
  /// **'Travel, emotions, public dealing'**
  String get panchang_hora_desc_moon;

  /// No description provided for @panchang_hora_desc_mars.
  ///
  /// In en, this message translates to:
  /// **'Courage, competition, action'**
  String get panchang_hora_desc_mars;

  /// No description provided for @panchang_hora_desc_mercury.
  ///
  /// In en, this message translates to:
  /// **'Communication, learning, business'**
  String get panchang_hora_desc_mercury;

  /// No description provided for @panchang_hora_desc_jupiter.
  ///
  /// In en, this message translates to:
  /// **'Education, spirituality, expansion'**
  String get panchang_hora_desc_jupiter;

  /// No description provided for @panchang_hora_desc_venus.
  ///
  /// In en, this message translates to:
  /// **'Arts, relationships, pleasures'**
  String get panchang_hora_desc_venus;

  /// No description provided for @panchang_hora_desc_saturn.
  ///
  /// In en, this message translates to:
  /// **'Hard work, discipline, patience'**
  String get panchang_hora_desc_saturn;

  /// No description provided for @panchang_birthHora.
  ///
  /// In en, this message translates to:
  /// **'Birth Hora'**
  String get panchang_birthHora;

  /// No description provided for @panchang_inauspicious_title.
  ///
  /// In en, this message translates to:
  /// **'Inauspicious Period'**
  String get panchang_inauspicious_title;

  /// No description provided for @panchang_inauspicious_rahuKala_desc.
  ///
  /// In en, this message translates to:
  /// **'Rahu Kala is the most inauspicious period of the day, ruled by the shadow planet Rahu. Starting new ventures, important meetings, or auspicious activities should be avoided during this time.'**
  String get panchang_inauspicious_rahuKala_desc;

  /// No description provided for @panchang_inauspicious_yamaghanda_desc.
  ///
  /// In en, this message translates to:
  /// **'Yamaghanda, also called Yama Ghantaka, is ruled by Yama, the god of death. This period is considered inauspicious for starting journeys, especially in the direction governed by Yama that day.'**
  String get panchang_inauspicious_yamaghanda_desc;

  /// No description provided for @panchang_inauspicious_gulika_desc.
  ///
  /// In en, this message translates to:
  /// **'Gulika Kala, ruled by Saturn\'s son Gulika (Mandi), is associated with poison and hidden dangers. While generally avoided for new beginnings, it\'s considered good for activities requiring secrecy.'**
  String get panchang_inauspicious_gulika_desc;

  /// No description provided for @panchang_inauspicious_significance.
  ///
  /// In en, this message translates to:
  /// **'Birth during {period} ({time}) suggests specific karmic lessons related to this period\'s ruler. Understanding this helps in timing important life decisions.'**
  String panchang_inauspicious_significance(String period, String time);

  /// No description provided for @panchang_inauspicious_point1.
  ///
  /// In en, this message translates to:
  /// **'Period: {period}'**
  String panchang_inauspicious_point1(String period);

  /// No description provided for @panchang_inauspicious_point2.
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String panchang_inauspicious_point2(String time);

  /// No description provided for @panchang_inauspicious_point3.
  ///
  /// In en, this message translates to:
  /// **'Duration: Approximately 1.5 hours'**
  String get panchang_inauspicious_point3;

  /// No description provided for @panchang_inauspicious_point4_rahu.
  ///
  /// In en, this message translates to:
  /// **'Most important inauspicious period'**
  String get panchang_inauspicious_point4_rahu;

  /// No description provided for @panchang_inauspicious_point4_yama.
  ///
  /// In en, this message translates to:
  /// **'Avoid travels and risky activities'**
  String get panchang_inauspicious_point4_yama;

  /// No description provided for @panchang_inauspicious_point4_gulika.
  ///
  /// In en, this message translates to:
  /// **'Related to hidden matters and secrecy'**
  String get panchang_inauspicious_point4_gulika;

  /// No description provided for @panchang_inauspicious_point5.
  ///
  /// In en, this message translates to:
  /// **'Each weekday has different timings for these periods'**
  String get panchang_inauspicious_point5;

  /// No description provided for @panchang_birthDuring.
  ///
  /// In en, this message translates to:
  /// **'Birth during {period}'**
  String panchang_birthDuring(String period);

  /// No description provided for @panchang_dayTimeline.
  ///
  /// In en, this message translates to:
  /// **'Day Timeline (6 AM - 6 PM)'**
  String get panchang_dayTimeline;

  /// No description provided for @panchang_birth.
  ///
  /// In en, this message translates to:
  /// **'Birth'**
  String get panchang_birth;

  /// No description provided for @panchang_varshphal_title.
  ///
  /// In en, this message translates to:
  /// **'Varshphal'**
  String get panchang_varshphal_title;

  /// No description provided for @panchang_varshphal_value.
  ///
  /// In en, this message translates to:
  /// **'Solar Return {year}'**
  String panchang_varshphal_value(int year);

  /// No description provided for @panchang_varshphal_desc.
  ///
  /// In en, this message translates to:
  /// **'Varshphal (Annual Horoscope) is the chart cast for the exact moment when the Sun returns to its birth position each year. It provides insights into the themes, opportunities, and challenges for that specific year of life.'**
  String get panchang_varshphal_desc;

  /// No description provided for @panchang_varshphal_significance.
  ///
  /// In en, this message translates to:
  /// **'At age {age}, your Muntha (progressed Ascendant) is in {munthaSign}, and the Year Lord is {yearLord}. These factors shape the major themes of this year.'**
  String panchang_varshphal_significance(
    int age,
    String munthaSign,
    String yearLord,
  );

  /// No description provided for @panchang_varshphal_point1.
  ///
  /// In en, this message translates to:
  /// **'Year: {year}'**
  String panchang_varshphal_point1(int year);

  /// No description provided for @panchang_varshphal_point2.
  ///
  /// In en, this message translates to:
  /// **'Age: {age} years'**
  String panchang_varshphal_point2(int age);

  /// No description provided for @panchang_varshphal_point3.
  ///
  /// In en, this message translates to:
  /// **'Solar Return: {date}'**
  String panchang_varshphal_point3(String date);

  /// No description provided for @panchang_varshphal_point4.
  ///
  /// In en, this message translates to:
  /// **'Muntha Sign: {sign}'**
  String panchang_varshphal_point4(String sign);

  /// No description provided for @panchang_varshphal_point5.
  ///
  /// In en, this message translates to:
  /// **'Year Lord: {lord}'**
  String panchang_varshphal_point5(String lord);

  /// No description provided for @panchang_years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get panchang_years;

  /// No description provided for @panchang_muntha.
  ///
  /// In en, this message translates to:
  /// **'Muntha'**
  String get panchang_muntha;

  /// No description provided for @panchang_yearLord.
  ///
  /// In en, this message translates to:
  /// **'Year Lord'**
  String get panchang_yearLord;

  /// No description provided for @panchang_moonSign.
  ///
  /// In en, this message translates to:
  /// **'Moon Sign'**
  String get panchang_moonSign;

  /// No description provided for @panchang_degree.
  ///
  /// In en, this message translates to:
  /// **'Degree'**
  String get panchang_degree;

  /// No description provided for @panchang_elongation.
  ///
  /// In en, this message translates to:
  /// **'Elongation'**
  String get panchang_elongation;

  /// No description provided for @panchang_percentLit.
  ///
  /// In en, this message translates to:
  /// **'{percent}% lit'**
  String panchang_percentLit(String percent);

  /// No description provided for @panchang_paksha.
  ///
  /// In en, this message translates to:
  /// **'{paksha} PAKSHA'**
  String panchang_paksha(String paksha);

  /// No description provided for @panchang_lord.
  ///
  /// In en, this message translates to:
  /// **'Lord'**
  String get panchang_lord;

  /// No description provided for @panchang_pada.
  ///
  /// In en, this message translates to:
  /// **'Pada {pada}'**
  String panchang_pada(int pada);

  /// No description provided for @panchang_varaWeekday.
  ///
  /// In en, this message translates to:
  /// **'Vara (Weekday)'**
  String get panchang_varaWeekday;

  /// No description provided for @planets_nav_overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get planets_nav_overview;

  /// No description provided for @planets_overviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Planetary positions summary'**
  String get planets_overviewSubtitle;

  /// No description provided for @planets_grahaSthiti.
  ///
  /// In en, this message translates to:
  /// **'Graha Sthiti'**
  String get planets_grahaSthiti;

  /// No description provided for @planets_grahaSthitiDesc.
  ///
  /// In en, this message translates to:
  /// **'Planetary positions via Swiss Ephemeris'**
  String get planets_grahaSthitiDesc;

  /// No description provided for @planets_grahaSthitiInsight.
  ///
  /// In en, this message translates to:
  /// **'Graha Sthiti shows the positions of all nine planets (Navagrahas) in your birth chart. These positions are calculated using the Swiss Ephemeris for astronomical precision and then mapped to the Vedic sidereal zodiac.'**
  String get planets_grahaSthitiInsight;

  /// No description provided for @planets_grahaSthitiSignificance.
  ///
  /// In en, this message translates to:
  /// **'Your chart has {total} planets positioned across different signs and houses. {exalted} planet(s) are exalted (strongest), {debilitated} are debilitated, {retrograde} are retrograde, and {combust} are combust.'**
  String planets_grahaSthitiSignificance(
    int total,
    int exalted,
    int debilitated,
    int retrograde,
    int combust,
  );

  /// No description provided for @planets_totalPlanets.
  ///
  /// In en, this message translates to:
  /// **'Total Planets: {count}'**
  String planets_totalPlanets(int count);

  /// No description provided for @planets_exaltedCount.
  ///
  /// In en, this message translates to:
  /// **'Exalted: {count} (Maximum strength)'**
  String planets_exaltedCount(int count);

  /// No description provided for @planets_debilitatedCount.
  ///
  /// In en, this message translates to:
  /// **'Debilitated: {count} (Need remedies)'**
  String planets_debilitatedCount(int count);

  /// No description provided for @planets_retrogradeCount.
  ///
  /// In en, this message translates to:
  /// **'Retrograde: {count} (Internal effects)'**
  String planets_retrogradeCount(int count);

  /// No description provided for @planets_combustCount.
  ///
  /// In en, this message translates to:
  /// **'Combust: {count} (Hidden energy)'**
  String planets_combustCount(int count);

  /// No description provided for @planets_calculations.
  ///
  /// In en, this message translates to:
  /// **'Calculations: Swiss Ephemeris + Lahiri Ayanamsa'**
  String get planets_calculations;

  /// No description provided for @planets_stat_exalt.
  ///
  /// In en, this message translates to:
  /// **'Exalt'**
  String get planets_stat_exalt;

  /// No description provided for @planets_stat_debil.
  ///
  /// In en, this message translates to:
  /// **'Debil'**
  String get planets_stat_debil;

  /// No description provided for @planets_stat_retro.
  ///
  /// In en, this message translates to:
  /// **'Retro'**
  String get planets_stat_retro;

  /// No description provided for @planets_stat_comb.
  ///
  /// In en, this message translates to:
  /// **'Comb'**
  String get planets_stat_comb;

  /// No description provided for @planets_stat_exaltDesc.
  ///
  /// In en, this message translates to:
  /// **'Exalted planets are in their strongest position, giving maximum positive results.'**
  String get planets_stat_exaltDesc;

  /// No description provided for @planets_stat_debilDesc.
  ///
  /// In en, this message translates to:
  /// **'Debilitated planets are in their weakest position, requiring remedies for better results.'**
  String get planets_stat_debilDesc;

  /// No description provided for @planets_stat_retroDesc.
  ///
  /// In en, this message translates to:
  /// **'Retrograde planets move backwards (apparent motion), intensifying internal effects.'**
  String get planets_stat_retroDesc;

  /// No description provided for @planets_stat_combDesc.
  ///
  /// In en, this message translates to:
  /// **'Combust planets are too close to Sun, their energy gets hidden or weakened.'**
  String get planets_stat_combDesc;

  /// No description provided for @planets_statCount.
  ///
  /// In en, this message translates to:
  /// **'{count} {label}'**
  String planets_statCount(int count, String label);

  /// No description provided for @planets_statInsight.
  ///
  /// In en, this message translates to:
  /// **'You have {count} planet(s) with this status in your birth chart.'**
  String planets_statInsight(int count);

  /// No description provided for @planets_dignities.
  ///
  /// In en, this message translates to:
  /// **'Planetary Dignities'**
  String get planets_dignities;

  /// No description provided for @planets_tapForDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap planets for details'**
  String get planets_tapForDetails;

  /// No description provided for @planets_dignityAffects.
  ///
  /// In en, this message translates to:
  /// **'Planetary dignity determines how strongly a planet can express its energy in your chart.'**
  String get planets_dignityAffects;

  /// No description provided for @planets_dignity_exaltDesc.
  ///
  /// In en, this message translates to:
  /// **'Maximum strength - the planet gives its best results'**
  String get planets_dignity_exaltDesc;

  /// No description provided for @planets_dignity_moolaDesc.
  ///
  /// In en, this message translates to:
  /// **'Second strongest position after exaltation'**
  String get planets_dignity_moolaDesc;

  /// No description provided for @planets_dignity_ownDesc.
  ///
  /// In en, this message translates to:
  /// **'Planet in its own sign - comfortable and stable'**
  String get planets_dignity_ownDesc;

  /// No description provided for @planets_dignity_friendlyDesc.
  ///
  /// In en, this message translates to:
  /// **'Planet in a friendly sign - supportive environment'**
  String get planets_dignity_friendlyDesc;

  /// No description provided for @planets_dignity_neutralDesc.
  ///
  /// In en, this message translates to:
  /// **'Neither strong nor weak - balanced results'**
  String get planets_dignity_neutralDesc;

  /// No description provided for @planets_dignity_enemyDesc.
  ///
  /// In en, this message translates to:
  /// **'Planet in an enemy sign - extra effort needed'**
  String get planets_dignity_enemyDesc;

  /// No description provided for @planets_dignity_debilDesc.
  ///
  /// In en, this message translates to:
  /// **'Weakest position - may need remedial measures'**
  String get planets_dignity_debilDesc;

  /// No description provided for @planets_moolatrikona.
  ///
  /// In en, this message translates to:
  /// **'Moolatrikona'**
  String get planets_moolatrikona;

  /// No description provided for @planets_moola.
  ///
  /// In en, this message translates to:
  /// **'Moola'**
  String get planets_moola;

  /// No description provided for @planets_own.
  ///
  /// In en, this message translates to:
  /// **'Own'**
  String get planets_own;

  /// No description provided for @planets_friend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get planets_friend;

  /// No description provided for @planets_combustWarning.
  ///
  /// In en, this message translates to:
  /// **'Combust · Reduced planetary strength due to Sun proximity'**
  String get planets_combustWarning;

  /// No description provided for @planets_insight_planet.
  ///
  /// In en, this message translates to:
  /// **'Planet'**
  String get planets_insight_planet;

  /// No description provided for @planets_insight_signLabel.
  ///
  /// In en, this message translates to:
  /// **'Sign: {sign} ({symbol})'**
  String planets_insight_signLabel(String sign, String symbol);

  /// No description provided for @planets_insight_houseLabel.
  ///
  /// In en, this message translates to:
  /// **'House: {house}'**
  String planets_insight_houseLabel(String house);

  /// No description provided for @planets_insight_degreeLabel.
  ///
  /// In en, this message translates to:
  /// **'Degree: {degree}°'**
  String planets_insight_degreeLabel(String degree);

  /// No description provided for @planets_insight_nakshatraLabel.
  ///
  /// In en, this message translates to:
  /// **'Nakshatra: {nakshatra} (Pada {pada})'**
  String planets_insight_nakshatraLabel(String nakshatra, int pada);

  /// No description provided for @planets_insight_nakshatraLordLabel.
  ///
  /// In en, this message translates to:
  /// **'Nakshatra Lord: {lord}'**
  String planets_insight_nakshatraLordLabel(String lord);

  /// No description provided for @planets_insight_dignityLabel.
  ///
  /// In en, this message translates to:
  /// **'Dignity: {dignity}'**
  String planets_insight_dignityLabel(String dignity);

  /// No description provided for @planets_insight_statusRetrograde.
  ///
  /// In en, this message translates to:
  /// **'Status: Retrograde'**
  String get planets_insight_statusRetrograde;

  /// No description provided for @planets_insight_statusCombust.
  ///
  /// In en, this message translates to:
  /// **'Status: Combust'**
  String get planets_insight_statusCombust;

  /// No description provided for @planets_insight_natureLabel.
  ///
  /// In en, this message translates to:
  /// **'Nature: {nature}'**
  String planets_insight_natureLabel(String nature);

  /// No description provided for @planets_insight_benefic.
  ///
  /// In en, this message translates to:
  /// **'Benefic'**
  String get planets_insight_benefic;

  /// No description provided for @planets_insight_malefic.
  ///
  /// In en, this message translates to:
  /// **'Malefic'**
  String get planets_insight_malefic;

  /// No description provided for @planets_insight_planetaryDignity.
  ///
  /// In en, this message translates to:
  /// **'Planetary Dignity'**
  String get planets_insight_planetaryDignity;

  /// No description provided for @planets_dignity_exaltedFull.
  ///
  /// In en, this message translates to:
  /// **'The planet is exalted, meaning it\'s in its strongest possible position. Exalted planets give their best results and indicate areas of natural talent and blessing in your life.'**
  String get planets_dignity_exaltedFull;

  /// No description provided for @planets_dignity_debilitatedFull.
  ///
  /// In en, this message translates to:
  /// **'The planet is debilitated, in its weakest position. While this can indicate challenges, it also shows areas for growth and spiritual development. The effects can be cancelled through various yogas.'**
  String get planets_dignity_debilitatedFull;

  /// No description provided for @planets_dignity_ownSignFull.
  ///
  /// In en, this message translates to:
  /// **'The planet is in its own sign, feeling comfortable and at home. This gives stability and consistency in the areas the planet governs.'**
  String get planets_dignity_ownSignFull;

  /// No description provided for @planets_dignity_moolatrikonaFull.
  ///
  /// In en, this message translates to:
  /// **'The planet is in its Moolatrikona sign, its second-best position after exaltation. This is considered a very powerful placement.'**
  String get planets_dignity_moolatrikonaFull;

  /// No description provided for @planets_dignity_friendlyFull.
  ///
  /// In en, this message translates to:
  /// **'The planet is in a friendly sign, where it receives support from the sign lord. This generally gives favorable results.'**
  String get planets_dignity_friendlyFull;

  /// No description provided for @planets_dignity_enemyFull.
  ///
  /// In en, this message translates to:
  /// **'The planet is in an enemy sign, creating some friction with the sign lord. This may require extra effort in related life areas.'**
  String get planets_dignity_enemyFull;

  /// No description provided for @planets_dignity_neutralFull.
  ///
  /// In en, this message translates to:
  /// **'The planet is in a neutral sign, giving balanced results based on other chart factors.'**
  String get planets_dignity_neutralFull;

  /// No description provided for @planets_dignitySignificance.
  ///
  /// In en, this message translates to:
  /// **'{planet} in {sign} is {dignity}. This affects the strength and quality of the planet\'s results in your life.'**
  String planets_dignitySignificance(
    String planet,
    String sign,
    String dignity,
  );

  /// No description provided for @planets_strength_max.
  ///
  /// In en, this message translates to:
  /// **'Strength: Maximum (100%)'**
  String get planets_strength_max;

  /// No description provided for @planets_strength_veryHigh.
  ///
  /// In en, this message translates to:
  /// **'Strength: Very High (85%)'**
  String get planets_strength_veryHigh;

  /// No description provided for @planets_strength_high.
  ///
  /// In en, this message translates to:
  /// **'Strength: High (75%)'**
  String get planets_strength_high;

  /// No description provided for @planets_strength_good.
  ///
  /// In en, this message translates to:
  /// **'Strength: Good (60%)'**
  String get planets_strength_good;

  /// No description provided for @planets_strength_moderate.
  ///
  /// In en, this message translates to:
  /// **'Strength: Moderate (50%)'**
  String get planets_strength_moderate;

  /// No description provided for @planets_strength_reduced.
  ///
  /// In en, this message translates to:
  /// **'Strength: Reduced (35%)'**
  String get planets_strength_reduced;

  /// No description provided for @planets_strength_low.
  ///
  /// In en, this message translates to:
  /// **'Strength: Low (25%)'**
  String get planets_strength_low;

  /// No description provided for @planets_nakshatra_title.
  ///
  /// In en, this message translates to:
  /// **'Nakshatra'**
  String get planets_nakshatra_title;

  /// No description provided for @planets_nakshatra_value.
  ///
  /// In en, this message translates to:
  /// **'{nakshatra} (Pada {pada})'**
  String planets_nakshatra_value(String nakshatra, int pada);

  /// No description provided for @planets_nakshatra_desc.
  ///
  /// In en, this message translates to:
  /// **'{nakshatra} is one of the 27 lunar mansions in Vedic astrology. Its symbol is {symbol} and it embodies the quality of being {nature}. The presiding deity is {deity}.'**
  String planets_nakshatra_desc(
    String nakshatra,
    String symbol,
    String nature,
    String deity,
  );

  /// No description provided for @planets_nakshatra_significance.
  ///
  /// In en, this message translates to:
  /// **'This Nakshatra is ruled by {lord}, which influences the Vimshottari Dasha sequence. Pada {pada} of {nakshatra} falls in the {sign} navamsa.'**
  String planets_nakshatra_significance(
    String lord,
    int pada,
    String nakshatra,
    String sign,
  );

  /// No description provided for @planets_nakshatra_padaLabel.
  ///
  /// In en, this message translates to:
  /// **'Pada: {pada} of 4'**
  String planets_nakshatra_padaLabel(int pada);

  /// No description provided for @planets_nakshatra_lordLabel.
  ///
  /// In en, this message translates to:
  /// **'Lord: {lord}'**
  String planets_nakshatra_lordLabel(String lord);

  /// No description provided for @planets_nakshatra_deityLabel.
  ///
  /// In en, this message translates to:
  /// **'Deity: {deity}'**
  String planets_nakshatra_deityLabel(String deity);

  /// No description provided for @planets_nakshatra_symbolLabel.
  ///
  /// In en, this message translates to:
  /// **'Symbol: {symbol}'**
  String planets_nakshatra_symbolLabel(String symbol);

  /// No description provided for @planets_nakshatra_natureLabel.
  ///
  /// In en, this message translates to:
  /// **'Nature: {nature}'**
  String planets_nakshatra_natureLabel(String nature);

  /// No description provided for @planets_sun_desc.
  ///
  /// In en, this message translates to:
  /// **'The Sun represents your soul, ego, vitality, and life force. It shows your core identity, self-expression, and relationship with authority. A strong Sun gives confidence, leadership qualities, and recognition.'**
  String get planets_sun_desc;

  /// No description provided for @planets_moon_desc.
  ///
  /// In en, this message translates to:
  /// **'The Moon represents your mind, emotions, and subconscious patterns. It shows your emotional nature, mental peace, and connection with the mother. A strong Moon gives emotional stability and intuition.'**
  String get planets_moon_desc;

  /// No description provided for @planets_mars_desc.
  ///
  /// In en, this message translates to:
  /// **'Mars represents courage, energy, aggression, and action. It shows your drive, competitive spirit, and how you assert yourself. A strong Mars gives determination, physical strength, and the ability to overcome obstacles.'**
  String get planets_mars_desc;

  /// No description provided for @planets_mercury_desc.
  ///
  /// In en, this message translates to:
  /// **'Mercury represents intellect, communication, and analytical ability. It shows your thinking patterns, speech, and business acumen. A strong Mercury gives sharp wit, good communication skills, and adaptability.'**
  String get planets_mercury_desc;

  /// No description provided for @planets_jupiter_desc.
  ///
  /// In en, this message translates to:
  /// **'Jupiter represents wisdom, knowledge, expansion, and good fortune. It shows your philosophical outlook, teaching ability, and spiritual growth. A strong Jupiter brings blessings, optimism, and prosperity.'**
  String get planets_jupiter_desc;

  /// No description provided for @planets_venus_desc.
  ///
  /// In en, this message translates to:
  /// **'Venus represents love, beauty, pleasures, and relationships. It shows your romantic nature, artistic talents, and appreciation for luxury. A strong Venus gives charm, creativity, and harmonious relationships.'**
  String get planets_venus_desc;

  /// No description provided for @planets_saturn_desc.
  ///
  /// In en, this message translates to:
  /// **'Saturn represents discipline, responsibility, karma, and life lessons. It shows your endurance, work ethic, and areas of restriction. A strong Saturn gives perseverance, maturity, and long-lasting achievements.'**
  String get planets_saturn_desc;

  /// No description provided for @planets_rahu_desc.
  ///
  /// In en, this message translates to:
  /// **'Rahu represents desires, obsessions, and worldly ambitions. It shows your unconventional side, foreign connections, and areas of intense focus. Rahu amplifies whatever it touches and drives material pursuits.'**
  String get planets_rahu_desc;

  /// No description provided for @planets_ketu_desc.
  ///
  /// In en, this message translates to:
  /// **'Ketu represents spirituality, detachment, and past life karma. It shows your intuitive abilities, liberation tendencies, and areas where you seek transcendence. Ketu brings wisdom through letting go.'**
  String get planets_ketu_desc;

  /// No description provided for @planets_currently.
  ///
  /// In en, this message translates to:
  /// **'Currently {dignity} in {sign}.'**
  String planets_currently(String dignity, String sign);

  /// No description provided for @planets_combustInfo.
  ///
  /// In en, this message translates to:
  /// **'This planet is combust (too close to Sun), which reduces its strength.'**
  String get planets_combustInfo;

  /// No description provided for @planets_retroInfo.
  ///
  /// In en, this message translates to:
  /// **'Currently retrograde, which intensifies its internal effects.'**
  String get planets_retroInfo;

  /// No description provided for @planets_planetSignificance.
  ///
  /// In en, this message translates to:
  /// **'{planet} is placed in {sign} at {degree}° in House {house}. The Nakshatra is {nakshatra} (Pada {pada}), ruled by {lord}. This is a {nature} planet.'**
  String planets_planetSignificance(
    String planet,
    String sign,
    String degree,
    int house,
    String nakshatra,
    int pada,
    String lord,
    String nature,
  );

  /// No description provided for @planets_planetaryStatus.
  ///
  /// In en, this message translates to:
  /// **'Planetary Status'**
  String get planets_planetaryStatus;

  /// No description provided for @planets_statusCount.
  ///
  /// In en, this message translates to:
  /// **'Count: {count} planets'**
  String planets_statusCount(int count);

  /// No description provided for @planets_statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String planets_statusLabel(String status);

  /// No description provided for @planets_defaultDesc.
  ///
  /// In en, this message translates to:
  /// **'This planet influences specific life areas.'**
  String get planets_defaultDesc;

  /// No description provided for @planet_sun_desc.
  ///
  /// In en, this message translates to:
  /// **'The Sun represents your soul, ego, vitality, and life force. It shows your core identity, self-expression, and relationship with authority. A strong Sun gives confidence, leadership qualities, and recognition.'**
  String get planet_sun_desc;

  /// No description provided for @planet_moon_desc.
  ///
  /// In en, this message translates to:
  /// **'The Moon represents your mind, emotions, and subconscious patterns. It shows your emotional nature, mental peace, and connection with the mother. A strong Moon gives emotional stability and intuition.'**
  String get planet_moon_desc;

  /// No description provided for @planet_mars_desc.
  ///
  /// In en, this message translates to:
  /// **'Mars represents courage, energy, aggression, and action. It shows your drive, competitive spirit, and how you assert yourself. A strong Mars gives determination, physical strength, and the ability to overcome obstacles.'**
  String get planet_mars_desc;

  /// No description provided for @planet_mercury_desc.
  ///
  /// In en, this message translates to:
  /// **'Mercury represents intellect, communication, and analytical ability. It shows your thinking patterns, speech, and business acumen. A strong Mercury gives sharp wit, good communication skills, and adaptability.'**
  String get planet_mercury_desc;

  /// No description provided for @planet_jupiter_desc.
  ///
  /// In en, this message translates to:
  /// **'Jupiter represents wisdom, knowledge, expansion, and good fortune. It shows your philosophical outlook, teaching ability, and spiritual growth. A strong Jupiter brings blessings, optimism, and prosperity.'**
  String get planet_jupiter_desc;

  /// No description provided for @planet_venus_desc.
  ///
  /// In en, this message translates to:
  /// **'Venus represents love, beauty, pleasures, and relationships. It shows your romantic nature, artistic talents, and appreciation for luxury. A strong Venus gives charm, creativity, and harmonious relationships.'**
  String get planet_venus_desc;

  /// No description provided for @planet_saturn_desc.
  ///
  /// In en, this message translates to:
  /// **'Saturn represents discipline, responsibility, karma, and life lessons. It shows your endurance, work ethic, and areas of restriction. A strong Saturn gives perseverance, maturity, and long-lasting achievements.'**
  String get planet_saturn_desc;

  /// No description provided for @planet_rahu_desc.
  ///
  /// In en, this message translates to:
  /// **'Rahu represents desires, obsessions, and worldly ambitions. It shows your unconventional side, foreign connections, and areas of intense focus. Rahu amplifies whatever it touches and drives material pursuits.'**
  String get planet_rahu_desc;

  /// No description provided for @planet_ketu_desc.
  ///
  /// In en, this message translates to:
  /// **'Ketu represents spirituality, detachment, and past life karma. It shows your intuitive abilities, liberation tendencies, and areas where you seek transcendence. Ketu brings wisdom through letting go.'**
  String get planet_ketu_desc;

  /// No description provided for @transit_nav_overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get transit_nav_overview;

  /// No description provided for @transit_nav_sky.
  ///
  /// In en, this message translates to:
  /// **'Sky'**
  String get transit_nav_sky;

  /// No description provided for @transit_nav_gochar.
  ///
  /// In en, this message translates to:
  /// **'Gochar'**
  String get transit_nav_gochar;

  /// No description provided for @transit_nav_effects.
  ///
  /// In en, this message translates to:
  /// **'Effects'**
  String get transit_nav_effects;

  /// No description provided for @transit_nav_sadesati.
  ///
  /// In en, this message translates to:
  /// **'Sade Sati'**
  String get transit_nav_sadesati;

  /// No description provided for @transit_currentSky_title.
  ///
  /// In en, this message translates to:
  /// **'Current Sky'**
  String get transit_currentSky_title;

  /// No description provided for @transit_currentSky_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time planetary positions'**
  String get transit_currentSky_subtitle;

  /// No description provided for @transit_gochar_title.
  ///
  /// In en, this message translates to:
  /// **'Gochar (गोचर)'**
  String get transit_gochar_title;

  /// No description provided for @transit_gochar_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Transit from {moonSign} (Janma Rashi)'**
  String transit_gochar_subtitle(Object moonSign);

  /// No description provided for @transit_effects_title.
  ///
  /// In en, this message translates to:
  /// **'Transit Effects'**
  String get transit_effects_title;

  /// No description provided for @transit_effects_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Impact analysis on your chart'**
  String get transit_effects_subtitle;

  /// No description provided for @transit_sadesati_title.
  ///
  /// In en, this message translates to:
  /// **'Sade Sati (साढ़े साती)'**
  String get transit_sadesati_title;

  /// No description provided for @transit_sadesati_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Saturn\'s 7.5 year transit cycle'**
  String get transit_sadesati_subtitle;

  /// No description provided for @transit_live.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get transit_live;

  /// No description provided for @transit_overview.
  ///
  /// In en, this message translates to:
  /// **'Transit Overview'**
  String get transit_overview;

  /// No description provided for @transit_balance_excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get transit_balance_excellent;

  /// No description provided for @transit_balance_good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get transit_balance_good;

  /// No description provided for @transit_balance_mixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get transit_balance_mixed;

  /// No description provided for @transit_balance_tough.
  ///
  /// In en, this message translates to:
  /// **'Tough'**
  String get transit_balance_tough;

  /// No description provided for @transit_balance_difficult.
  ///
  /// In en, this message translates to:
  /// **'Difficult'**
  String get transit_balance_difficult;

  /// No description provided for @transit_challenging.
  ///
  /// In en, this message translates to:
  /// **'Challenging'**
  String get transit_challenging;

  /// No description provided for @transit_planet_header.
  ///
  /// In en, this message translates to:
  /// **'Planet'**
  String get transit_planet_header;

  /// No description provided for @transit_current_header.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get transit_current_header;

  /// No description provided for @transit_natal_header.
  ///
  /// In en, this message translates to:
  /// **'Natal'**
  String get transit_natal_header;

  /// No description provided for @transit_major.
  ///
  /// In en, this message translates to:
  /// **'Major'**
  String get transit_major;

  /// No description provided for @transit_good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get transit_good;

  /// No description provided for @transit_alert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get transit_alert;

  /// No description provided for @transit_housesFrom.
  ///
  /// In en, this message translates to:
  /// **'Houses from {moonSign}'**
  String transit_housesFrom(Object moonSign);

  /// No description provided for @transit_moon_label.
  ///
  /// In en, this message translates to:
  /// **'Moon'**
  String get transit_moon_label;

  /// No description provided for @transit_sadesati_active.
  ///
  /// In en, this message translates to:
  /// **'Sade Sati Active'**
  String get transit_sadesati_active;

  /// No description provided for @transit_sadesati_notActive.
  ///
  /// In en, this message translates to:
  /// **'Sade Sati Not Active'**
  String get transit_sadesati_notActive;

  /// No description provided for @transit_sadesati_clearPeriod.
  ///
  /// In en, this message translates to:
  /// **'Clear Period'**
  String get transit_sadesati_clearPeriod;

  /// No description provided for @transit_sadesati_notAffecting.
  ///
  /// In en, this message translates to:
  /// **'Saturn\'s 7.5-year cycle is not affecting you'**
  String get transit_sadesati_notAffecting;

  /// No description provided for @transit_sadesati_learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get transit_sadesati_learnMore;

  /// No description provided for @transit_saturn.
  ///
  /// In en, this message translates to:
  /// **'Saturn'**
  String get transit_saturn;

  /// No description provided for @transit_phase_rising.
  ///
  /// In en, this message translates to:
  /// **'Rising Phase'**
  String get transit_phase_rising;

  /// No description provided for @transit_phase_peak.
  ///
  /// In en, this message translates to:
  /// **'Peak Phase'**
  String get transit_phase_peak;

  /// No description provided for @transit_phase_setting.
  ///
  /// In en, this message translates to:
  /// **'Setting Phase'**
  String get transit_phase_setting;

  /// No description provided for @transit_phase_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get transit_phase_active;

  /// No description provided for @transit_phase_rising_subtitle.
  ///
  /// In en, this message translates to:
  /// **'12th from Moon · Expenses & Mental Stress'**
  String get transit_phase_rising_subtitle;

  /// No description provided for @transit_phase_peak_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Over Moon · Most Intense Period'**
  String get transit_phase_peak_subtitle;

  /// No description provided for @transit_phase_setting_subtitle.
  ///
  /// In en, this message translates to:
  /// **'2nd from Moon · Family & Finances'**
  String get transit_phase_setting_subtitle;

  /// No description provided for @transit_janmaRashi.
  ///
  /// In en, this message translates to:
  /// **'(Janma Rashi)'**
  String get transit_janmaRashi;

  /// No description provided for @transit_12th.
  ///
  /// In en, this message translates to:
  /// **'12th'**
  String get transit_12th;

  /// No description provided for @transit_1st.
  ///
  /// In en, this message translates to:
  /// **'1st'**
  String get transit_1st;

  /// No description provided for @transit_2nd.
  ///
  /// In en, this message translates to:
  /// **'2nd'**
  String get transit_2nd;

  /// No description provided for @transit_on.
  ///
  /// In en, this message translates to:
  /// **'on'**
  String get transit_on;

  /// No description provided for @transit_insight_overview_title.
  ///
  /// In en, this message translates to:
  /// **'Transit Overview'**
  String get transit_insight_overview_title;

  /// No description provided for @transit_insight_overview_desc.
  ///
  /// In en, this message translates to:
  /// **'Planetary transits (Gochar) are the current positions of planets in the sky relative to your birth chart. They trigger events and influence your life based on their relationship with your natal planets, especially the Moon sign (Janma Rashi).'**
  String get transit_insight_overview_desc;

  /// No description provided for @transit_insight_overview_significance.
  ///
  /// In en, this message translates to:
  /// **'Currently, {favorable} planets are in favorable positions and {challenging} are challenging. Your Janma Rashi is {moonSign}, which is the reference point for all transit calculations in Vedic astrology.'**
  String transit_insight_overview_significance(
    Object challenging,
    Object favorable,
    Object moonSign,
  );

  /// No description provided for @transit_insight_overview_keypoint1.
  ///
  /// In en, this message translates to:
  /// **'Favorable Transits: {count} planets'**
  String transit_insight_overview_keypoint1(Object count);

  /// No description provided for @transit_insight_overview_keypoint2.
  ///
  /// In en, this message translates to:
  /// **'Challenging Transits: {count} planets'**
  String transit_insight_overview_keypoint2(Object count);

  /// No description provided for @transit_insight_overview_keypoint3.
  ///
  /// In en, this message translates to:
  /// **'Overall Balance: {status}'**
  String transit_insight_overview_keypoint3(Object status);

  /// No description provided for @transit_insight_overview_keypoint4.
  ///
  /// In en, this message translates to:
  /// **'Janma Rashi (Moon Sign): {moonSign}'**
  String transit_insight_overview_keypoint4(Object moonSign);

  /// No description provided for @transit_insight_overview_keypoint5.
  ///
  /// In en, this message translates to:
  /// **'Favorable houses from Moon: 3, 6, 10, 11'**
  String get transit_insight_overview_keypoint5;

  /// No description provided for @transit_insight_overview_keypoint6.
  ///
  /// In en, this message translates to:
  /// **'Transits are temporary influences that trigger natal potential'**
  String get transit_insight_overview_keypoint6;

  /// No description provided for @transit_insight_gochar_title.
  ///
  /// In en, this message translates to:
  /// **'Gochar (गोचर)'**
  String get transit_insight_gochar_title;

  /// No description provided for @transit_insight_gochar_value.
  ///
  /// In en, this message translates to:
  /// **'Transit System'**
  String get transit_insight_gochar_value;

  /// No description provided for @transit_insight_gochar_desc.
  ///
  /// In en, this message translates to:
  /// **'Gochar is the Vedic system of planetary transits calculated from the Moon sign. Unlike Western astrology which uses the Sun sign, Vedic astrology emphasizes the Moon as the seat of the mind and emotions, making it the primary reference for transit predictions.'**
  String get transit_insight_gochar_desc;

  /// No description provided for @transit_insight_gochar_significance.
  ///
  /// In en, this message translates to:
  /// **'Your transits are calculated from {moonSign}, your Janma Rashi. Planets transiting the 3rd, 6th, 10th, and 11th houses from Moon are generally favorable, while the 1st, 2nd, 4th, 5th, 7th, 8th, 9th, and 12th require careful attention.'**
  String transit_insight_gochar_significance(Object moonSign);

  /// No description provided for @transit_insight_gochar_keypoint1.
  ///
  /// In en, this message translates to:
  /// **'Reference Point: {moonSign} (Janma Rashi)'**
  String transit_insight_gochar_keypoint1(Object moonSign);

  /// No description provided for @transit_insight_gochar_keypoint2.
  ///
  /// In en, this message translates to:
  /// **'Favorable Houses: 3, 6, 10, 11'**
  String get transit_insight_gochar_keypoint2;

  /// No description provided for @transit_insight_gochar_keypoint3.
  ///
  /// In en, this message translates to:
  /// **'Challenging Houses: 1, 4, 5, 7, 8, 12'**
  String get transit_insight_gochar_keypoint3;

  /// No description provided for @transit_insight_gochar_keypoint4.
  ///
  /// In en, this message translates to:
  /// **'Neutral Houses: 2, 9'**
  String get transit_insight_gochar_keypoint4;

  /// No description provided for @transit_insight_gochar_keypoint5.
  ///
  /// In en, this message translates to:
  /// **'Each planet has specific favorable/unfavorable houses'**
  String get transit_insight_gochar_keypoint5;

  /// No description provided for @transit_insight_gochar_keypoint6.
  ///
  /// In en, this message translates to:
  /// **'Slow planets (Saturn, Jupiter, Rahu/Ketu) have longer effects'**
  String get transit_insight_gochar_keypoint6;

  /// No description provided for @transit_insight_planet_title.
  ///
  /// In en, this message translates to:
  /// **'Transit'**
  String get transit_insight_planet_title;

  /// No description provided for @transit_insight_planet_value.
  ///
  /// In en, this message translates to:
  /// **'{planet} in House {house}'**
  String transit_insight_planet_value(Object house, Object planet);

  /// No description provided for @transit_insight_planet_desc_favorable.
  ///
  /// In en, this message translates to:
  /// **'{planet} is currently transiting {sign} at {degree}°, which is the {house} house from your Moon sign. This is a favorable position.'**
  String transit_insight_planet_desc_favorable(
    Object degree,
    Object house,
    Object planet,
    Object sign,
  );

  /// No description provided for @transit_insight_planet_desc_challenging.
  ///
  /// In en, this message translates to:
  /// **'{planet} is currently transiting {sign} at {degree}°, which is the {house} house from your Moon sign. This position requires attention.'**
  String transit_insight_planet_desc_challenging(
    Object degree,
    Object house,
    Object planet,
    Object sign,
  );

  /// No description provided for @transit_insight_planet_significance_favorable.
  ///
  /// In en, this message translates to:
  /// **'{planet} in the {house} house supports growth and positive developments.'**
  String transit_insight_planet_significance_favorable(
    Object house,
    Object planet,
  );

  /// No description provided for @transit_insight_planet_significance_challenging.
  ///
  /// In en, this message translates to:
  /// **'{planet} in the {house} house may bring challenges that require patience and careful handling.'**
  String transit_insight_planet_significance_challenging(
    Object house,
    Object planet,
  );

  /// No description provided for @transit_insight_planet_keypoint1.
  ///
  /// In en, this message translates to:
  /// **'Planet: {planet}'**
  String transit_insight_planet_keypoint1(Object planet);

  /// No description provided for @transit_insight_planet_keypoint2.
  ///
  /// In en, this message translates to:
  /// **'Current Sign: {sign}'**
  String transit_insight_planet_keypoint2(Object sign);

  /// No description provided for @transit_insight_planet_keypoint3.
  ///
  /// In en, this message translates to:
  /// **'Degree: {degree}°'**
  String transit_insight_planet_keypoint3(Object degree);

  /// No description provided for @transit_insight_planet_keypoint4.
  ///
  /// In en, this message translates to:
  /// **'House from Moon: {house}'**
  String transit_insight_planet_keypoint4(Object house);

  /// No description provided for @transit_insight_planet_keypoint5_favorable.
  ///
  /// In en, this message translates to:
  /// **'Status: Favorable ✓'**
  String get transit_insight_planet_keypoint5_favorable;

  /// No description provided for @transit_insight_planet_keypoint5_challenging.
  ///
  /// In en, this message translates to:
  /// **'Status: Challenging ⚠'**
  String get transit_insight_planet_keypoint5_challenging;

  /// No description provided for @transit_insight_planet_keypoint6.
  ///
  /// In en, this message translates to:
  /// **'Aspect to Natal: {aspect}'**
  String transit_insight_planet_keypoint6(Object aspect);

  /// No description provided for @transit_insight_planet_keypoint7.
  ///
  /// In en, this message translates to:
  /// **'Major Transit: {planet} moves slowly, effects last {duration} per sign'**
  String transit_insight_planet_keypoint7(Object duration, Object planet);

  /// No description provided for @transit_insight_house_title.
  ///
  /// In en, this message translates to:
  /// **'Gochar House'**
  String get transit_insight_house_title;

  /// No description provided for @transit_insight_house_value.
  ///
  /// In en, this message translates to:
  /// **'House {house}'**
  String transit_insight_house_value(Object house);

  /// No description provided for @transit_insight_house_value_moon.
  ///
  /// In en, this message translates to:
  /// **'House {house} (Moon)'**
  String transit_insight_house_value_moon(Object house);

  /// No description provided for @transit_insight_house_desc_moonHouse.
  ///
  /// In en, this message translates to:
  /// **'House {house} represents {significations}. This is your Janma Rashi house where the Moon was at birth.'**
  String transit_insight_house_desc_moonHouse(
    Object house,
    Object significations,
  );

  /// No description provided for @transit_insight_house_desc_favorable.
  ///
  /// In en, this message translates to:
  /// **'House {house} represents {significations}. This is generally a favorable house for transits.'**
  String transit_insight_house_desc_favorable(
    Object house,
    Object significations,
  );

  /// No description provided for @transit_insight_house_desc_challenging.
  ///
  /// In en, this message translates to:
  /// **'House {house} represents {significations}. Transits through this house require attention.'**
  String transit_insight_house_desc_challenging(
    Object house,
    Object significations,
  );

  /// No description provided for @transit_insight_house_significance_empty.
  ///
  /// In en, this message translates to:
  /// **'No planets are currently transiting this house.'**
  String get transit_insight_house_significance_empty;

  /// No description provided for @transit_insight_house_significance_planets.
  ///
  /// In en, this message translates to:
  /// **'Currently {planets} {verb} transiting this house, {action} matters related to {area}.'**
  String transit_insight_house_significance_planets(
    Object action,
    Object area,
    Object planets,
    Object verb,
  );

  /// No description provided for @transit_insight_house_keypoint1.
  ///
  /// In en, this message translates to:
  /// **'House Number: {house}'**
  String transit_insight_house_keypoint1(Object house);

  /// No description provided for @transit_insight_house_keypoint2.
  ///
  /// In en, this message translates to:
  /// **'Significations: {significations}'**
  String transit_insight_house_keypoint2(Object significations);

  /// No description provided for @transit_insight_house_keypoint3.
  ///
  /// In en, this message translates to:
  /// **'Type: Janma Rashi (Moon Sign House)'**
  String get transit_insight_house_keypoint3;

  /// No description provided for @transit_insight_house_keypoint4_favorable.
  ///
  /// In en, this message translates to:
  /// **'Transit Quality: Favorable ★'**
  String get transit_insight_house_keypoint4_favorable;

  /// No description provided for @transit_insight_house_keypoint4_challenging.
  ///
  /// In en, this message translates to:
  /// **'Transit Quality: Requires Attention'**
  String get transit_insight_house_keypoint4_challenging;

  /// No description provided for @transit_insight_house_keypoint5.
  ///
  /// In en, this message translates to:
  /// **'Current Planets: {planets}'**
  String transit_insight_house_keypoint5(Object planets);

  /// No description provided for @transit_insight_sadesati_title.
  ///
  /// In en, this message translates to:
  /// **'Sade Sati (साढ़े साती)'**
  String get transit_insight_sadesati_title;

  /// No description provided for @transit_insight_sadesati_value_active.
  ///
  /// In en, this message translates to:
  /// **'{phase}'**
  String transit_insight_sadesati_value_active(Object phase);

  /// No description provided for @transit_insight_sadesati_value_inactive.
  ///
  /// In en, this message translates to:
  /// **'Not Active'**
  String get transit_insight_sadesati_value_inactive;

  /// No description provided for @transit_insight_sadesati_desc.
  ///
  /// In en, this message translates to:
  /// **'Sade Sati is Saturn\'s 7.5-year transit cycle over three signs: the 12th, 1st, and 2nd from your Moon sign. Each sign takes approximately 2.5 years. This period is often associated with challenges, delays, and karmic lessons, but also brings maturity and spiritual growth.'**
  String get transit_insight_sadesati_desc;

  /// No description provided for @transit_insight_sadesati_significance_active.
  ///
  /// In en, this message translates to:
  /// **'{description} Saturn is transiting {sign} at {degree}°.'**
  String transit_insight_sadesati_significance_active(
    Object degree,
    Object description,
    Object sign,
  );

  /// No description provided for @transit_insight_sadesati_significance_inactive.
  ///
  /// In en, this message translates to:
  /// **'Saturn is not currently transiting the 12th, 1st, or 2nd house from your Moon sign ({moonSign}). Sade Sati is not active.'**
  String transit_insight_sadesati_significance_inactive(Object moonSign);

  /// No description provided for @transit_insight_sadesati_keypoint1.
  ///
  /// In en, this message translates to:
  /// **'Duration: 7.5 years total (~2.5 years per phase)'**
  String get transit_insight_sadesati_keypoint1;

  /// No description provided for @transit_insight_sadesati_keypoint2.
  ///
  /// In en, this message translates to:
  /// **'Phase 1 (Rising): Saturn in 12th from Moon - expenses, travel, mental stress'**
  String get transit_insight_sadesati_keypoint2;

  /// No description provided for @transit_insight_sadesati_keypoint3.
  ///
  /// In en, this message translates to:
  /// **'Phase 2 (Peak): Saturn over Moon - most intense, health/emotional challenges'**
  String get transit_insight_sadesati_keypoint3;

  /// No description provided for @transit_insight_sadesati_keypoint4.
  ///
  /// In en, this message translates to:
  /// **'Phase 3 (Setting): Saturn in 2nd from Moon - family, finances, speech'**
  String get transit_insight_sadesati_keypoint4;

  /// No description provided for @transit_insight_sadesati_keypoint5.
  ///
  /// In en, this message translates to:
  /// **'Current Phase: {phase}'**
  String transit_insight_sadesati_keypoint5(Object phase);

  /// No description provided for @transit_insight_sadesati_keypoint6.
  ///
  /// In en, this message translates to:
  /// **'Saturn in: {sign}'**
  String transit_insight_sadesati_keypoint6(Object sign);

  /// No description provided for @transit_insight_sadesati_keypoint7.
  ///
  /// In en, this message translates to:
  /// **'Remedies: Saturn mantras, charity on Saturdays, patience'**
  String get transit_insight_sadesati_keypoint7;

  /// No description provided for @transit_insight_currentSky_title.
  ///
  /// In en, this message translates to:
  /// **'Current Sky'**
  String get transit_insight_currentSky_title;

  /// No description provided for @transit_insight_currentSky_value.
  ///
  /// In en, this message translates to:
  /// **'Live Planetary Positions'**
  String get transit_insight_currentSky_value;

  /// No description provided for @transit_insight_currentSky_desc.
  ///
  /// In en, this message translates to:
  /// **'These are the real-time positions of planets in the zodiac right now. The \"Current\" column shows where each planet is today, while \"Natal\" shows where it was at your birth. When these align or form aspects, significant transits occur.'**
  String get transit_insight_currentSky_desc;

  /// No description provided for @transit_insight_currentSky_significance.
  ///
  /// In en, this message translates to:
  /// **'Comparing current positions to your natal chart reveals active transits. Pay special attention to slow-moving planets (Saturn, Jupiter, Rahu, Ketu) as their transits have longer-lasting effects.'**
  String get transit_insight_currentSky_significance;

  /// No description provided for @transit_insight_currentSky_keypoint1.
  ///
  /// In en, this message translates to:
  /// **'Sun/Moon: Quick transits, daily/monthly influences'**
  String get transit_insight_currentSky_keypoint1;

  /// No description provided for @transit_insight_currentSky_keypoint2.
  ///
  /// In en, this message translates to:
  /// **'Mercury/Venus/Mars: Medium-speed, weeks to months'**
  String get transit_insight_currentSky_keypoint2;

  /// No description provided for @transit_insight_currentSky_keypoint3.
  ///
  /// In en, this message translates to:
  /// **'Jupiter: ~1 year per sign, major life themes'**
  String get transit_insight_currentSky_keypoint3;

  /// No description provided for @transit_insight_currentSky_keypoint4.
  ///
  /// In en, this message translates to:
  /// **'Saturn: ~2.5 years per sign, karmic lessons'**
  String get transit_insight_currentSky_keypoint4;

  /// No description provided for @transit_insight_currentSky_keypoint5.
  ///
  /// In en, this message translates to:
  /// **'Rahu/Ketu: ~1.5 years per sign, destiny points'**
  String get transit_insight_currentSky_keypoint5;

  /// No description provided for @transit_insight_currentSky_keypoint6.
  ///
  /// In en, this message translates to:
  /// **'Retrograde (℞): Planet appears to move backward, intensified effects'**
  String get transit_insight_currentSky_keypoint6;

  /// No description provided for @transit_insight_currentSky_keypoint7.
  ///
  /// In en, this message translates to:
  /// **'Sign Change (↔): Planet entering new sign, shift in energy'**
  String get transit_insight_currentSky_keypoint7;

  /// No description provided for @transit_insight_currentPosition_title.
  ///
  /// In en, this message translates to:
  /// **'Current Position'**
  String get transit_insight_currentPosition_title;

  /// No description provided for @transit_insight_currentPosition_desc.
  ///
  /// In en, this message translates to:
  /// **'{planet} is currently at {degree}° in {sign}{retro}. {natalInfo}'**
  String transit_insight_currentPosition_desc(
    Object degree,
    Object natalInfo,
    Object planet,
    Object retro,
    Object sign,
  );

  /// No description provided for @transit_insight_currentPosition_retro.
  ///
  /// In en, this message translates to:
  /// **' (Retrograde)'**
  String get transit_insight_currentPosition_retro;

  /// No description provided for @transit_insight_currentPosition_natalInfo.
  ///
  /// In en, this message translates to:
  /// **'At your birth, {planet} was at {degree}° in {sign}.'**
  String transit_insight_currentPosition_natalInfo(
    Object degree,
    Object planet,
    Object sign,
  );

  /// No description provided for @transit_insight_currentPosition_significance_changed.
  ///
  /// In en, this message translates to:
  /// **'{planet} has moved to a different sign since your birth. This indicates the planet is in a new area of your chart.'**
  String transit_insight_currentPosition_significance_changed(Object planet);

  /// No description provided for @transit_insight_currentPosition_significance_same.
  ///
  /// In en, this message translates to:
  /// **'{planet} is in the same sign as at birth.'**
  String transit_insight_currentPosition_significance_same(Object planet);

  /// No description provided for @transit_insight_currentPosition_significance_transiting.
  ///
  /// In en, this message translates to:
  /// **'{planet} is currently transiting.'**
  String transit_insight_currentPosition_significance_transiting(Object planet);

  /// No description provided for @transit_insight_currentPosition_significance_slow.
  ///
  /// In en, this message translates to:
  /// **' As a slow-moving planet, its transits have longer-lasting effects.'**
  String get transit_insight_currentPosition_significance_slow;

  /// No description provided for @transit_insight_currentPosition_keypoint1.
  ///
  /// In en, this message translates to:
  /// **'Planet: {planet}'**
  String transit_insight_currentPosition_keypoint1(Object planet);

  /// No description provided for @transit_insight_currentPosition_keypoint2.
  ///
  /// In en, this message translates to:
  /// **'Current: {sign} {degree}°'**
  String transit_insight_currentPosition_keypoint2(Object degree, Object sign);

  /// No description provided for @transit_insight_currentPosition_keypoint3.
  ///
  /// In en, this message translates to:
  /// **'Natal: {sign} {degree}°'**
  String transit_insight_currentPosition_keypoint3(Object degree, Object sign);

  /// No description provided for @transit_insight_currentPosition_keypoint4.
  ///
  /// In en, this message translates to:
  /// **'Status: Retrograde ℞'**
  String get transit_insight_currentPosition_keypoint4;

  /// No description provided for @transit_insight_currentPosition_keypoint5.
  ///
  /// In en, this message translates to:
  /// **'Sign Changed: Yes'**
  String get transit_insight_currentPosition_keypoint5;

  /// No description provided for @transit_insight_currentPosition_keypoint6.
  ///
  /// In en, this message translates to:
  /// **'Transit Speed: Slow ({duration}/sign)'**
  String transit_insight_currentPosition_keypoint6(Object duration);

  /// No description provided for @transit_insight_transitCount_title.
  ///
  /// In en, this message translates to:
  /// **'{label} Transits'**
  String transit_insight_transitCount_title(Object label);

  /// No description provided for @transit_insight_transitCount_value.
  ///
  /// In en, this message translates to:
  /// **'{count} Planets'**
  String transit_insight_transitCount_value(Object count);

  /// No description provided for @transit_insight_transitCount_desc_favorable.
  ///
  /// In en, this message translates to:
  /// **'These planets are currently transiting houses that are generally supportive from your Moon sign. Favorable transits bring opportunities, success, and positive energy.'**
  String get transit_insight_transitCount_desc_favorable;

  /// No description provided for @transit_insight_transitCount_desc_challenging.
  ///
  /// In en, this message translates to:
  /// **'These planets are currently in positions that may bring challenges or require extra attention. Challenging transits offer growth opportunities through overcoming obstacles.'**
  String get transit_insight_transitCount_desc_challenging;

  /// No description provided for @transit_insight_transitCount_significance.
  ///
  /// In en, this message translates to:
  /// **'You have {count} {label} planetary transits currently active.'**
  String transit_insight_transitCount_significance(Object count, Object label);

  /// No description provided for @transit_insight_transitCount_keypoint1.
  ///
  /// In en, this message translates to:
  /// **'Count: {count} planets'**
  String transit_insight_transitCount_keypoint1(Object count);

  /// No description provided for @transit_insight_transitCount_keypoint2.
  ///
  /// In en, this message translates to:
  /// **'Type: {label}'**
  String transit_insight_transitCount_keypoint2(Object label);

  /// No description provided for @transit_insight_transitCount_keypoint3_favorable.
  ///
  /// In en, this message translates to:
  /// **'Houses 3, 6, 10, 11 are generally favorable'**
  String get transit_insight_transitCount_keypoint3_favorable;

  /// No description provided for @transit_insight_transitCount_keypoint3_challenging.
  ///
  /// In en, this message translates to:
  /// **'Other houses require more attention'**
  String get transit_insight_transitCount_keypoint3_challenging;

  /// No description provided for @transit_insight_transitCount_keypoint4.
  ///
  /// In en, this message translates to:
  /// **'Transits are calculated from your Moon sign (Janma Rashi)'**
  String get transit_insight_transitCount_keypoint4;

  /// No description provided for @transit_house_1_significations.
  ///
  /// In en, this message translates to:
  /// **'Self, personality, health, new beginnings'**
  String get transit_house_1_significations;

  /// No description provided for @transit_house_2_significations.
  ///
  /// In en, this message translates to:
  /// **'Wealth, family, speech, accumulated resources'**
  String get transit_house_2_significations;

  /// No description provided for @transit_house_3_significations.
  ///
  /// In en, this message translates to:
  /// **'Courage, siblings, communication, short journeys'**
  String get transit_house_3_significations;

  /// No description provided for @transit_house_4_significations.
  ///
  /// In en, this message translates to:
  /// **'Home, mother, comfort, emotional well-being, property'**
  String get transit_house_4_significations;

  /// No description provided for @transit_house_5_significations.
  ///
  /// In en, this message translates to:
  /// **'Intelligence, children, creativity, romance, speculation'**
  String get transit_house_5_significations;

  /// No description provided for @transit_house_6_significations.
  ///
  /// In en, this message translates to:
  /// **'Enemies, diseases, debts, daily work, service'**
  String get transit_house_6_significations;

  /// No description provided for @transit_house_7_significations.
  ///
  /// In en, this message translates to:
  /// **'Marriage, partnerships, business relationships'**
  String get transit_house_7_significations;

  /// No description provided for @transit_house_8_significations.
  ///
  /// In en, this message translates to:
  /// **'Longevity, transformation, inheritance, hidden matters'**
  String get transit_house_8_significations;

  /// No description provided for @transit_house_9_significations.
  ///
  /// In en, this message translates to:
  /// **'Fortune, higher learning, spirituality, father, long journeys'**
  String get transit_house_9_significations;

  /// No description provided for @transit_house_10_significations.
  ///
  /// In en, this message translates to:
  /// **'Career, reputation, authority, public standing'**
  String get transit_house_10_significations;

  /// No description provided for @transit_house_11_significations.
  ///
  /// In en, this message translates to:
  /// **'Gains, income, friends, fulfillment of desires'**
  String get transit_house_11_significations;

  /// No description provided for @transit_house_12_significations.
  ///
  /// In en, this message translates to:
  /// **'Losses, expenses, foreign lands, liberation, isolation'**
  String get transit_house_12_significations;

  /// No description provided for @transit_sadesati_phase1_desc.
  ///
  /// In en, this message translates to:
  /// **'Saturn transiting 12th from Moon. Beginning of 7.5 year cycle. Increased expenses, travel, and mental stress possible.'**
  String get transit_sadesati_phase1_desc;

  /// No description provided for @transit_sadesati_phase2_desc.
  ///
  /// In en, this message translates to:
  /// **'Saturn transiting over Moon sign. Most intense period. Health, emotions, and relationships may face challenges.'**
  String get transit_sadesati_phase2_desc;

  /// No description provided for @transit_sadesati_phase3_desc.
  ///
  /// In en, this message translates to:
  /// **'Saturn transiting 2nd from Moon. Final phase. Financial matters, family, and speech may be affected.'**
  String get transit_sadesati_phase3_desc;

  /// No description provided for @transit_veryFavorable.
  ///
  /// In en, this message translates to:
  /// **'Very Favorable'**
  String get transit_veryFavorable;

  /// No description provided for @transit_none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get transit_none;

  /// No description provided for @transit_tapForDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap for details'**
  String get transit_tapForDetails;

  /// No description provided for @transit_is.
  ///
  /// In en, this message translates to:
  /// **'is'**
  String get transit_is;

  /// No description provided for @transit_are.
  ///
  /// In en, this message translates to:
  /// **'are'**
  String get transit_are;

  /// No description provided for @transit_supporting.
  ///
  /// In en, this message translates to:
  /// **'supporting'**
  String get transit_supporting;

  /// No description provided for @transit_influencing.
  ///
  /// In en, this message translates to:
  /// **'influencing'**
  String get transit_influencing;

  /// No description provided for @transit_currentPosition.
  ///
  /// In en, this message translates to:
  /// **'Current Position'**
  String get transit_currentPosition;

  /// No description provided for @transit_changed.
  ///
  /// In en, this message translates to:
  /// **'Changed'**
  String get transit_changed;

  /// No description provided for @transit_houseFromMoon.
  ///
  /// In en, this message translates to:
  /// **'House {house} from Moon'**
  String transit_houseFromMoon(Object house);

  /// No description provided for @transit_currentSkyPositions.
  ///
  /// In en, this message translates to:
  /// **'Current Sky Positions'**
  String get transit_currentSkyPositions;

  /// No description provided for @transit_currentSkyPositions_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time planetary transits'**
  String get transit_currentSkyPositions_subtitle;

  /// No description provided for @transit_houseTransits.
  ///
  /// In en, this message translates to:
  /// **'House Transits'**
  String get transit_houseTransits;

  /// No description provided for @transit_houseTransits_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Effects from {moonSign}'**
  String transit_houseTransits_subtitle(Object moonSign);

  /// No description provided for @transit_transitInHouse.
  ///
  /// In en, this message translates to:
  /// **'Transit in House {house}'**
  String transit_transitInHouse(Object house);

  /// No description provided for @transit_sadeSatiInfo.
  ///
  /// In en, this message translates to:
  /// **'Sade Sati Info'**
  String get transit_sadeSatiInfo;

  /// No description provided for @transit_phase.
  ///
  /// In en, this message translates to:
  /// **'Phase {phase}'**
  String transit_phase(Object phase);

  /// No description provided for @transit_timeLeft.
  ///
  /// In en, this message translates to:
  /// **'{years}y {months}m left'**
  String transit_timeLeft(Object months, Object years);

  /// No description provided for @transit_phaseDescription.
  ///
  /// In en, this message translates to:
  /// **'{phase} • Saturn transiting {sign}'**
  String transit_phaseDescription(Object phase, Object sign);

  /// No description provided for @transit_start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get transit_start;

  /// No description provided for @transit_end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get transit_end;

  /// No description provided for @transit_currentSky_value.
  ///
  /// In en, this message translates to:
  /// **'Live Planetary Positions'**
  String get transit_currentSky_value;

  /// No description provided for @transit_currentSky_desc.
  ///
  /// In en, this message translates to:
  /// **'These are the real-time positions of planets in the zodiac right now. The \'Current\' column shows where each planet is today, while \'Natal\' shows where it was at your birth. When these align or form aspects, significant transits occur.'**
  String get transit_currentSky_desc;

  /// No description provided for @transit_currentSky_significance.
  ///
  /// In en, this message translates to:
  /// **'Comparing current positions to your natal chart reveals active transits. Pay special attention to slow-moving planets (Saturn, Jupiter, Rahu, Ketu) as their transits have longer-lasting effects.'**
  String get transit_currentSky_significance;

  /// No description provided for @transit_currentSky_keypoint1.
  ///
  /// In en, this message translates to:
  /// **'Sun/Moon: Quick transits, daily/monthly influences'**
  String get transit_currentSky_keypoint1;

  /// No description provided for @transit_currentSky_keypoint2.
  ///
  /// In en, this message translates to:
  /// **'Mercury/Venus/Mars: Medium-speed, weeks to months'**
  String get transit_currentSky_keypoint2;

  /// No description provided for @transit_currentSky_keypoint3.
  ///
  /// In en, this message translates to:
  /// **'Jupiter: ~1 year per sign, major life themes'**
  String get transit_currentSky_keypoint3;

  /// No description provided for @transit_currentSky_keypoint4.
  ///
  /// In en, this message translates to:
  /// **'Saturn: ~2.5 years per sign, karmic lessons'**
  String get transit_currentSky_keypoint4;

  /// No description provided for @transit_currentSky_keypoint5.
  ///
  /// In en, this message translates to:
  /// **'Rahu/Ketu: ~1.5 years per sign, destiny points'**
  String get transit_currentSky_keypoint5;

  /// No description provided for @transit_currentSky_keypoint6.
  ///
  /// In en, this message translates to:
  /// **'Retrograde (℞): Planet appears to move backward, intensified effects'**
  String get transit_currentSky_keypoint6;

  /// No description provided for @transit_currentSky_keypoint7.
  ///
  /// In en, this message translates to:
  /// **'Sign Change (↔): Planet entering new sign, shift in energy'**
  String get transit_currentSky_keypoint7;

  /// No description provided for @transit_insight_favorable_position.
  ///
  /// In en, this message translates to:
  /// **'This is a favorable position.'**
  String get transit_insight_favorable_position;

  /// No description provided for @transit_insight_attention_position.
  ///
  /// In en, this message translates to:
  /// **'This position requires attention.'**
  String get transit_insight_attention_position;

  /// No description provided for @transit_insight_supports_growth.
  ///
  /// In en, this message translates to:
  /// **'supports growth and positive developments'**
  String get transit_insight_supports_growth;

  /// No description provided for @transit_insight_requires_patience.
  ///
  /// In en, this message translates to:
  /// **'may bring challenges that require patience and careful handling'**
  String get transit_insight_requires_patience;

  /// No description provided for @transit_status_label.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get transit_status_label;

  /// No description provided for @transit_aspectToNatal.
  ///
  /// In en, this message translates to:
  /// **'Aspect to Natal'**
  String get transit_aspectToNatal;

  /// No description provided for @transit_movesSlow.
  ///
  /// In en, this message translates to:
  /// **'moves slowly'**
  String get transit_movesSlow;

  /// No description provided for @transit_effectsLast.
  ///
  /// In en, this message translates to:
  /// **'effects last'**
  String get transit_effectsLast;

  /// No description provided for @transit_years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get transit_years;

  /// No description provided for @transit_year.
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get transit_year;

  /// No description provided for @transit_perSign.
  ///
  /// In en, this message translates to:
  /// **'per sign'**
  String get transit_perSign;

  /// No description provided for @transit_sign_label.
  ///
  /// In en, this message translates to:
  /// **'Sign'**
  String get transit_sign_label;

  /// No description provided for @transit_planet_label.
  ///
  /// In en, this message translates to:
  /// **'Planet'**
  String get transit_planet_label;

  /// No description provided for @transit_degree_label.
  ///
  /// In en, this message translates to:
  /// **'Degree'**
  String get transit_degree_label;

  /// No description provided for @yogas_nav_overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get yogas_nav_overview;

  /// No description provided for @yogas_nav_yogas.
  ///
  /// In en, this message translates to:
  /// **'Yogas'**
  String get yogas_nav_yogas;

  /// No description provided for @yogas_nav_doshas.
  ///
  /// In en, this message translates to:
  /// **'Doshas'**
  String get yogas_nav_doshas;

  /// No description provided for @yogas_nav_insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get yogas_nav_insights;

  /// No description provided for @yogas_balance_excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get yogas_balance_excellent;

  /// No description provided for @yogas_balance_veryFavorable.
  ///
  /// In en, this message translates to:
  /// **'Very Favorable'**
  String get yogas_balance_veryFavorable;

  /// No description provided for @yogas_balance_favorable.
  ///
  /// In en, this message translates to:
  /// **'Favorable'**
  String get yogas_balance_favorable;

  /// No description provided for @yogas_balance_mixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get yogas_balance_mixed;

  /// No description provided for @yogas_balance_challenging.
  ///
  /// In en, this message translates to:
  /// **'Challenging'**
  String get yogas_balance_challenging;

  /// No description provided for @yogas_balance_veryGood.
  ///
  /// In en, this message translates to:
  /// **'Very Good'**
  String get yogas_balance_veryGood;

  /// No description provided for @yogas_balance_good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get yogas_balance_good;

  /// No description provided for @yogas_balance_needsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs Attention'**
  String get yogas_balance_needsAttention;

  /// No description provided for @yogas_overview_title.
  ///
  /// In en, this message translates to:
  /// **'Yoga Overview'**
  String get yogas_overview_title;

  /// No description provided for @yogas_auspiciousYogas.
  ///
  /// In en, this message translates to:
  /// **'Auspicious Yogas'**
  String get yogas_auspiciousYogas;

  /// No description provided for @yogas_beneficialCombinations.
  ///
  /// In en, this message translates to:
  /// **'{count} beneficial combinations'**
  String yogas_beneficialCombinations(Object count);

  /// No description provided for @yogas_doshasPresent.
  ///
  /// In en, this message translates to:
  /// **'Doshas Present'**
  String get yogas_doshasPresent;

  /// No description provided for @yogas_detected.
  ///
  /// In en, this message translates to:
  /// **'{count} detected'**
  String yogas_detected(Object count);

  /// No description provided for @yogas_astrologicalInsights.
  ///
  /// In en, this message translates to:
  /// **'Astrological Insights'**
  String get yogas_astrologicalInsights;

  /// No description provided for @yogas_understandingYourChart.
  ///
  /// In en, this message translates to:
  /// **'Understanding your chart'**
  String get yogas_understandingYourChart;

  /// No description provided for @yogas_noYogasDetected.
  ///
  /// In en, this message translates to:
  /// **'No Yogas Detected'**
  String get yogas_noYogasDetected;

  /// No description provided for @yogas_noYogasMessage.
  ///
  /// In en, this message translates to:
  /// **'Standard chart configuration without special combinations.'**
  String get yogas_noYogasMessage;

  /// No description provided for @yogas_noDoshasFound.
  ///
  /// In en, this message translates to:
  /// **'No Doshas Found'**
  String get yogas_noDoshasFound;

  /// No description provided for @yogas_noDoshasMessage.
  ///
  /// In en, this message translates to:
  /// **'Your chart is free from major doshas.'**
  String get yogas_noDoshasMessage;

  /// No description provided for @yogas_yogas.
  ///
  /// In en, this message translates to:
  /// **'Yogas'**
  String get yogas_yogas;

  /// No description provided for @yogas_doshas.
  ///
  /// In en, this message translates to:
  /// **'Doshas'**
  String get yogas_doshas;

  /// No description provided for @yogas_strong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get yogas_strong;

  /// No description provided for @yogas_moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get yogas_moderate;

  /// No description provided for @yogas_severe.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get yogas_severe;

  /// No description provided for @yogas_mild.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get yogas_mild;

  /// No description provided for @yogas_low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get yogas_low;

  /// No description provided for @yogas_high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get yogas_high;

  /// No description provided for @yogas_type_raja.
  ///
  /// In en, this message translates to:
  /// **'Raja'**
  String get yogas_type_raja;

  /// No description provided for @yogas_type_dhana.
  ///
  /// In en, this message translates to:
  /// **'Dhana'**
  String get yogas_type_dhana;

  /// No description provided for @yogas_type_mahapurusha.
  ///
  /// In en, this message translates to:
  /// **'Mahapurusha'**
  String get yogas_type_mahapurusha;

  /// No description provided for @yogas_type_lunar.
  ///
  /// In en, this message translates to:
  /// **'Lunar'**
  String get yogas_type_lunar;

  /// No description provided for @yogas_type_yoga.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get yogas_type_yoga;

  /// No description provided for @yogas_type_dosha.
  ///
  /// In en, this message translates to:
  /// **'Dosha'**
  String get yogas_type_dosha;

  /// No description provided for @yogas_formation.
  ///
  /// In en, this message translates to:
  /// **'Formation'**
  String get yogas_formation;

  /// No description provided for @yogas_planetsInvolved.
  ///
  /// In en, this message translates to:
  /// **'Planets Involved'**
  String get yogas_planetsInvolved;

  /// No description provided for @yogas_whatIs.
  ///
  /// In en, this message translates to:
  /// **'What is {name}?'**
  String yogas_whatIs(Object name);

  /// No description provided for @yogas_potentialEffects.
  ///
  /// In en, this message translates to:
  /// **'Potential Effects'**
  String get yogas_potentialEffects;

  /// No description provided for @yogas_benefits.
  ///
  /// In en, this message translates to:
  /// **'Benefits'**
  String get yogas_benefits;

  /// No description provided for @yogas_remedies.
  ///
  /// In en, this message translates to:
  /// **'Remedies'**
  String get yogas_remedies;

  /// No description provided for @yogas_howToStrengthen.
  ///
  /// In en, this message translates to:
  /// **'How to Strengthen'**
  String get yogas_howToStrengthen;

  /// No description provided for @yogas_insight_understanding.
  ///
  /// In en, this message translates to:
  /// **'Understanding'**
  String get yogas_insight_understanding;

  /// No description provided for @yogas_insight_activation.
  ///
  /// In en, this message translates to:
  /// **'Activation'**
  String get yogas_insight_activation;

  /// No description provided for @yogas_insight_strength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get yogas_insight_strength;

  /// No description provided for @yogas_insight_remedies.
  ///
  /// In en, this message translates to:
  /// **'Remedies'**
  String get yogas_insight_remedies;

  /// No description provided for @yogas_insight_understanding_desc.
  ///
  /// In en, this message translates to:
  /// **'Yogas are beneficial combinations that enhance life areas.'**
  String get yogas_insight_understanding_desc;

  /// No description provided for @yogas_insight_activation_desc.
  ///
  /// In en, this message translates to:
  /// **'Yogas manifest during their planetary Dasha periods.'**
  String get yogas_insight_activation_desc;

  /// No description provided for @yogas_insight_strength_desc.
  ///
  /// In en, this message translates to:
  /// **'Planet placement determines yoga manifestation level.'**
  String get yogas_insight_strength_desc;

  /// No description provided for @yogas_insight_remedies_desc.
  ///
  /// In en, this message translates to:
  /// **'Most doshas can be mitigated through proper remedies.'**
  String get yogas_insight_remedies_desc;

  /// No description provided for @yogas_kaalSarpRemedy.
  ///
  /// In en, this message translates to:
  /// **'Kaal Sarp Remedy'**
  String get yogas_kaalSarpRemedy;

  /// No description provided for @yogas_kaalSarpRemedy_desc.
  ///
  /// In en, this message translates to:
  /// **'Trimbakeshwar Puja recommended. Chant Maha Mrityunjaya Mantra 108 times daily.'**
  String get yogas_kaalSarpRemedy_desc;

  /// No description provided for @yogas_manglikRemedy.
  ///
  /// In en, this message translates to:
  /// **'Manglik Remedy'**
  String get yogas_manglikRemedy;

  /// No description provided for @yogas_manglikRemedy_desc.
  ///
  /// In en, this message translates to:
  /// **'Perform Mangal Shanti Puja. Recite Hanuman Chalisa on Tuesdays.'**
  String get yogas_manglikRemedy_desc;

  /// No description provided for @yogas_doshaRemedy.
  ///
  /// In en, this message translates to:
  /// **'Dosha Remedy'**
  String get yogas_doshaRemedy;

  /// No description provided for @yogas_noSpecialYogas.
  ///
  /// In en, this message translates to:
  /// **'No Special Yogas'**
  String get yogas_noSpecialYogas;

  /// No description provided for @yogas_doshaFreeChart.
  ///
  /// In en, this message translates to:
  /// **'Dosha-Free Chart'**
  String get yogas_doshaFreeChart;

  /// No description provided for @yogas_overview_insight_title.
  ///
  /// In en, this message translates to:
  /// **'Yoga & Dosha Overview'**
  String get yogas_overview_insight_title;

  /// No description provided for @yogas_overview_insight_desc.
  ///
  /// In en, this message translates to:
  /// **'Yogas are auspicious planetary combinations that bestow specific benefits, while Doshas are challenging combinations that may create obstacles. The balance between them shapes your life experiences and opportunities.'**
  String get yogas_overview_insight_desc;

  /// No description provided for @yogas_overview_insight_significance.
  ///
  /// In en, this message translates to:
  /// **'Your chart has {yogaCount} yoga(s) and {doshaCount} dosha(s). {strongYogas} yoga(s) are strong, and {severeDoshas} dosha(s) are severe. With {ascendant} Lagna, the overall balance is {balanceStatus}.'**
  String yogas_overview_insight_significance(
    Object ascendant,
    Object balanceStatus,
    Object doshaCount,
    Object severeDoshas,
    Object strongYogas,
    Object yogaCount,
  );

  /// No description provided for @yogas_overview_insight_keypoint1.
  ///
  /// In en, this message translates to:
  /// **'Total Yogas: {count} (Strong: {strong})'**
  String yogas_overview_insight_keypoint1(Object count, Object strong);

  /// No description provided for @yogas_overview_insight_keypoint2.
  ///
  /// In en, this message translates to:
  /// **'Total Doshas: {count} (Severe: {severe})'**
  String yogas_overview_insight_keypoint2(Object count, Object severe);

  /// No description provided for @yogas_overview_insight_keypoint3.
  ///
  /// In en, this message translates to:
  /// **'Ascendant: {ascendant}'**
  String yogas_overview_insight_keypoint3(Object ascendant);

  /// No description provided for @yogas_overview_insight_keypoint4.
  ///
  /// In en, this message translates to:
  /// **'Overall Balance: {balance}'**
  String yogas_overview_insight_keypoint4(Object balance);

  /// No description provided for @yogas_overview_insight_keypoint5.
  ///
  /// In en, this message translates to:
  /// **'Yogas manifest during their planetary Dasha periods'**
  String get yogas_overview_insight_keypoint5;

  /// No description provided for @yogas_overview_insight_keypoint6.
  ///
  /// In en, this message translates to:
  /// **'Most doshas can be mitigated through proper remedies'**
  String get yogas_overview_insight_keypoint6;

  /// No description provided for @yogas_typeInsight_rajaYoga_desc.
  ///
  /// In en, this message translates to:
  /// **'Raja Yogas are the most powerful combinations that bestow kingship, authority, power, and success. They are formed by the association of lords of Kendra (1, 4, 7, 10) and Trikona (1, 5, 9) houses.'**
  String get yogas_typeInsight_rajaYoga_desc;

  /// No description provided for @yogas_typeInsight_rajaYoga_significance.
  ///
  /// In en, this message translates to:
  /// **'Success in career, rise to power, leadership, authority, fame'**
  String get yogas_typeInsight_rajaYoga_significance;

  /// No description provided for @yogas_typeInsight_dhanaYoga_desc.
  ///
  /// In en, this message translates to:
  /// **'Dhana Yogas indicate wealth and prosperity. They are formed by the association of lords of wealth houses (2, 5, 9, 11) with each other or with benefics.'**
  String get yogas_typeInsight_dhanaYoga_desc;

  /// No description provided for @yogas_typeInsight_dhanaYoga_significance.
  ///
  /// In en, this message translates to:
  /// **'Financial prosperity, accumulation of wealth, material success'**
  String get yogas_typeInsight_dhanaYoga_significance;

  /// No description provided for @yogas_typeInsight_mahapurusha_desc.
  ///
  /// In en, this message translates to:
  /// **'These are five great yogas formed when Mars, Mercury, Jupiter, Venus, or Saturn are in their own or exaltation sign in a Kendra house. They create exceptional individuals.'**
  String get yogas_typeInsight_mahapurusha_desc;

  /// No description provided for @yogas_typeInsight_mahapurusha_significance.
  ///
  /// In en, this message translates to:
  /// **'Outstanding personality, exceptional achievements, leadership in specific domains'**
  String get yogas_typeInsight_mahapurusha_significance;

  /// No description provided for @yogas_typeInsight_lunarYoga_desc.
  ///
  /// In en, this message translates to:
  /// **'Lunar Yogas are formed based on the Moon\'s relationship with other planets. They primarily affect the mind, emotions, and mental abilities.'**
  String get yogas_typeInsight_lunarYoga_desc;

  /// No description provided for @yogas_typeInsight_lunarYoga_significance.
  ///
  /// In en, this message translates to:
  /// **'Mental strength, emotional stability, intuition, memory'**
  String get yogas_typeInsight_lunarYoga_significance;

  /// No description provided for @yogas_typeInsight_severeDosha_desc.
  ///
  /// In en, this message translates to:
  /// **'Severe doshas require immediate attention and remedial measures. They can significantly impact the areas they govern.'**
  String get yogas_typeInsight_severeDosha_desc;

  /// No description provided for @yogas_typeInsight_severeDosha_significance.
  ///
  /// In en, this message translates to:
  /// **'May cause significant challenges in specific life areas'**
  String get yogas_typeInsight_severeDosha_significance;

  /// No description provided for @yogas_typeInsight_moderateDosha_desc.
  ///
  /// In en, this message translates to:
  /// **'Moderate doshas have noticeable effects but are manageable with proper awareness and remedies.'**
  String get yogas_typeInsight_moderateDosha_desc;

  /// No description provided for @yogas_typeInsight_moderateDosha_significance.
  ///
  /// In en, this message translates to:
  /// **'Some challenges that can be overcome with effort'**
  String get yogas_typeInsight_moderateDosha_significance;

  /// No description provided for @yogas_typeInsight_mildDosha_desc.
  ///
  /// In en, this message translates to:
  /// **'Low severity doshas have minimal impact and may not require intensive remedial measures.'**
  String get yogas_typeInsight_mildDosha_desc;

  /// No description provided for @yogas_typeInsight_mildDosha_significance.
  ///
  /// In en, this message translates to:
  /// **'Minor influences that are easily managed'**
  String get yogas_typeInsight_mildDosha_significance;

  /// No description provided for @yogas_strengthInsight_strong_desc.
  ///
  /// In en, this message translates to:
  /// **'Strong yogas are fully activated and manifest their effects clearly in life. The planets involved are well-placed, dignified, and free from afflictions.'**
  String get yogas_strengthInsight_strong_desc;

  /// No description provided for @yogas_strengthInsight_moderate_desc.
  ///
  /// In en, this message translates to:
  /// **'Moderate strength indicates partial manifestation. The yoga is present but planets may have mixed dignity or receive both benefic and malefic influences.'**
  String get yogas_strengthInsight_moderate_desc;

  /// No description provided for @yogas_strengthInsight_severe_desc.
  ///
  /// In en, this message translates to:
  /// **'Severe doshas have strong impact and require attention. Remedial measures are recommended to mitigate their effects.'**
  String get yogas_strengthInsight_severe_desc;

  /// No description provided for @yogas_insightCard_understanding_desc.
  ///
  /// In en, this message translates to:
  /// **'Yogas are beneficial planetary combinations formed by specific relationships between planets and houses. They indicate areas of life where you have special potential or blessings.'**
  String get yogas_insightCard_understanding_desc;

  /// No description provided for @yogas_insightCard_understanding_significance.
  ///
  /// In en, this message translates to:
  /// **'Understanding your yogas helps you recognize your strengths and work with your natural talents.'**
  String get yogas_insightCard_understanding_significance;

  /// No description provided for @yogas_insightCard_activation_desc.
  ///
  /// In en, this message translates to:
  /// **'Yogas don\'t always manifest constantly—they activate during the Dasha (planetary period) of the planets involved. The Dasha system in Vedic astrology determines when each yoga will give its results.'**
  String get yogas_insightCard_activation_desc;

  /// No description provided for @yogas_insightCard_activation_significance.
  ///
  /// In en, this message translates to:
  /// **'Knowing when your yogas activate helps in timing important life decisions.'**
  String get yogas_insightCard_activation_significance;

  /// No description provided for @yogas_insightCard_strength_desc.
  ///
  /// In en, this message translates to:
  /// **'The strength of a yoga depends on the dignity of planets involved (own sign, exaltation, debilitation), aspects from benefics or malefics, and placement in houses.'**
  String get yogas_insightCard_strength_desc;

  /// No description provided for @yogas_insightCard_strength_significance.
  ///
  /// In en, this message translates to:
  /// **'Strong yogas manifest clearly while weak ones need strengthening through remedies.'**
  String get yogas_insightCard_strength_significance;

  /// No description provided for @yogas_insightCard_remedies_desc.
  ///
  /// In en, this message translates to:
  /// **'Doshas can be mitigated through various remedies including mantras, gemstones, charity, fasting, and pujas. The right remedy depends on the specific dosha and your chart.'**
  String get yogas_insightCard_remedies_desc;

  /// No description provided for @yogas_insightCard_remedies_significance.
  ///
  /// In en, this message translates to:
  /// **'Proper remedies performed with faith can significantly reduce dosha effects.'**
  String get yogas_insightCard_remedies_significance;

  /// No description provided for @yogas_emptyState_noYogas_desc.
  ///
  /// In en, this message translates to:
  /// **'Your chart does not have any of the commonly recognized special yogas. This is normal and doesn\'t mean anything negative—many successful people have charts without named yogas. The strength of your chart comes from other factors like planet dignity, house placements, and aspects.'**
  String get yogas_emptyState_noYogas_desc;

  /// No description provided for @yogas_emptyState_noDoshas_desc.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! Your chart is free from major doshas like Manglik, Kaal Sarp, or other challenging combinations. This indicates fewer karmic obstacles in the areas typically affected by these doshas.'**
  String get yogas_emptyState_noDoshas_desc;

  /// No description provided for @yogas_kaalSarpDosha_desc.
  ///
  /// In en, this message translates to:
  /// **'Kaal Sarp Dosha occurs when all planets are hemmed between Rahu and Ketu. This can cause delays, obstacles, and sudden changes in life. However, with proper remedies, its effects can be significantly reduced.'**
  String get yogas_kaalSarpDosha_desc;

  /// No description provided for @yogas_manglikDosha_desc.
  ///
  /// In en, this message translates to:
  /// **'Manglik Dosha occurs when Mars is placed in the 1st, 4th, 7th, 8th, or 12th house from the Ascendant. It primarily affects marriage and relationships but can be effectively remedied.'**
  String get yogas_manglikDosha_desc;

  /// No description provided for @charDasha_nav_current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get charDasha_nav_current;

  /// No description provided for @charDasha_nav_karakas.
  ///
  /// In en, this message translates to:
  /// **'Karakas'**
  String get charDasha_nav_karakas;

  /// No description provided for @charDasha_nav_timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get charDasha_nav_timeline;

  /// No description provided for @charDasha_activeRasiDasha.
  ///
  /// In en, this message translates to:
  /// **'Active Rasi Dasha'**
  String get charDasha_activeRasiDasha;

  /// No description provided for @charDasha_jaiminiKarakas.
  ///
  /// In en, this message translates to:
  /// **'Jaimini Karakas'**
  String get charDasha_jaiminiKarakas;

  /// No description provided for @charDasha_rasiDashaTimeline.
  ///
  /// In en, this message translates to:
  /// **'Rasi Dasha Timeline'**
  String get charDasha_rasiDashaTimeline;

  /// No description provided for @charDasha_infoFooter.
  ///
  /// In en, this message translates to:
  /// **'Char Dasha (Jaimini) is a sign-based system. Duration varies based on the lord\'s position.'**
  String get charDasha_infoFooter;

  /// No description provided for @charDasha_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Char Dasha Unavailable'**
  String get charDasha_unavailable;

  /// No description provided for @charDasha_unableToCalculate.
  ///
  /// In en, this message translates to:
  /// **'Unable to calculate Char Dasha for this chart.'**
  String get charDasha_unableToCalculate;

  /// No description provided for @charDasha_active.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get charDasha_active;

  /// No description provided for @charDasha_rasiDasha.
  ///
  /// In en, this message translates to:
  /// **'Rasi Dasha'**
  String get charDasha_rasiDasha;

  /// No description provided for @charDasha_signRasiDasha.
  ///
  /// In en, this message translates to:
  /// **'{sign} Rasi Dasha'**
  String charDasha_signRasiDasha(Object sign);

  /// No description provided for @charDasha_journeyProgress.
  ///
  /// In en, this message translates to:
  /// **'Journey Progress'**
  String get charDasha_journeyProgress;

  /// No description provided for @charDasha_remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get charDasha_remaining;

  /// No description provided for @charDasha_duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get charDasha_duration;

  /// No description provided for @charDasha_cycles.
  ///
  /// In en, this message translates to:
  /// **'Cycles'**
  String get charDasha_cycles;

  /// No description provided for @charDasha_yearsAbbr.
  ///
  /// In en, this message translates to:
  /// **'{years} yrs'**
  String charDasha_yearsAbbr(Object years);

  /// No description provided for @charDasha_antardasha.
  ///
  /// In en, this message translates to:
  /// **'Antardasha'**
  String get charDasha_antardasha;

  /// No description provided for @charDasha_left.
  ///
  /// In en, this message translates to:
  /// **'{duration} left'**
  String charDasha_left(Object duration);

  /// No description provided for @charDasha_dashaDirection.
  ///
  /// In en, this message translates to:
  /// **'Dasha Direction'**
  String get charDasha_dashaDirection;

  /// No description provided for @charDasha_clockwise.
  ///
  /// In en, this message translates to:
  /// **'Clockwise'**
  String get charDasha_clockwise;

  /// No description provided for @charDasha_antiClockwise.
  ///
  /// In en, this message translates to:
  /// **'Anti-clockwise'**
  String get charDasha_antiClockwise;

  /// No description provided for @charDasha_fromSign.
  ///
  /// In en, this message translates to:
  /// **'from {sign}'**
  String charDasha_fromSign(Object sign);

  /// No description provided for @charDasha_karaka_ak.
  ///
  /// In en, this message translates to:
  /// **'AK'**
  String get charDasha_karaka_ak;

  /// No description provided for @charDasha_karaka_amk.
  ///
  /// In en, this message translates to:
  /// **'AmK'**
  String get charDasha_karaka_amk;

  /// No description provided for @charDasha_karaka_bk.
  ///
  /// In en, this message translates to:
  /// **'BK'**
  String get charDasha_karaka_bk;

  /// No description provided for @charDasha_karaka_mk.
  ///
  /// In en, this message translates to:
  /// **'MK'**
  String get charDasha_karaka_mk;

  /// No description provided for @charDasha_karaka_pik.
  ///
  /// In en, this message translates to:
  /// **'PiK'**
  String get charDasha_karaka_pik;

  /// No description provided for @charDasha_karaka_puk.
  ///
  /// In en, this message translates to:
  /// **'PuK'**
  String get charDasha_karaka_puk;

  /// No description provided for @charDasha_karaka_gk.
  ///
  /// In en, this message translates to:
  /// **'GK'**
  String get charDasha_karaka_gk;

  /// No description provided for @charDasha_karaka_dk.
  ///
  /// In en, this message translates to:
  /// **'DK'**
  String get charDasha_karaka_dk;

  /// No description provided for @charDasha_karaka_atmakaraka.
  ///
  /// In en, this message translates to:
  /// **'Atmakaraka'**
  String get charDasha_karaka_atmakaraka;

  /// No description provided for @charDasha_karaka_amatyakaraka.
  ///
  /// In en, this message translates to:
  /// **'Amatyakaraka'**
  String get charDasha_karaka_amatyakaraka;

  /// No description provided for @charDasha_karaka_bhratrikaraka.
  ///
  /// In en, this message translates to:
  /// **'Bhratrikaraka'**
  String get charDasha_karaka_bhratrikaraka;

  /// No description provided for @charDasha_karaka_matrikaraka.
  ///
  /// In en, this message translates to:
  /// **'Matrikaraka'**
  String get charDasha_karaka_matrikaraka;

  /// No description provided for @charDasha_karaka_pitrikaraka.
  ///
  /// In en, this message translates to:
  /// **'Pitrikaraka'**
  String get charDasha_karaka_pitrikaraka;

  /// No description provided for @charDasha_karaka_putrakaraka.
  ///
  /// In en, this message translates to:
  /// **'Putrakaraka'**
  String get charDasha_karaka_putrakaraka;

  /// No description provided for @charDasha_karaka_gnatikaraka.
  ///
  /// In en, this message translates to:
  /// **'Gnatikaraka'**
  String get charDasha_karaka_gnatikaraka;

  /// No description provided for @charDasha_karaka_darakaraka.
  ///
  /// In en, this message translates to:
  /// **'Darakaraka'**
  String get charDasha_karaka_darakaraka;

  /// No description provided for @charDasha_karakamsa.
  ///
  /// In en, this message translates to:
  /// **'Karakamsa'**
  String get charDasha_karakamsa;

  /// No description provided for @charDasha_karakamsa_desc.
  ///
  /// In en, this message translates to:
  /// **'{sign} (AK in Navamsa)'**
  String charDasha_karakamsa_desc(Object sign);

  /// No description provided for @charDasha_now.
  ///
  /// In en, this message translates to:
  /// **'NOW'**
  String get charDasha_now;

  /// No description provided for @charDasha_start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get charDasha_start;

  /// No description provided for @charDasha_end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get charDasha_end;

  /// No description provided for @charDasha_subPeriods.
  ///
  /// In en, this message translates to:
  /// **'Sub-Periods ({count})'**
  String charDasha_subPeriods(Object count);

  /// No description provided for @charDasha_noSubPeriods.
  ///
  /// In en, this message translates to:
  /// **'No sub-periods available'**
  String get charDasha_noSubPeriods;

  /// No description provided for @charDasha_signDesc_aries.
  ///
  /// In en, this message translates to:
  /// **'Initiative & leadership'**
  String get charDasha_signDesc_aries;

  /// No description provided for @charDasha_signDesc_taurus.
  ///
  /// In en, this message translates to:
  /// **'Stability & comfort'**
  String get charDasha_signDesc_taurus;

  /// No description provided for @charDasha_signDesc_gemini.
  ///
  /// In en, this message translates to:
  /// **'Communication & learning'**
  String get charDasha_signDesc_gemini;

  /// No description provided for @charDasha_signDesc_cancer.
  ///
  /// In en, this message translates to:
  /// **'Emotions & nurturing'**
  String get charDasha_signDesc_cancer;

  /// No description provided for @charDasha_signDesc_leo.
  ///
  /// In en, this message translates to:
  /// **'Creativity & authority'**
  String get charDasha_signDesc_leo;

  /// No description provided for @charDasha_signDesc_virgo.
  ///
  /// In en, this message translates to:
  /// **'Service & analysis'**
  String get charDasha_signDesc_virgo;

  /// No description provided for @charDasha_signDesc_libra.
  ///
  /// In en, this message translates to:
  /// **'Partnerships & balance'**
  String get charDasha_signDesc_libra;

  /// No description provided for @charDasha_signDesc_scorpio.
  ///
  /// In en, this message translates to:
  /// **'Transformation & depth'**
  String get charDasha_signDesc_scorpio;

  /// No description provided for @charDasha_signDesc_sagittarius.
  ///
  /// In en, this message translates to:
  /// **'Expansion & wisdom'**
  String get charDasha_signDesc_sagittarius;

  /// No description provided for @charDasha_signDesc_capricorn.
  ///
  /// In en, this message translates to:
  /// **'Ambition & structure'**
  String get charDasha_signDesc_capricorn;

  /// No description provided for @charDasha_signDesc_aquarius.
  ///
  /// In en, this message translates to:
  /// **'Innovation & humanity'**
  String get charDasha_signDesc_aquarius;

  /// No description provided for @charDasha_signDesc_pisces.
  ///
  /// In en, this message translates to:
  /// **'Spirituality & intuition'**
  String get charDasha_signDesc_pisces;

  /// No description provided for @charDasha_signDesc_default.
  ///
  /// In en, this message translates to:
  /// **'Cosmic influence'**
  String get charDasha_signDesc_default;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'as',
    'bn',
    'en',
    'gu',
    'hi',
    'kn',
    'ml',
    'mr',
    'or',
    'pa',
    'ta',
    'te',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'as':
      return AppLocalizationsAs();
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'ml':
      return AppLocalizationsMl();
    case 'mr':
      return AppLocalizationsMr();
    case 'or':
      return AppLocalizationsOr();
    case 'pa':
      return AppLocalizationsPa();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
