import 'package:flutter/material.dart';

class DatePickerWidget extends StatelessWidget {
  final String title;
  final DateTime? selectedDate;
  final Function(DateTime) onDatePicked;

  DatePickerWidget({required this.title, required this.selectedDate, required this.onDatePicked});

  Future<void> _pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      onDatePicked(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(selectedDate == null ? "เลือก$title" : "$title: ${selectedDate!.toLocal()}"),
      trailing: Icon(Icons.calendar_today),
      onTap: () => _pickDate(context),
    );
  }
}