import 'package:flutter_test/flutter_test.dart';
import 'package:login_rive_animation/utils/auth_validators.dart';

void main() {
  group('isInstitutionalEmail', () {
    test('accepts the institutional domain, ignoring case and spaces', () {
      expect(isInstitutionalEmail('ariff@tecdesoftware.edu.mx'), isTrue);
      expect(isInstitutionalEmail('  Ariff@TecDeSoftware.edu.mx '), isTrue);
    });

    test('rejects other domains and look-alikes', () {
      for (final email in [
        'ariff@gmail.com',
        '@tecdesoftware.edu.mx',
        'ariff@tecdesoftware.edu.mx.evil.com',
        'ariff@nottecdesoftware.edu.mx',
        'a riff@tecdesoftware.edu.mx',
        'a@b@tecdesoftware.edu.mx',
        '',
      ]) {
        expect(isInstitutionalEmail(email), isFalse, reason: email);
      }
    });
  });

  group('isStrongPassword', () {
    test('accepts a password meeting every rule, from exactly 8 chars', () {
      expect(isStrongPassword('Gecko#2026'), isTrue);
      expect(isStrongPassword('Gecko#26'), isTrue);
    });

    test('rejects when any single rule is missing', () {
      for (final password in [
        'Geck#26', // 7 chars
        'gecko#2026', // no uppercase
        'GECKO#2026', // no lowercase
        'Gecko#abcd', // no digit
        'Gecko2026', // no symbol
      ]) {
        expect(isStrongPassword(password), isFalse, reason: password);
      }
    });
  });

  test('signUpErrorMessage maps known Firebase codes and falls back', () {
    expect(signUpErrorMessage('email-already-in-use'), 'Ese correo ya tiene una cuenta.');
    expect(signUpErrorMessage('weak-password'), 'La contraseña es demasiado débil.');
    expect(signUpErrorMessage('something-new'), 'No se pudo crear la cuenta. Inténtalo de nuevo.');
  });
}
