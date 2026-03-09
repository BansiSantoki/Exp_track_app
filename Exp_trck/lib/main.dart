import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:exp_trck/firebase_options.dart';
import 'package:exp_trck/screens/Splash_Screen.dart';
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
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const SplashScreen(),
      routes: {
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
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _service.deleteExpense(id);
              Navigator.pop(context);
              _snack('Expense Deleted');
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
        backgroundColor: Colors.green,
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
        backgroundColor: Colors.green,
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
                  color: Colors.green[100],
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
                  color: Colors.green[200],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          _monthview ? 'Monthly Expenses' : 'Total Expenses',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '₹ ${amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
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

