import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:primafit/features/reminder/data/database_agenda.dart';
import 'package:primafit/features/reminder/presentation/jadwal/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:isolate';

class BackgroundService {
  // ID for background tasks
  static const int dailyCheckId = 0;
  static const int hourlyCheckId = 1;
  
  // Initialize background service
  static Future<void> initialize() async {
    await AndroidAlarmManager.initialize();
    await _startDailyCheck();
    await _startHourlyCheck();
  }
  
  // Start daily task to check and clean old agendas
  static Future<void> _startDailyCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final isDailyCheckEnabled = prefs.getBool('daily_check_enabled') ?? true;
    
    if (isDailyCheckEnabled) {
      // Run daily at midnight
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day, 0, 0).add(const Duration(days: 1));
      
      await AndroidAlarmManager.oneShotAt(
        midnight,
        dailyCheckId,
        _dailyCheckCallback,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );
    }
  }
  
  // Start hourly task to check upcoming agendas
  static Future<void> _startHourlyCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final isHourlyCheckEnabled = prefs.getBool('hourly_check_enabled') ?? true;
    
    if (isHourlyCheckEnabled) {
      await AndroidAlarmManager.periodic(
        const Duration(hours: 1),
        hourlyCheckId,
        _hourlyCheckCallback,
        wakeup: true,
        rescheduleOnReboot: true,
      );
    }
  }
  
  // Stop all background tasks
  static Future<void> stopAllTasks() async {
    await AndroidAlarmManager.cancel(dailyCheckId);
    await AndroidAlarmManager.cancel(hourlyCheckId);
  }
  
  // Callback for daily check task
  @pragma('vm:entry-point')
  static Future<void> _dailyCheckCallback() async {
    // Send to Isolate
    final ReceivePort port = ReceivePort();
    await Isolate.spawn(_isolateDailyCheck, port.sendPort);
    port.listen((message) {
      debugPrint('Daily check completed: $message');
    });
    
    // Schedule the next daily check
    await _startDailyCheck();
  }
  
  // Callback for hourly check task
  @pragma('vm:entry-point')
  static Future<void> _hourlyCheckCallback() async {
    // Send to Isolate
    final ReceivePort port = ReceivePort();
    await Isolate.spawn(_isolateHourlyCheck, port.sendPort);
    port.listen((message) {
      debugPrint('Hourly check completed: $message');
    });
  }
  
  // Isolate for daily check
  static Future<void> _isolateDailyCheck(SendPort sendPort) async {
    try {
      // Clean up old agendas (older than 30 days)
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      final dateStr = DateFormat('yyyy-MM-dd').format(thirtyDaysAgo);
      
      final deletedCount = await DatabaseAgenda.instance.deleteOldAgendas(dateStr);
      
      // Check for agendas that passed without completion
      final yesterday = now.subtract(const Duration(days: 1));
      final yesterdayStr = DateFormat('yyyy-MM-dd').format(yesterday);
      
      final pastAgendas = await DatabaseAgenda.instance.getAgendaByDate(yesterdayStr);
      for (final agenda in pastAgendas) {
        if (agenda.isCompleted == 0) {
          // Auto-mark as expired for past agendas
          await DatabaseAgenda.instance.updateAgenda(
            Agenda(
              id: agenda.id,
              title: agenda.title,
              description: agenda.description,
              date: agenda.date,
              time: agenda.time,
              isCompleted: 2, // Use 2 for expired status
              reminderTime: agenda.reminderTime,
              repeatType: agenda.repeatType,
              repeatInterval: agenda.repeatInterval,
              color: agenda.color,
            ),
          );
          
          // Cancel any pending notifications
          if (agenda.id != null) {
            await NotificationService().cancelNotification(agenda.id!);
          }
        }
      }
      
      sendPort.send('Cleaned $deletedCount old agendas');
    } catch (e) {
      sendPort.send('Error in daily check: $e');
    }
  }
  
  // Isolate for hourly check
  static Future<void> _isolateHourlyCheck(SendPort sendPort) async {
    try {
      // Check and reschedule upcoming agenda notifications
      await NotificationService().checkAndRescheduleUpcomingAgendas();
      
      sendPort.send('Rescheduled upcoming agenda notifications');
    } catch (e) {
      sendPort.send('Error in hourly check: $e');
    }
  }
}