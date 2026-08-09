# Phoenix

Local-first fitness app in Flutter. The app builds deterministic training
templates from the user's goal, experience, available equipment, training
location, weekly frequency, and session duration. All profile, workout,
nutrition, weight, and Spotify-link data stays on the device.

## Current modules

- Phoenix Today home with focused daily actions
- categorized, searchable Toolbox for the complete feature set
- Reports Studio for local progress and coach-handoff reports
- Photo Meal Scan with local photo history and transparent estimates
- native JSON backup file import/export for moving the complete local profile
- operating-system workout reminders with weekly rescheduling
- Greek onboarding with 10 personalization inputs
- daily mission that advances through the correct training rotation
- current-week target and completion progress on the dashboard
- per-exercise prescriptions for working sets, rep/hold range, RIR, tempo, and rest
- automatic migration that enriches existing programs without deleting history
- IRON UPPER, IRON LOWER, IRON HYBRID, and IRON ENGINE programs
- strict and weighted calisthenics, plus a separate skill session
- beginner regressions and equipment-aware home alternatives
- offline visual exercise guides with start/finish positions and technique cues
- set logging for reps, load, holds, and RIR
- automatic rest timer based on each program
- progression suggestions, records, history, and charts
- nutrition log with calories and macro targets
- optional Spotify playlist, album, or track link

## Training design

“Hardcore” means demanding basics executed with control. Every template includes
a set/rep target, RIR target, rest period, and a technical-stop cue. The generator
does not prescribe kipping, forced reps, repeated maximal attempts, unstable
novelty exercises, or mandatory training to failure.

The program engine distinguishes heavy compounds, unilateral movements,
bodyweight strength, accessories, isometrics, and conditioning. Progression
returns to the lower end of the prescribed range after a load increase, while
exercise-specific rest automatically starts after every logged set.

## Run

```powershell
flutter pub get
flutter run
```

For the web build:

```powershell
flutter build web --release --no-tree-shake-icons
```

## Quality status

- `flutter analyze`: no issues
- `flutter test`: 351/351 passing
- `flutter build web --release`: passing
- Android and Windows native build prerequisites are not installed on this
  workstation; their manifests, generated plugin registrants, and platform
  configuration are committed with the app.
