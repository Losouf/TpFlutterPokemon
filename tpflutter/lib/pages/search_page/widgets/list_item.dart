import 'package:flutter/material.dart';
import '../../../data/pokemon_item.dart';

class ListItem extends StatelessWidget {
  final PokemonItem item;
  final VoidCallback onTapMore;

  const ListItem({super.key, required this.item, required this.onTapMore});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Image.network(
                item.spriteUrl,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              '#${item.id} ${item.name}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text('Pokémon'),
            trailing: FilledButton.tonal(
              onPressed: onTapMore,
              style: FilledButton.styleFrom(shape: const StadiumBorder()),
              child: const Text('Voir plus'),
            ),
          ),
        ),
      ),
    );
  }
}
