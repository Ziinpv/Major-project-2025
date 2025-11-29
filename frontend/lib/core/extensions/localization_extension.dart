import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// Extension để dễ dàng truy cập AppLocalizations
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

