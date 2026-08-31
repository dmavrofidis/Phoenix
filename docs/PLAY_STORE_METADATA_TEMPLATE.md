# Phoenix Play Store metadata template

Use sanitized screenshots and verify every statement against the release artifact.

## Listing

- App name: `Phoenix Fitness`
- Short description: `Simple fitness and nutrition, with your personal data kept on your device.`
- Category: `Health & Fitness`
- Support contact: `<release owner supplies this>`
- Support URL: `https://phoenix-fitness-local.d-mavrofidis.chatgpt.site/support`
- Privacy-policy URL: `https://phoenix-fitness-local.d-mavrofidis.chatgpt.site/privacy`

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

- Does this exact build collect or share user data off the device? `No.`
- Are crash reporting, analytics or advertising SDKs present? `No in the current repository.`
- Can users export and delete their local data? `Yes, through explicit portability and retention controls.`
- Is Android system backup disabled for profile databases? `Yes.`

## Health apps declaration

- Activity and fitness: `Yes`
- Nutrition and weight management: `Yes`
- Sleep management: `Yes`
- Stress management, relaxation, mental acuity: `Yes`
- Medical categories or medical-device status: `No`
- Health Connect access: `No`

Use this disclaimer in the full description:

> Phoenix is not a medical device and does not diagnose, treat, cure, or
> prevent any medical condition. Consult a qualified healthcare professional
> for medical advice, diagnosis, or treatment.
