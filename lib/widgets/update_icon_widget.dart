import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruta_placa/providers/rules_provider.dart';

class UpdateIconWidget extends ConsumerStatefulWidget {
  const UpdateIconWidget({super.key});

  @override
  ConsumerState<UpdateIconWidget> createState() =>
      _UpdateIconWidgetState();
}

class _UpdateIconWidgetState extends ConsumerState<UpdateIconWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rulesProvider);
    if (state.status == RulesStatus.downloading) {
      _controller.repeat();
    } else {
      _controller.stop();
    }

    return RotationTransition(
      turns: _controller,
      child: IconButton(
        onPressed: () {
          ref.read(rulesProvider.notifier).downloadUpdate();
        },
        icon: const Icon(Icons.sync),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
