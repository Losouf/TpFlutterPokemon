class PokemonItem {
  final String name;
  final String url;

  PokemonItem({required this.name, required this.url});

  factory PokemonItem.fromJson(Map<String, dynamic> json) =>
      PokemonItem(name: json['name'] as String, url: json['url'] as String);

  int get id {
    final parts = url.split('/');
    return int.tryParse(parts[parts.length - 2]) ?? 0;
  }

  String get spriteUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

  String get artworkUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
}
