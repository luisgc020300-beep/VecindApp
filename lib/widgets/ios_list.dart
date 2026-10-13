// lib/widgets/ios_list.dart
//
// Lista agrupada estilo iOS: cabecera opcional en mayúsculas + una única
// tarjeta redondeada con las filas separadas por un divisor fino, icono en
// una insignia de color, chevron a la derecha solo cuando la fila navega a
// otro sitio. Mismo patrón que Repara.
import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

class IosSection extends StatelessWidget {
  const IosSection({this.header, this.footer, required this.rows, super.key});

  final String? header;
  final String? footer;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 6),
              child: Text(
                header!.toUpperCase(),
                style: TextStyle(fontSize: 12, letterSpacing: 0.6, fontWeight: FontWeight.w700, color: context.colors.inkMuted),
              ),
            ),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0) Divider(height: 1, indent: 56, color: context.colors.inkMuted.withValues(alpha: 0.14)),
                  rows[i],
                ],
              ],
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.only(left: 6, top: 6),
              child: Text(footer!, style: TextStyle(fontSize: 12.5, color: context.colors.inkMuted)),
            ),
        ],
      ),
    );
  }
}

class IosValueRow extends StatelessWidget {
  const IosValueRow({required this.label, required this.value, this.onTap, super.key});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            children: [
              Text(label, style: TextStyle(fontSize: 15, color: context.colors.ink)),
              Expanded(child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontSize: 15, color: context.colors.inkMuted))),
            ],
          ),
        ),
      ),
    );
  }
}

class IosRow extends StatelessWidget {
  const IosRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
    this.showChevron = true,
    super.key,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 29,
                height: 29,
                decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(7)),
                child: Icon(icon, color: Colors.white, size: 17),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 15.5, color: titleColor ?? context.colors.ink), maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: TextStyle(fontSize: 12, color: context.colors.inkMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (trailing != null)
                trailing!
              else if (onTap != null && showChevron)
                Icon(Icons.chevron_right, color: context.colors.inkMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
