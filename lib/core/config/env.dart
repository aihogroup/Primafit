/// Build-time configuration injected with `--dart-define` / `--dart-define-from-file`.
///
/// Secrets must never be hard-coded in source. Provide them per environment:
/// `flutter run --dart-define-from-file=env/dev.json`
/// (see `env/example.json` for the expected keys).
abstract final class Env {
  static const String appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'dev');

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// Supabase publishable key (`sb_publishable_...`). Safe to ship in the
  /// client: data access is enforced by Row Level Security, not by this key.
  static const String supabasePublishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static const String newsApiKey = String.fromEnvironment('NEWS_API_KEY');

  static bool get isProduction => appEnv == 'prod';

  /// The app runs in offline/local-only mode until Supabase keys are supplied.
  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;

  static bool get isNewsApiConfigured => newsApiKey.isNotEmpty;
}
