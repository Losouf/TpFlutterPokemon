import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../data/pokemon_item.dart';
import 'search_page/widgets/search_bar.dart';
import 'search_page/widgets/pagination_bar.dart';
import 'search_page/widgets/list.dart';
import 'search_page/widgets/detail_sheet.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  late final Dio _dio;

  List<PokemonItem> _all = [];
  List<PokemonItem> _filtered = [];
  bool _loading = true;
  String? _error;
  int _page = 0;
  static const int _pageSize = 25;

  @override
  void initState() {
    super.initState();
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://pokeapi.co/api/v2',
        // temps d'attente avant timeout
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Accept': 'application/json'},
      ),
    );
    _load();
    _searchCtrl.addListener(_filter);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _dio.get('/pokemon', queryParameters: {'limit': 2000});
      final results = (res.data['results'] as List)
          .map((e) => PokemonItem.fromJson(e as Map<String, dynamic>))
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

  void _filter() {
    final q = _searchCtrl.text.trim().toLowerCase();

    final next = q.isEmpty
        ? _all
        : _all
              .where(
                (p) => p.name.toLowerCase().contains(q) || p.id.toString() == q,
              )
              .toList();
    setState(() {
      _filtered = next;
      _page = 0;
    });
  }

  int get _totalPages =>
      _filtered.isEmpty ? 1 : ((_filtered.length - 1) ~/ _pageSize) + 1;

  List<PokemonItem> get _slice {
    final start = _page * _pageSize;
    final end = math.min(start + _pageSize, _filtered.length);
    if (start >= _filtered.length) return const [];
    return _filtered.sublist(start, end);
  }

  Future<void> _openDetail(PokemonItem item) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => DetailSheet(dio: _dio, item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 8),
            FilledButton(onPressed: _load, child: const Text('Réessayer')),
          ],
        ),
      );
    }

    return Column(
      children: [
        SearchBarWidget(controller: _searchCtrl),
        PaginationBar(
          totalResults: _filtered.length,
          currentPage: _page,
          totalPages: _totalPages,
          onPrev: _page > 0 ? () => setState(() => _page--) : null,
          onNext: (_page + 1) < _totalPages
              ? () => setState(() => _page++)
              : null,
        ),
        if (_filtered.isEmpty && !_loading)
          const Expanded(child: Center(child: Text("Aucun résultat")))
        else
          ListWidget(items: _slice, onRefresh: _load, onTapItem: _openDetail),
      ],
    );
  }
}
