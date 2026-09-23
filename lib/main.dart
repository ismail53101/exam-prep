import 'dart:async';
import 'package:flutter/material.dart';
import 'data.dart';
import 'models.dart';
import 'store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = AppStore();
  await store.load(buildQuestions());
  runApp(ExamPrepApp(store: store));
}

class ExamPrepApp extends StatelessWidget {
  final AppStore store;
  const ExamPrepApp({super.key, required this.store});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: store,
        builder: (_, __) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ExamPrep',
          themeMode: store.darkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(colorSchemeSeed: const Color(0xff315c9b), useMaterial3: true),
          darkTheme: ThemeData(colorSchemeSeed: const Color(0xff8eb7ff), brightness: Brightness.dark, useMaterial3: true),
          home: Shell(store: store),
        ),
      );
}

class Shell extends StatefulWidget {
  final AppStore store;
  const Shell({super.key, required this.store});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [
      Dashboard(store: widget.store, onQuiz: () => setState(() => tab = 1)),
      QuestionBank(store: widget.store),
      Planner(store: widget.store),
      ProgressPage(store: widget.store),
    ];
    return Scaffold(
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (value) => setState(() => tab = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Question Bank'),
          NavigationDestination(icon: Icon(Icons.event_note_outlined), selectedIcon: Icon(Icons.event_note), label: 'Planner'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Progress'),
        ],
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  final AppStore store;
  final VoidCallback onQuiz;
  const Dashboard({super.key, required this.store, required this.onQuiz});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text('ExamPrep', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [IconButton(onPressed: store.toggleTheme, icon: Icon(store.darkMode ? Icons.light_mode : Icons.dark_mode))],
          floating: true,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text('Good morning, learner 👋', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 5),
              Text('Build your knowledge, one question at a time.', style: TextStyle(color: colors.onSurfaceVariant)),
              const SizedBox(height: 22),
              _progressCard(context),
              const SizedBox(height: 22),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Practice modes', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), TextButton(onPressed: onQuiz, child: const Text('View all'))]),
              const SizedBox(height: 8),
              Row(children: [_mode(context, Icons.bolt, 'Quick Quiz', '10 questions'), const SizedBox(width: 12), _mode(context, Icons.timer_outlined, 'Timed Test', '15 minutes')]),
              const SizedBox(height: 26),
              Text('Subjects', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(spacing: 10, runSpacing: 10, children: subjects.take(6).map((s) => ActionChip(avatar: Icon(_subjectIcon(s), size: 18), label: Text(s), onPressed: onQuiz)).toList()),
              const SizedBox(height: 24),
              Text('Your study streak', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Card(child: ListTile(leading: const Icon(Icons.local_fire_department, color: Colors.orange, size: 34), title: Text('${store.streak} day streak'), subtitle: const Text('Keep going — consistency beats intensity.'), trailing: Text('${store.solvedToday}/${store.dailyGoal}'))),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _progressCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final double progress = store.dailyGoal == 0 ? 0.0 : (store.solvedToday / store.dailyGoal).clamp(0.0, 1.0).toDouble();
    return Card(color: colors.primary, child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Today's progress", style: TextStyle(color: colors.onPrimary.withAlpha(205))), const SizedBox(height: 8), Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('${store.solvedToday}', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: colors.onPrimary)), Text(' / ${store.dailyGoal} questions', style: TextStyle(color: colors.onPrimary.withAlpha(205)))]), const SizedBox(height: 14), ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: colors.onPrimary.withAlpha(50), color: colors.onPrimary)), const SizedBox(height: 16), Row(children: [Text('${(store.accuracy * 100).round()}% accuracy', style: TextStyle(color: colors.onPrimary)), const Spacer(), Text('${store.correct} correct • ${store.wrong} wrong', style: TextStyle(color: colors.onPrimary.withAlpha(205)))])])));
  }

  Widget _mode(BuildContext context, IconData icon, String title, String subtitle) => Expanded(child: Card(child: InkWell(onTap: onQuiz, borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 12), Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(subtitle, style: Theme.of(context).textTheme.bodySmall)])))));
  IconData _subjectIcon(String value) => value == 'Mathematics' ? Icons.calculate_outlined : value == 'Computer Science' ? Icons.computer : value == 'English Grammar' ? Icons.translate : Icons.public;
}

class QuestionBank extends StatefulWidget {
  final AppStore store;
  const QuestionBank({super.key, required this.store});
  @override
  State<QuestionBank> createState() => _QuestionBankState();
}

class _QuestionBankState extends State<QuestionBank> {
  String query = '';
  String filter = 'All';
  @override
  Widget build(BuildContext context) {
    final questions = widget.store.questions.where((q) => (filter == 'All' || q.subject == filter) && q.text.toLowerCase().contains(query.toLowerCase())).toList();
    return Column(children: [
      AppBar(title: const Text('Question Bank'), actions: [IconButton(onPressed: () => _start(questions), icon: const Icon(Icons.play_arrow))]),
      Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 8), child: TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search questions'), onChanged: (value) => setState(() => query = value))),
      SizedBox(height: 45, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: ['All', ...subjects].map((subject) => Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(subject), selected: filter == subject, onSelected: (_) => setState(() => filter = subject))).toList()))),
      Expanded(child: ListView.builder(itemCount: questions.length, itemBuilder: (_, index) { final question = questions[index]; return ListTile(leading: CircleAvatar(child: Text('${index + 1}')), title: Text(question.text, maxLines: 2, overflow: TextOverflow.ellipsis), subtitle: Text('${question.subject} • ${question.difficulty}'), trailing: IconButton(icon: Icon(widget.store.bookmarks.contains(question.id) ? Icons.bookmark : Icons.bookmark_border), onPressed: () => widget.store.toggleBookmark(question))); })),
    ]);
  }
  void _start(List<Question> questions) { if (questions.isNotEmpty) Navigator.push(context, MaterialPageRoute(builder: (_) => QuizPage(store: widget.store, questions: questions.take(10).toList(), title: 'Practice Quiz'))); }
}

