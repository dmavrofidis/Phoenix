export default function Home() {
  return (
    <main className="installer-shell">
      <section className="installer-card" aria-labelledby="phoenix-title">
        <div className="brand-row">
          <img
            className="app-icon"
            src="/app/icons/Icon-192.png"
            alt="Εικονίδιο Phoenix"
            width="88"
            height="88"
          />
          <div>
            <p className="eyebrow">PHOENIX · LOCAL-FIRST</p>
            <h1 id="phoenix-title">Η εφαρμογή σου είναι έτοιμη.</h1>
          </div>
        </div>

        <p className="lead">
          Άνοιξε το Phoenix στο iPhone σου. Οι προπονήσεις, τα γεύματα, το
          νερό και οι φωτογραφίες παραμένουν στη συσκευή σου.
        </p>

        <a className="primary-action" href="/app/index.html">
          Άνοιγμα Phoenix
          <span aria-hidden="true">→</span>
        </a>

        <div className="steps" aria-label="Οδηγίες εγκατάστασης στο iPhone">
          <p className="steps-title">Μετά, μέσα από το Safari:</p>
          <ol>
            <li>
              Πάτησε <strong>Κοινοποίηση</strong>.
            </li>
            <li>
              Διάλεξε <strong>Προσθήκη στην οθόνη Αφετηρίας</strong> και
              ενεργοποίησε <strong>Άνοιγμα ως εφαρμογή</strong>.
            </li>
          </ol>
        </div>

        <p className="privacy-note">
          Χωρίς λογαριασμό · Χωρίς tracking · Λειτουργεί και offline μετά την
          πρώτη φόρτωση.
        </p>
      </section>
    </main>
  );
}
