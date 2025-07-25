import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chat/presentation/core/base_hook_widget.dart';
import 'package:chat/presentation/shared/widgets/primary_button.dart';
import 'package:chat/presentation/shared/widgets/custom_text_field.dart';
import 'package:chat/presentation/shared/widgets/loading_indicator.dart';

/// Ejemplo de uso de widgets de presentation siguiendo las reglas establecidas.
///
/// Este widget demuestra cómo componer múltiples widgets pequeños
/// para crear una interfaz compleja pero mantenible.
class ExampleUsagePage extends BaseHookWidget {
  const ExampleUsagePage({super.key});

  @override
  Widget buildView(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejemplo de Widgets Presentation'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _HeaderSection(),
            SizedBox(height: 20),
            _FormSection(),
            SizedBox(height: 20),
            _LoadingSection(),
            SizedBox(height: 20),
            _ButtonsSection(),
          ],
        ),
      ),
    );
  }
}

/// Widget pequeño y enfocado para el header.
/// Sigue la regla de "widgets pequeños y enfocados".
class _HeaderSection extends BaseHookWidget {
  const _HeaderSection();

  @override
  Widget buildView(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.widgets,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              'Widgets de Presentation',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Componentes reutilizables y desacoplados',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget enfocado en mostrar un formulario usando CustomTextField.
class _FormSection extends BaseHookWidget {
  const _FormSection();

  @override
  Widget buildView(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Campos de Texto',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            const CustomTextField(
              hintText: 'Ingresa tu email',
              labelText: 'Email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const CustomTextField(
              hintText: 'Ingresa tu contraseña',
              labelText: 'Contraseña',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget enfocado en mostrar indicadores de carga.
class _LoadingSection extends BaseHookWidget {
  const _LoadingSection();

  @override
  Widget buildView(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Indicadores de Carga',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                LoadingIndicator(size: 30),
                LoadingIndicator(
                  message: 'Cargando...',
                  size: 30,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget enfocado en mostrar diferentes variantes de botones.
class _ButtonsSection extends BaseHookWidget {
  const _ButtonsSection();

  @override
  Widget buildView(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Botones',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Botón Primario',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Botón presionado!')),
                );
              },
            ),
            const SizedBox(height: 12),
            const PrimaryButton(
              label: 'Botón Cargando',
              isLoading: true,
            ),
            const SizedBox(height: 12),
            const PrimaryButton(
              label: 'Botón Deshabilitado',
              enabled: false,
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Botón Personalizado',
              backgroundColor: Colors.green,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
