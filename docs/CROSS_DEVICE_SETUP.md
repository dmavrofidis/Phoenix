# Continue Phoenix from another laptop

The safe source-code workflow is a **private GitHub repository**. Phoenix athlete data is not source code and must never be committed; move athlete data only with an encrypted `.phx` backup or the reviewed `.phxsync` package from the app.

## One-time setup on this laptop

1. Create an empty private repository on GitHub. Do not add a README or license there because this repository already has history.
2. From the Phoenix repository root, connect and push:

```powershell
git remote add origin https://github.com/<owner>/<private-repository>.git
git push -u origin main
```

3. In GitHub, confirm repository visibility is **Private** and protect `main` by requiring the `Phoenix Quality Gates` workflow.
4. Never add `.env`, `key.properties`, `.jks`, `.keystore`, `build/`, exported `.phx`, or `.phxsync` files. The repository ignore rules and CI safety check reject the main secret/build patterns.

## Setup on the second laptop

Install Git and Flutter 3.44.8 through your normal, user-approved setup, then:

```powershell
git clone https://github.com/<owner>/<private-repository>.git
cd <private-repository>\mobile
flutter pub get
dart run build_runner build
flutter analyze
flutter test
```

Start a branch before changing code:

```powershell
git switch -c feature/<short-name>
```

Commit and push that branch, open a pull request, and merge only after quality gates pass. On either laptop, run `git pull --ff-only` before starting new work.

## Move local athlete data separately

- For a complete handoff, export `EXPORT ENCRYPTED BACKUP` and import it on the other device.
- If both devices have changed, use `EXPORT ENCRYPTED SYNC`, transport the opaque `.phxsync` file through a private folder/cable, then choose `IMPORT & REVIEW SYNC` on the other device.
- Review changed sections and conflicts before selecting safe merge or incoming state. No sync operation applies before explicit approval, and approved changes are undoable.
- Do not commit either file to Git, even though its contents are encrypted.

## Android release signing

Keep the upload keystore outside Git. Configure it separately on an approved release machine, or store its base64 value and passwords as private GitHub Actions secrets documented in `docs/ANDROID_RELEASE.md`.
