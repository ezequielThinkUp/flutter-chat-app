import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:chat/presentation/base/base_stateful_widget.dart';
import 'package:chat/presentation/base/content_state/content_state_widget.dart';
import 'package:chat/presentation/flows/users/providers/users_provider.dart';
import 'package:chat/presentation/flows/users/models/action.dart';
import 'package:chat/presentation/flows/users/widgets/user_list_item.dart';
import 'package:chat/routes/app_router.dart';

/// Pantalla de usuarios conectados.
class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends BaseStatefulWidget<UsersScreen> {
  @override
  Widget buildView(BuildContext context) {
    final state = ref.usersState;

    // Escuchar cambios de estado para navegación después del logout
    // Usar Future.microtask para evitar modificar provider durante build
    ref.listen(usersProvider.provider, (previous, next) {
      print('🔄 Estado cambió: ${previous?.message} → ${next.message}');

      if ((next.message ?? '') == 'Sesión cerrada exitosamente' &&
          (previous?.message ?? '') != (next.message ?? '')) {
        print('🚪 Programando navegación al login tras logout exitoso');

        // Usar Future.microtask para ejecutar después del build cycle
        Future.microtask(() {
          if (mounted) {
            print('📱 Ejecutando navegación al login');

            // Navegar y limpiar stack completo
            try {
              context.goToLogin();
              print('✅ Navegación al login exitosa');
            } catch (e) {
              print('❌ Error en navegación: $e');
              // Fallback: usar pushReplacement
              context.replaceWithLogin();
            }
          } else {
            print('⚠️ Widget no montado, navegación cancelada');
          }
        });
      }

      // Manejar errores de logout
      if ((next.message ?? '').startsWith('Error al cerrar sesión') &&
          (previous?.message ?? '') != (next.message ?? '')) {
        print('❌ Error detectado en logout: ${next.message}');

        // Mostrar dialog de error si es necesario
        Future.microtask(() {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(next.message ?? 'Error desconocido'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xffF2F2F2),
      appBar: AppBar(
        title: const Text(
          'Usuarios Conectados',
          style: TextStyle(color: Colors.black54),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onPressed: () => _showUserMenu(context),
          ),
        ],
      ),
      body: ContentStateWidget(
        isLoading: state.isLoading,
        errorMessage:
            state.message?.contains('Error') == true ? state.message : null,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.executeUsersAction(const RefreshUsers());
          },
          child: state.users.isEmpty
              ? const Center(
                  child: Text(
                    'No hay usuarios conectados',
                    style: TextStyle(color: Colors.black54),
                  ),
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: state.users.length,
                  itemBuilder: (context, index) {
                    final user = state.users[index];
                    return UserListItem(
                      user: user,
                      onTap: () {
                        // Navegar al chat con este usuario
                        context.goToChat(
                          recipientUserId: user.id,
                          recipientUserName: user.name,
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }

  @override
  void onInitState() {
    super.onInitState();
    // Cargar usuarios al inicializar usando PostFrameCallback para evitar
    // modificar el provider durante la construcción del widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.executeUsersAction(const LoadUsers());
      }
    });
  }

  void _showUserMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () {
                Navigator.of(context).pop();
                print('🚪 Iniciando proceso de logout');
                ref.executeUsersAction(const Logout());
              },
            ),
          ],
        ),
      ),
    );
  }
}
