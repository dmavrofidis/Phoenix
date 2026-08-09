# Phoenix 1.1 release-candidate handoff

Candidate: `1.1.0+2` / proposed tag `v1.1.0-rc.1`.

## Included hardening

- Recovery Vault with checksum verification, quarantine visibility and reversible restore.
- Provider-neutral encrypted device-sync packages with explicit conflict resolution.
- Expanded reviewed German/Spanish application-shell translations and explicit English fallback.
- Local performance profiling for serialization, deserialization, validation, reconciliation, payload size and SQLite reliability queries.
- Responsive, semantic, migration, malformed-import and PWA contract tests.
- Production signing now fails closed; a release can never silently use the Android debug key.
- Private GitHub quality and signed-release workflows with APK/AAB checksums.

Evidence: `docs/UI_UX_AUDIT.md` and `docs/PERFORMANCE_BASELINE.md`.

## External release-owner gates

- Supply a private Android upload keystore and credentials.
- Run the signed release workflow on the private GitHub repository.
- Install the signed APK on representative Android phone/tablet hardware and complete the manual smoke checklist.
- Review store screenshots, privacy policy, data-safety answers and German/Spanish feature-specific copy.

No Android SDK, signing key or GitHub credentials are created or installed by repository scripts.
