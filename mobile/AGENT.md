# AGENT.md — Jemenai App Architecture

This document describes the skeletal architecture of the Jemenai Flutter app in enough detail to reproduce it in another project.

---

## 1. Tech Stack

| Concern | Choice |
|---|---|
| Framework | Flutter (Dart SDK `^3.9.0`) |
| State management | `flutter_bloc` — Cubits only (no full Blocs) |
| Backend | Firebase (Auth, Firestore, Storage, Messaging, Crashlytics, Remote Config) |
| Local cache | `shared_preferences` via a singleton `CacheService` |
| AI | Google Gemini (`flutter_gemini`) + Cerebras (custom REST via `dio`) |
| Subscriptions | RevenueCat (`purchases_flutter`, `purchases_ui_flutter`) |
| Navigation | Named routes with a custom `AppRouter` using `CupertinoPageRoute` |
| i18n | `flutter_translate` (git dep), 8 locales: `en es fr ar de it pt ru` |
| Font | Inter (all weights bundled locally under `assets/fonts/Inter/`) |
| Notifications | `firebase_messaging` + `flutter_local_notifications` |
| Auth providers | Email/Password, Google Sign-In, Apple Sign-In |

---

## 2. Project Directory Layout

```
jemenai/
├── lib/
│   ├── main.dart                  # App entry point, DI root, MultiBlocProvider
│   ├── firebase_options.dart      # Auto-generated Firebase config
│   │
│   ├── features/                  # One folder per product feature
│   │   ├── auth/
│   │   ├── home/
│   │   ├── dashboard/
│   │   ├── bucket_list/
│   │   ├── memories/
│   │   ├── interactions/
│   │   ├── ai_coach/
│   │   └── settings/
│   │
│   ├── services/                  # Singleton / infrastructure services
│   │   ├── base_api_service.dart
│   │   ├── cache_service.dart
│   │   ├── cerebras_service.dart
│   │   ├── firebase_service.dart
│   │   ├── image_service.dart
│   │   ├── location_service.dart
│   │   ├── notification_service.dart
│   │   ├── translation_service.dart
│   │   └── tts_service.dart
│   │
│   └── shared/                    # Design system & cross-cutting utilities
│       ├── navigator/
│       │   ├── app_route_string.dart
│       │   └── app_router.dart
│       ├── app_button.dart
│       ├── app_colors.dart
│       ├── app_string.dart        # All user-facing strings (i18n keys)
│       ├── assets.dart            # Typed asset references (SVGs, images)
│       ├── base_app_screen.dart   # Scaffold wrapper + AppInput widget
│       ├── constants.dart
│       ├── theme.dart
│       └── user_avatar.dart
│
├── assets/
│   ├── fonts/Inter/               # Inter font weights (Black, Bold, Light, Medium, Regular)
│   ├── i18n/                      # JSON translation files per locale
│   ├── images/
│   └── svgs/
│
├── functions/                     # Firebase Cloud Functions (Node.js)
├── android/
├── ios/
├── windows/
├── test/
├── pubspec.yaml
├── firebase.json
└── .firebaserc
```

---

## 3. Feature Module Structure

Every feature under `lib/features/<feature_name>/` follows the same three-layer pattern:

```
<feature>/
├── models/         # Plain Dart data classes (fromJson / toJson)
├── view_models/    # Cubit + State (one cubit file, one state file)
└── views/          # Screens and page widgets
    └── widgets/    # Sub-widgets local to this feature (optional)
```

> **Rule:** Views never call services directly. They only interact with cubits.  
> **Rule:** Cubits never import other cubits. They call `FirebaseService` or other services.

---

## 4. Features Inventory

| Feature | Screens / Pages |
|---|---|
| **auth** | `welcome_screen`, `onboarding_screen`, `login_screen`, `sign_up_screen`, `forgot_password_screen`, `check_email_screen` |
| **home** | `home_page` (main tab shell), `notification_screen`, `change_password_screen` |
| **dashboard** | `dashboard_screen`, `profile_setup_screen`, `add_partner_screen`, `pairing_code_screen` (widget), `connected_screen` (widget) |
| **bucket_list** | `bucket_list_page`, `add_bucket_item_screen` |
| **memories** | `memories_page`, `add_memory_screen`, `memory_details_screen` |
| **interactions** | `interactions_page`, `all_questions_screen`, `question_details_screen` |
| **ai_coach** | `ai_coach_screen`, `ai_chat_list_screen` |
| **settings** | `settings_screen`, `edit_profile_screen`, `remove_partner_screen`, `contact_support_screen` |

---

## 5. State Management — Cubit Pattern

