import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat/presentation/base/base_stateful_widget.dart';
import 'package:chat/presentation/base/content_state/content_state_widget.dart';
import 'package:chat/presentation/flows/login/providers/login_provider.dart';
import 'package:chat/presentation/flows/login/states/action.dart';
import 'package:chat/presentation/flows/login/widgets/login_form.dart';
import 'package:chat/presentation/flows/login/widgets/login_header.dart';
import 'package:chat/routes/app_router.dart';

/// Pantalla de login siguiendo la arquitectura de flows.
///
/// Extiende ConsumerStatefulWidget y usa BaseStatefulWidget
/// para suscripciones automáticas a navegación y alertas.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends BaseStatefulWidget<LoginScreen> {
  @override
  Widget buildView(BuildContext context) {
    final state = ref.loginState;

    // Escuchar cambios de estado para navegación
    ref.listen(loginProvider.provider, (previous, next) {
      if ((next.message ?? '') == 'Login exitoso' &&
          (previous?.message ?? '') != (next.message ?? '')) {
        // Navegar a usuarios tras login exitoso
        context.goToUsers();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xffF2F2F2),
      body: ContentStateWidget(
        isLoading: state.isLoading,
        errorMessage:
            state.message?.contains('Error') == true ? state.message : null,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.9,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AuthHeader(title: 'Login'),
                  LoginForm(),
                  _LoginFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void onInitState() {
    super.onInitState();
    ref.executeLoginAction(const ClearForm());
  }
}

/// Footer de la pantalla de login.
class _LoginFooter extends StatelessWidget {
  const _LoginFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 50),
      child: TextButton(
        onPressed: () => context.goToRegister(),
        child: const Text(
          '¿No tienes cuenta? Crear una cuenta nueva',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
