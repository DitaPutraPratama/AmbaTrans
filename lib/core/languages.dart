import 'strings.dart';

/// BCP-47 codes supported by ML Kit Translation -> display names in Bahasa Indonesia.
abstract final class Languages {
  /// Source-language value meaning "detect automatically" (F-11).
  static const auto = 'auto';

  static const _names = <String, String>{
    'af': 'Afrikaans',
    'ar': 'Arab',
    'be': 'Belarusia',
    'bg': 'Bulgaria',
    'bn': 'Bengali',
    'ca': 'Katalan',
    'cs': 'Ceko',
    'cy': 'Wales',
    'da': 'Denmark',
    'de': 'Jerman',
    'el': 'Yunani',
    'en': 'Inggris',
    'eo': 'Esperanto',
    'es': 'Spanyol',
    'et': 'Estonia',
    'fa': 'Persia',
    'fi': 'Finlandia',
    'fr': 'Prancis',
    'ga': 'Irlandia',
    'gl': 'Galisia',
    'gu': 'Gujarat',
    'he': 'Ibrani',
    'hi': 'Hindi',
    'hr': 'Kroasia',
    'ht': 'Kreol Haiti',
    'hu': 'Hungaria',
    'id': 'Indonesia',
    'is': 'Islandia',
    'it': 'Italia',
    'ja': 'Jepang',
    'ka': 'Georgia',
    'kn': 'Kannada',
    'ko': 'Korea',
    'lt': 'Lituania',
    'lv': 'Latvia',
    'mk': 'Makedonia',
    'mr': 'Marathi',
    'ms': 'Melayu',
    'mt': 'Malta',
    'nl': 'Belanda',
    'no': 'Norwegia',
    'pl': 'Polandia',
    'pt': 'Portugis',
    'ro': 'Rumania',
    'ru': 'Rusia',
    'sk': 'Slovakia',
    'sl': 'Slovenia',
    'sq': 'Albania',
    'sv': 'Swedia',
    'sw': 'Swahili',
    'ta': 'Tamil',
    'te': 'Telugu',
    'th': 'Thailand',
    'tl': 'Tagalog',
    'tr': 'Turki',
    'uk': 'Ukraina',
    'ur': 'Urdu',
    'vi': 'Vietnam',
    'zh': 'Mandarin',
  };

  /// All known language codes (without [auto]).
  static Iterable<String> get codes => _names.keys;

  /// Display name for [code]; unknown codes are returned unchanged.
  static String nameOf(String code) =>
      code == auto ? Strings.autoDetect : _names[code] ?? code;
}
