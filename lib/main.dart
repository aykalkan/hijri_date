import 'hijri_calendar.dart';

void main(List<String> args) {
  DateTime start = DateTime.now();
  print('Compile finished : ' + start.toString());
  for (int i = 0; i < 90; i++) {
    var date = DateTime(2024, 01, 20).add(Duration(days: i));
    var converted = HijriCalendar.fromDate(date);

    print(date.toString());
    print(converted);
    print("---------------------");
  }
/*
  for (int i = 0; i < 180; i++) {
    var date = DateTime(2009, 10, 30).add(Duration(days: i));
    var converted = HijriCalendar.fromDate(date);

    print(date.toString());
    print(converted);
    print("---------------------");
  }
*/
  var end = DateTime.now();
  print('RUN finished : ' + end.toString());
  print('Duration : ' + end.difference(start).inMilliseconds.toString());
}
