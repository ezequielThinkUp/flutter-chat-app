import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chat/presentation/core/base_hook_widget.dart';
import 'package:chat/presentation/shared/widgets/custom_text_field.dart';
import 'package:chat/presentation/shared/widgets/primary_button.dart';
import 'package:chat/presentation/flows/register/providers/register_provider.dart';
import 'package:chat/presentation/flows/register/states/action.dart';

/// Formulario de registro.
class RegisterForm extends BaseHookWidget {
  const RegisterForm({super.key});

  @override
  Widget buildView(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final state = ref.registerState;

    // Sincronizar controladores con el estado
    useEffect(() {
      nameController.text = state.name;
      emailController.text = state.email;
      passwordController.text = state.password;
      confirmPasswordController.text = state.confirmPassword;
      return null;
    }, [state.name, state.email, state.password, state.confirmPassword]);

    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          CustomTextField(
            controller: nameController,
            prefixIcon: Icons.person_outline,
            hintText: 'Nombre',
            keyboardType: TextInputType.name,
            errorText: !state.isNameValid ? 'Mínimo 2 caracteres' : null,
            onChanged: (value) {
              ref.executeRegisterAction(UpdateName(value));
            },
          ),
          CustomTextField(
            controller: emailController,
            prefixIcon: Icons.mail_outline,
            hintText: 'Correo',
            keyboardType: TextInputType.emailAddress,
            errorText: !state.isEmailValid ? 'Email inválido' : null,
            onChanged: (value) {
              ref.executeRegisterAction(UpdateEmail(value));
            },
          ),
          CustomTextField(
            controller: passwordController,
            prefixIcon: Icons.lock_outline,
            hintText: 'Contraseña',
            isPassword: true,
            errorText: !state.isPasswordValid ? 'Mínimo 6 caracteres' : null,
            onChanged: (value) {
              ref.executeRegisterAction(UpdatePassword(value));
            },
          ),
          CustomTextField(
            controller: confirmPasswordController,
            prefixIcon: Icons.lock_outline,
            hintText: 'Confirmar contraseña',
            isPassword: true,
            errorText:
                !state.passwordsMatch ? 'Las contraseñas no coinciden' : null,
            onChanged: (value) {
              ref.executeRegisterAction(UpdateConfirmPassword(value));
            },
          ),

          // Botón de registro
          PrimaryButton(
            label: 'Registrarse',
            enabled: state.canSubmit,
            isLoading: state.isLoading,
            onPressed: () => ref.executeRegisterAction(const SubmitRegister()),
          ),
        ],
      ),
    );
  }
}
