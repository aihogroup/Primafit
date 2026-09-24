import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:primafit/database/pengingat/database_agenda.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
  String? selectedNotificationPayload;
  final AndroidInitializationSettings _androidInitializationSettings =
      const AndroidInitializationSettings('@mipmap/ic_launcher');
  
  // Define notification channels
  static const String agendaChannelId = 'agenda_reminders_channel';
  static const String agendaChannelName = 'Agenda Reminders';
  static const String agendaChannelDescription = 'Notifications for your agenda reminders';
  
  // Notification Details
  static const AndroidNotificationDetails _androidNotificationDetails = AndroidNotificationDetails(
    agendaChannelId,
    agendaChannelName,
    channelDescription: agendaChannelDescription,
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
    enableLights: true,
    color: Color(0xFF64D1DE),
    ledColor: Color(0xFF64D1DE),
    ledOnMs: 1000,
    ledOffMs: 500,
  );
  
  static const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: _androidNotificationDetails,
  );

  // Initialize the notification service
  Future<void> init() async {
    // Initialize timezone
    tz_data.initializeTimeZones();
    
    // Set local timezone without flutter_native_timezone
    try {
      // Get device timezone offset in minutes
      final int offsetInMinutes = DateTime.now().timeZoneOffset.inMinutes;
      
      // Convert to hours and minutes for better timezone identification
      final int hours = offsetInMinutes ~/ 60;
      final int minutes = offsetInMinutes % 60;
      
      // Format timezone string
      final String timezoneString = 'GMT${hours >= 0 ? '+' : ''}$hours${minutes != 0 ? ':${minutes.abs().toString().padLeft(2, '0')}' : ''}';
      
      // For most common cases, try to map to IANA timezone
      String timezoneName = _getIanaTimeZone(hours, minutes);
      
      // Set the timezone
      tz.setLocalLocation(tz.getLocation(timezoneName));
      debugPrint('Timezone set to: $timezoneName (offset: $timezoneString)');
    } catch (e) {
      // Default to UTC if unable to determine timezone
      tz.setLocalLocation(tz.getLocation('Etc/UTC'));
      debugPrint('Failed to set local timezone, defaulting to UTC: $e');
    }
    
    // Initialize notification plugin
    final InitializationSettings initializationSettings = InitializationSettings(
      android: _androidInitializationSettings,
    );
    
    await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
      final String? payload = notificationResponse.payload;
      debugPrint('Notification payload: $payload');
      selectedNotificationPayload = payload;
      
      // TODO: Navigate ke halaman yang kamu mau di sini
    },
  );
    
    // Request notification permissions
    _requestNotificationPermissions();
    
    // Create notification channels on Android
    await _createNotificationChannel();
  }

  // Helper method to map offset to common IANA timezones
  // This is a simplified approach, but works for common cases
  String _getIanaTimeZone(int hours, int minutes) {
    // Default timezone if we can't determine a more specific one
    String timezone = 'Etc/GMT${hours >= 0 ? '-' : '+'}${hours.abs()}';
    
    // Try to map to common timezones based on offset
    // This is a simplified approach and doesn't account for DST changes
    switch (hours) {
      case -12: return 'Etc/GMT+12';
      case -11: return 'Etc/GMT+11';
      case -10: return 'Pacific/Honolulu';
      case -9: return 'America/Anchorage';
      case -8: return 'America/Los_Angeles';
      case -7: return 'America/Denver';
      case -6: return 'America/Chicago';
      case -5: return 'America/New_York';
      case -4: return 'America/Halifax';
      case -3: return 'America/Sao_Paulo';
      case -2: return 'Atlantic/South_Georgia';
      case -1: return 'Atlantic/Azores';
      case 0: return 'Europe/London';
      case 1: return 'Europe/Paris';
      case 2: return 'Europe/Athens';
      case 3: return 'Europe/Moscow';
      case 4: return 'Asia/Dubai';
      case 5: return 'Asia/Karachi';
      case 5.5: return 'Asia/Kolkata'; // Special case for India
      case 6: return 'Asia/Dhaka';
      case 7: return 'Asia/Bangkok';
      case 8: return 'Asia/Shanghai';
      case 9: return 'Asia/Tokyo';
      case 10: return 'Australia/Sydney';
      case 11: return 'Pacific/Noumea';
      case 12: return 'Pacific/Auckland';
      case 13: return 'Pacific/Tongatapu';
    }
    
    // Handle India's 30-minute offset
    if (hours == 5 && minutes == 30) {
      return 'Asia/Kolkata';
    }
    
    return timezone;
  }

  Future<void> _requestNotificationPermissions() async {
  if (Platform.isAndroid) {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    int sdkInt = androidInfo.version.sdkInt ?? 0;

    if (sdkInt >= 33) {
      // Versi terbaru memerlukan argumen untuk requestPermission
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission(
          );
    } else {
      // Untuk Android di bawah 13 (API 33), tidak perlu permission notifikasi
      print('No need to request notification permission (Android SDK < 33)');
    }
  }
}

  // Create notification channel for Android
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      agendaChannelId,
      agendaChannelName,
      description: agendaChannelDescription,
      importance: Importance.high,
    );
    
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Convert reminder time string to duration
  Duration _reminderTimeToDuration(String? reminderTime) {
    switch (reminderTime) {
      case '5min':
        return const Duration(minutes: 5);
      case '15min':
        return const Duration(minutes: 15);
      case '30min':
        return const Duration(minutes: 30);
      case '1hour':
        return const Duration(hours: 1);
      case '2hours':
        return const Duration(hours: 2);
      case '1day':
        return const Duration(days: 1);
      default:
        return const Duration(minutes: 15); // Default is 15 minutes
    }
  }

  // Schedule notification for an agenda
  Future<void> scheduleAgendaNotification(Agenda agenda) async {
    if (agenda.id == null) return;
    
    // Check if notifications are enabled in settings
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    if (!notificationsEnabled) return;
    
    // If no reminder time is set, don't schedule a notification
    if (agenda.reminderTime == null) return;
    
    try {
      // Parse date and time from agenda
      final DateTime agendaDateTime = _parseAgendaDateTime(agenda);
      
      // Calculate reminder time
      final reminderDuration = _reminderTimeToDuration(agenda.reminderTime);
      final reminderDateTime = agendaDateTime.subtract(reminderDuration);
      
      // Skip if reminder time is in the past
      if (reminderDateTime.isBefore(DateTime.now())) {
        debugPrint('Reminder time is in the past, skipping notification');
        return;
      }
      
      // Create a notification title and body
      final String title = 'Reminder: ${agenda.title}';
      final String body = agenda.description ?? 'Time for your scheduled agenda';
      
      // Schedule the notification
      await flutterLocalNotificationsPlugin.zonedSchedule(
        agenda.id!,
        title,
        body,
        tz.TZDateTime.from(reminderDateTime, tz.local),
        platformChannelSpecifics,
        // androidAllowWhileIdle: true, // Parameter lama, sudah deprecated
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Alternatif terbaru
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: agenda.id.toString(),
        matchDateTimeComponents: DateTimeComponents.time,
      );
      
      debugPrint('Notification scheduled for agenda ${agenda.id} at $reminderDateTime');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  // Parse date and time from agenda strings
  DateTime _parseAgendaDateTime(Agenda agenda) {
    try {
      final dateParts = agenda.date.split('-');
      final timeParts = agenda.time.split(':');
      
      return DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
    } catch (e) {
      debugPrint('Error parsing date/time: $e');
      return DateTime.now().add(const Duration(minutes: 30)); // Default fallback
    }
  }

  // Show an immediate notification
  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond, // Random ID
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Cancel a scheduled notification
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Check and reschedule upcoming agendas
  Future<void> checkAndRescheduleUpcomingAgendas() async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final tomorrowStr = "${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}";
    
    // Get all incomplete agendas for next 24 hours
    final upcomingAgendas = await DatabaseAgenda.instance.getAgendaInDateRange(
      "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}",
      tomorrowStr,
    );
    
    // Filter for incomplete agendas
    final incompleteAgendas = upcomingAgendas.where((agenda) => agenda.isCompleted == 0).toList();
    
    // Cancel all existing notifications to avoid duplicates
    await cancelAllNotifications();
    
    // Reschedule all upcoming agenda notifications
    for (final agenda in incompleteAgendas) {
      await scheduleAgendaNotification(agenda);
    }
  }
}