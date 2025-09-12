import 'package:flutter/material.dart';

class ToggleBox extends StatefulWidget {
  const ToggleBox({super.key});

  @override
  State<ToggleBox> createState() => _ToggleBoxState();
}

class _ToggleBoxState extends State<ToggleBox> {
  Color _color = Colors.red;

  void _toggleColor() {
    setState(() {
      _color = _color != Colors.lightBlue ? Colors.lightBlue : Colors.red;
    });
  }

  void _longPressColor() {
    setState(() {
      _color = Colors.purple;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleColor,
      onLongPress: _longPressColor,
      child: Container(
        width: 200,
        height: 200,
        color: _color,
        alignment: Alignment.center,
        child: const Text(
          "Clique ici !",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
