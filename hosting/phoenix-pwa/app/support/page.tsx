import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Υποστήριξη — Phoenix",
  description: "Βοήθεια για εγκατάσταση, δεδομένα, backup και χρήση του Phoenix.",
};

export default function SupportPage() {
  return (
    <main className="legal-shell">
      <article className="legal-card">
        <header className="legal-topbar">
          <span className="legal-brand">PHOENIX · SUPPORT</span>
          <Link className="legal-back" href="/">
            ← Αρχική
          </Link>
        </header>

        <h1>Είμαστε εδώ για να βοηθήσουμε.</h1>
        <p className="legal-intro">
          Απλές απαντήσεις για την εγκατάσταση, την ιδιωτικότητα και τη
          μεταφορά των τοπικών δεδομένων σου.
        </p>

        <div className="support-grid">
          <a className="support-action primary" href="/app/">
            <strong>Άνοιγμα Phoenix</strong>
            <span>Μπες στην εφαρμογή από αυτή τη συσκευή.</span>
          </a>
          <a
            className="support-action"
            href="https://github.com/dmavrofidis/Phoenix/issues"
            rel="noreferrer"
            target="_blank"
          >
            <strong>Αναφορά προβλήματος</strong>
            <span>Άνοιξε ένα ασφαλές, δημόσιο GitHub issue χωρίς προσωπικά δεδομένα.</span>
          </a>
          <Link className="support-action" href="/privacy">
            <strong>Πολιτική Απορρήτου</strong>
            <span>Δες ακριβώς τι μένει στη συσκευή σου.</span>
          </Link>
          <Link className="support-action" href="/">
            <strong>Εγκατάσταση σε iPhone</strong>
            <span>Οδηγίες για προσθήκη στην οθόνη Αφετηρίας.</span>
          </Link>
        </div>

        <section className="legal-section" lang="el">
          <h2>Συχνές ερωτήσεις</h2>

          <div className="faq-item">
            <h3>Πού αποθηκεύονται τα δεδομένα μου;</h3>
            <p>
              Στη συσκευή σου. Το Phoenix δεν απαιτεί λογαριασμό και δεν
              στέλνει σιωπηρά το ιστορικό σου σε server.
            </p>
          </div>

          <div className="faq-item">
            <h3>Πώς μεταφέρω το Phoenix σε άλλη συσκευή;</h3>
            <p>
              Άνοιξε «Εγώ» → «Μεταφορά σε άλλη συσκευή» και δημιούργησε ένα
              κρυπτογραφημένο backup. Μετέφερε το αρχείο με τον τρόπο που
              επιλέγεις και κάνε εισαγωγή στη νέα συσκευή.
            </p>
          </div>

          <div className="faq-item">
            <h3>Τι γίνεται αν αρνηθώ κάμερα ή ειδοποιήσεις;</h3>
            <p>
              Η βασική εφαρμογή συνεχίζει να λειτουργεί. Απλώς δεν θα μπορείς
              να φωτογραφίσεις γεύμα ή να λαμβάνεις τοπικές υπενθυμίσεις μέχρι
              να αλλάξεις την άδεια από τις ρυθμίσεις της συσκευής.
            </p>
          </div>

          <div className="faq-item">
            <h3>Πώς διαγράφω τα δεδομένα μου;</h3>
            <p>
              Χρησιμοποίησε τις επιλογές διαγραφής στο Data Vault/Control
              Center ή αφαίρεσε την εφαρμογή μαζί με τα τοπικά δεδομένα της.
              Διέγραψε ξεχωριστά και όσα backup έχεις εξαγάγει.
            </p>
          </div>

          <div className="faq-item">
            <h3>Μπορώ να ζητήσω ιατρική συμβουλή από το Phoenix;</h3>
            <p>
              Όχι. Το Phoenix προσφέρει γενικές πληροφορίες άσκησης και
              ευεξίας και δεν αντικαθιστά επαγγελματία υγείας. Μην ανεβάζεις
              προσωπικά ή ιατρικά δεδομένα σε δημόσιο issue.
            </p>
          </div>
        </section>

        <section className="legal-section" lang="en">
          <h2>English support summary</h2>
          <p>
            Phoenix stores fitness and nutrition information locally. For a
            device transfer, use <strong>Me → Transfer to another device</strong>
            and create an encrypted backup. Camera and notifications are
            optional. For a bug report, use the GitHub link above and never
            include personal, health, photo, PIN, or backup data.
          </p>
        </section>

        <section className="legal-section" lang="de">
          <h2>Kurze Hilfe auf Deutsch</h2>
          <p>
            Phoenix speichert Fitness- und Ernährungsdaten lokal. Für den
            Gerätewechsel nutze <strong>Ich → Auf ein anderes Gerät übertragen</strong>
            und erstelle eine verschlüsselte Sicherung. Kamera und
            Benachrichtigungen sind optional. Teile in öffentlichen
            Fehlermeldungen niemals Gesundheitsdaten, Fotos, PINs oder Backups.
          </p>
        </section>
      </article>
    </main>
  );
}
