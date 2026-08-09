import 'package:flutter/material.dart';

class PhoenixL10n {
  const PhoenixL10n(this.locale);

  final Locale locale;

  /// Non-Greek locales use the complete English fallback until a string has
  /// an explicit locale-catalog translation.
  bool get isEnglish => locale.languageCode != 'el';

  String text(String greek, String english) => isEnglish ? english : greek;

  static PhoenixL10n of(BuildContext context) =>
      PhoenixL10n(Localizations.localeOf(context));
}

extension PhoenixLocalization on BuildContext {
  PhoenixL10n get l10n => PhoenixL10n.of(this);
}
