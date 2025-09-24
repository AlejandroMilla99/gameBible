class Country {
  final String name;
  final String es_name;
  final String capital;
  final String capital_es;
  final String flag;
  final Map<String, int> rankings;

  Country({
    required this.name,
    required this.es_name,
    required this.capital,
    required this.capital_es,
    required this.flag,
    required this.rankings,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'],
      es_name: json['es_name'],
      flag: json['flag'],
      capital: json['capital'],
      capital_es: json['capital_es'],
      rankings: Map<String, int>.from(json['rankings']),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'es_name': es_name,
        'capital': capital,
        'capital_es': capital_es,
        'flag': flag,
        'rankings': rankings,
      };
}
