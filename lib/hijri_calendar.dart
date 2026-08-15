library hijri;

import 'digits_converter.dart';
import 'hijri_date.dart';
import 'hijri_array.dart';

class HijriCalendar {
  static String language = 'en';
  late int lengthOfMonth;
  int hDay = 1;
  late int hMonth;
  late int hYear;
  int? wkDay;
  late String longMonthName;
  late String shortMonthName;
  late String dayWeName;
  Map<int, int>? adjustments;

  static Map<String, Map<String, Map<int, String>>> _local = {
    'en': {
      'long': monthNames,
      'short': monthShortNames,
      'days': wdNames,
      'short_days': shortWdNames
    },
    'ar': {
      'long': arMonthNames,
      'short': arMonthShortNames,
      'days': arWkNames,
      'short_days': arShortWdNames
    },
    'tr': {
      'long': trMonthNames,
      'short': trMonthShortNames,
      'days': trWdNames,
      'short_days': trShortWdNames
    },
  };

  // Consider switching to the factory pattern
  factory HijriCalendar.setLocal(String locale) {
    language = locale;
    return HijriCalendar();
  }

  HijriCalendar();

  HijriCalendar.fromDate(DateTime date) {
    gregorianToHijri(date);
  }

  HijriCalendar.now() {
    this._now();
  }

  HijriCalendar.addMonth(int year, int month) {
    hYear = month % 12 == 0 ? year - 1 : year;
    hMonth = month % 12 == 0 ? 12 : month % 12;
    hDay = 1;
  }

  HijriCalendar.addLocale(String locale, Map<String, Map<int, String>> names) {
    _local[locale] = names;
  }

  String _now() {
    return gregorianToHijri(DateTime.now());
  }

  int getDaysInMonth(int year, int month) {
    int i = _getNewMoonMJDNIndex(year, month);
    return _ummalquraDataIndex(i)! - _ummalquraDataIndex(i - 1)!;
  }

  int _gMod(int n, int m) {
    // generalized modulo function (n mod m) also valid for negative values of n
    return ((n % m) + m) % m;
  }

  int _getNewMoonMJDNIndex(int hy, int hm) {
    int cYears = hy - 1, totalMonths = (cYears * 12) + 1 + (hm - 1);
    return totalMonths - 16260;
  }

  int lengthOfYear({int? year = 0}) {
    int total = 0;
    if (year == 0) year = this.hYear;
    for (int m = 0; m <= 11; m++) {
      total += getDaysInMonth(year!, m);
    }
    return total;
  }

  DateTime hijriToGregorian(year, month, day) {
    int iy = year;
    int im = month;
    int id = day;
    int ii = iy - 1;
    int iln = (ii * 12) + 1 + (im - 1);
    int i = iln - 16260;
    int mcjdn = id + _ummalquraDataIndex(i - 1)! - 1;
    int cjdn = mcjdn + 2400000;
    return julianToGregorian(cjdn);
  }

  DateTime julianToGregorian(julianDate) {
    //source from: http://keith-wood.name/calendars.html
    int z = (julianDate + 0.5).floor();
    int a = ((z - 1867216.25) / 36524.25).floor();
    a = z + 1 + a - (a / 4).floor();
    int b = a + 1524;
    int c = ((b - 122.1) / 365.25).floor();
    int d = (365.25 * c).floor();
    int e = ((b - d) / 30.6001).floor();
    int day = b - d - (e * 30.6001).floor();
    //var wd = _gMod(julianDate + 1, 7) + 1;
    int month = e - (e > 13.5 ? 13 : 1);
    int year = c - (month > 2.5 ? 4716 : 4715);
    if (year <= 0) {
      year--;
    } // No year zero
    return DateTime(year, (month), day);
  }

  String gregorianToHijri(DateTime date) {
    DateTime truncDate = DateTime(date.year, date.month, date.day);
    wkDay = truncDate.weekday;

    HijriDate hijriDateObject =
        hijriDatesCache.putIfAbsent(truncDate, () => fillCache(truncDate));

    return hDate(
        hijriDateObject.year, hijriDateObject.month, hijriDateObject.day);
  }

