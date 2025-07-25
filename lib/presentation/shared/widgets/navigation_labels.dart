import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chat/presentation/core/base_hook_widget.dart';
import 'package:chat/routes/app_router.dart';

/// Widget reutilizable para mostrar etiquetas de navegación.
///
/// Muestra un texto descriptivo y un enlace clickeable para navegar
/// a otra pantalla. Usado típicamente en pantallas de auth.
class NavigationLabels extends BaseHookWidget {
  /// Ruta a la que navegar cuando se hace tap.
  final String route;

  /// Texto descriptivo (pregunta).
  final String title;

  /// Texto del enlace clickeable.
  final String subtitle;

  /// Color del título (opcional).
  final Color? titleColor;

  /// Color del subtítulo/enlace (opcional).
  final Color? subtitleColor;

  const NavigationLabels({
    super.key,
    required this.route,
    required this.title,
    required this.subtitle,
    this.titleColor,
    this.subtitleColor,
  });

  @override
  Widget buildView(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: titleColor ?? Colors.black54,
            fontSize: 15,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            // Usar go_router basado en la ruta
            switch (route) {
              case 'login':
                context.goToLogin();
                break;
              case 'register':
                context.goToRegister();
                break;
              case 'usuarios':
                context.goToUsers();
                break;
              default:
                context.goToLogin();
            }
          },
          child: Text(
            subtitle,
            style: TextStyle(
              color: subtitleColor ?? theme.primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
