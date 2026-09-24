import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:primafit/core/error/failure.dart';
import 'package:primafit/core/error/result.dart';
import 'package:primafit/features/profile/domain/entities/user_profile.dart';
import 'package:primafit/features/profile/domain/repositories/profile_repository.dart';
import 'package:primafit/features/profile/presentation/providers/profile_providers.dart';

class _FakeProfileRepository implements ProfileRepository {
  UserProfile? stored;
  Failure? saveFailure;
  int saves = 0;

  bool cacheCleared = false;

  @override
  Future<Result<UserProfile?>> getProfile() async => Result.success(stored);

  @override
  Future<void> clearLocalCache() async => cacheCleared = true;

  @override
  Future<Result<UserProfile>> saveProfile(UserProfile profile) async {
    saves++;
    if (saveFailure != null) return Result.failure(saveFailure!);
    stored = profile.copyWith(id: profile.id ?? 1);
    return Result.success(stored!);
  }
}

void main() {
  late _FakeProfileRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _FakeProfileRepository();
    container = ProviderContainer.test(
      overrides: [profileRepositoryProvider.overrideWithValue(repository)],
    );
  });

  test('loads null when onboarding has not been completed', () async {
    expect(await container.read(profileControllerProvider.future), isNull);
  });

  test('save publishes the stored profile to every listener', () async {
    await container.read(profileControllerProvider.future);

    final error = await container
        .read(profileControllerProvider.notifier)
        .save(const UserProfile(name: 'Ghazi', gender: 'Laki-laki', birthDate: '17-08-2000'));

    expect(error, isNull);
    final state = container.read(profileControllerProvider).value;
    expect(state?.id, 1);
    expect(state?.name, 'Ghazi');
    expect(state?.isComplete, isTrue);
  });

  test('save failure returns a user-facing message and keeps old state', () async {
    repository.stored = const UserProfile(id: 7, name: 'Lama');
    await container.read(profileControllerProvider.future);
    repository.saveFailure = const StorageFailure('Gagal menyimpan profil.');

    final error = await container
        .read(profileControllerProvider.notifier)
        .save(const UserProfile(id: 7, name: 'Baru'));

    expect(error, 'Gagal menyimpan profil.');
    expect(container.read(profileControllerProvider).value?.name, 'Lama');
  });

  test('profile is complete only with name, birth date and gender', () {
    expect(const UserProfile(name: 'Ghazi').isComplete, isFalse);
    expect(const UserProfile(name: 'Ghazi', gender: 'Laki-laki').isComplete, isFalse);
    expect(
      const UserProfile(name: 'Ghazi', gender: 'Laki-laki', birthDate: '17-08-2000').isComplete,
      isTrue,
    );
    expect(
      const UserProfile(name: ' ', gender: 'Laki-laki', birthDate: '17-08-2000').isComplete,
      isFalse,
    );
  });

  test('UserProfile keeps the legacy SQLite column names', () {
    const profile = UserProfile(
      name: 'A',
      birthDate: '2000-01-31',
      bloodType: 'O',
      photoPath: '/a.jpg',
    );

    expect(profile.toMap(), {
      'nama': 'A',
      'tanggalLahir': '2000-01-31',
      'gender': null,
      'golonganDarah': 'O',
      'telepon': null,
      'foto': '/a.jpg',
    });
    expect(UserProfile.fromMap({...profile.toMap(), 'id': 3}).id, 3);
  });
}
