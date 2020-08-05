// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as TimeAgo;

class TemporalHelper {
  static String date(DateTime datetime, {String format = 'dd-MM-yyyy'}) {
    if (datetime != null) {
      return DateFormat(format).format(datetime);
    } else {
      return '';
    }
  }

  static String datetime(DateTime datetime,
      {String format = 'dd MM yyyy h:mm a'}) {
    if (datetime != null) {
      return DateFormat(format).format(datetime);
    } else {
      return '';
    }
  }

  static String timeago(DateTime datetime) {
    if (datetime != null) {
      return TimeAgo.format(datetime);
    } else {
      return '';
    }
  }

  // static String timestampAsDate(Timestamp timestamp,
  //     {String format = 'dd-MM-yyyy'}) {
  //   if (timestamp != null) {
  //     return DateFormat(format).format(datetimeFromTimestamp(timestamp));
  //   } else {
  //     return '';
  //   }
  // }

  // static String timestampAsDateTime(Timestamp timestamp,
  //     {String format = 'dd MM yyyy h:mm a'}) {
  //   if (timestamp != null) {
  //     return DateFormat(format).format(datetimeFromTimestamp(timestamp));
  //   } else {
  //     return '';
  //   }
  // }

  // static String timestampAsTimeAgo(Timestamp timestamp) {
  //   if (timestamp != null) {
  //     return TimeAgo.format(datetimeFromTimestamp(timestamp));
  //   } else {
  //     return '';
  //   }
  // }

  // static DateTime datetimeFromTimestamp(Timestamp timestamp) {
  //   if (timestamp != null) {
  //     return timestamp.toDate();
  //   } else {
  //     return null;
  //   }
  // }
}
