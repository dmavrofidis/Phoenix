# Phoenix Android release

Το Android package είναι `com.phoenix.fitness`. Η παραγωγική έκδοση απαιτεί
ιδιωτικό upload keystore και δεν αποθηκεύει κωδικούς ή κλειδιά στο repository.

1. Δημιούργησε upload key σύμφωνα με το Play App Signing.
2. Αντέγραψε το `mobile/android/key.properties.example` σε
   `mobile/android/key.properties`.
3. Συμπλήρωσε το απόλυτο path του keystore και τα πραγματικά credentials.
4. Εκτέλεσε:

```powershell
.\scripts\build_android_release.ps1
```

Το script εκτελεί dependency resolution, generated Drift code, formatting,
static analysis, ολόκληρη τη test suite και release AAB με obfuscation. Τα
split debug symbols πρέπει να αποθηκευτούν ιδιωτικά μαζί με κάθε release.

## GitHub Actions secrets

Το workflow `.github/workflows/android-release.yml` απαιτεί:

- `PHOENIX_KEYSTORE_BASE64`
- `PHOENIX_STORE_PASSWORD`
- `PHOENIX_KEY_PASSWORD`
- `PHOENIX_KEY_ALIAS`

Το keystore και το `key.properties` δημιουργούνται μόνο μέσα στον προσωρινό CI
runner και δεν ανεβαίνουν ως artifacts. Το μοναδικό public artifact είναι το
signed `.aab`; τα symbols πρέπει να παραμένουν σε access-controlled storage.