  HijriDate fillCache(DateTime date) {
    //print("!!! DATE IS ABSENT !!!");
    //print("Date : ${date}");

    DateTime minDate = parseDateFromInt(dateMap.keys.first);
    DateTime maxDate = parseDateFromInt(dateMap.keys.last);
    maxDate = DateTime(maxDate.year, maxDate.month, maxDate.day + 30);
    if (date.isBefore(minDate) ||
        date.isAfter(maxDate) ||
        date.isAtSameMomentAs(maxDate)) {
      throw new Exception(
          "Selected date should between $minDate and $maxDate.");
    }

    if (hijriDatesCache.length > 180) {
      for (int i = 0; i < hijriDatesCache.length - 180; i++) {
        //print(
        //    "Removing ${hijriDatesCache.keys.elementAt(i)} -> ${hijriDatesCache.values.elementAt(i)}");
        hijriDatesCache.remove(hijriDatesCache.keys.elementAt(i));
      }
    }

    String dateString = (date.year.toString() +
        date.month.toString().padLeft(2, '0') +
        date.day.toString().padLeft(2, '0'));
    int dateInt = int.parse(dateString);

    int i = dateMap.length - 1;

    for (; i >= 0; i--) {
      if (dateMap.keys.elementAt(i) <= dateInt) {
        break;
      }
    }

    DateTime monthStartDate = parseDateFromInt(dateMap.keys.elementAt(i));
    DateTime monthEndDate;
    try {
      monthEndDate = parseDateFromInt(dateMap.keys.elementAt(i + 1));
    } catch (e) {
      monthEndDate = DateTime(maxDate.year, maxDate.month, maxDate.day);
    }
    HijriDate monthStartHijri = parseHijriFromInt(dateMap.values.elementAt(i));

    for (DateTime calculatedDate = monthStartDate;
        calculatedDate.isBefore(monthEndDate);
        calculatedDate = DateTime(calculatedDate.year, calculatedDate.month,
            calculatedDate.day + 1)) {
      hijriDatesCache[calculatedDate] = HijriDate.fromMonthStart(calculatedDate,
          monthStartDate, monthStartHijri.year, monthStartHijri.month);
    }

    //printCacheMap();

    return hijriDatesCache[date]!;
  }

  DateTime parseDateFromInt(int dateInt) {
    String dateString = dateInt.toString().padLeft(8, '0');
    return DateTime(
      int.parse(dateString.substring(0, 4)),
      int.parse(dateString.substring(4, 6)),
      int.parse(dateString.substring(6, 8)),
    );
  }

  HijriDate parseHijriFromInt(int hijriInt) {
    String hijriYearMonthString = hijriInt.toString().padLeft(6, '0');

    int hijriMonth = int.parse(hijriYearMonthString.substring(4, 6));
    int hijriYear = int.parse(hijriYearMonthString.substring(0, 4));

    return HijriDate(hijriYear, hijriMonth, 1);
  }

  String hDate(int year, int month, int day) {
    this.hYear = year;
    this.hMonth = month;
    this.longMonthName = _local[language]!['long']![month]!;
    this.dayWeName = _local[language]!['days']![wkDay]!;
    this.shortMonthName = _local[language]!['short']![month]!;
    this.hDay = day;
    return format(this.hYear, this.hMonth, this.hDay, "dd/mm/yyyy");
  }

  String toFormat(String format) {
    return this.format(this.hYear, this.hMonth, this.hDay, format);
  }

  String format(year, month, day, String format) {
    String newFormat = format;

    String dayString;
    String monthString;
    String yearString;

    if (language == 'ar') {
      dayString = DigitsConverter.convertWesternNumberToEastern(day);
      monthString = DigitsConverter.convertWesternNumberToEastern(month);
      yearString = DigitsConverter.convertWesternNumberToEastern(year);
    } else {
      dayString = day.toString();
      monthString = month.toString();
      yearString = year.toString();
    }

    if (format.contains("dd")) {
      newFormat = newFormat.replaceFirst("dd", dayString);
    } else {
      if (format.contains("d")) {
        newFormat = newFormat.replaceFirst("d", day.toString());
      }
    }

    //=========== Day Name =============//
    // Friday
    if (format.contains("DDDD")) {
      newFormat = newFormat.replaceFirst(
          "DDDD", "${_local[language]!['days']![wkDay ?? weekDay()]}");

      // Fri
    } else if (format.contains("DD")) {
      newFormat = newFormat.replaceFirst(
          "DD", "${_local[language]!['short_days']![wkDay ?? weekDay()]}");
    }

    //============== Month ========================//
    // 1
    if (format.contains("mm")) {
      newFormat = newFormat.replaceFirst("mm", monthString);
    } else if (format.contains("m")) {
      newFormat = newFormat.replaceFirst("m", monthString);
    }

    // Muharram
    if (format.contains("MMMM")) {
      newFormat =
          newFormat.replaceFirst("MMMM", _local[language]!['long']![month]!);
    } else {
      if (format.contains("MM")) {
        newFormat =
            newFormat.replaceFirst("MM", _local[language]!['short']![month]!);
      }
    }

    //================= Year ========================//
    if (format.contains("yyyy")) {
      newFormat = newFormat.replaceFirst("yyyy", yearString);
    } else if (format.contains("yy")) {
      newFormat = newFormat.replaceFirst("yy", yearString.substring(2, 4));
    }
    return newFormat;
  }

