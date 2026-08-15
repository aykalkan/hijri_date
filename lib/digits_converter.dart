class DigitsConverter {
  static const List<String> easternArabicNumerals = [
    '٠',
    '١',
    '٢',
    '٣',
    '٤',
    '٥',
    '٦',
    '٧',
    '٨',
    '٩'
  ];

  static const List<String> urduNumerals = [
    '۰',
    '۱',
    '۲',
    '۳',
    '۴',
    '۵',
    '۶',
    '۷',
    '۸',
    '۹'
  ];

  static String convertWesternNumberToEastern(int? easternNumber) {
    String englishNumber = easternNumber.toString();
    StringBuffer stringBuffer = StringBuffer();
    englishNumber.runes.forEach((rune) {
      String character = String.fromCharCode(rune);
      stringBuffer.write(easternArabicNumerals[int.parse(character)]);
    });
    return stringBuffer.toString();
  }

  static String convertWesternNumberToUrdu(int? urduNumber) {
    String englishNumber = urduNumber.toString();
    StringBuffer stringBuffer = StringBuffer();
    englishNumber.runes.forEach((rune) {
      String character = String.fromCharCode(rune);
      stringBuffer.write(urduNumerals[int.parse(character)]);
    });
    return stringBuffer.toString();
  }
}
