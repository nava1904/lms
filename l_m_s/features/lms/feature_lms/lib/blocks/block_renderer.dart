// filepath: /Users/navadeepreddy/learning mangement system/l_m_s/features/lms/feature_lms/lib/blocks/block_renderer.dart

import 'package:flutter/material.dart';
import 'block_base.dart';

/// Renders a list of content blocks
class BlockRenderer extends StatelessWidget {
  final List<Map<String, dynamic>> blocks;
  final EdgeInsets padding;
  final double spacing;

  const BlockRenderer({
    super.key,
    required this.blocks,
    this.padding = const EdgeInsets.all(16),
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) {
      return const Center(child: Text('No content available'));
    }

    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: blocks.map((blockData) {
          final block = ContentBlock.fromJson(blockData);
          return Padding(
            padding: EdgeInsets.only(bottom: spacing),
            child: block.build(context),
          );
        }).toList(),
      ),
    );
  }
}

/// Renders content from Sanity portable text
class PortableTextRenderer extends StatelessWidget {
  final List<dynamic> content;
  final EdgeInsets padding;

  const PortableTextRenderer({
    super.key,
    required this.content,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content.map((block) {
          if (block is Map<String, dynamic>) {
            return _renderBlock(context, block);
          }
          return const SizedBox.shrink();
        }).toList(),
      ),
    );
  }

  Widget _renderBlock(BuildContext context, Map<String, dynamic> block) {
    final type = block['_type'];
    
    switch (type) {
      case 'block':
        return _renderTextBlock(context, block);
      case 'image':
        return ImageBlock.fromJson(block).build(context);
      case 'code':
        return CodeBlock.fromJson(block).build(context);
      default:
        return ContentBlock.fromJson(block).build(context);
    }
  }

  Widget _renderTextBlock(BuildContext context, Map<String, dynamic> block) {
    final children = block['children'] as List?;
    if (children == null || children.isEmpty) return const SizedBox.shrink();
    
    final text = children.map((c) => c['text'] ?? '').join('');
    final style = block['style'] ?? 'normal';
    
    TextStyle textStyle;
    switch (style) {
      case 'h1':
        textStyle = Theme.of(context).textTheme.headlineLarge!;
        break;
      case 'h2':
        textStyle = Theme.of(context).textTheme.headlineMedium!;
        break;
      case 'h3':
        textStyle = Theme.of(context).textTheme.headlineSmall!;
        break;
      case 'h4':
        textStyle = Theme.of(context).textTheme.titleLarge!;
        break;
      case 'blockquote':
        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: Colors.grey[400]!, width: 4)),
            color: Colors.grey[100],
          ),
          child: Text(text, style: const TextStyle(fontStyle: FontStyle.italic)),
        );
      default:
        textStyle = Theme.of(context).textTheme.bodyLarge!;
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: textStyle),
    );
  }
}

/// Card block for displaying content in a card
class CardBlock extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Widget? child;
  final VoidCallback? onTap;

  const CardBlock({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null || title != null)
                Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: iconColor ?? Theme.of(context).primaryColor),
                      const SizedBox(width: 12),
                    ],
                    if (title != null)
                      Expanded(
                        child: Text(title!, style: Theme.of(context).textTheme.titleMedium),
                      ),
                  ],
                ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
              if (child != null) ...[
                const SizedBox(height: 12),
                child!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
