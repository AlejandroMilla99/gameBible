class Country {
  final String name;
  final String flag; // Emoji o URL de bandera
  final Map<String, int> rankings;

  Country({
    required this.name,
    required this.flag,
    required this.rankings,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'],
      flag: json['flag'],
      rankings: Map<String, int>.from(json['rankings']),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'flag': flag,
        'rankings': rankings,
      };
}
