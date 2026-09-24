import 'package:flutter_test/flutter_test.dart';
import 'package:primafit/features/recommendation/presentation/pakaian/list_pertanyaan.dart';

List<String> _bodyTypeOptions(Map<String, String> answers) {
  final question = FashionQuestions.activeQuestions(
    answers,
  ).firstWhere((q) => q['id'] == 'body_type');
  return List<String>.from(question['options']);
}

void main() {
  test('body type options are filtered by gender', () {
    final male = _bodyTypeOptions({'gender': 'Pria'});

    expect(male, isNotEmpty);
    expect(male.every((o) => o.startsWith('Pria') || o == 'Prefer Not to Specify'), isTrue);
  });

  test('regression: filtering does not mutate the shared question list', () {
    final before = _bodyTypeOptions({});

    _bodyTypeOptions({'gender': 'Pria'});
    final female = _bodyTypeOptions({'gender': 'Wanita'});

    expect(_bodyTypeOptions({}), before, reason: 'static question list must stay intact');
    expect(female.any((o) => o.startsWith('Wanita')), isTrue);
  });
}
