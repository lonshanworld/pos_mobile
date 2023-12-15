import 'package:intl/intl.dart';

class TextFormatters{
  static String getDateTime(DateTime? dateTxt){
    final DateFormat formatter = DateFormat("dd-MMM-yyyy  hh:mm a");
    if(dateTxt == null){
      return "- -";
    }else{
      return formatter.format(dateTxt);
    }
  }

  static String getDate(DateTime? dateTxt){
    final DateFormat formatter = DateFormat("dd-MMM-yyyy");
    if(dateTxt == null){
      return "- -";
    }else{
      return formatter.format(dateTxt);
    }
  }

  static String getMonthAndYear(DateTime? dateTxt){
    final DateFormat formatter = DateFormat("MMMM-yyyy");
    if(dateTxt == null){
      return "- -";
    }else{
      return formatter.format(dateTxt);
    }
  }

  static String getTime(DateTime? dateTxt){
    final DateFormat formatter = DateFormat("hh:mm a");
    if(dateTxt == null){
      return "- -";
    }else{
      return formatter.format(dateTxt);
    }
  }

  static DateTime reverseDate(String dateStr){
    final DateFormat formatter = DateFormat("dd-MMM-yyyy");
    return formatter.parse(dateStr);
  }
}