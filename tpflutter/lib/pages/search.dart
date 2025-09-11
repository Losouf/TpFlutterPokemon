import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  late final Dio _dio;

  List<_PokemonItem> _all = [];
  List<_PokemonItem> _filtered = [];
  bool _loading = true;
  String? _error;
  int _page = 0;
  static const int _pageSize = 50;

  @override
  void initState() {
    super.initState();
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://pokeapi.co/api/v2',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Accept': 'application/json'},
      ),
    );
    _loadIndex();
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_applyFilter);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadIndex() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _dio.get('/pokemon', queryParameters: {'limit': 2000});
      final results = (res.data['results'] as List)
          .map((e) => _PokemonItem.fromJson(e as Map<String, dynamic>))
          .toList();

      setState(() {
        _all = results;
        _filtered = results;
        _page = 0;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur réseau: $e';
        _loading = false;
      });
    }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = _all;
      } else {
        _filtered = _all.where((p) {
          final byName = p.name.contains(q);
          final byId = p.id.toString() == q;
          return byName || byId;
        }).toList();
      }
      _page = 0;
    });
  }

  int get _totalPages =>
      _filtered.isEmpty ? 1 : ((_filtered.length - 1) ~/ _pageSize) + 1;

  List<_PokemonItem> get _slice {
    final start = _page * _pageSize;
    final end = math.min(start + _pageSize, _filtered.length);
    if (start >= _filtered.length) return const [];
    return _filtered.sublist(start, end);
  }

  Future<void> _openDetail(_PokemonItem item) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => FutureBuilder<Response>(
        future: _dio.get('/pokemon/${item.id}'),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const SizedBox(
              height: 240,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snap.hasError || snap.data == null) {
            return SizedBox(
              height: 240,
              child: Center(child: Text('Erreur: ${snap.error}')),
            );
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
                  children: types
                      .map((t) => Chip(label: Text(_cap(t))))
                      .toList(),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 8),
            FilledButton(onPressed: _loadIndex, child: const Text('Réessayer')),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Rechercher un Pokémon (nom ou #id)',
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        // Pagination header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text('Résultats: ${_filtered.length}'),
              const Spacer(),
              IconButton(
                tooltip: 'Précédent',
                onPressed: _page > 0 ? () => setState(() => _page--) : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Text('Page ${_page + 1} / $_totalPages'),
              IconButton(
                tooltip: 'Suivant',
                onPressed: (_page + 1) < _totalPages
                    ? () => setState(() => _page++)
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        // Liste
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadIndex,
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: _slice.length,
              itemBuilder: (context, i) {
                final p = _slice[i];
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: Image.network(
                            p.spriteUrl,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          '#${p.id} ${_cap(p.name)}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: const Text('Pokémon'),
                        trailing: FilledButton.tonal(
                          onPressed: () => _openDetail(p),
                          style: FilledButton.styleFrom(
                            shape: const StadiumBorder(),
                          ),
                          child: const Text('Voir plus'),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  static String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _PokemonItem {
  final String name;
  final String url;

  _PokemonItem({required this.name, required this.url});

  factory _PokemonItem.fromJson(Map<String, dynamic> json) =>
      _PokemonItem(name: json['name'] as String, url: json['url'] as String);

  int get id {
    final parts = url.split('/');
    return int.tryParse(parts[parts.length - 2]) ?? 0;
  }

  String get spriteUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

  String get artworkUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
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
