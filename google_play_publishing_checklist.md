# Google Play Store Publishing Checklist

Publishing your first app to the Google Play Store involves several steps, from preparing your Flutter project to navigating the Google Play Console. Use this checklist to guide you through the process.

## Phase 1: Prepare Your App (Pre-Requisites)

- [ ] **App Icon:** Ensure your app has a polished launcher icon. You can use the `flutter_launcher_icons` package to generate these easily.
- [ ] **Store Assets:** Prepare the required graphics for the Play Store:
  - High-res icon (512x512 PNG)
  - Feature Graphic (1024x500 PNG/JPEG)
  - Phone Screenshots (at least 2, max 8)
- [ ] **Privacy Policy:** You **must** have a privacy policy hosted online (e.g., on a free Google Site or GitHub Pages). You cannot publish without one.
- [ ] **App Details:** Prepare your App Title, Short Description (80 chars), and Full Description (4000 chars).
- [ ] **Remove Debug Code:** Ensure there are no debug prints or bypassed authentications in your code.

## Phase 2: Sign Your App (Crucial Step)

Android requires all release apps to be digitally signed with a certificate (Keystore). If you lose this Keystore later, you cannot update your app!

1. **Generate a Keystore:**
   Open your terminal (Command Prompt/PowerShell) and run:
   ```bash
   keytool -genkey -v -keystore c:\Users\saifg\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   *(Keep this `.jks` file extremely safe and back it up!)*

2. **Reference Keystore in Android:**
   Create a file named `key.properties` in your `android/` folder:
   ```properties
   storePassword=your_password
   keyPassword=your_password
   keyAlias=upload
   storeFile=c:/Users/saifg/upload-keystore.jks
   ```

3. **Update `android/app/build.gradle`:**
   Modify the gradle file to use this keystore for release builds. (See Flutter's official documentation on [App Signing](https://docs.flutter.dev/deployment/android#signing-the-app)).

## Phase 3: Build the App Bundle

Google Play requires an App Bundle (`.aab` file) rather than an APK.

- [ ] Check your version in `pubspec.yaml` (e.g., `version: 1.0.0+1`). The `+1` is the build number, which must be incremented every time you upload a new version.
- [ ] Open your terminal and run:
  ```bash
  flutter build appbundle
  ```
- [ ] Find your bundle at: `build/app/outputs/bundle/release/app-release.aab`.

## Phase 4: Google Play Console Setup

- [ ] **Create a Developer Account:** Go to the [Google Play Console](https://play.google.com/console), sign in with your Google account, and pay the $25 one-time registration fee.
- [ ] **Verify Identity:** You will need to verify your ID with Google.
- [ ] **Create App:** Click "Create app", enter the name, default language, and select "App" (not Game) and "Free" or "Paid".

## Phase 5: Play Console Questionnaires

Navigate the left menu in the Play Console to complete these mandatory forms:
- [ ] **Store Settings:** Add your app category and contact details.
- [ ] **Main Store Listing:** Upload your descriptions, icon, and screenshots here.
- [ ] **App Content:** Complete the questionnaires for:
  - Privacy Policy URL
  - Ads (Does your app have them?)
  - App Access (Provide test credentials if your app requires login)
  - Content Rating
  - Target Audience (If targeting children, there are strict rules)
  - Data Safety (Declare exactly what data you collect, like emails/IDs via Firebase)

## Phase 6: Testing Tracks (The "20 Tester Rule")

> [!IMPORTANT]
> **New Google Play Rule for Personal Accounts:** 
> Before you can publish to Production, you **must** run a Closed Test with at least **20 testers opted-in for 14 continuous days**.

- [ ] Go to **Testing > Closed testing** and create a track.
- [ ] Upload your `app-release.aab` file here.
- [ ] Add the email addresses of 20 friends, family members, or beta testers.
- [ ] Send them the opt-in link and ensure they keep the app installed for 14 days.

## Phase 7: Production Release

- [ ] Once the 14-day closed testing period is successfully completed, the "Apply for Production" button will unlock.
- [ ] Submit your application for production review.
- [ ] Google will review your app (this can take anywhere from 2 to 7 days for a first-time app).
- [ ] Once approved, your app will be live on the Google Play Store!
