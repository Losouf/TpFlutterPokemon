import 'package:flutter/material.dart';

class PaginationBar extends StatelessWidget {
  final int totalResults;
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const PaginationBar({
    super.key,
    required this.totalResults,
    required this.currentPage,
    required this.totalPages,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text('Résultats: $totalResults'),
          const Spacer(),
          IconButton(
            tooltip: 'Précédent',
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left),
          ),
          Text('Page ${currentPage + 1} / $totalPages'),
          IconButton(
            tooltip: 'Suivant',
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
