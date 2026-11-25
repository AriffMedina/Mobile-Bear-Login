class Species {
  final int id;
  final String commonName;
  final String scientificName;
  final int feedingIntervalDays;
  final double minTemperature;
  final double maxTemperature;
  final int minHumidity;
  final int maxHumidity;
  final String diet;

  const Species({
    required this.id,
    required this.commonName,
    required this.scientificName,
    required this.feedingIntervalDays,
    required this.minTemperature,
    required this.maxTemperature,
    required this.minHumidity,
    required this.maxHumidity,
    required this.diet,
  });

  factory Species.fromJson(Map<String, dynamic> json) => Species(
        id: json['speciesId'] as int,
        commonName: json['commonName'] as String,
        scientificName: json['scientificName'] as String,
        feedingIntervalDays: json['feedingIntervalDays'] as int,
        minTemperature: (json['minTemperature'] as num).toDouble(),
        maxTemperature: (json['maxTemperature'] as num).toDouble(),
        minHumidity: json['minHumidity'] as int,
        maxHumidity: json['maxHumidity'] as int,
        diet: json['diet'] as String,
      );
}

class Reptile {
  final int id;
  final String name;
  final Species species;
  final String? sex;
  final DateTime? birthDate;
  final double? weightGrams;
  final DateTime? lastFeeding;
  final String? imageUrl;
  final String? notes;

  const Reptile({
    required this.id,
    required this.name,
    required this.species,
    this.sex,
    this.birthDate,
    this.weightGrams,
    this.lastFeeding,
    this.imageUrl,
    this.notes,
  });

  factory Reptile.fromJson(Map<String, dynamic> json) => Reptile(
        id: json['reptileId'] as int,
        name: json['name'] as String,
        species: Species.fromJson(json['species'] as Map<String, dynamic>),
        sex: json['sex'] as String?,
        birthDate: _date(json['birthDate']),
        weightGrams: (json['weightGrams'] as num?)?.toDouble(),
        lastFeeding: _date(json['lastFeeding']),
        imageUrl: json['imageUrl'] as String?,
        notes: json['notes'] as String?,
      );

  static DateTime? _date(Object? value) =>
      value == null ? null : DateTime.parse(value as String);

  /// Days left until the next meal; zero or negative means it is due.
  /// `today` is injected so the rule stays testable.
  int daysUntilFeeding(DateTime today) {
    final last = lastFeeding;
    // Never fed on record: treat as due so it gets attention.
    if (last == null) return 0;
    return species.feedingIntervalDays - today.difference(last).inDays;
  }

  bool isHungry(DateTime today) => daysUntilFeeding(today) <= 0;

  /// Human age such as "8 meses" or "2 años"; null when birth date is unknown.
  String? ageLabel(DateTime today) {
    final birth = birthDate;
    if (birth == null) return null;
    var months = (today.year - birth.year) * 12 + today.month - birth.month;
    if (today.day < birth.day) months--;
    if (months < 12) return months == 1 ? '1 mes' : '$months meses';
    final years = months ~/ 12;
    return years == 1 ? '1 año' : '$years años';
  }
}
