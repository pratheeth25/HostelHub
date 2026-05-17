import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/food_provider.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  DateTime _selectedDate = DateTime.now();
  int _breakfast = 0;
  int _lunch = 0;
  int _dinner = 0;
  bool _isLoading = false;
  bool _fetching = false;

  @override
  void initState() {
    super.initState();
    _loadMeal();
  }

  Future<void> _loadMeal() async {
    setState(() => _fetching = true);
    final authProvider = context.read<AuthProvider>();
    final provider = context.read<FoodProvider>();
    final meal = await provider.getUserMealForDate(
        authProvider.currentUser!.uid, _selectedDate);
    if (mounted) {
      setState(() {
        _breakfast = meal?.breakfast ?? 0;
        _lunch = meal?.lunch ?? 0;
        _dinner = meal?.dinner ?? 0;
        _fetching = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();
    final provider = context.read<FoodProvider>();
    final error = await provider.updateMeal(
      userId: authProvider.currentUser!.uid,
      date: _selectedDate,
      breakfast: _breakfast,
      lunch: _lunch,
      dinner: _dinner,
    );
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meal count saved!'), backgroundColor: Colors.green),
      );
    }
  }

  void _changeDate(int days) {
    setState(() => _selectedDate = _selectedDate.add(Duration(days: days)));
    _loadMeal();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.read<AuthProvider>().isAdmin;
    return Scaffold(
      appBar: AppBar(title: const Text('Food Count')),
      body: _fetching
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: () => _changeDate(-1),
                          ),
                          Expanded(
                            child: Text(
                              DateFormat('EEEE, MMM dd yyyy').format(_selectedDate),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () => _changeDate(1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!isAdmin) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Meal Count',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '0 = Not eating • 1 = Normal • 2 = Double',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            const SizedBox(height: 16),
                            _MealCounter(
                              label: 'Breakfast',
                              icon: Icons.free_breakfast,
                              color: Colors.orange,
                              value: _breakfast,
                              onChanged: (v) => setState(() => _breakfast = v),
                            ),
                            const Divider(),
                            _MealCounter(
                              label: 'Lunch',
                              icon: Icons.lunch_dining,
                              color: Colors.green,
                              value: _lunch,
                              onChanged: (v) => setState(() => _lunch = v),
                            ),
                            const Divider(),
                            _MealCounter(
                              label: 'Dinner',
                              icon: Icons.dinner_dining,
                              color: Colors.indigo,
                              value: _dinner,
                              onChanged: (v) => setState(() => _dinner = v),
                            ),
                            const SizedBox(height: 16),
                            AppButton(
                              label: 'Save Meal Count',
                              onPressed: _save,
                              isLoading: _isLoading,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _DailyTotalsCard(date: _selectedDate),
                ],
              ),
            ),
    );
  }
}

class _MealCounter extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final int value;
  final ValueChanged<int> onChanged;

  const _MealCounter({
    required this.label,
    required this.icon,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: value > 0 ? () => onChanged(value - 1) : null,
            color: color,
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: value < 2 ? () => onChanged(value + 1) : null,
            color: color,
          ),
        ],
      ),
    );
  }
}

class _DailyTotalsCard extends StatelessWidget {
  final DateTime date;

  const _DailyTotalsCard({required this.date});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<FoodProvider>();
    return StreamBuilder<Map<String, int>>(
      stream: provider.getDailyTotalsStream(date),
      builder: (context, snapshot) {
        final totals = snapshot.data ?? {'breakfast': 0, 'lunch': 0, 'dinner': 0};
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Totals',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _TotalChip(
                      label: 'Breakfast',
                      count: totals['breakfast']!,
                      color: Colors.orange,
                    ),
                    _TotalChip(
                      label: 'Lunch',
                      count: totals['lunch']!,
                      color: Colors.green,
                    ),
                    _TotalChip(
                      label: 'Dinner',
                      count: totals['dinner']!,
                      color: Colors.indigo,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TotalChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _TotalChip({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
