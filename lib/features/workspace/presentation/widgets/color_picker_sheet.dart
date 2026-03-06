import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A bottom sheet color picker with preset colors and custom HSV picker.
class ColorPickerSheet extends StatefulWidget {
  const ColorPickerSheet({
    super.key,
    required this.currentColor,
    required this.onColorSelected,
  });

  final Color currentColor;
  final ValueChanged<Color> onColorSelected;

  @override
  State<ColorPickerSheet> createState() => _ColorPickerSheetState();
}

class _ColorPickerSheetState extends State<ColorPickerSheet> {
  late HSVColor _hsvColor;

  static const List<Color> _presetColors = [
    Colors.black,
    Color(0xFF333333),
    Color(0xFF666666),
    Color(0xFF999999),
    Colors.white,
    Color(0xFFE74C3C), // Red
    Color(0xFFE67E22), // Orange
    Color(0xFFF1C40F), // Yellow
    Color(0xFF2ECC71), // Green
    Color(0xFF1ABC9C), // Teal
    Color(0xFF3498DB), // Blue
    Color(0xFF9B59B6), // Purple
    Color(0xFFE91E63), // Pink
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
    // Skin tones
    Color(0xFFFDBEA5),
    Color(0xFFF0A68C),
    Color(0xFFD08B5B),
    Color(0xFFAE5D29),
    Color(0xFF614335),
  ];

  @override
  void initState() {
    super.initState();
    _hsvColor = HSVColor.fromColor(widget.currentColor);
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

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Color Picker',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Current color preview
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _hsvColor.toColor(),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Preset colors grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presetColors.map((color) {
              final isSelected =
                  color.value == _hsvColor.toColor().value;
              return GestureDetector(
                onTap: () {
                  setState(() => _hsvColor = HSVColor.fromColor(color));
                  widget.onColorSelected(color);
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Theme.of(context).colorScheme.outline,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Hue slider
          _buildSliderRow(
            label: 'Hue',
            value: _hsvColor.hue,
            max: 360,
            activeColor: _hsvColor.toColor(),
            onChanged: (value) {
              setState(() {
                _hsvColor = _hsvColor.withHue(value);
              });
              widget.onColorSelected(_hsvColor.toColor());
            },
          ),

          // Saturation slider
          _buildSliderRow(
            label: 'Saturation',
            value: _hsvColor.saturation * 100,
            max: 100,
            activeColor: _hsvColor.toColor(),
            onChanged: (value) {
              setState(() {
                _hsvColor = _hsvColor.withSaturation(value / 100);
              });
              widget.onColorSelected(_hsvColor.toColor());
            },
          ),

          // Value (brightness) slider
          _buildSliderRow(
            label: 'Brightness',
            value: _hsvColor.value * 100,
            max: 100,
            activeColor: _hsvColor.toColor(),
            onChanged: (value) {
              setState(() {
                _hsvColor = _hsvColor.withValue(value / 100);
              });
              widget.onColorSelected(_hsvColor.toColor());
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required double value,
    required double max,
    required Color activeColor,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: 0,
              max: max,
              activeColor: activeColor,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '${value.toInt()}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
