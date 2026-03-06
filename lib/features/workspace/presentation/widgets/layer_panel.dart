import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/canvas_layer.dart';
import '../engine/canvas_controller.dart';

/// Side panel / bottom sheet showing the layer stack with management controls.
class LayerPanel extends StatelessWidget {
  const LayerPanel({
    super.key,
    required this.controller,
  });

  final CanvasController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    // Display layers in reverse order (top layer first)
    final layers = state.layers.reversed.toList();

    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Layers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => controller.addLayer(),
                      tooltip: 'Add Layer',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: state.layers.length > 1
                          ? () {
                              if (state.activeLayerId != null) {
                                controller.removeLayer(state.activeLayerId!);
                              }
                            }
                          : null,
                      tooltip: 'Delete Layer',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Layer list
          Flexible(
            child: ReorderableListView.builder(
              shrinkWrap: true,
              itemCount: layers.length,
              onReorder: (oldIndex, newIndex) {
                // Convert reversed indices back to actual indices
                final actualOld = layers.length - 1 - oldIndex;
                final actualNew = layers.length - 1 - newIndex;
                controller.reorderLayers(actualOld, actualNew);
              },
              itemBuilder: (context, index) {
                final layer = layers[index];
                final isActive = layer.id == state.activeLayerId;
                return _LayerTile(
                  key: ValueKey(layer.id),
                  layer: layer,
                  isActive: isActive,
                  onTap: () => controller.setActiveLayer(layer.id),
                  onVisibilityToggle: () =>
                      controller.toggleLayerVisibility(layer.id),
                  onOpacityChange: (opacity) =>
                      controller.setLayerOpacity(layer.id, opacity),
                  onRename: (name) =>
                      controller.renameLayer(layer.id, name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LayerTile extends StatelessWidget {
  const _LayerTile({
    super.key,
    required this.layer,
    required this.isActive,
    this.onTap,
    this.onVisibilityToggle,
    this.onOpacityChange,
    this.onRename,
  });

  final CanvasLayer layer;
  final bool isActive;
  final VoidCallback? onTap;
  final VoidCallback? onVisibilityToggle;
  final ValueChanged<double>? onOpacityChange;
  final ValueChanged<String>? onRename;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withAlpha(20)
            : Colors.transparent,
        border: Border(
          left: BorderSide(
            color: isActive ? AppColors.primary : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: IconButton(
          icon: Icon(
            layer.isVisible ? Icons.visibility : Icons.visibility_off,
            size: 20,
            color: layer.isVisible
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onPressed: onVisibilityToggle,
        ),
        title: Text(
          layer.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: layer.isVisible
                ? null
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        subtitle: Row(
          children: [
            Text(
              '${(layer.opacity * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${layer.strokes.length} strokes',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (layer.isLocked)
              const Icon(Icons.lock, size: 16),
            const Icon(Icons.drag_handle, size: 20),
          ],
        ),
      ),
    );
  }
}
