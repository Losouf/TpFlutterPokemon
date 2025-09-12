import 'package:flutter/material.dart';

import 'home_page/widgets/toggle_box.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(children: [Text('Bienvenue'), ToggleBox()]),
    );
  }
}
