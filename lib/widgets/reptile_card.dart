import 'package:flutter/material.dart';
import 'package:login_rive_animation/models/reptile.dart';
import 'package:login_rive_animation/theme/app_theme.dart';

class ReptileCard extends StatelessWidget {
  const ReptileCard({super.key, required this.reptile, required this.today});

  final Reptile reptile;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final species = reptile.species;
    final age = reptile.ageLabel(today);
    final weight = reptile.weightGrams;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _Avatar(reptile: reptile),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reptile.name, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text(
                  species.commonName,
                  style: text.bodySmall?.copyWith(color: AppColors.muted),
                ),
                Text(
                  species.scientificName,
                  style: text.bodySmall?.copyWith(
                    color: AppColors.muted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (age != null) _Pill(age),
                    if (weight != null) _Pill('${weight.round()} g'),
                    _Pill('${species.minTemperature.round()}–${species.maxTemperature.round()} °C'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _FeedingBadge(daysLeft: reptile.daysUntilFeeding(today)),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.reptile});

  final Reptile reptile;

  @override
  Widget build(BuildContext context) {
    final fallback = Center(
      child: Text(
        reptile.name.characters.first.toUpperCase(),
        style: const TextStyle(
          color: AppColors.moss,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    final url = reptile.imageUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 64,
        height: 64,
        color: AppColors.sage,
        child: url == null
            ? fallback
            : Image.network(url, fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.sand,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.ink)),
    );
  }
}

class _FeedingBadge extends StatelessWidget {
  const _FeedingBadge({required this.daysLeft});

  final int daysLeft;

  @override
  Widget build(BuildContext context) {
    final hungry = daysLeft <= 0;
    final label = hungry ? 'Le toca\ncomer' : 'Come en\n$daysLeft d';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: hungry ? AppColors.amberSoft : AppColors.sage,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          height: 1.2,
          fontWeight: FontWeight.w600,
          color: hungry ? AppColors.amber : AppColors.moss,
        ),
      ),
    );
  }
}
