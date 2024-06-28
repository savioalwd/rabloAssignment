import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final String hintText;
  final double height;
  final RegExp validationRegExp;
  final bool obscureText;
  final String? initialValue;
  final bool readOnly;
  final void Function(String?) onSaved;

  const CustomFormField({
    super.key,
    required this.hintText,
    required this.height,
    required this.validationRegExp,
    required this.onSaved,
    this.obscureText = false,
    this.initialValue,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextFormField(
        initialValue: initialValue,
        onSaved: onSaved,
        readOnly: readOnly,
        obscureText: obscureText,
        validator: (value) {
          if (value != null && validationRegExp.hasMatch(value)) {
            return null;
          } else {
            return "Enter a valid ${hintText.toLowerCase()}";
          }
        },
        decoration: InputDecoration(
          hintText: hintText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
