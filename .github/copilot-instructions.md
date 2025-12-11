# Repo-specific instructions for AI coding agents

These notes are targeted and actionable for working in this Flutter repo (`KmIndustrial`). Keep guidance concise — reference files, commands, and concrete patterns so an agent can be immediately productive.

- **Project root**: `pubspec.yaml` and `lib/main.dart` live at the repository root (not in a `my_app/` subfolder). Use the repo root for `flutter` commands.
- **Run / build** (PowerShell):
  - `flutter pub get`
  - `flutter run`
  - `flutter test`

- **Entrypoint & app shell**: `lib/main.dart` sets up `MaterialApp` and the theme. `LoginScreen` is the initial `home` (see `lib/screens/login_screen.dart`). Use `main.dart` to find global theme, button styles and Material3 usage.

- **UI organization**: Screens live in `lib/screens/` (examples: `login_screen.dart`, `home_screen.dart`, `coleta_screen.dart`, `estoque_screen.dart`). Prefer updating or adding screens in this folder and follow existing naming (snake_case with `_screen` suffix).

- **Service layer**: Networking and external calls are centralized under `lib/services/` (notably `lib/services/api_service.dart`). Check this file for HTTP patterns and auth/token handling before adding new network calls.

- **State & persistence**: The project uses `shared_preferences` (see `pubspec.yaml`). Search for `SharedPreferences` usage when modifying persisted settings or session state.

- **Assets & icons**: Assets declared in `pubspec.yaml` (example: `assets/km_ind_1024.png`). Launcher icon generation is configured via `flutter_launcher_icons` in `pubspec.yaml` — run `flutter pub run flutter_launcher_icons:main` only when changing icons.

- **Dependencies**: Key packages in use: `http`, `shared_preferences`, `url_launcher`. When adding packages, update `pubspec.yaml` and run `flutter pub get` from the repo root.

- **Platform folders**: Android (`android/`) and iOS (`ios/`) directories exist and contain generated/native code. Avoid manual edits in `build/`, `flutter_assets/`, or other generated outputs unless modifying platform-specific config. If you change native settings, note which platform file changed (e.g., `android/app/build.gradle.kts`, `ios/Runner/Info.plist`).

- **Tests**: Unit/widget tests are in `test/` (example `test/widget_test.dart`). Run `flutter test` from the repo root.

- **Local dev notes & gotchas discovered**:
  - The workspace contains a task that references a `my_app` folder — that does not exist in this repo. Use the repo root when running `flutter` commands, or confirm if the user intends a different subfolder.
  - There is a minimal `README.md` at the repo root that documents how this skeleton was created; refer to it for manual `flutter create` hints.

- **When editing code**:
  - Inspect `lib/main.dart` first for theming and button styles before adding UI widgets — the app centralizes look-and-feel there.
  - Consult `lib/services/api_service.dart` for existing HTTP call patterns and error handling conventions.
  - Follow existing file naming and folder organization: `lib/screens/` for screens, `lib/services/` for backend integrations.

- **What not to do**:
  - Don’t check in or modify generated files in `build/` or `flutter_assets/` unless specifically asked.
  - Don’t assume a `my_app` subfolder exists; confirm or use the repo root.

If anything in these instructions is unclear or you want additional examples (e.g., a short example patch that adds an API call or a new screen), say which area to expand and I will update the file.
