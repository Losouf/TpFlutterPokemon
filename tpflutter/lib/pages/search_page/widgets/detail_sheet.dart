import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../data/pokemon_item.dart';

class DetailSheet extends StatelessWidget {
  final Dio dio;
  final PokemonItem item;

  const DetailSheet({super.key, required this.dio, required this.item});

  static String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Response>(
      future: dio.get('/pokemon/${item.id}'),
      builder: (context, snap) {
        if (snap.hasError) {
          return SizedBox(
            height: 240,
            child: Center(child: Text('Erreur: ${snap.error}')),
          );
        }

        if (!snap.hasData) {
          return const SizedBox(height: 0);
        }

        final data = snap.data!.data as Map<String, dynamic>;
        final name = data['name'] as String;
        final id = data['id'] as int;
        final types = (data['types'] as List)
            .map((t) => t['type']['name'] as String)
            .toList();
        final heightM = (data['height'] as int) / 10.0;
        final weightKg = (data['weight'] as int) / 10.0;
        final sprite =
            data['sprites']?['other']?['official-artwork']?['front_default'] ??
            data['sprites']?['front_default'] ??
            item.artworkUrl;

        return Padding(
          padding: MediaQuery.of(
            context,
          ).viewInsets.add(const EdgeInsets.all(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(sprite, width: 140, height: 140),
              const SizedBox(height: 8),
              Text(
                '#$id ${_cap(name)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: types.map((t) => Chip(label: Text(_cap(t)))).toList(),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Info(
                    label: 'Taille',
                    value: '${heightM.toStringAsFixed(1)} m',
                  ),
                  const SizedBox(width: 16),
                  _Info(
                    label: 'Poids',
                    value: '${weightKg.toStringAsFixed(1)} kg',
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _Info extends StatelessWidget {
  final String label;
  final String value;
  const _Info({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(value),
      ],
    );
  }
}
