import 'dart:convert';
import 'package:drazzle/core/theme/app_colors.dart';
import 'package:drazzle/features/auth/ui/providers/auth_providers.dart';
import 'package:drazzle/features/drawing/models/drawing_model.dart';
import 'package:drazzle/features/gallery/ui/providers/gallery_providers.dart';
import 'package:drazzle/features/gallery/ui/widgets/gallery_shimmer_widget.dart';
import 'package:drazzle/features/widgets/glass_app_bar.dart';
import 'package:drazzle/features/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class GalleryPage extends ConsumerWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawingsAsync = ref.watch(userDrawingsProvider);

    return Scaffold(
      appBar: GlassAppBar(
        title: const Text('Галерея'),
        leading: IconButton(
          icon: SvgPicture.asset('assets/svg/logout.svg'),
          onPressed: () async {
            _logoutDialog(context, ref);
          },
        ),
        actions: drawingsAsync.when(
          data: (drawings) => drawings.isNotEmpty
              ? [
                  IconButton(
                    onPressed: () => context.push('/drawing'),
                    icon: SvgPicture.asset('assets/svg/paint.svg'),
                    tooltip: 'Создать',
                  ),
                ]
              : null,
          loading: () => null,
          error: (error, stackTrace) => null,
        ),
      ),
      body: drawingsAsync.when(
        data: (drawings) {
          return Stack(
            children: [
              // Фон
              Image.asset(
                'assets/png/background_img.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
              ),

              // Контент
              drawings.isEmpty
                  ? _buildEmptyGallery(context)
                  : _buildGallery(drawings, context, ref),
            ],
          );
        },
        loading: () => Stack(
          children: [
            Image.asset(
              'assets/png/background_img.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
            ),
            const GalleryShimmer(),
          ],
        ),
        error: (error, stack) => Stack(
          children: [
            Image.asset(
              'assets/png/background_img.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Ошибка загрузки: $error',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(userDrawingsProvider),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final authUseCase = ref.read(authUseCaseProvider);
              authUseCase.logoutUseCase();
            },
            child: const Text('Выйти', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  // Пустая галерея
  Widget _buildEmptyGallery(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GradientButton(
            onPressed: () => context.push('/drawing'),
            text: "Создать",
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Галерея с рисунками
  Widget _buildGallery(
    List<DrawingModel> drawings,
    BuildContext context,
    WidgetRef ref,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 46,
        bottom: 16.0,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: drawings.length,
      itemBuilder: (context, index) {
        final drawing = drawings[index];
        return _buildDrawingCard(drawing, context, ref, index);
      },
    );
  }

  // Карточка рисунка
  Widget _buildDrawingCard(
    DrawingModel drawing,
    BuildContext context,
    WidgetRef ref,
    int index,
  ) {
    final heroTag = 'gallery_image_${drawing.id}_$index';

    return GestureDetector(
      onTap: () async {
        final imageUrl = drawing.imageUrl.isNotEmpty
            ? drawing.imageUrl
            : drawing.thumbnailUrl ?? '';

        final ImageProvider? provider = _tryBuildImageProvider(imageUrl);
        if (provider != null) {
          try {
            await precacheImage(provider, context);
          } catch (_) {
            // ignore
          }
        }

        if (!context.mounted) return;

        context.push(
          '/image-viewer',
          extra: {'imageUrl': imageUrl, 'heroTag': heroTag},
        );
      },
      onLongPress: () =>
          _showDeleteDialog(context: context, ref: ref, drawingId: drawing.id),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Hero(
          tag: heroTag,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            child: _buildImage(drawing),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog({
    required BuildContext context,
    required WidgetRef ref,
    required String drawingId,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить рисунок?'),
        content: const Text('Действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final storageService = ref.read(firebaseStorageServiceProvider);
      await storageService.deleteDrawing(drawingId);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка удаления: $e')));
    }
  }

  // Отображение изображения
  Widget _buildImage(DrawingModel drawing) {
    final imageUrl = drawing.imageUrl.isNotEmpty
        ? drawing.imageUrl
        : drawing.thumbnailUrl ?? '';

    // Base64 изображение
    if (imageUrl.startsWith('data:image')) {
      try {
        final base64Data = imageUrl.split(',').last;
        final bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      } catch (e) {
        return _buildPlaceholder();
      }
    }

    // Network изображение
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  // Заглушка для изображения
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.image, size: 48, color: Colors.grey),
      ),
    );
  }

  ImageProvider? _tryBuildImageProvider(String imageUrl) {
    if (imageUrl.startsWith('data:image')) {
      try {
        final base64Data = imageUrl.split(',').last;
        final bytes = base64Decode(base64Data);
        return MemoryImage(bytes);
      } catch (_) {
        return null;
      }
    }

    if (imageUrl.isNotEmpty) {
      return NetworkImage(imageUrl);
    }

    return null;
  }
}
