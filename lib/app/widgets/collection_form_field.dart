import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shared light form field for milk collection screens.
class CollectionFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool required;
  final String? hint;
  final TextInputType keyboard;
  final String? Function(String?)? validator;
  final bool readOnly;
  final ValueChanged<String>? onChanged;

  const CollectionFormField({
    super.key,
    required this.controller,
    required this.label,
    this.required = false,
    this.hint,
    this.keyboard = TextInputType.text,
    this.validator,
    this.readOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboard,
        onChanged: onChanged,
        inputFormatters: keyboard == TextInputType.number ||
                keyboard == const TextInputType.numberWithOptions(decimal: true)
            ? [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ]
            : null,
        style: const TextStyle(
          color: Color(0xFF263238),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          label: RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                color: Color(0xFF546E7A),
                fontSize: 14,
              ),
              children: required
                  ? const [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(
                          color: Color(0xFFD32F2F),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ]
                  : null,
            ),
          ),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.blueGrey.shade300, fontSize: 13),
          filled: true,
          fillColor: readOnly ? const Color(0xFFF5F7FA) : Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCFD8DC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF007EA7), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD32F2F)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
          ),
          errorStyle: const TextStyle(
            color: Color(0xFFC62828),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        validator: validator ??
            (required
                ? (v) {
                    if (v == null || v.trim().isEmpty) {
                      return '$label is required';
                    }
                    return null;
                  }
                : null),
      ),
    );
  }
}

class CollectionSectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;

  const CollectionSectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3E8EF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B3A4B),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF607D8B),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
          ] else
            const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}
