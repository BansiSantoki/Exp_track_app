import 'package:flutter/material.dart';

class MonthMoodWidget extends StatelessWidget {
  final double totalExpense;
  final double monthlyBudget;

  const MonthMoodWidget({
    super.key,
    required this.totalExpense,
    required this.monthlyBudget,
  });

  @override
  Widget build(BuildContext context) {
    String emoji;
    String message;
    Color color;

    if (totalExpense <= monthlyBudget * 0.7) {
      emoji = "😄";
      message = "Great control this month!";
      color = Colors.green;
    } else if (totalExpense <= monthlyBudget) {
      emoji = "😐";
      message = "You're close to the limit";
      color = Colors.orange;
    } else {
      emoji = "😟";
      message = "Overspending this month";
      color = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Monthly Mood",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
