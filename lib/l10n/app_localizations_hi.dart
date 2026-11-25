// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'दूध हिसाब';

  @override
  String get milkIconDescription => 'दूध की बूँद';

  @override
  String get homeGreeting => 'दूध का हिसाब,\nअब आसान';

  @override
  String get welcomeMessage =>
      'रोज़ का दूध, भुगतान और महीने का बाकी हिसाब — सब एक ही जगह।';

  @override
  String get offlineMessage =>
      'आपका हिसाब इसी फ़ोन में सुरक्षित रहता है। ऐप बिना इंटरनेट के भी चलता है।';

  @override
  String get tabToday => 'आज';

  @override
  String get tabCalendar => 'कैलेंडर';

  @override
  String get previousMonth => 'पिछला महीना';

  @override
  String get nextMonth => 'अगला महीना';

  @override
  String get tabVendors => 'दूधवाले';

  @override
  String get tabPayments => 'भुगतान';

  @override
  String get tabReports => 'बिल';

  @override
  String get tabSettings => 'सेटिंग';

  @override
  String get settings => 'सेटिंग';

  @override
  String get addVendor => 'दूधवाला जोड़ें';

  @override
  String get editVendor => 'दूधवाले की जानकारी बदलें';

  @override
  String get vendorName => 'दूधवाले का नाम';

  @override
  String get vendorNameHint => 'जैसे, रमेश डेयरी';

  @override
  String get phoneNumber => 'फ़ोन नंबर';

  @override
  String get milkType => 'दूध का प्रकार';

  @override
  String get cowMilk => 'गाय';

  @override
  String get buffaloMilk => 'भैंस';

  @override
  String get mixedMilk => 'मिश्रित';

  @override
  String get otherMilk => 'अन्य';

  @override
  String get defaultQuantity => 'रोज़ की मात्रा';

  @override
  String get ratePerLitre => 'एक लीटर का भाव';

  @override
  String get openingBalance => 'पहले का बाकी';

  @override
  String get deliveryTime => 'दूध आने का समय';

  @override
  String get notes => 'नोट';

  @override
  String get save => 'सेव करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get delete => 'हटाएँ';

  @override
  String get edit => 'बदलें';

  @override
  String get archiveVendor => 'दूधवाले को सूची से हटाएँ';

  @override
  String archiveVendorQuestion(Object vendorName) {
    return '$vendorName को सूची से हटाएँ? उनका पुराना हिसाब सुरक्षित रहेगा।';
  }

  @override
  String get deleteVendor => 'दूधवाले को हटाएँ';

  @override
  String deleteVendorQuestion(Object vendorName) {
    return '$vendorName को दूधवालों की सूची से हटाएँ? दूध और भुगतान का पुराना हिसाब सुरक्षित रहेगा।';
  }

  @override
  String get vendorSaved => 'जानकारी सेव हो गई';

  @override
  String get vendorArchived => 'दूधवाला सूची से हटाया गया';

  @override
  String get vendorDetails => 'दूधवाले की जानकारी';

  @override
  String get rateHistory => 'भाव का इतिहास';

  @override
  String get changeRate => 'भाव बदलें';

  @override
  String get effectiveFrom => 'किस तारीख़ से';

  @override
  String get rateSaved => 'नया भाव सेव हो गया';

  @override
  String get noRateHistory => 'अभी कोई भाव नहीं जोड़ा गया।';

  @override
  String get noVendors => 'अभी कोई दूधवाला नहीं';

  @override
  String get addFirstVendor => 'शुरू करने के लिए अपना दूधवाला जोड़ें।';

  @override
  String get callVendor => 'फ़ोन करें';

  @override
  String get messageVendor => 'WhatsApp पर संदेश भेजें';

  @override
  String get today => 'आज';

  @override
  String get delivered => 'दूध आया';

  @override
  String get skipped => 'दूध नहीं आया';

  @override
  String get customQuantity => 'बदली हुई मात्रा';

  @override
  String get markDelivered => 'दूध आया';

  @override
  String get markSkipped => 'दूध नहीं आया';

  @override
  String get changeQuantity => 'मात्रा बदलें';

  @override
  String get undo => 'वापस करें';

  @override
  String get entrySaved => 'आज का हिसाब सेव हो गया';

  @override
  String get entryUndone => 'बदलाव वापस हो गया';

  @override
  String get deleteEntryQuestion => 'क्या इस दिन का दूध का हिसाब हटाएँ?';

  @override
  String get entryDeleted => 'दिन का हिसाब हट गया';

  @override
  String get currentMonth => 'इस महीने';

  @override
  String get totalLitres => 'कुल दूध';

  @override
  String get totalAmount => 'दूध का कुल भाव';

  @override
  String get deliveredDays => 'दूध आने के दिन';

  @override
  String get skippedDays => 'दूध न आने के दिन';

  @override
  String get unmarked => 'हिसाब नहीं लिखा';

  @override
  String get markUnmarked => 'बाकी दिनों में दूध आया लिखें';

  @override
  String get bulkEntry => 'एक साथ हिसाब जोड़ें';

  @override
  String get backdateEntry => 'पुराने दिन का हिसाब जोड़ें';

  @override
  String get bulkMarkQuestion =>
      'चुनी गई तारीख़ों में जिन दिनों का हिसाब नहीं है, उनमें रोज़ की तय मात्रा जोड़ें?';

  @override
  String get bulkEntryMissingRate =>
      'कुछ तारीख़ों का दूध का भाव दर्ज नहीं है। पूरी तारीख़ों के लिए भाव जोड़कर फिर कोशिश करें।';

  @override
  String bulkMarkDone(int count) {
    return '$count दिनों का हिसाब लिखा गया';
  }

  @override
  String get month => 'महीना';

  @override
  String get paymentsThisMonth => 'इस महीने जमा';

  @override
  String get paid => 'जमा';

  @override
  String get balance => 'बाकी रकम';

  @override
  String get advance => 'अग्रिम जमा';

  @override
  String get openingBalanceCaption => 'पहले का बाकी';

  @override
  String get calendar => 'कैलेंडर';

  @override
  String get addPayment => 'भुगतान जोड़ें';

  @override
  String get paymentAmount => 'जमा की गई रकम';

  @override
  String get paymentDate => 'भुगतान की तारीख़';

  @override
  String get paymentMode => 'भुगतान का तरीका';

  @override
  String get cash => 'नकद';

  @override
  String get upi => 'UPI';

  @override
  String get bank => 'बैंक ट्रांसफ़र';

  @override
  String get otherPayment => 'अन्य';

  @override
  String get paymentNote => 'नोट (ज़रूरी नहीं)';

  @override
  String get paymentSaved => 'भुगतान सेव हो गया';

  @override
  String get paymentDeleted => 'भुगतान हटाया गया';

  @override
  String get payFullBalance => 'पूरा बाकी जमा करें';

  @override
  String get advancePaymentHint =>
      'बाकी रकम से ज़्यादा जमा करने पर अतिरिक्त रकम अग्रिम में रहेगी।';

  @override
  String addAdvanceAmount(Object amount) {
    return '$amount अग्रिम जमा करें';
  }

  @override
  String get noPayments => 'अभी कोई भुगतान दर्ज नहीं है।';

  @override
  String get report => 'महीने का बिल';

  @override
  String get selectVendor => 'दूधवाला चुनें';

  @override
  String get selectMonth => 'महीना चुनें';

  @override
  String get carriedForward => 'पिछला बाकी';

  @override
  String get closingBalance => 'महीने के अंत का बाकी';

  @override
  String get dayByDay => 'हर दिन का हिसाब';

  @override
  String get rate => 'भाव';

  @override
  String get quantity => 'मात्रा';

  @override
  String get amount => 'रकम';

  @override
  String get sharePdf => 'PDF बिल साझा करें';

  @override
  String get shareWhatsApp => 'WhatsApp पर भेजें';

  @override
  String get noReportData => 'इस महीने का कोई हिसाब नहीं है।';

  @override
  String get language => 'भाषा';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get english => 'English';

  @override
  String get theme => 'दिखावट';

  @override
  String get systemTheme => 'फ़ोन की सेटिंग के अनुसार';

  @override
  String get lightTheme => 'हल्की';

  @override
  String get darkTheme => 'गहरी';

  @override
  String get dailyReminder => 'रोज़ की याद दिलाएँ';

  @override
  String get reminderTime => 'याद दिलाने का समय';

  @override
  String get enableReminder => 'दूध का हिसाब न लिखने पर याद दिलाएँ';

  @override
  String get enablePaymentReminder => 'हर महीने भुगतान की याद दिलाएँ';

  @override
  String get paymentReminderDay => 'किस तारीख़ को याद दिलाएँ';

  @override
  String get paymentReminderTitle => 'दूध के भुगतान की याद';

  @override
  String get paymentReminderBody => 'दूध का हिसाब देखें और बाकी रकम जमा करें।';

  @override
  String get notificationPermission =>
      'याद दिलाने के लिए Android सेटिंग में सूचनाएँ चालू करें।';

  @override
  String get backup => 'हिसाब का बैकअप लें';

  @override
  String get restore => 'बैकअप से हिसाब वापस लाएँ';

  @override
  String get backupCreated => 'बैकअप साझा करने के लिए तैयार है';

  @override
  String get restoreSuccess => 'बैकअप वापस आ गया';

  @override
  String get restoreConfirm =>
      'बैकअप लाने पर अभी का हिसाब बदल जाएगा। जारी रखें?';

  @override
  String get appLock => 'ऐप लॉक';

  @override
  String get enableAppLock => 'फ़िंगरप्रिंट या फ़ोन लॉक से खोलें';

  @override
  String get lockUnavailable => 'फ़ोन में कोई लॉक तरीका सेट नहीं है।';

  @override
  String get about => 'दूध हिसाब के बारे में';

  @override
  String get insights => 'जानकारी';

  @override
  String get monthlySpend => 'हर महीने दूध का खर्च';

  @override
  String get monthlyLitres => 'हर महीने दूध की मात्रा';

  @override
  String get spendingLastSixMonths => 'पिछले ६ महीनों का खर्च';

  @override
  String get litresLastSixMonths => 'पिछले ६ महीनों का दूध';

  @override
  String get onboardingTitle => 'दूध का साफ़ और आसान हिसाब';

  @override
  String get onboardingBody =>
      'दूध और भुगतान लिखें। आपका हिसाब इसी फ़ोन में रहेगा और बिना इंटरनेट चलेगा।';

  @override
  String get skip => 'बाद में करेंगे';

  @override
  String get continueLabel => 'आगे बढ़ें';

  @override
  String get requiredField => 'कृपया यह जानकारी भरें।';

  @override
  String get invalidAmount => 'सही रकम लिखें।';

  @override
  String get invalidQuantity => 'सही मात्रा लिखें।';

  @override
  String get errorOccurred => 'कुछ गड़बड़ हुई। कृपया फिर कोशिश करें।';

  @override
  String get retry => 'फिर कोशिश करें';

  @override
  String get confirm => 'पक्का करें';

  @override
  String reportMonth(Object month, int year) {
    return '$month $year';
  }

  @override
  String get appDescription => 'घर के दूध का ऑफ़लाइन हिसाब रखने वाला ऐप।';

  @override
  String get litreUnit => 'लीटर';

  @override
  String get reminderTitle => 'दूध का हिसाब लिखें';

  @override
  String get reminderBody => 'आज के दूध की जानकारी अपने हिसाब में लिखें।';

  @override
  String get reminderChannel => 'दूध हिसाब की याद दिलाना';

  @override
  String get reminderChannelDescription =>
      'आज के दूध का हिसाब लिखने की रोज़ की याद।';

  @override
  String get authReason => 'दूध हिसाब खोलें';

  @override
  String get backupUnavailable => 'बैकअप पूरा नहीं हो सका।';

  @override
  String get deletePaymentQuestion => 'यह भुगतान हटाएँ?';

  @override
  String get unlock => 'खोलें';

  @override
  String get appLocked => 'आपका हिसाब लॉक है।';
}
