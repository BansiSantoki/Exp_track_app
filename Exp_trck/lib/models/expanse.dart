class Expense {
  final String id;
  final String title;
  final double amount;
  final String categoty;
  final DateTime date;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoty,
    required this.date,
  });
  factory Expense.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Expense(
      id: documentId,
      title: data['title'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      categoty: data['categoty'] ?? '',
      date: (data['date'] != null
          ? DateTime.parse(data['date'] as String)
          : DateTime.now()),
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'amount': amount,
      'categoty': categoty,
      'date': date.toIso8601String(),
    };
  }

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? categoty,
    DateTime? date,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoty: categoty ?? this.categoty,
      date: date ?? this.date,
    );
  }
}
