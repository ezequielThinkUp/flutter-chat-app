import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chat/presentation/core/base_hook_widget.dart';

/// Botón primario reutilizable para la aplicación.
///
/// Widget completamente desacoplado de la lógica de negocio,
/// recibe todos los datos necesarios por parámetros.
class PrimaryButton extends BaseHookWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.enabled = true,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 55,
  });

  @override
  Widget buildView(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? theme.primaryColor,
          foregroundColor: textColor ?? Colors.white,
          elevation: 2,
          shape: const StadiumBorder(),
          disabledBackgroundColor: Colors.grey[300],
        ),
        onPressed: (enabled && !isLoading) ? onPressed : null,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? Colors.white,
                ),
              ),
      ),
    );
  }
}
