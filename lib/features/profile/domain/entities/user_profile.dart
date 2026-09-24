import 'package:flutter/foundation.dart';

/// Immutable profile of the person using the app.
///
/// Field values keep the on-device format used since the MVP
/// (`tanggalLahir` as `yyyy-MM-dd`, Indonesian gender labels) so existing
/// local data stays readable.
@immutable
class UserProfile {
  const UserProfile({
    this.id,
    required this.name,
    this.birthDate,
    this.gender,
    this.bloodType,
    this.phone,
    this.photoPath,
  });

  final int? id;
  final String name;
  final String? birthDate;
  final String? gender;
  final String? bloodType;
  final String? phone;
  final String? photoPath;

  /// Onboarding is complete once name, birth date and gender are known: the
  /// health-record analyses derive age/gender-specific normal ranges from them.
  bool get isComplete =>
      name.trim().isNotEmpty && (birthDate?.isNotEmpty ?? false) && (gender?.isNotEmpty ?? false);

  factory UserProfile.fromMap(Map<String, Object?> map) => UserProfile(
    id: map['id'] as int?,
    name: (map['nama'] as String?) ?? '',
    birthDate: map['tanggalLahir'] as String?,
    gender: map['gender'] as String?,
    bloodType: map['golonganDarah'] as String?,
    phone: map['telepon'] as String?,
    photoPath: map['foto'] as String?,
  );

  Map<String, Object?> toMap() => {
    'nama': name,
    'tanggalLahir': birthDate,
    'gender': gender,
    'golonganDarah': bloodType,
    'telepon': phone,
    'foto': photoPath,
  };

  UserProfile copyWith({
    int? id,
    String? name,
    String? birthDate,
    String? gender,
    String? bloodType,
    String? phone,
    String? photoPath,
  }) => UserProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    birthDate: birthDate ?? this.birthDate,
    gender: gender ?? this.gender,
    bloodType: bloodType ?? this.bloodType,
    phone: phone ?? this.phone,
    photoPath: photoPath ?? this.photoPath,
  );
}
