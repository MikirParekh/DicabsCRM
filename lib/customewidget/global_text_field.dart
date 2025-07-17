import 'package:dicabs/core/color.dart';
import 'package:flutter/material.dart';

class GlobalTextFormField extends StatelessWidget {
  final String labelText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final int maxLine;
  final VoidCallback? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  const GlobalTextFormField({
    super.key,
    required this.labelText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.maxLine = 1,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      decoration: ShapeDecoration(
        color: DColor.primaryColor.withOpacity(0.09), // Fill color
        shape: ContinuousRectangleBorder(
           borderRadius: BorderRadius.circular(50)
        )
      ),
      child: Center(
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLine,
          onTap: onTap,
          style: Theme.of(context).textTheme.bodyLarge,
          validator: validator,
          onChanged: onChanged,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(16),
            border: InputBorder.none,
            hintText: labelText,
            hintStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.grey),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            suffixIconColor: Colors.grey,
            prefixIconColor: Colors.grey,
            errorMaxLines: 3,
            errorBorder: InputBorder.none,
              errorStyle: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.red)
          ),
        ),
      ),
    );
  }
}
