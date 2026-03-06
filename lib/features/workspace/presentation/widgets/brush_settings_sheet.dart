import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../engine/canvas_controller.dart';

/// Bottom sheet for adjusting brush size and opacity.
class BrushSettingsSheet extends StatefulWidget {
  const BrushSettingsSheet({
    super.key,
    required this.controller,
  });

  final CanvasController controller;

  @override
  State<BrushSettingsSheet> createState() => _BrushSettingsSheetState();
}

class _BrushSettingsSheetState extends State<BrushSettingsSheet> {
  late double _size;
  late double _opacity;

  @override
  void initState() {
    super.initState();
    _size = widget.controller.state.currentTool.size;
    _opacity = widget.controller.state.currentTool.opacity;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Brush Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Preview dot
          Center(
            child: Container(
              width: _size.clamp(4, 80),
              height: _size.clamp(4, 80),
              decoration: BoxDecoration(
                color: widget.controller.state.currentTool.color
                    .withAlpha((_opacity * 255).toInt()),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Size slider
          Row(
            children: [
              const SizedBox(
                width: 60,
                child: Text('Size', style: TextStyle(fontSize: 14)),
              ),
              Expanded(
                child: Slider(
                  value: _size,
                  min: 1,
                  max: 100,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() => _size = value);
                    widget.controller.setBrushSize(value);
                  },
                ),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '${_size.toInt()}px',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),

          // Opacity slider
          Row(
            children: [
              const SizedBox(
                width: 60,
                child: Text('Opacity', style: TextStyle(fontSize: 14)),
              ),
              Expanded(
                child: Slider(
                  value: _opacity,
                  min: 0.05,
                  max: 1.0,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() => _opacity = value);
                    widget.controller.setOpacity(value);
                  },
                ),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '${(_opacity * 100).toInt()}%',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Quick size presets
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [2.0, 5.0, 10.0, 20.0, 40.0].map((size) {
              final isActive = (_size - size).abs() < 1;
              return GestureDetector(
                onTap: () {
                  setState(() => _size = size);
                  widget.controller.setBrushSize(size);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary.withAlpha(30)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isActive
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: size.clamp(4, 30),
                      height: size.clamp(4, 30),
                      decoration: BoxDecoration(
                        color: widget.controller.state.currentTool.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
