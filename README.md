# OffRoad

Private local AI. Anywhere. Anytime.

OffRoad (formerly Jemenai) is a Flutter-based mobile application designed to run state-of-the-art AI models (such as Google Gemma) entirely on-device. No internet, no servers, no tracking—just pure, offline, private intelligence.

---

## 🌟 Features

- **On-Device Inference**: Powered by `flutter_gemma` to execute large language models locally on your hardware.
- **Voice & Chat Screens**: Fully featured chat interface supporting text-based and voice-based conversation streams.
- **Offline First**: Once models are downloaded, the app operates completely off-grid without requiring any internet connection.
- **Privacy Centric**: Your conversations, tokens, and data never leave your device.
- **Model Store**: Easily browse, download, and manage compatible local models directly from within the app.
- **Rich Aesthetics**: Responsive, highly custom design with support for both light and dark modes.

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (pinned to version `3.44.0` via FVM)
- **State Management**: `flutter_bloc` (using the Cubit pattern)
- **Local Storage**: `shared_preferences` for caching settings and app state
- **Core Engine**: `flutter_gemma` for local LLM execution

---

## 🚀 Getting Started

### Prerequisites

- **FVM (Flutter Version Management)**: This project enforces Flutter SDK `3.44.0`. Install FVM and ensure it is configured.
- **Hardware**: Running on-device LLMs requires a device with sufficient RAM (typically 8GB+ is recommended for optimal performance on mobile devices).

### Run the App

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd offroad
   ```

2. **Install dependencies**:
   ```bash
   fvm flutter pub get
   ```

3. **Run the project**:
   ```bash
   fvm flutter run
   ```

---

## 📂 Architecture

OffRoad follows a structured features-first directory layout:

- `lib/features/`: Contains distinct product features (e.g., `auth`, `ai`, `home`, `settings`, `dashboard`), with each folder maintaining its own `models/`, `view_models/` (Cubits), and `views/`.
- `lib/services/`: Centralized singletons for cross-cutting services like `CacheService` and `StorageService`.
- `lib/shared/`: Shared components, constants, styles, navigation (`AppRouter`), and theme assets.
