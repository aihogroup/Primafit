import 'package:flutter_test/flutter_test.dart';
import 'package:primafit/features/health_record/data/sync/health_metric_spec.dart';

HealthMetricSpec _spec(HealthMetric m) => healthMetricSpecs.firstWhere((s) => s.metric == m);

void main() {
  test('every metric has exactly one spec with a distinct file', () {
    expect(healthMetricSpecs.map((s) => s.metric).toSet(), HealthMetric.values.toSet());
    expect(healthMetricSpecs.map((s) => s.fileName).toSet(), hasLength(6));
  });

  test('single-value row maps to the server format and back', () {
    final spec = _spec(HealthMetric.cholesterol);
    final remote = spec.toRemote({
      'sync_id': 'a1',
      'updated_at': '2026-09-25T01:02:03.000Z',
      'tanggal': '2026-09-24',
      'waktu': '7:05',
      'hasil': '190,5',
      'satuan': 'mg/dL',
      'catatan': '  puasa ',
    })!;

    expect(remote, containsPair('measured_on', '2026-09-24'));
    expect(remote, containsPair('measured_time', '07:05:00'));
    expect(remote, containsPair('value', 190.5));
    expect(remote, containsPair('note', 'puasa'));
    expect(remote['deleted_at'], isNull);

    final local = spec.toLocal({...remote, 'measured_time': '07:05:00'});
    expect(local, {
      'tanggal': '2026-09-24',
      'waktu': '7:05',
      'hasil': '190.5',
      'satuan': 'mg/dL',
      'catatan': 'puasa',
    });
  });

  test('blood pressure needs both numbers', () {
    final spec = _spec(HealthMetric.bloodPressure);
    final base = {'sync_id': 'b', 'updated_at': '2026-09-25T00:00:00Z', 'tanggal': '2026-09-25'};

    expect(
      spec.toRemote({...base, 'sistolik': '120', 'diastolik': '80'}),
      containsPair('value2', 80),
    );
    expect(spec.toRemote({...base, 'sistolik': '120', 'diastolik': ''}), isNull);
  });

  test('BMI keeps weight and height, drops impossible ones instead of failing the batch', () {
    final spec = _spec(HealthMetric.bmi);
    final base = {'sync_id': 'c', 'updated_at': '2026-09-25T00:00:00Z', 'tanggal': '2026-09-25'};

    final ok = spec.toRemote({...base, 'bmi': '22.9', 'berat': '65', 'tinggi': '168.5'})!;
    expect([ok['value'], ok['weight_kg'], ok['height_cm']], [22.9, 65, 168.5]);

    final odd = spec.toRemote({...base, 'bmi': '22.9', 'berat': '0', 'tinggi': '999'})!;
    expect(odd['weight_kg'], isNull);
    expect(odd['height_cm'], isNull);
  });

  test('rows the server would reject are skipped', () {
    final spec = _spec(HealthMetric.bloodSugar);
    final base = {'sync_id': 'd', 'updated_at': '2026-09-25T00:00:00Z', 'tanggal': '2026-09-25'};

    expect(spec.toRemote({...base, 'hasil': 'tinggi'}), isNull);
    expect(spec.toRemote({...base, 'hasil': '100000'}), isNull);
    expect(spec.toRemote({...base, 'hasil': '-5'}), isNull);
    expect(spec.toRemote({...base, 'tanggal': 'kemarin', 'hasil': '90'}), isNull);
    expect(spec.toRemote({...base, 'hasil': '90', 'waktu': '25:99'})!['measured_time'], isNull);
  });

  test('tombstones carry the deletion time as the version', () {
    final spec = _spec(HealthMetric.uricAcid);
    final remote = spec.toRemote({
      'sync_id': 'e',
      'tanggal': '2026-09-25',
      'hasil': '6.1',
    }, deletedAt: '2026-09-26T00:00:00Z')!;

    expect(remote['deleted_at'], '2026-09-26T00:00:00Z');
    expect(remote['client_updated_at'], '2026-09-26T00:00:00Z');
  });
}
