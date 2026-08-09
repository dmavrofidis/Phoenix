# Phoenix working agreement

## Scope

- Phoenix is a local-first Flutter fitness application.
- The active application source is in `mobile/`.
- Keep user profile, workout, nutrition, recovery, media, and analytics data on
  the device unless the user explicitly requests an optional transfer feature.
- Do not introduce mandatory accounts, cloud storage, telemetry, or network
  dependencies.

## Data safety

- Treat existing local data as durable user data.
- Keep JSON and Drift migrations backward-compatible and covered by tests.
- Never reset, delete, or replace a local database as a migration shortcut.
- Keep backup/restore deterministic and validate input before replacing data.
- Store large local media carefully; do not silently upload it.

## Development workflow

- Work from `mobile/` for Flutter commands.
- Format changed Dart files with `dart format`.
- Run `flutter analyze` after source changes.
- Run the complete `flutter test` suite before handing off changes.
- When the Drift schema changes, regenerate `phoenix_database.g.dart` with
  `dart run build_runner build --delete-conflicting-outputs` and test upgrades
  from older schema versions.
- Do not make operating-system or machine-wide configuration changes.

## Current product baseline

- Reports Studio and Photo Meal Scan with local photo history are available.
- The home experience is Phoenix Today with a categorized, searchable Toolbox.
- Flutter analysis is clean and the full test suite passes.
