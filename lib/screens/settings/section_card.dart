import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  final List<Widget> children;

  const SectionCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Column(children: children),
  );
}
