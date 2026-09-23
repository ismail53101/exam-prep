import 'package:flutter_test/flutter_test.dart';
import 'package:examprep/data.dart';

void main() {
  test('question bank contains 108 playable MCQs', () {
    final questions = buildQuestions();
    expect(questions.length, 108);
    expect(questions.every((q) => q.options.length == 4 && q.answer >= 0), isTrue);
  });
}
