import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class AppStore extends ChangeNotifier {
  final questions = <Question>[];
  Set<String> bookmarks = {};
  Set<String> attempted = {};
  int correct = 0, wrong = 0, streak = 3, dailyGoal = 20;
  List<String> tasks = ['Complete a Quick Quiz', 'Review bookmarked questions'];
  bool darkMode = false;
  late SharedPreferences _prefs;
  Future<void> load(List<Question> all) async { questions.addAll(all); _prefs = await SharedPreferences.getInstance(); bookmarks = (_prefs.getStringList('bookmarks') ?? []).toSet(); attempted = (_prefs.getStringList('attempted') ?? []).toSet(); correct = _prefs.getInt('correct') ?? 0; wrong = _prefs.getInt('wrong') ?? 0; streak = _prefs.getInt('streak') ?? 3; dailyGoal = _prefs.getInt('goal') ?? 20; tasks = _prefs.getStringList('tasks') ?? tasks; darkMode = _prefs.getBool('dark') ?? false; notifyListeners(); }
  double get accuracy => correct + wrong == 0 ? 0 : correct / (correct + wrong);
  int get solvedToday => correct + wrong;
  void answer(Question q, bool right) { attempted.add(q.id); right ? correct++ : wrong++; _save(); notifyListeners(); }
  void toggleBookmark(Question q) { bookmarks.contains(q.id) ? bookmarks.remove(q.id) : bookmarks.add(q.id); _save(); notifyListeners(); }
  void addTask(String task) { if (task.trim().isNotEmpty) { tasks.add(task.trim()); _save(); notifyListeners(); } }
  void removeTask(int i) { tasks.removeAt(i); _save(); notifyListeners(); }
  void toggleTheme() { darkMode = !darkMode; _save(); notifyListeners(); }
  Future<void> _save() async { await _prefs.setStringList('bookmarks', bookmarks.toList()); await _prefs.setStringList('attempted', attempted.toList()); await _prefs.setInt('correct', correct); await _prefs.setInt('wrong', wrong); await _prefs.setInt('streak', streak); await _prefs.setInt('goal', dailyGoal); await _prefs.setStringList('tasks', tasks); await _prefs.setBool('dark', darkMode); }
  String exportProgress() => jsonEncode({'correct': correct, 'wrong': wrong, 'bookmarks': bookmarks.length});
}
