import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:primafit/database/pengingat/database_obat.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class AlarmService {
  // Singleton pattern
  AlarmService._privateConstructor();
  static final AlarmService instance = AlarmService._privateConstructor();

  // Local notifications plugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Background port for alarm callbacks
  static const String BACKGROUND_PORT_NAME = 'alarm_background_port';
  static SendPort? uiSendPort;

  // Initialize service
  Future<void> init() async {
    // Initialize timezone
    tz_data.initializeTimeZones();

    // Initialize flutter local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request notification permissions
    // await flutterLocalNotificationsPlugin
    //     .resolvePlatformSpecificImplementation<
    //         AndroidFlutterLocalNotificationsPlugin>()
    //     ?.requestPermission();
    await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
    ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );


    // Initialize Android Alarm Manager
    await AndroidAlarmManager.initialize();

    // Set up background port
    final receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(
        receivePort.sendPort, BACKGROUND_PORT_NAME);
    
    // Listen for background events
    receivePort.listen((dynamic message) {
      _handleAlarmCallback(message);
    });
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) async {
    if (response.payload != null) {
      // Parse the payload (obat_id)
      final int obatId = int.parse(response.payload!);
      
      // Handle notification tap based on the obat ID
      // This could navigate to the detail page for that medication
      print('Notification tapped with obat ID: $obatId');
      
      // Here you would typically use Navigator to navigate to detail page
      // Example: Navigator.push(context, MaterialPageRoute(builder: (_) => DetailObat(obatId: obatId)))
    }
  }

  // Schedule all alarms for a medication
  Future<void> scheduleAlarmsForObat(int obatId) async {
    try {
      // Get medication data
      final obatData = await DatabaseObatHelper.instance.getObatById(obatId);
      if (obatData == null) return;

      // Get all alarms for this medication
      final alarms = await DatabaseObatHelper.instance.getAlarmsByObatId(obatId);
      
      // Cancel existing alarms for this medication
      await cancelAlarmsForObat(obatId);

      // Schedule new alarms
      for (var alarm in alarms) {
        final alarmId = alarm['id'];
        final timeInMillis = alarm['waktu_alarm'];
        final alarmTime = DateTime.fromMillisecondsSinceEpoch(timeInMillis);
        
        // Schedule daily repeating alarm
        await _scheduleDailyAlarm(
          obatId: obatId,
          alarmId: alarmId,
          time: TimeOfDay(hour: alarmTime.hour, minute: alarmTime.minute),
          obatName: obatData['nama'],
          dosis: obatData['dosis'],
          instruksi: obatData['instruksi'],
          stok: int.parse(obatData['stok'] ?? '0'),
        );
      }
    } catch (e) {
      print('Error scheduling alarms: $e');
    }
  }

  // Schedule a daily repeating alarm
  Future<bool> _scheduleDailyAlarm({
    required int obatId,
    required int alarmId,
    required TimeOfDay time,
    required String obatName,
    required String dosis,
    required String instruksi,
    required int stok,
  }) async {
    if (stok <= 0) return false; // Don't schedule if out of stock
    
    try {
      // Calculate next alarm time
      final now = DateTime.now();
      var scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      
      // If the time has already passed today, schedule for tomorrow
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
      
      // Create unique ID for this alarm
      final uniqueId = obatId * 10000 + alarmId;
      
      // Schedule android alarm manager
      bool result = await AndroidAlarmManager.periodic(
        const Duration(days: 1),
        uniqueId,
        _alarmCallback,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
        startAt: scheduledTime,
        params: {
          'obat_id': obatId,
          'alarm_id': alarmId,
          'obat_name': obatName,
          'dosis': dosis,
          'instruksi': instruksi,
        },
      );
      
      // Save the alarm info to shared preferences for persistence
      if (result) {
        await _saveAlarmToPrefs(uniqueId, {
          'obat_id': obatId,
          'alarm_id': alarmId,
          'time': scheduledTime.millisecondsSinceEpoch,
          'obat_name': obatName,
          'dosis': dosis,
          'instruksi': instruksi,
        });
      }
      
      return result;
    } catch (e) {
      print('Error scheduling daily alarm: $e');
      return false;
    }
  }

  // Save alarm data to shared preferences
  Future<void> _saveAlarmToPrefs(int alarmId, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String key = 'alarm_$alarmId';
      
      // Convert Map to JSON string
      // Here we should actually use a proper JSON encoding, but for simplicity:
      final timeStr = data['time'].toString();
      final obatId = data['obat_id'].toString();
      final alarmIdStr = data['alarm_id'].toString();
      final obatName = data['obat_name'];
      final dosis = data['dosis'];
      final instruksi = data['instruksi'];
      
      final value = '$timeStr|$obatId|$alarmIdStr|$obatName|$dosis|$instruksi';
      await prefs.setString(key, value);
    } catch (e) {
      print('Error saving alarm to prefs: $e');
    }
  }

  // Load alarm data from shared preferences
  Future<Map<String, dynamic>?> _getAlarmFromPrefs(int alarmId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String key = 'alarm_$alarmId';
      
      final String? value = prefs.getString(key);
      if (value == null) return null;
      
      final parts = value.split('|');
      if (parts.length < 6) return null;
      
      return {
        'time': int.parse(parts[0]),
        'obat_id': int.parse(parts[1]),
        'alarm_id': int.parse(parts[2]),
        'obat_name': parts[3],
        'dosis': parts[4],
        'instruksi': parts[5],
      };
    } catch (e) {
      print('Error getting alarm from prefs: $e');
      return null;
    }
  }

  // Cancel all alarms for a medication
  Future<void> cancelAlarmsForObat(int obatId) async {
  try {
    // Get all alarms for this medication
    final alarms = await DatabaseObatHelper.instance.getAlarmsByObatId(obatId);

    for (var alarm in alarms) {
      final dynamic rawAlarmId = alarm['id'];
      if (rawAlarmId == null) {
        print('Alarm ID is null, skipping...');
        continue;
      }

      final int alarmId = int.tryParse(rawAlarmId.toString()) ?? -1;
      if (alarmId == -1) {
        print('Invalid alarm ID: $rawAlarmId, skipping...');
        continue;
      }

      final int uniqueId = obatId * 10000 + alarmId;

      // Cancel the alarm
      await AndroidAlarmManager.cancel(uniqueId);

      // Remove from shared preferences
      await _removeAlarmFromPrefs(uniqueId);
    }
  } catch (e) {
    print('Error canceling alarms: $e');
  }
}


  // Remove alarm data from shared preferences
  Future<void> _removeAlarmFromPrefs(int alarmId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String key = 'alarm_$alarmId';
      await prefs.remove(key);
    } catch (e) {
      print('Error removing alarm from prefs: $e');
    }
  }

  // Reschedule all alarms from shared preferences
  // Call this method when the app launches
  Future<void> rescheduleAllAlarms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      
      for (final key in allKeys) {
        if (key.startsWith('alarm_')) {
          final alarmId = int.parse(key.replaceFirst('alarm_', ''));
          final alarmData = await _getAlarmFromPrefs(alarmId);
          
          if (alarmData != null) {
            final obatId = alarmData['obat_id'];
            
            // Check if medication still exists and has stock
            final obat = await DatabaseObatHelper.instance.getObatById(obatId);
            if (obat != null) {
              final stok = int.parse(obat['stok'] ?? '0');
              
              if (stok > 0) {
                // Reschedule the alarm
                final alarmTime = DateTime.fromMillisecondsSinceEpoch(alarmData['time']);
                
                await AndroidAlarmManager.periodic(
                  const Duration(days: 1),
                  alarmId,
                  _alarmCallback,
                  exact: true,
                  wakeup: true,
                  rescheduleOnReboot: true,
                  startAt: alarmTime,
                  params: {
                    'obat_id': obatId,
                    'alarm_id': alarmData['alarm_id'],
                    'obat_name': alarmData['obat_name'],
                    'dosis': alarmData['dosis'],
                    'instruksi': alarmData['instruksi'],
                  },
                );
              } else {
                // Remove alarm if out of stock
                await _removeAlarmFromPrefs(alarmId);
              }
            } else {
              // Remove alarm if medication doesn't exist
              await _removeAlarmFromPrefs(alarmId);
            }
          }
        }
      }
    } catch (e) {
      print('Error rescheduling alarms: $e');
    }
  }

  // Show a notification
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medication_reminder_channel',
      'Medication Reminders',
      channelDescription: 'Reminds you to take your medications',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('alarm_sound'),
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      enableLights: true,
      ledColor: Color(0xFF64D1DE),
      ledOnMs: 1000,
      ledOffMs: 500,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id, 
      title, 
      body, 
      platformDetails, 
      payload: payload
    );
  }

  // Static callback function for alarm
  @pragma('vm:entry-point')
  static Future<void> _alarmCallback(int id) async {
    // Get the background send port
    final SendPort? sendPort = IsolateNameServer.lookupPortByName(BACKGROUND_PORT_NAME);
    
    if (sendPort != null) {
      // Send the alarm ID to the main isolate
      sendPort.send(id);
    } else {
      // If port not found, handle the alarm directly
      await _handleAlarmDirectly(id);
    }
  }

  // Handle alarm callback in main isolate
  static Future<void> _handleAlarmCallback(int id) async {
    await _handleAlarmDirectly(id);
  }

  // Handle alarm directly
  static Future<void> _handleAlarmDirectly(int id) async {
    try {
      // Get alarm service instance
      final alarmService = AlarmService.instance;
      
      // Get alarm data from shared preferences
      final alarmData = await alarmService._getAlarmFromPrefs(id);
      if (alarmData == null) return;
      
      final obatId = alarmData['obat_id'];
      final obatName = alarmData['obat_name'];
      final dosis = alarmData['dosis'];
      final instruksi = alarmData['instruksi'];
      
      // Get the latest medication data to check stock
      final obat = await DatabaseObatHelper.instance.getObatById(obatId);
      if (obat == null) return;
      
      final stok = int.parse(obat['stok'] ?? '0');
      
      if (stok > 0) {
        // Show notification
        final now = DateTime.now();
        final formattedTime = DateFormat.jm().format(now);
        
        await alarmService._showNotification(
          id: id,
          title: 'Waktunya Minum Obat: $obatName',
          body: 'Dosis: $dosis\nWaktu: $formattedTime\nInstruksi: $instruksi',
          payload: obatId.toString(),
        );
        
        // Update stock (decrease by 1)
        final newStok = (stok - 1).toString();
        await DatabaseObatHelper.instance.updateObat(
          obatId, 
          {'stok': newStok}
        );
        
        // If stock is now 0, cancel future alarms for this medication
        if (stok == 1) { // Will be 0 after update
          await alarmService.cancelAlarmsForObat(obatId);
        }
      } else {
        // Cancel alarm if out of stock
        await alarmService.cancelAlarmsForObat(obatId);
      }
    } catch (e) {
      print('Error handling alarm directly: $e');
    }
  }

  // Check and update all alarms (call this periodically)
  Future<void> checkAndUpdateAlarms() async {
    try {
      // Get all medications
      final obatList = await DatabaseObatHelper.instance.getAllObat();
      
      for (var obat in obatList) {
        final obatId = obat['id'];
        final stok = int.parse(obat['stok'] ?? '0');
        
        if (stok > 0) {
          // Reschedule alarms for medications with stock
          await scheduleAlarmsForObat(obatId);
        } else {
          // Cancel alarms for medications out of stock
          await cancelAlarmsForObat(obatId);
        }
      }
    } catch (e) {
      print('Error checking and updating alarms: $e');
    }
  }
}