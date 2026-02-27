/// Utility class for handling copyright text based on language and Bible version
class CopyrightUtils {
  /// Get the appropriate copyright text for a given language and version
  static String getCopyrightText(String language, String version) {
    const Map<String, Map<String, String>> copyrightMap = {
      'es': {
        'RVR1960':
            'El texto bíblico Reina-Valera 1960® © Sociedades Bíblicas en América Latina, 1960. Derechos renovados 1988, Sociedades Bíblicas Unidas. Usado con permiso.',
        'NVI':
            'El texto bíblico Nueva Versión Internacional® (NVI®) © 1999 Biblica, Inc.® Todos los derechos reservados en todo el mundo.',
        'default':
            'El texto bíblico Reina-Valera 1960® © Sociedades Bíblicas en América Latina, 1960. Derechos renovados 1988, Sociedades Bíblicas Unidas.',
      },
      'en': {
        'KJV': 'The Holy Bible, King James Version (KJV). Public Domain.',
        'NIV':
            'Holy Bible, New International Version®, NIV® Copyright © 1973, 1978, 1984, 2011 by Biblica, Inc.® Used by permission. All rights reserved worldwide.',
        'default': 'The Holy Bible, King James Version (KJV). Public Domain.',
      },
      'pt': {
        'ARC':
            'O texto bíblico Almeida Revista e Corrigida (ARC). Domínio Público.',
        'NVI':
            'O texto bíblico Nova Versão Internacional® (NVI®) © 1993, 2000 Biblica, Inc.® Todos os direitos reservados.',
        'default':
            'O texto bíblico Almeida Revista e Corrigida (ARC). Domínio Público.',
      },
      'fr': {
        'LSG1910': 'La Bible Louis Segond 1910 (LSG). Domaine Public.',
        'BDS':
            'La Bible du Semeur® (BDS) © 1992, 1999, 2015 Société Biblique Internationale. Tous droits réservés.',
        'default': 'La Bible Louis Segond 1910 (LSG). Domaine Public.',
      },
      'zh': {
        'CUV1919': '中文聖經和合本 (CUV) 1919 版。公共領域。',
        'CNVS': '聖經當代譯本修訂版 (CNVS) © 1979, 2010 國際聖經協會。版權所有。',
        'default': '中文聖經和合本 (CUV) 1919 版。公共領域。',
      },
      'hi': {
        'HERV':
            'Hindi Easy-to-Read Version (HERV) © 1995 Bible League International. All rights reserved.',
        'HIOV': 'Hindi Old Version Bible (HIOV). Public Domain.',
        'default': 'Hindi Old Version Bible (HIOV). Public Domain.',
      },
    };

    final langMap = copyrightMap[language] ?? copyrightMap['en']!;
    return langMap[version] ?? langMap['default']!;
  }

  /// Get Bible version display name for TTS
  static String getBibleVersionDisplayName(String language, String version) {
    const Map<String, Map<String, String>> versionNames = {
      'es': {
        'RVR1960': 'Reina-Valera 1960',
        'NVI': 'Nueva Versión Internacional',
      },
      'en': {
        'KJV': 'King James Version',
        'NIV': 'New International Version',
      },
      'pt': {
        'ARC': 'Almeida Revista e Corrigida',
        'NVI': 'Nova Versão Internacional',
      },
      'fr': {
        'LSG1910': 'Louis Segond 1910',
        'BDS': 'Bible du Semeur',
      },
      'zh': {
        'CUV1919': '和合本 1919',
        'CNVS': '當代譯本修訂版',
      },
      'hi': {
        'HERV': 'Hindi Easy-to-Read Version 95',
        'HIOV': 'Hindi Old Version',
      },
    };

    return versionNames[language]?[version] ?? version;
  }
}