class QuizPage extends StatefulWidget {
  final AppStore store;
  final List<Question> questions;
  final String title;
  const QuizPage({super.key, required this.store, required this.questions, required this.title});
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int index = 0, selected = -1, correct = 0, seconds = 900;
  Timer? timer;
  bool answered = false;
  @override
  void initState() { super.initState(); timer = Timer.periodic(const Duration(seconds: 1), (_) { if (!mounted) return; if (seconds > 0) setState(() => seconds--); else _finish(); }); }
  @override
  void dispose() { timer?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final question = widget.questions[index];
    return Scaffold(appBar: AppBar(title: Text(widget.title), actions: [Text('${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}'), const SizedBox(width: 16)]), body: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [LinearProgressIndicator(value: (index + 1) / widget.questions.length), const SizedBox(height: 24), Text('Question ${index + 1} of ${widget.questions.length}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)), const SizedBox(height: 12), Text(question.text, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 22), ...question.options.asMap().entries.map((entry) => _option(question, entry.key, entry.value)), if (answered) Card(child: Padding(padding: const EdgeInsets.all(14), child: Text(question.explanation))), const Spacer(), SizedBox(width: double.infinity, child: FilledButton(onPressed: answered ? _next : null, child: Text(index == widget.questions.length - 1 ? 'Finish quiz' : 'Next question')))]));
  }
  Widget _option(Question question, int value, String text) => Card(child: RadioListTile<int>(value: value, groupValue: selected, onChanged: answered ? null : (answer) { setState(() { selected = answer!; answered = true; widget.store.answer(question, answer == question.answer); if (answer == question.answer) correct++; }); }, title: Text(text)));
  void _next() { if (index == widget.questions.length - 1) _finish(); else setState(() { index++; selected = -1; answered = false; }); }
  void _finish() { timer?.cancel(); if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ResultPage(correct: correct, total: widget.questions.length, title: widget.title))); }
}

class ResultPage extends StatelessWidget {
  final int correct, total;
  final String title;
  const ResultPage({super.key, required this.correct, required this.total, required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Quiz complete')), body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(correct >= total / 2 ? Icons.emoji_events : Icons.refresh, size: 78, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 20), Text('Great work!', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text('$title results'), const SizedBox(height: 28), Text('$correct / $total', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)), Text('${(correct / total * 100).round()}% accuracy'), const SizedBox(height: 28), FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Back to dashboard'))])));
}

class Planner extends StatefulWidget {
  final AppStore store;
  const Planner({super.key, required this.store});
  @override
  State<Planner> createState() => _PlannerState();
}

class _PlannerState extends State<Planner> {
  void addTask() {
    final controller = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(title: const Text('New study task'), content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: 'Task name')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () { widget.store.addTask(controller.text); Navigator.pop(context); }, child: const Text('Add'))]));
  }
  @override
  Widget build(BuildContext context) => Column(children: [AppBar(title: const Text('Study planner'), actions: [IconButton(onPressed: addTask, icon: const Icon(Icons.add))]), Expanded(child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: widget.store.tasks.length, itemBuilder: (_, index) => Card(child: ListTile(leading: const Icon(Icons.task_alt), title: Text(widget.store.tasks[index]), trailing: IconButton(onPressed: () => widget.store.removeTask(index), icon: const Icon(Icons.delete_outline))))))]);
}

class ProgressPage extends StatelessWidget {
  final AppStore store;
  const ProgressPage({super.key, required this.store});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Progress')), body: ListView(padding: const EdgeInsets.all(20), children: [Card(child: ListTile(title: const Text('Questions answered'), trailing: Text('${store.solvedToday}'))), Card(child: ListTile(title: const Text('Correct answers'), trailing: Text('${store.correct}'))), Card(child: ListTile(title: const Text('Accuracy'), trailing: Text('${(store.accuracy * 100).round()}%'))), Card(child: ListTile(title: const Text('Bookmarked questions'), trailing: Text('${store.bookmarks.length}')))]);
}
