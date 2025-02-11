import 'package:flutter/material.dart';

class ExpandableCheckboxList extends StatefulWidget {
  final String title;
  final Set<String> items;
  final List<String> selectedItems;
  final Function(List<String>) onSelectionChanged; // Callback เมื่อมีการเลือก

  const ExpandableCheckboxList({
    Key? key,
    required this.title,
    required this.items,
    required this.selectedItems,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  _ExpandableCheckboxListState createState() => _ExpandableCheckboxListState();
}

class _ExpandableCheckboxListState extends State<ExpandableCheckboxList> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        iconColor: Colors.blueAccent,
        collapsedIconColor: Colors.grey,
        title: Text(
          widget.title,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        children: widget.items.map((item) {
          return CheckboxListTile(
            title: Text(item),
            value: widget.selectedItems.contains(item),
            onChanged: (bool? selected) {
              setState(() {
                if (selected!) {
                  widget.selectedItems.add(item);
                } else {
                  widget.selectedItems.remove(item);
                }
              });

              // 🔄 เรียก callback เพื่อล่าสุดค่ากลับไปให้หน้าหลัก
              widget.onSelectionChanged(widget.selectedItems);
            },
          );
        }).toList(),
      ),
    );
  }
}