  bool isBefore(int year, int month, int day) {
    return hijriToGregorian(hYear, hMonth, hDay).millisecondsSinceEpoch <
        hijriToGregorian(year, month, day).millisecondsSinceEpoch;
  }

  bool isAfter(int year, int month, int day) {
    return hijriToGregorian(hYear, hMonth, hDay).millisecondsSinceEpoch >
        hijriToGregorian(year, month, day).millisecondsSinceEpoch;
  }

  bool isAtSameMomentAs(int year, int month, int day) {
    return hijriToGregorian(hYear, hMonth, hDay).millisecondsSinceEpoch ==
        hijriToGregorian(year, month, day).millisecondsSinceEpoch;
  }

  void setAdjustments(Map<int, int> adj) {
    adjustments = adj;
  }

  int? _ummalquraDataIndex(int index) {
    if (index < 0 || index >= ummAlquraDateArray.length) {
      throw ArgumentError(
          "Valid date should be between 1356 AH (14 March 1937 CE) to 1500 AH (16 November 2077 CE)");
    }

    if (adjustments != null && adjustments!.containsKey(index + 16260)) {
      return adjustments![index + 16260];
    }

    return ummAlquraDateArray[index];
  }

  int weekDay() {
    DateTime wkDay = hijriToGregorian(hYear, hMonth, hDay);
    return wkDay.weekday;
  }

  @override
  String toString() {
    String dateFormat = (language == "ar") ? "yyyy/mm/dd" : "dd/mm/yyyy";

    return format(hYear, hMonth, hDay, dateFormat);
  }

  List<int?> toList() => [hYear, hMonth, hDay];

  String fullDate() {
    String dateFormat =
        (language == 'tr') ? "dd MMMM yyyy DDDD" : "DDDD, MMMM dd, yyyy";

    return format(hYear, hMonth, hDay, dateFormat);
  }

  bool isValid() {
    if (validateHijri(this.hYear, this.hMonth, this.hDay)) {
      if (this.hDay <= getDaysInMonth(this.hYear, this.hMonth)) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  bool validateHijri(int year, int month, int day) {
    if (month < 1 || month > 12) return false;

    if (day < 1 || day > 30) return false;
    return true;
  }

  String getLongMonthName() {
    return _local[language]!['long']![hMonth]!;
  }

  String getShortMonthName() {
    return _local[language]!['short']![hMonth]!;
  }

  String getDayName() {
    return _local[language]!['days']![wkDay]!;
  }

  // to get all month names in long format
  Map<int, String> getMonths() {
    return _local[language]!['long']!;
  }

  // to get specific month days on map of date and day name
  Map<int, String> getMonthDays(int month, int year) {
    Map<int, String> calender = {};
    int d = hijriToGregorian(year, month, 1).weekday;
    int daysInMonth = getDaysInMonth(year, month);
    for (int i = 1; i <= daysInMonth; i++) {
      calender.putIfAbsent(i, () => _local[language]!['days']![d]!);
      d = d < 7 ? d + 1 : 1;
    }
    return calender;
  }

  void printCacheMap() {
    print("-------------hijriDatesCache----------------");
    hijriDatesCache.forEach((key, value) {
      print("${key} -> ${value.year}-${value.month}-${value.day}");
    });
    print("++++++++++++++++hijriDatesCache++++++++++++++++");
  }
}
