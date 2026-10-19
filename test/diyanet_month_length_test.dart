// hijri (hijri_date) — Diyanet/Turkiye takvimi (dateMap) tutarlilik testleri
import 'package:test/test.dart';

import '../lib/hijri_calendar.dart';

void main() {
  final HijriCalendar cal = HijriCalendar();

  group('ay uzunlugu tutarliligi (dateMap tek kaynak)', () {
    test('dateMap kapsaminda ay uzunlugu 29 veya 30 (1318-01..1457-10)', () {
      for (int y = 1318; y <= 1457; y++) {
        for (int m = 1; m <= 12; m++) {
          if (y == 1457 && m > 10) continue;
          expect(cal.getDaysInMonth(y, m), anyOf(29, 30), reason: '$y-$m');
        }
      }
    });

    test('ay uzunlugu iki ardisik ay baslangici farki ile ayni', () {
      for (int y = 1400; y <= 1457; y++) {
        for (int m = 1; m <= 12; m++) {
          if (y == 1457 && m > 10) continue;
          final int nm = m == 12 ? 1 : m + 1;
          final int ny = m == 12 ? y + 1 : y;
          if (ny > 1457) continue;
          // Yaz saati (DST) kaymasi local farki 1 saat/1 gun bozabildigi icin
          // karsilastirma UTC uzerinden yapilir (kutuphane _daysBetween gibi)
          final DateTime start = cal.hijriToGregorian(y, m, 1);
          final DateTime next = cal.hijriToGregorian(ny, nm, 1);
          final int diff = DateTime.utc(next.year, next.month, next.day)
              .difference(DateTime.utc(start.year, start.month, start.day))
              .inDays;
          expect(diff, cal.getDaysInMonth(y, m), reason: '$y-$m');
        }
      }
    });

    test('Hicri -> Gregoryen -> Hicri gidis-donus (1440..1450)', () {
      for (int y = 1440; y <= 1450; y++) {
        for (int m = 1; m <= 12; m++) {
          final int len = cal.getDaysInMonth(y, m);
          for (int d = 1; d <= len; d++) {
            final DateTime g = cal.hijriToGregorian(y, m, d);
            expect(HijriCalendar.fromDate(g).toList(), equals([y, m, d]),
                reason: '$y-$m-$d -> $g');
          }
        }
      }
    });

    test('Diyanet regresyonu: 1448-05 = 29 gun, 1448-06 basi 10 Kasim 2026',
        () {
      expect(cal.getDaysInMonth(1448, 5), equals(29));
      expect(cal.hijriToGregorian(1448, 5, 1), equals(DateTime(2026, 10, 12)));
      expect(cal.hijriToGregorian(1448, 6, 1), equals(DateTime(2026, 11, 10)));
      expect(HijriCalendar.fromDate(DateTime(2026, 11, 10)).toList(),
          equals([1448, 6, 1]));
    });

    test('Diyanet regresyonu: 1447-05 = 29 gun, 1447-06 basi 21 Kasim 2025',
        () {
      expect(cal.getDaysInMonth(1447, 5), equals(29));
      expect(cal.hijriToGregorian(1447, 5, 1), equals(DateTime(2025, 10, 23)));
      expect(cal.hijriToGregorian(1447, 6, 1), equals(DateTime(2025, 11, 21)));
    });

    test('fromDate lengthOfMonth atar (LateInitializationError yok)', () {
      final HijriCalendar c = HijriCalendar.fromDate(DateTime(2026, 11, 10));
      expect(c.lengthOfMonth, equals(cal.getDaysInMonth(1448, 6)));
    });
  });
}
