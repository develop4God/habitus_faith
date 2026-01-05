import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

String formatDevotionalDate(DateTime date, BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode;
  late DateFormat format;
  switch (locale) {
    case 'es':
      // lunes, 5 de enero
      format = DateFormat("EEEE, d 'de' MMMM", 'es');
      break;
    case 'fr':
      // lundi 5 janvier
      format = DateFormat('EEEE d MMMM', 'fr');
      break;
    case 'pt':
      // segunda-feira, 5 de janeiro
      format = DateFormat("EEEE, d 'de' MMMM", 'pt');
      break;
    case 'zh':
      // 星期一 1月5日
      format = DateFormat('EEEE M月d日', 'zh');
      break;
    default:
      // Monday, Jan 5
      format = DateFormat('EEEE, MMM d', 'en');
  }
  String formatted = format.format(date);
  // Capitalize first letter for Latin scripts
  if (['es', 'fr', 'pt', 'en'].contains(locale) && formatted.isNotEmpty) {
    formatted = formatted[0].toUpperCase() + formatted.substring(1);
  }
  return formatted;
}
