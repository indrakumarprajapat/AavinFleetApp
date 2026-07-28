import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String get ddMMyyyy =>
      DateFormat('dd-MM-yyyy').format(this);

  String get yyyyMMdd =>
      DateFormat('yyyy-MM-dd').format(this);

  String get ddMMyyyySlash =>
      DateFormat('dd/MM/yyyy').format(this);

  String get ddMMMyyyy =>
      DateFormat('dd MMM yyyy').format(this);

  String get ddMMMMyyyy =>
      DateFormat('dd MMMM yyyy').format(this);

  String get dateTime24 =>
      DateFormat('dd-MM-yyyy HH:mm:ss').format(this);

  String get dateTime12 =>
      DateFormat('dd-MM-yyyy hh:mm:ss a').format(this);

  String get time24 =>
      DateFormat('HH:mm').format(this);

  String get time12 =>
      DateFormat('hh:mm a').format(this);

  String get monthYear =>
      DateFormat('MMM yyyy').format(this);

  String get dayMonth =>
      DateFormat('dd MMM').format(this);

  String get apiDate =>
      DateFormat('yyyy-MM-dd').format(this);

  String get apiDateTime =>
      DateFormat('yyyy-MM-dd HH:mm:ss').format(this);

  String get isoDate =>
      toIso8601String();
}