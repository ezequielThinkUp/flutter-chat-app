import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chat/routes/app_router.dart';
import 'package:chat/infrastructure/providers/repositories/auth_repository_provider.dart';

void main() {
  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Inicializar autenticación al arrancar la app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authRepository = ref.read(authRepositoryProvider);
      authRepository.initializeAuth();
    });

    return MaterialApp.router(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'System',
      ),
      routerConfig: appRouter,
    );
  }
}
