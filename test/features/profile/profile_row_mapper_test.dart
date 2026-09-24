import 'package:flutter_test/flutter_test.dart';
import 'package:primafit/features/profile/data/profile_row_mapper.dart';
import 'package:primafit/features/profile/domain/entities/user_profile.dart';

void main() {
  test('toRow converts UI values to database constraints', () {
    const profile = UserProfile(
      name: '  Siti Aminah ',
      birthDate: '17-08-1995',
      gender: 'Perempuan',
      bloodType: 'AB',
      phone: '0812-3456-7890',
    );

    expect(ProfileRowMapper.toRow(profile), {
      'full_name': 'Siti Aminah',
      'phone': '081234567890',
      'birth_date': '1995-08-17',
      'gender': 'female',
      'blood_type': 'AB',
    });
  });

  test('toRow sends null for values the database would reject', () {
    const profile = UserProfile(
      name: 'Budi',
      birthDate: '31-02-2000', // impossible date
      gender: 'Lainnya',
      bloodType: ProfileRowMapper.unknownBloodType,
      phone: '123',
    );

    final row = ProfileRowMapper.toRow(profile);
    expect(row['birth_date'], isNull);
    expect(row['gender'], isNull);
    expect(row['blood_type'], isNull);
    expect(row['phone'], isNull);
  });

  test('fromRow restores UI values and keeps device-only fields', () {
    const cached = UserProfile(
      id: 3,
      name: 'Old',
      bloodType: ProfileRowMapper.unknownBloodType,
      photoPath: '/a.jpg',
    );

    final profile = ProfileRowMapper.fromRow({
      'full_name': 'Budi',
      'birth_date': '1990-01-05',
      'gender': 'male',
      'blood_type': null,
      'phone': '081234567890',
    }, cached: cached);

    expect(profile.id, 3);
    expect(profile.name, 'Budi');
    expect(profile.birthDate, '05-01-1990');
    expect(profile.gender, 'Laki-laki');
    expect(
      profile.bloodType,
      ProfileRowMapper.unknownBloodType,
      reason: 'the "unknown blood type" choice is preserved',
    );
    expect(profile.photoPath, '/a.jpg');
  });

  test('fillMissing migrates MVP data without overwriting account values', () {
    const account = UserProfile(name: 'Budi (akun)');
    const legacy = UserProfile(
      name: 'Budi (lokal)',
      birthDate: '05-01-1990',
      gender: 'Laki-laki',
      bloodType: 'O',
      phone: '081234567890',
      photoPath: '/p.jpg',
    );

    final merged = ProfileRowMapper.fillMissing(account, legacy);
    expect(merged.name, 'Budi (akun)');
    expect(merged.birthDate, '05-01-1990');
    expect(merged.gender, 'Laki-laki');
    expect(merged.bloodType, 'O');
    expect(merged.phone, '081234567890');
    expect(merged.photoPath, '/p.jpg');
    expect(merged.isComplete, isTrue);
  });
}
