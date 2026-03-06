import 'package:flutter/material.dart';
import 'package:task_8/core/theme/app_colors.dart';

class CustomDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String>? items;
  final Function(String?) onChanged;

  const CustomDropdown({
    super.key,
    required this.hint,
    this.items,
    required this.onChanged,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        filled: true,
        fillColor: AppColors.lightColor,
        hintText: hint,
      ),
      initialValue: value,
      items: items?.map((item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }
}