Each feature gets exactly **one Cubit** (and its companion State file) registered globally at the app root.

### Cubit skeleton
```dart
// view_models/foo_cubit.dart
part 'foo_state.dart';

class FooCubit extends Cubit<FooState> {
  FooCubit({required this.firebaseService, required this.cacheService})
      : super(FooInitial());

  final FirebaseService firebaseService;
  final CacheService cacheService;

  Future<void> doSomething() async {
    emit(FooLoading());
    // ...
    emit(FooSuccess(...));
  }
}
```

### State skeleton
```dart
// view_models/foo_state.dart
part of 'foo_cubit.dart';

sealed class FooState {}
class FooInitial  extends FooState {}
class FooLoading  extends FooState {}
class FooSuccess  extends FooState { final Data data; FooSuccess({required this.data}); }
class FooFailure  extends FooState { final String message; FooFailure({required this.message}); }
```

### Cubits registered in `main.dart`
All cubits are provided at the top of the widget tree via `MultiBlocProvider`:

```
AuthCubit        ← auth
HomeCubit        ← home (also drives locale switching)
MemoriesCubit    ← memories
BucketCubit      ← bucket_list
InteractionsCubit← interactions
AiCubit          ← ai_coach
```

Global side-effects (logout, account deletion, locale change) are handled by `MultiBlocListener` in `main.dart`, so no feature needs to know about another.

---

## 6. Navigation

### Router class: `AppRouter` (`lib/shared/navigator/app_router.dart`)

- Uses a **static `GlobalKey<NavigatorState> navKey`** — passed to `MaterialApp.navigatorKey`.
- All routes are **named strings** (no `go_router`, no auto-route).
- Transitions use `CupertinoPageRoute` (iOS-style slide) everywhere.
- Arguments are passed via typed `settings.arguments` casts.

### Route constants: `AppRouteString` (`lib/shared/navigator/app_route_string.dart`)

```dart
class AppRouteString {
  static const welcome         = '/';
  static const onboarding      = '/onboarding';
  static const login           = '/login';
  static const signup          = '/signup';
  static const forgotPassword  = '/forgot-password';
  static const checkEmail      = '/check-email';
  static const profileSetup    = '/profile-setup';
  static const addPartner      = '/add-partner';
  static const dashboard       = '/dashboard';
  static const pairingCode     = '/pairing-code';
  static const connected       = '/connected';
  static const notification    = '/notification';
  static const settings        = '/settings';
  static const editProfile     = '/edit-profile';
  static const changePassword  = '/change-password';
  static const removePartner   = '/remove-partner';
  static const addMemory       = '/add-memory';
  static const memoryDetails   = '/memory-details';
  static const aiCoach         = '/ai-coach';
  static const aiChats         = '/ai-chat-list';
  static const allQuestions    = '/all-questions';
  static const questionDetails = '/question-details';
  static const addBucketItem   = '/add-bucket-item';
  static const contactSupport  = '/contact-support';
}
```

### Navigation helpers (called from anywhere via the static navKey)
```dart
AppRouter.push(routeName, args: ...)
AppRouter.pushReplacement(routeName, args: ...)
AppRouter.pushAndRemoveUntil(routeName)   // clears the stack
AppRouter.pop(arg: ...)
AppRouter.showMessage(text)               // floating SnackBar
AppRouter.showModal(title:, builder:)     // bottom sheet
```

### Auth navigation flow
```
WelcomeScreen
  └─ OnboardingScreen  (first launch only)
  └─ LoginScreen ──────┐
  └─ SignUpScreen ──────┤
                        ├─ ProfileSetupScreen ──► AddPartnerScreen ──► Dashboard
                        └─ (existing user)    ──► Dashboard (home shell)
```

---

## 7. Services Layer

All services live in `lib/services/` and are instantiated as **global singletons** in `main.dart` (not inside the widget tree).

| Service | Role |
|---|---|
| `FirebaseService` | Single facade over Firebase Auth, Firestore & Storage. All Firestore reads/writes go through here. |
| `CacheService` | Singleton wrapping `SharedPreferences`. Stores the serialised `UserModel` locally. |
| `CerebrasService` | HTTP client (Dio) for the Cerebras AI REST API. |
| `NotificationService` | Wraps `firebase_messaging` + `flutter_local_notifications`. Handles FCM token, foreground/background/terminated message routing. |
| `ImageService` | Pick → crop → compress image pipeline (`image_picker`, `image_cropper`, `flutter_image_compress`). |
| `LocationService` | Wraps `geolocator`. Needs `FirebaseService` to persist location updates. |
| `TranslationService` | Thin wrapper around the `translator` package. |
| `TtsService` | Wraps `flutter_tts` for text-to-speech in the AI coach. |
| `BaseApiService` | Dio base class with interceptors (auth headers, logging via `pretty_dio_logger`). |

