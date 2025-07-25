import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chat/presentation/core/base_hook_widget.dart';

/// Campo de texto personalizado y reutilizable.
///
/// Encapsula la lógica visual del input sin depender
/// de lógica de negocio específica.
class CustomTextField extends BaseHookWidget {
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final bool enabled;
  final int maxLines;
  final String? errorText;

  const CustomTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.errorText,
  });

  @override
  Widget buildView(BuildContext context, WidgetRef ref) {
    final isObscured = useState(isPassword);
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        obscureText: isObscured.value,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        enabled: enabled,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          errorText: errorText,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: theme.primaryColor)
              : null,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isObscured.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: theme.primaryColor,
                  ),
                  onPressed: () => isObscured.value = !isObscured.value,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: theme.primaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: theme.primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}
