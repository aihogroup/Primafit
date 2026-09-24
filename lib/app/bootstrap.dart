import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/env.dart';
import '../core/logging/app_logger.dart';
import 'app.dart';

/// App start-up: initialise services in a defined order, install global
/// error handlers, then mount the widget tree under Riverpod.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    AppLogger.error('Flutter framework error', error: details.exception, stackTrace: details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error('Uncaught async error', error: error, stackTrace: stack);
    return true;
  };

  await initializeDateFormatting('id_ID');

  if (Env.isSupabaseConfigured) {
    await Supabase.initialize(url: Env.supabaseUrl, publishableKey: Env.supabasePublishableKey);
    AppLogger.info('Supabase initialised (${Env.appEnv})', tag: 'bootstrap');
  } else {
    AppLogger.info('Supabase not configured; running in offline mode', tag: 'bootstrap');
  }

  runApp(const ProviderScope(child: PrimafitApp()));
}
