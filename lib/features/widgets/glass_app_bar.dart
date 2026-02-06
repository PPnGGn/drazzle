import 'dart:ui';
import 'package:drazzle/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final double height;

  const GlassAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.height = kToolbarHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: title,
      leading: leading,
      actions: actions,
      
      centerTitle: centerTitle,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      
      forceMaterialTransparency: true,
      shadowColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      titleTextStyle: theme.appBarTheme.titleTextStyle,
      iconTheme: theme.appBarTheme.iconTheme,
      flexibleSpace: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: AppColors.purple20.withValues(alpha: 0.3)), // фиолетовый фон с прозрачностью
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Верхняя тень
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 20,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.shadow.withValues(alpha: 0.15),
                                AppColors.shadow.withValues(alpha: 0),
                              ],
                              stops: [0.0, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Нижняя тень
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 20,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                AppColors.shadow.withValues(alpha: 0.2),
                                AppColors.shadow.withValues(alpha: 0),
                              ],
                              stops: [0.0, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Левая тень
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      width: 20,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                AppColors.shadow.withValues(alpha: 0.15),
                                AppColors.shadow.withValues(alpha: 0),
                              ],
                              stops: [0.0, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Правая тень
                    Positioned(
                      top: 0,
                      bottom: 0,
                      right: 0,
                      width: 30,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [
                                AppColors.shadow.withValues(alpha: 0.1),
                                AppColors.shadow.withValues(alpha: 0),
                              ],
                              stops: [0, 1],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