### Global singletons in `main.dart`
```dart
final firebaseService = FirebaseService(
  firebaseAuth: FirebaseAuth.instance,
  firebaseFirestore: FirebaseFirestore.instance,
  cacheService: CacheService.instance,
  cerebrasService: CerebrasService(
    baseUrl: const String.fromEnvironment('CEREBRAS_BASE_URL'),
  ),
);

final locationService = LocationService(firebaseService: firebaseService);
```

---

## 8. Design System (`lib/shared/`)

### Colors (`app_colors.dart`)
```dart
primary       = Color(0xFFB084CC)   // lilac-purple
primaryDark   = Color(0xFF9060B0)
primaryLight  = Color(0xFFE6DCF0)
surfaceLilac  = Color(0xFFF8F4FC)
shadowLilac   = Color.fromRGBO(176, 132, 204, 0.15)
textMain      = Color(0xFF4A4A4A)
textSub       = Color(0xFF8A8A8A)
red           = Color(0xFFFF2056)
green         = Color(0xFF00C950)
blue          = Color(0xFF155DFC)
purple        = Color(0xFFAD46FF)
```

### Background gradient (auth & base screens)
```dart
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  stops: [0.0, 0.7, 1.0],
  colors: [
    Color(0xFFFFE4E6),  // light pink
    Color(0xFFFAF5FF),  // light lavender
    Color(0xFFF0FDF4),  // light green
  ],
)
```

### Shared widgets
| Widget | File | Purpose |
|---|---|---|
| `BaseAppScreen` | `base_app_screen.dart` | Gradient `Scaffold` wrapper, applies `SafeArea` |
| `AppInput` | `base_app_screen.dart` | Labelled `TextFormField` with rounded border style |
| `AppButton` | `app_button.dart` | Primary CTA button |
| `UserAvatar` | `user_avatar.dart` | Cached network image avatar with fallback initials |

### Typography
- Font family: **Inter** (all weights self-hosted)
- Base `TextStyle` exported as `textStyle` from `theme.dart`

### Assets reference
- All SVG and image asset paths are centralised in `assets.dart` using typed wrappers (`SvgAsset`, `ImageAsset`) so paths are never raw strings in widget code.

---

## 9. Internationalisation

- Translation JSON files live in `assets/i18n/`.
- Supported locales: `en`, `es`, `fr`, `ar`, `de`, `it`, `pt`, `ru`.
- The active locale is stored on the `UserModel` (Firestore field `language`).
- `HomeCubit` detects locale changes and calls `changeLocale(context, lang)` via a `BlocListener` in `main.dart`.
- All user-facing strings are keys looked up at runtime; raw strings should **not** be hardcoded in widgets — use `AppString` constants or `translate()`.

---

## 10. Secrets / Environment Variables

All secrets are injected at build time via `--dart-define`:

| Variable | Used by |
|---|---|
| `GEMINI_API_KEY` | `flutter_gemini` init |
| `CEREBRAS_BASE_URL` | `CerebrasService` |
| `REVENUECAT_APPLE_API_KEY` | RevenueCat iOS |
| `REVENUECAT_GOOGLE_API_KEY` | RevenueCat Android |

No secrets are committed to the repo.

---

## 11. Startup Sequence (`main()`)

```
1. WidgetsFlutterBinding.ensureInitialized()
2. Create LocalizationDelegate (flutter_translate)
3. Firebase.initializeApp()
4. NotificationService().init()
5. NotificationService().checkInitialMessage()   ← deep-link from terminated state
6. CacheService.instance.init()                  ← SharedPreferences ready
7. Gemini.init(apiKey)
8. Purchases.configure(apiKey)                   ← RevenueCat
9. runApp(LocalizedApp(delegate, MyApp()))
```

---

## 12. Adding a New Feature (Checklist)

- [ ] Create `lib/features/<name>/` with `models/`, `view_models/`, `views/` subdirectories.
- [ ] Add model class(es) with `fromJson` / `toJson`.
- [ ] Create `<Name>Cubit` + `<Name>State` (use `part`/`part of`).
- [ ] Register the cubit in `MultiBlocProvider` in `main.dart`.
- [ ] Add all new routes to `AppRouteString` constants.
- [ ] Add `case` entries in `AppRouter.generateRoute`.
- [ ] Add any Firestore methods to `FirebaseService`.
- [ ] Add i18n keys to the appropriate `assets/i18n/*.json` files and `AppString`.
- [ ] Add any new assets to `assets.dart` typed wrappers.
