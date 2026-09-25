import 'package:sqflite/sqflite.dart';

import '../database_asamurat.dart';
import '../database_bmi.dart';
import '../database_guladarah.dart';
import '../database_kolesterol.dart';
import '../database_suhu.dart';
import '../database_tensi.dart';

/// Mirrors Postgres enum `public.health_metric`.
enum HealthMetric {
  cholesterol('cholesterol'),
  bloodSugar('blood_sugar'),
  uricAcid('uric_acid'),
  bodyTemperature('body_temperature'),
  bloodPressure('blood_pressure'),
  bmi('bmi');

  const HealthMetric(this.dbValue);

  final String dbValue;

  static HealthMetric? tryParse(String? value) {
    for (final m in values) {
      if (m.dbValue == value) return m;
    }
    return null;
  }
}

/// How one legacy on-device table maps to `public.health_measurements`.
///
/// The legacy tables store everything as TEXT (`tanggal` yyyy-MM-dd, `waktu`
/// H:mm, numbers as typed by the user). Rows that cannot be mapped (e.g. a
/// non-numeric value) are skipped by sync and stay on the device.
class HealthMetricSpec {
  const HealthMetricSpec({
    required this.metric,
    required this.fileName,
    required this.table,
    required this.dataColumns,
    required this.open,
    required this.valueColumns,
  });

  final HealthMetric metric;

  /// Database file name (also the [LocalDb] open-hook key).
  final String fileName;
  final String table;

  /// User-editable columns; an update to any of them marks the row dirty.
  final List<String> dataColumns;

  /// Remote numeric column -> local TEXT column.
  final Map<String, String> valueColumns;

  /// Opens the table through its legacy helper (same singleton the screens use).
  final Future<Database> Function() open;

  bool get hasUnit => dataColumns.contains('satuan');

  /// Local row (or tombstone) -> RPC payload. `null` if the row is not valid.
  Map<String, Object?>? toRemote(Map<String, Object?> row, {String? deletedAt}) {
    final id = row['sync_id'] as String?;
    final updatedAt = (deletedAt ?? row['updated_at']) as String?;
    final date = _isoDate(row['tanggal'] as String?);
    // Same bounds as the CHECK constraints on public.health_measurements, so
    // one bad legacy row can never fail a whole batch.
    final values = {
      for (final e in valueColumns.entries)
        e.key: _number(
          row[e.value] as String?,
          max: _maxFor[e.key]!,
          allowZero: _allowsZero(e.key),
        ),
    };
    if (id == null || updatedAt == null || date == null || values['value'] == null) return null;
    if (metric == HealthMetric.bloodPressure && values['value2'] == null) return null;

    final unit = (row['satuan'] as String?)?.trim();
    var note = (row['catatan'] as String?)?.trim();
    if (note != null && note.length > 2000) note = note.substring(0, 2000);
    return {
      'id': id,
      'metric': metric.dbValue,
      'measured_on': date,
      'measured_time': _isoTime(row['waktu'] as String?),
      ...values,
      'unit': (unit == null || unit.isEmpty)
          ? null
          : (unit.length > 16 ? unit.substring(0, 16) : unit),
      'note': (note == null || note.isEmpty) ? null : note,
      'client_updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }

  /// Remote row -> local column values (TEXT, legacy formats).
  Map<String, Object?> toLocal(Map<String, dynamic> remote) => {
    'tanggal': remote['measured_on'] as String,
    'waktu': _uiTime(remote['measured_time'] as String?),
    for (final e in valueColumns.entries) e.value: _text(remote[e.key] as num?),
    if (hasUnit) 'satuan': remote['unit'] as String?,
    'catatan': remote['note'] as String?,
  };

  static String? _isoDate(String? value) {
    final parsed = DateTime.tryParse(value?.trim() ?? '');
    if (parsed == null) return null;
    return '${parsed.year.toString().padLeft(4, '0')}-'
        '${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
  }

  /// `H:mm` (legacy) -> `HH:mm:00`.
  static String? _isoTime(String? value) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(value?.trim() ?? '');
    if (match == null) return null;
    final h = int.parse(match[1]!);
    final m = int.parse(match[2]!);
    if (h > 23 || m > 59) return null;
    return '${h.toString().padLeft(2, '0')}:${match[2]}:00';
  }

  /// `HH:mm:ss` -> `H:mm` (legacy format used by the input screens).
  static String? _uiTime(String? value) {
    final match = RegExp(r'^(\d{2}):(\d{2})').firstMatch(value ?? '');
    return match == null ? null : '${int.parse(match[1]!)}:${match[2]}';
  }

  static const _maxFor = {'value': 100000, 'value2': 100000, 'weight_kg': 1000, 'height_cm': 300};

  static bool _allowsZero(String column) => column == 'value' || column == 'value2';

  static num? _number(String? value, {required num max, required bool allowZero}) {
    final parsed = num.tryParse((value ?? '').trim().replaceAll(',', '.'));
    if (parsed == null || !parsed.isFinite || parsed >= max) return null;
    if (allowZero ? parsed < 0 : parsed <= 0) return null;
    return (parsed * 100).round() / 100;
  }

  static String? _text(num? value) {
    if (value == null) return null;
    return value == value.roundToDouble() ? value.toInt().toString() : value.toString();
  }
}

const _singleValueColumns = ['tanggal', 'waktu', 'hasil', 'catatan', 'satuan'];

/// The six health-record tables that sync to Supabase.
final healthMetricSpecs = <HealthMetricSpec>[
  HealthMetricSpec(
    metric: HealthMetric.cholesterol,
    fileName: 'kolesterol.db',
    table: 'kolesterol',
    dataColumns: _singleValueColumns,
    valueColumns: const {'value': 'hasil'},
    open: () => KolesterolDatabaseHelper.instance.database,
  ),
  HealthMetricSpec(
    metric: HealthMetric.bloodSugar,
    fileName: 'guladarah.db',
    table: 'gula_darah',
    dataColumns: _singleValueColumns,
    valueColumns: const {'value': 'hasil'},
    open: () => GulaDarahDatabaseHelper.instance.database,
  ),
  HealthMetricSpec(
    metric: HealthMetric.uricAcid,
    fileName: 'asamurat.db',
    table: 'asam_urat',
    dataColumns: _singleValueColumns,
    valueColumns: const {'value': 'hasil'},
    open: () => AsamUratDatabaseHelper.instance.database,
  ),
  HealthMetricSpec(
    metric: HealthMetric.bodyTemperature,
    fileName: 'suhu_tubuh.db',
    table: 'suhu_tubuh',
    dataColumns: _singleValueColumns,
    valueColumns: const {'value': 'hasil'},
    open: () => SuhuDatabaseHelper.instance.database,
  ),
  HealthMetricSpec(
    metric: HealthMetric.bloodPressure,
    fileName: 'tekanandarah.db',
    table: 'tekanan_darah',
    dataColumns: const ['tanggal', 'waktu', 'sistolik', 'diastolik', 'catatan'],
    valueColumns: const {'value': 'sistolik', 'value2': 'diastolik'},
    open: () => TekananDarahDatabaseHelper.instance.database,
  ),
  HealthMetricSpec(
    metric: HealthMetric.bmi,
    fileName: 'indeksmassatubuh.db',
    table: 'indeks_massa_tubuh',
    dataColumns: const ['tanggal', 'waktu', 'berat', 'tinggi', 'bmi', 'catatan'],
    valueColumns: const {'value': 'bmi', 'weight_kg': 'berat', 'height_cm': 'tinggi'},
    open: () => IndeksMassaTubuhDatabaseHelper.instance.database,
  ),
];
