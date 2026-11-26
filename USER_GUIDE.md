# Doodh Hisaab user guide

## First use

1. Choose Hindi or English in Settings.
2. Add your milk vendor. Enter the current rate per litre and the usual daily
   quantity. Add an opening balance if money was already owed.
3. Use **Today** to record whether milk arrived. The main actions use the
   vendor's default quantity; adjust it before saving when needed.

## Daily records and rates

- In **Calendar**, tap any day to record, edit or remove that day's entry.
- Use **Mark unmarked days as delivered** to fill a selected date range. Existing
  delivered or skipped days are left unchanged.
- In the vendor's **Rate history**, choose the date the new rate starts. Past
  entries retain their saved rate.
- Deleting an entry or payment changes the balance immediately. Use the undo
  action shown after deletion to restore it.

## Payments and monthly bills

- Add a payment from **Payments**; select its date, amount and payment mode.
- **Reports** shows monthly litres, milk amount, payments, carried-forward
  balance and closing balance.
- Tap **Share PDF** to create and share the bill using the Android share sheet.
  WhatsApp is available there when installed.

## Settings, reminders and backups

- Pick a light, dark or system theme and switch the app language in Settings.
- Enable the daily reminder and allow Android notifications when prompted.
- Turn on **Automatic backup** to save copies inside the app on this phone.
  Choose daily, weekly or monthly and a preferred time. Android may defer the
  run; the app keeps the latest seven copies.
- **Backup** shares a JSON copy of the complete ledger. Save it somewhere safe.
- **Restore** replaces the ledger on this phone with the selected backup.
  Confirm the replacement only when you intend to overwrite the current data.
- **Restore automatic backup** lets you choose one of the retained local copies.
- App lock uses the device's biometric or screen-lock authentication when
  supported.

## Build a signed Android release

Keep the signing key and passwords private and backed up. From the project
directory, create a keystore (choose your own secure passwords):

```powershell
keytool -genkey -v -keystore doodh-hisaab-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias doodh-hisaab
```

Store the keystore outside source control, then create
`android/key.properties`:

```properties
storeFile=C:/secure/path/doodh-hisaab-release.jks
storePassword=YOUR_STORE_PASSWORD
keyAlias=doodh-hisaab
keyPassword=YOUR_KEY_PASSWORD
```

The file is ignored by Git. Build the Play Store bundle or a release APK:

```powershell
flutter build appbundle --release
flutter build apk --release
```

The output is under `build/app/outputs/`. Keep the same signing key for every
update to the published app.
