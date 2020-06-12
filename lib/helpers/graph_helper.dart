class GraphHelper {
  List<int> months = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  List<int> addUpMonthDays = [
    0,
    31,
    59,
    90,
    120,
    151,
    181,
    212,
    243,
    273,
    304,
    334
  ];
  List<String> monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  dateToInt(DateTime currentDate) {
    int addUp = 0;
    addUp += addUpMonthDays[currentDate.month - 1];
    addUp += currentDate.day;
    return addUp;
  }

  String doubleToAxisValue(double givenDate) {
    for (int i = 0; addUpMonthDays[i] < givenDate; i++) {
      if (addUpMonthDays[i] == givenDate + 1) {
        return monthNames[i];
      } else if (addUpMonthDays[i] + 16 == givenDate) {
        return (i + 1).toString() + '/15';
      }
    }
    return null;
  }

  String doubleToDate(double givenDate) {
    int month = 1;
    for (; month < addUpMonthDays.length; month++) {
      if (addUpMonthDays[month] > givenDate) {
        break;
      }
    }
    int day = givenDate.floor() - addUpMonthDays[month - 1];
    return month.toString() + '/' + day.toString();
  }
}
