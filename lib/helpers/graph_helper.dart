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

  bool isLeapYear(int year) {
    if (year % 4 == 0 && year % 400 != 0) {
      return true;
    }
    else  {
      return false;
    }
  }

  dateToInt(DateTime currentDate) {
    int addUp = 0;
    addUp += addUpMonthDays[currentDate.month - 1];
    addUp += currentDate.day;
    if (isLeapYear(currentDate.year) && (currentDate.month > 2 || currentDate.month == 2 && currentDate.day == 29)) {
      addUp++;
    }
    return addUp;
  }

  String doubleToAxisValue(double givenDate) {
    for (int i = 0; addUpMonthDays[i] < givenDate; i++) {
      if (i <= 1) {
        if (addUpMonthDays[i] + 1 == givenDate) {
          return monthNames[i];
        } else if (addUpMonthDays[i] + 15 == givenDate) {
          return '15';
        }
      }
      else {
        if (addUpMonthDays[i] + 2 == givenDate) {
          return monthNames[i];
        } else if (addUpMonthDays[i] + 16 == givenDate) {
          return '15';
        }
      }
    }
    return null;
  }

  String doubleToDate(double givenDate) {
    int month = 1;
    for (; month < addUpMonthDays.length; month++) {
      if (month == 1) {
        if (addUpMonthDays[month] >= givenDate) {
          break;
        }
      }
      else {
        if (addUpMonthDays[month] + 1 >= givenDate) {
          break;
        }
      }
    }
    int day = 0;
    if (month <= 2) {
      day = givenDate.floor() - addUpMonthDays[month - 1];
    }
    else {
      day = givenDate.floor() - addUpMonthDays[month - 1] - 1;
    }
    return month.toString() + '/' + day.toString();
  }
}
