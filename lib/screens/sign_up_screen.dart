import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_rive_animation/theme/app_theme.dart';
import 'package:login_rive_animation/utils/auth_validators.dart';
import 'package:login_rive_animation/widgets/status_view.dart';
import 'package:lottie/lottie.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  // Field errors appear only after the first attempt, not while typing.
  bool _submitted = false;

  Future<void> _signUp() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    setState(() => _submitted = true);
    if (!isInstitutionalEmail(email) || !isStrongPassword(pass) || pass != _confirmCtrl.text) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: pass);
      // Firebase signs the new user in; sign out so they log in from the login screen.
      await FirebaseAuth.instance.signOut();
      messenger.showSnackBar(
        const SnackBar(content: Text('Cuenta creada. Ya puedes iniciar sesión.')),
      );
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign-up error: ${e.code}');
      if (!mounted) return;
      setState(() => _isLoading = false);
      messenger.showSnackBar(SnackBar(content: Text(signUpErrorMessage(e.code))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final pass = _passCtrl.text;
    final emailError = _submitted && !isInstitutionalEmail(_emailCtrl.text)
        ? 'Usa tu correo @$institutionalDomain'
        : null;
    final confirmError = _submitted && _confirmCtrl.text != pass
        ? 'Las contraseñas no coinciden'
        : null;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Lottie.asset(ReptileAnimations.hero, height: 120)),
              Text('Únete al herpetario',
                  style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Crea tu cuenta con tu correo institucional.',
                  style: text.bodyMedium?.copyWith(color: AppColors.muted)),
              const SizedBox(height: 24),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'tu.nombre@$institutionalDomain',
                  prefixIcon: const Icon(Icons.alternate_email_rounded),
                  errorText: emailError,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
              ),
              _PasswordRules(password: pass),
              TextField(
                controller: _confirmCtrl,
                obscureText: _obscure,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Confirmar contraseña',
                  prefixIcon: const Icon(Icons.lock_reset_rounded),
                  errorText: confirmError,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading ? null : _signUp,
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                child: _isLoading
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text('Crear cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }
}

/// Live checklist so the user sees every rule before submitting.
class _PasswordRules extends StatelessWidget {
  const _PasswordRules({required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 14),
      child: Wrap(
        spacing: 14,
        runSpacing: 8,
        children: [
          for (final rule in passwordRules)
            _RuleItem(label: rule.label, met: rule.isMet(password)),
        ],
      ),
    );
  }
}

class _RuleItem extends StatelessWidget {
  const _RuleItem({required this.label, required this.met});

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final color = met ? AppColors.moss : AppColors.muted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(met ? Icons.check_circle_rounded : Icons.circle_outlined, size: 16, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12.5, color: color)),
      ],
    );
  }
}
