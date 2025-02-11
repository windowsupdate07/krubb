import 'package:flutter/material.dart';

class InputCard extends StatelessWidget {
  final IconData icon;
  final String hint;
  final TextEditingController controller;
  final int maxLines;

  const InputCard({
    Key? key,
    required this.icon,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}