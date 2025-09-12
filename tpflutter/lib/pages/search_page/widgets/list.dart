import 'package:flutter/material.dart';
import '../../../data/pokemon_item.dart';
import 'list_item.dart';

class ListWidget extends StatelessWidget {
  final List<PokemonItem> items;
  final Future<void> Function() onRefresh;
  final void Function(PokemonItem) onTapItem;

  const ListWidget({
    super.key,
    required this.items,
    required this.onRefresh,
    required this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final p = items[i];
            return ListItem(item: p, onTapMore: () => onTapItem(p));
          },
        ),
      ),
    );
  }
}
