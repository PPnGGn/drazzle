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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Color Picker',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildColorGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildColorGrid(BuildContext context) {
    // Генерируем палитру цветов как на изображении
    final colors = _generateColorPalette();
    
    return Column(
      children: [
        // Верхняя строка: градиент от белого к черному (9 цветов)
        SizedBox(
          height: 28,
          child: Row(
            children: colors.take(9).map((color) {
              final isSelected = color.value == selectedColor.value;
              return GestureDetector(
                onTap: () {
                  onPick(color);
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(right: 3),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 3),
        // Основная сетка: 9 цветов × 9 строк градиента
        ...List.generate(9, (rowIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: SizedBox(
              height: 28,
              child: Row(
                children: List.generate(9, (colIndex) {
                  final colorIndex = 9 + (rowIndex * 9) + colIndex;
                  final color = colors[colorIndex];
                  final isSelected = color.value == selectedColor.value;
                  
                  return GestureDetector(
                    onTap: () {
                      onPick(color);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.only(right: 3),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                }),
              ),
            ),
          );
        }),
      ],
    );
  }

  List<Color> _generateColorPalette() {
    final colors = <Color>[];
    
    // Верхняя полоса: градиент от белого к черному (9 цветов)
    final graySteps = 9;
    for (int i = 0; i < graySteps; i++) {
      final value = (1.0 - (i / (graySteps - 1)) * 255).round();
      colors.add(Color.fromARGB(255, value, value, value));
    }
    
    // Основные цвета для градиентов (9 цветов)
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
    
    // Создаем градиенты вниз для каждого цвета (9 строк)
    final rows = 9;
    for (int row = 0; row < rows; row++) {
      final brightness = 0.2 + (row / rows) * 0.8; // от 0.2 до 1.0 (темный сверху, светлый снизу)
      
      for (final baseColor in baseColors) {
        final hsl = HSLColor.fromColor(baseColor);
        final adjustedColor = hsl.withLightness(brightness).toColor();
        colors.add(adjustedColor);
      }
    }
    
    return colors;
  }
}
