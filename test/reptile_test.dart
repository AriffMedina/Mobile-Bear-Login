import 'package:flutter_test/flutter_test.dart';
import 'package:login_rive_animation/models/reptile.dart';

Map<String, dynamic> speciesJson({int feedingIntervalDays = 2}) => {
      'speciesId': 2,
      'commonName': 'Pitón bola',
      'scientificName': 'Python regius',
      'feedingIntervalDays': feedingIntervalDays,
      'minTemperature': 24.0,
      'maxTemperature': 32,
      'minHumidity': 50,
      'maxHumidity': 60,
      'diet': 'Carnívoro',
    };

Reptile reptile({
  String? birthDate = '2024-03-15',
  String? lastFeeding = '2026-11-20',
  int feedingIntervalDays = 2,
}) =>
    Reptile.fromJson({
      'reptileId': 3,
      'name': 'Nala',
      'speciesId': 2,
      'sex': 'F',
      'birthDate': birthDate,
      'weightGrams': 1450,
      'lastFeeding': lastFeeding,
      'imageUrl': null,
      'notes': null,
      'active': true,
      'species': speciesJson(feedingIntervalDays: feedingIntervalDays),
    });

void main() {
  final today = DateTime(2026, 11, 23);

  group('Reptile.fromJson', () {
    test('parses nested species, accents and numeric types', () {
      final r = reptile();
      expect(r.species.commonName, 'Pitón bola');
      expect(r.species.maxTemperature, 32.0);
      expect(r.weightGrams, 1450.0);
      expect(r.birthDate, DateTime(2024, 3, 15));
    });

    test('accepts missing optional dates', () {
      final r = reptile(birthDate: null, lastFeeding: null);
      expect(r.birthDate, isNull);
      expect(r.lastFeeding, isNull);
    });
  });

  group('feeding', () {
    test('counts down days until the next meal', () {
      final r = reptile(lastFeeding: '2026-11-20', feedingIntervalDays: 7);
      expect(r.daysUntilFeeding(today), 4);
      expect(r.isHungry(today), isFalse);
    });

    test('is hungry exactly on the due day and after it', () {
      expect(reptile(lastFeeding: '2026-11-21').isHungry(today), isTrue);
      expect(reptile(lastFeeding: '2026-11-10').isHungry(today), isTrue);
    });

    test('is hungry when it was never fed on record', () {
      expect(reptile(lastFeeding: null).isHungry(today), isTrue);
    });
  });

  group('ageLabel', () {
    test('uses months under a year', () {
      expect(reptile(birthDate: '2026-03-23').ageLabel(today), '8 meses');
      expect(reptile(birthDate: '2026-10-23').ageLabel(today), '1 mes');
    });

    test('does not count a month that has not completed', () {
      expect(reptile(birthDate: '2026-03-24').ageLabel(today), '7 meses');
    });

    test('uses years from twelve months on', () {
      expect(reptile(birthDate: '2025-11-23').ageLabel(today), '1 año');
      expect(reptile(birthDate: '2024-03-15').ageLabel(today), '2 años');
    });

    test('is null without a birth date', () {
      expect(reptile(birthDate: null).ageLabel(today), isNull);
    });
  });
}
