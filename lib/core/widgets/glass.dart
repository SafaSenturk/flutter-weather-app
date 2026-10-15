import 'dart:ui';

import 'package:flutter/material.dart';

/// Frosted-glass panel used for every card on top of the animated sky.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.title,
    this.icon,
  });

  final Widget child;
  final EdgeInsets padding;
  final String? title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter.grouped(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .13),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: .18)),
          ),
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Row(
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 15, color: Colors.white.withValues(alpha: .65)),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          upperCase(context, title!),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .65),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Upper-cases with the Turkish dotted İ when the app runs in Turkish.
String upperCase(BuildContext context, String text) =>
    Localizations.localeOf(context).languageCode == 'tr'
        ? text.replaceAll('i', 'İ').toUpperCase()
        : text.toUpperCase();
