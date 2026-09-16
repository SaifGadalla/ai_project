# AI Learning Path Generator

An intelligent, cross-platform Flutter application that creates customized, day-by-day learning roadmaps powered by **Firebase AI (Gemini)**. The app guides users interactively through conversation to pinpoint their goals, generates structured milestones and tasks, and tracks daily learning progress in real time.

---

## 🚀 Key Features

- **🤖 Conversational AI Curriculum Designer**:
  - Interactive chat interface powered by Firebase AI to understand learning goals, schedule, and skill level.
  - Automatically synthesizes discussions into a structured, multi-day learning roadmap with actionable daily tasks.

- **📅 Interactive Daily Progress Tracking**:
  - Breakdown of each day's focus and objectives.
  - Real-time task checklist with progress persistence in Cloud Firestore.

- **🔐 Robust Authentication & Security**:
  - Email and password authentication with form validation.
  - Route guards and reactive session management.
  - Firebase App Check integration to protect backend resources from abuse.

- **🌐 Internationalization & Localization (i18n / l10n)**:
  - Multi-language support out of the box (**English** and **Arabic**).
  - Native Right-to-Left (RTL) layout support.

- **🌓 Dynamic Theme Management**:
  - Seamless switching between Light Mode, Dark Mode, and System Default.
  - Clean Material 3 design system with customized Google Fonts and reusable components.

- **📱 Multi-Platform Support**:
  - Ready for Android, iOS, Web, Windows, macOS, and Linux.

---

## 🛠️ Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev) (Dart SDK `^3.12.2`)
- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) & [equatable](https://pub.dev/packages/equatable)
- **Routing**: [go_router](https://pub.dev/packages/go_router) with stream-based auth redirects
- **Backend & Cloud Services**:
  - [firebase_core](https://pub.dev/packages/firebase_core)
  - [firebase_auth](https://pub.dev/packages/firebase_auth) (User authentication)
  - [cloud_firestore](https://pub.dev/packages/cloud_firestore) (Real-time cloud database)
  - [firebase_ai](https://pub.dev/packages/firebase_ai) (Generative AI integration)
  - [firebase_app_check](https://pub.dev/packages/firebase_app_check) (App attestation & API security)
- **Internationalization**: `flutter_localizations`, `intl`
- **Design & Typography**: [google_fonts](https://pub.dev/packages/google_fonts), Cupertino Icons

---

## 📂 Project Structure

```text
lib/
├── firebase_options.dart         # Generated Firebase configuration
├── main.dart                     # App entry point & dependency bootstrap
├── l10n/                         # Localization files (.arb and generated classes)
│   ├── app_en.arb                # English strings
│   └── app_ar.arb                # Arabic strings
└── src/
    ├── auth/                     # Login & Sign-up screens
    ├── blocs/                    # BLoC / Cubit state management
    │   ├── auth/                 # Authentication logic
    │   ├── locale/               # Language switching
    │   ├── prompt/               # AI conversational & generation flow
    │   └── theme/                # Theme mode switching
    ├── components/               # Shared & reusable UI components
    ├── details/                  # Day details & task management views
    ├── home/                     # Dashboard & active paths list
    ├── models/                   # Data models (LearningPath, DayPlan, Task)
    ├── path/                     # Learning path timeline & overview
    ├── prompt/                   # AI prompt & path creation flow
    ├── router/                   # GoRouter configuration & route guards
    ├── services/                 # Firebase & API service layer
    ├── settings/                 # User preferences (Theme, Language, Account)
    └── utils/                    # App constants, helpers, and theme definitions
```

---

## 🏁 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.12.2 or later)
- [Firebase CLI](https://firebase.google.com/docs/cli) configured on your machine
- An active Firebase Project with **Authentication**, **Cloud Firestore**, and **Firebase AI / Vertex AI** enabled

### Installation & Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/ai_project.git
   cd ai_project
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
   Run the FlutterFire CLI to generate your platform credentials:
   ```bash
   flutterfire configure
   ```

4. **Generate Localizations**:
   ```bash
   flutter gen-l10n
   ```

5. **Run the application**:
   ```bash
   flutter run
   ```

---

## 🧪 Testing & Quality

Run unit and widget tests:
```bash
flutter test
```

Analyze code for linting and style rules:
```bash
flutter analyze
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

