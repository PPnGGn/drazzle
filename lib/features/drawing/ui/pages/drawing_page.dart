import 'dart:typed_data';
import 'package:drazzle/features/drawing/domain/drawing_controller.dart';
import 'package:drazzle/features/drawing/ui/widgets/brush_size_dialog.dart';
import 'package:drazzle/features/drawing/ui/widgets/color_picker.dart';
import 'package:drazzle/features/drawing/ui/widgets/editor_button.dart';
import 'package:drazzle/features/drawing/ui/widgets/painter.dart';
import 'package:drazzle/features/widgets/glass_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class DrawningPage extends ConsumerStatefulWidget {
  final Uint8List? backgroundImage;
  final bool closeOnSave;
  const DrawningPage({
    this.backgroundImage,
    this.closeOnSave = false,
    super.key,
  });

  @override
  ConsumerState<DrawningPage> createState() => _EditorPageState();
}

class _EditorPageState extends ConsumerState<DrawningPage> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(drawingControllerProvider.notifier)
          .initializeEditor(backgroundImage: widget.backgroundImage);
    });
  }

  void _onSavePressed() {
    final isLoading = ref.read(
      drawingControllerProvider.select(
        (s) => s.operationState is DrawingOperationLoading,
      ),
    );

    if (isLoading) return; // Предотвращаем множественные нажатия

    ref
        .read(drawingControllerProvider.notifier)
        .saveDrawing(_repaintBoundaryKey);
    ref
        .read(drawingControllerProvider.notifier)
        .saveLocalImage(_repaintBoundaryKey);
  }

  Future<void> _onBrushPressed() async {
    final currentWidth = ref.read(drawingControllerProvider).selectedWidth;
    final newWidth = await showDialog<double>(
      context: context,
      builder: (context) => BrushSizeDialog(initialSize: currentWidth),
    );

    if (newWidth != null && mounted) {
      ref.read(drawingControllerProvider.notifier).changeBrushWidth(newWidth);
    }
  }

  void _onColorPressed() {
    final currentColor = ref.read(drawingControllerProvider).selectedColor;
    showDialog(
      context: context,
      builder: (_) => ColorPicker(
        selectedColor: currentColor,
        onPick: (color) {
          if (mounted) {
            ref.read(drawingControllerProvider.notifier).changeColor(color);
          }
        },
      ),
    );
  }

  // ластик
  void _onEraserPressed() {
    ref.read(drawingControllerProvider.notifier).toggleEraser();
  }

  // очистка холста
  // void _onClearPressed() {
  //   ref.read(drawingControllerProvider.notifier).clearCanvas();
  // }

  // импорт изображения
  Future<void> _onImportImage() async {
    await ref.read(drawingControllerProvider.notifier).importImage();
  }

  // экспорт изображения
  Future<void> _onExportPressed() async {
    await ref
        .read(drawingControllerProvider.notifier)
        .exportDrawing(_repaintBoundaryKey, context);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(drawingControllerProvider, (previous, next) {
      if (next.operationState is DrawingOperationError) {
        // сбросить состояние ошибки
        Future.microtask(() {
          ref.read(drawingControllerProvider.notifier).resetOperationState();
        });
      }
      // проверка успешного сохранения
      if (next.operationState is DrawingOperationSuccess &&
          previous?.operationState is! DrawingOperationSuccess) {
        final successState = next.operationState as DrawingOperationSuccess;

        Future.microtask(() {
          ref.read(drawingControllerProvider.notifier).resetOperationState();
        });

        if (successState.operation == 'save') {
          Future.microtask(() {
            if (context.mounted) {
              context.go('/gallery');
            }
          });
        }
      }
    });

    return Scaffold(
      appBar: GlassAppBar(
        title: const Text('Редактор'),
        leading: IconButton(
          icon: SvgPicture.asset('assets/svg/arrow_back.svg'),
          onPressed: () => context.pop(),
          tooltip: 'Назад',
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final isLoading = ref.watch(
                drawingControllerProvider.select(
                  (s) => s.operationState is DrawingOperationLoading,
                ),
              );
              return IconButton(
                icon: SvgPicture.asset('assets/svg/check.svg'),
                onPressed: isLoading ? null : _onSavePressed,
                tooltip: 'Сохранить',
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 21),
        child: Column(
          children: [
            SizedBox(
              height: 86,
              child: Consumer(
                builder: (context, ref, child) {
                  final isEraser = ref.watch(
                    drawingControllerProvider.select((s) => s.isEraserMode),
                  );
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      EditorButton(
                        icon: SvgPicture.asset('assets/svg/export.svg'),
                        onTap: _onExportPressed,
                        tooltip: 'Экспорт',
                      ),
                      const SizedBox(width: 12),
                      EditorButton(
                        icon: SvgPicture.asset('assets/svg/import.svg'),
                        onTap: _onImportImage,
                        tooltip: 'Импорт из галереи',
                      ),
                      const SizedBox(width: 12),
                      EditorButton(
                        icon: SvgPicture.asset('assets/svg/pen.svg'),
                        onTap: _onBrushPressed,
                        tooltip: 'Размер кисти',
                      ),

                      const SizedBox(width: 12),
                      EditorButton(
                        icon: SvgPicture.asset('assets/svg/eraser.svg'),
                        onTap: _onEraserPressed,
                        tooltip: isEraser ? 'Выключить ластик' : 'Ластик',
                        isActive: isEraser,
                      ),
                      const SizedBox(width: 12),
                      EditorButton(
                        icon: SvgPicture.asset('assets/svg/palette.svg'),
                        onTap: _onColorPressed,
                        tooltip: 'Цвет',
                      ),
                      // const SizedBox(width: 12),
                      // EditorButton(
                      //   icon: Icon(Icons.clear_all),
                      //   onTap: _onClearPressed,
                      //   tooltip: 'Очистить',
                      // ),
                    ],
                  );
                },
              ),
            ),

            // Загрузка
            Consumer(
              builder: (context, ref, _) {
                final isLoading = ref.watch(
                  drawingControllerProvider.select(
                    (s) => s.operationState is DrawingOperationLoading,
                  ),
                );
                if (isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: LinearProgressIndicator(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Холст для рисования
            Expanded(
              child: GestureDetector(
                onPanDown: (details) => ref
                    .read(drawingControllerProvider.notifier)
                    .startStroke(details.localPosition),
                onPanUpdate: (details) => ref
                    .read(drawingControllerProvider.notifier)
                    .updateStroke(details.localPosition),
                onPanEnd: (_) =>
                    ref.read(drawingControllerProvider.notifier).endStroke(),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: RepaintBoundary(
                    key: _repaintBoundaryKey,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Consumer(
                          builder: (context, ref, _) {
                            final bgImage = ref.watch(
                              drawingControllerProvider.select(
                                (s) => s.backgroundImage,
                              ),
                            );
                            return bgImage != null
                                ? Image.memory(bgImage, fit: BoxFit.cover)
                                : Container(color: Colors.white);
                          },
                        ),

                        Consumer(
                          builder: (context, ref, child) {
                            final strokes = ref.watch(
                              drawingControllerProvider.select(
                                (s) => s.strokes,
                              ),
                            );
                            final currentStroke = ref.watch(
                              drawingControllerProvider.select(
                                (s) => s.currentStroke,
                              ),
                            );

                            return CustomPaint(
                              painter: Painter(
                                strokes: strokes,
                                currentStroke: currentStroke,
                              ),
                              child: Container(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
