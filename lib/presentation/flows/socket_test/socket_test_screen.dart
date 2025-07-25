import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat/infrastructure/providers/datasources/socket_test_provider.dart';

/// Pantalla de prueba para la conexión Socket.IO.
///
/// Demuestra la conectividad con el backend y las funcionalidades básicas.
class SocketTestScreen extends ConsumerWidget {
  const SocketTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(socketTestProvider);
    final notifier = ref.read(socketTestProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Socket.IO Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(state.isConnected ? Icons.wifi : Icons.wifi_off),
            onPressed: null,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Estado de conexión
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado de Conexión',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          state.isConnected ? Icons.check_circle : Icons.error,
                          color: state.isConnected ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          state.isConnected ? 'Conectado' : 'Desconectado',
                          style: TextStyle(
                            color: state.isConnected ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (state.isAuthenticated) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text('Autenticado como: ${state.currentUser?.name}'),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: state.isLoading ? null : notifier.connectAndAuthenticate,
                    icon: state.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.wifi),
                    label: Text(state.isLoading ? 'Conectando...' : 'Conectar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: state.isConnected ? notifier.disconnect : null,
                    icon: const Icon(Icons.wifi_off),
                    label: const Text('Desconectar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Botón de mensaje de prueba
            ElevatedButton.icon(
              onPressed: state.isAuthenticated ? notifier.sendTestMessage : null,
              icon: const Icon(Icons.send),
              label: const Text('Enviar Mensaje de Prueba'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // Usuarios online
            if (state.onlineUsers.isNotEmpty) ...[
              Text(
                'Usuarios Online (${state.onlineUsers.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.onlineUsers.length,
                  itemBuilder: (context, index) {
                    final user = state.onlineUsers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Text(user.name[0].toUpperCase()),
                      ),
                      title: Text(user.name),
                      subtitle: Text(user.email),
                      trailing: const Icon(Icons.circle, color: Colors.green, size: 12),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Mensajes
            if (state.messages.isNotEmpty) ...[
              Text(
                'Mensajes (${state.messages.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Card(
                  child: ListView.builder(
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      return ListTile(
                        leading: const Icon(Icons.message),
                        title: Text(message.toString()),
                        subtitle: Text(DateTime.now().toString()),
                      );
                    },
                  ),
                ),
              ),
            ],

            if (state.messages.isEmpty && state.isAuthenticated)
              Expanded(
                child: Card(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.message_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No hay mensajes aún',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Presiona "Enviar Mensaje de Prueba" para probar',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 