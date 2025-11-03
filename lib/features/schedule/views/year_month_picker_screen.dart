import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class YearMonthPickerScreen extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onMonthSelected;

  const YearMonthPickerScreen({
    super.key,
    required this.initialDate,
    required this.onMonthSelected,
  });

  @override
  State<YearMonthPickerScreen> createState() => _YearMonthPickerScreenState();
}

class _YearMonthPickerScreenState extends State<YearMonthPickerScreen> {
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialDate.year;
  }

  @override
  Widget build(BuildContext context) {
    List<String> months = List.generate(12, (index) {
      return DateFormat.MMMM().format(DateTime(0, index + 1));
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Month"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() => selectedYear--);
                },
              ),
              Expanded(
                child: Center(
                  child: Text(
                    "$selectedYear",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                )
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() => selectedYear++);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: months.length,
              itemBuilder: (context, index) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.blue[800],
                  ),
                  onPressed: () {
                    widget.onMonthSelected(DateTime(selectedYear, index + 1, 1));
                  },
                  child: Text(months[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
