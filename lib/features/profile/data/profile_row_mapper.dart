import 'package:intl/intl.dart';

import '../domain/entities/user_profile.dart';

/// Converts between the app's profile format (legacy UI values, e.g.
/// `dd-MM-yyyy`, "Laki-laki") and the `public.profiles` row format
/// (ISO date, `male`/`female`) enforced by the database CHECK constraints.
abstract final class ProfileRowMapper {
  static const columns = 'full_name, phone, birth_date, gender, blood_type';

  static const unknownBloodType = 'Tidak tahu';
  static const _bloodTypes = {'A', 'B', 'AB', 'O'};
  static const _genderToDb = {'Laki-laki': 'male', 'Perempuan': 'female'};
  static const _genderFromDb = {'male': 'Laki-laki', 'female': 'Perempuan'};

  static final _uiDate = DateFormat('dd-MM-yyyy');
  static final _dbDate = DateFormat('yyyy-MM-dd');

  /// Row for insert/update. Values the database would reject are sent as
  /// `null` rather than failing the whole save.
  static Map<String, Object?> toRow(UserProfile profile) => {
    'full_name': profile.name.trim(),
    'phone': _normalizePhone(profile.phone),
    'birth_date': _convertDate(profile.birthDate, from: _uiDate, to: _dbDate),
    'gender': _genderToDb[profile.gender],
    'blood_type': _bloodTypes.contains(profile.bloodType) ? profile.bloodType : null,
  };

  /// Builds the app profile from a row. Device-only fields (local id, photo
  /// path) and the "unknown blood type" choice come from [cached].
  static UserProfile fromRow(Map<String, dynamic> row, {UserProfile? cached}) {
    final bloodType = row['blood_type'] as String?;
    return UserProfile(
      id: cached?.id,
      name: (row['full_name'] as String?) ?? '',
      birthDate: _convertDate(row['birth_date'] as String?, from: _dbDate, to: _uiDate),
      gender: _genderFromDb[row['gender']],
      bloodType: bloodType ?? (cached?.bloodType == unknownBloodType ? unknownBloodType : null),
      phone: row['phone'] as String?,
      photoPath: cached?.photoPath,
    );
  }

  /// Fills fields the account is missing with values from an on-device MVP
  /// profile (first sign-in migration). Account values always win.
  static UserProfile fillMissing(UserProfile account, UserProfile legacy) => UserProfile(
    id: account.id,
    name: account.name.trim().isNotEmpty ? account.name : legacy.name,
    birthDate: _blankToNull(account.birthDate) ?? legacy.birthDate,
    gender: _blankToNull(account.gender) ?? legacy.gender,
    bloodType: _blankToNull(account.bloodType) ?? legacy.bloodType,
    phone: _blankToNull(account.phone) ?? legacy.phone,
    photoPath: _blankToNull(account.photoPath) ?? legacy.photoPath,
  );

  static String? _normalizePhone(String? phone) {
    final cleaned = phone?.replaceAll(RegExp(r'[^0-9+]'), '') ?? '';
    return RegExp(r'^\+?[0-9]{10,15}$').hasMatch(cleaned) ? cleaned : null;
  }

  static String? _convertDate(String? value, {required DateFormat from, required DateFormat to}) {
    if (value == null || value.isEmpty) return null;
    try {
      return to.format(from.parseStrict(value));
    } on FormatException {
      return null;
    }
  }

  static String? _blankToNull(String? value) => (value == null || value.isEmpty) ? null : value;
}
