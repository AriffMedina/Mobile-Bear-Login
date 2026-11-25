import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_rive_animation/models/reptile.dart';
import 'package:login_rive_animation/screens/login_screen.dart';
import 'package:login_rive_animation/services/herpetario_api.dart';
import 'package:login_rive_animation/theme/app_theme.dart';
import 'package:login_rive_animation/widgets/reptile_card.dart';
import 'package:login_rive_animation/widgets/status_view.dart';
import 'package:lottie/lottie.dart';

class ReptilesScreen extends StatefulWidget {
  const ReptilesScreen({super.key});

  @override
  State<ReptilesScreen> createState() => _ReptilesScreenState();
}

class _ReptilesScreenState extends State<ReptilesScreen> {
  late Future<List<Reptile>> _reptiles = HerpetarioApi.fetchReptiles();
  String _query = '';
  int? _speciesId;

  Future<void> _reload() {
    final next = HerpetarioApi.fetchReptiles();
    setState(() => _reptiles = next);
    return next;
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  List<Reptile> _filter(List<Reptile> all) {
    final q = _query.trim().toLowerCase();
    return all.where((r) {
      final matchesSpecies = _speciesId == null || r.species.id == _speciesId;
      final haystack = '${r.name} ${r.species.commonName}'.toLowerCase();
      return matchesSpecies && haystack.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi herpetario', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<Reptile>>(
        future: _reptiles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const StatusView(
              animation: ReptileAnimations.loading,
              title: 'Buscando a tus reptiles…',
            );
          }
          if (snapshot.hasError) {
            debugPrint('Reptiles request failed: ${snapshot.error}');
            return StatusView(
              animation: ReptileAnimations.error,
              title: 'Servidor no disponible',
              message: 'No pudimos conectar con el herpetario.\nRevisa tu conexión e inténtalo de nuevo.',
              actionLabel: 'Reintentar',
              onAction: _reload,
            );
          }
          return _content(snapshot.data ?? const []);
        },
      ),
    );
  }

  Widget _content(List<Reptile> all) {
    final today = DateUtils.dateOnly(DateTime.now());
    final species = {for (final r in all) r.species.id: r.species}.values.toList()
      ..sort((a, b) => a.commonName.compareTo(b.commonName));
    final visible = _filter(all);
    final hungry = all.where((r) => r.isHungry(today)).length;

    return RefreshIndicator(
      onRefresh: _reload,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _summary(all.length, hungry)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: 'Buscar por nombre o especie',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: _speciesChips(species)),
          if (visible.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: StatusView(
                animation: ReptileAnimations.empty,
                title: 'Nada por aquí',
                message: 'Ningún reptil coincide con tu búsqueda.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              sliver: SliverList.separated(
                itemCount: visible.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) => ReptileCard(reptile: visible[i], today: today),
              ),
            ),
        ],
      ),
    );
  }

  Widget _summary(int total, int hungry) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$total reptiles', style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  hungry == 0 ? 'Todos están alimentados' : '$hungry esperan su comida hoy',
                  style: text.bodyMedium?.copyWith(
                    color: hungry == 0 ? AppColors.muted : AppColors.amber,
                  ),
                ),
              ],
            ),
          ),
          Lottie.asset(ReptileAnimations.hero, width: 88, height: 88),
        ],
      ),
    );
  }

  Widget _speciesChips(List<Species> species) {
    Widget chip(String label, int? id) {
      final selected = _speciesId == id;
      return ChoiceChip(
        label: Text(label),
        selected: selected,
        labelStyle: TextStyle(color: selected ? Colors.white : AppColors.ink),
        onSelected: (_) => setState(() => _speciesId = id),
      );
    }

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          chip('Todas', null),
          for (final s in species) ...[const SizedBox(width: 8), chip(s.commonName, s.id)],
        ],
      ),
    );
  }
}
