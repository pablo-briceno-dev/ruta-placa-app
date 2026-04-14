import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/providers/rules_provider.dart';
import 'package:ruta_placa/widgets/ad_banner_widget.dart';
import 'package:ruta_placa/widgets/error_screen_widget.dart';
import 'package:ruta_placa/widgets/loading_screen_widget.dart';

class InterceptorScreenWidget extends ConsumerWidget {
  final Widget child;
  final bool viewAds;

  const InterceptorScreenWidget({
    super.key,
    required this.child,
    this.viewAds = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rule = ref.watch(rulesInitProvider);

    return rule.when(
      data: (rules) => Column(
        children: [
          Expanded(child: child),
          if (viewAds) const AdBannerWidget(),
        ],
      ),
      error: (_, _) => const ErrorScreenWidget(),
      loading: () => const LoadingScreenWidget(),
    );
  }
}
