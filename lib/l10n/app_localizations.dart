import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('hi'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Doodh Hisaab'**
  String get appTitle;

  /// No description provided for @milkIconDescription.
  ///
  /// In en, this message translates to:
  /// **'Milk drop'**
  String get milkIconDescription;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Your milk account,\nmade simple'**
  String get homeGreeting;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Keep track of daily deliveries, payments and your monthly balance — all in one place.'**
  String get welcomeMessage;

  /// No description provided for @offlineMessage.
  ///
  /// In en, this message translates to:
  /// **'Your records stay on this phone. The app works without an internet connection.'**
  String get offlineMessage;

  /// No description provided for @tabToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tabToday;

  /// No description provided for @tabCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get tabCalendar;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @tabVendors.
  ///
  /// In en, this message translates to:
  /// **'Vendors'**
  String get tabVendors;

  /// No description provided for @tabPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get tabPayments;

  /// No description provided for @tabReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get tabReports;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @addVendor.
  ///
  /// In en, this message translates to:
  /// **'Add vendor'**
  String get addVendor;

  /// No description provided for @editVendor.
  ///
  /// In en, this message translates to:
  /// **'Edit vendor'**
  String get editVendor;

  /// No description provided for @vendorName.
  ///
  /// In en, this message translates to:
  /// **'Vendor name'**
  String get vendorName;

  /// No description provided for @vendorNameHint.
  ///
  /// In en, this message translates to:
  /// **'For example, Ramesh Dairy'**
  String get vendorNameHint;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @milkType.
  ///
  /// In en, this message translates to:
  /// **'Milk type'**
  String get milkType;

  /// No description provided for @cowMilk.
  ///
  /// In en, this message translates to:
  /// **'Cow'**
  String get cowMilk;

  /// No description provided for @buffaloMilk.
  ///
  /// In en, this message translates to:
  /// **'Buffalo'**
  String get buffaloMilk;

  /// No description provided for @mixedMilk.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get mixedMilk;

  /// No description provided for @otherMilk.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherMilk;

  /// No description provided for @defaultQuantity.
  ///
  /// In en, this message translates to:
  /// **'Default daily quantity'**
  String get defaultQuantity;

  /// No description provided for @ratePerLitre.
  ///
  /// In en, this message translates to:
  /// **'Rate per litre'**
  String get ratePerLitre;

  /// No description provided for @openingBalance.
  ///
  /// In en, this message translates to:
  /// **'Opening balance'**
  String get openingBalance;

  /// No description provided for @deliveryTime.
  ///
  /// In en, this message translates to:
  /// **'Delivery time'**
  String get deliveryTime;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @exitApp.
  ///
  /// In en, this message translates to:
  /// **'Close app'**
  String get exitApp;

  /// No description provided for @exitAppQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close the app?'**
  String get exitAppQuestion;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @archiveVendor.
  ///
  /// In en, this message translates to:
  /// **'Archive vendor'**
  String get archiveVendor;

  /// No description provided for @archiveVendorQuestion.
  ///
  /// In en, this message translates to:
  /// **'Archive {vendorName}? Their history will be kept.'**
  String archiveVendorQuestion(Object vendorName);

  /// No description provided for @deleteVendor.
  ///
  /// In en, this message translates to:
  /// **'Delete vendor'**
  String get deleteVendor;

  /// No description provided for @deleteVendorQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete {vendorName}? All vendor details and history will be deleted.'**
  String deleteVendorQuestion(Object vendorName);

  /// No description provided for @vendorSaved.
  ///
  /// In en, this message translates to:
  /// **'Vendor saved'**
  String get vendorSaved;

  /// No description provided for @vendorArchived.
  ///
  /// In en, this message translates to:
  /// **'Vendor archived'**
  String get vendorArchived;

  /// No description provided for @vendorDeleted.
  ///
  /// In en, this message translates to:
  /// **'Vendor deleted'**
  String get vendorDeleted;

  /// No description provided for @vendorDetails.
  ///
  /// In en, this message translates to:
  /// **'Vendor details'**
  String get vendorDetails;

  /// No description provided for @rateHistory.
  ///
  /// In en, this message translates to:
  /// **'Rate history'**
  String get rateHistory;

  /// No description provided for @changeRate.
  ///
  /// In en, this message translates to:
  /// **'Change rate'**
  String get changeRate;

  /// No description provided for @effectiveFrom.
  ///
  /// In en, this message translates to:
  /// **'Effective from'**
  String get effectiveFrom;

  /// No description provided for @rateSaved.
  ///
  /// In en, this message translates to:
  /// **'Rate saved'**
  String get rateSaved;

  /// No description provided for @noRateHistory.
  ///
  /// In en, this message translates to:
  /// **'No rates have been added yet.'**
  String get noRateHistory;

  /// No description provided for @noVendors.
  ///
  /// In en, this message translates to:
  /// **'No milk vendors yet'**
  String get noVendors;

  /// No description provided for @addFirstVendor.
  ///
  /// In en, this message translates to:
  /// **'Add your milk vendor to get started.'**
  String get addFirstVendor;

  /// No description provided for @callVendor.
  ///
  /// In en, this message translates to:
  /// **'Call vendor'**
  String get callVendor;

  /// No description provided for @messageVendor.
  ///
  /// In en, this message translates to:
  /// **'Message on WhatsApp'**
  String get messageVendor;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Milk delivered'**
  String get delivered;

  /// No description provided for @skipped.
  ///
  /// In en, this message translates to:
  /// **'No delivery'**
  String get skipped;

  /// No description provided for @customQuantity.
  ///
  /// In en, this message translates to:
  /// **'Custom quantity'**
  String get customQuantity;

  /// No description provided for @markDelivered.
  ///
  /// In en, this message translates to:
  /// **'Milk came'**
  String get markDelivered;

  /// No description provided for @markSkipped.
  ///
  /// In en, this message translates to:
  /// **'No milk'**
  String get markSkipped;

  /// No description provided for @changeQuantity.
  ///
  /// In en, this message translates to:
  /// **'Change quantity'**
  String get changeQuantity;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @entrySaved.
  ///
  /// In en, this message translates to:
  /// **'Today\'s entry saved'**
  String get entrySaved;

  /// No description provided for @entryUndone.
  ///
  /// In en, this message translates to:
  /// **'Change undone'**
  String get entryUndone;

  /// No description provided for @deleteEntryQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete this day\'s milk entry?'**
  String get deleteEntryQuestion;

  /// No description provided for @entryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted'**
  String get entryDeleted;

  /// No description provided for @currentMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get currentMonth;

  /// No description provided for @totalLitres.
  ///
  /// In en, this message translates to:
  /// **'Total milk'**
  String get totalLitres;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Milk amount'**
  String get totalAmount;

  /// No description provided for @deliveredDays.
  ///
  /// In en, this message translates to:
  /// **'Delivery days'**
  String get deliveredDays;

  /// No description provided for @skippedDays.
  ///
  /// In en, this message translates to:
  /// **'Skipped days'**
  String get skippedDays;

  /// No description provided for @unmarked.
  ///
  /// In en, this message translates to:
  /// **'Not marked'**
  String get unmarked;

  /// No description provided for @markUnmarked.
  ///
  /// In en, this message translates to:
  /// **'Mark unmarked days as delivered'**
  String get markUnmarked;

  /// No description provided for @bulkEntry.
  ///
  /// In en, this message translates to:
  /// **'Bulk entry'**
  String get bulkEntry;

  /// No description provided for @backdateEntry.
  ///
  /// In en, this message translates to:
  /// **'Add past entry'**
  String get backdateEntry;

  /// No description provided for @bulkMarkQuestion.
  ///
  /// In en, this message translates to:
  /// **'Add the default daily amount to all unmarked days in the selected date range?'**
  String get bulkMarkQuestion;

  /// No description provided for @bulkEntryMissingRate.
  ///
  /// In en, this message translates to:
  /// **'A milk rate is missing for one or more dates. Add rates covering the full date range, then try again.'**
  String get bulkEntryMissingRate;

  /// No description provided for @bulkMarkDone.
  ///
  /// In en, this message translates to:
  /// **'{count} days marked'**
  String bulkMarkDone(int count);

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @paymentsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Paid this month'**
  String get paymentsThisMonth;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance due'**
  String get balance;

  /// No description provided for @advance.
  ///
  /// In en, this message translates to:
  /// **'Advance'**
  String get advance;

  /// No description provided for @openingBalanceCaption.
  ///
  /// In en, this message translates to:
  /// **'Starting balance'**
  String get openingBalanceCaption;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @addPayment.
  ///
  /// In en, this message translates to:
  /// **'Add payment'**
  String get addPayment;

  /// No description provided for @paymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount paid'**
  String get paymentAmount;

  /// No description provided for @paymentDate.
  ///
  /// In en, this message translates to:
  /// **'Payment date'**
  String get paymentDate;

  /// No description provided for @paymentMode.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMode;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @upi.
  ///
  /// In en, this message translates to:
  /// **'UPI'**
  String get upi;

  /// No description provided for @bank.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get bank;

  /// No description provided for @otherPayment.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherPayment;

  /// No description provided for @paymentNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get paymentNote;

  /// No description provided for @paymentSaved.
  ///
  /// In en, this message translates to:
  /// **'Payment saved'**
  String get paymentSaved;

  /// No description provided for @paymentDeleted.
  ///
  /// In en, this message translates to:
  /// **'Payment deleted'**
  String get paymentDeleted;

  /// No description provided for @payFullBalance.
  ///
  /// In en, this message translates to:
  /// **'Pay full balance'**
  String get payFullBalance;

  /// No description provided for @advancePaymentHint.
  ///
  /// In en, this message translates to:
  /// **'Any payment above the balance will remain as an advance.'**
  String get advancePaymentHint;

  /// No description provided for @addAdvanceAmount.
  ///
  /// In en, this message translates to:
  /// **'Add {amount} as advance'**
  String addAdvanceAmount(Object amount);

  /// No description provided for @noPayments.
  ///
  /// In en, this message translates to:
  /// **'No payments recorded yet.'**
  String get noPayments;

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment history'**
  String get paymentHistory;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Monthly bill'**
  String get report;

  /// No description provided for @selectVendor.
  ///
  /// In en, this message translates to:
  /// **'Choose a vendor'**
  String get selectVendor;

  /// No description provided for @selectMonth.
  ///
  /// In en, this message translates to:
  /// **'Choose a month'**
  String get selectMonth;

  /// No description provided for @carriedForward.
  ///
  /// In en, this message translates to:
  /// **'Previous balance'**
  String get carriedForward;

  /// No description provided for @closingBalance.
  ///
  /// In en, this message translates to:
  /// **'Closing balance'**
  String get closingBalance;

  /// No description provided for @dayByDay.
  ///
  /// In en, this message translates to:
  /// **'Day-by-day details'**
  String get dayByDay;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rate;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @sharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share bill as PDF'**
  String get sharePdf;

  /// No description provided for @shareWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Share on WhatsApp'**
  String get shareWhatsApp;

  /// No description provided for @noReportData.
  ///
  /// In en, this message translates to:
  /// **'No entries for this month.'**
  String get noReportData;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get hindi;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get theme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'Use device setting'**
  String get systemTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get dailyReminder;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTime;

  /// No description provided for @enableReminder.
  ///
  /// In en, this message translates to:
  /// **'Remind me if milk is unmarked'**
  String get enableReminder;

  /// No description provided for @enablePaymentReminder.
  ///
  /// In en, this message translates to:
  /// **'Monthly payment reminder'**
  String get enablePaymentReminder;

  /// No description provided for @paymentReminderDay.
  ///
  /// In en, this message translates to:
  /// **'Remind me on day'**
  String get paymentReminderDay;

  /// No description provided for @paymentReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Milk payment reminder'**
  String get paymentReminderTitle;

  /// No description provided for @paymentReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Check your milk account and pay any amount due.'**
  String get paymentReminderBody;

  /// No description provided for @notificationPermission.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications in Android settings to receive reminders.'**
  String get notificationPermission;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Back up data'**
  String get backup;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get restore;

  /// No description provided for @automaticBackup.
  ///
  /// In en, this message translates to:
  /// **'Automatic backup'**
  String get automaticBackup;

  /// No description provided for @automaticBackupHint.
  ///
  /// In en, this message translates to:
  /// **'Saved on this phone; Android may delay it. Keeps the latest 7 copies.'**
  String get automaticBackupHint;

  /// No description provided for @automaticBackupFrequency.
  ///
  /// In en, this message translates to:
  /// **'Backup frequency'**
  String get automaticBackupFrequency;

  /// No description provided for @backupDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get backupDaily;

  /// No description provided for @backupWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get backupWeekly;

  /// No description provided for @backupMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get backupMonthly;

  /// No description provided for @automaticBackupTime.
  ///
  /// In en, this message translates to:
  /// **'Backup time'**
  String get automaticBackupTime;

  /// No description provided for @automaticBackups.
  ///
  /// In en, this message translates to:
  /// **'Restore automatic backup'**
  String get automaticBackups;

  /// No description provided for @noAutomaticBackups.
  ///
  /// In en, this message translates to:
  /// **'No automatic backups are available yet.'**
  String get noAutomaticBackups;

  /// No description provided for @selectAutomaticBackup.
  ///
  /// In en, this message translates to:
  /// **'Choose an automatic backup'**
  String get selectAutomaticBackup;

  /// No description provided for @backupCreated.
  ///
  /// In en, this message translates to:
  /// **'Backup ready to share'**
  String get backupCreated;

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup restored'**
  String get restoreSuccess;

  /// No description provided for @restoreConfirm.
  ///
  /// In en, this message translates to:
  /// **'Restoring replaces the current ledger. Continue?'**
  String get restoreConfirm;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get appLock;

  /// No description provided for @enableAppLock.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or device lock'**
  String get enableAppLock;

  /// No description provided for @lockUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No device authentication is set up.'**
  String get lockUnavailable;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About Doodh Hisaab'**
  String get about;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @monthlySpend.
  ///
  /// In en, this message translates to:
  /// **'Milk spend by month'**
  String get monthlySpend;

  /// No description provided for @monthlyLitres.
  ///
  /// In en, this message translates to:
  /// **'Milk by month'**
  String get monthlyLitres;

  /// No description provided for @spendingLastSixMonths.
  ///
  /// In en, this message translates to:
  /// **'Spending over the last 6 months'**
  String get spendingLastSixMonths;

  /// No description provided for @litresLastSixMonths.
  ///
  /// In en, this message translates to:
  /// **'Milk over the last 6 months'**
  String get litresLastSixMonths;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'A simple, clear milk account'**
  String get onboardingTitle;

  /// No description provided for @onboardingBody.
  ///
  /// In en, this message translates to:
  /// **'Record deliveries and payments. Your account stays on this phone and works offline.'**
  String get onboardingBody;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Do this later'**
  String get skip;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Please fill in this field.'**
  String get requiredField;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount.'**
  String get invalidAmount;

  /// No description provided for @invalidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid quantity.'**
  String get invalidQuantity;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorOccurred;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @reportMonth.
  ///
  /// In en, this message translates to:
  /// **'{month} {year}'**
  String reportMonth(Object month, int year);

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'An offline milk delivery ledger for your household.'**
  String get appDescription;

  /// No description provided for @litreUnit.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get litreUnit;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Milk delivery check'**
  String get reminderTitle;

  /// No description provided for @reminderBody.
  ///
  /// In en, this message translates to:
  /// **'Mark today’s milk delivery in your ledger.'**
  String get reminderBody;

  /// No description provided for @reminderChannel.
  ///
  /// In en, this message translates to:
  /// **'Milk ledger reminders'**
  String get reminderChannel;

  /// No description provided for @reminderChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'A daily reminder to update today’s milk entry.'**
  String get reminderChannelDescription;

  /// No description provided for @authReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock Doodh Hisaab'**
  String get authReason;

  /// No description provided for @backupUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Backup could not be completed.'**
  String get backupUnavailable;

  /// No description provided for @deletePaymentQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete this payment?'**
  String get deletePaymentQuestion;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @appLocked.
  ///
  /// In en, this message translates to:
  /// **'Your ledger is locked.'**
  String get appLocked;

  /// No description provided for @totalDue.
  ///
  /// In en, this message translates to:
  /// **'Total due'**
  String get totalDue;

  /// No description provided for @totalAdvance.
  ///
  /// In en, this message translates to:
  /// **'Total advance'**
  String get totalAdvance;

  /// No description provided for @markAllDelivered.
  ///
  /// In en, this message translates to:
  /// **'Mark all delivered'**
  String get markAllDelivered;

  /// No description provided for @allDoneToday.
  ///
  /// In en, this message translates to:
  /// **'All done for today'**
  String get allDoneToday;

  /// No description provided for @pendingToday.
  ///
  /// In en, this message translates to:
  /// **'{count} left to mark today'**
  String pendingToday(int count);

  /// No description provided for @editTodayEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit today\'s entry'**
  String get editTodayEntry;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @printBill.
  ///
  /// In en, this message translates to:
  /// **'Print or save PDF'**
  String get printBill;

  /// No description provided for @averagePerDay.
  ///
  /// In en, this message translates to:
  /// **'Average per day'**
  String get averagePerDay;

  /// No description provided for @archivedVendors.
  ///
  /// In en, this message translates to:
  /// **'Removed vendors'**
  String get archivedVendors;

  /// No description provided for @restoreVendor.
  ///
  /// In en, this message translates to:
  /// **'Bring back'**
  String get restoreVendor;

  /// No description provided for @vendorRestored.
  ///
  /// In en, this message translates to:
  /// **'Vendor restored'**
  String get vendorRestored;

  /// No description provided for @deleteRateQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete this rate? Entries already saved keep their rate.'**
  String get deleteRateQuestion;

  /// No description provided for @cannotDeleteOnlyRate.
  ///
  /// In en, this message translates to:
  /// **'At least one rate is needed.'**
  String get cannotDeleteOnlyRate;

  /// No description provided for @rateDeleted.
  ///
  /// In en, this message translates to:
  /// **'Rate deleted'**
  String get rateDeleted;

  /// No description provided for @currentRate.
  ///
  /// In en, this message translates to:
  /// **'Current rate'**
  String get currentRate;

  /// No description provided for @generalSection.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalSection;

  /// No description provided for @remindersSection.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersSection;

  /// No description provided for @dataSection.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get dataSection;

  /// No description provided for @securitySection.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securitySection;

  /// No description provided for @quantityStep.
  ///
  /// In en, this message translates to:
  /// **'Quantity step'**
  String get quantityStep;

  /// No description provided for @quantityStepHint.
  ///
  /// In en, this message translates to:
  /// **'How much + and − change the quantity'**
  String get quantityStepHint;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @markRangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Fill many days at once'**
  String get markRangeTitle;

  /// No description provided for @markRangeDelivered.
  ///
  /// In en, this message translates to:
  /// **'Milk came on all unmarked days'**
  String get markRangeDelivered;

  /// No description provided for @markRangeSkipped.
  ///
  /// In en, this message translates to:
  /// **'No milk on unmarked days (holiday)'**
  String get markRangeSkipped;

  /// No description provided for @bulkSkipQuestion.
  ///
  /// In en, this message translates to:
  /// **'Mark all unmarked days in the selected range as no delivery?'**
  String get bulkSkipQuestion;

  /// No description provided for @billGeneratedOn.
  ///
  /// In en, this message translates to:
  /// **'Generated on {date}'**
  String billGeneratedOn(Object date);
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
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
