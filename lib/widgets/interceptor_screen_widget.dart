import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/widgets/ad_banner_widget.dart';

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
    return Column(
      children: [
        Expanded(child: child),
        if (viewAds) const AdBannerWidget(),
      ],
    );
  }
}
