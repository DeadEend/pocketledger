import 'package:cloud_firestore/cloud_firestore.dart';

// Defensive readers: a missing or wrongly typed field never crashes the app.

String readString(Object? value) => value is String ? value : '';

double readDouble(Object? value) => value is num ? value.toDouble() : 0.0;

DateTime readDate(Object? value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  return DateTime.now();
}
