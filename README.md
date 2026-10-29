\# PocketLedger



\*\*A Flutter-based personal expense tracker for college students.\*\*



PocketLedger helps users record expenses, organize spending by category, set a monthly budget, and review their spending through charts.



> \*\*Project status:\*\* The Flutter application has been built and tested locally. Privacy-policy publication and account-deletion functionality are still pending. Verify all release requirements before public distribution.



\## Table of Contents



1\. Overview

2\. Features

3\. Technology Stack

4\. Requirements

5\. Project Setup

6\. Firebase Configuration

7\. Running the Application

8\. Testing and Code Quality

9\. Building Release Artifacts

10\. Project Structure

11\. Data Storage and Privacy

12\. Security Guidelines

13\. Git and Version Control

14\. Release Checklist

15\. Planned Improvements



\## 1. Overview



PocketLedger is a cross-platform application developed using Flutter and Firebase.



The application uses Firebase Authentication for user accounts and Cloud Firestore to store profile information and expense records.



The Android application ID is `com.shivamtiwari.pocketledger`.



\## 2. Features



\- Email and password registration and login.

\- Password reset through email.

\- User profile management.

\- Monthly budget configuration.

\- Expense creation, editing, and deletion.

\- Expense categorization.

\- Expense dates and optional notes.

\- Spending charts using `fl\_chart`.

\- Cloud-based storage through Cloud Firestore.

\- User-specific data access through Firestore security rules.

\- Demo expense support in the data model.



\## 3. Technology Stack



| Technology              | Purpose                           |

| ----------------------- | --------------------------------- |

| Flutter                 | Application framework             |

| Dart                    | Programming language              |

| Firebase Authentication | Account management                |

| Cloud Firestore         | Cloud database                    |

| Provider                | State management                  |

| fl\_chart                | Charts and visualizations         |

| Google Fonts            | Typography                        |

| intl                    | Date and number formatting        |

| Git and GitHub          | Version control and source backup |



\## 4. Requirements



Install the following tools before developing the application:



\- Flutter SDK

\- Dart SDK, included with Flutter

\- Android SDK and Android platform tools

\- Android Studio or Visual Studio Code

\- Git

\- A Firebase project

\- A physical Android phone for device testing, if preferred



Check the installations:



```powershell

flutter --version

dart --version

flutter doctor -v

git --version

```



Resolve any relevant Flutter or Android toolchain errors before building the app.



\## 5. Project Setup



\### Step 1: Open the project directory



The development project is located at:



```text

D:\\PocketLedger-Setup\\Projects\\pocketledger

```



Open this folder in Visual Studio Code or a terminal.



\### Step 2: Install dependencies



```powershell

flutter pub get

```



\### Step 3: Configure Firebase



Follow the Firebase configuration instructions in Section 6 before running the application.



\### Step 4: Check the project



```powershell

flutter analyze

flutter test

```



\### Step 5: Run the app



```powershell

flutter run

```



\## 6. Firebase Configuration



PocketLedger uses Firebase project `pocketledger-d4846`.



The application requires the appropriate Firebase configuration for the target platform.



\### Android configuration



The Android Firebase configuration file is:



```text

android/app/google-services.json

```



FlutterFire configuration is also used through:



```text

lib/firebase\_options.dart

```



These files are environment-specific. Do not replace them with arbitrary configuration files from another Firebase project.



If configuring a new development environment, use the Firebase Console and FlutterFire CLI to generate the appropriate configuration.



Typical FlutterFire configuration command:



```powershell

flutterfire configure

```



Review the selected Firebase project and platforms before accepting the configuration.



\### Firebase services



\- Firebase Authentication: email/password authentication.

\- Cloud Firestore: user profiles and expense records.



\### Firestore data structure



```text

users/

&#x20; {uid}/

&#x20;   name

&#x20;   email

&#x20;   monthlyBudget

&#x20;   createdAt



&#x20;   expenses/

&#x20;     {expenseId}/

&#x20;       title

&#x20;       amount

&#x20;       category

&#x20;       date

&#x20;       note

&#x20;       createdAt

&#x20;       isSample

```



\### Current Firebase plan



The project is currently using the Spark free plan. Review Firebase pricing and service requirements before enabling additional backend services.



\## 7. Running the Application



\### Run on an Android phone



1\. Enable Developer options on the phone.

2\. Enable USB debugging.

3\. Connect the phone to the computer.

4\. Approve the debugging prompt on the phone.

5\. Check whether Flutter detects the device:



```powershell

flutter devices

```



6\. Run the application:



```powershell

flutter run

```



\### Run in release mode for testing



```powershell

flutter run --release

```



Release-mode testing should be performed on a physical device before publishing.



\## 8. Testing and Code Quality



Run the static analyzer:



```powershell

flutter analyze

```



Run the automated tests:



```powershell

flutter test

```



Build the Android APK:



```powershell

flutter build apk --release

```



Build the Android App Bundle:



```powershell

flutter build appbundle --release

```



The APK and AAB are generated at:



```text

build/app/outputs/flutter-apk/app-release.apk

build/app/outputs/bundle/release/app-release.aab

```



Re-run the analyzer and tests after significant code changes. A successful build alone does not guarantee that all application functionality is correct.



\## 9. Building Release Artifacts



\### Android APK



The APK can be installed directly on compatible Android devices.



```powershell

flutter build apk --release

```



