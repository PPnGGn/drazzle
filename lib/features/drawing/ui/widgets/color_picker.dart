import 'package:drazzle/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ColorPicker extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onPick;

  const ColorPicker({
    required this.selectedColor,
    required this.onPick,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          minHeight: 356,
          maxHeight: 520,
          minWidth: 324,
          maxWidth: 460,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.grayc4,
          borderRadius: BorderRadius.circular(16),
        ),
        child: _buildColorGrid(context),
      ),
    );
  }

  Widget _buildColorGrid(BuildContext context) {
    final colors = _generateColorPalette();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Адаптивный размер ячейки
    final cellSize = _calculateCellSize(screenWidth, screenHeight);

    return Flexible(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Верхняя строка: градиент от белого к черному
            _buildColorRow(
              colors.take(9).toList(),
              cellSize,
              selectedColor,
              context,
            ),
            // Основная сетка: 9 цветов × 9 строк градиента
            ...List.generate(9, (rowIndex) {
              final startIndex = 9 + (rowIndex * 9);
              final rowColors = colors.skip(startIndex).take(9).toList();

              return Padding(
                padding: EdgeInsets.zero,
                child: _buildColorRow(
                  rowColors,
                  cellSize,
                  selectedColor,
                  context,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  double _calculateCellSize(double screenWidth, double screenHeight) {
    final maxDialogWidth =
        screenWidth * 0.9 - 32; // 16 padding с каждой стороны
    final cellSize = (maxDialogWidth / 9).floorToDouble();

    return cellSize.clamp(24.0, 48.0);
  }

  Widget _buildColorRow(
    List<Color> colors,
    double cellSize,
    Color selectedColor,
    BuildContext context,
  ) {
    return SizedBox(
      height: cellSize,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: colors.map((color) {
          final isSelected = color.value == selectedColor.value;
          return GestureDetector(
            onTap: () {
              onPick(color);
              Navigator.of(context).pop();
            },
            child: Container(
              width: cellSize,
              height: cellSize,
              decoration: BoxDecoration(
                color: color,
                border: isSelected
                    ? Border.all(color: Colors.white, width: 2)
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Color> _generateColorPalette() {
    final colors = <Color>[];

    //градиент от белого к черному (сверху)
    final graySteps = 9;
    for (int i = 0; i < graySteps; i++) {
      final value = (1.0 - (i / (graySteps - 1)) * 255).round();
      colors.add(Color.fromARGB(255, value, value, value));
    }

    // Основные цвета для градиентов
    final baseColors = [
      // Темно голубой/бирюзовый
      const Color(0xFF008B8B),
      // Синий
      const Color(0xFF0000FF),
      // Фиолетовый
      const Color(0xFF800080),
      // Бордо
      const Color(0xFF800020),
      // Красный
      const Color(0xFFFF0000),
      // Розовый
      const Color(0xFFFF69B4),
      // Оранжевый как апельсин
      const Color(0xFFFF7F50),
      // Желтый
      const Color(0xFFFFFF00),
      // Зеленый
      const Color(0xFF00FF00),
    ];

    // градиенты вниз для каждого цвета
    final rows = 9;
    for (int row = 0; row < rows; row++) {
      final brightness =
          0.2 +
          (row / rows) * 0.8; // от 0.2 до 1.0 (темный сверху, светлый снизу)

      for (final baseColor in baseColors) {
        final hsl = HSLColor.fromColor(baseColor);
        final adjustedColor = hsl.withLightness(brightness).toColor();
        colors.add(adjustedColor);
      }
    }

    return colors;
  }
}
