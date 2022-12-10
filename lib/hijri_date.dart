class HijriDate {
  int year;
  int month;
  int day;

  HijriDate(this.year, this.month, this.day);

  HijriDate.fromMonthStart(
      DateTime pickedDate, DateTime monthStartDate, this.year, this.month)
      : day = pickedDate.difference(monthStartDate).inDays + 1;
}
