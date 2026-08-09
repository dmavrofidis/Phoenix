# Phoenix local performance baseline

Measured on 2026-08-07 with Flutter 3.44.8 / Dart 3.12.2 on the local Windows development machine. These are reproducible engineering measurements, not remote telemetry.

## Runtime profiler

Operations Studio now measures the active local profile on demand:

- JSON serialization and deserialization
- data-integrity audit
- deterministic duplicate reconciliation
- encoded profile payload size
- Drift/SQLite reliability queries when Drift is active

Unmeasured budgets remain visibly marked `NOT MEASURED`; Phoenix does not invent startup, frame, image-memory or bundle measurements at runtime.

## Production web build

Command:

```powershell
flutter build web --release --no-pub
```

Result:

- Build completed successfully; Flutter's Wasm dry run also succeeded.
- `main.dart.js`: 6,322,768 bytes (6.03 MiB), below the 12 MiB JavaScript budget.
- Complete generated `build/web`: 62,026,686 bytes (59.15 MiB), 55 files.
- The complete directory includes several alternative CanvasKit/Skwasm renderer artifacts; it is not the amount downloaded on every browser path.
- Eight source exercise-guide PNGs total 14,109,436 bytes (13.46 MiB). They are the clearest remaining asset-size optimization target, but were preserved in this candidate to avoid changing verified instructional artwork without a visual review.

## Regression gates

- The local profiler compares every measured operation against explicit budgets in `OperationalReadinessEngine`.
- CI performs analyze, all tests and a production web build on every pull request and `main` push.
- A future artwork optimization should preserve dimensions/content, add visual review, compare decoded quality and record before/after bytes here.
