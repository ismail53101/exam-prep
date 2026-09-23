class Question {
  final String id, subject, text, explanation, difficulty;
  final List<String> options;
  final int answer;
  const Question({required this.id, required this.subject, required this.text, required this.options, required this.answer, required this.explanation, required this.difficulty});
}

class QuizResult {
  final int correct, total;
  final String title;
  final DateTime date;
  const QuizResult({required this.correct, required this.total, required this.title, required this.date});
  double get accuracy => total == 0 ? 0 : correct / total;
}
