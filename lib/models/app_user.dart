import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/firestore_parsing.dart';

/// The profile stored at users/{uid}.
class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.monthlyBudget,
    required this.createdAt,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      name: readString(map['name']).trim(),
      email: readString(map['email']),
      monthlyBudget: readDouble(map['monthlyBudget']),
      createdAt: readDate(map['createdAt']),
    );
  }

  final String uid;
  final String name;
  final String email;
  final double monthlyBudget;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'monthlyBudget': monthlyBudget,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
