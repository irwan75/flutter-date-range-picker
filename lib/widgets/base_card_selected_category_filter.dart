import 'package:flutter/material.dart';

class BaseCardSelectedCategoryFilter extends StatelessWidget {
  final int? selectedMode;
  final int valueMode;
  final String title;
  final VoidCallback onTap;
  const BaseCardSelectedCategoryFilter({
    Key? key,
    this.selectedMode,
    required this.valueMode,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F7),
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(
          color: selectedMode == valueMode
              ? const Color(0xFF00529C)
              : const Color(0xFFE5E5E6),
          width: 2,
        ),
      ),
      child: InkWell(
        hoverColor: const Color(0xFFFF6500).withOpacity(0.2),
        splashColor: const Color(0xFFFF6500).withOpacity(0.7),
        borderRadius: BorderRadius.circular(4.0),
        onTap: onTap,
        child: Center(
          child: Text(
            title,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }
}
