import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerList extends StatelessWidget {
  final int count;
  final double height;
  const ShimmerList({super.key, this.count = 3, this.height = 120});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: cs.surfaceVariant,
      highlightColor: cs.surface,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => Container(
          height: height,
          decoration: BoxDecoration(
            color: cs.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
