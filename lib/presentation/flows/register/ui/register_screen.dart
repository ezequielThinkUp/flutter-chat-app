import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat/presentation/base/base_stateful_widget.dart';
import 'package:chat/presentation/base/content_state/content_state_widget.dart';
import 'package:chat/presentation/flows/register/providers/register_provider.dart';
import 'package:chat/presentation/flows/register/states/action.dart';
import 'package:chat/presentation/flows/register/widgets/register_form.dart';
import 'package:chat/presentation/flows/login/widgets/login_header.dart';
import 'package:chat/routes/app_router.dart';

/// Pantalla de registro siguiendo la arquitectura de flows.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends BaseStatefulWidget<RegisterScreen> {
  @override
  Widget buildView(BuildContext context) {
    final state = ref.registerState;

    // Escuchar cambios de estado para navegación
    ref.listen(registerProvider.provider, (previous, next) {
      if (next.message == 'Registro exitoso' &&
          previous?.message != next.message) {
        // Navegar al login tras registro exitoso usando PostFrameCallback
        // para asegurar que el contexto esté disponible
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.goToLogin();
          }
        });
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AuthHeader(title: 'Registro'),
                  const RegisterForm(),
                  _RegisterFooter(),
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
    ref.executeRegisterAction(const ClearForm());
  }
}

/// Footer de la pantalla de registro.
class _RegisterFooter extends StatelessWidget {
  const _RegisterFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 50),
      child: TextButton(
        onPressed: () => context.goToLogin(),
        child: const Text(
          '¿Ya tienes cuenta? Iniciar sesión',
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
