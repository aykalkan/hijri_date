class HijriDate {
  int year;
  int month;
  int day;

  HijriDate(this.year, this.month, this.day);

  factory HijriDate.fromMonthStart(DateTime pickedDate, DateTime monthStartDate, year, month) {
    // Yaz saati uygulamasından dolayı günlerin yanlış çıkartılmasını çözmek amacıyla tarihler UTC'ye çevrildi
    DateTime utcPickedDate = DateTime.utc(pickedDate.year, pickedDate.month, pickedDate.day);
    DateTime utcMonthStartDate = DateTime.utc(monthStartDate.year, monthStartDate.month, monthStartDate.day);

    int day = utcPickedDate.difference(utcMonthStartDate).inDays + 1;

    return HijriDate(year, month, day);
  }
}
