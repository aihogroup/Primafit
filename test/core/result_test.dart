import 'package:flutter_test/flutter_test.dart';
import 'package:primafit/core/error/failure.dart';
import 'package:primafit/core/error/result.dart';

void main() {
  group('guard', () {
    test('wraps a returned value in Success', () async {
      final result = await guard(() async => 42);

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, 42);
    });

    test('maps a thrown exception to UnexpectedFailure by default', () async {
      final result = await guard<int>(() async => throw StateError('boom'));

      expect(result.isSuccess, isFalse);
      result.when(
        success: (_) => fail('expected failure'),
        failure: (f) {
          expect(f, isA<UnexpectedFailure>());
          expect(f.cause, isA<StateError>());
        },
      );
    });

    test('uses the provided onError mapper', () async {
      final result = await guard<int>(
        () async => throw Exception('disk full'),
        onError: (e) => StorageFailure('Penyimpanan penuh', e),
      );

      expect(
        result.when(success: (_) => null, failure: (f) => f),
        isA<StorageFailure>().having((f) => f.message, 'message', 'Penyimpanan penuh'),
      );
    });
  });
}
