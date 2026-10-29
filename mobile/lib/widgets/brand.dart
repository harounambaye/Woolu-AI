import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.light = false});
  final bool light;

  @override
  Widget build(BuildContext context) {
    final fg = light ? Colors.white : AppColors.ink;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: light ? Colors.white : AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(PhosphorIconsFill.shieldCheck, size: 22, color: light ? AppColors.primary : Colors.white),
      ),
      const SizedBox(width: 10),
      Text.rich(
        TextSpan(children: [
          const TextSpan(text: 'Woolu'),
          TextSpan(text: ' AI', style: TextStyle(color: light ? AppColors.accent : AppColors.primary)),
        ]),
        style: TextStyle(color: fg, fontSize: 21, fontWeight: FontWeight.w800, letterSpacing: -0.3),
      ),
    ]);
  }
}
