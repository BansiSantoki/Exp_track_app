import 'package:flutter/material.dart';

class DailyLimitCard extends StatelessWidget {
  final double dailyLimit;
  final double todaySpent;

  const DailyLimitCard({
    super.key,
    required this.dailyLimit,
    required this.todaySpent,
  });

  @override
  Widget build(BuildContext context) {
    double progress = todaySpent / dailyLimit;
    bool overLimit = todaySpent > dailyLimit;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Spending Limit",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Text(
            "₹ ${todaySpent.toStringAsFixed(0)} / ₹ ${dailyLimit.toStringAsFixed(0)}",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: overLimit ? Colors.red : Colors.black,
            ),
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress > 1 ? 1 : progress,
              minHeight: 10,
              backgroundColor: Colors.white,
              color: overLimit ? Colors.red : Colors.green,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            overLimit ? "Limit Crossed ⚠️ Control spending" : "You're on track 😄",
            style: TextStyle(
              color: overLimit ? Colors.red : Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
