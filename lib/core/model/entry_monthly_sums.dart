class EntryMonthlySums {
  int usage = 0;
  int? day;
  int month = 0;
  int year = 0;
  int? count;
  bool isReset = false;

  EntryMonthlySums({
    required this.usage,
    required this.month,
    required this.year,
    this.day,
    this.count,
    required this.isReset,
  });
}
