# Phoenix iOS / TestFlight

Το Phoenix διανέμεται σε πραγματικό iPhone μέσω TestFlight. Η εφαρμογή
παραμένει local-first: τα προφίλ, οι προπονήσεις, τα γεύματα και οι φωτογραφίες
μένουν στη συσκευή και δεν προστέθηκε analytics, account ή cloud sync.

## Σταθερή ταυτότητα

- Display name: Phoenix
- Bundle identifier: com.phoenix.fitness
- Version: 1.5.1 (build 10)
- Ελάχιστη έκδοση: iOS 13
- Privacy manifest: χωρίς tracking domains ή δεδομένα που αποστέλλονται εκτός
  συσκευής

Το bundle identifier πρέπει να καταχωριστεί ως explicit App ID στο Apple
Developer account και να χρησιμοποιηθεί και στο App Store Connect app record.

## Απαιτούμενα Apple στοιχεία

Τα παρακάτω μπαίνουν αποκλειστικά ως GitHub Actions secrets και δεν
αποθηκεύονται ποτέ στο repository:

| Secret | Περιεχόμενο |
| --- | --- |
| APPLE_TEAM_ID | Apple Developer Team ID |
| IOS_DISTRIBUTION_CERTIFICATE_BASE64 | Apple Distribution .p12, σε base64 |
| IOS_DISTRIBUTION_CERTIFICATE_PASSWORD | Κωδικός του .p12 |
| IOS_PROVISIONING_PROFILE_BASE64 | App Store Connect provisioning profile για com.phoenix.fitness, σε base64 |
| APP_STORE_CONNECT_API_KEY_ID | App Store Connect API key ID |
| APP_STORE_CONNECT_ISSUER_ID | App Store Connect issuer ID |
| APP_STORE_CONNECT_API_PRIVATE_KEY_BASE64 | Το αντίστοιχο .p8, σε base64 |

Το workflow .github/workflows/ios-testflight.yml εισάγει certificate και
profile σε προσωρινό keychain, κάνει signed archive, εξάγει IPA, γράφει SHA-256
checksum και διαγράφει τα signing αρχεία ακόμη και αν αποτύχει κάποιο βήμα.

## Πρώτη διάθεση

1. Δημιούργησε το explicit App ID com.phoenix.fitness.
2. Δημιούργησε App Store Connect provisioning profile για το ίδιο App ID.
3. Δημιούργησε το Phoenix app record στο App Store Connect.
4. Πρόσθεσε τα παραπάνω secrets στο private GitHub repository.
5. Τρέξε το workflow **Phoenix iOS TestFlight** και ενεργοποίησε
   upload_to_testflight.
6. Όταν ολοκληρωθεί το processing, πρόσθεσε το build σε Internal Testing και
   προσκάλεσε το Apple Account του iPhone.
7. Στο iPhone εγκατέστησε το TestFlight, αποδέξου την πρόσκληση και πάτησε
   **Install**.

## Export compliance

Το Phoenix χρησιμοποιεί τυποποιημένη κρυπτογράφηση για τοπικά, προαιρετικά
encrypted backups. Για αυτό δεν δηλώνεται αυτόματα
ITSAppUsesNonExemptEncryption. Ο Account Holder ή App Manager πρέπει να
απαντήσει το ερωτηματολόγιο App Encryption Documentation στο App Store Connect
και να προσθέσει στο Info.plist μόνο την τιμή ή το compliance key που θα
προκύψει από την Apple.

## Περιορισμός Windows

Το Xcode και η υπογραφή iOS δεν εκτελούνται στα Windows. Η δημιουργία του IPA
γίνεται σε προσωρινό macOS GitHub runner. Χωρίς ενεργό Apple Developer Program,
registered App ID και signing credentials δεν υπάρχει νόμιμα εγκαταστάσιμο IPA
για πραγματικό iPhone.
