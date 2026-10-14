import 'package:flutter/material.dart';

import '../../features/ai/model/ai_model.dart';
import '../theme.dart';

/// The model's maker logo, or a branded sparkle when it has none.
class ModelAvatar extends StatelessWidget {
  const ModelAvatar({
    super.key,
    required this.model,
    required this.size,
    this.radius = 10,
    this.circle = false,
  });

  final AIModel model;
  final double size;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final image = model.image;
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).jColors.card,
        gradient: image == null ? JemenaiTheme.gradBrand : null,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(radius),
        boxShadow:
            circle
                ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child:
          image != null
              ? image.image(width: size, height: size, fit: BoxFit.cover)
              : Icon(Icons.auto_awesome, color: Colors.white, size: size * 0.5),
    );
  }
}
