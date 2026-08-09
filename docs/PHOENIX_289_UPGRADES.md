# Phoenix — 289-upgrade delivery record

Date: 2026-08-07  
Scope: roadmap identifiers **#279 through #567 inclusive**  
Count: `567 - 279 + 1 = 289`

## What “delivered” means

Every identifier in this range has a real, searchable entry in Capability Studio with:

- a stable unique ID and title;
- a persisted enabled state, conservative/balanced/progressive mode and 0–100 guard level;
- a private local note, execution count, last result and evidence score;
- deterministic on-device evaluation against the current `FitnessData` snapshot;
- local audit output with no account, telemetry or mandatory network request.

The catalog test asserts exactly 289 unique consecutive IDs. This operational layer is intentionally paired with deeper product packs for the highest-impact groups below. A control entry is not described as a complete external integration or medical capability when Phoenix cannot honestly provide one.

## Delivery matrix

| Batch | IDs | Area | Concrete delivery |
|---|---:|---|---|
| 28 | 279–280 | Reports Studio | Local report controls and auditable report evidence. |
| 29 | 281–290 | Local Collaboration | Signed, checksummed, expiring PHXC1 share codes; redacted read-only coach views; conflict preview; local feedback notes. |
| 30 | 291–300 | Education and Media | Nine offline lessons covering cues, errors, breathing, tempo, RPE/RIR, pain versus effort, warm-up, nutrition and recovery, with contextual search and stop rules. |
| 31 | 301–310 | Accessibility Plus | Text scaling, reduced motion, color-vision palettes, readability font, one-hand padding, touch-target scaling, voice labels, keyboard traversal and an availability self-check. |
| 32 | 311–320 | Privacy and Security | AES-256-GCM backups, PBKDF2 derivation, profile PIN cooldown, privacy shield, secure clipboard timeout, retention controls and undo. |
| 33 | 321–330 | Import and Export | Generic/Strong/Hevy workout CSV, nutrition CSV, GPX, ICS, schema map, incremental backup and selective restore with preview/deduplication. |
| 34 | 331–340 | Integrations Hub | Explicit local configuration/audit controls and guarded boundaries; no fabricated remote connection or mandatory cloud dependency. |
| 35 | 341–350 | Wearable Intelligence | Fourteen-day personal medians, source comparison, completeness score, missing-data penalties, readiness contribution and quality alerts. HRV remains explicitly unavailable until captured. |
| 36 | 351–360 | Gamification | Data-derived XP, athlete levels, skill XP, badges and rarity without engagement telemetry. |
| 37 | 361–370 | Challenges | Strength, mobility, steps, nutrition and recovery templates, hard safety ceilings, active-day tracking and local completion reports. |
| 38 | 371–380 | Onboarding Plus | Ten modular checks, confidence, schedule reality, goal trade-off, privacy boundary and next actions. |
| 39 | 381–390 | Workout Experience | Persisted per-capability experience controls plus evidence-based set completeness and focused operational modes. |
| 40 | 391–400 | Timer and Audio | Concurrent EMOM, AMRAP, Tabata and custom interval timers, start countdown, phases/rounds, semantics, preference-aware cues and local completion history. |
| 41 | 401–410 | Advanced Logging | Reps/hold, load, RIR, set RPE, velocity and technique completeness scoring, with missing-field disclosure. |
| 42 | 411–420 | Planner and Calendar | Month view combining date/weekly plans, completions, density conflicts and deload markers. |
| 43 | 421–430 | Injury-Aware Training | Symptom check, pain trend, tolerance map, bounded load/range modification, isometric fallback, four return stages, recurrence flags, care boundary and handoff note. |
| 44 | 431–440 | Periodization Plus | Linear, undulating and block plans, accumulation/intensification/realization, pivot/deload criteria, taper and bounded ramps. |
| 45 | 441–450 | Performance Testing | Eight field tests, stop rules, normalized personal radar, lowest measured category and six-week retest scheduling. |
| 46 | 451–460 | Sports Conditioning | Sport-demand scores, acceleration/agility/landing/power sessions, sprint ceiling, in-season volume reduction and competition-week taper. |
| 47 | 461–470 | Outdoor Training | Outdoor context tags, verified-data boundary and weather/daylight/route/equipment safety checklist. |
| 48 | 471–480 | Travel Training | Hotel/no-equipment/band plans, 15-minute mode, unfamiliar-equipment check, streak protection and return-home ramp. |
| 49 | 481–490 | Adaptive Training | Seated, low-impact, balance-supported, range-, sensory- and fatigue-limited plans with functional exercises and explicit constraints. |
| 50 | 491–500 | Life-Stage Options | Teen, older-adult, pregnancy, postpartum and menopause tags with privacy controls, conservative limits and professional-guidance boundaries. |
| 51 | 501–510 | Dashboard Studio | Goal presets, card reordering, compact density, pinned priorities, quick entries, honest empty states, reset and portable local layout backup. |
| 52 | 511–520 | Smart Reminders | Overnight quiet hours, quiet-aware snooze, context candidates, workout/water/meal/measurement reasons, delivery-history inputs, minimum spacing and daily fatigue cap. |
| 53 | 521–530 | Localization | German/Spanish core catalog, English fallback, locale-aware dates/decimals, coverage report, RTL groundwork and language setting import/export. This is documented as a core catalog—not a falsely claimed full-app translation. |
| 54 | 531–540 | Desktop and PWA | Responsive navigation rail, Ctrl+1–4 shortcuts, install/update/connectivity events, cache diagnostics, local maintenance sync event, share target and JSON/PHX/CSV/GPX file-handler declarations. |
| 55 | 541–550 | Android Production | Existing notification channel plus deep-link groundwork, cloud/device-backup exclusion, cleartext denial, permission/privacy audit, icon/splash checklist, metadata template and pre-release checklist. Signing and store upload remain human release actions. |
| 56 | 551–560 | Performance | On-device JSON timing plus explicit budgets for startup, queries, serialization, frames, rebuilds, bundle and image memory; unmeasured values remain labelled “not measured.” |
| 57 | 561–567 | Data Reliability | Drift schema v4 checksums, five verified snapshots, transactional profile switch, corruption quarantine/recovery, migration-safe snapshots and deterministic duplicate reconciliation with undo. |

