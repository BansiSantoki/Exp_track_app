import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exp_trck/models/expanse.dart';

class FirestoreServices {
  static final FirestoreServices _instance = FirestoreServices._internal();

  factory FirestoreServices() {
    return _instance;
  }

  FirestoreServices._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String collectionPath = 'expenses';

  /// 🔹 Get all expenses
  Stream<List<Expense>> getAllExpenses() {
    return _db
        .collection(collectionPath)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Expense.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  /// 🔹 Get total expenses by month
  Stream<double> getTotalExpensesByMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    return _db
        .collection(collectionPath)
        .where(
          'date',
          isGreaterThanOrEqualTo: firstDay.toIso8601String(),
        )
        .where(
          'date',
          isLessThanOrEqualTo: lastDay.toIso8601String(),
        )
        .snapshots()
        .map((snapshot) {
      double total = 0.0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
        total += amount;
      }

      return total;
    });
  }

  /// 🔹 Get total expenses (all time)
  Stream<double> getTotalExpenses() {
    return _db.collection(collectionPath).snapshots().map((snapshot) {
      double total = 0.0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
        total += amount;
      }

      return total;
    });
  }

  //Get expenses for specific  month
  Stream<List<Expense>> getExpensesByMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    return _db
        .collection(collectionPath)
        .where(
          'date',
          isGreaterThanOrEqualTo: firstDay.toIso8601String(),
        )
        .where(
          'date',
          isLessThanOrEqualTo: lastDay.toIso8601String(),
        )
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Expense.fromFirestore(
            doc.data(), doc.id);
      }).toList();
    });
  }

  //Add expense
  Future<void> addExpense(Expense expense) async {
    await _db.collection(collectionPath).add(expense.toFirestore());
  }

  //Update expense
  Future<void> updateExpense(Expense expense) async {
    await _db
        .collection(collectionPath)
        .doc(expense.id)
        .update(expense.toFirestore());
  }

  //Delete expense
  Future<void> deleteExpense(String id) async {
    await _db.collection(collectionPath).doc(id).delete();
  }
}
