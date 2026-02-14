import 'package:cloud_firestore/cloud_firestore.dart';

abstract class NotificationState {}

class NotificationsInitial extends NotificationState {}

class NotificationsLoading extends NotificationState {}

class NotificationsLoaded extends NotificationState {
  final List<QueryDocumentSnapshot> notifications;
  NotificationsLoaded(this.notifications);
}

class NotificationsError extends NotificationState {
  final String message;
  NotificationsError(this.message);
}

