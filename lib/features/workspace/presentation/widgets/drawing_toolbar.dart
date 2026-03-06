import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/drawing_tool.dart';
import '../engine/canvas_controller.dart';

/// Top/bottom toolbar for the drawing workspace with tool selection.
class DrawingToolbar extends StatelessWidget {
  const DrawingToolbar({
    super.key,
    required this.controller,
    required this.onColorPickerTap,
    required this.onLayerPanelTap,
    required this.onBrushSettingsTap,
  });

  final CanvasController controller;
  final VoidCallback onColorPickerTap;
  final VoidCallback onLayerPanelTap;
  final VoidCallback onBrushSettingsTap;

  @override
  Widget build(BuildContext context) {
    final tool = controller.state.currentTool;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Brush tool
            _ToolButton(
              icon: Icons.brush,
              label: 'Brush',
              isActive: tool.type == ToolType.brush,
              onTap: () => controller.setToolType(ToolType.brush),
            ),
            // Pencil tool
            _ToolButton(
              icon: Icons.edit,
              label: 'Pencil',
              isActive: tool.type == ToolType.pencil,
              onTap: () => controller.setToolType(ToolType.pencil),
            ),
            // Eraser tool
            _ToolButton(
              icon: Icons.auto_fix_high,
              label: 'Eraser',
              isActive: tool.type == ToolType.eraser,
              onTap: () => controller.setToolType(ToolType.eraser),
            ),
            // Color picker
            GestureDetector(
              onTap: onColorPickerTap,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: tool.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                    width: 2,
                  ),
                ),
              ),
            ),
            // Brush size / settings
            _ToolButton(
              icon: Icons.tune,
              label: 'Size',
              isActive: false,
              onTap: onBrushSettingsTap,
            ),
            // Layers
            _ToolButton(
              icon: Icons.layers,
              label: 'Layers',
              isActive: false,
              onTap: onLayerPanelTap,
              badge: '${controller.state.layers.length}',
            ),
            // Undo
            _ToolButton(
              icon: Icons.undo,
              label: 'Undo',
              isActive: false,
              isEnabled: controller.canUndo,
              onTap: controller.canUndo ? controller.undo : null,
            ),
            // Redo
            _ToolButton(
              icon: Icons.redo,
              label: 'Redo',
              isActive: false,
              isEnabled: controller.canRedo,
              onTap: controller.canRedo ? controller.redo : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.isActive,
    this.isEnabled = true,
    this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final bool isEnabled;
  final VoidCallback? onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary.withAlpha(30)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: !isEnabled
                      ? Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(77)
                      : isActive
                          ? AppColors.primary
                          : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (badge != null)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: isActive
                  ? AppColors.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
