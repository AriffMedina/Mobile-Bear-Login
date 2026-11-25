/// Sign-up rules. Only the registration screen shows field-level errors;
/// the login screen stays generic (OWASP account enumeration).
const institutionalDomain = 'tecdesoftware.edu.mx';

final _institutionalEmail = RegExp(r'^[^\s@]+@tecdesoftware\.edu\.mx$');

bool isInstitutionalEmail(String email) =>
    _institutionalEmail.hasMatch(email.trim().toLowerCase());

class PasswordRule {
  const PasswordRule(this.label, this.isMet);

  final String label;
  final bool Function(String password) isMet;
}

final passwordRules = <PasswordRule>[
  PasswordRule('Mínimo 8 caracteres', (p) => p.length >= 8),
  PasswordRule('Una mayúscula', (p) => p.contains(RegExp('[A-Z]'))),
  PasswordRule('Una minúscula', (p) => p.contains(RegExp('[a-z]'))),
  PasswordRule('Un número', (p) => p.contains(RegExp(r'\d'))),
  PasswordRule('Un símbolo', (p) => p.contains(RegExp(r'[^A-Za-z0-9]'))),
];

bool isStrongPassword(String password) =>
    passwordRules.every((rule) => rule.isMet(password));

/// Specific messages are allowed at sign-up, where the user owns the email.
String signUpErrorMessage(String firebaseCode) => switch (firebaseCode) {
      'email-already-in-use' => 'Ese correo ya tiene una cuenta.',
      'weak-password' => 'La contraseña es demasiado débil.',
      'invalid-email' => 'El correo no es válido.',
      'network-request-failed' => 'Sin conexión. Revisa tu internet.',
      _ => 'No se pudo crear la cuenta. Inténtalo de nuevo.',
    };
