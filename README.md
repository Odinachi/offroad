# OffRoad

Private local AI. Anywhere. Anytime.

OffRoad (formerly Jemenai) is a Flutter-based mobile application designed to run state-of-the-art AI models (such as Google Gemma) entirely on-device. No internet, no servers, no tracking—just pure, offline, private intelligence.

---

## 🌟 Features

- **On-Device Inference**: Powered by `flutter_edge_ai` with the LiteRT-LM (`.litertlm`) and MediaPipe (`.task`) engines — Gemma, Qwen, Phi, DeepSeek and more run locally.
- **Chat**: Streaming replies with Markdown (code blocks, tables, lists), stop/regenerate, image input for vision models, dictation for audio models, and a visible **reasoning** trace for thinking-capable models.
- **Voice Mode**: Speak, the model transcribes and answers, and the reply is read aloud with the system's offline voice. Voice sessions are saved as regular chats.
- **Offline First**: Once a model is downloaded, nothing needs the internet.
- **Privacy Centric**: Conversations live in a local SQLite database; no accounts, analytics or telemetry. Settings can wipe all history.
- **Model Store**: Browse, download (with progress, cancel and retry), chat with and delete models. Gated models prompt for a Hugging Face token; low storage is flagged before downloading.
- **Light & Dark**: Follows the system theme until you pick one.

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (pinned to version `3.44.0` via FVM)
- **State Management**: `flutter_bloc` (using the Cubit pattern)
- **Local Storage**: `shared_preferences` for caching settings and app state
- **Core Engine**: `flutter_edge_ai` + `flutter_edge_ai_litertlm` + `flutter_edge_ai_mediapipe` for local LLM execution

---

## 🚀 Getting Started

### Prerequisites

- **FVM (Flutter Version Management)**: This project enforces Flutter SDK `3.44.0`. Install FVM and ensure it is configured.
- **Platforms**: iOS 16+; Android 11+ (API 30, arm64) — required by the LiteRT-LM engine.
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

Features-first layout:

- `lib/features/<feature>/` — `model/`, `view_models/` (Cubits) and `views/` per feature (`ai`, `auth` (onboarding), `dashboard`, `home`, `settings`).
- `lib/services/`
  - `chat_engine.dart` — **the only code that talks to flutter_edge_ai for inference.** Activates an installed model (never downloads), builds the chat session, replays history, streams replies, stops generation and transcribes audio. Shared by the chat and voice screens.
  - `db_service.dart` — SQLite (`chat_sessions`, `chat_messages`; schema v2 adds `thinking`).
  - `cache_service.dart` — `shared_preferences` for settings.
  - `storage_service.dart` — disk usage (returns `null` when the platform can't say).
- `lib/shared/` — theme, navigation (`AppRouter`, including `openDashboardTab`), `widgets/markdown_text.dart` (a small, tested Markdown renderer) and UI helpers.

### Notes

- Downloads happen only in the Model Store (`ModelDownloadCubit`), which also keeps the screen awake while any download runs.
- A model's context window comes from `AIModel.contextTokens`: LiteRT bundles named `…_ekvNNNN…` use that size, everything else 2048.
- The `flutter_gemma/` directory is a git submodule of the old plugin (now `flutter_edge_ai`) kept for reference; it is excluded from analysis.

---

## 🧪 Development

```bash
fvm flutter analyze
fvm flutter test
fvm dart format lib test
```

Use `fvm dart`, not a global `dart`, so formatting matches the pinned SDK.

On-device inference does not work in the iOS Simulator; use a physical device to try models. The UI runs fine in the simulator.
