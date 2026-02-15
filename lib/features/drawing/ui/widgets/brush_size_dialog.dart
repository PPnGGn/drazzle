import 'package:flutter/cupertino.dart';


// Диалог выбора размера кисти
class BrushSizeDialog extends StatefulWidget {
  final double initialSize;

  const BrushSizeDialog({required this.initialSize, super.key});

  @override
  State<BrushSizeDialog> createState() => _BrushSizeDialogState();
}

class _BrushSizeDialogState extends State<BrushSizeDialog> {
  late double _currentSize;

  @override
  void initState() {
    super.initState();
    _currentSize = widget.initialSize;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('Размер кисти'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoSlider(
            value: _currentSize,
            min: 1,
            max: 20,
           
            onChanged: (value) => setState(() => _currentSize = value),
          ),
          Text('${_currentSize.toStringAsFixed(1)} px'),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context, _currentSize),
          child: const Text('Применить'),
        ),
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
          isDestructiveAction: true,
        ),
      ],
    );
  }
}
