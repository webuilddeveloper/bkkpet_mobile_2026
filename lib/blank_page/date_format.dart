class DateFormatTH {
  static const List<String> thaiWeekdays = [
    'จ.',
    'อ.',
    'พ.',
    'พฤ.',
    'ศ.',
    'ส.',
    'อ.',
  ];

  static const List<String> thaiMonths = [
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม',
  ];

  static const List<String> shortMonths = [
    'ม.ค.',
    'ก.พ.',
    'มี.ค.',
    'เม.ย.',
    'พ.ค.',
    'มิ.ย.',
    'ก.ค.',
    'ส.ค.',
    'ก.ย.',
    'ต.ค.',
    'พ.ย.',
    'ธ.ค.',
  ];

  static String shortDate(DateTime date) {
    return '${date.day} ${shortMonths[date.month - 1]} ${date.year + 543}';
  }

  static String monthYear(DateTime date) {
    return '${thaiMonths[date.month - 1]} ${date.year + 543}';
  }
}
