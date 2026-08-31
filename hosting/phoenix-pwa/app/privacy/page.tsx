/* eslint-disable @next/next/no-html-link-for-pages -- Vinext renders these static legal routes reliably with native anchors. */
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Πολιτική Απορρήτου — Phoenix",
  description:
    "Πώς το Phoenix προστατεύει τα δεδομένα άσκησης, διατροφής και ευεξίας.",
};

export default function PrivacyPage() {
  return (
    <main className="legal-shell">
      <article className="legal-card">
        <header className="legal-topbar">
          <span className="legal-brand">PHOENIX · LOCAL-FIRST</span>
          <a className="legal-back" href="/">
            ← Αρχική
          </a>
        </header>

        <h1>Πολιτική Απορρήτου</h1>
        <p className="legal-intro">
          Το Phoenix σχεδιάστηκε ώστε τα προσωπικά δεδομένα άσκησης και
          διατροφής να παραμένουν στη συσκευή του χρήστη.
        </p>

        <nav className="language-links" aria-label="Γλώσσες πολιτικής">
          <a href="#el">Ελληνικά</a>
          <a href="#en">English</a>
          <a href="#de">Deutsch</a>
        </nav>

        <section className="legal-section" id="el" lang="el">
          <h2>Ελληνικά</h2>
          <p className="legal-date">Τελευταία ενημέρωση: 31 Αυγούστου 2026</p>

          <h3>1. Η βασική αρχή</h3>
          <p>
            Το Phoenix είναι εφαρμογή local-first. Δεν απαιτεί λογαριασμό και
            ο δημιουργός της εφαρμογής δεν λαμβάνει το προφίλ, τις
            προπονήσεις, τα γεύματα, το βάρος, τις φωτογραφίες ή τις
            καταγραφές ευεξίας του χρήστη.
          </p>

          <h3>2. Δεδομένα που αποθηκεύονται τοπικά</h3>
          <ul>
            <li>στόχοι, προτιμήσεις, διαθέσιμος εξοπλισμός και πρόγραμμα,</li>
            <li>προπονήσεις, σετ, επαναλήψεις, φορτία και πρόοδος,</li>
            <li>γεύματα, θερμίδες, μακροθρεπτικά, νερό και βάρος,</li>
            <li>ύπνος, κόπωση, ετοιμότητα και άλλες προαιρετικές σημειώσεις,</li>
            <li>φωτογραφίες που επιλέγει ρητά ο χρήστης,</li>
            <li>ρυθμίσεις, υπενθυμίσεις και προαιρετικοί σύνδεσμοι μουσικής.</li>
          </ul>
          <p>
            Αυτά τα δεδομένα αποθηκεύονται στη συσκευή. Παραμένουν εκεί μέχρι
            να τα διαγράψει ο χρήστης μέσα από την εφαρμογή ή να αφαιρέσει την
            εφαρμογή και τα τοπικά της δεδομένα.
          </p>

          <h3>3. Κάμερα, φωτογραφίες και ειδοποιήσεις</h3>
          <p>
            Η πρόσβαση στην κάμερα ή στη συλλογή φωτογραφιών ζητείται μόνο όταν
            ο χρήστης επιλέγει σχετική λειτουργία. Οι ειδοποιήσεις είναι
            προαιρετικές, δημιουργούνται τοπικά και μπορούν να απενεργοποιηθούν
            από τις ρυθμίσεις της συσκευής.
          </p>

          <h3>4. Διαδίκτυο και εξωτερικές υπηρεσίες</h3>
          <p>
            Η web έκδοση χρειάζεται σύνδεση για την πρώτη φόρτωση και μπορεί
            μετά να λειτουργεί offline. Το Phoenix μπορεί επίσης, μόνο μετά από
            επιλογή του χρήστη, να ανοίξει έναν σύνδεσμο Spotify, Apple Music ή
            άλλο HTTPS περιεχόμενο σε εξωτερική υπηρεσία. Από εκείνο το σημείο
            ισχύει η πολιτική της αντίστοιχης υπηρεσίας.
          </p>

          <h3>5. Εξαγωγή και μεταφορά</h3>
          <p>
            Η δημιουργία backup ή η κοινοποίησή του γίνεται αποκλειστικά μετά
            από ενέργεια του χρήστη. Ο χρήστης επιλέγει πού θα αποθηκευτεί ή σε
            ποια εφαρμογή θα σταλεί το αρχείο. Το Phoenix δεν ανεβάζει σιωπηρά
            αντίγραφα ασφαλείας σε cloud.
          </p>

          <h3>6. Tracking, διαφημίσεις και πωλήσεις δεδομένων</h3>
          <p>
            Η τρέχουσα έκδοση δεν περιλαμβάνει διαφημίσεις, analytics SDK,
            advertising identifier ή μηχανισμό πώλησης προσωπικών δεδομένων.
          </p>

          <h3>7. Υγεία και ασφάλεια</h3>
          <p>
            Το Phoenix είναι εργαλείο γενικής άσκησης και ευεξίας. Δεν είναι
            ιατρική συσκευή, δεν κάνει διάγνωση και δεν αντικαθιστά γιατρό,
            φυσικοθεραπευτή ή διαιτολόγο. Ο χρήστης πρέπει να σταματά όταν
            αισθάνεται πόνο, ζάλη ή ασυνήθιστη δυσφορία και να ζητά κατάλληλη
            επαγγελματική συμβουλή.
          </p>

          <h3>8. Παιδιά</h3>
          <p>
            Η εφαρμογή δεν απευθύνεται ειδικά σε παιδιά. Ανήλικοι πρέπει να τη
            χρησιμοποιούν μόνο με τη γνώση και επίβλεψη γονέα ή κηδεμόνα.
          </p>

          <h3>9. Επικοινωνία</h3>
          <p>
            Για ερωτήσεις απορρήτου ή υποστήριξη, χρησιμοποίησε τη σελίδα
            <a href="/support"> Υποστήριξης Phoenix</a>.
          </p>
        </section>

        <section className="legal-section" id="en" lang="en">
          <h2>English</h2>
          <p className="legal-date">Last updated: August 31, 2026</p>

          <h3>1. Core principle</h3>
          <p>
            Phoenix is a local-first app. No account is required, and the app
            developer does not receive the user&apos;s profile, workouts, meals,
            weight, photos, or wellbeing logs.
          </p>

          <h3>2. Data stored on the device</h3>
          <ul>
            <li>goals, preferences, available equipment, and training plan,</li>
            <li>workouts, sets, repetitions, loads, and progress,</li>
            <li>meals, calories, macros, hydration, and weight,</li>
            <li>sleep, fatigue, readiness, and optional notes,</li>
            <li>photos explicitly selected by the user,</li>
            <li>settings, reminders, and optional music links.</li>
          </ul>
          <p>
            This information remains on the device until the user deletes it
            in Phoenix or removes the app and its local data.
          </p>

          <h3>3. Camera, photos, and notifications</h3>
          <p>
            Camera or photo-library access is requested only when the user
            opens a related feature. Notifications are optional, scheduled
            locally, and can be disabled in system settings.
          </p>

          <h3>4. Internet and external services</h3>
          <p>
            The web version needs a connection for its first load and can then
            work offline. At the user&apos;s request, Phoenix can open Spotify,
            Apple Music, or other HTTPS content in an external service. That
            service&apos;s privacy policy applies after it opens.
          </p>

          <h3>5. Export and transfer</h3>
          <p>
            Backups are created or shared only after an explicit user action.
            The user chooses the destination. Phoenix does not silently upload
            backups to a cloud service.
          </p>

          <h3>6. Tracking, advertising, and data sales</h3>
          <p>
            The current version contains no advertising, analytics SDK,
            advertising identifier, or mechanism for selling personal data.
          </p>

          <h3>7. Health and safety</h3>
          <p>
            Phoenix is a general fitness and wellbeing tool. It is not a
            medical device, does not diagnose conditions, and does not replace
            a doctor, physiotherapist, or registered dietitian. Stop exercising
            if you feel pain, dizziness, or unusual discomfort and seek
            appropriate professional advice.
          </p>

          <h3>8. Children</h3>
          <p>
            Phoenix is not specifically directed at children. Minors should
            use it only with the knowledge and supervision of a parent or legal
            guardian.
          </p>

          <h3>9. Contact</h3>
          <p>
            For privacy questions or assistance, visit
            <a href="/support"> Phoenix Support</a>.
          </p>
        </section>

        <section className="legal-section" id="de" lang="de">
          <h2>Deutsch</h2>
          <p className="legal-date">Letzte Aktualisierung: 31. August 2026</p>

          <h3>1. Grundprinzip</h3>
          <p>
            Phoenix ist eine Local-First-App. Es ist kein Konto erforderlich,
            und der Entwickler erhält weder das Profil noch Trainings-,
            Ernährungs-, Gewichts-, Foto- oder Wohlbefindensdaten der Nutzer.
          </p>

          <h3>2. Auf dem Gerät gespeicherte Daten</h3>
          <ul>
            <li>Ziele, Einstellungen, verfügbare Geräte und Trainingsplan,</li>
            <li>Trainingseinheiten, Sätze, Wiederholungen, Gewichte und Fortschritt,</li>
            <li>Mahlzeiten, Kalorien, Makros, Flüssigkeit und Körpergewicht,</li>
            <li>Schlaf, Ermüdung, Trainingsbereitschaft und optionale Notizen,</li>
            <li>vom Nutzer ausdrücklich ausgewählte Fotos,</li>
            <li>Einstellungen, Erinnerungen und optionale Musiklinks.</li>
          </ul>
          <p>
            Diese Daten bleiben auf dem Gerät, bis der Nutzer sie in Phoenix
            löscht oder die App einschließlich ihrer lokalen Daten entfernt.
          </p>

          <h3>3. Kamera, Fotos und Benachrichtigungen</h3>
          <p>
            Der Zugriff auf Kamera oder Fotomediathek wird nur angefordert,
            wenn der Nutzer eine entsprechende Funktion öffnet.
            Benachrichtigungen sind optional, werden lokal geplant und können
            in den Systemeinstellungen deaktiviert werden.
          </p>

          <h3>4. Internet und externe Dienste</h3>
          <p>
            Die Webversion benötigt für den ersten Start eine Verbindung und
            kann danach offline funktionieren. Auf Wunsch öffnet Phoenix
            Spotify, Apple Music oder andere HTTPS-Inhalte in einem externen
            Dienst. Ab diesem Zeitpunkt gilt dessen Datenschutzerklärung.
          </p>

          <h3>5. Export und Übertragung</h3>
          <p>
            Sicherungen werden nur nach einer ausdrücklichen Aktion des Nutzers
            erstellt oder geteilt. Der Nutzer bestimmt das Ziel. Phoenix lädt
            Sicherungen nicht unbemerkt in einen Cloud-Dienst hoch.
          </p>

          <h3>6. Tracking, Werbung und Datenverkauf</h3>
          <p>
            Die aktuelle Version enthält keine Werbung, kein Analytics-SDK,
            keine Werbe-ID und keinen Mechanismus zum Verkauf persönlicher Daten.
          </p>

          <h3>7. Gesundheit und Sicherheit</h3>
          <p>
            Phoenix ist ein allgemeines Fitness- und Wohlbefindenswerkzeug. Die
            App ist kein Medizinprodukt, stellt keine Diagnosen und ersetzt
            keine ärztliche, physiotherapeutische oder ernährungsmedizinische
            Beratung. Bei Schmerzen, Schwindel oder ungewöhnlichen Beschwerden
            sollte das Training beendet und fachlicher Rat eingeholt werden.
          </p>

          <h3>8. Kinder</h3>
          <p>
            Phoenix richtet sich nicht speziell an Kinder. Minderjährige
            sollten die App nur mit Wissen und Aufsicht eines Elternteils oder
            Erziehungsberechtigten verwenden.
          </p>

          <h3>9. Kontakt</h3>
          <p>
            Bei Datenschutzfragen oder für Unterstützung besuche den
            <a href="/support"> Phoenix-Support</a>.
          </p>
        </section>
      </article>
    </main>
  );
}
