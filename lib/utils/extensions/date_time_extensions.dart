import 'package:intl/intl.dart';

extension DateBySlash on DateTime {
  String get bySlash => DateFormat('d/M/yyyy').format(this);

  String get bySpace => DateFormat('d MMM yyyy').format(this);

  String get byTime {
    DateFormat outputFormat = DateFormat('d/M/yyyy, hh:mm a');
    return outputFormat.format(this);
  }

  String timeAgo() {
    Duration diff = DateTime.now().difference(this);
    if (diff.inDays > 365) {
      return "${(diff.inDays / 365).floor()}${(diff.inDays / 365).floor() == 1 ? " year" : " years"} ago";
    }
    if (diff.inDays > 30) {
      return "${(diff.inDays / 30).floor()}${(diff.inDays / 30).floor() == 1 ? " month" : " months"} ago";
    }
    if (diff.inDays > 7) {
      return "${(diff.inDays / 7).floor()}${(diff.inDays / 7).floor() == 1 ? " week" : " weeks"} ago";
    }
    if (diff.inDays > 0) {
      return "${diff.inDays}${diff.inDays == 1 ? " day" : " days"} ago";
    }
    if (diff.inHours > 0) {
      return "${diff.inHours}${diff.inHours == 1 ? " h" : " h"} ago";
    }
    if (diff.inMinutes > 0) {
      return "${diff.inMinutes}${diff.inMinutes == 1 ? " min" : " min"} ago";
    }
    return "just now";
  }

  String get timeAgoShort {
    final now = DateTime.now();
    final difference = now.difference(this);
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'just now';
    }
  }

  String get dateFormat => DateFormat('h:mm a').format(this);

  String get byUTC =>
      "${DateFormat('yyyy-MM-ddTHH:mm:ss.000').format(toUtc())}Z";

  DateTime get withoutMilliseconds =>
      DateTime.parse(DateFormat('yyyy-MM-dd HH:mm:ss').format(this));

  String formatToTermsString() {
    //IST not getting while formatting
    final formatter = DateFormat("MMM d, yyyy hh:mm:ss a", "en_US");
    return "${formatter.format(this)} (IST)";
  }
}