\### Android App Bundle



The AAB is the preferred upload format for Google Play.



```powershell

flutter build appbundle --release

```



\### Signing configuration



The project uses a release upload keystore configured through local Android signing settings.



Keep the following files private:



```text

android/key.properties

android/app/google-services.json

lib/firebase\_options.dart

```



The keystore and its passwords must be backed up securely. Never commit signing credentials or private keys to a public repository.



Before distributing a build, verify its package ID, version, signing configuration, permissions, Firebase configuration, and release behavior.



\## 10. Project Structure



```text

pocketledger/

├── android/                # Android application and build configuration

├── assets/

│   └── icon/               # Application icon assets

├── ios/                    # iOS platform project

├── lib/

│   ├── models/             # Application data models

│   ├── providers/          # Authentication and data state

│   ├── screens/             # Application screens

│   ├── services/           # Firebase and data operations

│   ├── utils/              # Helpers, constants, validation and theme

│   ├── widgets/            # Reusable UI components

│   ├── app.dart            # Application configuration

│   └── main.dart           # Application entry point

├── test/                   # Automated tests

├── web/                    # Web platform files

├── windows/                # Windows platform files

├── macos/                  # macOS platform files

├── linux/                  # Linux platform files

├── firestore.rules         # Firestore security rules

├── firebase.json           # FlutterFire configuration

├── pubspec.yaml            # Dependencies and Flutter configuration

├── analysis\_options.yaml   # Dart analyzer configuration

└── README.md

```



\## 11. Data Storage and Privacy



\### Information stored by the application



The current data models include:



\- Account identifier and profile name.

\- Email address.

\- Monthly budget.

\- Expense titles, amounts, categories, and dates.

\- Optional expense notes.

\- Record creation timestamps.

\- A flag identifying sample expense records.



Firebase Authentication manages account credentials. PocketLedger does not store users' passwords in its Firestore profile documents.



\### Firestore security



The current `firestore.rules` file restricts access to each user's profile and expense collection using the authenticated Firebase user ID.



Review and test security rules before production deployment.



\### Privacy policy



A public privacy-policy URL has not yet been established.



Before public release:



1\. Prepare a policy that accurately describes data collection, Firebase services, data retention, security, and user rights.

2\. Publish it at a publicly accessible HTTPS URL.

3\. Add the policy link to the application.

4\. Provide the required privacy-policy URL in Google Play Console.

5\. Complete the applicable Google Play Data safety disclosures.



Do not claim that the application collects no technical data without reviewing the Firebase SDKs and relevant platform behavior.



\### Account deletion



Account deletion has not yet been implemented.



A complete implementation must address both Firebase Authentication and associated Firestore data, including nested expense documents.



Deleting a parent Firestore document does not automatically delete its subcollections.



A trusted backend using the Firebase Admin SDK is the preferred approach for reliable recursive deletion. Confirm deployment, billing, authentication, and failure-handling requirements before implementing it.



Until deletion has been implemented and tested, do not advertise it as an available in-app feature.



\## 12. Security Guidelines



\- Never commit passwords, API secrets, signing keys, or private credentials.

\- Keep signing keystores and backups in secure locations.

\- Restrict Firestore access through security rules.

\- Test security rules with authenticated and unauthenticated requests.

\- Require appropriate reauthentication for sensitive account operations.

\- Handle Firebase errors without exposing sensitive technical details to users.

\- Avoid logging passwords, tokens, or private financial records.

\- Review Firebase project permissions and enabled services.

\- Verify that release builds use the intended production configuration.

\- Back up important project files before making significant changes.



\## 13. Git and Version Control



Check the current repository status:



```powershell

git status

```



Review changed files before committing:



```powershell

git diff

```



Stage the intended changes:



```powershell

git add README.md

```



Commit the documentation update:



```powershell

git commit -m "docs: improve project README"

```



Push the commit when ready:



```powershell

git push

```



Always review `.gitignore` before staging configuration or release files. Never force-add private credentials to the repository.



\## 14. Release Checklist



Before releasing PocketLedger publicly, verify each item.



\- \[x] Flutter analysis passes.

\- \[x] Automated tests pass.

\- \[ ] Authentication and password reset work.

\- \[x] Profile and budget updates work.

\- \[x] Expense creation, editing, and deletion work.

\- \[x] Firestore rules have been reviewed.

\- \[ ] Offline and network-failure behavior has been reviewed.

\- \[ ] Account deletion is implemented and tested.

\- \[ ] Privacy policy is published and linked in the app.

\- \[ ] Google Play Data safety disclosures are completed accurately.

\- \[x] App signing and keystore backups are verified.

\- \[x] Release APK and AAB are tested on a physical device.

\- \[x] App version and package identifier are correct.

\- \[ ] Google Play listing and support contact are prepared.



\## 15. Planned Improvements



Potential future improvements include:



\- Implementing reliable account and associated-data deletion.

\- Publishing and linking the privacy policy.

\- Adding account-deletion error recovery and user feedback.

\- Improving automated tests for authentication and expense workflows.

\- Completing Google Play release preparation.

\- Expanding project documentation as features are added.



\---



\*\*Project:\*\* PocketLedger

\*\*Framework:\*\* Flutter

\*\*Backend:\*\* Firebase Authentication and Cloud Firestore

\*\*Android application ID:\*\* `com.shivamtiwari.pocketledger`





