import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/providers/rules_provider.dart';
import 'package:ruta_placa/widgets/error_screen_widget.dart';
import 'package:ruta_placa/widgets/loading_screen_widget.dart';

class InterceptorScreenWidget extends ConsumerWidget {
  final Widget child;

  const InterceptorScreenWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rule = ref.watch(rulesInitProvider);

    return rule.when(
      data: (rules) => child,
      error: (_, _) => const ErrorScreenWidget(),
      loading: () => const LoadingScreenWidget(),
    );
  }
}
