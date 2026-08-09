import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'phoenix_l10n.dart';
import 'state/fitness_store.dart';

class VaultSecurityPage extends StatefulWidget {
  const VaultSecurityPage({super.key, required this.store});

  final FitnessStore store;

  @override
  State<VaultSecurityPage> createState() => _VaultSecurityPageState();
}

class _VaultSecurityPageState extends State<VaultSecurityPage> {
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _busy = false;

  @override
  void dispose() {
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = context.l10n;
    if (widget.store.hasVaultPin && !widget.store.vaultUnlocked) {
      setState(() => _busy = true);
      final valid = await widget.store.unlockVault(_pin.text);
      if (mounted) {
        setState(() => _busy = false);
        _message(
          valid
              ? l.text('Το vault ξεκλειδώθηκε.', 'Vault unlocked.')
              : l.text('Λάθος PIN.', 'Incorrect PIN.'),
        );
        if (valid) _pin.clear();
      }
      return;
    }
    if (_pin.text != _confirm.text) {
      _message(l.text('Τα PIN δεν ταιριάζουν.', 'PINs do not match.'));
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.store.setVaultPin(_pin.text);
      _pin.clear();
      _confirm.clear();
      if (mounted) {
        _message(l.text('Το νέο PIN ενεργοποιήθηκε.', 'New PIN enabled.'));
      }
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove() async {
    final l = context.l10n;
    try {
      await widget.store.removeVaultPin(_pin.text);
      _pin.clear();
      _confirm.clear();
      if (mounted) _message(l.text('Το PIN αφαιρέθηκε.', 'PIN removed.'));
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final l = context.l10n;
        final locked = widget.store.hasVaultPin && !widget.store.vaultUnlocked;
        return Scaffold(
          appBar: AppBar(
            title: Text(l.text('ΑΣΦΑΛΕΙΑ VAULT', 'VAULT SECURITY')),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
            children: [
              Icon(
                locked ? Icons.lock_outline : Icons.lock_open_outlined,
                size: 66,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 14),
              Text(
                locked
                    ? l.text('Τοπικό vault κλειδωμένο', 'Local vault locked')
                    : widget.store.hasVaultPin
                    ? l.text('Το vault είναι ξεκλείδωτο', 'Vault is unlocked')
                    : l.text(
                        'Προστάτευσε τα exports σου',
                        'Protect your exports',
                      ),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l.text(
                  'Το PIN έχει 4–8 ψηφία και αποθηκεύεται μόνο ως κρυπτογραφικό αποτύπωμα SHA-256 στη συσκευή.',
                  'The 4–8 digit PIN is stored only as a SHA-256 cryptographic fingerprint on this device.',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _pin,
                keyboardType: TextInputType.number,
                obscureText: _obscure,
                maxLength: 8,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: locked
                      ? l.text('PIN ξεκλειδώματος', 'Unlock PIN')
                      : widget.store.hasVaultPin
                      ? l.text('Τρέχον ή νέο PIN', 'Current or new PIN')
                      : l.text('Νέο PIN', 'New PIN'),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
              if (!locked) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _confirm,
                  keyboardType: TextInputType.number,
                  obscureText: _obscure,
                  maxLength: 8,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: l.text(
                      'Επιβεβαίωση νέου PIN',
                      'Confirm new PIN',
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _busy ? null : _submit,
                icon: Icon(locked ? Icons.lock_open : Icons.shield_outlined),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  child: Text(
                    locked
                        ? l.text('Ξεκλείδωμα', 'Unlock')
                        : l.text(
                            'Ενεργοποίηση / αλλαγή PIN',
                            'Enable / change PIN',
                          ),
                  ),
                ),
              ),
              if (widget.store.hasVaultPin && !locked) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    widget.store.lockVault();
                    _pin.clear();
                    _confirm.clear();
                  },
                  icon: const Icon(Icons.lock_clock_outlined),
                  label: Text(l.text('Κλείδωμα τώρα', 'Lock now')),
                ),
                TextButton.icon(
                  onPressed: _remove,
                  icon: const Icon(Icons.no_encryption_outlined),
                  label: Text(l.text('Αφαίρεση PIN', 'Remove PIN')),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
