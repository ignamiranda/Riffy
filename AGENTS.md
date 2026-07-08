# Riffy — AGENTS.md

## Commands

```sh
flutter analyze          # lint + static analysis
flutter test             # no tests exist yet (empty test/)
flutter run              # runs on Windows (default) or Android
flutter build windows
flutter build apk
```

## Architecture

- **Entrypoint**: `lib/main.dart` → `Hive.initFlutter()` → `ProviderScope` → `Riffy` (`lib/app.dart`)
- **Feature-first**: `lib/features/{home,search,library,player,album,playlist,artist,settings}/`
- **Core services**: `lib/core/{auth,network,router,storage,theme,models}/`
- **State**: Riverpod `StateNotifier` + `StateNotifierProvider` everywhere (no codegen yet)
- **Routing**: `go_router` with a `ShellRoute` for 3-tab bottom nav (Home, Search, Library); detail pages (player, album, playlist, artist, settings) are pushed at root level (`lib/core/router/app_router.dart`)
- **Theme**: MD3 with custom dark/light, seed color `#E91E63`, `GoogleFonts.inter` (`lib/core/theme/app_theme.dart`)

## Conventions

- All Dart code uses `package:flutter_riverpod`; never use vanilla `ChangeNotifier` or `setState` for cross-widget state.
- Define state classes and notifiers in `*_provider.dart` files inside each feature folder.
- Screens go in `*_screen.dart`, widgets in `widgets/` subdirectory of the feature.
- `copyWith` pattern on all state classes.
- Use `context.go()` for tab navigation, `context.push()` for detail screens (player is overlayed at root key).
- Prefer `ConsumerWidget` / `ConsumerStatefulWidget` over `StatelessWidget`/`StatefulWidget` when reading providers.

## Storage

- **Auth/settings**: Hive (`lib/core/storage/settings_service.dart`, box name `auth`)
- **Library cache**: drift declared in pubspec but **not wired up** (`database_service.dart` is a stub with TODO)
- `Hive.initFlutter()` is called once in `main()` before `runApp`.

## Project State

- **Early stage**: many stubs and TODOs. Home/search/library all use mock data (hardcoded `_mockTracks` in search, empty state elsewhere).
- **InnerTube API client** is not implemented (`lib/core/network/api_client.dart` is a thin `http` wrapper; `lib/core/network/generated/` is empty).
- **No models yet** (`lib/core/models/` is empty, model classes like `Track` are inlined in `player_provider.dart`).
- **No CI** (no `.github/workflows/`).

## Key References

- `CONTEXT.md` — domain decisions (data APIs, auth flow, design approach)
