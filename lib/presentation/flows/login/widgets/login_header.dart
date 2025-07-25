import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chat/presentation/core/base_hook_widget.dart';

/// Header reutilizable para pantallas de autenticación.
///
/// Widget pequeño y enfocado que muestra el logo y título personalizable.
/// Sigue la regla de widgets pequeños y reutilizables.
class AuthHeader extends BaseHookWidget {
  final String title;

  const AuthHeader({
    super.key,
    this.title = 'Messenger',
  });

  @override
  Widget buildView(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(top: 50),
      child: Column(
        children: [
          // Logo
          Container(
            width: 170,
            height: 170,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/tag-logo.png'),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Título
          Text(
            title,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}

/// Alias para mantener compatibilidad con login.
class LoginHeader extends AuthHeader {
  const LoginHeader({super.key}) : super(title: 'Messenger');
}
