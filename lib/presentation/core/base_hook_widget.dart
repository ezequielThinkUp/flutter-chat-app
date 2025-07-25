import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Widget base para todos los widgets de la capa presentation.
/// 
/// Implementa [HookConsumerWidget] de forma uniforme y proporciona
/// un método [buildView] que debe ser implementado por las clases hijas.
/// 
/// Uso:
/// ```dart
/// class MyWidget extends BaseHookWidget {
///   @override
///   Widget buildView(BuildContext context, WidgetRef ref) {
///     return Container();
///   }
/// }
/// ```
abstract class BaseHookWidget extends HookConsumerWidget {
  const BaseHookWidget({
    super.key,
  });

  /// Método que debe ser implementado por las clases hijas.
  /// 
  /// Este método reemplaza al [build] tradicional y proporciona
  /// acceso tanto al [BuildContext] como al [WidgetRef].
  Widget buildView(BuildContext context, WidgetRef ref);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return buildView(context, ref);
  }
} 