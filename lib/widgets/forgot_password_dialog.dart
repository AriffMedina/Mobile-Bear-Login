import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> showForgotPasswordDialog(BuildContext context, {String initialEmail = ''}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ForgotPasswordDialog(initialEmail: initialEmail),
  );
}

class _ForgotPasswordDialog extends StatefulWidget {
  const _ForgotPasswordDialog({required this.initialEmail});

  final String initialEmail;

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  late final _emailCtrl = TextEditingController(text: widget.initialEmail);
  bool _sending = false;
  String? _error;

  Future<void> _send() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Ingresa tu correo.');
      return;
    }

    setState(() {
      _sending = true;
      _error = null;
    });
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      debugPrint('Password reset error: ${e.code}');
      // Only input/network problems are surfaced. Anything about the account
      // itself falls through to the neutral message so it can't be enumerated.
      final message = switch (e.code) {
        'invalid-email' => 'El correo no es válido.',
        'network-request-failed' => 'Sin conexión. Revisa tu internet.',
        _ => null,
      };
      if (message != null) {
        if (!mounted) return;
        setState(() {
          _sending = false;
          _error = message;
        });
        return;
      }
    }
    navigator.pop();
    messenger.showSnackBar(const SnackBar(
      content: Text('Si el correo está registrado, te enviamos un enlace para restablecer tu contraseña.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Recuperar contraseña'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Te enviaremos un enlace para crear una nueva contraseña.'),
          const SizedBox(height: 16),
          TextField(
            controller: _emailCtrl,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            onSubmitted: (_) => _sending ? null : _send(),
            decoration: InputDecoration(
              hintText: 'Correo',
              prefixIcon: const Icon(Icons.alternate_email_rounded),
              errorText: _error,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _sending ? null : _send,
          style: FilledButton.styleFrom(minimumSize: const Size(110, 44)),
          child: _sending
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Enviar'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }
}
