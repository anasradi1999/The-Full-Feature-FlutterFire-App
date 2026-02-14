import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'notifications_state.dart';


class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationsInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _subscription;

  void fetchNotifications() {
    emit(NotificationsLoading());

    _subscription?.cancel();

    _subscription = _firestore
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
        emit(NotificationsLoaded(snapshot.docs));
      },
      onError: (e) {
        emit(NotificationsError(e.toString()));
      },
    );
  }

  Future<void> markAsRead(String id) async {
    await _firestore.collection('notifications').doc(id).update({
      'isRead': true,
    });
  }

  Future<void> deleteNotification(String id) async {
    await _firestore.collection('notifications').doc(id).delete();
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}