## New user-facing studios

- **Capability Studio 289** — all 289 persisted operational controls and audits.
- **Education Library** — offline coaching and safety lessons.
- **Local Collaboration** — expiring redacted codes and local notes.
- **Structured Import / Export** — preview-first portable data interchange.
- **Athlete Intelligence** — wearables, XP, challenges, assessment and calendar.
- **Interval Timer Lab** — concurrent preset/custom timers.
- **Safety & Adaptation** — symptoms, phases, tests, sport and adaptive plans.
- **Operations Studio** — dashboard, reminders, locales, performance and reliability.

All are reachable from the searchable Phoenix Toolbox.

## Storage and privacy guarantees

- Existing `FitnessData` JSON remains backward compatible.
- Capability state is stored inside the isolated local profile.
- Database writes create verified rotating snapshots before replacement.
- A checksum failure quarantines the suspect payload and restores only a verified snapshot; Phoenix does not silently overwrite it.
- Critical reconciliation and retention mutations preserve one-step undo.
- Collaboration exports exclude photos, PIN material and authentication tokens; redacted exports can also exclude nutrition.
- Android system backup excludes Phoenix databases/preferences/files; cross-device continuity uses explicit encrypted export.
- No analytics SDK, ad identifier, mandatory account or background upload was added.

## Automated evidence

The final verification gate is:

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --release
```

The test suite includes catalog cardinality/continuity, persistence round trips, encryption rejection, accessibility bounds, imports, collaboration expiry/redaction, wearable quality, challenges, timer phases, injury red flags, periodization, test batteries, adaptive plans, dashboard backups, reminder fatigue protection, locale parsing, responsive keyboard navigation, checksums, snapshot rotation, quarantine recovery and duplicate reconciliation.

Final observed results on 2026-08-07:

- format gate: pass, 128 Dart files unchanged;
- Flutter analysis: pass, no issues;
- Flutter tests: pass, **391/391**;
- production web build: pass;
- web Wasm dry run: pass;
- release `main.dart.js`: approximately **5.99 MiB**, within the 12 MiB application-code budget;
- PWA manifest JSON and Android XML configuration parse checks: pass.

## Commits

- `6adec16` — 289-upgrade capability foundation
- `7885b0e` — athlete intelligence and interval tools
- `9edc849` — safety adaptation and sport planning
- `fa67ce6` — operations studio and reliability safeguards

Final verification/documentation is committed separately after the release build.
