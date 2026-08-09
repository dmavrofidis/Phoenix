import 'package:flutter/material.dart';

class PhoenixL10n {
  const PhoenixL10n(this.locale);

  final Locale locale;

  bool get isEnglish => locale.languageCode == 'en';

  String text(String greek, String english) => isEnglish ? english : greek;

  static PhoenixL10n of(BuildContext context) =>
      PhoenixL10n(Localizations.localeOf(context));
}

extension PhoenixLocalization on BuildContext {
  PhoenixL10n get l10n => PhoenixL10n.of(this);
}
