import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime date;
  bool read;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    this.read = false,
  });

  // من Firestore
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      read: data['read'] ?? false,
    );
  }

  // إلى Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'date': Timestamp.fromDate(date),
      'read': read,
    };
  }
}