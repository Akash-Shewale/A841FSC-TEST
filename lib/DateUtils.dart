import 'package:intl/intl.dart';
class DateUtils
{

  static String getTodaysDate()
  {
     var now = new DateTime.now();
     String todaysDay=new DateFormat("EEEE").format(now);
     String todaysDate=new DateFormat("dd MMM hh:mm aa").format(now);
     return todaysDay+" ,"+todaysDate;
  }
}