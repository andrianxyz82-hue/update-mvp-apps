import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final _supabase = Supabase.instance.client;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notificationsPlugin.initialize(initSettings);
    _isInitialized = true;
    
    _listenToNewExams();
    _listenToNewCourses();
  }

  void _listenToNewExams() {
    _supabase
        .from('exams')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) {
          // This stream returns the current state of the table row(s).
          // For simple "new item" detection, we might need a different approach 
          // or just check if the item is very new.
          // However, Supabase Realtime 'INSERT' payload is better for this.
        });

    // Using channel for INSERT events
    _supabase.channel('public:exams').onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'exams',
      callback: (payload) {
        final newExam = payload.newRecord;
        _showNotification(
          id: newExam['id'].hashCode,
          title: 'New Exam Available!',
          body: 'A new exam "${newExam['title']}" has been posted.',
        );
      },
    ).subscribe();
  }

  void _listenToNewCourses() {
    _supabase.channel('public:courses').onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'courses',
      callback: (payload) {
        final newCourse = payload.newRecord;
        _showNotification(
          id: newCourse['id'].hashCode,
          title: 'New Course Available!',
          body: 'Check out the new course: "${newCourse['title']}".',
        );
      },
    ).subscribe();
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'General Notifications',
      channelDescription: 'Notifications for new exams and courses',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentSound: true,
    );
    
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notificationsPlugin.show(id, title, body, details);
  }
}
