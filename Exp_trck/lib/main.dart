import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:exp_trck/firebase_options.dart';
import 'package:exp_trck/screens/login_screen.dart';
import 'package:exp_trck/screens/register_screen.dart';
import 'package:exp_trck/screens/splash_screen.dart';
import 'package:exp_trck/models/expanse.dart';
import 'package:exp_trck/services/firestore_services.dart';
import 'package:exp_trck/screens/add_expense.dart';
import 'package:exp_trck/screens/expanse_card.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ExpTrck());
}

class ExpTrck extends StatelessWidget {
  const ExpTrck({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E63),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE91E63),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE91E63),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFDEEF4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFF8C8D9)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE91E63), width: 1.6),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const ExpenseTrackerHome(),
      },
    );
  }
}

class ExpenseTrackerHome extends StatefulWidget {
  const ExpenseTrackerHome({super.key});

  @override
  State<ExpenseTrackerHome> createState() => ExpenseTrackerHomeState();
}

class ExpenseTrackerHomeState extends State<ExpenseTrackerHome> {
  DateTime _month = DateTime.now();
  bool _monthview = false;
  final _service = FirestoreServices();

  static const Color _pink = Color(0xFFE91E63);
  static const Color _pinkDark = Color(0xFFC2185B);

  void _chgmonth(int value) {
    setState(() {
      _month = DateTime(_month.year, _month.month + value, 1);
    });
  }

  void _snack(String msg, [bool err = false]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: err ? Colors.red : null,
      ),
    );
  }

  void _sheet(Expense? e) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (c) => AddExpenseScreen(
        expenseToEdit: e,
        onSave: () => _snack(e == null ? 'Expense Added' : 'Expense Updated'),
      ),
    );
  }

  void _delete(String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context, rootNavigator: true);
              final messenger = ScaffoldMessenger.of(context);

              await _service.deleteExpense(id);
              if (!mounted) return;

              navigator.pop();
              messenger.showSnackBar(
                const SnackBar(content: Text('Expense Deleted')),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker Home'),
        centerTitle: true,
        backgroundColor: _pink,
        actions: [
          IconButton(
            onPressed: () {
              setState(() => _monthview = !_monthview);
            },
            icon: Icon(
              _monthview ? Icons.calendar_month : Icons.calendar_today,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _pink,
        child: const Icon(Icons.add),
        onPressed: () => _sheet(null),
      ),
      body: Column(
        children: [
          if (_monthview)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFAD5E4), Color(0xFFFFEEF4)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => _chgmonth(-1),
                      icon: const Icon(Icons.arrow_left),
                    ),
                    Text(
                      '${[
                        'Jan',
                        'Feb',
                        'Mar',
                        'Apr',
                        'May',
                        'Jun',
                        'Jul',
                        'Aug',
                        'Sep',
                        'Oct',
                        'Nov',
                        'Dec'
                      ][_month.month - 1]} ${_month.year}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _chgmonth(1),
                      icon: const Icon(Icons.arrow_right),
                    ),
                  ],
                ),
              ),
            ),

          /// TOTAL CARD
          Padding(
            padding: const EdgeInsets.all(16),
            child: StreamBuilder<double>(
              stream: _monthview
                  ? _service.getTotalExpensesByMonth(_month)
                  : _service.getTotalExpenses(),
              builder: (context, snapshot) {
                final amount = snapshot.data ?? 0.0;
                return Card(
                  elevation: 10,
                  color: const Color(0xFFFFD7E4),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          _monthview ? 'Monthly Expenses' : 'Total Expenses',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _pinkDark,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '₹ ${amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: _pinkDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          /// EXPENSE LIST
          Expanded(
            child: StreamBuilder<List<Expense>>(
              stream: _monthview
                  ? _service.getExpensesByMonth(_month)
                  : _service.getAllExpenses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final expenses = snapshot.data ?? [];

                if (expenses.isEmpty) {
                  return const Center(child: Text('No expenses found'));
                }

                return ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final e = expenses[index];

                    return ExpanseCard(
                      expense: e,
                      onEdit: () => _sheet(e),
                      onDelete: () => _delete(e.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
