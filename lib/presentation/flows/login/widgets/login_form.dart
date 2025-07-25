import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chat/presentation/core/base_hook_widget.dart';
import 'package:chat/presentation/shared/widgets/custom_text_field.dart';
import 'package:chat/presentation/shared/widgets/primary_button.dart';
import 'package:chat/presentation/flows/login/providers/login_provider.dart';
import 'package:chat/presentation/flows/login/states/action.dart';

/// Formulario de login.
///
/// Widget enfocado que maneja la captura de datos del usuario
/// y se conecta con el notifier para procesar las acciones.
class LoginForm extends BaseHookWidget {
  const LoginForm({super.key});

  @override
  Widget buildView(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final state = ref.loginState;

    // Sincronizar controladores con el estado
    useEffect(() {
      emailController.text = state.email;
      passwordController.text = state.password;
      return null;
    }, [state.email, state.password]);

    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          CustomTextField(
            controller: emailController,
            prefixIcon: Icons.mail_outline,
            hintText: 'Correo',
            keyboardType: TextInputType.emailAddress,
            errorText: !state.isEmailValid ? 'Email inválido' : null,
            onChanged: (value) {
              ref.executeLoginAction(UpdateEmail(value));
            },
          ),
          CustomTextField(
            controller: passwordController,
            prefixIcon: Icons.lock_outline,
            hintText: 'Contraseña',
            isPassword: true,
            errorText: !state.isPasswordValid ? 'Mínimo 6 caracteres' : null,
            onChanged: (value) {
              ref.executeLoginAction(UpdatePassword(value));
            },
          ),

          // Botón de login
          PrimaryButton(
            label: 'Ingresar',
            enabled: state.canSubmit,
            isLoading: state.isLoading,
            onPressed: () => ref.executeLoginAction(const SubmitLogin()),
          ),
        ],
      ),
    );
  }
}
