class CopyrightUtils {
  // Get copyright text based on Bible version and language
  static String getCopyright(String versionCode, String languageCode) {
    final key = '${versionCode}_$languageCode';

    return _copyrightTexts[key] ??
        _copyrightTexts[versionCode] ??
        _getDefaultCopyright(languageCode);
  }

  static String _getDefaultCopyright(String languageCode) {
    if (languageCode == 'es') {
      return 'Texto bíblico utilizado con permiso.';
    }
    return 'Biblical text used with permission.';
  }

  static final Map<String, String> _copyrightTexts = {
    // Spanish versions
    'RVR1960':
        'Reina-Valera 1960® © Sociedades Bíblicas en América Latina, 1960. Renovado © Sociedades Bíblicas Unidas, 1988. Utilizado con permiso.',
    'RVR1960_es':
        'Reina-Valera 1960® © Sociedades Bíblicas en América Latina, 1960. Renovado © Sociedades Bíblicas Unidas, 1988. Utilizado con permiso.',
    'RVR1960_en':
        'Reina-Valera 1960® © Latin American Bible Societies, 1960. Renewed © United Bible Societies, 1988. Used with permission.',

    'NTV':
        'Nueva Traducción Viviente, © Tyndale House Foundation, 2010. Todos los derechos reservados.',
    'NTV_es':
        'Nueva Traducción Viviente, © Tyndale House Foundation, 2010. Todos los derechos reservados.',
    'NTV_en':
        'Nueva Traducción Viviente, © Tyndale House Foundation, 2010. All rights reserved.',

    'TLA':
        'Traducción en Lenguaje Actual © Sociedades Bíblicas Unidas, 2002, 2004. Utilizado con permiso.',
    'TLA_es':
        'Traducción en Lenguaje Actual © Sociedades Bíblicas Unidas, 2002, 2004. Utilizado con permiso.',
    'TLA_en':
        'Traducción en Lenguaje Actual © United Bible Societies, 2002, 2004. Used with permission.',

    'Pesh-es':
        'Biblia Peshitta en Español © Instituto Cultural Álef y Tau, A.C., 2016. Todos los derechos reservados.',
    'Pesh-es_es':
        'Biblia Peshitta en Español © Instituto Cultural Álef y Tau, A.C., 2016. Todos los derechos reservados.',
    'Pesh-es_en':
        'Peshitta Bible in Spanish © Alef and Tau Cultural Institute, A.C., 2016. All rights reserved.',

    'RV1865': 'Reina-Valera 1865. Texto de dominio público.',
    'RV1865_es': 'Reina-Valera 1865. Texto de dominio público.',
    'RV1865_en': 'Reina-Valera 1865. Public domain text.',
  };

  // Get version name in the specified language
  static String getVersionName(String versionCode, String languageCode) {
    final key = '${versionCode}_$languageCode';
    return _versionNames[key] ?? _versionNames[versionCode] ?? versionCode;
  }

  static final Map<String, String> _versionNames = {
    'RVR1960': 'Reina Valera 1960',
    'RVR1960_es': 'Reina Valera 1960',
    'RVR1960_en': 'Reina Valera 1960',
    'NTV': 'Nueva Traducción Viviente',
    'NTV_es': 'Nueva Traducción Viviente',
    'NTV_en': 'New Living Translation (Spanish)',
    'TLA': 'Traducción en Lenguaje Actual',
    'TLA_es': 'Traducción en Lenguaje Actual',
    'TLA_en': 'Contemporary Language Translation',
    'Pesh-es': 'Biblia Peshitta',
    'Pesh-es_es': 'Biblia Peshitta',
    'Pesh-es_en': 'Peshitta Bible',
    'RV1865': 'Reina Valera 1865',
    'RV1865_es': 'Reina Valera 1865',
    'RV1865_en': 'Reina Valera 1865',
  };
}
