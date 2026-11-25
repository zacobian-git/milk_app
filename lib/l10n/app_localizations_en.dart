// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Doodh Hisaab';

  @override
  String get milkIconDescription => 'Milk drop';

  @override
  String get homeGreeting => 'Your milk account,\nmade simple';

  @override
  String get welcomeMessage =>
      'Keep track of daily deliveries, payments and your monthly balance — all in one place.';

  @override
  String get offlineMessage =>
      'Your records stay on this phone. The app works without an internet connection.';

  @override
  String get tabToday => 'Today';

  @override
  String get tabCalendar => 'Calendar';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get tabVendors => 'Vendors';

  @override
  String get tabPayments => 'Payments';

  @override
  String get tabReports => 'Reports';

  @override
  String get tabSettings => 'Settings';

  @override
  String get settings => 'Settings';

  @override
  String get addVendor => 'Add vendor';

  @override
  String get editVendor => 'Edit vendor';

  @override
  String get vendorName => 'Vendor name';

  @override
  String get vendorNameHint => 'For example, Ramesh Dairy';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get milkType => 'Milk type';

  @override
  String get cowMilk => 'Cow';

  @override
  String get buffaloMilk => 'Buffalo';

  @override
  String get mixedMilk => 'Mixed';

  @override
  String get otherMilk => 'Other';

  @override
  String get defaultQuantity => 'Default daily quantity';

  @override
  String get ratePerLitre => 'Rate per litre';

  @override
  String get openingBalance => 'Opening balance';

  @override
  String get deliveryTime => 'Delivery time';

  @override
  String get notes => 'Notes';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get archiveVendor => 'Archive vendor';

  @override
  String archiveVendorQuestion(Object vendorName) {
    return 'Archive $vendorName? Their history will be kept.';
  }

  @override
  String get deleteVendor => 'Delete vendor';

  @override
  String deleteVendorQuestion(Object vendorName) {
    return 'Remove $vendorName from your vendor list? Their milk and payment history will be kept.';
  }

  @override
  String get vendorSaved => 'Vendor saved';

  @override
  String get vendorArchived => 'Vendor archived';

  @override
  String get vendorDetails => 'Vendor details';

  @override
  String get rateHistory => 'Rate history';

  @override
  String get changeRate => 'Change rate';

  @override
  String get effectiveFrom => 'Effective from';

  @override
  String get rateSaved => 'Rate saved';

  @override
  String get noRateHistory => 'No rates have been added yet.';

  @override
  String get noVendors => 'No milk vendors yet';

  @override
  String get addFirstVendor => 'Add your milk vendor to get started.';

  @override
  String get callVendor => 'Call vendor';

  @override
  String get messageVendor => 'Message on WhatsApp';

  @override
  String get today => 'Today';

  @override
  String get delivered => 'Milk delivered';

  @override
  String get skipped => 'No delivery';

  @override
  String get customQuantity => 'Custom quantity';

  @override
  String get markDelivered => 'Milk came';

  @override
  String get markSkipped => 'No milk';

  @override
  String get changeQuantity => 'Change quantity';

  @override
  String get undo => 'Undo';

  @override
  String get entrySaved => 'Today\'s entry saved';

  @override
  String get entryUndone => 'Change undone';

  @override
  String get deleteEntryQuestion => 'Delete this day\'s milk entry?';

  @override
  String get entryDeleted => 'Entry deleted';

  @override
  String get currentMonth => 'This month';

  @override
  String get totalLitres => 'Total milk';

  @override
  String get totalAmount => 'Milk amount';

  @override
  String get deliveredDays => 'Delivery days';

  @override
  String get skippedDays => 'Skipped days';

  @override
  String get unmarked => 'Not marked';

  @override
  String get markUnmarked => 'Mark unmarked days as delivered';

  @override
  String get bulkEntry => 'Bulk entry';

  @override
  String get backdateEntry => 'Add past entry';

  @override
  String get bulkMarkQuestion =>
      'Add the default daily amount to all unmarked days in the selected date range?';

  @override
  String get bulkEntryMissingRate =>
      'A milk rate is missing for one or more dates. Add rates covering the full date range, then try again.';

  @override
  String bulkMarkDone(int count) {
    return '$count days marked';
  }

  @override
  String get month => 'Month';

  @override
  String get paymentsThisMonth => 'Paid this month';

  @override
  String get paid => 'Paid';

  @override
  String get balance => 'Balance due';

  @override
  String get advance => 'Advance';

  @override
  String get openingBalanceCaption => 'Starting balance';

  @override
  String get calendar => 'Calendar';

  @override
  String get addPayment => 'Add payment';

  @override
  String get paymentAmount => 'Amount paid';

  @override
  String get paymentDate => 'Payment date';

  @override
  String get paymentMode => 'Payment method';

  @override
  String get cash => 'Cash';

  @override
  String get upi => 'UPI';

  @override
  String get bank => 'Bank transfer';

  @override
  String get otherPayment => 'Other';

  @override
  String get paymentNote => 'Note (optional)';

  @override
  String get paymentSaved => 'Payment saved';

  @override
  String get paymentDeleted => 'Payment deleted';

  @override
  String get payFullBalance => 'Pay full balance';

  @override
  String get advancePaymentHint =>
      'Any payment above the balance will remain as an advance.';

  @override
  String addAdvanceAmount(Object amount) {
    return 'Add $amount as advance';
  }

  @override
  String get noPayments => 'No payments recorded yet.';

  @override
  String get report => 'Monthly bill';

  @override
  String get selectVendor => 'Choose a vendor';

  @override
  String get selectMonth => 'Choose a month';

  @override
  String get carriedForward => 'Previous balance';

  @override
  String get closingBalance => 'Closing balance';

  @override
  String get dayByDay => 'Day-by-day details';

  @override
  String get rate => 'Rate';

  @override
  String get quantity => 'Quantity';

  @override
  String get amount => 'Amount';

  @override
  String get sharePdf => 'Share bill as PDF';

  @override
  String get shareWhatsApp => 'Share on WhatsApp';

  @override
  String get noReportData => 'No entries for this month.';

  @override
  String get language => 'Language';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get english => 'English';

  @override
  String get theme => 'Appearance';

  @override
  String get systemTheme => 'Use device setting';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get dailyReminder => 'Daily reminder';

  @override
  String get reminderTime => 'Reminder time';

  @override
  String get enableReminder => 'Remind me if milk is unmarked';

  @override
  String get enablePaymentReminder => 'Monthly payment reminder';

  @override
  String get paymentReminderDay => 'Remind me on day';

  @override
  String get paymentReminderTitle => 'Milk payment reminder';

  @override
  String get paymentReminderBody =>
      'Check your milk account and pay any amount due.';

  @override
  String get notificationPermission =>
      'Allow notifications in Android settings to receive reminders.';

  @override
  String get backup => 'Back up data';

  @override
  String get restore => 'Restore from backup';

  @override
  String get backupCreated => 'Backup ready to share';

  @override
  String get restoreSuccess => 'Backup restored';

  @override
  String get restoreConfirm =>
      'Restoring replaces the current ledger. Continue?';

  @override
  String get appLock => 'App lock';

  @override
  String get enableAppLock => 'Use fingerprint or device lock';

  @override
  String get lockUnavailable => 'No device authentication is set up.';

  @override
  String get about => 'About Doodh Hisaab';

  @override
  String get insights => 'Insights';

  @override
  String get monthlySpend => 'Milk spend by month';

  @override
  String get monthlyLitres => 'Milk by month';

  @override
  String get spendingLastSixMonths => 'Spending over the last 6 months';

  @override
  String get litresLastSixMonths => 'Milk over the last 6 months';

  @override
  String get onboardingTitle => 'A simple, clear milk account';

  @override
  String get onboardingBody =>
      'Record deliveries and payments. Your account stays on this phone and works offline.';

  @override
  String get skip => 'Do this later';

  @override
  String get continueLabel => 'Continue';

  @override
  String get requiredField => 'Please fill in this field.';

  @override
  String get invalidAmount => 'Enter a valid amount.';

  @override
  String get invalidQuantity => 'Enter a valid quantity.';

  @override
  String get errorOccurred => 'Something went wrong. Please try again.';

  @override
  String get retry => 'Try again';

  @override
  String get confirm => 'Confirm';

  @override
  String reportMonth(Object month, int year) {
    return '$month $year';
  }

  @override
  String get appDescription =>
      'An offline milk delivery ledger for your household.';

  @override
  String get litreUnit => 'L';

  @override
  String get reminderTitle => 'Milk delivery check';

  @override
  String get reminderBody => 'Mark today’s milk delivery in your ledger.';

  @override
  String get reminderChannel => 'Milk ledger reminders';

  @override
  String get reminderChannelDescription =>
      'A daily reminder to update today’s milk entry.';

  @override
  String get authReason => 'Unlock Doodh Hisaab';

  @override
  String get backupUnavailable => 'Backup could not be completed.';

  @override
  String get deletePaymentQuestion => 'Delete this payment?';

  @override
  String get unlock => 'Unlock';

  @override
  String get appLocked => 'Your ledger is locked.';

  @override
  String get totalDue => 'Total due';

  @override
  String get totalAdvance => 'Total advance';

  @override
  String get markAllDelivered => 'Mark all delivered';

  @override
  String get allDoneToday => 'All done for today';

  @override
  String pendingToday(int count) {
    return '$count left to mark today';
  }

  @override
  String get editTodayEntry => 'Edit today\'s entry';

  @override
  String get date => 'Date';

  @override
  String get status => 'Status';

  @override
  String get printBill => 'Print or save PDF';

  @override
  String get averagePerDay => 'Average per day';

  @override
  String get archivedVendors => 'Removed vendors';

  @override
  String get restoreVendor => 'Bring back';

  @override
  String get vendorRestored => 'Vendor restored';

  @override
  String get deleteRateQuestion => 'Delete this rate? Entries already saved keep their rate.';

  @override
  String get cannotDeleteOnlyRate => 'At least one rate is needed.';

  @override
  String get rateDeleted => 'Rate deleted';

  @override
  String get currentRate => 'Current rate';

  @override
  String get generalSection => 'General';

  @override
  String get remindersSection => 'Reminders';

  @override
  String get dataSection => 'Backup';

  @override
  String get securitySection => 'Security';

  @override
  String get quantityStep => 'Quantity step';

  @override
  String get quantityStepHint => 'How much + and − change the quantity';

  @override
  String get notSet => 'Not set';

  @override
  String get clear => 'Clear';

  @override
  String get markRangeTitle => 'Fill many days at once';

  @override
  String get markRangeDelivered => 'Milk came on all unmarked days';

  @override
  String get markRangeSkipped => 'No milk on unmarked days (holiday)';

  @override
  String get bulkSkipQuestion => 'Mark all unmarked days in the selected range as no delivery?';

  @override
  String billGeneratedOn(Object date) {
    return 'Generated on $date';
  }
}
