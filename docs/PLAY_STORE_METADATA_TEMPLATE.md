# Phoenix Play Store metadata template

Use sanitized screenshots and verify every statement against the release artifact.

## Listing

- App name: `Phoenix — Local Fitness OS`
- Short description: `Private, offline-first training, nutrition and recovery tools.`
- Category: `Health & Fitness`
- Support contact: `<release owner supplies this>`
- Privacy-policy URL: `<release owner supplies this>`

## Long-description facts

- Local profiles and fitness history are stored on the device.
- Core training, nutrition, recovery, reports and planning work offline.
- Encrypted `.phx` backup/export is explicit and user initiated.
- Camera access is optional and used only after the user opens photo capture.
- Notifications are optional local reminders with quiet-hour controls.
- Phoenix is not a medical device and does not diagnose injury or disease.
- Optional HTTPS media links can open external services; no account is required for core use.

## Required visual assets

- Phone screenshots: Today, active workout, Nutrition, Recovery, Data Reliability.
- Tablet screenshot: responsive navigation rail.
- Feature graphic and high-resolution icon.
- No screenshot may contain a real athlete name, photo, PIN, backup payload, or health history.

## Data-safety review prompts

- Does this exact build transmit any user data? `<verify before every release>`
- Are crash reporting, analytics or advertising SDKs present? `No in the current repository.`
- Can users export and delete their local data? `Yes, through explicit portability and retention controls.`
- Is Android system backup disabled for profile databases? `Yes.`
